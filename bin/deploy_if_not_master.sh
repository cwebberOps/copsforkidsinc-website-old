#!/bin/bash

LIFECYCLE_CONFIG='http://util.cwebber.net/15_day_expire.json'
HOSTNAME=$(echo "${CI_BRANCH}" | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
SUFFIX='-staging.copsforkidsinc.org'

echo $hostname
if [ "${CI_BRANCH}" != "master" ]; then

  echo "Deploying ${HOSTNAME}${SUFFIX}"

  pip install awscli
  aws s3 mb s3://${HOSTNAME}${SUFFIX}
  aws s3 sync . s3://${HOSTNAME}${SUFFIX} --acl public-read --delete
  aws s3api put-bucket-lifecycle --bucket ${HOSTNAME}${SUFFIX} --lifecycle-configuration $LIFECYCLE_CONFIG
  aws s3 website s3://${HOSTNAME}${SUFFIX} --index-document index.html
  aws sns publish --topic-arn $SNS_ARN --subject '[copsforkidsinc.org] Staging Deploy' \
    --message "Deploy of branch $CI_BRANCH can be viewed at http://${HOSTNAME}${SUFFIX}.s3-website-us-east-1.amazonaws.com/"

fi
