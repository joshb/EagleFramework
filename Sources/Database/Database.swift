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

public enum DatabaseError: Error {
    case ConnectionFailed(message: String?)
    case CommandFailed(message: String?)
    case ModelNotSupported
    case TableDoesNotExist
    case RecordDoesNotExist
    case UnexpectedNumberOfColumns
}

public protocol Database {
    /// Create storage in the database for the given model.
    func createStorage(forModel model: Model) throws

    /// Saves a data model to the database.
    ///
    /// - parameter model: The data model to save.
    func save(model: Model) throws

    /// Loads a data model from the database.
    ///
    /// - parameter model: The data model instance to load the data into.
    /// - parameter withId: The unique identifier of the data model to load.
    /// - returns: The data model populated with the loaded data.
    func load(model: Model, withId id: Int64) throws -> Model

    /// Query for models of the given type.
    func query<T: Model>(model: T) throws -> [T]
}
