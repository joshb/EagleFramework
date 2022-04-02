FROM swift:5.6
WORKDIR /EagleFramework
EXPOSE 5000/tcp

# Copy EagleFramework source files to the working directory.
ADD Package.swift .
RUN mkdir Sources
COPY Sources Sources
RUN mkdir Resources
COPY Resources Resources
RUN mkdir www
COPY www www

# Install SQLite.
RUN apt update
RUN apt install libsqlite3-dev

# Build and run.
RUN swift build
ENTRYPOINT ./.build/debug/EagleServer www Resources
