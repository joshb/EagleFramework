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

/// Protocol for data model properties to implement.
public protocol ModelProperty: CustomStringConvertible {
    var nonTypedValue: Any { get set }
}

/// Represents a required property of a data model.
public class RequiredModelProperty<T>: ModelProperty {
    public var value: T

    public var nonTypedValue: Any {
        get {
            return self.value as Any
        }

        set {
            if let typedValue = newValue as? T {
                self.value = typedValue
            }
        }
    }

    public init(defaultValue: T) {
        self.value = defaultValue
    }

    public var description: String {
        return "\(self.value)".htmlSafe
    }
}

/// Represents an optional property of a data model.
public class OptionalModelProperty<T>: ModelProperty {
    public var value: T?

    public var nonTypedValue: Any {
        get {
            return self.value as Any
        }

        set {
            self.value = newValue as? T
        }
    }

    public init(defaultValue: T? = nil) {
        self.value = defaultValue
    }

    public var description: String {
        if let value = self.value {
            return "\(value)".htmlSafe
        } else {
            return "(nil)"
        }
    }
}

/// Represents a data model.
open class Model: CustomStringConvertible {
    public typealias BoolProperty = RequiredModelProperty<Bool>
    public typealias OptionalBoolProperty = OptionalModelProperty<Bool>
    public typealias DoubleProperty = RequiredModelProperty<Double>
    public typealias OptionalDoubleProperty = OptionalModelProperty<Double>
    public typealias IntProperty = RequiredModelProperty<Int64>
    public typealias OptionalIntProperty = OptionalModelProperty<Int64>
    public typealias StringProperty = RequiredModelProperty<String>
    public typealias OptionalStringProperty = OptionalModelProperty<String>

    public typealias ForeignKeyProperty = IntProperty
    public typealias OptionalForeignKeyProperty = OptionalIntProperty

    public typealias NameAndProperty = (name: String, property: ModelProperty)
    public typealias NameAndPropertyValue = (name: String, value: Any)

    private var _storageName: String?
    private var _properties: [NameAndProperty]?
    private var _propertiesDictionary: [String: ModelProperty]?

    /// A name for the model's storage. This is used as a table name in a database.
    public var storageName: String {
        if _storageName == nil {
            _storageName = "\(type(of: self))"
        }

        return _storageName!
    }

    /// A number to uniquely identify the model.
    public var id: Int64 = 0

    /// List of tuples containing property names and properties.
    public var properties: [NameAndProperty] {
        if _properties == nil {
            var result: [NameAndProperty] = []

            let mirror = Mirror(reflecting: self)
            for child in mirror.children {
                if let label = child.label {
                    if let property = child.value as? ModelProperty {
                        result.append((label, property))
                    }
                }
            }

            _properties = result
        }

        return _properties!
    }

    /// Dictionary of property names to properties.
    var propertiesDictionary: [String: ModelProperty] {
        if _propertiesDictionary == nil {
            var result: [String: ModelProperty] = [:]

            for (name, property) in properties {
                result[name] = property
            }

            _propertiesDictionary = result
        }

        return _propertiesDictionary!
    }

    /// List of tuples containing property names and values.
    public var propertyValues: [NameAndPropertyValue] {
        var result: [NameAndPropertyValue] = []

        for (name, property) in properties {
            result.append((name, property.nonTypedValue))
        }
        
        return result
    }

    /// Dictionary of property names to values.
    var propertyValuesDictionary: [String: Any] {
        var result: [String: Any] = [:]

        for (name, property) in properties {
            result[name] = property.nonTypedValue
        }

        return result
    }

    required public init() {}

    public var description: String {
        var propertyList = "id: " + id.description

        for (name, value) in propertyValues {
            propertyList += ", "
            
            if let stringValue = value as? String {
                propertyList += name + ": \"" + stringValue + "\""
            } else {
                propertyList += name + ": \(value)"
            }
        }

        return "\(type(of: self))(" + propertyList + ")"
    }
}
