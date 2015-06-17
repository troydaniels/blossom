#!/bin/bash
#bloomlib.sh
#Functions for the manipulation of a bloom filter

#Calculates the 32-bit FNV hash of argument
#Exits with status 1 if invalid arguments
#fnv_la_hash element

function fnv_1a ()
{
  echo "$1 --" 
  echo "$# -"
  if [[ -z $1 || $# -ne 1 ]]
  then
      echo "$FUNCNAME: invalid arguments"
      exit 1
  fi

  local 32_fnv_prime=16777619
  local 32_offset_basis=2166136261
  local element=$1
  local string=$32_offset_basis

  while [ -n "$element" ]
  do
    hash=$(( $string ^ "${element:0}" ))
    hash=$string*$32_fnv_prime
    #Remove first element
    element="${element:0:${#element}}"
  done

  return $string
}

#Adds k hashed values of an element to a hashstring, all passed in as arguments
#Returns updated hashstring, or exits with status 1 if invalid arguments
#add_value element k string
function add_value ()
{
  if [ $# -ne 3 ]
  then
      echo "$FUNCNAME: invalid  arguments"
      exit 1
  fi

  local element=$1
  local k_value=$2
  local string=$3
  local new_hash

  #Add k different hashes of character to string
  for count in {1..k_value}
  do
    #g(x)=f(x)+i*h(x)
    #bitwise AND together to give FNV hash-bit length string
    fnv_1a "$element"
    new_hash=$?
    string=$string & ($new_hash + $count * $new_hash)
  done

  return $string
}

#Tests to see if element is a member of a hashstring as defined by add_element
#Returns 1 if true, 0 if false, and exits with status 1 if incorrect number of arguments
#test_value element k string
function test_value ()
{
  if [ $# -ne 3 ]
  then
      echo "$FUNCNAME: invalid arguments"
      exit 1
  fi

  local element=$1
  local k_value=$2
  local string=$3
  local test=0
  local compare

  #Add k different hashes of character to test
  for count in {1..k_value}
  do
    #g(x)=f(x)+i*h(x)
    #bitwise AND together to give FNV hash-bit length string
    test=$test & (fnv_1a "$element" + $count * fnv_1a "$element")
  done

  #If strings can be bitwise ANDed together, and are equal to hashstring, we have a high
  #probability of having a match
  compare=$string & $test
  return [ $compare -eq $string ] && 1 || 0
}

