FROM instrumentisto/flutter:3.27

WORKDIR /app

COPY ./app/. .

RUN dart pub global activate dhttpd
RUN flutter pub get
RUN flutter build web

EXPOSE 8080

CMD ["dart", "pub", "global", "run", "dhttpd", "--path", "build/web/", "--port", "8080", "--host", "0.0.0.0"]
