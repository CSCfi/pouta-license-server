#!/usr/bin/env bash
openstack stack show license-server -f json | jq '.outputs[2].output_value'
