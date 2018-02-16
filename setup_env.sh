if [ "$CIRCLE_BRANCH" == "master" ]; then export ENV=PROD; fi
if [ "$CIRCLE_BRANCH" == "dev" ]; then export ENV=DEV; fi
if [ "$CIRCLE_BRANCH" == "qa" ]; then export ENV=QA; fi
if [ "$CIRCLE_BRANCH" == "dev-auth0" ]; then export ENV=NEWAUTH; fi

echo export AWS_ACCESS_KEY_ID=$(eval "echo \$${ENV}_AWS_ACCESS_KEY_ID") >> ~/.circlerc
echo export AWS_SECRET_ACCESS_KEY=$(eval "echo \$${ENV}_AWS_SECRET_ACCESS_KEY") >> ~/.circlerc
echo export AWS_S3_BUCKET=$(eval "echo \$${ENV}_S3_BUCKET") >> ~/.circlerc
echo export AUTH0_DOMAIN=$(eval "echo \$${ENV}_AUTH0_DOMAIN") >> ~/.circlerc
echo export AUTH0_CLIENT_ID=$(eval "echo \$${ENV}_AUTH0_CLIENT_ID") >> ~/.circlerc
echo export AUTH0_DEPLOY_CLIENT_ID=$(eval "echo \$${ENV}_AUTH0_DEPLOY_CLIENT_ID") >> ~/.circlerc
echo export AUTH0_DEPLOY_CLIENT_SECRET=$(eval "echo \$${ENV}_AUTH0_DEPLOY_CLIENT_SECRET") >> ~/.circlerc
echo export AUTH0_DEPLOY_DOMAIN=$(eval "echo \$${ENV}_AUTH0_DEPLOY_DOMAIN") >> ~/.circlerc
echo export AUTH0_TENANT=$(eval "echo \$${ENV}_AUTH0_TENANT") >> ~/.circlerc
echo export ACCOUNTS_DOMAIN=$(eval "echo \$${ENV}_ACCOUNTS_DOMAIN") >> ~/.circlerc