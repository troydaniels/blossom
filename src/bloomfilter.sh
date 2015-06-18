#!/bin/bash
#bloomfilter.sh
#Troy Daniels
#A bloom filter, using functions from bloomlib.sh
. bloomlib.sh

declare -i bloom_filter=0
declare -i k_value=5
declare -i element_test
declare  add="add"
declare  test="test"

echo "Usage: [$add|$test] ELEMENT"
while :
do
  read flag element
  #Validate input
  if [[ "$flag" != "$add" && "$flag" != "$test" ]]
  then
    echo "Usage: [$add|$test] ELEMENT"
    read flag element
  #Perform operation
  elif [ "$flag" = "$add" ]
  then
    ((bloom_filter=$(add_value "$element" "$k_value" "$bloom_filter")))
  elif [ "$flag" = "$test" ]
  then
    #Test existence of element
    ((element_test=$(test_value "$element" "$k_value" "$bloom_filter")))
    if [[ "$element_test" -eq 0 ]]
    then
      echo ">$element has probably been seen"
    else
      echo ">$element has not been seen"
    fi
  fi

  flag=""
  element=""
done
