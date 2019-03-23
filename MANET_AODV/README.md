# Purpose
Review Ad-Hoc On-Demand Distance Vector Routing of Mobile Ad-Hoc Network(MANET).

# 1 Introduction
AODV allows mobile nodes to respond to link breakages and changes in network topology in a timely manner.
The operation of AODV is loop-free, and by avoiding the Bellman-Ford "counting to infinity" problem offers quick convergence when the ad
hoc network topology changes (typically, when a node moves in the network).

One distinguishing feature of AODV is its use of a destination sequence number for each route entry.  The destination sequence
number is created by the destination to be included along with any route information it sends to requesting nodes.  Using destination
sequence numbers ensures loop freedom and is simple to program.
Given the choice between two routes to a destination, a requesting node is required to select the one with the greatest sequence number.

# 2 Overview
Route Requests (RREQs), Route Replies (RREPs), and Route Errors (RERRs) are the message types defined by AODV.
These message types are received via UDP, and normal IP header processing applies.
For broadcast messages, the IP limited broadcast address (255.255.255.255) is used.
This means that such messages are not blindly forwarded.  However, AODV operation does require certain messages (e.g., RREQ) to be
disseminated widely, perhaps throughout the ad hoc network.  
The range of dissemination of such RREQs is indicated by the TTL in the IP header.  Fragmentation is typically not required.

As long as the endpoints of a communication connection have valid routes to each other, AODV does not play any role.
When a route to a new destination is needed, the node broadcasts a RREQ to find a route to the destination.
A route can be determined when the RREQ reaches either the destination itself, or an intermediate node with a 'fresh enough' route to the destination.
A **'fresh enough'** route is a valid route entry for the destination whose associated sequence number is at least as great as that contained in the RREQ.
The route is made available by unicasting a RREP back to the origination of the RREQ.
Each node receiving the request caches a route back to the originator of the request, so that the RREP can be unicast from the destination along a path to that originator, or likewise from any intermediate node that is able to satisfy the request.

Nodes monitor the link status of next hops in active routes.  
When a link break in an active route is detected, a RERR message is used to notify other nodes that the loss of that link has occurred.
The RERR message indicates those destinations (possibly subnets) which are no longer reachable by way of the broken link.
In order to enable this reporting mechanism, each node keeps a **"precursor list"**, containing the IP address for each its neighbors that are likely to use it as a next hop towards each destination.
The information in the precursor lists is most easily acquired during the processing for generation of a RREP message, which by definition has to be sent to a node in a **precursor list (see section 6.6)**. 
If the RREP has a nonzero prefix length, then the originator of the RREQ which solicited the RREP information is included among the precursors for the subnet route (not specifically for the particular destination).

A RREQ may also be received for a multicast IP address.  In this document, full processing for such messages is not specified.

AODV is a routing protocol, and it deals with route table management.  Route table information must be kept even for short-lived routes,
such as are created to temporarily store reverse paths towards nodes originating RREQs.
AODV uses the following fields with each route table entry:
```
   -  Destination IP Address
   -  Destination Sequence Number
   -  Valid Destination Sequence Number flag
   -  Other state and routing flags (e.g., valid, invalid, repairable, being repaired)
   -  Network Interface
   -  Hop Count (number of hops needed to reach destination)
   -  Next Hop
   -  List of Precursors (described in Section 6.2)
   -  Lifetime (expiration or deletion time of the route)
```

Managing **the sequence number** is crucial to avoiding routing loops, even when links break and a node is no longer reachable to supply its own information about its sequence number.
When these conditions occur, the route is invalidated by operations involving the sequence number and marking the route table entry state as invalid.  See section 6.1 for details.

# 3. AODV Terminology
## active route
A route towards a destination that has a routing table entry that is marked as valid.  Only active routes can be used to forward data packets.

## broadcast
Broadcasting means transmitting to the IP Limited Broadcast address, 255.255.255.255.

## destination
An IP address to which data packets are to be transmitted. Same as "destination node".

## forwarding node
A node that agrees to forward packets destined for another node, by retransmitting them to a next hop that is closer to the unicast destination along a path that has been set up using routing control messages.

## forward route
A route set up to send data packets from a node originating a Route Discovery operation towards its desired destination.

## invalid route
A route that has expired, denoted by a state of invalid in the routing table entry.
An invalid route is used to store previously valid route information for an extended period of time.
An invalid route cannot be used to forward data packets, but it can provide information useful for route repairs, and also for future RREQ messages.

## originating node
A node that initiates an AODV route discovery message to be processed and possibly retransmitted by other nodes in the ad hoc network.

## reverse route
A route set up to forward a reply (RREP) packet back to the originator from the destination or from an intermediate node having a route to the destination.

## sequence number
A monotonically increasing number maintained by each originating node.  
In AODV routing protocol messages, it is used by other nodes to determine the freshness of the information contained from the originating node.

## valid route
See active route.

# 4. Applicability Statement
The AODV routing protocol is designed for mobile ad hoc networks with populations of tens to thousands of mobile nodes.  
AODV can handle low, moderate, and relatively high mobility rates, as well as a variety of data traffic levels.
AODV is designed for use in networks where the nodes can all trust each other, either by use of preconfigured keys, or because it is known that there are no malicious intruder nodes.  
AODV has been designed to reduce the dissemination of control traffic and eliminate overhead on data traffic, in order to improve scalability and performance.

