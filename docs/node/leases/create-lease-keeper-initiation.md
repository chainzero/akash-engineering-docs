---
sidebar_position: 5
---

# Create Lease Keeper Initiation

In a prior section the Handler matching of the message `MsgCreateLease` was introduced.  Including the `NewHandler` message correlation logic anew below for clarity.

```
func NewHandler(keepers Keepers) sdk.Handler {
	ms := NewServer(keepers)

	return func(ctx sdk.Context, msg sdk.Msg) (*sdk.Result, error) {
		switch msg := msg.(type) {
		...

		case *types.MsgCreateLease:
			res, err := ms.CreateLease(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)
		...
	}
}
```

When the `MsgCreateLease` is received and correlated in the Handler, the `CreateLease` method is called.  This method is found in `node/x/market/handler/server.go`.

Several validations are performed - such as `GetBid` to ensure that the associated bid is found, `BidOpen` to ensure that the bid is open, etc - and eventually the following methods are called for lease creation and associated blockchain entries.

* ms.keepers.Market.CreateLease
* ms.keepers.Market.OnOrderMatched
* ms.keepers.Market.OnBidMatched

Additionally all lost bids are closed via:

* ms.keepers.Market.OnBidLost

The methods called - and as reviewed in the subsequent section - call their respective Keepers for blockchain store population.

```
func (ms msgServer) CreateLease(goCtx context.Context, msg *types.MsgCreateLease) (*types.MsgCreateLeaseResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	bid, found := ms.keepers.Market.GetBid(ctx, msg.BidID)
	if !found {
		return &types.MsgCreateLeaseResponse{}, types.ErrBidNotFound
	}

	if bid.State != types.BidOpen {
		return &types.MsgCreateLeaseResponse{}, types.ErrBidNotOpen
	}

	order, found := ms.keepers.Market.GetOrder(ctx, msg.BidID.OrderID())
	if !found {
		return &types.MsgCreateLeaseResponse{}, types.ErrOrderNotFound
	}

	if order.State != types.OrderOpen {
		return &types.MsgCreateLeaseResponse{}, types.ErrOrderNotOpen
	}

	group, found := ms.keepers.Deployment.GetGroup(ctx, order.ID().GroupID())
	if !found {
		return &types.MsgCreateLeaseResponse{}, types.ErrGroupNotFound
	}

	if group.State != dtypes.GroupOpen {
		return &types.MsgCreateLeaseResponse{}, types.ErrGroupNotOpen
	}

	owner, err := sdk.AccAddressFromBech32(msg.BidID.Provider)
	if err != nil {
		return &types.MsgCreateLeaseResponse{}, err
	}

	if err := ms.keepers.Escrow.PaymentCreate(ctx,
		dtypes.EscrowAccountForDeployment(msg.BidID.DeploymentID()),
		types.EscrowPaymentForLease(msg.BidID.LeaseID()),
		owner,
		bid.Price); err != nil {
		return &types.MsgCreateLeaseResponse{}, err
	}

	ms.keepers.Market.CreateLease(ctx, bid)
	ms.keepers.Market.OnOrderMatched(ctx, order)
	ms.keepers.Market.OnBidMatched(ctx, bid)

	// close losing bids
	var lostbids []types.Bid
	ms.keepers.Market.WithBidsForOrder(ctx, msg.BidID.OrderID(), func(bid types.Bid) bool {
		if bid.ID().Equals(msg.BidID) {
			return false
		}
		if bid.State != types.BidOpen {
			return false
		}

		lostbids = append(lostbids, bid)
		return false
	})

	for _, bid := range lostbids {
		ms.keepers.Market.OnBidLost(ctx, bid)
		if err := ms.keepers.Escrow.AccountClose(ctx,
			types.EscrowAccountForBid(bid.ID())); err != nil {
			return &types.MsgCreateLeaseResponse{}, err
		}
	}

	return &types.MsgCreateLeaseResponse{}, nil
}
```