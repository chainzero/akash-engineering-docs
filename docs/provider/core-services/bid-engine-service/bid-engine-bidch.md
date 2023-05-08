---
sidebar_position: 11
---

# bidch Channel Processing

When a result from the prior step is placed onto the `bidch` channel, an error check is made to ensure the bid has not failed for any reason.  And post this final bid validator a message is written to the provider logs of `bid complete`.

The Bid Engine Service logic for single bid processing is now complete.  The Bid Engine perpetual loop will continue to monitor for new orders found on the blockchain and repeat reviewed order processing on each receipt.

```
		case result := <-bidch:
			bidch = nil
			if result.Error() != nil {
				bidCounter.WithLabelValues(metricsutils.OpenLabel, metricsutils.FailLabel).Inc()
				o.log.Error("bid failed", "err", result.Error())
				break loop
			}

			o.log.Info("bid complete")
			bidCounter.WithLabelValues(metricsutils.OpenLabel, metricsutils.SuccessLabel).Inc()

			// Fulfillment placed.
			bidPlaced = true

			bidTimeout = o.getBidTimeout(
```