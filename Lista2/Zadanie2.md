# manual 
```zhs
man ps
```

```man
PS(1)                                                                                                                        User Commands                                                                                                                       PS(1)

NAME
       ps - report a snapshot of the current processes.

SYNOPSIS
       ps [options]
...
```

# Checking process information 

## Command  
```zhs
ps -eo pid,ppid,stat,pri,nice,%mem,%cpu,tty,cmd
```
-e: It will show all processes.
-o: Specifies the columns to display, such as: 
   - pid (Process ID): The unique identifier of the process.
   - ppid (Parent Process ID): The ID of the parent process.
   - stat (Status): The current state of the process (e.g., running, sleeping).
   - pri (Priority): The scheduling priority of the process.
   - nice (Niceness): The nice value, affecting process priority.
   - %mem (Memory Usage): The percentage of physical memory used by the process.
   - %cpu (CPU Usage): The percentage of CPU time used by the process.
   - tty (Terminal Type): The terminal associated with the process.
   - cmd (Command): The command that started the process.

### Output:
```
ID    PPID STAT PRI  NI %MEM %CPU TT       CMD
      1       0 Ss    19   0  0.0  0.0 ?        /sbin/init
      2       0 S     19   0  0.0  0.0 ?        [kthreadd]
      3       2 S     19   0  0.0  0.0 ?        [pool_workqueue_release]
      4       2 I<    39 -20  0.0  0.0 ?        [kworker/R-rcu_gp]
      5       2 I<    39 -20  0.0  0.0 ?        [kworker/R-sync_wq]
      6       2 I<    39 -20  0.0  0.0 ?        [kworker/R-slub_flushwq]
      7       2 I<    39 -20  0.0  0.0 ?        [kworker/R-netns]
      8       2 I     19   0  0.0  0.0 ?        [kworker/0:0-mm_percpu_wq]
...
```

## Command 
```zhs 
ps axjf
```
operands:
  - a (All Users): Selects all processes with a terminal (TTY) attached, including those belonging to other users. This operand helps display processes beyond just those initiated by the current user.
  - x (Without a TTY): Includes processes that do not have a controlling terminal. This is useful for viewing background or daemon processes that run without user interaction.
  - j (Jobs Format): Displays processes in the jobs format, which includes additional columns such as session ID and PGID (process group ID). This provides more context about the job control and process hierarchy.
  - f (Forest View): Shows processes in a hierarchical tree structure, making it easier to see the parent-child relationships between processes. This visual representation helps identify which processes are related and how they are organized.

### Output 
```
PPID     PID    PGID     SID TTY        TPGID STAT   UID   TIME COMMAND
      0       2       0       0 ?             -1 S        0   0:00 [kthreadd]
      2       3       0       0 ?             -1 S        0   0:00  \_ [pool_workqueue_release]
      2       4       0       0 ?             -1 I<       0   0:00  \_ [kworker/R-rcu_gp]
      2       5       0       0 ?             -1 I<       0   0:00  \_ [kworker/R-sync_wq]
      2       6       0       0 ?             -1 I<       0   0:00  \_ [kworker/R-slub_flushwq]
      2       7       0       0 ?             -1 I<       0   0:00  \_ [kworker/R-netns]
      2       8       0       0 ?             -1 I        0   0:00  \_ [kworker/0:0-events]
      2       9       0       0 ?             -1 I        0   0:00  \_ [kworker/0:1-events]
      2      10       0       0 ?             -1 I<       0   0:00  \_ [kworker/0:0H-events_highpri]
      2      13       0       0 ?             -1 I<       0   0:00  \_ [kworker/R-mm_percpu_wq]
...
```
