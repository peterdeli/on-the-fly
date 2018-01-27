#!/bin/bash
# :s/^/\=line('.')/ 
#
# :%s/^/\=line('.')/
print_services(){
cat<<EOF_print_services

 Services:
 
Service 8
Service 9
Service 10
Service 11
Service 12
Service 13
Service 14
Service 15
Service 16
Service 17
Service 18
 
EOF_print_services

}

do_query(){

	if [ $# -ne 3 ]; then
		echo "Usage: $0 <SOME ID> <date as MM/DD/YYY> <service type>"
		exit
	fi

	date=$2
	for hour in {0..23}; do 
		#for minutes in 0 30; do
		for minutes in 0; do
			if [ $hour -lt 10 ]; then
				start_hour="0${hour}"
			else
				start_hour=$hour
			fi
			start_timestamp=$( eval date -d \'$date ${start_hour}:${minutes}0:00\' \'+%m/%d/%Y %H:%M:%S\' )
			if [ $minutes -eq 30 ]; then
				end_hour=$(( $hour + 1 ))
				end_minutes=00	
			else
				end_hour=$(( $hour + 1 ))
				end_minutes=00	
				#end_hour=$(( $hour ))
				#end_minutes=30	
			fi
			#if [ $hour -eq 23 -a $minutes -eq 30 ]; then
			#	end_timestamp=$( eval date -d \'$date + 1 day 00:00:00\' \'+%m/%d/%Y %H:%M:%S\' )
			if [ $hour -eq 23 ]; then
				end_timestamp=$( eval date -d \'$date + 1 day 00:00:00\' \'+%m/%d/%Y %H:%M:%S\' )
			else
				end_timestamp=$( eval date -d \'$date ${end_hour}:00:00\' \'+%m/%d/%Y %H:%M:%S\' )
			fi

cat<<EOF_header
SOME_ID_COL: $1
start: $start_timestamp 
end: $end_timestamp

EOF_header

################## query #1 ########################################
		
cat <<EOF_print1_sql
select '$start_timestamp'as timestamp, decile,
min(SOME_METRIC_TOTAL) as min_time,
avg(SOME_METRIC_TOTAL) as avg_time,
max(SOME_METRIC_TOTAL) as max_time,
count(*) as count from (select SOME_METRIC_TOTAL, SOME_COL_TYPE, SOME_COL(5) over 
(order by SOME_METRIC_TOTAL) as decile from SOME_DB_TABLE where SOME_ID_COL = '$1' 
and create_date > '$start_timestamp' 
and create_date < '$end_timestamp' 
and SOME_COL_TYPE = '$3') 
as x group by decile order by decile;
EOF_print1_sql

if [ $DEBUG = "false" ]; then
cat <<EOF1_sql | psql
select '$start_timestamp'as timestamp, decile,
min(SOME_METRIC_TOTAL) as min_time,
avg(SOME_METRIC_TOTAL) as avg_time,
max(SOME_METRIC_TOTAL) as max_time,
count(*) as count from (select SOME_METRIC_TOTAL, SOME_COL_TYPE, SOME_COL(5) over 
(order by SOME_METRIC_TOTAL) as decile from SOME_DB_TABLE where SOME_ID_COL = '$1' 
and create_date > '$start_timestamp' 
and create_date < '$end_timestamp' 
and SOME_COL_TYPE = '$3') 
as x group by decile order by decile;
EOF1_sql
fi

################## query #1 ########################################


################## query #2 ########################################
cat <<EOF_query2_print
select '$start_timestamp' as timestamp,
 SOME_COL_TYPE,
 response_code,
 count(*) as requests,
avg(SOME_METRIC_TOTAL) as SOME_AVG_METRIC,
stddev(SOME_METRIC_TOTAL) as SOME_STDDEV_METRIC,
sum(content_length)/3600 as bytes_per_second from SOME_DB_TABLE
where create_date > '$start_timestamp' 
and create_date < '$end_timestamp' 
and SOME_ID_COL = '$1' 
and result_code < '100000' group by 1, 2, 3 order by 2, 5 desc;
EOF_query2_print

if [ $DEBUG = "false" ]; then
cat <<EOF2_sql | psql 
select '$start_timestamp' as timestamp,
 SOME_COL_TYPE,
 response_code,
 count(*) as requests,
avg(SOME_METRIC_TOTAL) as SOME_AVG_METRIC,
stddev(SOME_METRIC_TOTAL) as SOME_STDDEV_METRIC,
sum(content_length)/3600 as bytes_per_second from SOME_DB_TABLE
where create_date > '$start_timestamp' 
and create_date < '$end_timestamp' 
and SOME_ID_COL = '$1' 
and result_code < '100000' group by 1, 2, 3 order by 2, 5 desc;
EOF2_sql
fi
################## query #2 ########################################

		done
cat <<EOF_hline

############################################################

EOF_hline
	done

}

################################# MAIN #############################


id=$1
start_date=$2
end_date=$3
SOME_COL_TYPE="${4}"

${DEBUG:=false}

if [ $# -ne 4 ]; then
	echo "Usage: $(basename $0) <SOME ID> <start date as MM/DD/YYYY> <end date as MM/DD/YYYY> <service type>"
	print_services
	exit
fi

log="${id}_$( basename $0 ).$$.out"
echo "logging to $log"
#echo "Press return to start query for $id start $start_date end $end_date service type $SOME_COL_TYPE"
#echo "Start of query for $id start $start_date end $end_date service type $SOME_COL_TYPE"

date=$start_date

while [ "$date" != "$end_date" ]; do
	do_query $id $date "$SOME_COL_TYPE" | tee -a $log
	new_date=$( eval date -d \'${date}+1 day\' \'+%m/%d/%Y %H:%M:%S\' )
	date=$( echo $new_date | awk '{print $1 }' )
done

##################################################################
echo "Logfile $log"
