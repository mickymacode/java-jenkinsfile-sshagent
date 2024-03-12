FROM openjdk:8-jre-alpine

EXPOSE 8080

RUN pwd
COPY ./target/java-maven-app-*.jar .
WORKDIR .
RUN pwd

ENTRYPOINT ["java", "-jar", "java-maven-app-*.jar"]
