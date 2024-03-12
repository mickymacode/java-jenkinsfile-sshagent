FROM openjdk:8-jre-alpine

EXPOSE 8080

COPY target/java-maven-app-*.jar java-maven-app.jar

ENTRYPOINT ["java", "-jar", "java-maven-app.jar"]
