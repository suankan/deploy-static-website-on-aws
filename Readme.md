# Description

This is a response for https://github.com/qctrl/devops-challenge

# Required third-party tools

- curl
- jq
- aws cli
- stackup (a nice wrapper around aws cli. Installation details: https://github.com/realestate-com-au/stackup).

# Assumptions

Deployment script assumes that aws cli is configured in your local execution environment and valid credentials are present.

# How it works

Minimal deployment of a static website on AWS can be done by:
- creating an S3 bucket
- giving it Public Access
- giving it website configuration
- placing `index.html` file inside it

File `cloudformation/static_website.yaml` contains CloudFortmation with:
- S3 bucket
- Bucket Policy
- Output with WebsiteURL

File `files/index.html` contains the required string **This is Suan Kan's website**.

File `deployment.sh` contains shell script which:

- Validates CloudFortmation template.
- Deploys the CloudFormation template on AWS (assuming that valid and working AWS_PROFILE is set).
- Deploys file `files/index.html` into the created S3 bucket.
- Retrieves URL of the created S3 bucket website and calls it with `curl`.
- Tests the `curl` output with the required string.

# How to use this repo

- Satisfy **Required third-party tools** and **Assumptions**
- Clone the repo.
- Enter repo directory.
- Execute script `deployment.sh`

```
./deployment.sh
==> Validating CloudFormation template...
{
    "Parameters": [
        {
            "ParameterKey": "BucketName",
            "NoEcho": false
        }
    ],
    "Description": "CloudFormation stack to deploy a static website on S3."
}
==> Deploying S3 bucket for a static website...
INFO: [18:16:31] qctrl-static-website - CREATE_IN_PROGRESS - User Initiated
INFO: [18:16:34] S3Bucket - CREATE_IN_PROGRESS
INFO: [18:16:36] S3Bucket - CREATE_IN_PROGRESS - Resource creation Initiated
INFO: [18:16:57] S3Bucket - CREATE_COMPLETE
INFO: [18:16:59] S3BucketPolicy - CREATE_IN_PROGRESS
INFO: [18:17:00] S3BucketPolicy - CREATE_IN_PROGRESS - Resource creation Initiated
INFO: [18:17:01] S3BucketPolicy - CREATE_COMPLETE
INFO: [18:17:03] qctrl-static-website - CREATE_COMPLETE
CREATE_COMPLETE
==> Deploying files into the website...
upload: files/index.html to s3://039095953046-qctrl-static-website-bucket/index.html
==> Test if the website displays the required string...
SUCCESS: Deployed and tested a static website!
```

This repo and deployment script are ready to be a part of existing CI/CD pipeline. 
