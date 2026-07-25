#!/bin/bash

set -ex -o pipefail

ROOT_DIR="$(dirname "$(realpath "$0")")"
cd "$ROOT_DIR"

cd infra
tofu init
tofu apply


cd "$ROOT_DIR"

ln -sfn "../inventory" matrix-docker-ansible-deploy/inventory

docker run \
  -it \
  --rm \
  -w /work/matrix-docker-ansible-deploy \
  --mount type=bind,src=`pwd`,dst=/work \
  --mount type=bind,src=$HOME/.ssh/id_rsa,dst=/root/.ssh/id_rsa,ro \
  ghcr.io/devture/ansible:11.6.0-r0-0 ansible-playbook -i inventory/hosts setup.yml --tags=install-all,ensure-matrix-users-created,start
