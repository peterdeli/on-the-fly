#!/bin/ksh
#keep

f5_jar="C:\Users\pdelevor\.m2\repository\com\digitalglobe\tools\f5Explore\1.2\f5Explore-1.2.jar"

cd ~/bin 

pipe=""
once=true

while [ 1 ]; do
    echo -n "$0 ";  date
    
    if [ $# -gt 0 ]; then
    	if [ $1 = green ]; then
    		pipe="| grep -i green"
    	elif [ $1 = red ]; then
    		pipe="| grep -i red"
    	elif [ $1 = "both" -o $1 = "all" ]; then
    		pipe=""
    		once=false
    	fi
    fi
    
    if [ "XX$pipe" = "XX" -a $once = "true" ]; then	
    	  java -Df5.user=pdelevor -Df5.pass=sk1p2myL0u -Df5.properties=services.properties -jar $f5_jar output=poolsOnly && echo
    	  break
    else
    	  f5_jar="C:\\Users\\pdelevor\\.m2\\repository\\com\\digitalglobe\\tools\\f5Explore\\1.2\\f5Explore-1.2.jar"
    	  eval "java -Df5.user=pdelevor -Df5.pass=sk1p2myL0u -Df5.properties=services.properties -jar '$f5_jar' output=poolsOnly | sort -k1 $pipe | grep dgwsapp && echo"
	  echo "==========================="
	  echo 
          sleep 15
    	  eval "java -Df5.user=pdelevor -Df5.pass=sk1p2myL0u -Df5.properties=services.properties -jar '$f5_jar' output=poolsOnly | sort -k1 $pipe | grep pu00 && echo"
	  echo "==========================="
	  echo 
          sleep 15
    fi
    

done
