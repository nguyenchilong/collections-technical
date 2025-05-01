# How to Take Incremental Backup In Linux?
- Here i taken backup of my home folder.
```shell
ls -1 ~ | xargs -0 | while read name
do
	rsync -ruz --delete --exclude-from='/home/mana/Work/backup- \\exclude.txt' ~/"$name" /media/mana/DATA/Data-Backup/
done
```
- Explanation of Command:
  - ls -1 => list one file per line.
  - xargs -0 => When handle files or directories with a space in the name, -® will be removed if there is any white-space character.
  - while read name => while loop iterate input one by one.
  - rsync -r => Recursive Directories
  - rsync -u => option do not overwrite a file at the destination, if it is modified.
  - rsync -z => compress file data.
  - rsync --delete => If a file or directory not exist at the source, but already exists at the destination, you might want to delete that existing file/directory at the target while syncing .
  --exclude-from => Exclude files and folders if you don’t want to be transferred.

