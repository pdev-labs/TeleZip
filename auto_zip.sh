#!/bin/bash

# Auto-install zip if missing
if ! command -v zip &> /dev/null; then
    echo "zip command not found. Attempting to install..."
    if command -v pkg &> /dev/null; then
        # Termux
        pkg install -y zip
    elif command -v apt &> /dev/null; then
        # Debian/Ubuntu
        sudo apt update && sudo apt install -y zip
    elif command -v brew &> /dev/null; then
        # macOS
        brew install zip
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        sudo pacman -Sy --noconfirm zip
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y zip
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum install -y zip
    else
        echo "Could not find a supported package manager (pkg, apt, brew, pacman, dnf, yum)."
        echo "Please install 'zip' manually."
        exit 1
    fi
fi

# Get parent directory from argument or prompt
if [ -z "$1" ]; then
    # -e enables readline, allowing tab autocompletion for paths
    read -e -p "Enter the path of the parent folder: " parent_dir
else
    parent_dir="$1"
fi

# Resolve ~ and get absolute path
parent_dir=$(eval echo "$parent_dir")
if command -v realpath &> /dev/null; then
    parent_dir=$(realpath "$parent_dir")
else
    # Fallback for systems without realpath (like some older macOS)
    parent_dir=$(cd "$parent_dir" 2>/dev/null && pwd)
fi

if [ ! -d "$parent_dir" ]; then
    echo "Error: Directory '$parent_dir' does not exist."
    exit 1
fi

parent_name=$(basename "$parent_dir")
output_dir="$parent_dir/${parent_name}-zip"

echo "Output directory: $output_dir"
mkdir -p "$output_dir"

# Navigate to parent directory to make zip paths relative to it
cd "$parent_dir" || { echo "Failed to access $parent_dir"; exit 1; }

shopt -s nullglob # Ensure loop doesn't execute if no directories match
found_dirs=0

for sub in */; do
    # Skip the output directory itself
    if [ "$sub" = "${parent_name}-zip/" ]; then
        continue
    fi
    
    found_dirs=1
    # Remove trailing slash
    sub_name="${sub%/}"
    
    echo "Zipping '$sub_name'..."
    zip -r "$output_dir/${sub_name}.zip" "$sub_name"
done

if [ $found_dirs -eq 0 ]; then
    echo "No subfolders found in '$parent_dir'."
else
    echo "Done! All zip files are saved in:"
    echo "  -> $output_dir"
fi
