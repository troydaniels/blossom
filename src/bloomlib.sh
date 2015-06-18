#bloomlib.sh
#Functions for the manipulation of a bloom filter

#Calculates the 32-bit FNV hash of argument
#Exits with status 1 if invalid arguments
#fnv_la_hash element
function fnv_1a ()
{
  if [[ -z $1 || $# -ne 1 ]]
  then
      echo "$FUNCNAME: invalid arguments"
      exit 1
  fi

  local fnv_prime_32=16777619
  local offset_basis_32=2166136261
  local element="$1"
  local hash

  while [ -n "$element" ]
  do
    hash="$offset_basis"
    #The offset basis bitwise or equalled with the first character
    ((hash|=$(ascii_to_dec "${element:0}")))
    ((hash*="$fnv_prime_32"))
    #Remove first character
    element="${element:1:${#element}}"
  done

  echo "$hash"
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
  while [ "$k_value" -ne 0 ]
  do
    #g(x)=f(x)+i*h(x)
    #bitwise AND together to give FNV hash-bit length string
    ((new_hash=$(fnv_1a "$element")))
    ((string|=("$new_hash"+"$k_value"*"$new_hash")))
    ((k_value--))
  done
  echo "$string"
}

#Tests to see if element is a member of a hashstring as defined by add_element
#Returns 0 IF TRUE, the hash of the element if false, and exits with status 1 if incorrect number of arguments
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
  while [ "$k_value" -ne 0 ]
  do
    #g(x)=f(x)+i*h(x)
    #bitwise AND together to give FNV hash-bit length string
    ((new_hash=$(fnv_1a "$element")))
    ((test|=("$new_hash"+"$k_value"*"$new_hash")))
    ((k_value--))
  done

  #If strings can be bitwise ANDed together, and are equal to original test hash, we have a high
  #probability of having a match
  ((compare="$string" & "$test"))
  ((compare^="$test"))
#  verbose "$string" "$test" "$compare"
  echo "$compare"
}

#Returns decimal value of ASCII character passed in as argument
#Exits with status 1 if passed invalid arguments
function ascii_to_dec()
{

  if [[ -z $1 || $# -ne 1 ]]
  then
#      echo "$FUNCNAME: invalid arguments"
      exit 1
  fi

  local dec_val

  #Note seemingly (but not) misplaced ' character
  printf -v dec_val %d "'$1"

  echo "$dec_val"
}

function verbose()
{
  echo "Current String:   $1"
  echo "Element Hash:     $2"
  echo "Difference:       $3"
}
