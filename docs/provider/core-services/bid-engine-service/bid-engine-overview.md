---
sidebar_position: 1
---

# Bid Engine Overview

## Section 1 - Event Bus

* [Provider Service Calls/Initiates the BidEngine Service](./bid-engine-initiate.md)
* [BidEngine Calls/Initiates an Event Bus to Monitor New Orders](./bid-engine-order-processing.md)
* [BidEngine Loop is Created to React to New Order Receipt and Then Process Order](./bid-engine-order-processing.md)

## Section 2 - Order Receipt and Initial Processing
* [Order/Bid Process Manager Uses Perpetual Loop for Event Processing and to Complete Each Step in Bid Process](./bid-engine-loop.md)
* [Bid Engine Order Detail Fetch](./bid-engine-deployment-fetch.md)
* [groupch Channel Processing](./bid-engine-groupch.md)

## Section 3 - Bid Pricing and Response
* [shouldBidCh Channel Processing](./bid-engine-should-bid-chan.md)
* [clusterch Channel Prcoessing](./bid-engine-clusterch.md)
* [pricech Channel Processing](./bid-engine-pricech.md)
* [bidch Channel Processing](./bid-engine-bidch.md)