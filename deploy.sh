#!/usr/bin/env bash

ENV=$1

#AWS_REGION=$(eval "echo \$${ENV}_AWS_REGION")
AWS_ACCESS_KEY_ID=$(eval "echo \$${ENV}_AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY=$(eval "echo \$${ENV}_AWS_SECRET_ACCESS_KEY")
AWS_S3_BUCKET=$(eval "echo \$${ENV}_S3_BUCKET")

configure_aws_cli() {
	aws --version
	aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
	aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
	#aws configure set default.region $AWS_REGION
	aws configure set default.output json
	echo "Configured AWS CLI."
}

deploy_s3bucket() {
	result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control private,no-store,no-cache,must-revalidate,max-age=0  --content-encoding gzip`
	if [ $? -eq 0 ]; then
		#echo $result
		echo "Deployed!"
	else
		echo "Deployment Failed  - $result"
		exit 1
	fi
}

configure_aws_cli
deploy_s3bucket