# 5. Message Formats

## 5.1. Route Request (RREQ) Message Format
```
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Type      |J|R|G|D|U|   Reserved          |   Hop Count   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                            RREQ ID                            |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Destination IP Address                     |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                  Destination Sequence Number                  |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Originator IP Address                      |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                  Originator Sequence Number                   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

The format of the Route Request message is illustrated above, and contains the following fields:
```
      Type           1

      J              Join flag; reserved for multicast.

      R              Repair flag; reserved for multicast.

      G              Gratuitous RREP flag; indicates whether a gratuitous RREP should be unicast to the node                     
                     specified in the Destination IP Address field (see sections 6.3, 6.6.3).                     

      D              Destination only flag; indicates only the destination may respond to this RREQ (see                     
                     section 6.5).

      U              Unknown sequence number; indicates the destination sequence number is unknown (see section 6.3).                     

      Reserved       Sent as 0; ignored on reception.

      Hop Count      The number of hops from the Originator IP Address to the node handling the request.                     

      RREQ ID        A sequence number uniquely identifying the particular RREQ when taken in conjunction with the
                     originating node's IP address.

      Destination IP Address
      Destination Sequence Number
      Originator IP Address
      Originator Sequence Number                  
```

## 5.2. Route Reply (RREP) Message Format
```
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Type      |R|A|    Reserved     |Prefix Sz|   Hop Count   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                     Destination IP address                    |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                  Destination Sequence Number                  |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Originator IP address                      |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                           Lifetime                            |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

The format of the Route Reply message is illustrated above, and contains the following fields:
```
      Type          2

      R             Repair flag; used for multicast.

      A             Acknowledgment required; see sections 5.4 and 6.7.

      Reserved      Sent as 0; ignored on reception.

      Prefix Size   If nonzero, the 5-bit Prefix Size specifies that the indicated next hop may be used for any nodes with                    
                    the same routing prefix (as defined by the Prefix Size) as the requested destination.                    

      Hop Count     The number of hops from the Originator IP Address to the Destination IP Address.  
                    For multicast route requests this indicates the number of hops to the                    
                    multicast tree member sending the RREP.

      Destination IP Address
      Destination Sequence Number
      Originator IP Address

      Lifetime      The time in milliseconds for which nodes receiving the RREP consider the route to be valid.
```

## 5.3. Route Error (RERR) Message Format
```
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Type      |N|          Reserved           |   DestCount   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |            Unreachable Destination IP Address (1)             |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |         Unreachable Destination Sequence Number (1)           |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-|
   |  Additional Unreachable Destination IP Addresses (if needed)  |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |Additional Unreachable Destination Sequence Numbers (if needed)|
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

The format of the Route Error message is illustrated above, and contains the following fields:
```
      Type        3

      N           No delete flag; set when a node has performed a local repair of a link, and upstream nodes should not delete                  
                  the route.

      Reserved    Sent as 0; ignored on reception.

      DestCount   The number of unreachable destinations included in the message; MUST be at least 1.                  

      Unreachable Destination IP Address
                  The IP address of the destination that has become unreachable due to a link break.                  

      Unreachable Destination Sequence Number
                  The sequence number in the route table entry for
                  the destination listed in the previous Unreachable Destination IP Address field.                  
```
The RERR message is sent whenever a link break causes one or more destinations to become unreachable from some of the node's neighbors.
See section 6.2 for information about how to maintain the appropriate records for this determination, and 
section 6.11 for specification about how to create the list of destinations.

# 6. AODV Operation
This section describes the scenarios under which nodes generate Route Request (RREQ), Route Reply (RREP) and Route Error (RERR) messages for unicast communication towards a destination, and how the message data are handled.  
In order to process the messages correctly, certain state information has to be maintained in the route table entries for the destinations of interest.

All AODV messages are sent to port 654 using UDP.

## 6.1. Maintaining Sequence Numbers
Every route table entry at every node MUST include the latest information available about the sequence number for the IP address of the destination node for which the route table entry is maintained.
This sequence number is called the **"destination sequence number"**.  It is updated whenever a node receives new (i.e., not stale) information about the sequence number from **RREQ, RREP, or RERR** messages that may be received related to that destination.
AODV depends on each node  in the network to own and maintain its destination sequence number to guarantee the loop-freedom of all routes towards that node.
A destination node increments its own sequence number in two circumstances:
```
   -  Immediately before a node originates a route discovery, it MUST increment its own sequence number.
      This prevents conflicts with previously established reverse routes towards the originator of a
      RREQ.

   -  Immediately before a destination node originates a RREP in response to a RREQ,
      it MUST update its own sequence number to the maximum of its current sequence number and the destination      
      sequence number in the RREQ packet.
