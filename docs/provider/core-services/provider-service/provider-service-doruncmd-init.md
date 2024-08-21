---
sidebar_position: 3
---

# Function doRunCmd Called on Provider Service Invoke

Within the `doRunCmd` function the method `NewService` is called.

The `NewService` method is defined in `provider/service.go`.

```
	service, err := provider.NewService(ctx, cctx, info.GetAddress(), session, bus, cclient, ipOperatorClient, operatorWaiter, config)
	if err != nil {
		return err
	}
```