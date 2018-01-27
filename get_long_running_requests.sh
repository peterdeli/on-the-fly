#!/bin/bash


#select distinct COLS from TABLE: 
REQUEST_DESCRIPTIONS="Bad request
Could not do something
Internal server error
Invalid ID
Invalid remote IP address
Missing ID
Password expired
Success
Success - all types
Success - blank 
Success - mixed type and high res
Unauthorized access
Unauthorized coordinate error 
Unauthorized type
Unauthorized othertype1
Unauthorized othertype2
User suspended
"


export HOST=HOST
export PORT=0000
export DATABASE=DB
export USER=USER
export PASSWORD=1234
export OUTFILE="$( basename $0 ).sql.out.$$"

COL__OPT=false
START_DATE_OPT=false
END_DATE_OPT=false
SERVICE_TYPE_OPT=false
row_limit=100
ROW_LIMIT_OPT=false 
DESCR_OPT=false

help(){
cat <<EOF
Usage: $0 -m <COL_ uid>  -s <start date> -e <end date> -l <row limit> -d <description>
    Service types:
Some Service 51
Some Service 52
Some Service 53
Some Service 54
Some Service 55
Some Service 56
Some Service 57
Some Service 58
Some Service 59
Some Service 60
Some Service 61
EOF
}

while getopts d:l:m:s:t:e:h opt; do
    # echo "Option: $opt"
    case $opt in
        m) COL__guid=$OPTARG ; COL__OPT=true ;;
        s) start_date=$OPTARG; START_DATE_OPT=true ;;
        e) end_date=$OPTARG; END_DATE_OPT=true ;;
        l) row_limit=$OPTARG; ROW_LIMIT_OPT=true ;;
        d) descr=$OPTARG; DESCR_OPT=true ;;
        #t) service_type=$OPTARG; SERVICE_TYPE_OPT=true ;;
	h) help; exit;;
        ?) echo "Unknown option $opt"; exit ;;
    esac
done


appdir=$( dirname $0 )
cd $appdir
fname=$( basename $0 )

SOME_file="${PWD}/.${fname}.COL__guid"
touch $SOME_file

if [ $COL__OPT = "false" ]; then
	SOME=$( cat $SOME_file | tail -1 2>/dev/null )
	echo -n "COL__guid: ( $SOME ): "
	read COL__guid
	if [[ -z $COL__guid  ]]; then
		COL__guid=$SOME
	fi
fi
echo $COL__guid >> $SOME_file 

saved_descr_file="${PWD}/.${fname}.descr"
touch $saved_descr_file

if [ $DESCR_OPT = "false" ]; then
	SAVED_PS3=$PS3
	#PS3="description: ( $saved_descr ): "
	saved_descr=$( cat $saved_descr_file | tail -1 2>/dev/null )
	PS3="Choice: "
	select descr in $REQUEST_DESCRIPTIONS; do
	  echo "Using choice $REPLY ( $descr )" 	
	  break
          done
	if [[ -z $descr  ]]; then
		descr=$saved_descr
	fi
fi
echo $descr >> $saved_descr_file 


saved_service_file="${PWD}/.${fname}.service_type"
touch $saved_service_file


saved_start_date_file="${PWD}/.${fname}.start_date"
touch $saved_start_date_file

if [ $START_DATE_OPT = "false" ]; then
	saved_start_date=$( cat $saved_start_date_file | tail -1 2>/dev/null )
	echo -n "start_date (  $saved_start_date  ): "
	read start_date
	if [[ -z $start_date ]]; then
		start_date=$saved_start_date
	fi
fi
echo $start_date >> $saved_start_date_file 

saved_end_date_file="${PWD}/.${fname}.end_date"
touch $saved_end_date_file

if [ $END_DATE_OPT = "false" ]; then
	saved_end_date=$( cat $saved_end_date_file | tail -1 2>/dev/null )
	echo -n "end_date ( $saved_end_date  ): "
	read end_date
	if [[ -z $end_date ]]; then
		end_date=$saved_end_date
	fi
fi

echo $end_date >> $saved_end_date_file 

cat <<EOF
environment:

$( env | grep ENV )

OPTIONS:
COL__OPT=$COL__OPT
START_DATE_OPT=$START_DATE_OPT
END_DATE_OPT=$END_DATE_OPT

COL__guid: $COL__guid
start_date:  $start_date
end_date:    $end_date

EOF

echo "Checking for $COL__guid start date $start_date end date $end_date, limit first $row_limit rows."
cat <<EOF3
select SOME_COL, app_host, response_code, count(*) as requests, avg(SOME__time) as avg_request_time, stddev(SOME__time) as stddev_request_time, sum(content_length)/3600 as bytes_per_second from DB  where COL__guid = '$COL__guid' and SOME__time > 100000 and create_date > '$start_date' and create_date < '$end_date' and result_code < '100000' group by 1, 2, 3 order by 1, 4 desc;
EOF3
echo "press return to run"
read this
cat <<EOF1 | psql -o $DB_OUTFILE  
select SOME_COL, app_host, response_code, count(*) as requests, avg(SOME__time) as avg_request_time, stddev(SOME__time) as stddev_request_time, sum(content_length)/3600 as bytes_per_second from DB  where COL__guid = '$COL__guid' and SOME__time > 100000 and create_date > '$start_date' and create_date < '$end_date' and result_code < '100000' group by 1, 2, 3 order by 1, 4 desc;
EOF1
cat <<EOF2
select SOME_COL, app_host, response_code, count(*) as requests, avg(SOME__time) as avg_request_time, stddev(SOME__time) as stddev_request_time, sum(content_length)/3600 as bytes_per_second from DB  where COL__guid = '$COL__guid' and SOME__time > 100000 and create_date > '$start_date' and create_date < '$end_date' and result_code < '100000' group by 1, 2, 3 order by 1, 4 desc;
EOF2
echo "Results in $DB_OUTFILE"
cat $DB_OUTFILE | more