```

When the destination increments its sequence number, it MUST do so by treating the sequence number value as if it were an unsigned number.

In order to ascertain that information about a destination is not stale, the node compares its current numerical value for the sequence number with that obtained from the incoming AODV message.
If **the result of subtracting the currently stored sequence number from the value of the incoming sequence number is less than zero**, then the information related to **that destination in the AODV message MUST be discarded**, since that information is stale compared to the node's currently stored information.

The only other circumstance in which a node may change the destination sequence number in one of its route table entries is in response to **a lost or expired link to the next hop towards that destination**.

The node determines which destinations use a particular next hop by consulting its routing table.  In this case, for each destination that uses the next hop, **the node increments the sequence number and marks the route as invalid (see also sections 6.11, 6.12)**.

A node may change the sequence number in the routing table entry of a destination only if:
```
   -  it is itself the destination node, and offers a new route to itself, or      

   -  it receives an AODV message with new information about the sequence number for a destination node, or      

   -  the path towards the destination node expires or breaks.
```

## 6.2. Route Table Entries and Precursor Lists
When a node receives an AODV control packet from a neighbor, or creates or updates a route for a particular destination or subnet, it checks its route table for an entry for the destination.
In the event that there is no corresponding entry for that destination, an entry is created.
The sequence number is either determined from the information contained in the control packet, or else the valid sequence number field is set to false. 

The route is only updated if the new sequence number is either
```
   (i)       higher than the destination sequence number in the route table, or             

   (ii)      the sequence numbers are equal, but the hop count (of the new information) plus one, is smaller than the existing hop             
             count in the routing table, or

   (iii)     the sequence number is unknown.
```

The Lifetime field of the routing table entry is either determined from the control packet, or **it is initialized to ACTIVE_ROUTE_TIMEOUT**.

Each time a route is used to forward a data packet, its Active Route Lifetime field of the source, destination and the next hop on the path to the destination is updated to be no less than the current time plus ACTIVE_ROUTE_TIMEOUT.

Since the route between each originator and destination pair is expected to be symmetric, the Active Route Lifetime for the previous hop, along the reverse path back to the IP source, is **also updated to be no less than the current time plus ACTIVE_ROUTE_TIMEOUT**.  
The lifetime for an Active Route is updated each time the route is used regardless of whether the destination is a single node or a subnet.

For each valid route maintained by a node as a routing table entry, **the node also maintains a list of precursors that may be forwarding packets on this route**.
These precursors will receive notifications from the node in the event of detection of the loss of the next hop link.  
The list of precursors in a routing table entry contains those neighboring nodes to which a route reply was generated or forwarded.

## 6.3. Generating Route Requests
A node disseminates a RREQ when it determines that it needs a route to a destination and does not have one available.
This can happen if the destination is previously unknown to the node, or if a previously valid route to the destination expires or is marked as invalid.
The Destination Sequence Number field in the RREQ message is the last known destination sequence number for this destination and is copied from the Destination Sequence Number field in the routing table.
**If no sequence number is known, the unknown sequence number flag MUST be set**.

The Originator Sequence Number in the RREQ message is the node's own sequence number, which is incremented prior to insertion in a RREQ.  
The RREQ ID field is incremented by one from the last RREQ ID used by the current node.  Each node maintains only one RREQ ID.  
The Hop Count field is set to zero.

Before broadcasting the RREQ, the originating node buffers the **RREQ ID and the Originator IP address (its own address) of the RREQ for PATH_DISCOVERY_TIME**.  
In this way, when the node receives the packet again from its neighbors, it will not reprocess and re-forward the packet.

An originating node often expects to have bidirectional communications with a destination node.  
In order for this to happen as efficiently as possible, any generation of **a RREP by an intermediate node (as in section 6.6) for delivery to the originating node** SHOULD be accompanied by some action that **notifies the destination about a route back to the originating node**.  
The originating node selects this mode of operation in **the intermediate nodes by setting the 'G' flag**.  **See section 6.6.3** for details about actions taken by the intermediate node in response to a RREQ with the 'G' flag set.   

A node **SHOULD NOT** originate more than **RREQ_RATELIMIT RREQ messages per second**.  
After broadcasting a RREQ, a node waits for a RREP (or other control message with current information regarding a route to the appropriate destination).
If a route is not received **within NET_TRAVERSAL_TIME milliseconds**, the node MAY try again to discover a route by broadcasting another RREQ, **up to a maximum of RREQ_RETRIES times at the maximum TTL value**.  
Each new attempt **MUST increment and update the RREQ ID**.  For each attempt, the TTL field of the IP header is set according to the mechanism specified in section 6.4, in order to enable control over how far the RREQ is disseminated for the each retry.

Data packets **waiting for a route** (i.e., waiting for a RREP after a RREQ has been sent) **SHOULD be buffered**.  The buffering SHOULD be "first-in, first-out" (FIFO).  
If a route discovery has been attempted RREQ_RETRIES times **at the maximum TTL without receiving any RREP**, all data packets destined for the corresponding destination **SHOULD be dropped from the buffer** and **a Destination Unreachable message SHOULD be delivered to the application**.

To reduce congestion in a network, repeated attempts by a source node at route discovery for a single destination **MUST utilize a binary exponential backoff**.  
The first time a source node broadcasts a RREQ, **it waits NET_TRAVERSAL_TIME milliseconds** for the reception of a RREP.  
If a RREP is not received within that time, the source node sends a new RREQ.  
When calculating the time to wait for the RREP after sending the second RREQ, the source node MUST use a binary exponential backoff.  
Hence, the waiting time for the RREP corresponding to the **second RREQ** is **2 * NET_TRAVERSAL_TIME milliseconds**.  
If a RREP is not received within this time period, another RREQ may be sent, up to RREQ_RETRIES additional attempts after the first RREQ.  
**For each additional attempt, the waiting time for the RREP is multiplied by 2**, so that the time conforms to a binary exponential backoff.

## 6.4. Controlling Dissemination of Route Request Messages
To prevent unnecessary network-wide dissemination of RREQs, the originating node SHOULD use an **expanding ring search technique**.
In an expanding ring search, the originating node initially uses a TTL =TTL_START in the RREQ packet IP header and sets the timeout for receiving a RREP to RING_TRAVERSAL_TIME milliseconds.  
RING_TRAVERSAL_TIME is calculated as described in section 10.  The TTL_VALUE used in calculating RING_TRAVERSAL_TIME is set equal to the value of the TTL field in the IP header.  
If the RREQ times out without a corresponding RREP, the originator broadcasts the RREQ again with the TTL incremented by TTL_INCREMENT.
This continues **until the TTL set in the RREQ reaches TTL_THRESHOLD, beyond which a TTL = NET_DIAMETER is used for each attempt**.  
Each time, **the timeout for receiving a RREP is RING_TRAVERSAL_TIME.**  **When it is desired to have all retries traverse the entire ad hoc network, this can be achieved by configuring TTL_START and TTL_INCREMENT both to be the same value as NET_DIAMETER**.

The Hop Count stored in an invalid routing table entry indicates the last known hop count to that destination in the routing table.  
When a new route to the same destination is required at a later time (e.g., upon route loss), the TTL in the RREQ IP header is initially set to the Hop Count plus TTL_INCREMENT.
Thereafter, following each timeout the TTL is incremented by TTL_INCREMENT until TTL = TTL_THRESHOLD is reached.  
Beyond this TTL = NET_DIAMETER is used.
Once TTL = NET_DIAMETER, the timeout for waiting for the RREP is set to NET_TRAVERSAL_TIME, as specified in section 6.3.

An expired routing table entry **SHOULD NOT be expunged before (current_time + DELETE_PERIOD) (see section 6.11)**.
Otherwise, the soft state corresponding to the route (e.g., last known hop count) will be lost.  
Furthermore, a longer routing table entry expunge time MAY be configured.  
Any routing table entry **waiting for a RREP SHOULD NOT be expunged before (current_time + 2 * NET_TRAVERSAL_TIME)**.

## 6.5. Processing and Forwarding Route Requests
When a node receives a RREQ, it first creates or updates a route to the previous hop without a valid sequence number (see section 6.2) then checks to determine whether it has received a RREQ with the same Originator IP Address and RREQ ID **within at least the last PATH_DISCOVERY_TIME**.  
If such a RREQ has been received, **the node silently discards the newly received RREQ**.  
The rest of this subsection describes actions taken for RREQs that are not discarded.

First, **it first increments the hop count value in the RREQ by one**, to account for the new hop through the intermediate node.  
Then the node searches for **a reverse route to the Originator IP Address (see section 6.2), using longest-prefix matching**.  
If need be, the route is created, or updated using the Originator Sequence Number from the RREQ in its routing table.  
This reverse route will be needed **if the node receives a RREP back to the node that originated the RREQ** (identified by the Originator IP Address).  When the reverse route is created or updated, the following actions on the route are also carried out:
```
   1. the Originator Sequence Number from the RREQ is compared to the corresponding destination sequence number in the route table entry      
      and copied if greater than the existing value there

   2. the valid sequence number field is set to true;

   3. the next hop in the routing table becomes the node from which the RREQ was received (it is obtained from the source IP address in      
      the IP header and is often not equal to the Originator IP Address field in the RREQ message);      

   4. the hop count is copied from the Hop Count in the RREQ message;
