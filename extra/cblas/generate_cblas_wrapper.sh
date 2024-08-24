#!/bin/bash

# Set the Docker image name
IMAGE_NAME="pycparser"

# Build the Docker image quietly, suppressing output
echo "Building Docker image..."
docker build -q -t $IMAGE_NAME .

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Docker build failed. Exiting."
    exit 1
fi

# Run the Docker container, suppress output, and pipe the script output into a file
OUTPUT_FILE="cblas.mojo"
echo "Running Docker container and generating code..."
docker run --rm -v "$(pwd)":/app/workspace $IMAGE_NAME /app/venv/bin/python3 /app/workspace/generate_mojo.py >$OUTPUT_FILE

# Check if the script ran successfully
if [ $? -ne 0 ]; then
    echo "Docker run failed. Exiting."
    exit 1
fi

echo "Code generated and saved to $OUTPUT_FILE."
