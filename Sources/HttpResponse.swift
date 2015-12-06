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

import Foundation

/// Represents a response to an HTTP request.
class HttpResponse: CustomStringConvertible {
    var version = "HTTP/1.1"
    var statusCode = 200
    var statusMessage = "OK"
    var headers: [String: String] = ["Server": "SwiftHTTPServer"]

    private var content: [CChar]?

    var textContent: String? {
        get {
            return content != nil ? String.fromCString(content!) : nil
        }

        set {
            content = newValue?.utf8CString
            contentLength = (content?.count ?? 1) - 1
        }
    }

    var binaryContent: [CChar]? {
        get {
            return content
        }

        set {
            content = newValue
            contentLength = content?.count ?? 0
        }
    }

    /// The content type of the HTTP response.
    var contentType: String {
        get {
            return headers["Content-Type"] ?? ""
        }

        set {
            headers["Content-Type"] = newValue
        }
    }

    // The length (in bytes) of the HTTP response's content.
    var contentLength: Int {
        get {
            return Int(headers["Content-Length"] ?? "0") ?? 0
        }

        set {
            headers["Content-Length"] = newValue.description
        }
    }

    var description: String {
        return "\(version) \(statusCode) \(statusMessage)"
    }

    var descriptionWithHeaders: String {
        var s = description

        for (key, value) in headers {
            s += "\r\n\(key): \(value)"
        }

        return s
    }

    init(version: String, statusCode: Int, statusMessage: String) {
        self.version = version
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }

    init(statusCode: Int, statusMessage: String) {
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }

    static func redirect(location: String) -> HttpResponse {
        let response = HttpResponse(statusCode: 302, statusMessage: "Found")
        response.headers["Location"] = location
        return response
    }

    static func html(statusCode: Int, statusMessage: String, content: String) -> HttpResponse {
        let response = HttpResponse(statusCode: statusCode, statusMessage: statusMessage)
        response.textContent = content
        response.contentType = "text/html; charset=utf-8"
        return response
    }

    static func htmlMessage(statusCode: Int, statusMessage: String, message: String) -> HttpResponse {
        var content = "<!DOCTYPE html>\r\n"
        content += "<html lang=\"en\">\r\n"
        content += "<head>\r\n"
        content += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\r\n"
        content += "<title>\(statusCode)</title>\r\n"
        content += "<style type=\"text/css\">\r\n"
        content += "body { margin: 0; background-color: white; color: black; font-family: Arial, Helvetica, sans-serif; }\r\n"
        content += "h1 { margin: 0; padding: 16px; background-color: #dedede; color: inherit; text-shadow: gray 1px 1px 4px; }\r\n"
        content += "p { margin: 16px; }\r\n"
        content += "</style>\r\n"
        content += "</head>\r\n"
        content += "<body>\r\n\r\n"
        content += "<h1>\(statusCode) \(statusMessage)</h1>\r\n"
        content += "<p>\(message)</p>\r\n\r\n"
        content += "</body>\r\n"
        content += "</html>\r\n"

        return html(statusCode, statusMessage: statusMessage, content: content)
    }

    static func text(statusCode: Int, statusMessage: String, content: String) -> HttpResponse {
        let response = HttpResponse(statusCode: statusCode, statusMessage: statusMessage)
        response.textContent = content
        response.contentType = ContentType.PlainText.rawValue
        return response
    }

    static func fileNotFound(path: String) -> HttpResponse {
        return htmlMessage(404, statusMessage: "File Not Found", message: "The file with the given path could not be found.")
    }

    static func file(filePath: String, withContentType contentType: ContentType? = nil) -> HttpResponse? {
        if let data = NSData(contentsOfFile: filePath) {
            let response = HttpResponse(statusCode: 200, statusMessage: "OK")
            response.contentType = (contentType ?? ContentType.forFile(filePath)).rawValue
            response.contentLength = data.length
            response.content = [CChar](count: data.length, repeatedValue: 0)
            data.getBytes(&response.content!, length: data.length)
            return response
        }

        return nil
    }

    static func template(statusCode: Int, statusMessage: String, contentType: ContentType, template: Template, data: [String: Any]? = nil) -> HttpResponse {
        let response = HttpResponse(statusCode: statusCode, statusMessage: statusMessage)
        response.contentType = contentType.rawValue
        response.textContent = template.render(data ?? [String: Any]())
        return response
    }

    static func template(statusCode: Int, statusMessage: String, template: Template, data: [String: Any]? = nil) -> HttpResponse {
        return HttpResponse.template(statusCode, statusMessage: statusMessage, contentType: ContentType.HTML, template: template, data: data)
    }
}
