#!/usr/bin/env bash

NUMBER=$(echo "Toi nam nay 999 tuoi roi." | tr -dc '0-9')
echo $NUMBER

NUMBER=$(echo "Toi nam nay 999 tuoi roi." | sed 's/[^0-9]*//g')
echo $NUMBER

STRING="Toi nam nay 999 tuoi roi."
#echo "${STRING//[!0-9]/}"
echo "${STRING//[^0-9]/}"

NUMBER=$(echo "Toi nam nay 999 tuoi roi." | grep -o -E '[0-9]+')
echo $NUMBER