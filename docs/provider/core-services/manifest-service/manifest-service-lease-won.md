---
sidebar_position: 4
---

# Monitor Service Loop is Created to React to New Lease Won Events

Within the run function of `provider/manifest/service.go` an endless for loop monitors for events placed onto a channel.  When a event is received for the RPC node event bus of type LeaseWon the `handleLease` method is called.

```
	for {
		select {

		case err := <-s.lc.ShutdownRequest():
			s.lc.ShutdownInitiated(err)
			break loop

		case ev := <-s.sub.Events():
			switch ev := ev.(type) {

			case event.LeaseWon:
				if ev.LeaseID.GetProvider() != s.session.Provider().Address().String() {
					continue
				}
				s.session.Log().Info("lease won", "lease", ev.LeaseID)
				s.handleLease(ev, true)
```

The `handleLease` method determines if a manager is active for the deployment via the `ensureManager` method.  The manifest manager logic exists in `provider/manifest/manager.go` and handles the validation/application of the manifest when received from the tenant send manifest operation.

```
func (s *service) handleLease(ev event.LeaseWon, isNew bool) {
	// Only run this if configured to do so
	if isNew && s.config.ManifestTimeout > time.Duration(0) {
		// Create watchdog if it does not exist AND a manifest has not been received yet
		if watchdog := s.watchdogs[ev.LeaseID.DeploymentID()]; watchdog == nil {
			watchdog = newWatchdog(s.session, s.lc.ShuttingDown(), s.watchdogch, ev.LeaseID, s.config.ManifestTimeout)
			s.watchdogs[ev.LeaseID.DeploymentID()] = watchdog
		}
	}

	manager := s.ensureManager(ev.LeaseID.DeploymentID())
	....
}
```

New Manifest Manager instance is initiated by calling the `newManager` function in `provider/manifest/manager.go` with the service type and deployment ID (DSEQ) passed in as arguments.

```
func (s *service) ensureManager(did dtypes.DeploymentID) (manager *manager) {
	manager = s.managers[dquery.DeploymentPath(did)]
	if manager == nil {
		manager = newManager(s, did)
		s.managers[dquery.DeploymentPath(did)] = manager
	}
	return manager
}
```