/*
 * Copyright (C) 2015 Josh A. Beam
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Network

private let newlineChar: CChar = 10

/// Represents an HTTP connection from a client. Instances of this class
/// can be used to handle the processing of requests and sending responses.
public class HttpConnection: ServerConnection {
    private var lineBuffer: [CChar] = []
    private var lines: [String] = []
    private var requestAwaitingPostData: HttpRequest?

    override public init(descriptor: Descriptor, localEndpoint: Endpoint, remoteEndpoint: Endpoint) {
        super.init(descriptor: descriptor, localEndpoint: localEndpoint, remoteEndpoint: remoteEndpoint)
    }

    /// Sends the given response to the client.
    public func sendResponse(_ response: HttpResponse) {
        send(string: response.descriptionWithHeaders + "\r\n\r\n")

        if let binaryContent = response.binaryContent {
            send(data: binaryContent)
        }
    }

    private func processRequest(_ request: HttpRequest) {
        print("\(self) request: \(request)")

        let response = ResponderRegistry.respond(request)
        print("\(self) response: \(response)")
        sendResponse(response)

        shouldClose = true
    }

    private func processLine(_ line: String) {
        if let request = requestAwaitingPostData {
            request.postData = line
            processRequest(request)
            requestAwaitingPostData = nil
            lines = []
        } else if line.length == 0 {
            if let request = HttpRequest.parse(lines) {
                if request.method == "POST" {
                    requestAwaitingPostData = request
                } else {
                    processRequest(request)
                }
                lines = []
            }
        } else {
            lines.append(line)
        }
    }

    /// Reads and processes any available data sent by the client.
    public func handleRead() {
        let buf = readData()

        // Look for newline characters in the received data; if any are found, the
        // line data will be constructed and given to the line processing function.
        var bufStart = 0
        for i in 0..<buf.count {
            let c: CChar = buf[i]
            if c == newlineChar {
                let lineData = lineBuffer + buf[bufStart..<i] + [0]
                lineBuffer = []
                bufStart = i + 1

                let line = String(cString: lineData)
                processLine(line.trimmed)
            }
        }

        lineBuffer.append(contentsOf: buf[bufStart..<buf.count])

        // If we're waiting for a request's post data and the line buffer
        // length is equal to the content length, then we can go ahead
        // and process the contents of the line buffer.
        if let request = requestAwaitingPostData {
            if lineBuffer.count >= request.contentLength {
                let lineData = lineBuffer + [0]
                let line = String(cString: lineData)
                processLine(line.trimmed)
            }
        }
    }
}
