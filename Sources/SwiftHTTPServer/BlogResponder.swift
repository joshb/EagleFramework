/*
 * Copyright (C) 2016 Josh A. Beam
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

import Database
import Foundation
import Http
import Template

enum BlogError: ErrorProtocol {
    case NoTitleGiven, NoMessageBodyGiven
}

class BlogPost: Model {
    let title = Model.StringProperty(defaultValue: "Title")
    let body = Model.StringProperty(defaultValue: "Body")
    let timestamp = Model.DoubleProperty(defaultValue: 0.0)

    required init() {
        self.timestamp.value = NSDate().timeIntervalSince1970
    }

    init(title: String, body: String) {
        self.title.value = title
        self.body.value = body
        self.timestamp.value = NSDate().timeIntervalSince1970
    }
}

class BlogResponder: Responder {
    private(set) var webPath: String
    private(set) var database: Database

    private let indexTemplate: Template

    init(webPath: String, databasePath: String) throws {
        self.webPath = webPath
        self.database = try SQLiteDatabase(filePath: databasePath)
        do {
            try self.database.createStorage(forModel: BlogPost())
        } catch {}

        self.indexTemplate = try Template.fromFile("blog_index.html.template")
    }

    func index() throws -> HttpResponse? {
        var html = ""

        for post in try database.query(model: BlogPost()).reversed() {
            let formatter = NSDateFormatter()
#if os(Linux)
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .MediumStyle
#else
            formatter.dateStyle = .mediumStyle
            formatter.timeStyle = .mediumStyle
#endif
            let datetime = formatter.string(from: NSDate(timeIntervalSince1970: post.timestamp.value))

            html += "<h2>\(post.title) <span class=\"timestamp\">\(datetime.htmlSafe)</span></h2>"
            html += "<p>\(post.body)</p>"
        }

        let content = indexTemplate.render(["blog_posts": html])
        return HttpResponse.html(content: content)
    }

    func addPost(from request: HttpRequest) throws -> HttpResponse? {
        let formData = request.formData
        let title: String! = formData["title"]
        let body: String! = formData["body"]

        guard title != nil else {
            throw BlogError.NoTitleGiven
        }

        guard body != nil else {
            throw BlogError.NoMessageBodyGiven
        }

        let post = BlogPost(title: title, body: body)
        try database.save(model: post)

        return HttpResponse.redirect(to: "/" + webPath)
    }

    func response(to request: HttpRequest) throws -> HttpResponse? {
        if let safeFilePath = request.safeFilePath {
            if let path = safeFilePath.relativeToPath(self.webPath) {
                let pathComponents = path.components(separatedBy: "/")
                if pathComponents.count == 0 {
                    return try index()
                } else if pathComponents[0] == "addPost" {
                    return try addPost(from: request)
                }
            }
        }

        return nil
    }
}
