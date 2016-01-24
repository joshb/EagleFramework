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

typealias TestFunc = () throws -> Void
typealias TestDictionary = [String: TestFunc]

enum TestCaseError: ErrorType {
    case AssertionFailed
}

class TestCase {
    static var testsSucceeded = 0
    static var testsFailed = 0

    var tests: TestDictionary {
        return [:]
    }

    func setUp() {}
    func tearDown() {}

    func run() {
        print("Running test case \(self.dynamicType)...")
        for (testName, testFunc) in tests {
            print("\t\(testName)... ", terminator: "")
            setUp()

            do {
                try testFunc()
                TestCase.testsSucceeded += 1
                print("\u{1b}[1;32msuccess\u{1b}[0;0m")
            } catch {
                TestCase.testsFailed += 1
                print("\u{1b}[1;31mfailure\u{1b}[0;0m")
            }

            tearDown()
        }

        print()
    }

    static func printStats() {
        var succeeded = "\(testsSucceeded)"
        if testsSucceeded > 0 {
            succeeded = "\u{1b}[1;32m\(succeeded)\u{1b}[0;0m"
        }

        var failed = "\(testsFailed)"
        if testsFailed > 0 {
            failed = "\u{1b}[1;31m\(failed)\u{1b}[0;0m"
        }

        print("\(succeeded) succeeded, \(failed) failed")
    }

    static func runTestCases(testCases: [TestCase]) {
        for testCase in testCases {
            testCase.run()
        }

        printStats()
    }
}

func assertEqual<T: Equatable>(a: T, _ b: T) throws {
    if a != b {
        throw TestCaseError.AssertionFailed
    }
}

func assertEqual<T: Equatable>(a: [T], _ b: [T]) throws {
    try assertEqual(a.count, b.count)
    for i in 0..<a.count {
        try assertEqual(a[i], b[i])
    }
}

func assertEqual<T, U: Equatable>(a: [T: U], _ b: [T: U]) throws {
    try assertEqual(a.count, b.count)
    for (key, value) in a {
        try assertEqual(b[key], value)
    }
}

func assertEqual<T: Equatable>(a: T?, _ b: T) throws {
    if let c = a {
        try assertEqual(c, b)
    } else {
        throw TestCaseError.AssertionFailed
    }
}

func assertTrue(value: Bool) throws {
    if !value {
        throw TestCaseError.AssertionFailed
    }
}

func assertFalse(value: Bool) throws {
    try assertTrue(!value)
}
