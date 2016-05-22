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
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public extension String {
    private static func ucharToChar(_ c: CUnsignedChar) -> CChar {
        if c < 128 {
            return CChar(c)
        } else {
            return CChar(-128) | CChar(c & 0b01111111)
        }
    }

    /// A UTF-8 C-string representation of the string.
    public var utf8CString: [CChar] {
        return self.nulTerminatedUTF8.map({ String.ucharToChar($0) })
    }

    private var fstatMode: mode_t {
        var fd = open(self.utf8CString, O_RDONLY)
        guard fd != -1 else {
            return 0
        }

        defer {
            close(fd)
        }

        var status = stat()
        guard fstat(fd, &status) != -1 else {
            return 0
        }

        return status.st_mode
    }

    /// Indicates whether or not the string contains the path of a directory.
    public var isDirectory: Bool {
        return (fstatMode & S_IFDIR) != 0
    }

    /// Indicates whether or not the string contains the path of a regular file.
    public var isFile: Bool {
        return (fstatMode & S_IFREG) != 0
    }

    /// If the string contains a path that begins with the given
    /// path, returns a path relative to the given path.
    public func relativeToPath(_ path: String) -> String? {
        let p1 = self.trimmed
        var p2 = path.trimmed

        // Remove any trailing slashes.
        while p2.hasSuffix("/") {
            p2 = p2.substring(to: p2.index(before: p2.endIndex)).trimmed
        }

        if p2.isEmpty && !p1.hasPrefix("/") {
            return p1
        }

        if p1 == p2 {
            return ""
        }

        if !p2.isEmpty && p1.hasPrefix(p2 + "/") {
            return p1.substring(from: p2.length + 1)
        }

        return nil
    }

    /// The string's character count.
    public var length: Int {
        return self.characters.count
    }

    /// Gets a substring of the string.
    ///
    /// - parameter from: The starting index to create the substring from.
    /// - parameter length: The length of the substring.
    /// - returns: A substring from the starting index and with the given length.
    public func substring(from startIndex: Int, length: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(start, offsetBy: length)
        return self.substring(with: Range(uncheckedBounds: (start, end)))
    }

    /// Gets a substring of the string.
    ///
    /// - parameter from: The starting index to create the substring from.
    /// - returns: A substring from the starting index up to the end of the string.
    public func substring(from startIndex: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.endIndex
        return self.substring(with: Range(uncheckedBounds: (start, end)))
    }

    /// Checks whether or not the given character is a whitespace character.
    ///
    /// - parameter c: The character to check.
    /// - returns: true if the character is a whitespace character, false otherwise.
    public static func isWhitespace(_ c: Character) -> Bool {
        return c == " " || c == "\r" || c == "\n" || c == "\r\n" || c == "\t"
    }

    /// A copy of the string with all beginning and trailing whitespace characters removed.
    public var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines())
    }

    /// A copy of the string safe for inclusion in HTML content.
    public var htmlSafe: String {
        let replacements = [
            "<": "&lt;",
            ">": "&gt;",
            "\"": "&quot;"
        ]

        var s = self.replacingOccurrences(of: "&", with: "&amp;")
        for (key, value) in replacements {
            s = s.replacingOccurrences(of: key, with: value)
        }

        return s
    }

    /// A URL-decoded copy of the string.
    public var urlDecoded: String {
        var s1 = ""
        var s2 = self.replacingOccurrences(of: "+", with: " ")

        while let range = s2.range(of: "%") {
            let hexStart = range.upperBound
            let hexEnd = s2.index(hexStart, offsetBy: 2)
            if hexEnd > s2.endIndex {
                break
            }

            var hexInt: UInt32 = 0
            let hex = s2.substring(with: Range(uncheckedBounds: (hexStart, hexEnd)))
            let scanner = NSScanner(string: hex)
#if os(Linux)
            let result = scanner.scanHexInt(&hexInt)
#else
            let result = scanner.scanHexInt32(&hexInt)
#endif
            if !result {
                break
            }

            s1 += s2.substring(with: Range(uncheckedBounds: (s2.startIndex, range.lowerBound)))
            s1 += String(UnicodeScalar(hexInt))
            s2 = s2.substring(with: Range(uncheckedBounds: (hexEnd, s2.endIndex)))
        }

        return s1 + s2
    }

    /// A dictionary containing form data in the string.
    public var formData: [String: String] {
        var result: [String: String] = [:]

        for pairString in self.components(separatedBy: "&") {
            let pair = pairString.components(separatedBy: "=")
            if pair.count != 2 {
                continue
            }

            result[pair[0]] = pair[1].urlDecoded
        }

        return result
    }
}
