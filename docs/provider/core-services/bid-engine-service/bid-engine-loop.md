---
sidebar_position: 4
---

# Bid Engine Loop is Created to React to New Order Receipt and Then Process Order

Within the `run` function of `provider/bidengine/service.go` an endless for loop monitors for events placed onto a channel.

When an event of type `EventOrderCreated` is seen a call to the `newOrder` function - which exists in `provider/bidengine/order.go` - is initiated.  The `newOrder` function call creates a new manager for a specific order.

```
loop:
	for {
		select {
		case <-s.lc.ShutdownRequest():
			s.lc.ShutdownInitiated(nil)
			break loop

		case ev := <-s.sub.Events():
			switch ev := ev.(type) { // nolint: gocritic
			case mtypes.EventOrderCreated:
				// new order
				key := mquery.OrderPath(ev.ID)

				s.session.Log().Info("order detected", "order", key)

				if order := s.orders[key]; order != nil {
					s.session.Log().Debug("existing order", "order", key)
					break
				}

				// create an order object for managing the bid process and order lifecycle
				order, err := newOrder(s, ev.ID, s.cfg, s.pass, false)
				if err != nil {
					s.session.Log().Error("handling order", "order", key, "err", err)
					break
				}

				ordersCounter.WithLabelValues("start").Inc()
				s.orders[key] = order
```