---
sidebar_position: 5
---

# Bid Engine Order Processing Initiation

When the `newOrder` function within `order.go` is called in the previous step, an `order` struct is populated and then passed to the `run` method.

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/bidengine/order.go#L477)



```
	order := &order{
		cfg:                        cfg,
		orderID:                    oid,
		session:                    session,
		cluster:                    svc.cluster,
		bus:                        svc.bus,
		sub:                        sub,
		log:                        log,
		lc:                         lifecycle.New(),
		reservationFulfilledNotify: reservationFulfilledNotify, // Normally nil in production
		pass:                       pass,
	}

	...

	// Run main loop in separate thread.
	go order.run(checkForExistingBid)
```