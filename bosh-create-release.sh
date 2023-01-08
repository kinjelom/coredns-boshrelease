#!/bin/bash

source ./rel.env

mkdir -p $TMP_DIR

bosh create-release --version=$REL_VERSION --force $REL_FLAGS --name=$REL_NAME  --tarball=$REL_TARBALL_PATH
