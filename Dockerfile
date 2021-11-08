FROM openjdk:latest

WORKDIR /app

ARG JAR_FILE
ADD ${JAR_FILE} /app/app.jar

ENTRYPOINT ["java", "-cp", "/app/app.jar", "com.coveros.demo.helloworld.HelloWorld"]
