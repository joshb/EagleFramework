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

/// Represents an object to be notified of tokenization events.
public protocol TemplateTokenizerDelegate {
    /// Called when non-code text has been found.
    ///
    /// - parameter text: The text that was found.
    func textFound(_ text: String) throws

    /// Called when the beginning of a code segment has been found.
    func codeStartFound() throws

    /// Called when the end of a code segment has been found.
    func codeStopFound() throws

    /// Called when a token has been found in a code segment.
    ///
    /// - parameter token: The token that was found.
    /// - parameter quoted: true if the token was surrounded by quotes, false otherwise.
    func tokenFound(_ token: String, quoted: Bool) throws
}

/// Tokenizes strings for the template engine.
public class TemplateTokenizer {
    private static let codeStartSymbol = "<%"
    private static let codeStopSymbol = "%>"

    public var delegate: TemplateTokenizerDelegate?

    private var inCode: Bool = false
    private var previousChar: Character = " "
    private var token: String = ""
    private var quoteChar: Character?

    public init() {}

    /// Check if a token is a special token, such as a mathematical symbol.
    ///
    /// - parameter token: The token to check.
    /// - returns: true if the token is a special token, false otherwise.
    private static func isSpecialToken(_ token: String) -> Bool {
        let specialTokens = [
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "+", "=",
            "{", "}", "[", "]", ":", ";", ",", "<", ">", "?", "/", "~", "|",
            "!=", "%=", "^=", "&=", "*=", "-=", "+=", "==", ".",
            "<=", ">=", "/=", "|=", "<<", ">>", "<<=", ">>=", "&&", "||",
            codeStopSymbol
        ]

        return specialTokens.contains(token)
    }

    private func emitToken(_ quoted: Bool = false) throws {
        if token.isEmpty {
            return
        }

        if inCode {
            if token == TemplateTokenizer.codeStopSymbol && !quoted {
                inCode = false
                try delegate?.codeStopFound()
            } else {
                try delegate?.tokenFound(token, quoted: quoted)
            }
        } else {
            try delegate?.textFound(token)
        }

        token = ""
    }

    private func processCharacter(_ c: Character) throws {
        let cs = String(c)

        // If we're not processing code yet, just append
        // the character to the token string.
        if !inCode {
            token += cs

            // If the token now has the code start symbol, we emit
            // the token as text and switch to in-code processing.
            if token.hasSuffix(TemplateTokenizer.codeStartSymbol) {
                token = token.substring(from: 0, length: token.length - TemplateTokenizer.codeStartSymbol.length)
                try emitToken()
                try delegate?.codeStartFound()
                inCode = true
            }

            return
        }

        // Check for the end of a quoted token.
        if let quoteChar = self.quoteChar {
            if c == quoteChar {
                try emitToken(true)
                self.quoteChar = nil
            } else {
                token += cs
            }

            return
        }

        // Check for the beginning of a quoted token.
        if c == "'" || c == "\"" {
            self.quoteChar = c
            return
        }

        // Check for whitespace separating tokens.
        if String.isWhitespace(c) {
            try emitToken()
            return
        }

        // Now check for special tokens, such as mathematical symbols.
        if TemplateTokenizer.isSpecialToken(token) {
            if !TemplateTokenizer.isSpecialToken(token + cs) {
                try emitToken()
            }
        } else {
            if TemplateTokenizer.isSpecialToken(cs) {
                try emitToken()
            }
        }

        token += cs
    }

    /// Tokenize a string, sending tokens and events to the delegate.
    ///
    /// - parameter s: The string to tokenize.
    public func processString(_ s: String) throws {
        for c in s.characters {
            try processCharacter(c)
        }

        try emitToken()
    }
}
