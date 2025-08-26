#!/bin/bash

# This script finds and copies all Chart-template.yaml files to Chart.yaml,
# then replaces the ${VERSION} placeholder with a hard-coded version.

# --- Configuration ---
# Set the version for the Helm charts
CHART_VERSION="0.1.0"

# Set the target directory to search for charts
# If not provided, it defaults to the current directory
TARGET_DIR="${1:-.}"

echo "Preparing Helm charts in directory: $TARGET_DIR"
echo "Using version: $CHART_VERSION"
echo "---"

# Step 1: Find all Chart-template.yaml files and copy them to Chart.yaml
echo "1. Copying Chart-template.yaml to Chart.yaml..."
find "$TARGET_DIR" -type f -name "Chart-template.yaml" -print0 | while IFS= read -r -d '' template_path; do
    # Determine the target directory and new filename
    chart_dir=$(dirname "$template_path")
    new_chart_path="$chart_dir/Chart.yaml"

    # Copy the file
    cp "$template_path" "$new_chart_path"
    echo "  - Copied $template_path to $new_chart_path"
done

# Step 2: Walk through the newly created Chart.yaml files and replace ${VERSION}
echo "2. Replacing \${VERSION} with $CHART_VERSION in all Chart.yaml files..."
find "$TARGET_DIR" -type f -name "Chart.yaml" -print0 | while IFS= read -r -d '' chart_path; do
    # Use sed to perform the in-place replacement
    sed -i "s/\${VERSION}/$CHART_VERSION/g" "$chart_path"
    echo "  - Updated $chart_path"
done

echo "---"
echo "Script finished successfully. All charts are prepared."