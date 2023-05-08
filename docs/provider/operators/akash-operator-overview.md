---
sidebar_position: 1
---

# Akash Operator Overview

## Overview

## Suggested Pre-Reading

#### Kubebuilder for Operator Builds

Familiarity with Kubernetes Operators allows a better understanding of Akash provider Custom Resource Definitions (CRD) and custom controllers.

A very populate tool for scaffolding Kubernetes Operators is Kubebuilder.  While the Akash Provider Operators were not created using Kubebuilder, reviewing this tool and experimenting with simple examples provided in the guide below serve as an excellent exposure to the creation of CRDs and associated controllers.

* [Kubebuilder Tutorials](https://book.kubebuilder.io/introduction.html)

#### Code-Generator for Operator Builds

The Akash code base uses [code-generator ](https://github.com/kubernetes/code-generator) for CRD and controller scaffolding.  Code-Generator limits some of the bloated boiler-plate created via other tools like Kubebuilder.  Many resources exist for an introduction to code-generator and listed below is one such article to increase familiarity with the scaffolded directory structure.  With this knowledge in place we can begin digging into Akash Provider Operators.

* [Extending Kubernetes - Create Controllers for Core and Custom Resources (using code-generator)](https://trstringer.com/extending-k8s-custom-controllers/)

## Akash Provider Operators

* [Hostname Operator](./hostname-operator/hostname-operator-overview.md)
* [IP Operator](./ip-operator/ip-operator-overview.md)
* [Inventory Operator](./inventory-operator/inventory-operator-overview.md)