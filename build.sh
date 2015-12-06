#!/bin/sh

mkdir -p build
cd build

swiftc -import-objc-header ../Sources/Bridging-Header.h -lsqlite3 -o SwiftHTTPServer ../Sources/*.swift
