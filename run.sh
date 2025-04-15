#!/bin/bash

set -ex -o pipefail

cd "$(dirname "$0")"

cd infra
tofu init
tofu plan
