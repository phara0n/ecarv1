# Stage 1: Build the Flutter web application
FROM ubuntu:20.04 AS build

# Avoid tzdata prompt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Set Flutter channel to stable
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Copy the app
WORKDIR /app
COPY . .

# Get Flutter dependencies
RUN flutter pub get

# Build for web
RUN flutter build web --release

# Stage 2: Create the runtime image
FROM nginx:alpine

# Copy the build output to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy the nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 