# How To Find Real Memory Usage In Linux?

## How To Find Real Memory Useage?
- Memory plays an important role in the system performance and is one of the most critical component to be analyzed during system performance issue, we have lots of tools via which the system performance can be measured but sometimes they fail miserably , especially,when you are not checking a home grown lab but a critically running production box with 60G of RAM,multicore CPUs and heavy application spawning millions of connections and thus creating performance bottleneck, in such scenarios, running a top command will definitely not reflect the actual memory usage and so in such scenarios, we usually don’t rely much on ps or top commands as they report the memory usage of process on the concept that it's the only process running in the OS, but actually linux also has some concepts of shared libs , so when we do a ps or top on a process to get the usage, it ignores other memory related stuff like shared/private sections that shows the actual memory usage, this one liner below will help us find the exact stuff for running processes. 
- You shouldn't be happy always with these top one liners: `ps -e -o user,pid,%cpu,%mem,rss,cmd --sort=-rss | head`
- NB: The moral of this story is that process memory usage on Linux is a complex matter; you can't just run ps and know what is going on. This is especially true when you deal with programs that create a lot of identical children processes, like Java. ps might report that each Java process uses 100 megabytes of memory, when the reality might be that the marginal cost of each Java process is 10 megabyte of memory.
- One line below will give you a detailed snapshot what's going under the kernel bed sheets:
```shell
for i in `ps -eaf | grep java | grep -v grep | awk '{print $2}'`; 
do
	echo -n "PID $i actual memory usage is :" >> totaluse.txt; 
	pmap -d $i | grep -i "writeable/private: " >> totaluse.txt; 
done
```
- So we can view the process map of any process and its actual memory consumption and not the vague average reported by top process .

