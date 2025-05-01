# How To Change Linux Server Password Automatically by Python?
- Run this script in cmd line:
```shell
sudo pass-changed.py username password
```
- pass-changed.py code
```Python
import sys
import subprocess as sp

user, password = sys.argv[1:]
password = password.encode() + b'\n'
subk = dict(stdout=sp.PIPE, stdin=sp.PIPE, stderr=sp.PIPE)
pwd_change = sp.Popen(['passwd', user], **subk)
for i in range(2):
	pwd_change.stdin.write(password)
```
- Check whether password changed or not via bash/shell, run this command `sudo chage -1 joe | head -1`


