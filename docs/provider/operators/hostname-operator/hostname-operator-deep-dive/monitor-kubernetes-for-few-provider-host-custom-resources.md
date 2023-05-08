---
sidebar_position: 5
---

# Monitor Kubernetes for New Provider Host Custom Resources

The  `ObserveHostnameState` function - located within provider/cluster/kube/client\_hostname\_connections.go - monitors for new `providerhost` custom resource adds, updates, or deletes.

The `ObserveHostnameState` method returns new events on a channel which is then taken off the channel within a select block.&#x20;

Finally the event - stored in the `ev` variable once it is pulled off the channel - is passed into the `applyEvent` method.

```
	....
	
	events, err := op.client.ObserveHostnameState(ctx)
	if err != nil {
		cancel()
		return err
	}

loop:
	for {
		select {
		....

		case ev, ok := <-events:
			if !ok {
				exitError = operatorcommon.ErrObservationStopped
				break loop
			}
			err = op.applyEvent(ctx, ev)
			if err != nil {
				op.log.Error("failed applying event", "err", err)
				exitError = err
				break loop
			}
		case <-pruneTicker.C:
			op.prune()
		case <-prepareTicker.C:
			if err := op.server.PrepareAll(); err != nil {
				op.log.Error("preparing web data failed", "err", err)
			}

		}
	}

	cancel()
	op.log.Debug("hostname operator done")
	return exitError
```