# Linux scp Command Examples
- scp /path/file user@host:/path/dir => copy a local file to a remote dir
- scp user@host:/path/file /local/dir => copy a remote file to a local dir
- scp -r /path/dir user@host:/path/dir => copy a local dir to a remote dir
- scp -r user@host:/path/dir /path/dir => copy a remote dir toa local dir
- scp file1 file2 user@host:/path/dir => copy multiple files to a remote dir
- scp -P 2222 =>use a custom ssh port for remote host (e.g. 2222)
- scp -C => enable automatic compression during data transfer
- scp -i /path/pri-_key => use a specific ssh pri-ate key File
- scp -l 500 => rate-limit data transfer to 500 Kbit/s
- scp -p => preserve File mode bits & modification/access time of source files
- scp -F /path/ssh_config => use a custom ssh config File -
- scp -6 => force scp to use IP-6 (Gg )
- scp -B => disable all interactive prompts for batch mode eo. ©
- scp -v => enable verbose mode for troubleshooting
- scp -q => disable progress bar and warning messages Dan Nanni
- scp -c aes256-cbc => use a specific cipher (e.g. aes256-cbc) \study-notes.org
- ssh -Q cipher => show all ciphers supported by ssh/scp client
- scp -J user@jump-server => copy data -ia an intermediate jump ser-er
- scp -J user@jump-server,user@jump-server2  => use multiple jump ser-ers
- scp -S /bin/ssh_cmd => use a custom ssh command For encrypted sessions
- find . -type f -name "*.log" -exec scp {} user@host:/path/dir => combine scp with Find For selective file transfer (e.g. *.log Files only)


