#!/bin/bash

VAR1="backup_full.2016-06-01.txt"
FLAG=0

if [ ! -z ${VAR1} ];then
	for i in `seq 1 ${#VAR1}`
	do
		CHAR=$(echo ${VAR1: -${i}:1})
		if [[ ${CHAR} == "." ]];then
			POS=`expr ${#VAR1} - $i`
			FLAG=1
			break
		fi
	done
	if [ ${FLAG} -eq 0 ];then
		echo "Input = ${VAR1}"
		echo "Output = ${VAR1}"
		echo "- No extension name of file."
	else
		# In string tu index 0 den gia tri gan dau '.' index
		echo "Input = ${VAR1}"
		echo "Output = ${VAR1:0:${POS}}"
	fi
else
	echo "- Variable input is null. Exit"
fi

exit 0
