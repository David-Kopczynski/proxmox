#!/usr/bin/env nix-shell
#! nix-shell -i bash -p ansible python3
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

ansible-playbook playbook.yml
