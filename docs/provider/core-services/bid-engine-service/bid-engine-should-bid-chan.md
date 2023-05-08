---
sidebar_position: 8
---

# shouldBidCh Channel Processing

When a result from the prior step is placed onto the `shouldBinCh` channel, the `shouldBid` function - also located within `provider/bidengine/order.go` - processes several validations to determine if the provider should bid on the order.

```
		case result := <-shouldBidCh:
			shouldBidCh = nil
```

The validations include:

* _**MatchAttributes**_ - return `unable to fulfill` if provider does not possess necessary attributes
* _**MatchResourcesRequirements**_ - return `unable to fulfill` if provider does not possess required, available resources
* _**SignedBy**_ - return `attribute signature requirements not met` if provider does not possess required audited attributes&#x20;

```
	if !group.GroupSpec.MatchAttributes(o.session.Provider().Attributes) {
		o.log.Debug("unable to fulfill: incompatible provider attributes")
		return false, nil
	}

	...

	// does provider have required capabilities?
	if !group.GroupSpec.MatchResourcesRequirements(attr) {
		o.log.Debug("unable to fulfill: incompatible attributes for resources requirements", "wanted", group.GroupSpec, "have", attr)
		return false, nil
	}
	...
	signatureRequirements := group.GroupSpec.Requirements.SignedBy
	if signatureRequirements.Size() != 0 {
		// Check that the signature requirements are met for each attribute
		var provAttr []atypes.Provider
		ownAttrs := atypes.Provider{
			Owner:      o.session.Provider().Owner,
			Auditor:    "",
			Attributes: o.session.Provider().Attributes,
		...
		ok := group.GroupSpec.MatchRequirements(provAttr)
		if !ok {
			o.log.Debug("attribute signature requirements not met")
			return false, nil
		}
		}
	...
	

```

Should either `MatchAttributes`, `MatchResourcesRequirements`, or `SignedBy` evaluations fail to satisfy requirements, a boolean false is returned.  If the result evaluates to `false` - meaning one of the validations does not satisfy requirements, `shouldBid` is set to `false`, the loop is exited, and a log message of `decline to bid` on the order is populated.

```
			shouldBid := result.Value().(bool)
			if !shouldBid {
				shouldBidCounter.WithLabelValues("decline").Inc()
				o.log.Debug("declined to bid")
				break loop
			}
```

The next step will begin the Kubernetes cluster reservation of requested resources.

While the bid process proceeds the reservation of resources in the Provider's Kubernetes cluster occurs via a call to the `cluster.Reserve` method.  If the bid is not won the reservation will be cancelled.

If the provider is capable of satisfying all of the requirements of the order the result is placed onto the clusterch channel which provokes the next step of order processing.

```
			clusterch = runner.Do(metricsutils.ObserveRunner(func() runner.Result {
				v := runner.NewResult(o.cluster.Reserve(o.orderID, group))
				return v
			}, reservationDuration))
```

The `Reserve` function called - the result of which is placed onto the `clusterch` channel - is called from `provider.service.go`.

```
func (s *service) Reserve(order mtypes.OrderID, resources atypes.ResourceGroup) (ctypes.Reservation, error) {
	return s.inventory.reserve(order, resources)
}
```