```
Whenever a RREQ message is received, the Lifetime of the reverse route entry for the Originator IP address is set to be the maximum of
 (ExistingLifetime, MinimalLifetime), where

    MinimalLifetime =    (current time + 2*NET_TRAVERSAL_TIME - 2*HopCount*NODE_TRAVERSAL_TIME).

The current node can use the reverse route to forward data packets in the same way as for any other route in the routing table.

If a node does not generate a RREP (following the processing rules in section 6.6), and if the incoming IP header has TTL larger than 1,
 the node updates and broadcasts the RREQ to address 255.255.255.255 on each of its configured interfaces (see section 6.14).  
To update the RREQ, **the TTL or hop limit field in the outgoing IP header is decreased by one**, and **the Hop Count field in the RREQ message is incremented by one**, to account for the new hop through the intermediate node.  
Lastly, the Destination Sequence number for the requested destination is set to **the maximum of the corresponding value received in the RREQ message**, and the destination sequence value currently maintained by the node for the requested destination.   
However, **the forwarding node MUST NOT modify its maintained value for the destination sequence number**, **even if the value received in the incoming RREQ is larger than the value currently maintained by the forwarding node**.

Otherwise, **if a node does generate a RREP, then the node discards the RREQ**.  
Notice that, **if intermediate nodes reply to every transmission of RREQs for a particular destination, it might turn out that the destination does not receive any of the discovery messages**.  
In this situation, the destination does not learn of a route to the originating node from the RREQ messages.  
This could cause the destination to initiate a route discovery (for example, if the originator is attempting to establish a TCP session).  
**In order that the destination learn of routes to the originating node**, **the originating node SHOULD set the "gratuitous RREP" ('G') flag in the RREQ** if for any reason the destination is likely to need a route to the originating node.  
If, **in response to a RREQ with the 'G' flag set**, **an intermediate node returns a RREP, it MUST also unicast a gratuitous RREP to the destination node (see section 6.6.3)**.

## 6.6. Generating Route Replies
A node generates a RREP if either:
```
   (i)       it is itself the destination, or

   (ii)      it has an active route to the destination, the destination sequence number in the node's existing route table entry
             for the destination is valid and greater than or equal to the Destination Sequence Number of the RREQ (comparison             
             using signed 32-bit arithmetic), and the "destination only" ('D') flag is NOT set.
