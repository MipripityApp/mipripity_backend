# Use Dart's official image
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy all source code
COPY . .

# Compile to kernel snapshot
RUN dart compile exe bin/main.dart -o bin/server

# Build minimal serving image from AOT-compiled snapshot
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server
CMD ["/app/bin/server"]
