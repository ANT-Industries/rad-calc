FROM ghcr.io/cirruslabs/flutter:3.35.0

COPY . /app
WORKDIR /app

RUN flutter pub get
RUN flutter build web
RUN dart compile exe bin/server.dart -o build/server

ENV HOST=0.0.0.0
ENV PORT=8181

EXPOSE 8181

CMD ["./build/server"]
