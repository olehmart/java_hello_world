FROM openjdk:latest

WORKDIR /app

COPY target/helloworld-1.1.jar /app/

ENTRYPOINT ["java", "-cp", "/app/helloworld-1.1.jar", "com.coveros.demo.helloworld.HelloWorld"]
