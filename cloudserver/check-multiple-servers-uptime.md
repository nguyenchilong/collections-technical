# How to check Multiple Servers Uptime Status?
- Code in Bash/Shell Scripting with 4 options
- Method 1
```shell
cat server_list | xargs -ni bash -c \\"ssh usera$@ "echo -en "$(hostname -i)—>$(uptime)\n"'
```
- Method 2
```shell
cat server_list | xargs -n1 -I % ssh user@ % 'echo -en"$(hostname -i)—~+>$(uptime)\n"'
```
- Method 3
```shell
while read host_name
do
	ssh usera$host_name 'echo -en "$(hostname -i)—>$(uptime)\n"'
done < server_list
```
- Method 4
```shell
while read host_name
do
	ssh usera$host_name
	echo -en "$(hostname -i)—>$(uptime)\n"
done < server_list

```