```

When generating a RREP message, **a node copies the Destination IP Address and the Originator Sequence Number from the RREQ message into the corresponding fields in the RREP message**.  
Processing is slightly different, depending on **whether the node is itself the requested destination (see section 6.6.1)**, or **instead if it is an intermediate node with an fresh enough route to the destination (see section 6.6.2)**.

Once created, the RREP is unicast to the next hop toward the originator of the RREQ, as indicated by the route table entry for that originator.  
**As the RREP is forwarded back towards the node which originated the RREQ message, the Hop Count field is incremented by one at each hop.**  
Thus, **when the RREP reaches the originator, the Hop Count represents the distance, in hops, of the destination from the originator**.

### 6.6.1. Route Reply Generation by the Destination
If the generating node is the destination itself, **it MUST increment its own sequence number by one if the sequence number in the RREQ packet is equal to that incremented value.**  
Otherwise, the destination does not change its sequence number before generating the RREP message.  
**The destination node places its (perhaps newly incremented) sequence number into the Destination Sequence Number field of the RREP, and enters the value zero in the Hop Count field of the RREP.**

The destination node copies the value MY_ROUTE_TIMEOUT (see section 10) into the Lifetime field of the RREP.  
Each node MAY reconfigure its value for MY_ROUTE_TIMEOUT, within mild constraints (see section 10).

### 6.6.2. Route Reply Generation by an Intermediate Node
If the node generating the RREP is **not the destination node**, but instead is an intermediate hop along the path from the originator to the destination, **it copies its known sequence number for the destination into the Destination Sequence Number field in the RREP message**.

The intermediate node updates the forward route entry by placing the last hop node (from which it received the RREQ, as indicated by the source IP address field in the IP header) **into the precursor list for the forward route entry -- i.e., the entry for the Destination IP Address**.  
The intermediate node also updates its route table entry for the node originating the RREQ by placing the next hop **towards the destination in the precursor list for the reverse route entry -- i.e., the entry for the Originator IP Address field of the RREQ message data**.

The intermediate node places **its distance in hops from the destination (indicated by the hop count in the routing table) Count field in the RREP**.  
**The Lifetime field of the RREP** is calculated by subtracting the current time from the expiration time in its route table entry.

### 6.6.3. Generating Gratuitous RREPs
After a node receives a RREQ and responds with a RREP, it discards the RREQ.  
**If the RREQ has the 'G' flag set**, and **the intermediate node returns a RREP to the originating node**, it **MUST also unicast a gratuitous RREP to the destination node**.  

**The gratuitous RREP** that is to be sent to the desired destination contains the following values in the RREP message fields:
```
   Hop Count                        The Hop Count as indicated in the node's route table entry for the originator                                 
                                    
   Destination IP Address           The IP address of the node that originated the RREQ                                    

   Destination Sequence Number      The Originator Sequence Number from the RREQ                                    

   Originator IP Address            The IP address of the Destination node in the RREQ
                                    
   Lifetime                         The remaining lifetime of the route towards the originator of the RREQ,                                    
                                    as known by the intermediate node.
```
*Intermediate node回給Destination node，Originator IP Address就你Destination node自己，不必回RREP*

The gratuitous RREP is then sent to the next hop along the path to the destination node, just as if the destination node had already issued a RREQ for the originating node and this RREP was produced in response to that (fictitious) RREQ.  
The RREP that is sent to the originator of the RREQ is the same whether or not the 'G' bit is set.

![alt tag](https://i.imgur.com/ZIMOAMa.jpg)

## 6.7. Receiving and Forwarding Route Replies
When a node receives a RREP message, it searches (using longest-prefix matching) for a route to the previous hop.  
If needed, a route is created for the previous hop, **but without a valid sequence number (see section 6.2)**.  
Next, **the node then increments the hop count value in the RREP by one**, to account for the new hop through the intermediate node.  
**Call this incremented value the "New Hop Count"**.   
Then the forward route for this destination is created if it does not already exist.  
Otherwise, **the node compares the Destination Sequence Number in the message with its own stored destination sequence number for the Destination IP Address in the RREP message**.  
Upon comparison, the existing entry is updated only in the following circumstances:
```
   (i)       the sequence number in the routing table is marked as invalid in route table entry.

   (ii)      the Destination Sequence Number in the RREP is greater than the node's copy of the destination sequence number and the             
             known value is valid, or

   (iii)     the sequence numbers are the same, but the route is is marked as inactive, or             

   (iv)      the sequence numbers are the same, and the New Hop Count is smaller than the hop count in route table entry.             
