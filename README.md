Swift HTTP Server
=================

This is a small and simple HTTP server that's written in Swift. Rather than being a full-featured, general purpose web server, it is intended to be easily extensible and usable as part of web applications written in Swift; as such, it implements only a subset of standard HTTP server features that are necessary to that end.

It's still in very early stages of development. Currently implemented features include:

 - Handling multiple connections simultaneously
 - Serving static content (such as HTML and CSS files)
 - A simple template engine that can be used to embed values from a dictionary in rendered output

This software was developed by [Josh Beam](http://joshbeam.com/) and is distributed under the BSD-style license shown at the bottom of this file.

Supported Platforms
-------------------
This software currently only runs on Mac OS X. The plan is to port it to Linux after the [open source Swift release](https://developer.apple.com/swift/blog/?id=29) has happened, at which point it will be able to run on a wide range of Linux server offerings. Until then, though, it can be useful for people with Mac-based servers, whether they be self-hosted or hosted through a service such as [macminicolo](http://www.macminicolo.net/) or [MacStadium](http://www.macstadium.com/).

Usage
-----
Open SwiftHTTPServer.xcodeproj in Xcode 7.0 or greater. Press ⌘R to build and run the server. By default, it binds to localhost (preferring IPv6 to IPv4) on port 5000, and serves the files stored in the [www](https://github.com/joshb/SwiftHTTPServer/tree/master/www) directory. If you have the server running, go to [http://localhost:5000/index.html](http://localhost:5000/index.html) to see the welcome page. When you're done, just hit ⌘. in Xcode to stop the server.

License
-------
Copyright © 2015 Josh A. Beam  
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
