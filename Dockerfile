FROM maven:3.5-jdk-8-alpine AS build
WORKDIR /api-sample-java/
COPY . .
ARG REVISION
RUN mvn --batch-mode -DskipTests -Drevision=${REVISION} clean package
RUN mvn test

FROM openjdk:8-jre-alpine
ARG REVISION
ENV APP_JAR=/usr/share/api-sample-java/app.jar
COPY --from=build /api-sample-java/target/api-sample-java-${REVISION}.jar ${APP_JAR}
EXPOSE 8080
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
