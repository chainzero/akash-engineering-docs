---
sidebar_position: 2
---

# Leases Tendermint RPC Endpoint Overview

Client communication for Akash lease creation, updates, and deletions occurs via the Tendermint RPC implementation.

Further details on the Tendermint RPC implementation can be found [here](https://docs.cosmos.network/main/core/grpc\_rest#tendermint-rpc).

The source code review in this section primarily focus on the module directory of `node/x/market`.

### Leases RPC Endpoint Route Registration

> [Source code reference location](https://github.com/akash-network/node/blob/master/x/market/module.go)

The RPC Endpoint for Deployments - allowing inbound communication for CRUD operations - is found in `node/x/market/module.go`.

When encountered this Route calls the `NewHandler` method for further message handling.

```
func (am AppModule) Route() sdk.Route {
	return sdk.NewRoute(types.RouterKey, handler.NewHandler(am.keepers))
}
```