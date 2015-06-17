#!/bin/bash
#bloomfilter.sh
#A bloom filter, using functions from bloomlib.sh
. bloomlib.sh

declare -i bloom_filter=""
declare -i k_value=5

while :
do
  #Validate input
  while [[ "$flag" != "a" && "$flag" != "t" ]]
  do
    echo "Usage: arg [a|t] - a for add, t for test"
  read element flag
  done

  #Perform operation
  if [ "$flag" = "a" ]
  then
    add_value "$element" $k_value $bloom_filter
  else
    #Test existence of element
    if [ test_value "$element" $k_value $bloom_filter ]
    then
      echo "$element has probably been seen"
    else
      echo "$element has not been seen"
    fi
  fi

  flag=""
  element=""
done
