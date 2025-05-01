#!/usr/bin/env bash

#sed '/^$/d' demo.txt > trim.txt

awk 'NF > 0' demo.txt > trim.txt

#perl -n -e "print if /\S/" demo.txt > trim.txt