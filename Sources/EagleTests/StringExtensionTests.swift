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

import Base

class StringExtensionTests: TestCase {
    override var tests: TestDictionary {
        return [
            "testRelativeToPath": {
                try assertNil("/tmp/test.txt".relativeToPath("/usr"))
                try assertNil("/tmp/test.txt".relativeToPath(""))
                try assertEqual("/tmp".relativeToPath("/tmp"), "")
                try assertEqual("/tmp/".relativeToPath("/tmp"), "")
                try assertEqual("/tmp/test.txt".relativeToPath("/tmp"), "test.txt")
                try assertEqual("/tmp/test.txt".relativeToPath("/tmp/"), "test.txt")
                try assertEqual("index.html".relativeToPath(""), "index.html")
            },

            "testLength": {
                try assertEqual("".length, 0)
                try assertEqual("Hello, world!".length, 13)
            },

            "testSubstring": {
                try assertEqual("Hello, world!".substring(from: 7, length: 5), "world")
                try assertEqual("0123".substring(from: 1), "123")
            },

            "testIsWhitespace": {
                try assertEqual(String.isWhitespace("\t"), true)
                try assertEqual(String.isWhitespace("\r"), true)
                try assertEqual(String.isWhitespace("\n"), true)
                try assertEqual(String.isWhitespace("\r\n"), true)
                try assertEqual(String.isWhitespace(" "), true)
                try assertEqual(String.isWhitespace("a"), false)
            },

            "testTrimmed": {
                let s1 = " \t  \r\ntest  \n\t \r  \r\n"
                let s2 = "test"

                try assertEqual(s1.trimmed, s2)
            },

            "testHtmlSafe": {
                let s1 = "\"<i>Hello & good morning, world!</i>\""
                let s2 = "&quot;&lt;i&gt;Hello &amp; good morning, world!&lt;/i&gt;&quot;"

                try assertEqual(s1.htmlSafe, s2)
            },

            "testUrlDecoded": {
                let s1 = "Hello%2c+world%21"
                let s2 = "Hello, world!"

                try assertEqual(s1.urlDecoded, s2)
            },

            "testFormData": {
                let s = "title=Good%20morning&body=Hello%2c+world%21"
                let formData = ["title": "Good morning",
                                "body": "Hello, world!"]

                try assertEqual(s.formData, formData)
            }
        ]
    }
}
