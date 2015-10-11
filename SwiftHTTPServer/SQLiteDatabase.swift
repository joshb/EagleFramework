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

/// Represents an SQLite database.
class SQLiteDatabase: Database {
    enum SQLiteValue {
        case Null
    }

    private var db: COpaquePointer = nil

    init(filePath: String) throws {
        if sqlite3_open(filePath.utf8CString, &db) != SQLITE_OK {
            throw DatabaseError.ConnectionFailed(message: "Could not open the file: " + filePath)
        }
    }

    deinit {
        sqlite3_close(db)
    }

    /// Determines whether or not the given property is supported for storage in a SQLite database.
    ///
    /// - parameter property: The property to check.
    /// - returns: true if the property is supported, false otherwise.
    static func isModelPropertySupported(property: ModelProperty) -> Bool {
        return property is Model.BoolProperty || property is Model.OptionalBoolProperty ||
               property is Model.DoubleProperty || property is Model.OptionalDoubleProperty ||
               property is Model.IntProperty || property is Model.OptionalIntProperty ||
               property is Model.StringProperty || property is Model.StringProperty
    }

    /// Generates a 'CREATE TABLE' command for the given model.
    ///
    /// - parameter model: The model to generate the command for.
    /// - returns: String containing the command.
    static func createTableCommandForModel(model: Model) throws -> String {
        var propertyList = "id INTEGER PRIMARY KEY NOT NULL"

        for (name, property) in model.properties {
            propertyList += ", "
            
            var propertyType: String?
            if property is Model.BoolProperty || property is Model.IntProperty {
                propertyType = "INTEGER NOT NULL"
            } else if property is Model.OptionalBoolProperty || property is Model.OptionalIntProperty {
                propertyType = "INTEGER NULL"
            } else if property is Model.DoubleProperty {
                propertyType = "REAL NOT NULL"
            } else if property is Model.OptionalDoubleProperty {
                propertyType = "REAL NULL"
            } else if property is Model.StringProperty {
                propertyType = "TEXT NOT NULL"
            } else if property is Model.OptionalStringProperty {
                propertyType = "TEXT NULL"
            } else {
                throw DatabaseError.ModelNotSupported
            }

            if let type = propertyType {
                propertyList += name + " " + type
            }
        }

        return "CREATE TABLE " + model.storageName + " (" + propertyList + ")"
    }

    /// Generates an escaped version of a string suitable for use in an SQL command.
    ///
    /// - parameter s: The string to escape.
    /// - returns: The escaped string.
    static func escapeString(s: String) -> String {
        return "'" + s.replace("'", withString: "''") + "'"
    }

    /// Generates an array of tuples containing the field names and SQL-formatted values for the given model's properties.
    ///
    /// - parameter model: The model to get field names and values for.
    /// - returns: Array of tuples, each containing a field name and a value.
    static func getFieldNamesAndValuesForModel(model: Model) throws -> [(String, String)] {
        var result: [(String, String)] = []

        for (name, abstractProperty) in model.properties {
            var propertyValue: String?
            if let property = abstractProperty as? Model.BoolProperty {
                propertyValue = property.value ? "1" : "0"
            } else if let property = abstractProperty as? Model.OptionalBoolProperty {
                if property.value != nil {
                    propertyValue = property.value! ? "1" : "0"
                } else {
                    propertyValue = "NULL"
                }
            } else if let property = abstractProperty as? Model.DoubleProperty {
                propertyValue = String(property.value)
            } else if let property = abstractProperty as? Model.OptionalDoubleProperty {
                if let value = property.value {
                    propertyValue = String(value)
                } else {
                    propertyValue = "NULL"
                }
            } else if let property = abstractProperty as? Model.IntProperty {
                propertyValue = String(property.value)
            } else if let property = abstractProperty as? Model.OptionalIntProperty {
                if let value = property.value {
                    propertyValue = String(value)
                } else {
                    propertyValue = "NULL"
                }
            } else if let property = abstractProperty as? Model.StringProperty {
                propertyValue = escapeString(property.value)
            } else if let property = abstractProperty as? Model.OptionalStringProperty {
                if let value = property.value {
                    propertyValue = escapeString(value)
                } else {
                    propertyValue = "NULL"
                }
            } else {
                throw DatabaseError.ModelNotSupported
            }

            if let value = propertyValue {
                result.append((name, value))
            }
        }

        return result
    }

