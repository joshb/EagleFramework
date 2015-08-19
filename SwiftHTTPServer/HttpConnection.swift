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
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AS IS'' AND ANY EXPRESS OR
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

private let newlineChar: CChar = 10

/// Represents an HTTP connection from a client. Instances of this class
/// can be used to handle the processing of requests and sending responses.
class HttpConnection: Printable {
    private(set) var fd: Int32
    private(set) var address: Address
    private(set) var port: UInt16

    private var connectionClosedClosure: (HttpConnection) -> ()

    private var lineBuffer: [CChar] = []
    private var lines: [String] = []
    private var readMilliseconds = getMilliseconds()

    /// The number of milliseconds that have elapsed since the connection's socket was last read.
    var millisecondsSinceLastRead: Int {
        return getMilliseconds() - readMilliseconds
    }

    init(fd: Int32, address: Address, port: UInt16, connectionClosedClosure: (HttpConnection) -> ()) {
        self.fd = fd
        self.address = address
        self.port = port
        self.connectionClosedClosure = connectionClosedClosure

        println("\(self): Connection opened")
    }

    /// Closes the connection.
    func close() {
        myClose(fd)
        println("\(self): Connection closed")
        connectionClosedClosure(self)
    }

    /// Sends the given string to the client.
    func send(string: String) {
        let cString = string.cStringUsingEncoding(4)! // UTF-8
        mySend(fd, cString, cString.count - 1)
    }

    /// Sends the given line of text to the client.
    func sendLine(line: String) {
        send(line + "\r\n")
    }

    /// Sends the given response to the client.
    func sendResponse(response: HttpResponse) {
        if response.binaryContent == nil {
            return
        }

        send(response.description)
        mySend(fd, &response.binaryContent!, response.contentLength)
    }

    private func processRequest(request: HttpRequest) {
        println("\(self): Received request: \(request)")

        var response: HttpResponse?
        if let path = request.safeFilePath {
            let filePath = Settings.wwwPath! + "/" + path
            response = HttpResponse.file(filePath)
        }

        sendResponse(response ?? HttpResponse.fileNotFound(request.path))
        close()
    }

    private func processLine(line: String) {
        if line.length == 0 {
            if let request = HttpRequest.parse(lines) {
                processRequest(request)
                lines = []
            }
        } else {
            lines.append(line)
        }
    }

    /// Reads and processes any available data sent by the client.
    func read() {
        var buf = [CChar](count: 512, repeatedValue: 0)
        while true {
            let length = myRecv(fd, &buf, buf.count)
            if length == -1 {
                break
            } else if length == 0 {
                close()
                break
            }

            // Look for newline characters in the received data; if any are found, the
            // line data will be constructed and given to the line processing function.
            var bufStart = 0
            for i in 0..<length {
                let c: CChar = buf[i]
                if c == newlineChar {
                    let lineData = lineBuffer + buf[bufStart..<i] + [0]
                    lineBuffer = []
                    bufStart = i + 1

                    if let line = String.fromCString(lineData) {
                        processLine(line.trimmed)
                    }
                }
            }

            lineBuffer.extend(buf[bufStart..<length])
        }

        readMilliseconds = getMilliseconds()
    }

    var description: String {
        return "\(address) port \(port)"
    }
}
