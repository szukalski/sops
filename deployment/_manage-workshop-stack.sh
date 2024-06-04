#!/bin/bash -x
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

create_workshop() {
    bootstrap_cdk
    cd cloud9
    echo "Starting Cloud9 cdk deploy..."
    cdk deploy --all --require-approval never --context "workshop=$WORKSHOP_NAME"
    echo "Done Cloud9 cdk deploy!"

    get_c9_id
    echo "Waiting for " $C9_ID
    aws ec2 start-instances --instance-ids "$C9_ID"
    aws ec2 wait instance-status-ok --instance-ids "$C9_ID"
    echo $C9_ID "ready"

    replace_instance_profile $BUILD_C9_INSTANCE_PROFILE_PARAMETER_NAME
    run_ssm_command "cd ~/environment ; git clone --branch $REPO_BRANCH_NAME $REPO_URL || echo 'Repo already exists.'"
    #run_ssm_command "cd ~/environment/$REPO_NAME/deployment && ./c9-init.sh $REPO_URL | tee .ws-init.log"
    run_ssm_command "cd ~/environment/$REPO_NAME/deployment && ./c9-create.sh $REPO_URL | tee .ws-create.log"

    replace_instance_profile $PARTICIPANT_C9_INSTANCE_PROFILE_PARAMETER_NAME
}

delete_workshop() {
    get_c9_id
    ./c9-delete.sh
    
    aws ec2 create-tags --resources $C9_ID --tags "Key=Workshop,Value=${WORKSHOP_NAME}Old"

    bootstrap_cdk
    cd cloud9
    echo "Starting cdk destroy..."
    cdk destroy --all --force --context "workshop=$WORKSHOP_NAME"
    echo "Done cdk destroy!"
}