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

#if os(Linux)
import CEpoll
import Glibc
#else
import Darwin
#endif

public typealias Descriptor = Int32

#if os(Linux)
private let SOCK_STREAM: Int32 = 1
#endif

/// Contains server utility functions.
internal class ServerUtil {
#if os(Linux)
    class func addEpollEvent(_ epollDescriptor: Descriptor, socketDescriptor: Descriptor) {
        var event = epoll_event()
        event.events = 1 // EPOLLIN
        event.data.fd = socketDescriptor

        epoll_ctl(epollDescriptor, EPOLL_CTL_ADD, socketDescriptor, &event)
    }
#else
    class func addKEvent(_ kqueueDescriptor: Descriptor, socketDescriptor: Descriptor) {
        var event = kevent()
        event.ident = UInt(socketDescriptor)
        event.filter = Int16(EVFILT_READ)
        event.flags = UInt16(EV_ADD | EV_RECEIPT)
        event.fflags = 0
        event.data = 0
        event.udata = nil
        kevent(kqueueDescriptor, &event, 1, nil, 0, nil)
    }
#endif

    class func doBind(_ descriptor: Descriptor, address: UnsafeRawPointer, len: socklen_t) -> Int32 {
        let a = address.assumingMemoryBound(to: sockaddr.self)
        return bind(descriptor, a, len)
    }

    class func doAccept(_ descriptor: Descriptor, address: UnsafeMutableRawPointer, len: inout socklen_t) -> Int32 {
        let a = address.assumingMemoryBound(to: sockaddr.self)
        return accept(descriptor, a, &len)
    }

    class func createSocket(_ endpoint: Endpoint) -> Descriptor? {
        let descriptor = socket(endpoint.address.type == .IPv4 ? AF_INET : AF_INET6, SOCK_STREAM, 0)
        guard descriptor != -1 else {
            return nil
        }

        var reuseAddr: Int32 = 1
        setsockopt(descriptor, SOL_SOCKET, SO_REUSEADDR, &reuseAddr, 4)

        if endpoint.address.type == .IPv4 {
            var sin = sockaddr_in()
            bzero(&sin, MemoryLayout.size(ofValue: sin))
            sin.sin_family = sa_family_t(AF_INET)
            sin.sin_port = endpoint.port.bigEndian
            memcpy(&sin.sin_addr, endpoint.address.address, 4)
            let len = UInt32(MemoryLayout.size(ofValue: sin))

            if doBind(descriptor, address: &sin, len: len) == -1 {
                close(descriptor)
                return nil
            }
        } else {
            var sin6 = sockaddr_in6()
            bzero(&sin6, MemoryLayout.size(ofValue: sin6))
            sin6.sin6_family = sa_family_t(AF_INET6)
            sin6.sin6_port = endpoint.port.bigEndian
            memcpy(&sin6.sin6_addr, endpoint.address.address, 16)
            let len = UInt32(MemoryLayout.size(ofValue: sin6))

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

    class func acceptConnection(_ descriptor: Descriptor, localEndpoint: Endpoint) -> (Descriptor, Endpoint)? {
        var newDescriptor: Descriptor
        var rawAddress = [UInt8](repeating: 0, count: 16)
        var newPort: Port

        if localEndpoint.address.type == .IPv4 {
            var sin = sockaddr_in()
            bzero(&sin, MemoryLayout.size(ofValue: sin))
            var len = socklen_t(MemoryLayout.size(ofValue: sin))

            newDescriptor = doAccept(descriptor, address: &sin, len: &len)
            guard newDescriptor != -1 else {
                return nil
            }

            memcpy(&rawAddress, &sin.sin_addr, 4)
            newPort = sin.sin_port.bigEndian
        } else {
            var sin6 = sockaddr_in6()
            bzero(&sin6, MemoryLayout.size(ofValue: sin6))
            var len = socklen_t(MemoryLayout.size(ofValue: sin6))

            newDescriptor = doAccept(descriptor, address: &sin6, len: &len)
            guard newDescriptor != -1 else {
                return nil
            }

            memcpy(&rawAddress, &sin6.sin6_addr, 16)
            newPort = sin6.sin6_port.bigEndian
        }

        let newAddress = Address.init(type: localEndpoint.address.type, address: rawAddress, hostname: nil)
        return (newDescriptor, Endpoint(address: newAddress, port: newPort))
    }
}
