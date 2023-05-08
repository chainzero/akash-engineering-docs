---
sidebar_position: 6
---

# Custom Controller Logic

The Hostname Operator custom controller logic is located in the Go file `provider/operator/hostnameoperator/hostname_operator.go`.  This is the same file that the `hostname-operator` Cobra command is registered within and which was covered in the previous section.

> _**NOTE**_ - When a container image is generated and which implements the logic within this file, a Kubernetes deployment may be created to host the controller.

Our code review will detail the mechanics involved in the controller's reconciliation of Desired and Actual states.

> [Source code location](https://github.com/akash-network/provider/blob/main/operator/hostnameoperator/hostname\_operator.go)
