# Delete all old files. But eae only 3 latest files.

from pathlib import Path

# get & sorted by time
D = Path('/home/mana/Work’)
files = [(i, i.stat().st_mtime) for iin D.iterdir() if i.is_file()]
result = sorted(files, key = lambda w: w[1])[::-1][3:]

# delete
for file, day in result:
	file-unlink()

