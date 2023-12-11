# Akash Provider Repo SDL Testing Coverage

# Content
* CURRENT TESTS
	* [Persistent Storage](#persistent-storage)
	* [IP Leases](#ip-leases)
	* [GPU](#gpu)
	* [Services](#services)
	* [Profiles](#profiles)
	* [Placement](#placement)
	* [Resources](#resources)
	* [Escrow/Payments](#escrow/payments)
	* [General](#general)
* SUGGESTED ADDITIONS	

# ***Current Tests***

# Persistent Storage

## Test Coverage

| Focus Area | Success/Failure Test | Test Specs |
|----------|----------|----------|
| ***Persistent Storage*** |  |  |
|  | ***Success*** |  |
| | | [SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST WITH BETA2 STORAGE TYPE](#simple-persistent-storage-deployment-test-with-beta2-storage-type) |
|  | ***Failure*** |  |
| | | [SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST WITH NO MOUNT SPECIFIED](#simple-persistent-storage-deployment-test-with-no-mount-specified) |
| | | [SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST FAIL ON NO ABSOLUTE MOUNT PATH](#simple-persistent-storage-deployment-test-fail-on-no-absolute-mount-path) |
| | | [SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST FAIL ON INVALID NAME](#simple-persistent-storage-deployment-test-fail-on-invalid-name) |
| | | [SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST FAIL ON ATTEMPT TO USE MOUNT PATH TWICE](#simple-persistent-storage-deployment-test-fail-on-attempt-to-use-mount-path-twice) |
| | | [SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST FAIL ON NO SERVICE CONFIG](#single-ip-lease-creation-and-with-multiple-services-assignment) |

### Expected Success

######  SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST WITH BETA2 STORAGE TYPE

* ***Description*** - verify simple persistent storage deployment with the storage type of BETA2.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-storage-beta2.yaml)
* ***Expected Outcome*** - success deployment/order creation with associated provider bid receipt for persistent storage type of BETA2. 

### Expected Failure

######  SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST WITH NO MOUNT SPECIFIED

* ***Description*** - Failure test when no mount point is provided for persistent storage use
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/storageClass1.yaml)
* ***Expected Outcome*** -  The SDL should fail validation on deployment creation attempt as there is no mount point specified for persistent storage in the `services > params > storage > configs` stanza.

######  SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST FAIL ON NO ABSOLUTE MOUNT PATH

* ***Description*** - Failure test when no absolute directory path is supplied in mount point.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/storageClass2.yaml)
* ***Expected Outcome*** -  The SDL should fail validation on deployment creation attempt as the persistent storage mount point specified is a relative path of `etc/nginx`.  If the path were the absolute path of `/etc/nginx` the validation would succeed.

######  SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST FAIL ON INVALID NAME

* ***Description*** - Failure test when the persistent storage name does not align with name provided in services stanza.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/storageClass3.yaml)
* ***Expected Outcome*** -  The SDL should fail validation on deployment creation attempt as the persistent storage name specified in the `profiles` stanza - which is `configs` - does not align with the name used in the `services` stanza which is `data`.

######  SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST FAIL ON ATTEMPT TO USE MOUNT PATH TWICE

* ***Description*** - Failure test when a single mount path is used on more than one persistent storage volume.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/storageClass4.yaml)
* ***Expected Outcome*** -  The SDL should fail validation on deployment creation attempt as the persistent storage mount point of `/etc/nginx` is used on multiple persistent storage volumes within the `services` stanza.

######  SIMPLE PERSISTENT STORAGE DEPLOYMENT TEST FAIL ON NO SERVICE CONFIG

* ***Description*** - Failure test when no config for persistent storage is present in the `services > params > storage` stanza.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/storageClass5.yaml)
* ***Expected Outcome*** -  The SDL should fail validation on deployment creation attempt as the `params > storage` section of the `services` stanza does not contain expected specifications (volume name and mount point).

# IP Leases

## Test Coverage

| Focus Area | Success/Failure Test | Test Specs |
|----------|----------|----------|
| ***IP Leases*** |  |  |
|  | ***Success*** |  |
| | | [SIMPLE IP LEASES CREATION AND ASSIGNMENT](#simple-ip-leases-creation-and-assignment) |
| | | [MULTIPLE AND UNIQUE IP LEASES CREATION AND ASSIGNMENT - MULTIPLE PLACEMENT GROUPS](#multiple-and-unique-ip-leases-creation-and-assignment---multiple-placement-groups) |
| | | [MULTIPLE AND UNIQUE IP LEASES CREATION AND ASSIGNMENT - SINGLE PLACEMENT GROUP](#multiple-and-unique-ip-leases-creation-and-assignment---single-placement-group) |
| | | [MULTIPLE AND UNIQUE IP LEASES CREATION AND ASSIGNMENT - MULTIPLE PLACEMENT GROUPS](#multiple-and-unique-ip-leases-creation-and-assignment---multiple-placement-groups) |
| | | [SINGLE IP LEASE CREATION AND WITH MULTIPLE SERVICES ASSIGNMENT ](#single-ip-lease-creation-and-with-multiple-services-assignment) |
|  |


### Expected Success

######  SIMPLE IP LEASES CREATION AND ASSIGNMENT

* ***Description*** - validation of IP Leases creation and assignment to service .
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-ip-endpoint.yamll)
* ***Expected Outcome*** - deployment creation succeeds with the creation of an IP endpoint named `meow` and successful assignment of the `meow` IP endpoint to the `web` service.  Bid received from provider supporting IP Leases.

######  MULTIPLE AND UNIQUE IP LEASES CREATION AND ASSIGNMENT - MULTIPLE PLACEMENT GROUPS
* ***Description*** -  two IP Leases declaration and assignment in unique deployment groups with multiple (two) placement groups.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-multi-groups-ip-endpoint.yaml)
* ***Expected Outcome*** 

######  MULTIPLE AND UNIQUE IP LEASES CREATION AND ASSIGNMENT - SINGLE PLACEMENT GROUP
* ***Description*** -  two IP Leases declaration and assignment in unique deployment groups with a single placement groups.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-multi-ip-endpoint.yamll)
* ***Expected Outcome*** - successful creation of two IP Leases with activation in associated deployment group.

######  MULTIPLE AND UNIQUE IP LEASES CREATION AND ASSIGNMENT - MULTIPLE PLACEMENT GROUPS
* ***Description*** -  two IP Leases declaration and assignment in unique deployment groups with multiple placement groups.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-multi-groups-ip-endpoint.yaml)
* ***Expected Outcome*** -  successful creation of two IP Leases with activation in associated deployment group.

######  SINGLE IP LEASE CREATION AND WITH MULTIPLE SERVICES ASSIGNMENT 
* ***Description*** - ensure that a single IP Lease may be shared by multiple services.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-shared-ip-endpoint.yaml)
* ***Expected Outcome*** - successful creation of a single IP Lease with verification of assignment to two services using unique ports (TCP 80 and 81).

### Expected Failure

## GPU

### Expected Success

### Expected Failure

## Services

### Expected Success

##### Intra Service Communication Test
* ***Description*** - validation of communication of intra service communication using web front-end to Redis Server using Redis service name.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-c2c.yaml)
* ***Expected Outcome*** - web front-end should have successful communication with Redis pod via Redis service name.

##### Node Port Assignment Test
* ***Description*** - ensure a Kubernetes node port is assigned to service when a non-HTTP port is specified.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-nodeport.yaml)
* ***Expected Outcome*** - assignment of node port in the range of 30000-32767 when a non-HTTP port is specified in SDL port field.

##### URL Assignment on HTTP Service
* ***Description*** - ensure assignment of URL on HTTP/HTTPS port usage within service.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-nohost.yaml)
* ***Expected Outcome*** - assignment of valid HTTP URL for web services.  Current SDL creates a single HTTP service and thus should expect a single URL assignment.  URL should be in format of `<uniqueid>.provider.<provider-domain-name>`

##### PRIVATE SERVICE VALIDATION
* ***Description*** - ensure a service that does not have `global: true` specification in the `expose\to` stanza is only reachable to specified services of the same SDL.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/private_service.yaml)
* ***Expected Outcome*** - referenced SDL should create a service with no node port assignment that should only be reachable inside the Kubernetes cluster and only to services it is exposed to explicitly.  In the SDL tested only the `bind` service should have access to the `pg` service.

### Expected Failure

##### MISALIGNMENT/INCONSISTENT SERVICE NAMES
* ***Description*** - service name mismatch in the declaration within the `services` stanza and the use of the service in the `deployment` stanza
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/deployment-svc-mismatch.yaml)
* ***Expected Outcome*** - referenced SDL names the service `web` in the `services` stanza but references the service with name `webapp` in the `deployment stanza.  The misalignment of service name between stanzas should result in a validation failure during deployment creation transaction send.

## Profiles

### Expected Success

### Expected Failure

## Placement

### Expected Success

### Expected Failure

## Resources

### Expected Success

### Expected Failure

## Escrow/Payments

### Expected Success

##### Custom Denomination Test

###### TEST1

* Description - validation of payment using custom denom in placement section of the SDL.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-custom-currency.yaml)
* ***Expected Outcome*** - deployment creation succeeds with custom demon specified and bids received from provider supporting denom.

##### Per Block Price Specification Test

###### TEST1
* Description - validation of specified per block pricing specification.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/deployment/deployment-v2-escrow.yaml)
* ***Expected Outcome*** - bid received from provider with a per block price of less than or equal to specified amount.

### Expected Failure

## General

### Expected Success

######  SIMPLE DEPLOYMENT - SINGLE SERVICE

* ***Description*** -  simple deployment test with a single service.  No IP Leases, persistent storage, or other services.
* [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/simple.yaml)
* ***Expected Outcome*** - successful deployment/order creation with receipt of provider bid on simple, single service SDL

### Expected Failure

###### SIMPLE DEPLOYMENT - TWO SERVICES

-   **Description**  - simple deployment test with two services. Deployment should fail validation as two services are declared but only one used.  No IP Leases, persistent storage, or other services.
-   [Current SDL](https://github.com/akash-network/provider/blob/f13aca40ac42f96b80ec5e863cdfa20093e23b44/testdata/sdl/simple2.yaml)
-   _**Expected Outcome**_  - simple deployment with two services declares should fail validation as only one of the created services is called in the `deployment` stanza.

# Suggested Additions

######  DEPLOYMENT WITH MULTIPLE SERVICES USING DIFFERENT REPLICA COUNTS

* ***Description*** -  create deployment/order with multiple services using different replica counts and ensure bid receipt from provider.