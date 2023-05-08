---
sidebar_position: 3
---

# Deployments RPC Endpoint Handler

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/x/deployment/handler/handler.go#L12)

The Deployments handler matches a case based on the types defined via protobuf and contained within the `node/x/deployment/types/v1beta2/deploymentmsg.pb.go` file.  An example of the protobuf file is covered in the subsequent section.

```
func NewHandler(keeper keeper.IKeeper, mkeeper MarketKeeper, ekeeper EscrowKeeper, authzKeeper AuthzKeeper) sdk.Handler {
	ms := NewServer(keeper, mkeeper, ekeeper, authzKeeper)

	return func(ctx sdk.Context, msg sdk.Msg) (*sdk.Result, error) {
		switch msg := msg.(type) {
		case *types.MsgCreateDeployment:
			res, err := ms.CreateDeployment(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgDepositDeployment:
			res, err := ms.DepositDeployment(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgUpdateDeployment:
			res, err := ms.UpdateDeployment(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgCloseDeployment:
			res, err := ms.CloseDeployment(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgCloseGroup:
			res, err := ms.CloseGroup(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgPauseGroup:
			res, err := ms.PauseGroup(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		case *types.MsgStartGroup:
			res, err := ms.StartGroup(sdk.WrapSDKContext(ctx), msg)
			return sdk.WrapServiceResult(ctx, res, err)

		default:
			return nil, sdkerrors.ErrUnknownRequest
		}
	}
}
```