#!/usr/bin/env bash
set -euo pipefail

# Build local image and push to Docker Hub (requires DOCKERHUB_USERNAME and DOCKERHUB_TOKEN env vars)
IMAGE_NAME="${DOCKERHUB_USERNAME:-yourusername}/food-ordering-site:latest"

if [ -z "${DOCKERHUB_USERNAME:-}" ] || [ -z "${DOCKERHUB_TOKEN:-}" ]; then
  echo "Please set DOCKERHUB_USERNAME and DOCKERHUB_TOKEN environment variables."
  exit 1
fi

echo "Building image ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" .

echo "Logging into Docker Hub..."
echo "${DOCKERHUB_TOKEN}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin

echo "Pushing image..."
docker push "${IMAGE_NAME}"

echo "Done."
