# How To List Modified Files Between Specific Range Of Days ?
- Code in Bash/Shell Scripting
```shell
find /home/mana/Work/ -type f -newermt 20200408 \! \-newermt 20200410
```
- Code in Python
```python
from datetime import datetime
from pathlib import Path

start_day = datetime.strptime('08/4/2020 00', "%d/%m/%Y

end_day = datetime.strptime('10/4/2020 00',"%d/%m/%Y %H")
files = Path('/home/mana/Work/' )
ftime = [(datetime. fromtimestamp(i.stat()[-2]),i)
	for i in files.iterdir() if i.is_file()]

for x,y in ftime:
	if start_day < x < end_day:
		print(f'{x:%d-%m-%Y} => {y}')

# Output:
# @8-04-2020 = /home/mana/Work/map.txt
# @8-04-2020 = /home/mana/Work/log_report.csv
```

