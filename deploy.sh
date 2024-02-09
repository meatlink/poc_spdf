#!/bin/sh
set -eu
cd "$( dirname "$0" )"


get_free_hugepages() {
    local re
    re='^HugePages_Free:[[:space:]]\+\([[:digit:]]\+\)$'
    grep "$re" /proc/meminfo | sed "s/${re}/\1/"
}

cd kube
nr_hp="$( get_free_hugepages )"
mbs="$(( nr_hp * 2 ))"
echo "Allocating ${mbs} mbs (${nr_hp} hugepages)".
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install spdk . --set-string "spdk_hugepages_mb=${mbs}"
