#!/bin/bash

# Define the APT sources directory
sources_dir="/etc/apt/sources.list.d/"

# List all files in the sources directory
files=$(ls "$sources_dir")

# Initialize an array to store unique repository URLs
unique_urls=()

# Loop through each file in the sources directory
for file in $files; do
    file_path="$sources_dir$file"
    
    # Check if the file exists and is a regular file
    if [ -f "$file_path" ]; then
        while read -r line; do
            # Check if the line is not empty and is not a comment
            if [[ ! -z "$line" && "$line" != \#* ]]; then
                # Check if the URL is not already in the unique_urls array
                if ! [[ " ${unique_urls[@]} " =~ " $line " ]]; then
                    unique_urls+=("$line")
                fi
            fi
        done < "$file_path"
    fi
done

# Remove all files in the sources directory
rm -f "$sources_dir"*

# Write the unique URLs back to separate files in the sources directory
for url in "${unique_urls[@]}"; do
    echo "$url" | sudo tee -a "$sources_dir$(echo "$url" | md5sum | cut -d ' ' -f 1).list" > /dev/null
done

# Update the APT package cache
sudo apt update

# Optionally, upgrade packages if updates are available
# sudo apt upgrade

echo "Duplicate entries have been removed and APT has been updated."
