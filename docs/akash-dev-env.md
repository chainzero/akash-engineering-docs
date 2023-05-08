---
sidebar_position: 2
---

# Akash Development Environment

Follow these sequential steps to build a local Akash development environment.

* [Overview and Requirements](#overview-section)
* [Code](#code-section)
* [Install Tools](#install-tools-section)
* [Development Environment General Behavior](#general-behavior-section)
* [Runbook](#runbook-section)
* [Parameters](#parameters-section)
* [Use Runbook](#runbook-section)

## <a id="overview-section"></a>Overview and Requirements

### Overview

This page covers setting up development environment for both [node](https://github.com/akash-network/node) and [provider](https://github.com/akash-network/provider) repositories. The provider repo elected as placeholder for all the scripts as it depends on the `node` repo.   Should you already know what this guide is all about - feel free to explore examples.

### Requirements

#### Golang

Go must be installed on the machine used to initiate the code used in this guide. Both projects - Akash Node and Provider - are keeping up-to-date with major version on development branches. Both repositories are using the latest version of the Go, however only minor that has to always match.

#### **Docker Engine**

Ensure that Docker Desktop/Engine has been installed on machine that the development environment will be launched from.

#### Direnv Use

##### Install Direnv if Necessary

Direnv is used for the install process.  Ensure that you have Direnv install these [instructions](https://direnv.net/).

##### Configure Environment for Direnv Use

* Edit the ZSH shell profile with visual editor.

```
vi .zshrc
```

* Add the following line to the profile.

```
eval "$(direnv hook zsh)"
```

## <a id="code-section"></a>Code

In the example use within this guide, repositories will be located in `~/go/src/github.com/akash-network`. Create directory if it does not already exist via:

```
mkdir -p ~/go/src/github.com/akash-network
```

### Clone Akash Node and Provider Repositories

> _**NOTE**_ - all commands in the remainder of this guide  assume a current directory of `~/go/src/github.com/akash-network`unless stated otherwise.

```shell
cd ~/go/src/github.com/akash-network 
git clone https://github.com/akash-network/node.git
git clone https://github.com/akash-network/provider.git
```

## <a id="install-tools-section"></a>Install Tools

Run following script to install all system-wide tools. Currently supported host platforms.

* MacOS
* Debian based OS PRs with another hosts are welcome
* Windows is not supported

```shell
cd ~/go/src/github.com/akash-network
./provider/script/install_dev_dependencies.sh
```

## <a id="general-behavior-section"></a>Development Environment General Behavior

All examples are located within [\_run](https://github.com/akash-network/provider/tree/main/\_run) directory. Commands are implemented as `make` targets.

There are three ways we use to set up the Kubernetes cluster.

* kind
* minukube
* ssh

Both `kind` and `minikube` are e2e, i.e. the configuration is capable of spinning up cluster and the local host, whereas `ssh` expects cluster to be configured before use.

## <a id="runbook-section"></a>Runbook

There are four configuration variants, each presented as directory within[ \_run](https://github.com/akash-network/provider/tree/main/\_run).

* `kube` - uses `kind` to set up local cluster. It is widely used by e2e testing of the provider. Provider and the node run as host services. All operators run as kubernetes deployments.
* `single` - uses `kind` to set up local cluster. Main difference is both node and provider (and all operators) are running within k8s cluster as deployments. (at some point we will merge `single` with `kube` and call it `kind`)
* `minikube` - not in use for now
* `ssh` - expects cluster to be up and running. mainly used to test sophisticated features like `GPU` or `IP leases`

The only difference between environments above is how they set up. Once running, all commands are the same.

Running through the entire runbook requires multiples terminals. Each command is marked **t1**-**t3** to indicate a suggested terminal number.

If at any point something goes wrong and cluster needs to be run from the beginning:

```shell
cd provider/_run/<kube|single|ssh>
make kube-cluster-delete
make clean
make init
```
## <a id="parameters-section"></a>Parameters

Parameters for use within the Runbooks detailed later in this guide.

| Name                | Default value                                                                                     | Effective on target(s)                                                                                                                                            |
| ------------------- | ------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SKIP\_BUILD         | false                                                                                             |                                                                                                                                                                   |
| DSEQ                | 1                                                                                                 | <ul><li>deployment-\* </li><li>lease-\* </li><li>bid-\* </li><li>send-manifest</li></ul>                                                                             |
| OSEQ                | 1                                                                                                 | <ul><li>deployment-\* </li><li>lease-\* </li><li>bid-\* </li><li>send-manifest</li></ul>                                                                             |
| GSEQ                | 1                                                                                                 | <ul><li>deployment-\* </li><li>lease-\* </li><li>bid-\* </li><li>send-manifest</li></ul>                                                                             |
| KUSTOMIZE\_INSTALLS | <p>Depends on runbook.<br/>Refer to each runbook's <code>Makefile</code> to see default value.</p> | <ul><li>kustomize-init</li><li>kustomize-templates</li><li>kustomize-set-images</li><li>kustomize-configure-services </li><li>kustomize-deploy-services</li></ul> |

## <a id="runbook-section"></a>Use Runbook

### Runbook Overview

> _**NOTE**_ - this runbook requires three simultaneous terminals

For the purpose of documentation clarity we will refer to these terminal sessions as:

* terminal1
* terminal2
* terminal3

#### STEP 1 - Open Runbook

> _**NOTE**_ - run the commands in this step on terminal1, terminal2, and terminal3&#x20;

Run this step on all three terminal sessions to ensure we are in the correct directory for later steps.

```
cd ~/go/src/github.com/akash-network/provider/_run/kube
```

#### STEP 2 - Create and Provision Local Kind Kubernetes Cluster

> _**NOTE**_ - run this command in this step on terminal1 only

> _**NOTE**_ - this step may take several minutes to complete

```
make kube-cluster-setup
```

##### Possible Timed Out Waiting for the Condition Error

If the following error is encountered when running `make kube-cluster-setup`:

```
Waiting for deployment "ingress-nginx-controller" rollout to finish: 0 out of 1 new replicas have been updated...
Waiting for deployment "ingress-nginx-controller" rollout to finish: 0 of 1 updated replicas are available...
error: timed out waiting for the condition
make: *** [../common-kube.mk:120: kube-setup-ingress-default] Error 1
```

This is an indication that the Kubernetes ingress-controller did not initialize within the default timeout period.  In such cases, re-execute `make kube-cluster-setup` with a custom timeout period such as the example below.  This step is NOT necessary if `make kube-cluster-setup` completed on first run with no errors encountered.

```
cd provider/_run/<kube|single|ssh>
make kube-cluster-delete
make clean
make init
KUBE_ROLLOUT_TIMEOUT=300 make kube-cluster-setup
```

#### STEP 3 - Start Akash Node

> _**NOTE**_ - run this command in this step on terminal2 only

```
make node-run
```

#### STEP 4 - Create an Akash Provider

> _**NOTE**_ - run this command in this step on terminal1 only

```
make provider-create
```

##### Note on Keys

Each configuration creates four keys: The keys are assigned to the targets and under normal circumstances there is no need to alter it. However, it can be done with setting KEY\_NAME:

```
# create provider from **provider** key
make provider-create

# create provider from custom key
KEY_NAME=other make provider-create
```

#### STEP 5 - Start the Akash Provider

> _**NOTE**_ - run this command in this step on terminal3 only

```
make provider-run
```

#### STEP 6 - Create and Verify Test Deployment

> _**NOTE**_ - run the commands in this step on terminal1 only

##### Create the Deployment

* Take note of the deplpyment ID (DSEQ) generated for use in subsequent steps

```
make deployment-create
```

##### Query Deployments

```
make query-deployments
```

##### Query Orders

* Steps ensure that an order is created for the deployment after a short period of time

```
make query-orders
```

##### Query Bids

* Step ensures the Provider services daemon bids on the test deployment

```
make query-bids
```

#### STEP 7 - Test Lease Creation for the Test Deployment

> _**NOTE**_ - run the commands in this step on terminal1 only

##### Create Lease

```
make lease-create
```

##### Query Lease

```
make query-leases
```

##### Ensure Provider Received Lease Create Message

* Should see "pending" inventory in the provider status and for the test deployment

```
make provider-status
```

#### STEP 8 - Send Manifest

> _**NOTE**_ - run the commands in this step on terminal1 only

##### Send the Manifest to the Provider

```
make send-manifest
```

##### Check Status of  Deployment

```
make provider-lease-status
```

##### Ping the Deplpyment to Ensure Liveness

```
 make provider-lease-ping
```

#### STEP 9 - Verify Service Status

> _**NOTE**_ - run the commands in this step on terminal1 only

##### Query Lease Status

```
make provider-lease-status
```

##### Fetch Pod Logs

* Note that this will fetch the logs for all pods in the Kubernetes cluster.  Filter/search for the test deployment's ID (DSEQ) for related activities.

```
make provider-lease-logs
```