#!/bin/bash

curl $SITE_URL

# Check if the curl was successful
if [ $? -eq 0 ]; then
    echo "\nCurled successfully."
else
    echo "Failed to reach $SITE_URL."
    exit 1
fi
