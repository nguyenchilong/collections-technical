#!/bin/bash

echo "$@"


echo $0


FILE_NAME=$1

# Check file co ton tai khong
if [ ! -f $FILE_NAME ];then
	echo "File ${FILE_NAME} khong ton tai."
	echo "Thoat."
	exit 1
fi


# Doc noi dung tung dong cua file van ban
count=0
while read line; do
	((count++))
	odd_line=$(expr ${count} % 2)
	if [ "${odd_line}" -eq 0 ];then
		# In hoa noi dung dong chan, chu hoa
		echo ${line} | tr '[:lower:]' '[:upper:]'
	fi
done < ${FILE_NAME}

exit 0
