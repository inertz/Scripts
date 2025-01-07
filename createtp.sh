#!/bin/bash
#test push 7-1-1025

# List available OS templates
echo "Available OS templates:"
# Run below command to show all OS template 
#virt-builder -l
# Run below command to show only selected OS template
virt-builder -l | grep -E 'alma-8.5|centos-7.8|centos-8.2|debian-12|ubuntu-20.04|fedora-32'

# Prompt the user for the OS name
read -p "Enter the OS name (e.g., alma-8.5): " os_name

# Prompt the user for the root password
read -p "Enter the root password: " root_password

# Construct the virt-builder command
#virt_builder_command="virt-builder $os_name --format qcow2 --size 20G -o /var/lib/libvirt/images/${os_name}.qcow2 --root-password password:${root_password}"
virt_builder_command="virt-builder $os_name --format qcow2 -o /var/lib/libvirt/images/${os_name}.qcow2 --root-password password:${root_password}"

# Execute the virt-builder command
echo "Executing the following command:"
echo "$virt_builder_command"
eval "$virt_builder_command"

echo "Virtual machine image created."
