---
sidebar_position: 7
---

# Determine if New Ingress Controller Entry is Necessary

A check is conducted to determine if the hostname already exists in the hostname map of the `hostnameOperator (op)` struct.  If such an entry is not found in the map it is deemed a new ingress controller entry is necessary.

The ingress controller entry for the event is then made via the `ConnectHostnameToDeployment` method.

```
func (op *hostnameOperator) applyAddOrUpdateEvent(ctx context.Context, ev ctypes.HostnameResourceEvent) error {
	selectedExpose, err := locateServiceFromManifest(ctx, op.client, ev.GetLeaseID(), ev.GetServiceName(), ev.GetExternalPort())
	if err != nil {
		return err
	}

	leaseID := ev.GetLeaseID()

	op.log.Debug("connecting",
		"hostname", ev.GetHostname(),
		"lease", leaseID,
		"service", ev.GetServiceName(),
		"externalPort", ev.GetExternalPort())
	entry, exists := op.hostnames[ev.GetHostname()]
	....
	if isSameLease {
		shouldConnect := false

		if !exists {
			shouldConnect = true
			op.log.Debug("hostname target is new, applying")
			// Check to see if port or service name is different
		}
		....
		if shouldConnect {
			op.log.Debug("Updating ingress")
			// Update or create the existing ingress
			err = op.client.ConnectHostnameToDeployment(ctx, directive)
		}
		....
}
```