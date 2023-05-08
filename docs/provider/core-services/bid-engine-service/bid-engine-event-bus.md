---
sidebar_position: 4
---

# Bid Engine Initiates an Event Bus to Monitor New Orders

The `NewService` function called from `provider/blob/main/bidengine/service.go` checks for existing orders and subscribes to a RPC node event bus for new order processing.

Eventually the `run` method in this package is called with a service type passed in.

> [Source code reference location](https://github.com/akash-network/provider/blob/main/bidengine/service.go)

```
func NewService(ctx context.Context, session session.Session, cluster cluster.Cluster, bus pubsub.Bus, waiter waiter.OperatorWaiter, cfg Config) (Service, error) {
	session = session.ForModule("bidengine-service")

	existingOrders, err := queryExistingOrders(ctx, session)
	if err != nil {
		session.Log().Error("finding existing orders", "err", err)
		return nil, err
	}

	sub, err := bus.Subscribe()
	if err != nil {
		return nil, err
	}
	
	...
	s := &service{
		session:  session,
		cluster:  cluster,
		bus:      bus,
		sub:      sub,
		statusch: make(chan chan<- *Status),
		orders:   make(map[string]*order),
		drainch:  make(chan *order),
		lc:       lifecycle.New(),
		cfg:      cfg,
		pass:     providerAttrService,
		waiter:   waiter,
	}

	go s.lc.WatchContext(ctx)
	go s.run(ctx, existingOrders)
```