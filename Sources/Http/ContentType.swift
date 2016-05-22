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

public enum ContentType: String {
    case Default = "binary/octet-stream"
    case CSS = "text/css"
    case GIF = "image/gif"
    case HTML = "text/html; charset=utf-8"
    case JavaScript = "application/javascript"
    case JPEG = "image/jpeg"
    case PlainText = "text/plain"
    case PNG = "image/png"

    private static var fileContentTypes: [String: ContentType] = [
        "css": .CSS,
        "gif": .GIF,
        "html": .HTML,
        "js": .JavaScript,
        "jpeg": .JPEG,
        "jpg": .JPEG,
        "png": .PNG,
        "txt": .PlainText
    ]

    public static func forFile(withPath filePath: String) -> ContentType {
        let parts = filePath.components(separatedBy: ".")
        if let fileExtension = parts.last {
            if let contentType = fileContentTypes[fileExtension.lowercased()] {
                return contentType
            }
        }

        return Default
    }
}
