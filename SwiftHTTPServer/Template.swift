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

class Template: CustomStringConvertible, TemplateParserDelegate {
    private(set) var nodes: [TemplateNode] = []

    init(source: String = "") {
        if !source.isEmpty {
            parseSource(source)
        }
    }

    func addTemplateNode(node: TemplateNode) {
        nodes.append(node)
    }

    func parseSource(source: String) {
        nodes = []

        let parser = TemplateParser()
        parser.delegate = self
        parser.processString(source)
    }

    func render(data: [String : Any]) -> String {
        var s = ""

        for node in nodes {
            s += node.render(data)
        }

        return s
    }

    var description: String {
        var s = ""

        for node in nodes {
            s += node.description
        }

        return s
    }

    static func fromFile(path: String) -> Template? {
        let fullPath = Settings.getAbsoluteResourcePath(path)
        if let source = try? String(contentsOfFile: fullPath, encoding: 4) {
            return Template(source: source)
        }

        return nil
    }
}
