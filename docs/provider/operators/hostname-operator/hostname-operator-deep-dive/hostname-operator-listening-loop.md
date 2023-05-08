---
sidebar_position: 3
---

# Hostname Operator Listening Loop

&#x20;The `run` method invokes loop listening for new ingress controller entries.

A perpetual for loop is created and the upstream `monitorUntilError` method is called.  The `monitorUntilError` - as covered in detail next - will listen on an event bus for new Kubernetes Ingress Controller entries.

```
func (op *hostnameOperator) run(parentCtx context.Context) error {
	op.log.Debug("hostname operator start")

	for {
		...
		err := op.monitorUntilError(parentCtx)
		...
	}
}
```