FROM google/dart:2.8 AS dart-runtime

RUN apt-get update

RUN pub global activate webdev

WORKDIR /app
COPY . /app

RUN pub get
RUN pub upgrade

RUN webdev build --release --output web:build

RUN dart2native /app/bin/server/server.dart -o /app/server

FROM frolvlad/alpine-glibc:alpine-3.11_glibc-2.31

COPY --from=dart-runtime /app/server /server
COPY --from=dart-runtime /app/build /build
COPY databases/  databases/

CMD []
ENTRYPOINT ["/server"]