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

typealias Descriptor = Int32

/// Contains server utility functions.
class ServerUtil {
    private class func createKEvent(descriptor: Descriptor, write: Bool = false) -> kevent {
        var event = kevent()
        event.ident = UInt(descriptor)
        if write {
            event.filter = Int16(EVFILT_WRITE)
        } else {
            event.filter = Int16(EVFILT_READ)
        }
        event.flags = UInt16(EV_ADD | EV_RECEIPT | EV_CLEAR)
        event.fflags = 0
        event.data = 0
        event.udata = nil
        return event
    }

    class func addKEvent(kqueueDescriptor: Descriptor, socketDescriptor: Descriptor, readOnly: Bool = true) {
        if readOnly {
            var event = createKEvent(socketDescriptor)
            kevent(kqueueDescriptor, &event, 1, nil, 0, nil)
        } else {
            var events = [createKEvent(socketDescriptor), createKEvent(socketDescriptor, write: true)]
            kevent(kqueueDescriptor, &events, 2, nil, 0, nil)
        }
    }

    private class var hostIsLittleEndian: Bool {
        let a: [UInt8] = [0, 1]
        let b = UnsafePointer<UInt16>(a)
        let c = b[0]
        return c == 256
    }

    private class func hostToNetwork(port: Port) -> Port {
        if hostIsLittleEndian {
            let a = port & 0xff
            let b = (port >> 8) & 0xff
            return (a << 8) | b
        }

        return port
    }

    class func doBind(descriptor: Descriptor, address: UnsafePointer<Void>, len: socklen_t) -> Int32 {
        return bind(descriptor, UnsafePointer<sockaddr>(address), len)
    }

    class func doAccept(descriptor: Descriptor, address: UnsafePointer<Void>, inout len: socklen_t) -> Int32 {
        return accept(descriptor, UnsafeMutablePointer<sockaddr>(address), &len)
    }

    class func createSocket(endpoint: Endpoint) -> Descriptor? {
        let descriptor = socket(endpoint.address.type == .IPv4 ? AF_INET : AF_INET6, SOCK_STREAM, 0)
        guard descriptor != -1 else {
            return nil
        }

        var reuseAddr: Int32 = 1
        setsockopt(descriptor, SOL_SOCKET, SO_REUSEADDR, &reuseAddr, 4)

        if endpoint.address.type == .IPv4 {
            var sin = sockaddr_in()
            bzero(&sin, sizeofValue(sin))
            sin.sin_family = UInt8(AF_INET)
            sin.sin_port = hostToNetwork(endpoint.port)
            memcpy(&sin.sin_addr, endpoint.address.address, 4)
            let len = UInt32(sizeofValue(sin))

            if doBind(descriptor, address: &sin, len: len) == -1 {
                close(descriptor)
                return nil
            }
        } else {
            var sin6 = sockaddr_in6()
            bzero(&sin6, sizeofValue(sin6))
            sin6.sin6_family = UInt8(AF_INET6)
            sin6.sin6_port = hostToNetwork(endpoint.port)
            memcpy(&sin6.sin6_addr, endpoint.address.address, 16)
            let len = UInt32(sizeofValue(sin6))

            if doBind(descriptor, address: &sin6, len: len) == -1 {
                close(descriptor)
                return nil
            }
        }

        if listen(descriptor, 0) == -1 {
            close(descriptor)
            return nil
        }

        return descriptor
    }

    class func acceptConnection(descriptor: Descriptor, localEndpoint: Endpoint) -> (Descriptor, Endpoint)? {
        var newDescriptor: Descriptor
        var rawAddress = [UInt8](count: 16, repeatedValue: 0)
        var newPort: Port

        if localEndpoint.address.type == .IPv4 {
            var sin = sockaddr_in()
            bzero(&sin, sizeofValue(sin))
            var len = socklen_t(sizeofValue(sin))

            newDescriptor = doAccept(descriptor, address: &sin, len: &len)
            guard newDescriptor != -1 else {
                return nil
            }

            memcpy(&rawAddress, &sin.sin_addr, 4)
            newPort = hostToNetwork(sin.sin_port)
        } else {
            var sin6 = sockaddr_in6()
            bzero(&sin6, sizeofValue(sin6))
            var len = socklen_t(sizeofValue(sin6))

            newDescriptor = doAccept(descriptor, address: &sin6, len: &len)
            guard newDescriptor != -1 else {
                return nil
            }

            memcpy(&rawAddress, &sin6.sin6_addr, 16)
            newPort = hostToNetwork(sin6.sin6_port)
        }

        let newAddress = Address.init(type: localEndpoint.address.type, address: rawAddress, hostname: nil)
        return (newDescriptor, Endpoint(address: newAddress, port: newPort))
    }
}
