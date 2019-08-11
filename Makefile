all:
	docker build . -t garybowers/gcp_jenkins_agent:latest
	docker tag garybowers/gcp_jenkins_agent:latest garybowers/gcp_jenkins_agent:3.0
	docker push garybowers/gcp_jenkins_agent:latest
	docker push garybowers/gcp_jenkins_agent:3.0

build:
	docker build . -t ${IMG_NAME}:${BUILD_NUMBER}

tag:
	docker tag ${IMG_NAME}:${BUILD_NUMBER} ${IMG_NAME}:${VERSION}

push:
	docker push ${IMG_NAME}:${VERSION}
