#!/bin/bash
az login

# Variables
newUserEmail="newuser@example.com"
roleDefinitionName="Contributor"
subscriptionId="<Your Subscription ID>"

# Create the new user
newUser=$(az ad user create --display-name "New User" --user-principal-name $newUserEmail --password "P@ssw0rd" --force-change-password-next-login --output json)

# Get the new user's Object ID
newUserObjectId=$(echo $newUser | jq '.objectId' -r)

# Assign the role to the new user
az role assignment create --assignee-object-id $newUserObjectId --role $roleDefinitionName --scope "/subscriptions/$subscriptionId"