    /// Generates an 'INSERT' command for the given model.
    ///
    /// - parameter model: The model to generate the command for.
    /// - returns: String containing the command.
    static func insertCommandForModel(model: Model) throws -> String {
        var propertyList = ""
        var valueList = ""
        for (name, value) in try getFieldNamesAndValuesForModel(model) {
            if !propertyList.isEmpty {
                propertyList += ", "
                valueList += ", "
            }

            propertyList += name
            valueList += value
        }

        return "INSERT INTO " + model.storageName + " (" + propertyList + ") VALUES (" + valueList + ")"
    }

    /// Generates an 'UPDATE' command for the given model.
    ///
    /// - parameter model: The model to generate the command for.
    /// - returns: String containing the command.
    static func updateCommandForModel(model: Model) throws -> String {
        var valueList = ""
        for (name, value) in try getFieldNamesAndValuesForModel(model) {
            if !valueList.isEmpty {
                valueList += ", "
            }

            valueList += name + " = " + value
        }

        return "UPDATE " + model.storageName + " SET " + valueList + " WHERE id = " + model.id.description
    }

    /// Generates a 'SELECT' command for the given model.
    ///
    /// - parameter model: The model to generate the command for.
    /// - returns: String containing the command.
    static func selectCommandForModel(model: Model) throws -> String {
        var propertyList = ""
        for (name, _) in try getFieldNamesAndValuesForModel(model) {
            if !propertyList.isEmpty {
                propertyList += ", "
            }

            propertyList += name
        }

        return "SELECT " + propertyList + " FROM " + model.storageName
    }

    /// Executes an SQL command that does not return any data.
    ///
    /// - parameter command: String containing the command to execute.
    func executeCommand(command: String) throws {
        var errorPointer: UnsafeMutablePointer<CChar> = nil

        if sqlite3_exec(db, command.utf8CString, nil, nil, &errorPointer) != SQLITE_OK {
            let error = String.fromCString(errorPointer)
            if let errorMessage = error {
                if errorMessage.hasPrefix("no such table:") {
                    throw DatabaseError.TableDoesNotExist
                }
            }

            throw DatabaseError.CommandFailed(message: error)
        }
    }

    /// Executes an SQL query that returns data.
    ///
    /// - parameter query: String containing the query to execute.
    /// - returns: A two-dimensional array of values in each row/column.
    func executeQuery(query: String) throws -> [[Any]] {
        var statement: COpaquePointer = nil

        // Prepare the query.
        let queryCString = query.utf8CString
        if sqlite3_prepare_v2(db, queryCString, Int32(queryCString.count), &statement, nil) != SQLITE_OK {
            throw DatabaseError.CommandFailed(message: nil)
        }

        defer {
            sqlite3_finalize(statement)
        }

        var results: [[Any]] = []
        let columnCount = sqlite3_column_count(statement)
        if columnCount < 1 {
            return results
        }

        // Read each row.
        while sqlite3_step(statement) == SQLITE_ROW {
            var row: [Any] = []

            for i in 0..<columnCount {
                let columnType = sqlite3_column_type(statement, i)
                switch columnType {
                    case SQLITE_INTEGER:
                        row.append(Int(sqlite3_column_int(statement, i)))

                    case SQLITE_FLOAT:
                        row.append(sqlite3_column_double(statement, i))

                    case SQLITE_TEXT:
                        row.append(String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, i))) ?? "")

                    case SQLITE_NULL:
                        row.append(SQLiteValue.Null)

                    default:
                        throw DatabaseError.CommandFailed(message: "Unknown column type returned: " + columnType.description)
                }
            }

            results.append(row)
        }

        return results
    }

    func saveModel(model: Model) throws {
        // If the model's ID is not set, it's a new model that must be
        // inserted into the appropriate table. If the ID is set, it's
        // an existing model that must have its row updated.
        var command: String
        if model.id == 0 {
            command = try SQLiteDatabase.insertCommandForModel(model)
        } else {
            command = try SQLiteDatabase.updateCommandForModel(model)
        }

        do {
            try executeCommand(command)
        } catch DatabaseError.TableDoesNotExist {
            // Create the table and try executing the command again.
            try executeCommand(SQLiteDatabase.createTableCommandForModel(model))
            try executeCommand(command)
        }
    }

    func loadModel(model: Model, id: Int64) throws -> Model {
        let command = try SQLiteDatabase.selectCommandForModel(model) + " WHERE id = " + id.description
        let results = try executeQuery(command)
        guard results.count == 1 else {
            throw DatabaseError.RecordDoesNotExist
        }

        let row = results[0]
        let properties = model.properties
        guard row.count == properties.count else {
            throw DatabaseError.UnexpectedNumberOfColumns
        }

        for i in 0..<row.count {
            var property = properties[i].property
            property.nonTypedValue = row[i]
            print(property.nonTypedValue)
        }

        return model
    }
}
