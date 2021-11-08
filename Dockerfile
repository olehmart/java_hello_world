FROM openjdk:latest

WORKDIR /app

RUN wget http://35.239.122.244:8081/repository/maven-releases/com/coveros/demo/helloworld/1.1/helloworld-1.1.jar -O /app/app.jar

ENTRYPOINT ["java", "-cp", "/app/app.jar", "com.coveros.demo.helloworld.HelloWorld"]
