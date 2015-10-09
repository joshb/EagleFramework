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

protocol ModelPropertyType {}
extension Bool: ModelPropertyType {}
extension Double: ModelPropertyType {}
extension Int: ModelPropertyType {}
extension String: ModelPropertyType {}

/// Represents a property of a data model.
class ModelProperty<T: ModelPropertyType> {
    var value: T

    init(defaultValue: T) {
        self.value = defaultValue
    }
}

/// Represents a data model.
class Model {
    private var _properties: [String: Any]?

    let id = ModelProperty<Int>(defaultValue: 0)

    /// Dictionary of property names to ModelProperty instances.
    var properties: [String: Any] {
        if _properties != nil {
            return _properties!
        }

        _properties = [:]

        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let label = child.label {
                let value = child.value
                if value is ModelProperty<Bool> ||
                    value is ModelProperty<Double> ||
                    value is ModelProperty<Int> ||
                    value is ModelProperty<String> {
                        _properties![label] = value
                }
            }
        }

        return _properties!
    }

    /// Dictionary of property names to values.
    var propertyValues: [String: Any] {
        var result: [String: Any] = [:]

        for (key, rawProperty) in properties {
            if let property = rawProperty as? ModelProperty<Bool> {
                result[key] = property.value
            } else if let property = rawProperty as? ModelProperty<Double> {
                result[key] = property.value
            } else if let property = rawProperty as? ModelProperty<Int> {
                result[key] = property.value
            } else if let property = rawProperty as? ModelProperty<String> {
                result[key] = property.value
            }
        }

        return result
    }

    /// Sets the value for the property with the given name.
    ///
    /// - parameter value: The value to assign to the property.
    /// - parameter propertyName: The name of the property to assign the value to.
    func setValue(value: Any, forPropertyWithName propertyName: String) {
        if let rawProperty = properties[propertyName] {
            if let property = rawProperty as? ModelProperty<Bool> {
                if let newValue = value as? Bool {
                    property.value = newValue
                }
            } else if let property = rawProperty as? ModelProperty<Double> {
                if let newValue = value as? Double {
                    property.value = newValue
                }
            } else if let property = rawProperty as? ModelProperty<Int> {
                if let newValue = value as? Int {
                    property.value = newValue
                }
            } else if let property = rawProperty as? ModelProperty<String> {
                if let newValue = value as? String {
                    property.value = newValue
                }
            }
        }
    }
}
