#!/usr/bin/env bash
openstack stack create --template stack.yaml license-server --parameter ssh_allowed_cidrs="$1"
