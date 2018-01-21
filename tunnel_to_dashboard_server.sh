#!/bin/bash
#keep

ssh -i ~/.ssh_aws/id_rsa -L 9999:localhost:5678 httpd@jump.east1.gcsdev.com ssh -i httpd_ec2 -L 9999:localhost:9999 centos@ip-10-0-3-74.ec2.internal

