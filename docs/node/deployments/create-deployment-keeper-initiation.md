---
sidebar_position: 5
---

# Create Deployment Keeper Initiation

In a prior section the Handler matching of the message `MsgCreateDeployment` was introduced.  Including the `NewHandler` message correlation logic anew below for clarity.

```
func NewHandler(keeper keeper.IKeeper, mkeeper MarketKeeper, ekeeper EscrowKeeper, authzKeeper AuthzKeeper) sdk.Handler {
	ms := NewServer(keeper, mkeeper, ekeeper, authzKeeper)

	return func(ctx sdk.Context, msg sdk.Msg) (*sdk.Result, error) {
		switch msg := msg.(type) {
		case *types.MsgCreateDeployment:
			res, err := ms.CreateDeployment(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)
```

When the `MsgCreateDeployment` is received and correlated in the Handler, the `CreateDeployment` method is called.  This method is found in `node/x/deployment/handler/server.go`.

Several validations are performed - such as `GetDeployment` to ensure that the deployment does not already exist, assurance that the minimum deposit is fulfilled, etc - and eventually the following methods are called for deployment, order, and escrow blockchain entries.

* ms.deployment.Create
* ms.market.CreateOrder
* ms.escrow.AccountCreate

The methods called - and as reviewed in the subsequent section - call their respective Keepers for blockchain store population.

```
func (ms msgServer) CreateDeployment(goCtx context.Context, msg *types.MsgCreateDeployment) (*types.MsgCreateDeploymentResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	if _, found := ms.deployment.GetDeployment(ctx, msg.ID); found {
		return nil, types.ErrDeploymentExists
	}

	minDeposit := ms.deployment.GetParams(ctx).DeploymentMinDeposit

	if minDeposit.Denom != msg.Deposit.Denom {
		return nil, errors.Wrapf(types.ErrInvalidDeposit, "mininum:%v received:%v", minDeposit, msg.Deposit)
	}
	if minDeposit.Amount.GT(msg.Deposit.Amount) {
		return nil, errors.Wrapf(types.ErrInvalidDeposit, "mininum:%v received:%v", minDeposit, msg.Deposit)
	}

	deployment := types.Deployment{
		DeploymentID: msg.ID,
		State:        types.DeploymentActive,
		Version:      msg.Version,
		CreatedAt:    ctx.BlockHeight(),
	}

	if err := types.ValidateDeploymentGroups(msg.Groups); err != nil {
		return nil, errors.Wrap(types.ErrInvalidGroups, err.Error())
	}

	owner, err := sdk.AccAddressFromBech32(msg.ID.Owner)
	if err != nil {
		return &types.MsgCreateDeploymentResponse{}, err
	}

	depositor, err := sdk.AccAddressFromBech32(msg.Depositor)
	if err != nil {
		return &types.MsgCreateDeploymentResponse{}, err
	}

	if err = ms.authorizeDeposit(ctx, owner, depositor, msg.Deposit); err != nil {
		return nil, err
	}

	groups := make([]types.Group, 0, len(msg.Groups))

	for idx, spec := range msg.Groups {
		groups = append(groups, types.Group{
			GroupID:   types.MakeGroupID(deployment.ID(), uint32(idx+1)),
			State:     types.GroupOpen,
			GroupSpec: spec,
			CreatedAt: ctx.BlockHeight(),
		})
	}

	if err := ms.deployment.Create(ctx, deployment, groups); err != nil {
		return nil, errors.Wrap(types.ErrInternal, err.Error())
	}

	// create orders
	for _, group := range groups {
		if _, err := ms.market.CreateOrder(ctx, group.ID(), group.GroupSpec); err != nil {
			return &types.MsgCreateDeploymentResponse{}, err
		}
	}

	if err := ms.escrow.AccountCreate(ctx,
		types.EscrowAccountForDeployment(deployment.ID()),
		owner,
		depositor,
		msg.Deposit,
	); err != nil {
		return &types.MsgCreateDeploymentResponse{}, err
	}

	return &types.MsgCreateDeploymentResponse{}, nil
}
```