#!/usr/bin/env bash

kops delete cluster --name=kops.lnchub.com --state=s3://kops.lnchub.com --yes
