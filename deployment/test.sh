#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

export ADMIN_APIGATEWAYURL=$(aws cloudformation list-exports --query "Exports[?Name=='SaaS-Operations-AdminApiGatewayUrl'].Value" --output text)
export LOAD_REGION=$(aws configure get region)
export LOAD_USER_PASS=Lab@12345

export P1_METADATA=$(curl "${ADMIN_APIGATEWAYURL}/tenant/init/PooledTenant1")
export P1_USERPOOL=$(echo $P1_METADATA | jq -r '.userPoolId')
export P1_CLIENTID=$(echo $P1_METADATA | jq -r '.appClientId')
export P1_ENDPOINT=$(echo $P1_METADATA | jq -r '.apiGatewayUrl')
export P1_USER=$( aws cognito-idp list-users --user-pool-id $P1_USERPOOL --filter "email = \"success+PooledTenant1@simulator.amazonses.com\"" | jq -r '.Users[]|.Username')

aws cognito-idp admin-set-user-password --user-pool-id $P1_USERPOOL --username $P1_USER --password $LOAD_USER_PASS --permanent
export P1_TOKEN=$(aws cognito-idp initiate-auth --region $LOAD_REGION --auth-flow USER_PASSWORD_AUTH   \
    --client-id $P1_CLIENTID --auth-parameters \
    USERNAME=$P1_USER,PASSWORD=$LOAD_USER_PASS | jq -r .AuthenticationResult.IdToken)

curl -X GET -H "Authorization: Bearer ${P1_TOKEN}" "${P1_ENDPOINT}/products"
curl -X GET -H "Authorization: Bearer ${P1_TOKEN}" "${P1_ENDPOINT}/orders"
curl -X GET -H "Authorization: Bearer ${P1_TOKEN}" "${ADMIN_APIGATEWAYURL}/users"
