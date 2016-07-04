Eagle Framework
===============

The Eagle Framework is a small and simple framework for creating network servers and web applications. Rather than being a full-featured, general purpose web server, it is intended to be easily extensible and usable as part of web applications written in Swift; as such, it implements only a subset of standard HTTP server features that are necessary to that end.

It's still in very early stages of development. Currently implemented features include:

 - Handling multiple connections simultaneously
 - Serving static content (such as HTML and CSS files)
 - A simple template engine that can be used to embed values from a dictionary in rendered output

This software was developed by [Josh Beam](https://github.com/joshb) and is distributed under the BSD-style license shown at the bottom of this file.

Supported Platforms
-------------------
This software has been developed and tested on Mac OS X El Capitan and Ubuntu 15.10 (x86-64). It can be built using [Swift 3.0](https://swift.org/download/) with the Swift package manager.

Usage
-----
Make sure that you have a recent Swift Development snapshot installed, and run the following commands from the EagleFramework root directory to build and run the example web server application:

    swift build
    .build/debug/EagleServer www Resources

By default, the server binds to localhost (both IPv4 and IPv6) on port 5000, and serves the files stored in the directory given after the executable path (in the above example, this is the [www](https://github.com/joshb/EagleServer/tree/master/www) directory). The Resources directory given last can contain files used by the server that are not served by default like the files in the www directory. If you have the server running, go to http://localhost:5000/ to see the welcome page. When you're done, just hit Ctrl-C to stop the server.

License
-------
Copyright © 2015-2016 Josh A. Beam  
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
