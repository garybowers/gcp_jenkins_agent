all:
	docker build . -t garybowers/gcp_jenkins_agent:latest
	docker tag garybowers/gcp_jenkins_agent:latest garybowers/gcp_jenkins_agent:3.0
	docker push garybowers/gcp_jenkins_agent:latest
	docker push garybowers/gcp_jenkins_agent:3.0
