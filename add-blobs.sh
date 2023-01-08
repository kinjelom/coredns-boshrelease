#!/bin/bash

function down_add_blob {
  BLOBS_GROUP=$1
  FILE=$2
  URL=$3
  if [ ! -f blobs/${BLOBS_GROUP}/${FILE} ];then
    mkdir -p .downloads
    echo "Downloads resource from the Internet ($URL -> .downloads/$FILE)"
    curl -L $URL --output .downloads/$FILE
    echo "Adds blob (.downloads/$FILE -> $BLOBS_GROUP/$FILE), starts tracking blob in config/blobs.yml for inclusion in packages"
    bosh add-blob .downloads/$FILE $BLOBS_GROUP/$FILE
  fi
}

down_add_blob "coredns" "coredns-1.10.0.src.tar.gz" "https://github.com/coredns/coredns/archive/refs/tags/v1.10.0.tar.gz"

bosh sync-blobs
bosh upload-blobs