```

If the route table entry to the destination is created or updated, then the following actions occur:
```
   -  the route is marked as active,

   -  the destination sequence number is marked as valid,

   -  the next hop in the route entry is assigned to be the node from which the RREP is received, which is indicated by the source IP      
      address field in the IP header,

   -  the hop count is set to the value of the New Hop Count,

   -  the expiry time is set to the current time plus the value of the Lifetime in the RREP message,      

   -  and the destination sequence number is the Destination Sequence Number in the RREP message.      
```

The current node can subsequently use this route to forward data packets to the destination.

If the current node is not the node indicated by the Originator IP Address in the RREP message AND a forward route has been created or updated as described above, **the node consults its route table entry for the originating node to determine the next hop for the RREP packet**, and then **forwards the RREP towards the originator using the information in that route table entry**.  
If a node forwards a RREP over a link that is likely to **have errors or be unidirectional**, **the node SHOULD set the 'A' flag to require that the recipient of the RREP acknowledge receipt of the RREP** by **sending a RREP-ACK message back (see section 6.8)**.

When any node transmits a RREP, the precursor list for the corresponding destination node is updated by adding to it the next hop node to which the RREP is forwarded.  
Also, at each node the (reverse) route used to forward a RREP has its lifetime changed to be 
**the maximum of (existing-lifetime, (current time + ACTIVE_ROUTE_TIMEOUT)**.  
Finally, the precursor list for the next hop  towards the destination is updated to contain the next hop towards the source.

## 6.8. Operation over Unidirectional Links
It is possible that a RREP transmission may fail, especially if the RREQ transmission triggering the RREP occurs over a unidirectional link.  
If no other RREP generated from the same route discovery attempt reaches the node which originated the RREQ message, the originator will reattempt route discovery after a timeout (see section 6.3).  
However, the same scenario might well be repeated without any improvement, and no route would be discovered even after repeated retries.  
Unless corrective action is taken, this can happen even when bidirectional routes between originator and destination do exist.  
Link layers using **broadcast transmissions for the RREQ** will not be able **to detect the presence of such unidirectional links**.  
In AODV, any node acts on **only the first RREQ with the same RREQ ID and ignores any subsequent RREQs**.
Suppose, for example, that the first RREQ arrives along a path that has one or more unidirectional link(s).  
A subsequent RREQ may arrive via a bidirectional path (assuming such paths exist), but it will be ignored.

To prevent this problem, **when a node detects that its transmission of a RREP message has failed**, it remembers **the next-hop of the failed RREP** in a **"blacklist" set**.  
Such failures can be detected via the absence of a link-layer or network-layer acknowledgment (e.g., RREP-ACK).  A node ignores all RREQs received from any node in its blacklist set.  
Nodes **are removed from the blacklist set after a BLACKLIST_TIMEOUT period (see section 10)**.  This period should be set to the upper bound of the time it takes to perform the allowed number of route request retry attempts as described in section 6.3.

Note that the RREP-ACK packet does not contain any information about which RREP it is acknowledging.  
The time at which the RREP-ACK is received will likely come just **after the time when the RREP was sent with the 'A' bit**.
This information is expected to be sufficient to provide assurance to the sender of the RREP that the link is currently bidirectional, without any real dependence on the particular RREP message being acknowledged.

## 6.9. Hello Messages
A node MAY offer connectivity information by broadcasting local Hello messages.  A node **SHOULD only use hello messages if it is part of an active route**..  
**Every HELLO_INTERVAL milliseconds**, the node checks whether it has sent a broadcast (e.g., a RREQ or an appropriate layer 2 message) within the last HELLO_INTERVAL.  
If it has not, it **MAY broadcast a RREP with TTL = 1, called a Hello message, with the RREP message fields set** as follows:
```
      Destination IP Address         The node's IP address.

      Destination Sequence Number    The node's latest sequence number.

      Hop Count                      0

      Lifetime                       ALLOWED_HELLO_LOSS * HELLO_INTERVAL
