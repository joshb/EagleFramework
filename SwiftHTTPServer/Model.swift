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

/// Protocol for data model properties to implement.
protocol AbstractModelProperty {
    var nonTypedValue: Any { get set }
}

/// Represents a property of a data model.
class ModelProperty<T>: AbstractModelProperty {
    var value: T

    var nonTypedValue: Any {
        get {
            return value as Any
        }

        set {
            if let typedValue = newValue as? T {
                self.value = typedValue
            }
        }
    }

    init(defaultValue: T) {
        self.value = defaultValue
    }
}

/// Protocol for data models to implement.
protocol Model {
    /// A name for the model's storage. This is used as a table name in a database.
    var storageName: String { get }
}

extension Model {
    typealias NameAndProperty = (name: String, property: AbstractModelProperty)
    typealias NameAndPropertyValue = (name: String, value: Any)

    /// List of tuples containing property names and properties.
    var properties: [NameAndProperty] {
        var result: [NameAndProperty] = []

        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let label = child.label {
                if let property = child.value as? AbstractModelProperty {
                    result.append((label, property))
                }
            }
        }

        return result
    }

    /// List of tuples containing property names and values.
    var propertyValues: [NameAndPropertyValue] {
        var result: [NameAndPropertyValue] = []

        for pair in properties {
            result.append((pair.name, pair.property.nonTypedValue))
        }

        return result
    }
}
