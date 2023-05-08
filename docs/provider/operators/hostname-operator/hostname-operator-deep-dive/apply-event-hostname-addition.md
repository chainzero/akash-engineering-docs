---
sidebar_position: 6
---

# Apply the Event/Hostname Addition

The `applyEvent` method - located in the same file `hostname_operator.go` file as the `run` function - matches the event type (I.e. `ProviderResourceAdd`).  The event type was set prior via the `ObserveHostnameState` method.

Following the path of a new `providerhost` resource add as an example the matched event is then passed to the `applyAddOrUpdateEvent` method.

```
func (op *hostnameOperator) applyEvent(ctx context.Context, ev ctypes.HostnameResourceEvent) error {
	op.log.Debug("apply event", "event-type", ev.GetEventType(), "hostname", ev.GetHostname())
	switch ev.GetEventType() {
	...
	case ctypes.ProviderResourceAdd, ctypes.ProviderResourceUpdate:
		if op.isEventIgnored(ev) {
			op.log.Info("ignoring event for", "lease", ev.GetLeaseID().String())
			return nil
		}
		err := op.applyAddOrUpdateEvent(ctx, ev)
	...

}
```