if [ "$CIRCLE_BRANCH" == "master" ]; then export ENV=PROD; fi
if [ "$CIRCLE_BRANCH" == "dev" ]; then export ENV=DEV; fi
if [ "$CIRCLE_BRANCH" == "qa" ]; then export ENV=QA; fi
if [ "$CIRCLE_BRANCH" == "dev-auth0" ]; then export ENV=NEWAUTH; fi

export AWS_ACCESS_KEY_ID=$(eval "echo \$${ENV}_AWS_ACCESS_KEY_ID")
export AWS_SECRET_ACCESS_KEY=$(eval "echo \$${ENV}_AWS_SECRET_ACCESS_KEY")
export AWS_S3_BUCKET=$(eval "echo \$${ENV}_S3_BUCKET")
export AUTH0_DOMAIN=$(eval "echo \$${ENV}_AUTH0_DOMAIN")
export AUTH0_DEPLOY_CLIENT_ID=$(eval "echo \$${ENV}_AUTH0_DEPLOY_CLIENT_ID")
export AUTH0_DEPLOY_CLIENT_SECRET=$(eval "echo \$${ENV}_AUTH0_DEPLOY_CLIENT_SECRET")
export ACCOUNTS_DOMAIN=$(eval "echo \$${ENV}_ACCOUNTS_DOMAIN")