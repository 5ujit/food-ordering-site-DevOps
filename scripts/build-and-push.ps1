param()

if (-not $Env:DOCKERHUB_USERNAME -or -not $Env:DOCKERHUB_TOKEN) {
    Write-Error "Please set DOCKERHUB_USERNAME and DOCKERHUB_TOKEN environment variables."
    exit 1
}

$image = "$($Env:DOCKERHUB_USERNAME)/food-ordering-site:latest"
Write-Host "Building image $image"
docker build -t $image .

Write-Host "Logging into Docker Hub..."
docker login -u $Env:DOCKERHUB_USERNAME -p $Env:DOCKERHUB_TOKEN

Write-Host "Pushing image..."
docker push $image

Write-Host "Done."
