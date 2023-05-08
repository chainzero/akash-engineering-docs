---
sidebar_position: 7
---

# groupch Channel Processing

Still within the `run` function, a perpetual for loop awaits order group details to be sent to a channel named `groupch`.  When order/group details are placed onto that channel, the `shouldBid` method is called.

Eventually the result of calling `shouldBid` will be placed onto the `shouldBidCh` provoking further upstream order processing.  But prior to review upstream steps we will detail the `shouldBid` function logic.

```
		case result := <-groupch:
			// Group details fetched.

			groupch = nil
			o.log.Info("group fetched")

			if result.Error() != nil {
				o.log.Error("fetching group", "err", result.Error())
				break loop
			}

			res := result.Value().(dtypes.Group)
			group = &res

			shouldBidCh = runner.Do(func() runner.Result {
				return runner.NewResult(o.shouldBid(group))
			})
```