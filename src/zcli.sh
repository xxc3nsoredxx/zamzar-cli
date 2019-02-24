#! /bin/bash

URL_BASE="https://sandbox.zamzar.com/"
JOBS="v1/jobs/"
FILES="v1/files/"
FILES2="/content"

# Test number of parameters
if [ $# -ne 4 ]; then
    echo "Usage: ./zcli [key file] [input format] [output format] [input file]"
    exit 1
fi

KEY=$1
INPUT=$2
OUTPUT=$3
FILE=$(pwd)/$4

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

# Upload file to server
RESPONSE=$(curl $URL_BASE$JOBS \
    -u $KEY \
    -X POST \
    -F "source_file=@$FILE" \
    -F "target_format=$OUTPUT")

# Remove braces and brackets
RESPONSE=$(echo $RESPONSE | sed 's/[]{}\[]//g')

# Extract job ID
JOB_ID=$(echo $RESPONSE | awk 'BEGIN{FS=","} {print $1}')
JOB_ID=$(echo $JOB_ID | awk 'BEGIN{FS=":"} {print $2}')
echo "[!] job id: $JOB_ID"

JOB_STATUS=""
while [ "$JOB_STATUS" != "successful" ]; do
    # Check if job is complete
    RESPONSE=$(curl $URL_BASE$JOBS$JOB_ID \
        -u $KEY)
    
    # Remove braces and brackets
    RESPONSE=$(echo $RESPONSE | sed 's/[]{}\[]//g')
    
    # Extract job status
    JOB_STATUS=$(echo $RESPONSE | awk 'BEGIN{FS=","} {print $3}')
    JOB_STATUS=$(echo $JOB_STATUS | awk 'BEGIN{FS=":"} {print $2}')
    
    # Remove quotes
    JOB_STATUS=$(echo $JOB_STATUS | sed 's/"//g')
done
echo "[+] job complete"

# Extract file ID
FILE_ID=$(echo $RESPONSE | awk 'BEGIN{FS=","} {print $10}')
FILE_ID=$(echo $FILE_ID | awk 'BEGIN{FS=":"} {print $3}')

echo "[!] file id: $FILE_ID"

# Download file
curl $URL_BASE$FILES$FILE_ID$FILES2 \
    -u $KEY \
    -L \
    -O \
    -J
