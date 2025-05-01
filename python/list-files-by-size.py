# How to List Above 10MB Files By Python?


# Method: 1
from os.path import getsize,basename
import glob

folder = '/home/mana/Must Study/Python/*'
for i in glob.glob(folder):
	if getsize(i) > 10485760:
		print('{} - {:.0f}MB' . format(basename(i),getsize(i)/1024/1024))



# Method: 2
from os.path import getsize,basename
import glob

folder = '/home/mana/Must Study/Python/*'
file = filter(lambda i: getsize(i)/1024/1024 > 10, glob.glob( folder))
for j in file:
	print('{} - {:.of}MB' . format(basename(j),getsize(j)/1024/1024))

