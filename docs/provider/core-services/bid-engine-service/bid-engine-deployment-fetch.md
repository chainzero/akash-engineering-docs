---
sidebar_position: 6
---

# Bid Engine Order Detail Fetch

Within the `run` function details of the order are fetched.  The result of the order fetched are placed onto the `groupch` channel which provokes downstream, additional event processing.

```
	// Begin fetching group details immediately.
	groupch = runner.Do(func() runner.Result {
		res, err := o.session.Client().Query().Group(ctx, &dtypes.QueryGroupRequest{ID: o.orderID.GroupID()})
		return runner.NewResult(res.GetGroup(), err)
	})
```