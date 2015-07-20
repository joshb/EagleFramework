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

import Foundation

/// Represents an HTTP request from a client.
class HttpRequest: Printable {
    var method: String
    var path: String
    var version: String

    var headers: [String: String] = [:]

    var safeFilePath: String? {
        if path[path.startIndex] != "/" || path.contains("..") {
            return nil
        }

        return path.substring(1)
    }

    init(method: String, path: String, version: String) {
        self.method = method
        self.path = path
        self.version = version
    }

    static func parse(lines: [String]) -> HttpRequest? {
        let parts = lines[0].split(" ")
        if parts.count != 3 {
            return nil
        }

        var request = HttpRequest(method: parts[0].trimmed,
                                  path: parts[1].trimmed,
                                  version: parts[2].trimmed)

        // The rest of the lines should be headers.
        for line in lines[1..<lines.count] {
            let headerParts = line.split(": ")
            if headerParts.count == 2 {
                request.headers[headerParts[0].trimmed] = headerParts[1].trimmed
            }
        }

        return request
    }

    static func parse(str: String) -> HttpRequest? {
        return parse(str.split("\n"))
    }

    var description: String {
        return "\(method) \(path) \(version)"
    }
}
