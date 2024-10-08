# Akash Provider Automated Build

## Overview

In this document the process of building an Akash Provider via shell scripts is reviewed.  These techniques will allow an Akash Provider build with the following components:

* Kubernetes build using K3s.  Multinode cluster build is possible using reviewed strategy.  Both clusters with multiple control plane nodes and multiple worker nodes are possible and are detailed in the instructions that follow.
* The K3s cluster in these builds use calcio as their container network interface (CNI)
* When mutli control plane node clusters are built such clusters use a redundant etc cluster.
* Install of ALL Akash Provider components including Akash Provider, Akash Operators (hostname, inventory), NGINX ingress controller, and necessary Kubernetes constructs (namespaces, labels, etc)
* Install of worker nodes including optional GPU configurations.  By simply provider an option in the shell script invoke the user is able to dictate if the node has GPUs and if so installs the necessary NVIDIA drivers and tool kits.

## Script Access

* During initial testing of this Akash Provider build strategy the scripts mentioned will be available in this [repo](https://github.com/chainzero/provider-build-scripts)
* Please clone the directory for direct access to scripts referenced in this guide

## Install K3s and Akash Provider Services on Master

### Steps

* Download and install script on first master node
* The templates below include the `-g` option which enables GPU support.   Remove this option if your master node does not host GPU resources.
* The `All in One Template` below includes the `-a` option which signals this is as an all in one cluster install (I.e. single cluster node with single host acting as master and worker node).&#x20;
* The template below includes the `-e` option which automatically updates the K3s kubeconfig file with the external IP address of the master node.  This will provoke cert generation for the external address as well.  This allows kubectl access to the cluster externally without any further config necessary.  Remove this option if you do not desire external kubeconfig access.
* Template automatically configures Coredns to use upstream DNS servers of `8.8.8.8` and `8.8.4.4` via Coredns configmap.  No user option is necessary for this purpose.  Edit script manually if you choose to use other DNS servers for external domain name resolutions.

> _**NOTE**_ - prior to executing this script and all remaining script executions in this guide, ensure to make the file executable such as:\
> \
> `chmod 755 k3sAndProviderServices.sh`

#### Multi Node Cluster Templates

**INITIIAL CONTROL PLANE NODE**

* Use this template if the cluster has multiple nodes

```
./k3sAndProviderServices.sh -d traefik -e <public-ip-of-node> -g
```

#### ADDITIONAL CONTROL PLAN NODE ADDS

* Use this template to join additional control plane nodes to the cluster
* Logic in script will join the node as an additional control plane instance and join the node to the pre-existing etcd cluster

```
./k3sAndProviderServices.sh -d traefik -m <internal-ip-existing-master-node> -c <cluster-join-token> -g
```

#### All in One Cluster Template

* Use this template if the cluster has only a single node (I.e. one host serving as both master/worker)

```
./k3sAndProviderServices.sh -d traefik -e <public-ip-of-node> -g -a
```

#### Remove a Control Plane Node

```
./k3sAndProviderServices.sh -r <node-name>
```

#### Remove a Worker Node

```
./k3sAndProviderServices.sh -w <node-name>
```

### Notes

* Should be no need to use options or edit script
* Script installs K3s master node and akash-provider services latest version (can specify other version if needed but defaults to latest)
* Capture the outputted k3s token for later use in worker node additions (not applicable to `All in One Cluster` scenarios).

## Create/Import Provider Account and Export

### Steps

> NOTE - while the scripts used have access to the `provider-services` binary - it will be necessary to add `/root/bin` to your path for execution of commands in this section.  Adding the binary's directory to your path is detailed in the CLI install docs [here](https://akash.network/docs/deployments/akash-cli/installation/#install-akash-cli).

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

* We considered making the import of provider account and export of private key/key.pem file creation part of scripted steps but proved to be cumbersome and likely better to handle these sensitive operations manually and outside of script.  But could reconsider embedding into automated process later.

## Worker Node Build

> _**NOTE**_ - if your provider is an `All in One` cluster and was specified as such during the K3s/Provider-Services install script - skip this `Worker Node Build` step and proceed to the Build Provider section&#x20;

> _**NOTE**_ - proactively reboot the worker node following completion of these steps as it is often necessary following the install of GPU drives

### Steps

* Download and install script on worker nodes
* Script joins the worker node to the K3s cluster and install GPU drivers/toolkits if the associated option is specified

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

* Download and install script on the master node
* Script installs Helm, installs all necessary Akash Provider labels/namespaces/CRDs, install all necessary Akash operators (inventory, hostname), and installs the Akash provider itself.
* Edit script `provider.yaml` section with your own values/provider attributes.  No other changes to the script are necessary.
* If the use of the customer bid script is desired - ensure that the `provider.yaml` section is updated with appropriate/desired pricing options.  Customization is covered in detail within this [doc](https://akash.network/docs/providers/build-a-cloud-provider/akash-cloud-provider-build-with-helm-charts/#step-9---provider-bid-customization).
* Provider RPC Node use/declaration - the `-n` option exists to specify the RPC node that the Akash Provider should use.  Defaults for the RPC node have been set as follows:

> \-- If the chain-id is defined as `akashnet-2` - which is the default chain unless otherwise specified - the RPC node will be set to [http://akash-node-1:26657](http://akash-node-1:26657).  In the build of a Mainnet provider a custom/local RPC node will be deployed in your Kubernetes cluster and thus we use that node at the specified Kubernetes service name.\
> \
> \-- If the chain-id is specified as `sandbox-01` - which dictates that this is an Akash sandbox provider build - the RPC node will be set to [https://rpc.sandbox-01.aksh.pw:443](https://rpc.sandbox-01.aksh.pw).  In the sandbox provider build - by default - we do not install a local/dedicated RPC node and instead use this publicly available endpoint.

* The template below includes the `-g` option which enables GPU support.  Remove this option if your provider does not host GPUs.
* The template below includes the `-w` option which is a command separated list of the nodes in your cluster with GPU resources.  Remove this option if your provider does not host GPUs.
* The template below includes the `-s` option which enables persistent storage on the provider.    The script expects a CEPH config file in the `~/provider` directory.  An example CEPH config file can be found [here](https://akash.network/docs/providers/build-a-cloud-provider/helm-based-provider-persistent-storage-enablement/#configuration-for-a-single-storage-node).  Remove this option if your provider does not support persistent storage.
* The template below includes the `-b` option which allows the user to state the storage class of the provider (I.e. beta1, beta2, or beta3).  Using this option allows automatic labeling of the storage class and an update to the inventory operator with the storage class type if necessary.  Remove this option if your provider does not support persistent storage.
* The template below includes the `-p` option which enables the use of the custom bid price script.  Remove this option if the custom bid price script use is not desired.
* The script includes the `c` option to specify the chain ID.  The default chain ID is `mainnet2`.  This option is NOT included in the template.
* The script includes the `v` option to specify the `provider-services` binary version.  The current/latest version is extracted from the related Helm Chart `appVersion` field..  This option is NOT included in the template.
* The script includes the `x` option to specify the `akash` binary version for use within the provider's custom RPC node. The current/latest version is extracted from the related Helm Chart `appVersion` field.  This option is NOT included in the template.

#### TEMPLATE

```
./providerBuild.sh -a <akash-provider-address> -k <password-for-private-key-file> -d <provider-domain> -g -w <comma-seperated-list-of-gpu-nodes> -s -b <storage-class> -p
```

#### EXAMPLE

```
./providerBuild.sh -a akash1mtnuc449l0mckz4cevs835qg72nvqwlul5wzyf -k akashprovider -d akashtesting.xyz -g -w worker -s -b beta2 -p
```

## Verifications

> _**NOTE**_ - conduct these validations from a Kubernetes master node in your cluster

> _**NOTE**_ - while the scripts executed in this guide have access to the Kubernetes kubeconfig within it's session, your CLI session may not have access to kubeconfig.  Execute this command to allow access to your kubeconfig file for the verifications in this section and for other Kubernetes activities.
>
>
>
> ```shellscript
> # Set KUBECONFIG
> export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
> ```

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

### Query Provider's Inventory

> _**NOTE**_ - after the Akash Provider has entered a running state - restart the inventory operator to ensure fresh discovery such as:\
> \
> `kubectl delete pod <inventory-operator-pod-name> -n akash-services`

```
grpcurl -insecure <provider-domain/IP-address>:8444 akash.provider.v1.ProviderRPC.GetStatus
```

## K3s Upgrades

### Overview

A script is made available - `upgrade_k3s.sh` - to allow ease in upgrading the K3s cluster.

The script performs the following actions:

* Determines the currently installed K3s version on the host
* Determines the latest stable version from the K3s GitHub repository
* If there is a difference in the current version on the host and the latest stable version available the script is initiate/complete the upgrade to the latter.
* An option is made available - covered in the Usage section of this guide - to put the script into "discovery only" mode.  When used the analysis of current to latest stable version will be conducted but the host upgrade process will not iproceed.  This is provided to allow analysis if an upgrade is available with intent to upgrade later.
* This upgrade script must be executed on all host in the cluster.  Begin by upgrade the control plane nodes and then proceed to the worker nodes.

### Usage

#### Discovery Only Mode

```
upgrade_k3s.sh -d
```

#### Host Upgrade Mode

```
upgrade_k3s.sh
```