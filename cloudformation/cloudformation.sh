#!/bin/bash

#####################################
## Deploy cloudformation templates
#

REGION="eu-usa-1"
PROFILE="default"
AWSCLI="/usr/local/bin/aws"
TEMPLATES_PATH="./"

deploy_all () {
  if [[ ! -z ${DEPLOY_ALL} ]]; then
    if [[ -z ${YES_TO_ALL} ]]; then
      read -p "I will deploy ALL stacks, are you sure? (y/n)" -n 1 -r
      echo
      if [[ $REPLY =~ [Yy]$ ]]; then
        YES_TO_ALL='y'
      else
        YES_TO_ALL=''
      fi
    fi
    if [[ ! -z ${YES_TO_ALL} ]]; then
      echo ""
      echo "File: ${TEMPLATES_PATH}${ENV_NAME}/base/${ENV_NAME}-networkstack.yaml"
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${TEMPLATES_PATH}${ENV_NAME}/base/${ENV_NAME}-networkstack.yaml --stack-name ${ENV_NAME}-networkstack
      echo ""
      echo "File: ${TEMPLATES_PATH}${ENV_NAME}/security/${ENV_NAME}-securitygroups.yaml"
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${TEMPLATES_PATH}${ENV_NAME}/security/${ENV_NAME}-securitygroups.yaml --stack-name ${ENV_NAME}-securitygroups
      echo ""
      echo "File: ${TEMPLATES_PATH}${ENV_NAME}/security/${ENV_NAME}-iam.yaml"
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${TEMPLATES_PATH}${ENV_NAME}/security/${ENV_NAME}-iam.yaml --stack-name ${ENV_NAME}-iam --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM"
      echo ""
      echo "File: ${TEMPLATES_PATH}${ENV_NAME}/security/${ENV_NAME}-bastion.yaml"
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${TEMPLATES_PATH}${ENV_NAME}/security/${ENV_NAME}-bastion.yaml --stack-name ${ENV_NAME}-bastion
      echo ""
      echo "File: ${TEMPLATES_PATH}${ENV_NAME}/db/${ENV_NAME}-database.yaml"
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${TEMPLATES_PATH}${ENV_NAME}/db/${ENV_NAME}-database.yaml --stack-name ${ENV_NAME}-database
      echo ""
      echo "File: ${TEMPLATES_PATH}${ENV_NAME}/application/${ENV_NAME}-beanstalk-restdataapi.yaml"
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${TEMPLATES_PATH}${ENV_NAME}/application/${ENV_NAME}-beanstalk-restdataapi.yaml --stack-name ${ENV_NAME}-beanstalk-restdataapi
      echo ""
      echo "File: ${TEMPLATES_PATH}${ENV_NAME}/application/${ENV_NAME}-apigw.yaml"
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${TEMPLATES_PATH}${ENV_NAME}/application/${ENV_NAME}-apigw.yaml --stack-name ${ENV_NAME}-apigw
      echo ""
      echo "File: ${TEMPLATES_PATH}${ENV_NAME}/application/${ENV_NAME}-apigw-vpclink.yaml"
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${TEMPLATES_PATH}${ENV_NAME}/application/${ENV_NAME}-apigw-vpclink.yaml --stack-name ${ENV_NAME}-apigw-vpclink --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM"
    fi
  fi
}

deploy_stack() {
  if [[ ! -z ${STACK_NAME} && ! -z ${FILE_NAME} ]]; then
    if [[ -z ${YES_TO_ALL} ]]; then
      read -p "I will deploy ${FILE_NAME} with stack name as ${STACK_NAME}, are you sure? (y/n)" -n 1 -r
      echo
      if [[ $REPLY =~ [Yy]$ ]]; then
        YES_TO_ALL='y'
      else
        YES_TO_ALL=''
      fi
    fi
    if [[ ! -z ${YES_TO_ALL} ]]; then
      ${AWSCLI} --region ${REGION} --profile ${PROFILE} cloudformation deploy --template-file ${FILE_NAME} --stack-name ${STACK_NAME}
    fi
  fi
}

show_help () {
  echo "USAGE:"
  echo ""
  echo " # Deploy a stack as STACKNAME getting resources from FILENAME"
  echo "   $0 -s STACKNAME -f FILENAME"
  echo ""
  echo " # Deploy ALL the files for the environment ENVNAME"
  echo "   $0 -a -e ENVNAME"
  echo ""
  echo " Add -y for NO confirmation on deployment."
  echo " ENVNAME is part of file path on this directory structure."
  echo ""
  echo "Script defaults:"
  echo " - REGION:         ${REGION}"
  echo " - PROFILE:        ${PROFILE}"
  echo " - TEMPLATES PATH: ${TEMPLATES_PATH}"
  echo ""
  echo "You MUST have aws cli configured and working BEFORE trying using this."
  echo ""
}

#########
## Main 
#

 STACK_NAME=''
 ENV_NAME=''
 FILE_NAME=''
 DEPLOY_ALL=''
 YES_TO_ALL=''

 while getopts 'yhs:e:f:a' opt; do
   case ${opt} in
     h)
       show_help
       exit 0
       ;;
     s)
       STACK_NAME="$OPTARG"
       ;;
     e)
       ENV_NAME="$OPTARG"
       ;;
     f)
       FILE_NAME="$OPTARG"
       ;;
     y)
       YES_TO_ALL="y"
       ;;
     a)
       DEPLOY_ALL="y"
       ;;
   esac
 done

 if [[ ! -z ${DEPLOY_ALL} && ! -z ${ENV_NAME} ]]; then
   echo ""
   echo "Starting deploy ALL for env  [ ${ENV_NAME} ]  <<--"
   deploy_all
 fi
 if [[ ! -z ${STACK_NAME} && ! -z ${FILE_NAME} ]]; then
   echo ""
   echo "Starting deploy of  [ ${FILE_NAME} ]  for stack  [ ${STACK_NAME} ]  in  [ ${REGION} ] "
   echo ""
   deploy_stack
 fi

 exit 0
