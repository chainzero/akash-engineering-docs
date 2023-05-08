---
sidebar_position: 5
---

# Creating Deployment Managers for Existing Deployments

Within in the `run` method a for loop creates a deployment manager for pre-existing deployments on the provider.

Further explanation of the deployment manager can be found in a later section of this documentation section.

```
func (s *service) run(ctx context.Context, deployments []ctypes.Deployment) {
	...

	for _, deployment := range deployments {
		key := deployment.LeaseID()
		mgroup := deployment.ManifestGroup()
		s.managers[key] = newDeploymentManager(s, deployment.LeaseID(), &mgroup, false)
		s.updateDeploymentManagerGauge()
	}
```
