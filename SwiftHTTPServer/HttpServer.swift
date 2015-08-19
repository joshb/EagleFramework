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

/// Represents an HTTP server bound to a particular address and port.
/// Handles accepting and managing connections from clients.
class HttpServer: Printable {
    private(set) var address: Address
    private(set) var port: UInt16

    private var boundSocket: Int32
    private let poller = Poller()
    private var connections: [Int32: HttpConnection] = [:]

    private init(boundSocket: Int32, address: Address, port: UInt16) {
        self.address = address
        self.port = port

        self.boundSocket = boundSocket
        poller.addSocket(self.boundSocket) { (socket: Int32) -> () in
            self.acceptConnection()
        }
    }

    deinit {
        close(boundSocket)
    }

    /// Called when a connection to the bound socket is ready to be accepted.
    private func acceptConnection() {
        var rawAddress = [UInt8](count: 16, repeatedValue: 0)
        var port: UInt16 = 0

        let socket = myAccept(boundSocket, self.address.type == .IPv4 ? 1 : 0, &rawAddress, &port)
        if socket < 0 {
            return
        }

        // Create an HttpConnection.
        let address = Address(type: self.address.type, address: rawAddress, hostname: nil)
        let connection = HttpConnection(fd: socket,
                                        address: address,
                                        port: port,
                                        connectionClosedClosure: connectionClosed)

        // Add the connection to our socket -> connection dictionary and to the poller.
        connections[socket] = connection
        poller.addSocket(socket, closure: readFromConnectionSocket)
    }

    /**
     * Called when a connection has been closed.
     *
     * :param: connection The connection that was closed.
     */
    private func connectionClosed(connection: HttpConnection) {
        poller.removeSocket(connection.fd)
    }

    /**
     * Called when data is available to be read from the given socket.
     *
     * :param: socket Integer representing the socket that has data available.
     */
    private func readFromConnectionSocket(socket: Int32) {
        if let connection = connections[socket] {
            connection.read()
        }
    }

    /// Run the main server loop that waits for connections and processes them.
    func run() {
        while true {
            poller.run()
        }
    }

    var description: String {
        return "[\(address)]:\(port)"
    }

    /**
     * Creates a new HTTP server that listens for connections to the given address/port.
     *
     * :param: address The address to listen for connections to.
     * :param: port The port to listen for connections to.
     */
    static func start(#address: Address, port: UInt16) -> HttpServer? {
        let socket = myBind(address.type == .IPv4 ? 1 : 0, address.address, port)
        return socket >= 0 ? HttpServer(boundSocket: socket, address: address, port: port) : nil
    }
}
