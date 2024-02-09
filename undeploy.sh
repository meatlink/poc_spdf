#!/bin/sh
set -eu
cd "$( dirname "$0" )"


cd kube
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm delete spdk
