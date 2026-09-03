FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY Main.java .
RUN javac Main.java

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /src/Main.class .
EXPOSE 8080
CMD ["java", "Main"]
