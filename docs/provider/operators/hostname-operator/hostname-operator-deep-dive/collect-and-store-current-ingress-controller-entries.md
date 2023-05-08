---
sidebar_position: 4
---

# Collect and Store Current Ingress Controller Entries

The `monitorUntilError` method calls the `GetHostnameDeploymentConnections` - located in `provider/cluster/kube/client_ingress.go` - which makes a call to the Kubernetes API server for a list of Ingress Controller entries.

The Ingress Controller entries are stored in the `connections` variable which is ranged/looped through and added to the `hostnameOperator` struct map of hostnames.  Future deployments will have their hostname added to the complete, current map when new `providerhost` custom resources are created.

The map of hostnames will be used in downstream logic to determine if an ingress controller entry needs to be created for a `providerhost` custom resource or if the entry already exists and can then be updated or deemed no add/update necessary.

```
func (op *hostnameOperator) monitorUntilError(parentCtx context.Context) error {
	....
	op.log.Info("starting observation")

	connections, err := op.client.GetHostnameDeploymentConnections(ctx)
	....

	for _, conn := range connections {
		leaseID := conn.GetLeaseID()
		hostname := conn.GetHostname()
		entry := managedHostname{
			lastEvent:           nil,
			presentLease:        leaseID,
			presentServiceName:  conn.GetServiceName(),
			presentExternalPort: uint32(conn.GetExternalPort()),
		}

		op.hostnames[hostname] = entry
		op.log.Debug("identified existing hostname connection",
			"hostname", hostname,
			"lease", entry.presentLease,
			"service", entry.presentServiceName,
			"port", entry.presentExternalPort)
	}
}
```