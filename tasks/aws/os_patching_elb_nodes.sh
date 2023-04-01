#!/bin/bash

# Set AWS profile and region
export AWS_PROFILE=<your-aws-profile>
export AWS_REGION=<your-aws-region>

# Get target groups with more than 2 nodes
target_groups=$(aws elbv2 describe-target-groups --query "TargetGroups[?length(Targets) > `2`].TargetGroupArn" --output text)

for target_group in $target_groups; do
  # Get target health
  target_health=$(aws elbv2 describe-target-health --target-group-arn $target_group --query "TargetHealthDescriptions[].{Id: Target.Id, State: TargetHealth.State}")

  # Check if there's a healthy node
  healthy_node=$(echo $target_health | jq '.[] | select(.State=="healthy") | .Id' -r)

  if [ -n "$healthy_node" ]; then
    # Get instance ID of the node to be patched
    instance_to_patch=$(echo $target_health | jq '.[] | select(.Id != '\"$healthy_node\"') | .Id' -r)

    # Execute patch baseline on the instance
    patch_result=$(aws ssm send-command --instance-ids $instance_to_patch --document-name "AWS-RunPatchBaseline" --output text)

    # Get the command ID to check the command status later
    command_id=$(echo $patch_result | awk '{print $4}')

    # Wait until the patching process is complete
    aws ssm wait command-executed --instance-id $instance_to_patch --command-id $command_id

    # Check if reboot is necessary
    reboot_needed=$(aws ssm list-inventory-entries --instance-id $instance_to_patch --type-name "AWS:InstanceInformation" --filters "Key=RebootOption,Values=RebootIfNeeded" --query "Entries[0].InstanceId" --output text)

    if [ "$reboot_needed" == "$instance_to_patch" ]; then
      # Reboot the instance
      aws ec2 reboot-instances --instance-ids $instance_to_patch
    fi

    # Wait until the instance is in a healthy state
    while true; do
      current_health=$(aws elbv2 describe-target-health --target-group-arn $target_group --targets Id=$instance_to_patch --query "TargetHealthDescriptions[].TargetHealth.State" --output text)
      if [ "$current_health" == "healthy" ]; then
        break
      fi
      sleep 30
    done
  fi
done
