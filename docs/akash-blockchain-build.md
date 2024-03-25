# Akash Blockchain Build

### Overview

Follow the steps in this guide to scaffold and build an Akash blockchain for testing purposes.

Sections:

* [Environment Overview](akash-blockchain-build.md#environment-overview)
* [Akash Blockchain Build](akash-blockchain-build.md#akash-blockchain-build)
* [RPC Node Build](akash-blockchain-build.md#rpc-node-build)
* [Akash Provider Build](akash-blockchain-build.md#akash-provider-build)
* [CosmoVisor Network Upgrade Test](akash-blockchain-build.md#cosmovisor-network-upgrade-test)

### Environment Overview

The topology used in this guide to build an Akash blockchain instance are as follows. Alternate toplogies could be used including a single host Kubernetes environment.

#### Hosts

* Kubespray host
* Single Kubernetes master node
* Single Kubernetes worker node

#### Components

* Akssh Validator created as a Kubernetes stateful set
* Akash RPC node created as a Kubernetes stateful set
* Akash Provider built using Helm Charts and within the same Kubernetes cluster as the validator

### Akash Blockchain Build

#### STEP 1 - Build Kubernetes Cluster

For this build we will use a Kubernetes cluster created via Kubespray.

Follow the steps in this Akash documentation [guide](https://akash.network/docs/providers/build-a-cloud-provider/kubernetes-cluster-for-akash-providers/kubernetes-cluster-for-akash-providers/) to build the K8s cluster.\
\
The build in this guide uses a two cluster topolgy with a single control-plane and single dedicated worker node.

#### STEP 2 - Deploy Initial Validator

> NOTE - example blockchain deployed on Google Cloud (GCP) and thus manually creating Kubernetes Persistent Volumes. In other environments this may be seen as unnecessary and may allow Container Storage Interface (CSI) to auto provision the PVs.

**Create Mount Point Directories**

* Create the `/mnt/validator`directory on each of the Kubernetes hosts

```
mkdir -p /mnt/validator
```

**Create the Persistent Volumes**

* Create the Kubernetes Persistent Volumes using the following manifest

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: validator-pv-1
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: validator-storage
  local:
    path: /mnt/validator
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node1

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: validator-pv-2
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: validator-storage
  local:
    path: /mnt/validator
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node2
```

#### Deploy the Initial Validator Stateful Set

> _**NOTE**_ - a generic Omnibus image is used in this step to create the Validator stateful set and related containers. The Akash Vaildator software is NOT installed via this generic image. We will install and configure Akash node binaries in subsequent steps.

* Create the initial Akash Validator's stateful set and related K8s services with this manifest

```
# StatefulSet for validator-01 service
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: validator-01
spec:
  serviceName: "validator-01-service"
  replicas: 1
  selector:
    matchLabels:
      app: validator-01
  template:
    metadata:
      labels:
        app: validator-01
    spec:
      containers:
      - name: validator-01
        image: "ghcr.io/akash-network/cosmos-omnibus:v0.4.11-rc1-generic"
        command: ["/bin/sh", "-c"]
        args: ["sleep infinity"]
        env:
        - name: PROJECT_BIN
          value: akash
        - name: BINARY_URL
          value: "https://github.com/akash-network/node/releases/download/v0.32.2/akash_0.32.2_linux_amd64.zip"
        - name: MONIKER
          value: validator-01
        - name: MINIMUM_GAS_PRICES
          value: 0.025uakt
        - name: FASTSYNC_VERSION
          value: v0
        - name: CHAIN_ID
          value: sandbox-01
        - name: COSMOVISOR_ENABLED
          value: "1"
        - name: DAEMON_ALLOW_DOWNLOAD_BINARIES
          value: "true"
        - name: DAEMON_RESTART_AFTER_UPGRADE
          value: "true"
        - name: DAEMON_LOG_BUFFER_SIZE
          value: "512"
        - name: UNSAFE_SKIP_BACKUP
          value: "true"
        ports:
        - name: p2p
          containerPort: 26656
        - name: rpc
          containerPort: 26657
        volumeMounts:
        - name: data
          mountPath: /root/.akash
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 50Gi
      storageClassName: validator-storage

---
apiVersion: v1
kind: Service
metadata:
  name: validator-01
spec:
  selector:
    app: validator-01
  ports:
    - protocol: TCP
      port: 26656
      targetPort: 26656
      name: p2p
    - protocol: TCP
      port: 26657
      targetPort: 26657
      name: rpc

---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: validator-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

**Verify Validator Deployment**

_**ENSURE PVC BINDING**_

```
kubectl get pvc
```

_**EXPECTED/EXAMPLE OUTPUT**_

```
root@node1:~/kube-manifests/validator# kubectl get pvc

NAME                  STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS        AGE
data-validator-01-0   Bound    validator-pv-1   50Gi       RWO            validator-storage   92s
```

**Verify Validator Pod**

```
kubectl get pods
```

_**EXPECTED/EXAMPLE OUTPUT**_

```
root@node1:~/kube-manifests/validator# kubectl get pods

NAME             READY   STATUS    RESTARTS   AGE
validator-01-0   1/1     Running   0          3m24s
```

#### STEP 3 - Configure the Initial Validator

> _**NOTE**_ - ensure the validator pod created in the prior step is in a `Running` status prior to completing the steps in this section

**Create a Session into the Validator Pod**

> _**NOTE**_ - following this section all remaining commands in this seciton shold be conducted from within the validator pod CLI session established

```
kubectl exec -ti validator-01-0 -- bash
```

**Install the Akash Node Binary within the Pod**

> _**NOTE**_ - replace the specific binary link used in the example with the current/desired binary version

```
cd

wget -c https://github.com/akash-network/node/releases/download/v0.32.2/akash_0.32.2_linux_amd64.zip

unzip akash_0.32.2_linux_amd64.zip

install akash /usr/local/bin/

rm akash_0.32.2_linux_amd64.zip akash
```

**Confirm Akash Binary Installation**

```
akash version
```

_**EXPECTED/EXAMPLE OUTPUT**_

```
root@validator-01-0:~# akash version

v0.32.2
```

**Ensure the `.akash` Directory is Empty**

```
rm -rf  ~/.akash/*
```

**Initialize the Validator**

* Initialize the node/validator with the chain ID of `sandbox-01` and a moniker of `validator-01`

```
akash init --chain-id sandbox-01 validator-01
```

_**EXAMPLE/EXPECTED OUTPUT**_

```
{"app_message":{"agov":{"deposit_params":{"min_initial_deposit_rate":"0.400000000000000000"}},"astaking":{"params":{"min_commission_rate":"0.050000000000000000"}},"audit":{"attributes":[]},"auth":{"accounts":[],"params":{"max_memo_characters":"256","sig_verify_cost_ed25519":"590","sig_verify_cost_secp256k1":"1000","tx_sig_limit":"7","tx_size_cost_per_byte":"10"}},"authz":{"authorization":[]},"bank":{"balances":[],"denom_metadata":[],"params":{"default_send_enabled":true,"send_enabled":[]},"supply":[]},"capability":{"index":"1","owners":[]},"cert":{"certificates":[]},"crisis":{"constant_fee":{"amount":"1000","denom":"stake"}},"deployment":{"deployments":[],"params":{"min_deposits":[{"amount":"500000","denom":"uakt"}]}},"distribution":{"delegator_starting_infos":[],"delegator_withdraw_infos":[],"fee_pool":{"community_pool":[]},"outstanding_rewards":[],"params":{"base_proposer_reward":"0.010000000000000000","bonus_proposer_reward":"0.040000000000000000","community_tax":"0.020000000000000000","withdraw_addr_enabled":true},"previous_proposer":"","validator_accumulated_commissions":[],"validator_current_rewards":[],"validator_historical_rewards":[],"validator_slash_events":[]},"escrow":{"accounts":[],"payments":[]},"evidence":{"evidence":[]},"feegrant":{"allowances":[]},"genutil":{"gen_txs":[]},"gov":{"deposit_params":{"max_deposit_period":"172800s","min_deposit":[{"amount":"10000000","denom":"stake"}]},"deposits":[],"proposals":[],"starting_proposal_id":"1","tally_params":{"quorum":"0.334000000000000000","threshold":"0.500000000000000000","veto_threshold":"0.334000000000000000"},"votes":[],"voting_params":{"voting_period":"172800s"}},"ibc":{"channel_genesis":{"ack_sequences":[],"acknowledgements":[],"channels":[],"commitments":[],"next_channel_sequence":"0","receipts":[],"recv_sequences":[],"send_sequences":[]},"client_genesis":{"clients":[],"clients_consensus":[],"clients_metadata":[],"create_localhost":false,"next_client_sequence":"0","params":{"allowed_clients":["06-solomachine","07-tendermint"]}},"connection_genesis":{"client_connection_paths":[],"connections":[],"next_connection_sequence":"0","params":{"max_expected_time_per_block":"30000000000"}}},"inflation":{"params":{"inflation_decay_factor":"2.000000000000000000","initial_inflation":"100.000000000000000000","variance":"0.050000000000000000"}},"market":{"bids":[],"leases":[],"orders":[],"params":{"bid_min_deposit":{"amount":"500000","denom":"uakt"},"order_max_bids":20}},"mint":{"minter":{"annual_provisions":"0.000000000000000000","inflation":"0.130000000000000000"},"params":{"blocks_per_year":"6311520","goal_bonded":"0.670000000000000000","inflation_max":"0.200000000000000000","inflation_min":"0.070000000000000000","inflation_rate_change":"0.130000000000000000","mint_denom":"stake"}},"params":null,"provider":{"providers":[]},"slashing":{"missed_blocks":[],"params":{"downtime_jail_duration":"600s","min_signed_per_window":"0.500000000000000000","signed_blocks_window":"100","slash_fraction_double_sign":"0.050000000000000000","slash_fraction_downtime":"0.010000000000000000"},"signing_infos":[]},"staking":{"delegations":[],"exported":false,"last_total_power":"0","last_validator_powers":[],"params":{"bond_denom":"stake","historical_entries":10000,"max_entries":7,"max_validators":100,"unbonding_time":"1814400s"},"redelegations":[],"unbonding_delegations":[],"validators":[]},"take":{"params":{"default_take_rate":20,"denom_take_rates":[{"denom":"uakt","rate":2}]}},"transfer":{"denom_traces":[],"params":{"receive_enabled":true,"send_enabled":true},"port_id":"transfer"},"upgrade":{},"vesting":{}},"chain_id":"sandbox-01","gentxs_dir":"","moniker":"validator-01","node_id":"af88523de02b3943d0e29c8b4d97408b3f0c1098"}
```

**Capture the Node ID of the Validator**

* Store the captured output/node ID exposed in this step for use in subsequent steps

```
akash tendermint show-node-id
```

_**EXAMPLE/EXPECTED OUTPUT**_

> _**NOTE**_ - your Node ID will be different/unique

```
root@validator-01-0:~# akash tendermint show-node-id

af88523de02b3943d0e29c8b4d97408b3f0c1098
```

**Create Validator Account**

> NOTE- ensure to capture the mnemonic outputted by the `akash keys add` command for future use/account recovery as needed

* Create an account with the key name of `default`

```
export AKASH_KEYRING_BACKEND=test

akash keys add default
```

#### STEP 4 - Initialize the New Blockchain

> _**NOTE**_ - the steps in this section should be performed in the CLI session within the Validator that was established

**Add this Genesis Account**

* In this step we add the account created - with the keyname of `default` - in the previous step as a genesis account and fund it with `100,000,000 AKT`

```
akash add-genesis-account $(akash keys show default -a) 100000000000000uakt
```

**Create the Blockchain Genesis with First Validator Defined**

* Generate the network genesis tramsaction with the initial validator account created prior and fund the validator with `1,000,000 AKT`
* This step creates a transaction which we will then update the network's genesis file with in the subsequent step and prior to actual network creation
* The blockchain is not actually intiialed in this step - that will happen in the subsequent step - but the genesis.json file will be generated for network initialization here.

```
akash gentx default 1000000000000uakt --chain-id sandbox-01
```

_**EXPECTED/EXAMPLE OUTPUT**_

```
root@validator-01-0:~# akash gentx default 1000000000000uakt --chain-id sandbox-01

Genesis transaction written to "/root/.akash/config/gentx/gentx-af88523de02b3943d0e29c8b4d97408b3f0c1098.json"
```

**Update genesis.json**

* Update the JSON file that the network is defined by with the transaction/update of the initial validator created in the previous step
* The output of this command will show current `genesis.json` with the first validators address included with the deep JSON structure

```
akash collect-gentxs
```

**Update Remaining/Necessary genesis.json File**

* There are a number of other `genesis.json` attributes that need updating before initializing the blockchain and these include:

```
.app_state.crisis.constant_fee.denom="uakt"
.app_state.gov.deposit_params.min_deposit[0].denom="uakt"
.app_state.mint.params.mint_denom="uakt"
.app_state.staking.params.bond_denom="uakt"
.app_state.gov.deposit_params.max_deposit_period="600s"
.app_state.gov.voting_params.voting_period="600s"
```

* To update the genesis definitions with these values execute these command sets
* In this approach we first copy the genesis file with the desired updated values discussed above into a new file named `genesis.json.new`
* We then compare via a diff the pre-existing and new genesis files
* Following review of the diff and changes intended, we replace the pre-existing genesis file with the new version
*

```
cat ~/.akash/config/genesis.json | jq -r '.app_state.crisis.constant_fee.denom="uakt"|.app_state.gov.deposit_params.min_deposit[0].denom="uakt"|.app_state.mint.params.mint_denom="uakt"|.app_state.staking.params.bond_denom="uakt"|.app_state.gov.deposit_params.max_deposit_period="600s"|.app_state.gov.voting_params.voting_period="600s"' > ~/.akash/config/genesis.json.new

diff ~/.akash/config/genesis.json ~/.akash/config/genesis.json.new

mv ~/.akash/config/genesis.json.new ~/.akash/config/genesis.json
```

**Preserve/Serve `genesis.json` File**

* We should store the `genesis.json` file in a place we can retrieve it from later and also to serve the file as a source for other Validator/RPC Nodes coming onto the network in the future
* We could use a services like `transfer.sh` to upload the file to and which will provide a URL for later access. Or we could store in a GitHub repo or Gist. For simplicity in this example we use a GH Gist post and that example can be found [here](https://gist.githubusercontent.com/chainzero/b4d767686a787bdd9bb0ea7510af17f3/raw/7e523d81d81de5d323baeed12907cea6bbb2b8bd/genesis.json).

#### STEP 5 - Initialize the Blockchain

> _**NOTE**_ - conduct the steps in this section from the Kubernetes control-plane node

**Update Validator Statefull Set**

* Update the Validator stateful set with removal of initial commands that initially put the associated pod in a sleep infinity condition to allow access and configuration.
* Now with the node configured we can remove sleep infinity and allow the pod to initialize the first validator on the network

```
kubectl patch statefulset validator-01 --type='json' -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}, {"op": "remove", "path": "/spec/template/spec/containers/0/args"}]'
```

**Verify the Validator is Writing Blocks**

* Verify that the validator is writing blocks to the blochchain by continually monitoring the validator pod

```
kubectl logs statefulset/validator-01 -f
```

_**EXAMPLE/EXPECTED OUTPUT**_

* This is an example message from a single blockchain write and for a single block. There should be incrementing block numbers/writes every several second and each with this type of log message.

```
INF committed state app_hash=B423ACA69FB037927DCD3FEBFD7B70F448673372380811273F7E3096F1DFA648 height=39 module=state num_txs=0
INF indexed block exents height=39 module=txindex
INF Timed out dur=4986.142971 height=40 module=consensus round=0 step=1
```

### RPC Node Build

* With a functional/live blockchain, we will launch the network's first RPC node for use by the Akash Provider we will build eventually and for other network query/transaction operations

#### STEP 1 - Create Persistent Volumes

> NOTE - example blockchain deployed on Google Cloud (GCP) and thus manually creating Kubernetes Persistent Volumes. In other environments this may be seen as unnecessary and may allow Container Storage Interface (CSI) to auto provision the PVs.

**Create Mount Point Directories**

* Create the `/mnt/rpc`directory on each of the Kubernetes hosts

```
mkdir -p /mnt/rpc
```

**Create the Persistent Volumes**

* Create the Kubernetes Persistent Volumes using the following manifest

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-rpc-node1
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: akash-nodes
  local:
    path: /mnt/rpc
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-rpc-node2
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: akash-nodes
  local:
    path: /mnt/rpc
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node2
```

#### STEP 2 - Deploy RPC Node Stateful Set

* Prior to creating this RPC Node stateful set via the manifest below - ensure to update these fields:
* `image` - update with latest Omnibus generic image found [here](https://github.com/akash-network/cosmos-omnibus/pkgs/container/cosmos-omnibus)
* `BINARY_URL` - update this env variable with current/desired Akash Node version
* `P2P_SEEDS`, `AKASH_P2P_PRIVATE_PEER_IDS`, `AKASH_P2P_PERSISTENT_PEERS`, `AKASH_P2P_UNCONDITIONAL_PEER_IDS`- update each of these env variables with the node ID captured prior in the `Capture the Node ID of the Validator` step
* `GENESIS_URL` - replace this env variable with the URL hosting the geneis.json files captured prior in step `Preserve/Serve genesis.json File`

```
# StatefulSet for rpc service
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: rpc
spec:
  serviceName: "rpc-service"
  replicas: 1
  selector:
    matchLabels:
      app: rpc
  template:
    metadata:
      labels:
        app: rpc
    spec:
      containers:
      - name: rpc
        image: "ghcr.io/akash-network/cosmos-omnibus:v0.4.11-rc1-generic"
        env:
        - name: PROJECT_BIN
          value: akash
        - name: BINARY_URL
          value: https://github.com/akash-network/node/releases/download/v0.32.2/akash_0.32.2_linux_amd64.zip
        - name: MONIKER
          value: rpc-01
        - name: MINIMUM_GAS_PRICES
          value: 0.025uakt
        - name: FASTSYNC_VERSION
          value: v0
        - name: P2P_SEEDS
          value: af88523de02b3943d0e29c8b4d97408b3f0c1098@validator-01:26656
        - name: AKASH_P2P_PRIVATE_PEER_IDS
          value: af88523de02b3943d0e29c8b4d97408b3f0c1098
        - name: AKASH_P2P_PERSISTENT_PEERS
          value: af88523de02b3943d0e29c8b4d97408b3f0c1098@validator-01:26656
        - name: AKASH_P2P_UNCONDITIONAL_PEER_IDS
          value: af88523de02b3943d0e29c8b4d97408b3f0c1098
        - name: CHAIN_ID
          value: sandbox-01
        - name: GENESIS_URL
          value: https://gist.githubusercontent.com/chainzero/b4d767686a787bdd9bb0ea7510af17f3/raw/7e523d81d81de5d323baeed12907cea6bbb2b8bd/genesis.json
        - name: AKASH_API_ENABLE
          value: "true"
        - name: AKASH_PRUNING
          value: custom
        - name: AKASH_PRUNING_INTERVAL
          value: "10"
        - name: AKASH_PRUNING_KEEP_EVERY
          value: "500"
        - name: AKASH_PRUNING_KEEP_RECENT
          value: "100"
        - name: AKASH_STATE_SYNC_SNAPSHOT_INTERVAL
          value: "500"
        - name: COSMOVISOR_ENABLED
          value: "1"
        - name: DAEMON_ALLOW_DOWNLOAD_BINARIES
          value: "true"
        - name: DAEMON_RESTART_AFTER_UPGRADE
          value: "true"
        - name: DAEMON_LOG_BUFFER_SIZE
          value: "512"
        - name: UNSAFE_SKIP_BACKUP
          value: "true"
        volumeMounts:
        - name: data
          mountPath: /root/.akash
        ports:
        - name: api
          containerPort: 1317
        - name: grpc
          containerPort: 9090
        - name: p2p
          containerPort: 26656
          hostPort: 26656
        - name: rpc
          containerPort: 26657
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 50Gi
      storageClassName: akash-nodes
---
apiVersion: v1
kind: Service
metadata:
  name: rpc
spec:
  selector:
    app: rpc
  ports:
    - protocol: TCP
      port: 1317
      targetPort: 1317
      name: api
    - protocol: TCP
      port: 9090
      targetPort: 9090
      name: grpc
    - protocol: TCP
      port: 26656
      targetPort: 26656
      name: p2p
    - protocol: TCP
      port: 26657
      targetPort: 26657
      name: rpc
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: akash-nodes
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

#### STEP 3 - Confirm RPC Node Status

> _**NOTE**_ - ensure the RPC Node pod created in the prior step is in a `Running` status prior to completing the steps in this section

**Create a Session into the Validator Pod**

> _**NOTE**_ - following this section all remaining commands in this seciton shold be conducted from within the RPC Node pod CLI session established

```
kubectl exec -ti rpc-0 -- bash
```

**Query Node Status**

* Checking the RPC node status will display latest block height received, if the RPC Node is in sync, etc

```
akash status
```

_**EXAMPLE/EXPECTED OUTPUT**_

* The node should eventually reach a status of `"catching_up":false` as demonstrated in the lengthy JSON output example below.
* Search for `catching_up` to see example/expected status. It may take the RPC node some time to catch up depending on how many blocks are on the blockchain. Should sync very quickly if you are performing this build shortly after the chain initiation.

```
{"NodeInfo":{"protocol_version":{"p2p":"8","block":"11","app":"0"},"id":"7cacf5b9b4609955651832dc956462748e6d5683","listen_addr":"tcp://0.0.0.0:26656","network":"sandbox-01","version":"0.34.27","channels":"40202122233038606100","moniker":"rpc-01","other":{"tx_index":"on","rpc_address":"tcp://0.0.0.0:26657"}},"SyncInfo":{"latest_block_hash":"354FE2E80583C4C5035473557C1268C5CEB4EA020A04ED2F23B1C8A64840538F","latest_app_hash":"C8D05A64741A9F80003482397A62C47BA8AF71198AB46901EFD4FBB2666A9A84","latest_block_height":"4055","latest_block_time":"2024-03-23T01:45:43.804861718Z","earliest_block_hash":"667680E786A4F4D371202BA1D184433405161F9A2775283BA79AB8937EF08F53","earliest_app_hash":"E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855","earliest_block_height":"1","earliest_block_time":"2024-03-22T18:25:20.428854275Z","catching_up":false},"ValidatorInfo":{"Address":"19764CA8E5E85F2186DAF1CF64923D99D9AFCB17","PubKey":{"type":"tendermint/PubKeyEd25519","value":"hv05xEVMkG5zYA7m6MiiGVLncTUn3FssG1HO1NnSIts="},"VotingPower":"0"}}
```

### Akash Provider Build

* Build the Akash Provider via Helm Charts and via this [documentation](https://akash.network/docs/providers/build-a-cloud-provider/akash-cloud-provider-build-with-helm-charts/)
* Conduct build from control-plane node of pre-existing Kubernetes cluster
* Review additional notes section below for guidance on setting up a provider for test blockchain use

#### Additional Notes Provider Build

_**Provider Account Creation and Configuration**_

* Install `provider-services` binary and create/import provider Akash address
* Configure environment variables as follows replacing the account address with your provider address

```
AKASH_KEY_NAME=default

AKASH_KEYRING_BACKEND=test

export AKASH_CHAIN_ID="sandbox-01"

export AKASH_ACCOUNT_ADDRESS=akash1mtnuc449l0mckz4cevs835qg72nvqwlul5wzyf
 
export AKASH_NODE=http://rpc:26657

export AKASH_GAS=auto
export AKASH_GAS_ADJUSTMENT=1.5
export AKASH_GAS_PRICES=0.025uakt
export AKASH_SIGN_MODE=amino-json
```

_**Fund Provider Account**_&#x20;

* Import the validator account to send funds to the provider account
* Enter the mnemonic for the account when prompted
* Example:

```
provider-services keys add validator --recover
```

* Transfer funds from the valiadtor account to the provider account
* Example:

```
provider-services tx send <valdiator-address> <provider-address> 100000000uakt
```

_**Chain ID Specification**_

* Ensure the chain ID is specified as `sandbox-01` in the `provider.yaml` file such as (replace address and other elements as necessary):

```
---
from: "$ACCOUNT_ADDRESS"
key: "$(cat ~/key.pem | openssl base64 -A)"
keysecret: "$(echo $KEY_PASSWORD | openssl base64 -A)"
domain: "$DOMAIN"
node: "$NODE"
withdrawalperiod: 12h
chainid: sandbox-01
attributes:
  - key: region
    value: "us-central"
  - key: host
    value: akash
  - key: tier
    value: community
  - key: organization
    value: "akashtesting"
```

### CosmoVisor Network Upgrade Test

**Create Proposal**

_**Notes on Proposal Customization**_

Create a network upgrade proposal on the blockchain using the `Example Full Proposal` below. This JSON proposal example should be updated for your purposes in the following sections:

_**Example Full Proposal**_

```
```
