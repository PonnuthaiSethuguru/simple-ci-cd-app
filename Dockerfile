# Use a lightweight Java 21 runtime
FROM eclipse-temurin:21-jre-alpine

# Set the directory inside the container
WORKDIR /app

# Copy the .jar file from your Gradle build output
# In a standard Gradle project, the jar is in app/build/libs/
COPY app/build/libs/*.jar app.jar

# Expose the port your app runs on
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
