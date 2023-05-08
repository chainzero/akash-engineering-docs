---
sidebar_position: 9
---

# Additional Inventory Service Notes

As described in the previous section the invoke of the NewService function spawns a call of the `newInventoryService` function.

The `newInventoryService` function is defined in `provider/cluster/inventory.go`.

When the Provider's bid engine determines that it should bid on a new deployment the `Reserve` method is called.  Downstream logic places this reservation into inventory.

In summation this Bid Engine logic is the mechanism in which the Provider reserves Kubernetes resources and places the reservation into inventory while the bid is pending.

> [Source code reference location](https://github.com/akash-network/provider/blob/95458f90c22c3be343efa7402ba4ac72100e251c/bidengine/order.go)

```
		case result := <-shouldBidCh:
			....
			clusterch = runner.Do(metricsutils.ObserveRunner(func() runner.Result {
				v := runner.NewResult(o.cluster.Reserve(o.orderID, group))
					return v
			}, reservationDuration))
```