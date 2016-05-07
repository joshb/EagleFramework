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
import Http
import Template

class BlogPost: Model {
    let title = Model.StringProperty(defaultValue: "Title")
    let body = Model.StringProperty(defaultValue: "Body")
}

class BlogResponder: Responder {
    private(set) var webPath: String
    private(set) var database: Database

    private let indexTemplate: Template

    init(webPath: String, databasePath: String) throws {
        self.webPath = webPath
        self.database = try SQLiteDatabase(filePath: databasePath)

        self.indexTemplate = try Template.fromFile("blog_index.html.template")
    }

    func index(_ request: HttpRequest) -> HttpResponse? {
        var html = ""

        for post in (try? database.query(model: BlogPost())) ?? [] {
            html += "<h2>\(post.title)</h2>"
            html += "<p>\(post.body)</p>"
        }

        let content = indexTemplate.render(["blog_posts": html])
        return HttpResponse.html(content)
    }

    func addPost(_ request: HttpRequest) -> HttpResponse? {
        let formData = request.formData
        let post = BlogPost()
        post.title.value = formData["title"] ?? ""
        post.body.value = formData["body"] ?? ""

        do {
            try database.save(model: post)
        } catch {}

        return HttpResponse.redirect("/" + webPath)
    }

    func response(to request: HttpRequest) -> HttpResponse? {
        if let safeFilePath = request.safeFilePath {
            if let path = safeFilePath.relativeToPath(self.webPath) {
                let pathComponents = path.split("/")
                if pathComponents.count == 0 {
                    return index(request)
                } else if pathComponents[0] == "addPost" {
                    return addPost(request)
                }
            }
        }

        return nil
    }
}
