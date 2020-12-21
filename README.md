Eagle Framework
===============

Eagle Framework is a small and simple framework for creating network servers and web applications. Rather than being a full-featured, general purpose web server, it is intended to be easily extensible and usable as part of web applications written in Swift; as such, it implements only a subset of standard HTTP server features that are necessary to that end.

Currently implemented features include:

 - Handling multiple connections simultaneously
 - Serving static content (such as HTML and CSS files)
 - A simple template engine that can be used to embed values from a dictionary in rendered output

This software was developed by [Josh Beam](https://joshbeam.com/) and is distributed under a [BSD-style license](LICENSE).

Supported Platforms
-------------------
This software has been developed and tested on macOS Big Sur and Ubuntu 20.04. It can be built using [Swift 5.3](https://swift.org/download/) with the Swift package manager.

Usage
-----
Run the following commands from the EagleFramework root directory to build and run the example web server application:

    swift build
    ./.build/debug/EagleServer www Resources

By default, the server binds to localhost (both IPv4 and IPv6) on port 5000, and serves the files stored in the directory given after the executable path (in the above example, this is the [www](https://github.com/joshb/EagleServer/tree/master/www) directory). The Resources directory given last can contain files used by the server that are not served by default like the files in the www directory. If you have the server running, go to http://localhost:5000/index.html to see the welcome page. When you're done, just hit Ctrl-C to stop the server.
