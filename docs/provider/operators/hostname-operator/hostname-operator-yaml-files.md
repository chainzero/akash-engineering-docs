---
sidebar_position: 3
---

# CRD YAML Files Created via Code-Generator

The YAML files to create the Custom Resource Definition (CRD) within Kubernetes is auto-generated by `code-generator` using the Go struct definition into this file:

> pkg/apis/akash.network/crd.yaml

> _**NOTE**_ - along with the generation of the YAML file for CRD application on the provider Kubernetes cluster, code-generator additionally used deep-copy to scaffold the files created in the `provider/pkg/client` directory.  The code-generator files scaffolded into the clientset, informers, and listers subdirectories should not be manually edited but instead are spawned via the definitions in the CRD definition file (I.e. the ProviderHostSpec struct).