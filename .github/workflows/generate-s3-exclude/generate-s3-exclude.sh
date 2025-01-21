#!/bin/bash
pwd

ls -alF
# Path to the text file containing files/directories to exclude
exclude_file="./exclude.txt"

# Initialize an empty string for the exclusions
exclude_args=""

# Check if the exclude file exists
if [[ ! -f "$exclude_file" ]]; then
  echo "Error: Exclude file '$exclude_file' not found."
  exit 1
fi

# Read each line from the exclude file
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines or lines that start with a hash (#, used for comments)
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  # Add the line as a --exclude argument
  exclude_args+="--exclude \"$line\" "
done < "$exclude_file"

# Output the exclude arguments
echo "$exclude_args"