```

A node MAY determine connectivity by listening for packets from its set of neighbors.  
If, within the past DELETE_PERIOD, it has received a Hello message from a neighbor, and then for that neighbor does not receive any packets (Hello messages or otherwise) for **more than ALLOWED_HELLO_LOSS * HELLO_INTERVAL milliseconds**, the node **SHOULD assume that the link to this neighbor is currently lost**.  When this happens, the node **SHOULD proceed as in Section 6.11**.

Whenever a node receives a Hello message from a neighbor, the node SHOULD make sure that it has an active route to the neighbor, and create one if necessary.  
If a route already exists, then **the Lifetime for the route should be increased, if necessary, to be at least ALLOWED_HELLO_LOSS * HELLO_INTERVAL**.  
The route to the neighbor, if it exists, **MUST subsequently contain the latest Destination Sequence Number from the Hello message**.
The current node can now begin using this route to forward data packets.  
Routes that are created by hello messages and not used by any other active routes will have empty precursor lists and would not trigger a RERR message if the neighbor moves away and a neighbor timeout occurs.

## 6.10. Maintaining Local Connectivity 
Each forwarding node **SHOULD keep track of its continued connectivity to its active next hops (i.e., which next hops or precursors have forwarded packets to or from the forwarding node during the last ACTIVE_ROUTE_TIMEOUT)**, as well as neighbors that have transmitted Hello messages during the last (ALLOWED_HELLO_LOSS * HELLO_INTERVAL).   
A node can maintain accurate information about its continued connectivity to these active next hops, using one or more of the available link or network layer mechanisms, as described below.
```
   -  Any suitable link layer notification, such as those provided by IEEE 802.11, can be used to determine connectivity, 
      each time a packet is transmitted to an active next hop.  
      For example, absence of a link layer ACK or failure to get a CTS after sending RTS,
      even after the maximum number of retransmission attempts, indicates loss of the link to this active next hop.

   -  If layer-2 notification is not available, passive acknowledgment SHOULD be used when the next hop is expected to 
      forward the packet, by listening to the channel for a transmission attempt made by the next hop.  
      If transmission is not detected within NEXT_HOP_WAIT milliseconds or the next hop is the destination (and
      thus is not supposed to forward the packet) one of the following methods SHOULD be used to determine connectivity:

      *  Receiving any packet (including a Hello message) from the next hop.

      *  A RREQ unicast to the next hop, asking for a route to the next hop.

      *  An ICMP Echo Request message unicast to the next hop.
```

If a link to the next hop cannot be detected by any of these methods, the forwarding node SHOULD assume that the link is lost, and take corrective action by following the methods specified in Section 6.11.

## 6.11. Route Error (RERR) Messages, Route Expiry and Route Deletion
Generally, route error and link breakage processing requires the following steps:
```
   -  Invalidating existing routes

   -  Listing affected destinations

   -  Determining which, if any, neighbors may be affected

   -  Delivering an appropriate RERR to such neighbors
```

A Route Error (RERR) message MAY be either broadcast (if there are many precursors), unicast (if there is only 1 precursor), or iteratively unicast to all precursors (if broadcast is inappropriate).  
Even when the RERR message is iteratively unicast to several precursors, it is considered to be a single control message for the purposes of the description in the text that follows.  With that understanding, a node **SHOULD NOT generate more than RERR_RATELIMIT RERR messages per second**.

A node initiates processing for a RERR message in three situations:
```
   (i)       if it detects a link break for the next hop of an active route in its routing table while transmitting data (and             
             route repair, if attempted, was unsuccessful), or

   (ii)      if it gets a data packet destined to a node for which it does not have an active route and is not repairing (if             
             using local repair), or

   (iii)     if it receives a RERR from a neighbor for one or more active routes.             
```

For case (i), the node first makes a list of unreachable destinations consisting of the unreachable neighbor and any additional destinations (or subnets, see section 7) in the local routing table that use the unreachable neighbor as the next hop.  
In this case, if a subnet route is found to be newly unreachable, an **IP destination address for the subnet** is constructed **by appending zeroes to the subnet prefix as shown in the route table entry**.  
This is unambiguous, since the precursor is known to have route table information with a compatible prefix length for that subnet.

For case (ii), **there is only one unreachable destination**, which is the destination of the data packet that cannot be delivered.  
For case (iii), **the list should consist of those destinations in the RERR** for which there exists a corresponding entry in the local routing table that has the transmitter of the received RERR as the next hop.

Some of the unreachable destinations in the list could be used by neighboring nodes, and it may therefore be necessary to send a (new) RERR.  
The RERR should contain those destinations that are **part of the created list of unreachable destinations** and **have a non-empty precursor list** .

The neighboring node(s) that should receive the RERR are all those that belong to a precursor list of at least one of the unreachable destination(s) in the newly created RERR.  
In case there is **only one unique neighbor** that needs to receive the RERR, **the RERR SHOULD be unicast toward that neighbor**.  Otherwise the RERR is typically sent to the **local broadcast address (Destination IP == 255.255.255.255, TTL == 1) with the unreachable destinations**, and their corresponding destination sequence numbers, included in the packet.  
The DestCount field of the RERR packet indicates the number of unreachable destinations included in the packet.

Just before transmitting the RERR, certain updates are made on the routing table that **may affect the destination sequence numbers for the unreachable destinations**.  
For each one of these destinations, the corresponding routing table entry is updated as follows:

## 6.12. Local Repair
## 6.13. Actions After Reboot
## 6.14. Interfaces

# 7. AODV and Aggregated Networks 

# 8. Using AODV with Other Networks

# 9. Extensions

# Reference
* [Ad hoc On-Demand Distance Vector (AODV) Routing RFC3561](https://tools.ietf.org/html/rfc3561)
* [600.647 - Advanced Topics in Wireless Networks, Spring 08](https://www.cs.jhu.edu/~cs647/)
* [Mobile ad-hoc networks](http://www.yl.is.s.u-tokyo.ac.jp/~kaneda/misc/resumes/mobile_ad_hoc_networks.ppt)
* [アドホックネットワークの概要と技術動向 千葉大学大学院 阪田 史郎 2005年2月26日](https://slidesplayer.net/slide/11226125/)
* [創発システムに向けて 慶應義塾大学環境情報学部 徳田英幸](https://slidesplayer.net/slide/11499738/)
* [第5回 DSR（Dynamic Source Routing）プロトコル 2003年3月5日](https://internet.watch.impress.co.jp/www/column/wp2p/wp2p05.htm)
* [第6回　OLSR（Optimized Link State Routing）プロトコル 2003年4月15日](https://internet.watch.impress.co.jp/www/column/wp2p/wp2p06.htm)
* [第7回 AODV(Ad hoc On-Demand Distance Vector)プロトコル 2003/5/22](https://internet.watch.impress.co.jp/www/column/wp2p/wp2p07.htm)

* [DSDV VS AODV Published on Sep 19, 2014](https://www.slideshare.net/SenthilKanth/dsdv-dsr-aodvtuto)
* [DSDV VS AODV page28 2/27/06](https://www.slideshare.net/SenthilKanth/dsdv-dsr-aodvtuto)
```
28. AODV --- Optimizations 
• Expanding ring search 
– Prevents flooding of network during route discovery 
– Control Time to Live of RREQ 

