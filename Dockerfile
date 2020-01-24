FROM google/dart-runtime

RUN pub global activate webdev
RUN webdev build --release --output web:build

CMD []
ENTRYPOINT ["/usr/bin/dart", "bin/server/server.dart"]