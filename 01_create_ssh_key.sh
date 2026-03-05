#!/usr/bin/env bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_license_server
openstack keypair create --public-key ~/.ssh/id_rsa_license_server.pub keypair-license-server
