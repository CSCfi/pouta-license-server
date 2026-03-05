#!/usr/bin/env bash
ansible-playbook -i hosts.yaml -l pouta_license_server playbook.yaml
