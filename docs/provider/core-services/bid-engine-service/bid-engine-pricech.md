---
sidebar_position: 10
---

# pricech Channel Processing

When a result from the prior step is placed onto the `pricech` channel, an analysis is made to ensure that the bid price is not larger than the max price defined in deployment manifest.

If the order gets past the maxPrice check the logs are populated with the `submitting fulfillment` with specified price message.

```
case result := <-pricech:
			pricech = nil
			if result.Error() != nil {
				o.log.Error("error calculating price", "err", result.Error())
				break loop
			}

			price := result.Value().(sdk.DecCoin)
			maxPrice := group.GroupSpec.Price()

			if maxPrice.IsLT(price) {
				o.log.Info("Price too high, not bidding", "price", price.String(), "max-price", maxPrice.String())
				break loop
			}

			o.log.Debug("submitting fulfillment", "price", price)

```

If the bid proceeds we eventually broadcast the bid to the blockchain and write the results of this transaction to the `bidch` channel which provokes additional upstream logic covered in the next section.

```
			bidch = runner.Do(func() runner.Result {
				return runner.NewResult(nil, o.session.Client().Tx().Broadcast(ctx, msg))
			})
```