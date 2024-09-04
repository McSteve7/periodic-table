#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to check if a string is a number
is_number() {
  [[ $1 =~ ^[0-9]+$ ]]
}

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 1
fi

INPUT=$1

# Determine if the input is a number or string
if is_number "$INPUT"; then
  QUERY_CONDITION="e.atomic_number = $INPUT"
else
  QUERY_CONDITION="e.symbol = '$INPUT' OR e.name = '$INPUT'"
fi

# Query to find the element information based on atomic_number, symbol, or name
ELEMENT_INFO=$($PSQL "
  SELECT
    e.atomic_number,
    e.symbol,
    e.name,
    p.type,
    p.atomic_mass,
    p.melting_point_celsius,
    p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  WHERE $QUERY_CONDITION
")

# Check if the element exists
if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
  exit 1
fi

# Parse the result into variables
IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$ELEMENT_INFO"

# Output the element information
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
