# Filesystem Alert

- Code in Bash and Python to alert when filesystem is running low.
- Method 1 in Bash/Shell
```shell
df -H | grep -Po "^/dev/(?!.*snap).*" | while read i
do
percent=$(echo $i | awk 'gsub("%", ""){print $5}')
fs=$(echo $i | awk '{print $1}')

if (( percent > 80 )); then
	echo "Running out of space $fs $percent% on $(hostname)."
fi

done
```
- Method 2 in Bash/Shell
```shell
df -H --output=source,pcent | grep -Po "^/dev/(?!.*(snap|loop)).*"\| sed 's/%//g'| while read -r fs pc

do
if (($pc > 80))
then
	echo "Running out of space $fs $pc% on $HOSTNAME."
fi

done
```
- Python
```python
from os import statvfs as svfs
from re import compile, search
from pathlib import Path

comp = compile(r'^/dev/(?!.*snap)')
mline = Path('/proc/mounts').read_text().splitlines()
fs = [i.split()[1] for i in mline if comp.search(i)]

for x in fis:
	def usep(x, y):
		return f"{(x - y)/x:.0%}"
	percent = usep(svfs(x).f_blocks,svfs(x).f_bfree)
	if int(percent.replace('%','')) > 80:
		print(f'Running out of space {x} abvoe {percent:80}.')

# Output: Running out of space / abvoe 80% .
```

