<h3>Porject Notes:</h3>

Docker is installed on the host machine

1.  Run a Docker container with the latest Jenkins image(Jenkins Container) & Mount the Docker into the container:

         docker run -p 8080:8080 -p 5000:5000 -d \
         -v jenkins_home:/var/jenkins_home \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -v $(which docker):/usr/bin/docker \
         jenkins/jenkins:lts

2.  Use ROOT user login container:

         docker exec -u 0 -it <ContainerId> bash

         chmod 666 /var/run/docker.sock

(rw premission for all users, so 'jenkins' user has permission to access docker.sock)

3.  To access jenkins page: localhost:8080

4.  Build pipeline for project, connect Github with jenkis using Credentials

5.  In Jenkins Manage Jenkis -> System, Setup the Global Pipeline Libraries for the use of @Library()

         Name: jenkins-shared-libraries

         Default version: master

         Choose: Modern SCM

         Source Code Management: Git

         Project Repository & Credentials

6.  jenkins page: localhost:8080 can't be used to set up Webhook in Github (push not trigger pipeline), so:

    6.1 expose the localhost:8080 to a public ip using 'ngrok':

          ngrok http http://localhost:8080

    (got the endpoint: https://xxxxxxxxxxxxxx.ngrok-free.app)

    Once ngrok stop(terminal closed, the public ip will not work)

    6.2 add Webhook in Github repository:

    Playload URL: https://xxxxxxxxxxxxxx.ngrok-free.app/github-webhook/

    Content type: application/json

7.  The jenkins pipline run and an AWS instance will be provisioned,

The 'java-maven-app' and 'postgres' 2 containers are successfully running

browser: ec2 instance public ip:8080 open the jave-maven-app page
