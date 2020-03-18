workspace=$(shell pwd)
AWS_CLI_IMAGE=csolutions/aws-cli:latest

docker-run-aws-command:
	@docker run --rm \
	-v $(PWD):/jenkins-server \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_SECRET_ACCESS_KEY \
	--env AWS_DEFAULT_REGION \
	${AWS_CLI_IMAGE} $(command)

docker-create-stack:
	@make -s docker-run-aws-command command="aws cloudformation create-stack --stack-name csolutions-ci \
	--template-body file://jenkins-server/jenkins-server.json"

docker-run:
	@docker run -u root -d -p 80:8080 -p 50000:50000 \
	-v $(which docker):/usr/bin/docker \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v csolutions_jenkins_data:/var/jenkins_home \
	--name csolutions-ci --restart always \
	${REPO_NAME}:${TAG}

docker-kill:
	@docker rm -f $$(docker ps -qa --filter name=csolutions-ci)
