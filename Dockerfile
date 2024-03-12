FROM openjdk:8-jre-alpine

EXPOSE 8080

RUN ls -lah /usr/app

COPY ./target/java-maven-app-*.jar /usr/app/
WORKDIR /usr/app

ENTRYPOINT ["java", "-jar", "java-maven-app-*.jar"]
