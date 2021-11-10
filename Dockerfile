FROM openjdk:latest

WORKDIR /app

ARG APP
ADD ${APP} /app/app.jar

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
