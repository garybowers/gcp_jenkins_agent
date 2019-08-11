all:
	docker build . -t garybowers/gcp_jenkins_agent:latest
	docker tag garybowers/gcp_jenkins_agent:latest garybowers/gcp_jenkins_agent:2.6
	docker push garybowers/gcp_jenkins_agent:latest
	docker push garybowers/gcp_jenkins_agent:2.6
