#!/bin/bash

BASE_DIR=$(dirname "$(realpath "$0")") #"
deployment_name=coredns-rnd

bosh -d ${deployment_name} deploy "$BASE_DIR/manifests/coredns.yml" \
  -v deployment_name="${deployment_name}" \
  --vars-file="$BASE_DIR/vars/${deployment_name}-vars.yml" \
  --no-redact --fix

