---
sidebar_position: 7
---

# Cluster Service Deployment Managers

The call of the `newDeploymentManager` function - located in `provider/cluster/manager.go` - provokes a deployment specific lifecycle manager.

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/cluster/manager.go#L81)

```
func newDeploymentManager(s *service, lease mtypes.LeaseID, mgroup *manifest.Group, isNewLease bool) *deploymentManager {
	....

	dm := &deploymentManager{
		bus:                 s.bus,
		client:              s.client,
		session:             s.session,
		state:               dsDeployActive,
		lease:               lease,
		mgroup:              mgroup,
		wg:                  sync.WaitGroup{},
		updatech:            make(chan *manifest.Group),
		teardownch:          make(chan struct{}),
		log:                 logger,
		lc:                  lifecycle.New(),
		hostnameService:     s.HostnameService(),
		config:              s.config,
		serviceShuttingDown: s.lc.ShuttingDown(),
		currentHostnames:    make(map[string]struct{}),
	}

	...

	go func() {
		<-dm.lc.Done()
		dm.log.Debug("sending manager into channel")
		s.managerch <- dm
	}()

	err := s.bus.Publish(event.LeaseAddFundsMonitor{LeaseID: lease, IsNewLease: isNewLease})
	if err != nil {
		s.log.Error("unable to publish LeaseAddFundsMonitor event", "error", err, "lease", lease)
	}

	return dm
}