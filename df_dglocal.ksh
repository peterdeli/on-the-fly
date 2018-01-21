#!/bin/ksh
#keep

if [ $# -gt 0 ]; then
range=$1
else
range=1-10
fi

df -h /dg/local | grep -i use

for i in 001 002 003 004 005 006 007 008 009; do 


start=${range/-*/}
end=${range/*-/}
echo pu00gcsweb$i

if [ $end -eq 10 ]; then
  cmd="ssh pu00gcsweb$i 'df -h /dg/local' | grep '/dg/local' | egrep '[${start}-9][0-9]%|100%|[0-9]%'"
  eval $cmd
else
  ssh pu00gcsweb$i 'df -h /dg/local' | grep '/dg/local' | eval egrep \'[$range][0-9]%|[0-9]%\'
fi

done

if [ -d /dg/local/backups ]; then
	echo /dg/local/backups
	df -h /dg/local/backups | grep '/dg/local/backups'
fi
