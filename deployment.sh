#!/bin/bash

set -e 

# Make sure the environment has a configured AWS_PROFILE var with gives access to the AWS resources
if [[ -z AWS_PROFILE ]]; then
  echo "ERROR: Cannot find env var AWS_PROFILE. Please configure it first."
  exit 1
fi

export AWS_PAGER=cat
AwsAccount=$(aws sts get-caller-identity | jq -r '.Account')
BucketName="${AwsAccount}-qctrl-static-website-bucket"

function cloudformation_validate() {
  echo "==> Validating CloudFormation template..."
  aws cloudformation validate-template --template-body file://cloudformation/static_website.yaml
}

function cloudformation_deploy() {
  echo "==> Deploying S3 bucket for a static website..."
  stackup qctrl-static-website up -t cloudformation/static_website.yaml \
    -o BucketName=${BucketName} \
    # --debug \
    # --on-failure DO_NOTHING
}

function static_website_deploy_files() {
  echo "==> Deploying files into the website..."
  aws s3 cp files/index.html s3://${BucketName}/index.html
}

function test_static_website_content() {
  echo "==> Test if the website displays the required string..."
  WebsiteURL=$(aws cloudformation describe-stacks --stack-name qctrl-static-website | jq -r '.Stacks[0].Outputs[] | select( .OutputKey | contains("WebsiteURL")).OutputValue')

  website_content=$(curl -s $WebsiteURL)
  if [[ $website_content != "This is Suan Kan's website" ]]; then
    echo "ERROR: website_content: $website_content. It is not equal to the required string."
    exit 1
  else
    echo "SUCCESS: Deployed and tested a static website!"
  fi
}

cloudformation_validate
cloudformation_deploy
static_website_deploy_files
test_static_website_content
