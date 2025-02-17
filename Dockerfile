# Install Operating system and dependencies
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3
RUN apt-get clean

ENV DEBIAN_FRONTEND=dialog
# ENV PUB_HOSTED_URL=https://pub.flutter.io
# ENV FLUTTER_STORAGE_BASE_URL=https://storage.flutter.io

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Enable flutter web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY ./app/. /app/
WORKDIR /app/

RUN flutter pub get
RUN flutter build web
RUN dart compile exe bin/server.dart -o build/server

ENV HOST=0.0.0.0
ENV PORT=8181

EXPOSE 8181

CMD ["./build/server"]
