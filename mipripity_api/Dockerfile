FROM dart:stable AS build
WORKDIR /app

COPY pubspec.* ./
RUN dart pub get
COPY . .

RUN dart compile exe bin/server.dart -o bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server
CMD ["/app/bin/server"]
