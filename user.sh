#!/bin/bash

set -ex -o pipefail

if [ -z "$1" ] ; then
  echo "Usage: user.sh <username>"
  exit 1
fi

ROOT_DIR="$(dirname "$(realpath "$0")")"
cd "$ROOT_DIR"

RANDOM_PASSWORD=$(gpg --gen-random --armor 1 30 | base64)

ln -sfn "../inventory" matrix-docker-ansible-deploy/inventory

docker run \
  -it \
  --rm \
  -w /work/matrix-docker-ansible-deploy \
  --mount type=bind,src=`pwd`,dst=/work \
  --mount type=bind,src=$HOME/.ssh/id_rsa,dst=/root/.ssh/id_rsa,ro \
  ghcr.io/devture/ansible:11.6.0-r0-0 ansible-playbook -i inventory/hosts setup.yml \
    --extra-vars="username=$1 password=${RANDOM_PASSWORD} admin=no" \
    --tags=register-user

echo "Created user with password: ${RANDOM_PASSWORD}"
