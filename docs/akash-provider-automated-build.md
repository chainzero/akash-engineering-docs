# Akash Provider Automated Build

## Overview

In this document the process of building an Akash Provider via shell scripts is reviewed.  These techniques will allow an Akash Provider build with the following components:

* Kubernetes build using K3s.  Multinode cluster build is possible using reviewed strategy.
* Install of ALL Akash Provider components including Akash Provider, Akash Operators (hostname, inventory), NGINX ingress controller, and necessary Kubernetes constructs (namespaces, labels, etc)
* Intall of worker nodes including optional GPU configurations.  By simply provider an option in the shell script invoke the user is able to dictate if the node has GPUs and if so installs the necessary NVIDIA drivers and tool kits.

## Script Access

* During initial testing of this Akash Provider build strategy the scripts mentioned will be available in this [repo](https://github.com/chainzero/provider-build-scripts)
* Please clone the directory for direct access to scripts referenced in this guide

## Install K3s and Akash Provider Services on Master

### Steps

* Download and install script on first master node

```
./k3sAndProviderServices.sh
```

### Notes

* Should be no need to use options or edit script
* Script installs K3s master node and akash-provider services latest version (can specify other version if needed but defaults to latest)
* Estimated time to complete - 3-5 minutes
* Capture the outputted k3s token for later use in worker node additions

## Create/Import Provider Account and Export

### Steps

* Conduct these steps on the master node
* Suggested commands to complete necessary actions:

```
# will prompt for mnemonic of pre-existing/funded account
provider-services keys add default --recover

# capture outout of this command for use in subsequent command
# will prompt for passphrase - capture passphrase for use in later steps
provider-services keys export default

# create key.pem file which stores exported private key and is used during provider build
# paste in full contents of prior export command
cd ~
vi key.pem
```

### Notes

* Considered makiing the import of provider account and export of private key/key.pem file creation part of scripted steps but proved to be cubersome and likely better to handle these sensitive oepratotions manually and outside of script.  But could reconsider embedding into automated process later.

## Worker Node Build

### Steps

* Download and install script on worker nodes

#### TEMPLATE

> _**NOTE**_ - in this example we are specifying the worker node has GPU resources with the `-g` option.  Remove this option if worker node has no GPU resources.

```
./workerNode.sh -m <master-node-ip-add> -t <k3-node-join-token> -g
```

#### EXAMPLE

```
./workerNode.sh -m 10.128.15.227 -t K105ec545b7369b24364688a3cbfdfb5e5b33bb8748b51c98fb2a6bff6615a97177::server:1a8cbb0acc6729c4905a3faadb262d3e -g
```

### Notes

* During the NVIDIA drivers install the user will be prompted to accept defaults in a couple of pop up screens.  Experimented with circumventing the need for user to interact with such screens with specification of an unattended install but initial experimentation proved this to be unreliable.  May revisit in the future.

## Build Provider

### Steps

* Download and install script on worker nodes
* Edit script `provider.yaml` section with your own values/provider attributes.  No other changes to the script are necessary.

#### TEMPLATE

```
./providerBuild.sh -a <akash-provider-address> -k <password-for-private-key-file> -d  -n http://akash-node-1:26657 -g -w '<comma-seperated-list-of-gpu-nodes>'
```

#### EXAMPLE

```
./providerBuild.sh -a akash1mtnuc449l0mckz4cevs835qg72nvqwlul5wzyf -k akashpass -d akashtesting.xyz -n http://akash-node-1:26657 -g -w 'worker'
```

## Verifications

> _**NOTE**_ - conduct these validations from a Kubernetes master node in your cluster

> _**NOTE**_ - the Akash provider will not come into service until the RPC Node in your cluster is in sync.  Confirm RPC Node status via:\
> \
> \- Access RPC node pod
>
> `kubectl exec -it akash-node1-0 -n akash-services -- bash`\
> \
> \- Execute the `akash status` command within the pod and check the status of the `catching_up` field.  The value of this field will be `true` while the node is sync'ing and `false` when the node is fully in sync.  Only when the node is fully in sync will the provider come into service.  The sync process may take up to an hour to complete.

### Akash Services/Pods

#### COMMAND

```
kubectl get pods -n akash-services
```

#### EXAMPLE/EXPECTED OUTPUT

```
root@master1:~/provider# kubectl get pods -n akash-services
NAME                                            READY   STATUS    RESTARTS   AGE
operator-hostname-574d8699d-m97rk               1/1     Running   0          51m
operator-inventory-fc7957869-l7mgc              1/1     Running   0          51m
operator-inventory-hardware-discovery-worker1   1/1     Running   0          51m
operator-inventory-hardware-discovery-master1   1/1     Running   0          51m
akash-node-1-0                                  1/1     Running   0          51m
akash-provider-0                                1/1     Running   0          16s
```
