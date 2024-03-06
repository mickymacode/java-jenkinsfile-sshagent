Docker is installed on the host machine

1. Run a Docker container with the latest Jenkins image(Jenkins Container) & Mount the Docker into the container
    docker run -p 8080:8080 -p 5000:5000 -d \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(which docker):/usr/bin/docker \
    jenkins/jenkins:lts
2. Use ROOT user login container
   docker exec -u 0 -it <ContainerId> bash
   chmod 666 /var/run/docker.sock (rw premission for all users, so 'jenkins' user has permission to access docker.sock)
3. To access jenkins page: localhost:8080 
