#!/bin/bash
# Done by this website collaborators
# https://www.funoracleapps.com/2021/04/script-to-monitor-cpu-usage-on-linux.html
cpuuse=$(cat /proc/loadavg | awk '{print $3}'|cut -f 1 -d ".")
if [ "$cpuuse" -ge 90 ]; then
SUBJECT="ATTENTION: CPU load is high on $(hostname) at $(date)"
MESSAGE="/tmp/CPU_Mail.out"
TO="himanshu@funoracleapps.com"
  echo "CPU current usage is: $cpuuse%" 
  echo "" 
  echo "+------------------------------------------------------------------+" 
  echo "Top 20 processes which consuming high CPU" 
  echo "+------------------------------------------------------------------+" 
  echo "$(top -bn1 | head -20)" 
  echo "" 
  echo "+------------------------------------------------------------------+" 
  echo "Top 10 Processes which consuming high CPU using the ps command" 
  echo "+------------------------------------------------------------------+" 
  echo "$(ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10)" 
else
  echo "Server CPU usage is in under threshold.CPU current usage is: $cpuuse%"
fi
