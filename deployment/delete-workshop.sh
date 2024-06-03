#!/bin/bash -x
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

source ./_delete-workshop.sh
echo "Deleting workshop resources"

TRAILS=( "saas-ops-ddb-access-trails" "saas-ops-management-trails" )
STACKS=( "saas-operations-controlplane" "saas-operations-pipeline" "saasOpsWorkshop-tierPerformance" "saasOpsWorkshop-applicationSummary")
CODECOMMIT_REPOS=( "saas-operations-workshop" )

for TRAIL in "${TRAILS[@]}"; do
    stop_cloudtrail "${TRAIL}"
done
delete_tenant_stacks
delete_buckets
for STACK in "${STACKS[@]}"; do
    delete_stack "${STACK}"
done
for REPO in "${CODECOMMIT_REPOS[@]}"; do
    delete_codecommit_repo "${REPO}"
done
delete_log_groups
delete_user_pools
delete_workshop_stacks
delete_api_keys

echo "Workshop deleted"
