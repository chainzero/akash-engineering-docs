---
sidebar_position: 9
---

# clusterch Channel Processing

When a result from the prior step is placed onto the `clusterch` channel,  an analysis is made to ensure no errors were encountered during the Kubernetes cluster reservation.  If not error is found a log entry of `Reservation fulfilled` is populated.

```
		case result := <-clusterch:
			clusterch = nil

			if result.Error() != nil {
				reservationCounter.WithLabelValues(metricsutils.OpenLabel, metricsutils.FailLabel)
				o.log.Error("reserving resources", "err", result.Error())
				break loop
			}

			reservationCounter.WithLabelValues(metricsutils.OpenLabel, metricsutils.SuccessLabel)

			o.log.Info("Reservation fulfilled")
```

If the Kubernetes cluster reservation for the order is successful,  the result of calling the `CalculatePrice` method (using the order specs as input) is placed onto the `pricech` channel which provokes the next step of order processing.

Calling `CalculatePrice` provokes the logic to determine price extended thru bid response.

```
			pricech = runner.Do(metricsutils.ObserveRunner(func() runner.Result {
				// Calculate price & bid
				return runner.NewResult(o.cfg.PricingStrategy.CalculatePrice(ctx, group.GroupID.Owner, &group.GroupSpec))
			}, pricingDuration))
```

The `CalculatePrice` function is located in `/bidengine/pricing.go` and will determine the price used in bid response to the order.  The price will be dictated by the order specs - I.e. CPU/memory/storage/replicas, etc - and the Provider's pricing script which defines per specification price.

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/bidengine/pricing.go#L127)

```
func (fp scalePricing) CalculatePrice(_ context.Context, _ string, gspec *dtypes.GroupSpec) (sdk.DecCoin, error) {
	// Use unlimited precision math here.
	// Otherwise a correctly crafted order could create a cost of '1' given
	// a possible configuration
	cpuTotal := decimal.NewFromInt(0)
	memoryTotal := decimal.NewFromInt(0)
	storageTotal := make(Storage)

	for k := range fp.storageScale {
		storageTotal[k] = decimal.NewFromInt(0)
	}

	endpointTotal := decimal.NewFromInt(0)
	ipTotal := decimal.NewFromInt(0).Add(fp.ipScale)
	ipTotal = ipTotal.Mul(decimal.NewFromInt(int64(util.GetEndpointQuantityOfResourceGroup(gspec, atypes.Endpoint_LEASED_IP))))
	...
```