all:
	docker build . -t garybowers/gcp_jenkins_agent:latest
	docker push garybowers/gcp_jenkins_agent:latest
