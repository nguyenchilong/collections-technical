#!/bin/bash

# BASH BRACKETS: 0), 0, $0, U, I[1]

# $(commands) Executes a command and captures its output. Command substitution allows the result of a command (in this case, grep) to be stored in a variable.
# code
log_file="/var/Log/syslog"
keyword="error"
output=$(grep "$keyword" "$log_file")
echo "Output: $output"



# (a b c) Creates an array of values. Parentheses are used to define an array, allowing multiple elements to be stored in one variable.
# code
files=(log.txt log2.txt log3.txt)
for file in "${files[@]}"; do
  echo "Processing $file"
done


# {range} Expands to multiple strings. Brace expansion is a powerful way to generate sequences or multiple strings, useful for batch operations. The range can be numbers or characters.
# code
for file in backup_{1..4}.tar.gz; do
  mv $file /var/oldbackups
done


# ${variable} Accesses a variable's value. This is another way to reference a variable, commonly used when you need to follow it with additional characters or text.
# code
username="John"
greeting="Hello, ${username}!"
echo "$greeting"


# [ expression ] Tests a condition using double brackets. Double brackets are more flexible in bash, supporting advanced pattern matching and logical operators.
# code
file="/etc/passwd"
if [ -f "$file" ]; then
  echo "File exists"
fi


# { list; } Executes a group of commands in the same shell process. Curly braces group commands together to be executed sequentially in the current environment.
# code
{ sudo apt install exa
echo exa
echo "Listed files using exa"; }


# (list ) Executes a list of commands in a separate subshell. The commands inside the parentheses run in a child process, isolated from the main shell.
# code
( cd /home/user
ls
whoami )


# ${expression) Modifies variable content. Parameter expansion allows you to alter a variable's value, such as changing a file extension from txt to .bak.
# code
filename="report.txt"
backup_file="${filename%. txt}.bak"
echo "Backup file: $backup_file"


# $((expression)) Performs arithmetic calculations. The double parentheses are used for math operations, such as addition, multiplication, etc.
# code
num1=5
num2=3
result=$((num1 * num2 + 1))
echo "Result: $result"

# [[ expression ]] Tests a condition using double brackets. Double brackets are more flexible in Bash, supporting advanced pattern matching and logical operators.
# code
user=$USER
if [[ $user == "root" ]]; then
  echo "You are the root user"
fi
