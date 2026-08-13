FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /build
COPY gradlew gradlew.bat settings.gradle build.gradle ./
COPY gradle gradle
COPY libs libs
COPY src src
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew
RUN ./gradlew bootJar --no-daemon

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /build/build/libs/hotelio-booking-service-1.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]