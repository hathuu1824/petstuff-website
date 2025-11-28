# ===== Stage 1: Build WAR bằng Maven =====
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Thư mục làm việc trong container build
WORKDIR /app

# Copy toàn bộ source code vào container
COPY . .

# Build dự án, tạo file .war trong thư mục target/
RUN mvn -B -DskipTests clean package


# ===== Stage 2: Chạy Tomcat + deploy WAR =====
FROM tomcat:10.1-jdk17

# Xoá hết webapps mặc định của Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy file WAR từ stage build sang Tomcat
# Dùng wildcard *.war cho chắc, khỏi cần biết artifactId tên gì
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Mở port 8080 trong container
EXPOSE 8080

# Lệnh start Tomcat
CMD ["catalina.sh", "run"]
