---
sidebar_position: 4
---

# Cluster Service Listening Bus

The `NewService` function eventually populates a `service` struct and passes the variable to the `run` method which invokes a perpetual listening bus for new deployments.  The `deployments` argument is additionally passed into the `run` method as an argument.

```
	
	s := &service{
		session:                        session,
		client:                         client,
		hostnames:                      hostnames,
		bus:                            bus,
		sub:                            sub,
		inventory:                      inventory,
		statusch:                       make(chan chan<- *ctypes.Status),
		managers:                       make(map[mtypes.LeaseID]*deploymentManager),
		managerch:                      make(chan *deploymentManager),
		checkDeploymentExistsRequestCh: make(chan checkDeploymentExistsRequest),

		log:    log,
		lc:     lc,
		config: cfg,
		waiter: waiter,
	}

	go s.lc.WatchContext(ctx)
	go s.run(ctx, deployments)
```