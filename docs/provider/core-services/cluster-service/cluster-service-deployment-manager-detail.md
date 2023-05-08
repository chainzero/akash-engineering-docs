---
sidebar_position: 8
---

# Deployment Manager Detail

When an instance of a Deployment Manager is initialized the `run` method is called with the `deploymentManager` struct passed in.

```
func newDeploymentManager(s *service, lease mtypes.LeaseID, mgroup *manifest.Group, isNewLease bool) *deploymentManager {
    ...
	go dm.run(context.Background())
    ...
}
```

The `run` method calls the `startDeploy` method to initialize the depployment creation in the Kubernetes cluster.

The retrurned value from the `startDeloy` method is placed onto the `runch` channel.

```
func (dm *deploymentManager) run(ctx context.Context) {
    ....
	runch := dm.startDeploy(ctx)
    ....
```

The `startDeploy` method sets the `deploymentManager` struct `state` field to `dsDeployActive`.

The `startDeploy` method exists in `provider/cluster/manager.go`.

A Go routine is launched calling the `doDeploy` method which will conduct the Kubernetes API post for new service and deployment creation.

```

func (dm *deploymentManager) startDeploy(ctx context.Context) <-chan error {
    ....
	dm.state = dsDeployActive

	chErr := make(chan error, 1)

	go func() {
		hostnames, endpoints, err := dm.doDeploy(ctx)
        ....
	}()
    ....
}

```

The `doDeploy` method makes several validations and queries then eventually creates the deployment in Kubernetes via a call of the `dm.client.Deploy` method.  The lease and manifest info is passed into this method as arguments.

The `doDeploy` method exists in `provider/cluster/manager.go`.


```
func (dm *deploymentManager) doDeploy(ctx context.Context) ([]string, []string, error) {
    ....

	if err = dm.checkLeaseActive(ctx); err != nil {
		return nil, nil, err
	}

	currentIPs, err := dm.client.GetDeclaredIPs(ctx, dm.lease)
	if err != nil {
		return nil, nil, err
	}

	// Either reserve the hostnames, or confirm that they already are held
	allHostnames := sdlutil.AllHostnamesOfManifestGroup(*dm.mgroup)
	withheldHostnames, err := dm.hostnameService.ReserveHostnames(ctx, allHostnames, dm.lease)

	if err != nil {
		deploymentCounter.WithLabelValues("reserve-hostnames", "err").Inc()
		dm.log.Error("deploy hostname reservation error", "state", dm.state, "err", err)
		return nil, nil, err
	}
	deploymentCounter.WithLabelValues("reserve-hostnames", "success").Inc()

	dm.log.Info("hostnames withheld", "cnt", len(withheldHostnames))

	hostnamesInThisRequest := make(map[string]struct{})
	for _, hostname := range allHostnames {
		hostnamesInThisRequest[hostname] = struct{}{}
	}

    ....

	err = dm.client.Deploy(deployCtx, dm.lease, dm.mgroup)
	label := "success"
	if err != nil {
		label = "fail"
	}
    ....
}
```