---
sidebar_position: 5
---

# Manifest Manager Logic

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/manifest/manager.go)

The  `newManager` function calls the `run` method - passing in the `manager` struct that includes the  `leasech` channel - which invokes a perpetual for loop to await events on various channels.

The manifest manager instance is returned to the `handleLease` method in `service.go`.

```
func newManager(h *service, daddr dtypes.DeploymentID) *manager {
	session := h.session.ForModule("manifest-manager")

	...

	go m.lc.WatchChannel(h.lc.ShuttingDown())
	go m.run(h.managerch)

	return m
}
```

The `handleLease` method in `service.go` continues and calls another `handleLease` method in `manager.go` passing in lease events received on the bus.

```
func (s *service) handleLease(ev event.LeaseWon, isNew bool) {
	....

	manager := s.ensureManager(ev.LeaseID.DeploymentID())

	manager.handleLease(ev)
}
```

The handleLease method in `manager.go` puts the event onto the `leasech` channel.

```
func (m *manager) handleLease(ev event.LeaseWon) {
	select {
	case m.leasech <- ev:
	case <-m.lc.ShuttingDown():
		m.log.Error("not running: handle manifest", "lease", ev.LeaseID)
	}
}
```

When the manifest manager `run` method receives an event on the `leasech` channel the `maybeFetchData` method is called and results is placed onto the `runch` channel.

```
func (m *manager) run(donech chan<- *manager) {
	..

loop:
	for {
		....
		select {
		....
		case ev := <-m.leasech:
			m.log.Info("new lease", "lease", ev.LeaseID)
			m.clearFetched()
			m.maybeScheduleStop()
			runch = m.maybeFetchData(ctx, runch)
```

The `maybeFetchData` method attempts to fetch deployment and lease data with associated downstream logic.

```
func (m *manager) maybeFetchData(ctx context.Context, runch <-chan runner.Result) <-chan runner.Result {
	if runch != nil {
		return runch
	}

	if !m.fetched || time.Since(m.fetchedAt) > m.config.CachedResultMaxAge {
		m.clearFetched()
		return m.fetchData(ctx)
	}
	return runch
}
```