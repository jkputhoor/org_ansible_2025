#!/bin/bash

output_dir="/mnt/details"
timestamp=$(date "+%d%m%Y")
random_suffix=$(date "+%s")
access_output_file="${output_dir}/access_${timestamp}_${random_suffix}.txt"
modify_output_file="${output_dir}/modify_${timestamp}_${random_suffix}.txt"

# Run find command for access time and save output to temporary file
find /packages/ -mindepth 1 -maxdepth 2 -type d -atime +90 -exec du -sh {} \; -exec touch /tmp/dummy.file \; > /tmp/access_output.txt

# Save access time output to file
cp /tmp/access_output.txt "${access_output_file}"

# Run find command for modify time and save output to temporary file
find /packages/ -mindepth 1 -maxdepth 2 -type d -mtime +90 -exec du -sh {} \; > /tmp/modify_output.txt

# Save modify time output to file
cp /tmp/modify_output.txt "${modify_output_file}"

# Cleanup temporary files
rm /tmp/access_output.txt /tmp/modify_output.txt /tmp/dummy.file

