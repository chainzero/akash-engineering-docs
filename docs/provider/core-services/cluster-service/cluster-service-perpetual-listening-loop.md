---
sidebar_position: 6
---

# Cluster Service Perpetual Listening Loop

A perpetual for loop is spawned for the Cluster Service which - amongst other cases - monitor for an event type of `ManifestReceived`.

Following a series of validations - for example ensuring that the deployment pre-exists in which would indicate a deployment update event and assurance that the deployment exist in inventory - when passed thru eventually reaches a call of the `newDeploymentManager` function.

```
loop:
	for {
		select {
		....
		case ev := <-s.sub.Events():
			switch ev := ev.(type) {
			case event.ManifestReceived:
				s.log.Info("manifest received", "lease", ev.LeaseID)

				mgroup := ev.ManifestGroup()
				if mgroup == nil {
					s.log.Error("indeterminate manifest group", "lease", ev.LeaseID, "group-name", ev.Group.GroupSpec.Name)
					break
				}

				if _, err := s.inventory.lookup(ev.LeaseID.OrderID(), mgroup); err != nil {
					s.log.Error("error looking up manifest", "err", err, "lease", ev.LeaseID, "group-name", mgroup.Name)
					break
				}

				key := ev.LeaseID
				if manager := s.managers[key]; manager != nil {
					if err := manager.update(mgroup); err != nil {
						s.log.Error("updating deployment", "err", err, "lease", ev.LeaseID, "group-name", mgroup.Name)
					}
					break
				}

				s.managers[key] = newDeploymentManager(s, ev.LeaseID, mgroup, true)
```