#! /bin/bash

# Test number of parameters
if [ $# -ne 4 ]; then
    echo "Usage: ./zcli [key file] [input format] [output format] [input file]"
    exit 1
fi

KEY=$1
INPUT=$2
OUTPUT=$3
FILE=$4

# Test if key file exists
if [ ! -r $KEY ]; then
    echo "Key file does not exist or is unreadable: $KEY"
    exit 1
fi

# Read key into variable
KEY=$(cat $KEY)

# Test if input file exists
if [ ! -r $FILE ]; then
    echo "Input file does not exist or is unreadable: $FILE"
    exit 1
fi

echo "key: $KEY"
echo "input format: $INPUT"
echo "output format: $OUTPUT"
echo "file to convert: $FILE"
