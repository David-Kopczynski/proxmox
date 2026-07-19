#!/usr/bin/env nix-shell
#! nix-shell -i bash -p ansible

ANSIBLE_CONFIG="$(dirname $0)/ansible.cfg" ansible-playbook "$(dirname $0)/playbook.yml"
