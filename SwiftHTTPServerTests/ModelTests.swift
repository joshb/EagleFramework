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

class ModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPropertyValues() {
        class TestModel: Model {
            var storageName: String {
                return "TestModel"
            }

            let boolProperty = ModelProperty<Bool>(defaultValue: false)
            let doubleProperty = ModelProperty<Double>(defaultValue: 1.23)
            let intProperty = ModelProperty<Int>(defaultValue: 42)
            let stringProperty = ModelProperty<String>(defaultValue: "Hello")
        }

        let model = TestModel()
        let propertyValues = model.propertyValues
        XCTAssertEqual(propertyValues.count, 4)
        XCTAssertEqual(propertyValues[0].name, "boolProperty")
        XCTAssertEqual(propertyValues[0].value as? Bool, false)
        XCTAssertEqual(propertyValues[1].value as? Double, 1.23)
        XCTAssertEqual(propertyValues[1].name, "doubleProperty")
        XCTAssertEqual(propertyValues[2].value as? Int, 42)
        XCTAssertEqual(propertyValues[2].name, "intProperty")
        XCTAssertEqual(propertyValues[3].value as? String, "Hello")
        XCTAssertEqual(propertyValues[3].name, "stringProperty")
    }
}
