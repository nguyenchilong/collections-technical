#!/usr/bin/env bash

kops create cluster \
--name=kops.lnchub.com \
--state=s3://kops.lnchub.com \
--authorization RBAC \
--zones=ap-southeast-1a \
--node-count=2 \
--node-size=t2.micro \
--master-size=t2.micro \
--master-count=1 \
--dns-zone=kops.lnchub.com \
--out=fts_terraform \
--target=terraform \
--dns=private \
--ssh-public-key=./keys/fts_user.pub
