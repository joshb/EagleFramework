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

import XCTest

class SwiftHTTPServerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReplace() {
        XCTAssertEqual("hi".replace("hi", withString: "hello"), "hello")
    }

    func testSplit() {
        XCTAssertEqual("a,b,c".split(","), ["a", "b", "c"])
    }

    func testSubstring() {
        XCTAssertEqual("Hello, world!".substring(7, length: 5), "world")
        XCTAssertEqual("0123".substring(1), "123")
    }

    func testTrimmed() {
        let s1 = " \t  \r\ntest  \n\t \r  \r\n"
        let s2 = "test"

        XCTAssertEqual(s1.trimmed, s2)
    }

    func testHtmlSafe() {
        let s1 = "\"<i>Hello & good morning, world!</i>\""
        let s2 = "&quot;&lt;i&gt;Hello &amp; good morning, world!&lt;/i&gt;&quot;"

        XCTAssertEqual(s1.htmlSafe, s2)
    }
}