• Local repair 
– Repair breaks in active routes locally instead of notifying source 
– Use small TTL because destination probably has not moved far 
– If first repair attempt is unsuccessful, send RERR to source 
```
* [An Engineering Approach to Computer Networking— Routing page98](https://slideplayer.com/slide/12337178/)
```
 Expanding ring search 
 A way to use multicast groups for resource discovery 
 Routers decrement TTL when forwarding 
 Sender sets TTL and multicasts 
    reaches all receivers <= TTL hops away 
 Discovers local resources first 
 Since heavily loaded servers can keep quiet, automatically distributes load 
```

* [Slides for 『Mobile and Wireless Networking』](http://erdos.csie.ncnu.edu.tw/~ccyang/WirelessNetwork/WirelessNetworkSlide.html)

* [Shashank95/AODV-vs-DSDV-vs-DSR-on-NS2.35 - GitHub 8 Apr 2017](https://github.com/Shashank95/AODV-vs-DSDV-vs-DSR-on-NS2.35)
* [joshjdevl/docker-ns3  29 Apr 2014](https://github.com/joshjdevl/docker-ns3)
* [[ns-3] Cloning MANET Routing Protocols in ns-3 November 7, 2015](http://mohittahiliani.blogspot.com/2015/11/ns-3-cloning-manet-routing-protocols-in.html)
```
 This post provides a "python script" to clone AODV, DSDV, OLSR or DSR in ns-3. By cloning, we mean that an identical copy of an existing protocol is created in ns-3, but with a different name. 

Once the clone is created, you can modify it for your research work without affecting the original code of existing protocols in ns-3.

Warning: DSR cloning will work only for ns-3.25 and higher versions of ns-3!

python script
```

```
 Steps to create a clone:

1. Download the python script: clone-manet-routing.py
2. Place it in ns-allinone-3.xx/ns-3.xx/src directory
3. Go to ns-allinone-3.xx/ns-3.xx/src via terminal and give the following command:
chmod 777 clone-manet-routing.py

4. Give the following command to create a clone of AODV:
./clone-manet-routing.py aodv myaodv

5. Go to ns-allinone-3.xx/ns-3.xx/ via terminal and give the following commands:
./waf configure --enable-examples
./waf

You are done with it!
Note: Replace aodv by dsdv, olsr or dsr in Step 4 to clone DSDV, OLSR or DSR respectively.
```

```
Verifying the working of a clone:

1. Copy myaodv.cc from ns-allinone-3.xx/ns-3.xx/src/myaodv/examples
2. Paste it in ns-allinone-3.xx/ns-3.xx/scratch
3. Give the following command from ns-3.xx directory to run it:

./waf --run scratch/myaodv

If the command succeeds, you have successfully cloned AODV to MYAODV.
```

* [NS-3_MANET_Projects 24 Dec 2016](https://github.com/setu4993/NS-3_MANET_Projects)
```
All of the programs written (and edited from examples) for implementation of various Mobile Ad-Hoc Networks in Network Simulator-3 for class projects. 
C++
```

* [ns-3.26で始めるネットワークシミュレーション Feb 06, 2017](https://qiita.com/haltaro/items/b474d924f63692c155c8)
* [ns-3でTCPの輻輳制御を観察する Feb 20, 2017](https://qiita.com/haltaro/items/d479538345357f08c595)
* [ns-3構築を爆速で終わらせるためのシェルスクリプト Jul 29, 2018](https://qiita.com/wawawa/items/02984c882816966c5583)

* [how can i extract delay and throughput from manet-routing-compare.cc in ns3? Apr 29 '17](https://stackoverflow.com/questions/43700595/how-can-i-extract-delay-and-throughput-from-manet-routing-compare-cc-in-ns3)

* []()
![alt tag]()

# h1 size

## h2 size

### h3 size

#### h4 size

##### h5 size

*strong*strong  
**strong**strong  

> quote  
> quote

- [ ] checklist1
- [x] checklist2

* 1
* 2
* 3

- 1
- 2
- 3