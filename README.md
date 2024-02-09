# Create Vagrant VM

Create and connect to a Vagrant VM

(next steps are expected to happen inside the VM)

```
vagrant up

# Optionally (hopefully already fixed):
#   if `vagrant ssh` gives something like:
#     vagrant@127.0.0.1: Permission denied (publickey).
#   do this:
#     dos2unix .vagrant/machines/default/virtualbox/private_key

vagrant ssh
```

Details in Vagrantfile. Summary:

- installs Docker, k3s, helm
- configures 512 huge pages (2048k)

Notes:
- I used k3s with Docker to simplify registry interactions

# Build image

It takes quite a while.

```
cd /vagrant
./build.sh
```

## TODO: Investigate image size optimisation opportunities

It's possible to use multistage builds to avoid storing build-time dependencies and source code in the container.

Something like:

```
... existing docker image ...

FROM ubuntu:22.04
RUN apt update && apt install -y libnuma-dev libfuse3-dev libaio-dev openssl
COPY --from=0 /spdk/build/bin/nvmf_tgt /spdk/nvmf_tgt
```

works well and this way we are able to successfully run `nvmf_tgt`, though I decided to skip that for now, as I'm not sure if I'm not missing anything. And we also need `scripts` directory which also have dependencies.


# Deploy

```
./deploy.sh
```

I used a simple helm chart to inject desired memory size values into manifests.

Hugepages configuration comes from local /proc/meminfo.

Output should look something like this:

```
vagrant@ubuntu-jammy:/vagrant$ ./deploy.sh
Allocating 1024 mbs (512 hugepages).
NAME: spdk
LAST DEPLOYED: Fri Feb  9 15:17:17 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Note the line `Allocating 1024 mbs (512 hugepages).`


# Validate

```
./check_pod_logs.sh
```

Script shows container logs.

Output should look like:

```
vagrant@ubuntu-jammy:/vagrant$ ./check_pod_logs.sh
[2024-02-09 15:17:25.084443] Starting SPDK v24.05-pre git sha1 84532e3d2 / DPDK 23.11.0 initialization...
[2024-02-09 15:17:25.084633] [ DPDK EAL parameters: nvmf --no-shconf -c 0x1 -m 1024 --huge-unlink --no-telemetry --log-level=lib.eal:6 --log-level=lib.cryptodev:5 --log-level=user1:6 --iova-mode=pa --base-virtaddr=0x200000000000 --match-allocations --file-prefix=spdk_pid1 ]
[2024-02-09 15:17:25.660251] app.c: 796:spdk_app_start: *NOTICE*: Total cores available: 1
[2024-02-09 15:17:25.764155] reactor.c: 937:reactor_run: *NOTICE*: Reactor started on core 0
[2024-02-09 15:17:29.981198] tcp.c: 659:nvmf_tcp_create: *NOTICE*: *** TCP Transport Init ***

Allocated hugepages memory (mb):-m 1024
```

We should node this line:

```
[2024-02-09 15:17:25.084633] [ DPDK EAL parameters: nvmf --no-shconf -c 0x1 -m 1024 --huge-unlink --no-telemetry --log-level=lib.eal:6 --log-level=lib.cryptodev:5 --log-level=user1:6 --iova-mode=pa --base-virtaddr=0x200000000000 --match-allocations --file-prefix=spdk_pid1 ]
```

We can use `-m 1024` to evaluate the memory actually used.

There is an additional filter for convenience at the very end:

```
Allocated hugepages memory (mb):-m 1024
```
