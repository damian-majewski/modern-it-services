#!/bin/bash
# Make sure to replace the variables with your actual values (RESOURCE_GROUP, AUTOMATION_ACCOUNT, VM_NAME, WORKSPACE_NAME, LOCATION, and <subscription_id>). The script sets up a weekly update schedule, but you can adjust the schedule as needed. The duration of the update deployment is set to 2 hours (PT2H). If you need a longer or shorter duration, modify the value accordingly.

# Note that you'll need to enable the Update Management solution for each VM you want to manage. You can automate this step by iterating through all the VMs in your resource group or subscription and applying the az automation update-management enable command to each VM.

# Variables
RESOURCE_GROUP="your_resource_group"
AUTOMATION_ACCOUNT="your_automation_account"
VM_NAME="your_vm_name"
WORKSPACE_NAME="your_log_analytics_workspace"
LOCATION="your_location"

# Create the resource group if it doesn't exist
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create the Log Analytics workspace if it doesn't exist
az monitor log-analytics workspace create --resource-group $RESOURCE_GROUP --workspace-name $WORKSPACE_NAME --location $LOCATION

# Get the workspace ID and primary key
WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group $RESOURCE_GROUP --workspace-name $WORKSPACE_NAME --query customerId --output tsv)
PRIMARY_KEY=$(az monitor log-analytics workspace get-shared-keys --resource-group $RESOURCE_GROUP --workspace-name $WORKSPACE_NAME --query primarySharedKey --output tsv)

# Create the automation account if it doesn't exist
az automation account create --name $AUTOMATION_ACCOUNT --resource-group $RESOURCE_GROUP --location $LOCATION

# Link the automation account to the Log Analytics workspace
az automation account link --name $AUTOMATION_ACCOUNT --resource-group $RESOURCE_GROUP --workspace-name $WORKSPACE_NAME

# Enable Update Management for the VM
az automation update-management enable --name $AUTOMATION_ACCOUNT --resource-group $RESOURCE_GROUP --workspace $WORKSPACE_ID --vm-id "/subscriptions/<subscription_id>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME"

# Deploy the Log Analytics agent to the VM
az vm extension set --publisher Microsoft.EnterpriseCloud.Monitoring --name OmsAgentForLinux --resource-group $RESOURCE_GROUP --vm-name $VM_NAME --settings "{'workspaceId': '$WORKSPACE_ID'}" --protected-settings "{'workspaceKey': '$PRIMARY_KEY'}"

# Schedule the update deployment
az automation schedule create --name "WeeklyPatching" --resource-group $RESOURCE_GROUP --automation-account-name $AUTOMATION_ACCOUNT --frequency "Week" --interval 1 --start-time "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" --time-zone "UTC"

az automation update-management create --name "UpdateDeployment" --resource-group $RESOURCE_GROUP --automation-account-name $AUTOMATION_ACCOUNT --duration "PT2H" --schedule-name "WeeklyPatching" --target-azure-query "{'Scope': ['/subscriptions/<subscription_id>/resourceGroups/$RESOURCE_GROUP'], 'Query': \"select * where type =~ 'microsoft.compute/virtualmachines'\", 'Top': 5000}"
