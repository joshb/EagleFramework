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

import XCTest

class SQLiteDatabaseTests: XCTestCase {
    class User: Model {
        let username = Model.StringProperty(defaultValue: "")
        let password = Model.StringProperty(defaultValue: "")
        let isAdmin = Model.BoolProperty(defaultValue: false)
        let fullName = Model.OptionalStringProperty()
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateTableCommandForModel() throws {
        let command = try SQLiteDatabase.createTableCommandForModel(User())
        let expectedCommand = "CREATE TABLE User (id INTEGER PRIMARY KEY NOT NULL, username TEXT NOT NULL, password TEXT NOT NULL, isAdmin INTEGER NOT NULL, fullName TEXT NULL)"
        XCTAssertEqual(command, expectedCommand)
    }

    func testInsertCommandForModel() throws {
        let user = User()
        user.username.value = "josh"
        user.password.value = "test"
        user.isAdmin.value = true

        let command = try SQLiteDatabase.insertCommandForModel(user)
        let expectedCommand = "INSERT INTO User (username, password, isAdmin, fullName) VALUES ('josh', 'test', 1, NULL)"
        XCTAssertEqual(command, expectedCommand)
    }

    func testUpdateCommandForModel() throws {
        let user = User()
        user.id = 42
        user.username.value = "bob"
        user.password.value = "hello"

        let command = try SQLiteDatabase.updateCommandForModel(user)
        let expectedCommand = "UPDATE User SET username = 'bob', password = 'hello', isAdmin = 0, fullName = NULL WHERE id = 42"
        XCTAssertEqual(command, expectedCommand)
    }

    func testSelectCommandForModel() throws {
        let command = try SQLiteDatabase.selectCommandForModel(User())
        let expectedCommand = "SELECT username, password, isAdmin, fullName FROM User"
        XCTAssertEqual(command, expectedCommand)
    }
}
