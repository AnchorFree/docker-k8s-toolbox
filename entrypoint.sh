#!/bin/sh

mkdir -p /root/.kube
cp /cluster/kube_config /root/.kube/config

exec "$@"
