FROM openjdk:latest

WORKDIR /app

ARG APP
ADD ${APP} /app/app.jar

ENTRYPOINT ["java", "-cp", "/app/app.jar", "com.coveros.demo.helloworld.HelloWorld"]
