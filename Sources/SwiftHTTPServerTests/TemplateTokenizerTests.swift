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

import Template

class TemplateTokenizerTests: TestCase {
    class TestTemplateTokenizerDelegate: TemplateTokenizerDelegate {
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

    var delegate: TestTemplateTokenizerDelegate!
    var tokenizer: TemplateTokenizer!

    override func setUp() {
        super.setUp()

        delegate = TestTemplateTokenizerDelegate()
        tokenizer = TemplateTokenizer()
        tokenizer.delegate = delegate
    }
    
    override func tearDown() {
        delegate = nil
        tokenizer = nil

        super.tearDown()
    }

    override var tests: TestDictionary {
        return [
            "test1": {
                try self.tokenizer.processString("hello")
                try assertEqual(self.delegate.events, ["text: hello"])
            },

            "test2": {
                try self.tokenizer.processString("<%%>")
                try assertEqual(self.delegate.events, ["codeStart", "codeStop"])
            },

            "test3": {
                try self.tokenizer.processString("hello <%=name%>!")
                try assertEqual(self.delegate.events, ["text: hello ", "codeStart", "unquotedToken: =",
                                                       "unquotedToken: name", "codeStop", "text: !"])
            },

            "test4": {
                try self.tokenizer.processString("<%= \"Hello, \" + name %>")
                try assertEqual(self.delegate.events, ["codeStart", "unquotedToken: =", "quotedToken: Hello, ",
                                                       "unquotedToken: +", "unquotedToken: name", "codeStop"])
            },

            "test5": {
                try self.tokenizer.processString("text.<%code!%>now text!<% and code.%>")
                try assertEqual(self.delegate.events, ["text: text.", "codeStart", "unquotedToken: code",
                                                       "unquotedToken: !", "codeStop", "text: now text!",
                                                       "codeStart", "unquotedToken: and", "unquotedToken: code",
                                                       "unquotedToken: .", "codeStop"])
            }
        ]
    }
}
