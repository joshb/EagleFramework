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

private var fileContentTypes: [String: String] = [
    "css": "text/css",
    "html": "text/html",
    "txt": "text/plain"
]

extension String {
    func contains(substring: String) -> Bool {
        let range = self.rangeOfString(substring, options: .LiteralSearch, range: nil, locale: nil)
        return range != nil
    }

    var fileContentType: String {
        var parts = self.split(".")
        if let fileExtension = parts.last {
            if let contentType = fileContentTypes[fileExtension.lowercaseString] {
                return contentType
            }
        }

        return "binary/octet-stream"
    }

    var length: Int {
        return count(self)
    }

    func split(delimiter: String) -> [String] {
        return self.componentsSeparatedByString(delimiter)
    }

    func substring(startIndex: Int, length: Int) -> String {
        return self.substringWithRange(Range<String.Index>(start: advance(self.startIndex, startIndex),
                                                           end: advance(self.startIndex, startIndex + length)))
    }

    func substring(startIndex: Int) -> String {
        return self.substringWithRange(Range<String.Index>(start: advance(self.startIndex, startIndex),
                                                           end: self.endIndex))
    }

    static private func isWhitespace(c: String) -> Bool {
        return c == " " || c == "\r" || c == "\n" || c == "\t"
    }

    var trimmed: String {
        var s = self

        while !s.isEmpty && String.isWhitespace(s.substring(0, length: 1)) {
            s = s.substring(1)
        }

        while !s.isEmpty && String.isWhitespace(s.substring(s.length - 1, length: 1)) {
            s = s.substring(0, length: s.length - 1)
        }

        return s
    }
}
