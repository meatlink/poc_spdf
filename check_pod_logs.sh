#!/bin/sh
set -eu
cd "$( dirname "$0" )"


pod="$( sudo kubectl get pods | grep -o '^spdk-[^[:space:]]\+' )"
sudo kubectl logs "$pod"

echo

echo -n "Allocated hugepages memory (mb)":
sudo kubectl logs "$pod" | grep "DPDK EAL parameters" | grep -o -- '-m [[:digit:]]\+'