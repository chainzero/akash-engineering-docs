---
sidebar_position: 2
---

# Types Used for Custom Resource Definition

The Go structs that define the Kubernetes Custom Resource Definition for the Hostname Operator are located in the `pkg/apis/akash.network/v2beta1` directory.  The Hostname Operator CRD specifically exists in the `types.go` file.

> [Source code reference location](https://github.com/akash-network/provider/blob/e7aa0b5b81957a130f1dc584f335c6f9e41db6b1/pkg/apis/akash.network/v2beta1/types.go)

Per typical Kubernetes CRD definition a `ProviderHostSpec` defines the schema for the Hostname Operator.  And `ProviderHostStatus` defines the values delivered in the response to a custom resource CRUD event.

With this definition we will extend the Kubernetes API for use with the Hostname Operator.  When `code-generator` is run against the Go struct the necessary YAML file for applying the CRD to the Kubernetes cluster will be generated and as detailed in the next section.

```
type ProviderHostStatus struct {
	State   string `json:"state,omitempty"`
	Message string `json:"message,omitempty"`
}

type ProviderHostSpec struct {
	Owner        string `json:"owner"`
	Provider     string `json:"provider"`
	Hostname     string `json:"hostname"`
	Dseq         uint64 `json:"dseq"`
	Gseq         uint32 `json:"gseq"`
	Oseq         uint32 `json:"oseq"`
	ServiceName  string `json:"service_name"`
	ExternalPort uint32 `json:"external_port"`
}
```