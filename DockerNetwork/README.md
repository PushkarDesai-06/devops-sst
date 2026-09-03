# Docker Networking & Volume Assignment

**Name :** Pushkar Desai

**Roll Number :** 24BCS10085

---

## TASK 1: Docker Container Networking

Created 3 containers — `frontend` (nginx), `backend` (alpine), `database` (mysql:8) —
and 3 bridge networks, with the **backend attached to 2 networks**.

| Network | Subnet | Containers |
| ------- | ------------- | ----------------- |
| net1 | 172.18.0.0/16 | frontend |
| net2 | 172.19.0.0/16 | frontend, backend |
| net3 | 172.20.0.0/16 | backend, database |

1. The 3 networks created :

![](./TASK%201/1%20network%20ls.png)

---

2. The 3 containers running :

![](./TASK%201/2%20docker%20ps.png)

---

3. Inspecting the backend — it is attached to **net2 and net3** :

![](./TASK%201/3%20inspect%20backend.png)

---

4. Connectivity check — backend can reach the other containers :

![](./TASK%201/4%20backend%20ping.png)

---

5. Isolation check — the frontend **cannot** reach the database, because they
share no network. `backend` resolves, `database` does not :

![](./TASK%201/5%20frontend%20isolation.png)

**Conclusion :** the database is reachable only through the backend, which is the
only container on two networks.

---

## TASK 2: Host Network

```bash
docker pull httpd
docker run -d --name apache-host --network host httpd
```

Apache accessed directly on **port 80** — with the host network the container
binds the host's port 80 itself, so no `-p` port mapping is needed :

![](./TASK%202/Apache.png)

---

## TASK 3: Bind Mount

```bash
mkdir -p ~/docker-bindmount/site
echo "<h1>Hello students</h1>" > ~/docker-bindmount/site/index.html

docker run -d --name nginx-bind -p 8080:80 \
    -v ~/docker-bindmount/site:/usr/share/nginx/html nginx
```

1. Folder + `index.html` created and bind mounted into the nginx container
(`docker inspect` confirms `bind ... -> /usr/share/nginx/html`) :

![](./TASK%203/1%20setup%20and%20mount.png)

---

2. Website accessed at `localhost:8080` — content verified :

![](./TASK%203/2%20before.png)

---

3. `index.html` modified **on the host**, and the change shows up immediately :

![](./TASK%203/3%20after.png)

---

4. Proof the container was **never restarted** — `StartedAt` is identical before
and after the edit and `RestartCount` is 0 :

![](./TASK%203/4%20no%20restart%20proof.png)

**Conclusion :** a bind mount maps the host folder straight into the container,
so edits on the host are served instantly with no rebuild and no restart.

---

## TASK 4: Overlay Network

### What an overlay network is

A **bridge** network lives on a single host — its `SCOPE` is `local` and no other
machine can join it. An **overlay** network is a virtual layer-2 network that
spans **many Docker hosts**: containers on different physical machines get
addresses from one shared subnet and talk to each other by name as if they were
on the same switch. Its `SCOPE` is `swarm`, and it requires swarm mode.

### How it works across multiple hosts

Overlay networks use **VXLAN**, which wraps a whole Ethernet frame inside a
**UDP packet on port 4789** and sends it to the other host's real IP :

![](./TASK%204/1%20how%20overlay%20works.png)

1. Container A sends a normal frame to container B's overlay IP.
2. Host 1's `vxlan0` wraps it in VXLAN + UDP + IP addressed to host 2's **real** IP.
3. Host 2 receives it on UDP 4789, strips the outer headers, and delivers the
   original frame to container B.

The physical network never needs to know the container subnet exists. Swarm's
raft store on the manager nodes holds the network definition and IP allocations
and distributes them to every node.

Each overlay container gets **two interfaces** — `eth0` on the overlay for
container-to-container traffic, and `eth1` on `docker_gwbridge` for outbound NAT.

**Ports required between hosts :**

| Port | Protocol | Purpose |
| ---- | -------- | ------------------------ |
| 2377 | TCP | cluster management |
| 7946 | TCP + UDP | node-to-node gossip |
| 4789 | UDP | VXLAN data plane |

Overlay traffic is **unencrypted by default**; `--opt encrypted` enables IPsec.

### Use cases

- **Multi-host container communication** — an app on host A talking to a database on host C by name.
- **Microservices across a cluster** — services discover each other by DNS name, no hard-coded IPs.
- **Scaling and self-healing** — replicas move between nodes but the service VIP stays the same.
- **Network segmentation** — one overlay per tier, cluster-wide (the Task 1 model, but across hosts).
- **Zero-downtime rolling updates** — swarm swaps the VIP's backends as new replicas come up.

### Driver comparison

| Driver | Scope | Spans hosts | Used in |
| ------- | ----- | ----------- | ---------------------- |
| bridge | local | No | Task 1, Task 3 |
| host | local | No | Task 2 |
| overlay | swarm | **Yes** | Task 4 |
| macvlan | local | No | container gets a LAN IP |

### Practical demo

Overlay networks need swarm mode, so swarm was initialised first :

![](./TASK%204/2%20swarm%20init.png)

---

Creating an **attachable** overlay network — note `SCOPE = swarm`, unlike the
`local` bridge networks from Task 1 :

![](./TASK%204/3%20create%20overlay.png)

---

Two containers attached to the overlay, communicating by name over the
swarm-managed `10.0.1.0/24` subnet :

![](./TASK%204/4%20overlay%20connectivity.png)

---

The real use case — a swarm **service** with 3 replicas on the overlay. The
service name resolves to one stable **virtual IP**, which the kernel
load-balances across the replicas, while `tasks.web` resolves to the individual
replica IPs :

![](./TASK%204/5%20swarm%20service.png)

```bash
docker swarm init
docker network create -d overlay --attachable my-overlay
docker run -d --name ov-a --network my-overlay alpine sleep infinity
docker run -d --name ov-b --network my-overlay alpine sleep infinity
docker exec ov-a ping -c 3 ov-b
docker service create --name web --network my-overlay --replicas 3 -p 8090:80 nginx
```

This ran on a single-node swarm, which exercises the same control plane — swarm
store, VXLAN interfaces, embedded DNS, VIP, load balancing and routing mesh —
with only the physical hop between two machines absent.
