FROM openjdk:latest

WORKDIR /app

ARG APP
ADD ${APP} /app/app.jar

ENV JAR_OPTS=""
ENV JAVA_OPTS=""
ENTRYPOINT exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app/app.jar $JAR_OPTS
