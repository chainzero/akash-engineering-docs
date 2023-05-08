---
sidebar_position: 2
---

# Deployments Tendermint RPC Endpoint Overview

Client communication for Akash deployment creation, updates, and deletions occurs via the Tendermint RPC implementation.

Further details on the Tendermint RPC implementation can be found [here](https://docs.cosmos.network/main/core/grpc\_rest#tendermint-rpc).

The source code review in this section primarily focus on the module directory of `node/x/deployment`.

## Deployments RPC Endpoint Route Registration

> [Source code reference location](https://github.com/akash-network/node/blob/52d5ee5caa2c6e5a5e59893d903d22fe450d6045/x/deployment/module.go#L138)

The RPC Endpoint for Deployments - allowing inbound communication for CRUD operations - is found in `node/x/deployment/module.go`.

When encountered this Route calls the `NewHandler` method for further message handling.

```
func (am AppModule) Route() sdk.Route {
	return sdk.NewRoute(types.RouterKey, handler.NewHandler(am.keeper, am.mkeeper, am.ekeeper, am.authzKeeper))
}
```