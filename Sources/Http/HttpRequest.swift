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

/// Represents an HTTP request from a client.
public class HttpRequest: CustomStringConvertible {
    public enum Method: String {
        case Delete = "DELETE",
             Get = "GET",
             Head = "HEAD",
             Options = "OPTIONS",
             Post = "POST",
             Put = "PUT"
    }

    public var method: String
    public var path: String
    public var version: String

    public var headers: [String: String] = [:]
    public var postData: String?

    public var safeFilePath: String? {
        if path[path.startIndex] != "/" || path.contains("..") {
            return nil
        }

        return String(path.suffix(from: path.index(after: path.startIndex)))
    }

    // The length (in bytes) of the HTTP request's content.
    public var contentLength: Int {
        get {
            return Int(headers["Content-Length"] ?? "0") ?? 0
        }

        set {
            headers["Content-Length"] = newValue.description
        }
    }

    public var formData: [String: String] {
        var data: [String: String] = [:]
        guard method == Method.Post.rawValue else {
            return data
        }

        if let postData = self.postData {
            data = postData.formData
        }

        return data
    }

    public init(method: String, path: String, version: String) {
        self.method = method
        self.path = path
        self.version = version
    }

    public func path(relativeTo path: String) -> String? {
        if let safePath = safeFilePath {
            return safePath.relativeToPath(path)
        }

        return nil
    }

    public static func parse(lines: [String]) -> HttpRequest? {
        let parts = lines[0].components(separatedBy: " ")
        if parts.count != 3 {
            return nil
        }

        let request = HttpRequest(method: parts[0].trimmed,
                                  path: parts[1].trimmed,
                                  version: parts[2].trimmed)

        // The rest of the lines should be headers.
        for line in lines[1..<lines.count] {
            let headerParts = line.components(separatedBy: ": ")
            if headerParts.count == 2 {
                request.headers[headerParts[0].trimmed] = headerParts[1].trimmed
            }
        }

        return request
    }

    public static func parse(string: String) -> HttpRequest? {
        return parse(lines: string.components(separatedBy: "\n"))
    }

    public var description: String {
        return "\(method) \(path) \(version)"
    }
}
