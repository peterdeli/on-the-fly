#!/bin/bash
#keep

outfile=~/bin/daily_status.out
trap  'echo "Exiting .. status file $outfile" ; exit '  1 2 3 15

while [ 1 ]; do

    echo "Enter the event:"

    now=$( date '+%Y:%m:%d-%H:%M:%S' )

    eventfile=daily_status_event.${now}.out
    cat  > $eventfile 
    date >> $outfile
    cat $eventfile >> $outfile
    echo "----" >> $outfile
    rm $eventfile

done

