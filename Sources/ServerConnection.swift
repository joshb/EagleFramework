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

/// Represents a connection to the server.
class ServerConnection: CustomStringConvertible {
    var shouldClose = false

    private(set) var descriptor: Descriptor
    private(set) var localEndpoint: Endpoint
    private(set) var remoteEndpoint: Endpoint

    init(descriptor: Descriptor, localEndpoint: Endpoint, remoteEndpoint: Endpoint) {
        self.descriptor = descriptor
        self.localEndpoint = localEndpoint
        self.remoteEndpoint = remoteEndpoint
    }

    func readData(length: Int? = nil) -> [CChar] {
        var buf = [CChar](count: length ?? 512, repeatedValue: 0)
        let len = recv(descriptor, &buf, buf.count, 0)
        guard len > 0 else {
            shouldClose = true
            return []
        }

        return buf
    }

    func readString() -> String {
        var data = readData()
        guard data.count != 0 else {
            return ""
        }

        data.append(CChar(0))
        return String.fromCString(data) ?? ""
    }

    func sendData(data: [CChar]) -> Int {
        return send(descriptor, data, data.count, 0)
    }

    func sendString(str: String) -> Int {
        let data = str.utf8CString
        return send(descriptor, data, data.count - 1, 0)
    }

    func sendLine(line: String) -> Int {
        return sendString(line + "\n")
    }

    var description: String {
        return "Connection from \(remoteEndpoint) to \(localEndpoint)"
    }
}
