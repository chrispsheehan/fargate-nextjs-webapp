#!/bin/bash

if [ -z "$REPO_NAME" ]
then
    echo "REPO_NAME not defined!"
    exit 1
fi

if [ -z "$AWS_REGION" ]
then
    echo "AWS_REGION not defined!"
    exit 1
fi

# Check if the repository already exists
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION > /dev/null 2>&1

if [ $? -ne 0 ]; then
    # Repository does not exist, create it
    echo "Creating ECR repository: $REPO_NAME"
    aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
else
    echo "ECR repository $REPO_NAME already exists."
fi
