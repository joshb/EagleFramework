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

import Foundation

private func objectToJSON(_ object: AnyObject?, compact: Bool) -> String? {
    guard object != nil else {
        return nil
    }

    guard JSONSerialization.isValidJSONObject(object!) else {
        return nil
    }

    let options = compact ? JSONSerialization.WritingOptions() : JSONSerialization.WritingOptions.prettyPrinted
    if let data = try? JSONSerialization.data(withJSONObject: object!, options: options) {
        var bytes = [UInt8](repeating: 0, count: data.count + 1)
        data.copyBytes(to: &bytes, count: data.count)
        return String(cString: bytes)
    }

    return nil
}

public extension Array {
    func toJSON(compact: Bool = true) -> String? {
        return objectToJSON(self as AnyObject, compact: compact)
    }
}

public extension Dictionary {
    func toJSON(compact: Bool = true) -> String? {
        return objectToJSON(self as AnyObject, compact: compact)
    }
}
