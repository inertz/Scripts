#!/bin/bash

# Define the current date and time
currentdatetime=$(date +'%Y-%m-%d-%H:%M')

# Get the list of running virtual machines
vm_list=$(virsh list --state-running --name)

# Loop through each VM and create a snapshot
for vm_name in $vm_list; do
    # Create a snapshot for the VM
    virsh snapshot-create-as --domain "$vm_name" --name "$vm_name $currentdatetime" --description "Snapshot of $vm_name at $currentdatetime"

    # Get the snapshot location
    # snapshot_location=$(virsh snapshot-list --domain "$vm_name" | awk -F' ' '/[0-9]+[[:space:]]+.*'"$currentdatetime"'/ {print $3}')

    # Display the snapshot location
    # echo "Snapshot for $vm_name created at: $snapshot_location"
done
