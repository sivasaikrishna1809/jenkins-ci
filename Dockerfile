# ============================
# Stage 1: Build with Maven
# ============================
FROM maven:3.9.4-eclipse-temurin-17 AS build

# Set working directory inside container
WORKDIR /app

# Copy only pom.xml first to cache dependencies
COPY pom.xml .

# Download dependencies to cache them (faster rebuilds)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build the JAR (skip tests for faster build)
RUN mvn clean package -DskipTests

# ============================
# Stage 2: Runtime image
# ============================
FROM eclipse-temurin:17-jre-jammy

# Set working directory
WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port your app will run on
EXPOSE 8080

# Command to run the app
CMD ["java", "-jar", "app.jar"]
