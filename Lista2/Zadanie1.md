# Info

```
/dev
```
- (devices) – Contains files that represent hardware and virtual devices in the system. 
- These files act as interfaces to device drivers, allowing system and user-level applications to access and communicate with devices. 


```
/proc
```
- (processes) – A virtual file system that provides information about running processes, kernel data, and system configuration.
- The main purpose of /proc is to supply dynamic data about the current state of the operating system and allow certain kernel parameters to be adjusted on the fly.

```
/sys
```
- (system) – A virtual file system created to organize and present detailed information about devices and their drivers. 
- It provides a more structured view than /proc and facilitates interaction with and control over system devices.




# Code 

## Command
```zsh
cat /proc/meminfo
```
## Output
```
MemTotal:       15795032 kB
MemFree:        12821852 kB
MemAvailable:   13927672 kB
Buffers:           69564 kB
Cached:          1275496 kB
SwapCached:            0 kB
...
HugePages_Surp:        0
Hugepagesize:       2048 kB
Hugetlb:               0 kB
DirectMap4k:      410880 kB
DirectMap2M:     7389184 kB
DirectMap1G:     9437184 kB
```

## Command
```zsh
cat /proc/cpuinfo
```
## Output
```
processor	: 0   # 0 to 7 on my laptop 
vendor_id	: AuthenticAMD
...
bogomips	: 4593.52
TLB size	: 2560 4K pages
clflush size	: 64
cache_alignment	: 64
address sizes	: 43 bits physical, 48 bits virtual
power management: ts ttp tm hwpstate eff_freq_ro [13] [14]
```

## Command
```zsh
cat /proc/partitions
```
## Output
```
 major   minor #blocks   name

 259        0  500107608 nvme0n1
 259        1    1048576 nvme0n1p1
 259        2   49283072 nvme0n1p2
 259        3  449773912 nvme0n1p3
 254        0    4194304 zram0
```
