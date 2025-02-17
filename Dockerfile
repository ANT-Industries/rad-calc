FROM instrumentisto/flutter:3.27

WORKDIR /app

COPY ./app/. .

RUN flutter pub get
RUN flutter build web
RUN dart compile exe bin/server.dart -o build/server

ENV PORT=8080
ENV HOST=0.0.0.0

EXPOSE 8080

CMD ["./build/server"]
