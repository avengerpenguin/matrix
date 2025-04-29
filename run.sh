#!/bin/bash

set -ex -o pipefail

ROOT_DIR="$(dirname "$(realpath "$0")")"
cd "$ROOT_DIR"

cd infra
tofu init
tofu apply


cd "$ROOT_DIR"

ln -sfn "$ROOT_DIR/inventory" matrix-docker-ansible-deploy/inventory

cd matrix-docker-ansible-deploy
just update
ansible-playbook -i inventory/hosts setup.yml --tags=install-all,ensure-matrix-users-created,start
#ansible-playbook -i inventory/hosts setup.yml --extra-vars='username=avengerpenguin password=aeYHhaGXm5BRk2MiaBD2C1rSde3WE9pzwsTfbaSDxdrEiNgGDKHsE5xWoDKZ58io admin=yes' --tags=register-user
