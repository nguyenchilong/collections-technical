#!/usr/bin/env bash

# Khai bao bien
# Delcare neccessary variables
MAX_LENGTH_NAME=0
MIN_LENGTH_NAME=0
WHO_NAME="unknown"
count=0

# Lay thong tin ten tung username
for name in $(cat /etc/passwd | cut -d':' -f1)
do
	# Lay thong tin do dai cua bien 'name'
	# Get the length of name
	LENGTH_NAME=${#name}

	# So sanh do dai lon nhat, ai dai hon gan bien max cho nguoi do
	# Compare two length number, assign max number to max length.
	if [ ${LENGTH_NAME} -gt ${MAX_LENGTH_NAME} ];then
		MAX_LENGTH_NAME="${LENGTH_NAME}"
		WHO_MAX_NAME="${name}"
	fi

	# So sanh do dai nho nhat, ai nho hon gan bien min cho nguoi do.
	if [ "${count}" -eq 0 ];then
		MIN_LENGTH_NAME="${LENGTH_NAME}"
		((count++))
	else
		if [ ${LENGTH_NAME} -lt ${MIN_LENGTH_NAME} ];then
			MIN_LENGTH_NAME="${LENGTH_NAME}"
			WHO_MIN_NAME="${name}"
		fi
	fi
done


# In thong tin ten dai nhat va ngan nhat
# Print infor indicate whose max length name and min length name
echo "- Max length name is: $WHO_MAX_NAME - $MAX_LENGTH_NAME"
echo ""
echo "- Min length name is: $WHO_MIN_NAME - $MIN_LENGTH_NAME"

exit 0