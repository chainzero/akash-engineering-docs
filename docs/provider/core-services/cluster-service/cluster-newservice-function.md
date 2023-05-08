---
sidebar_position: 3
---

# Cluster NewService Function

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/cluster/service.go)

The `NewService` function within `provider/cluster/service.go` invokes:

* Subscription to RPC Node pubsub bus via the `bus.Subscribe` method call
* The call of the `findDeployments` function to discover current deployments in the Kubernetes cluster.  This function is defined in the same file - `service.go` - as the cluster NewService function exists in.
* The call of the `newInventoryService` function which will track new/existing orders and create an inventory reservation when the provider bids on a deployment.

```
func NewService(ctx context.Context, session session.Session, bus pubsub.Bus, client Client, ipOperatorClient operatorclients.IPOperatorClient, waiter waiter.OperatorWaiter, cfg Config) (Service, error) {
	...

	sub, err := bus.Subscribe()
	if err != nil {
		return nil, err
	}

	deployments, err := findDeployments(ctx, log, client, session)
	if err != nil {
		sub.Close()
		return nil, err
	}

	inventory, err := newInventoryService(cfg, log, lc.ShuttingDown(), sub, client, ipOperatorClient, waiter, deployments)
	if err != nil {
		sub.Close()
		return nil, err
	}
```