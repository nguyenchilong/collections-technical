# How To Check Whether Server Up Or Down ?
- Code in Bash/Shell Scripting.
```shell
ssh -t manaQjoe "uptime"
```

- Code in Python.
```python
from subprocess import Popen, PIPE
args = dict(stdin=PIPE, stdout=PIPE, stderr=PIPE)

command = 'ssh -t manaQjoe "uptime"'

try:
 ssh = Popen(command.split(), **args)
 stat = ssh.stdout.read().decode().split()[1]
except:
	print('Host Down. ')

else:
	print(f'Host {stat.upper()}.')

# Output: Host UP
```

