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

class TokenizerTests: XCTestCase {
    class TestTokenizerDelegate: TokenizerDelegate {
        var events: [String] = []

        func codeStartFound() {
            events.append("codeStart")
        }

        func codeStopFound() {
            events.append("codeStop")
        }

        func textFound(text: String) {
            events.append("text: " + text)
        }

        func tokenFound(token: String, quoted: Bool) {
            if quoted {
                events.append("quotedToken: " + token)
            } else {
                events.append("unquotedToken: " + token)
            }
        }
    }

    var delegate: TestTokenizerDelegate!
    var tokenizer: Tokenizer!

    override func setUp() {
        super.setUp()

        delegate = TestTokenizerDelegate()
        tokenizer =  Tokenizer()
        tokenizer.delegate = delegate
    }
    
    override func tearDown() {
        delegate = nil
        tokenizer = nil

        super.tearDown()
    }

    func test1() {
        tokenizer.processString("hello")
        XCTAssertEqual(delegate.events, ["text: hello"])
    }

    func test2() {
        tokenizer.processString("<%%>")
        XCTAssertEqual(delegate.events, ["codeStart", "codeStop"])
    }

    func test3() {
        tokenizer.processString("hello <%=name%>!")
        XCTAssertEqual(delegate.events, ["text: hello ", "codeStart", "unquotedToken: =",
                                         "unquotedToken: name", "codeStop", "text: !"])
    }

    func test4() {
        tokenizer.processString("<%= \"Hello, \" + name %>")
        XCTAssertEqual(delegate.events, ["codeStart", "unquotedToken: =", "quotedToken: Hello, ",
                                         "unquotedToken: +", "unquotedToken: name", "codeStop"])
    }

    func test5() {
        tokenizer.processString("text.<%code!%>now text!<% and code.%>")
        XCTAssertEqual(delegate.events, ["text: text.", "codeStart", "unquotedToken: code", "unquotedToken: !",
                                         "codeStop", "text: now text!", "codeStart", "unquotedToken: and",
                                         "unquotedToken: code", "unquotedToken: .", "codeStop"])
    }
}
