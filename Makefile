all: build push

build:
	docker build . -t garybowers/gcp_jenkins_agent:latest

push:
	docker tag garybowers/gcp_jenkins_agent:latest garybowers/gcp_jenkins_agent:2.10
	docker push garybowers/gcp_jenkins_agent:latest
	docker push garybowers/gcp_jenkins_agent:2.10
