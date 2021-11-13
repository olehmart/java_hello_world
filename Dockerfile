FROM openjdk:latest

USER app-user

WORKDIR /app

ARG APP
ADD ${APP} /app/app.jar

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
