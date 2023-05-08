---
sidebar_position: 3
---

# Leases RPC Endpoint Handler

> [Source code reference location](https://github.com/akash-network/node/blob/master/x/market/handler/handler.go)

The Lease handler matches a case based on the types defined via protobuf and contained within the `node/x/market/types/v1beta2/lease.pb.go` file.  An example of the protobuf file is covered in the subsequent section.

```
func NewHandler(keepers Keepers) sdk.Handler {
	ms := NewServer(keepers)

	return func(ctx sdk.Context, msg sdk.Msg) (*sdk.Result, error) {
		switch msg := msg.(type) {
		case *types.MsgCreateBid:
			res, err := ms.CreateBid(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgCloseBid:
			res, err := ms.CloseBid(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgWithdrawLease:
			res, err := ms.WithdrawLease(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgCreateLease:
			res, err := ms.CreateLease(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgCloseLease:
			res, err := ms.CloseLease(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		default:
			return nil, sdkerrors.ErrUnknownRequest
		}
	}
}
```