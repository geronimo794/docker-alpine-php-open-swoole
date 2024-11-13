#/bin/bash

######################################
# Build Image
######################################

# Show all command and variable value
set -x

# Load configuration from .env file
set -o allexport

# If .env not exist then use format.env
if [ -f deploy.env ]; then
	source deploy.env
else
	echo "Please populate the deploy.env file from deploy.env.format"
	exit
fi
set +o allexport

# Hide all command and variable value again
set +x

# Build image from Docker file with var $IMAGE_REPO_NAME and tag $IMAGE_TAG
# You can see it from .env configuration
sudo docker build --platform=linux/amd64 --pull --rm -f "$DOCKER_FILE" -t $IMAGE_REPO_NAME:$IMAGE_TAG "."

# Show all list of docker iamge
sudo docker image ls

######################################
# Deploy Image To Private Registry
######################################

# Define full new image name, with registry, namespace, repo
FULL_NEW_IMAGE_NAME=$PRIVATE_REGISTRY/$IMAGE_REPO_NAME:$IMAGE_TAG

# Rename previous image repo with new repo and tag
sudo docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $FULL_NEW_IMAGE_NAME

# Login with saved Personal Access Token and Github Username
# You can configure it via .env file
echo $PRIVATE_REGISTRY_PASSWORD | sudo docker login $PRIVATE_REGISTRY --username $PRIVATE_REGISTRY_USERNAME --password-stdin

# Push the image to github registry
sudo docker push $FULL_NEW_IMAGE_NAME

######################################
# Deploy Image To Github Registry
######################################
# Define full new image name, with registry, namespace, repo
FULL_NEW_IMAGE_NAME=$GITHUB_REGISTRY/$GITHUB_USERNAME/$IMAGE_REPO_NAME:$IMAGE_TAG

# Rename previous image repo with new repo and tag
sudo docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $FULL_NEW_IMAGE_NAME

# Login with saved Personal Access Token and Github Username
# You can configure it via .env file
echo $GITHUB_PAT | sudo docker login $GITHUB_REGISTRY --username $GITHUB_USERNAME --password-stdin

# Push the image to github registry
sudo docker push $FULL_NEW_IMAGE_NAME
