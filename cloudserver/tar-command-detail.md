# Linux tar Command Examples

- Create tar archives
  - tar -cvf my.tar file1 file2 dir1 => Create a tar archive
  - tar -czvf my.tar.gz file1 file2 dir1 => Create a gzipped tar archive
  - tar -cjvf my.tar.bz2 file1 file2 dir1 => Create a bzipped tar archive
  - tar cvf - file1 file2 dir1 | gzip -9 -> my.tar.gz => Specify compression level for gzip
  - tar -cvf my.tar --exclude=/path/to/xxx dir1 => Exclude specific files/directories
  - tar -cvf -.| gzip | split -b 1G - my.tar.gz.part => Split archive to 1GB gzipped Files

- Extract tar archives
  - tar -xvf archive.tar => Extract a tar archive. Works for compressed archives
  - tar -xvf archive.tar -C /path/to/dir => Extract a tar archive to a target directory
  - sudo tar --same-owner -p -xvf archive.tar => Preserve owner and permission info
  - cat my.tar.gz.part” | gzip -d | tar -xvf- => Extract multi-part gzipped archives

- Update tar archives
  - tar -rvf archive.tar newfile1 newfile2 => Append files to an archive
  - tar --delete -f archive.tar file1 file2 => Delete Files From an archive

- View tar contents
  - tar -tvf archive.tar => List Files in a tar archive. Works for compressed archives

- Password-protect tar archives
  - tar -czvf - file1 file2 dir1 | gpg -c -o my.tar.gz.gpg => Create a GPG password protected compressed tar archive. You will be prompted to enter a password 
  - gpg -d my.tar.gz.gpg | tar -xzvf => Decrypt, uncompress and extract archive

