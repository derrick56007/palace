FROM google/dart-runtime

WORKDIR /app
COPY . /app

RUN apt-get update

RUN pub global activate webdev

RUN pub get

RUN pub upgrade

RUN webdev build --release --output web:build

CMD []
ENTRYPOINT ["/usr/bin/dart", "/app/bin/server/server.dart"]
