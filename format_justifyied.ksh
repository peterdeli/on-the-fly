cat /tmp/envs.txt | sort -t'=' -k2 |  awk -F'=' '{printf( "%25s =  %s\n", $1, $2) }' > envs.sorted.txt
#keep
