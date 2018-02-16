#!/usr/bin/env bash

ENV=$1

if [ "$2" = "no-cache" ]; then
    NOCACHE=true
fi

configure_aws_cli() {
	aws --version
	aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
	aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
	aws configure set default.output json
	echo "Configured AWS CLI."
}

deploy_s3bucket() {
	if [ "$NOCACHE" = "true" ]; then
		echo "Deploying without cache-control"
		aws s3 sync --dryrun ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control private,no-store,no-cache,must-revalidate,max-age=0 --exclude "*.txt" --exclude "*.js" --exclude "*.css"
		result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET}  --cache-control private,no-store,no-cache,must-revalidate,max-age=0 --exclude "*.txt" --exclude "*.js" --exclude "*.css"`
	else
		echo "Deploying with cache-control"
		aws s3 sync --dryrun ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control max-age=0,s-maxage=86400 --exclude "*.txt" --exclude "*.js" --exclude "*.css"
		result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET}  --cache-control max-age=0,s-maxage=86400 --exclude "*.txt" --exclude "*.js" --exclude "*.css"`
	fi

	if [ $? -eq 0 ]; then
		echo "All html, font, image and media files are Deployed without gzip encoding!"
	else
		echo "Deployment Failed  - $result"
		exit 1
	fi

	if [ "$NOCACHE" = "true" ]; then
		echo "Deploying without cache-control"
		aws s3 sync --dryrun ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control private,no-store,no-cache,must-revalidate,max-age=0 --exclude "*" --include "*.txt" --include "*.js" --include "*.css" --content-encoding gzip
		result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET}  --cache-control private,no-store,no-cache,must-revalidate,max-age=0 --exclude "*" --include "*.txt" --include "*.js" --include "*.css" --content-encoding gzip`
	else
		echo "Deploying with cache-control"
		aws s3 sync --dryrun ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control max-age=0,s-maxage=86400 --exclude "*" --include "*.txt" --include "*.js" --include "*.css" --content-encoding gzip
		result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET}  --cache-control max-age=0,s-maxage=86400 --exclude "*" --include "*.txt" --include "*.js" --include "*.css" --content-encoding gzip`
	fi

	if [ $? -eq 0 ]; then
		echo "All css, js, and map files are Deployed! with gzip"
	else
		echo "Deployment Failed  - $result"
		exit 1
	fi

}

deploy_auth0_page() {
	if [ "$AUTH0_DOMAIN" = "" ] || [ "$AUTH0_DEPLOY_CLIENT_ID" = "" ]; then
		echo "Auth0 deployment configuration missing. Ignoring hosted login page deployment"
		return
	fi

	echo "Starting deployment of Auth0 Hosted Login Page"

	echo "{\"pages\":{\"login\":{\"htmlFile\":\"$(sed 's/\"/\\"/g' dist/auth0-hlp.html | tr -d '\n')\",\"metadata\":false,\"name\":\"login\"}}}" > page_deploy.json
	echo "{\"AUTH0_CLIENT_ID\":\"$AUTH0_DEPLOY_CLIENT_ID\", \"AUTH0_DOMAIN\": \"$AUTH0_DEPLOY_DOMAIN\",\"AUTH0_EXCLUDED_RULES\":[\"Global variables and functions\",\"Add custom attributes to access token\"]}" > config.json
	unset AUTH0_CLIENT_ID
	unset AUTH0_DOMAIN
	./node_modules/auth0-deploy-cli/index.js -i ./page_deploy.json -c ./config.json -x $AUTH0_DEPLOY_CLIENT_SECRET
	if [ $? -eq 0 ]; then
		echo "Auth0 Hosted Page deployed successfully"
	else
		echo "Auth0 Page Deployment Failed  - $result"
		# TODO: When configured should this make the build fail although the scripts have been deployed to accounts?
	fi
	rm config.json page_deploy.json
	rm -rd ./local
}

echo -e "application/font-woff\t\t\t\twoff2" >> /etc/mime.types
echo -e "application/font-sfnt\t\t\t\tttf" >> /etc/mime.types
echo -e "application/json\t\t\t\tmap" >> /etc/mime.types

cat /etc/mime.types  | grep -i woff
cat /etc/mime.types  | grep -i ico
cat /etc/mime.types  | grep -i map
cat /etc/mime.types  | grep -i ttf

configure_aws_cli
deploy_s3bucket
deploy_auth0_page
