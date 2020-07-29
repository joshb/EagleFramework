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

import Base
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public enum AddressType {
    case IPv4, IPv6
}

/// Represents an IPv4 or IPv6 address.
public struct Address: CustomStringConvertible {
    public var type: AddressType
    public var address: [UInt8]
    public var hostname: String?

    public init(type: AddressType, address: [UInt8], hostname: String? = nil) {
        self.type = type
        self.address = address
        self.hostname = hostname
    }

    /// Initialize an address with the given hostname.
    ///
    /// - parameter forHostname: Hostname to resolve.
    /// - returns: Address, or nil if the hostname could not be resolved.
    public init?(forHostname hostname: String) {
        let hostnameCStr = hostname.cString(using: .utf8)

        // Resolve the hostname. We try resolving an IPv6 address
        // first, and fall back to IPv4 if that fails.
        var type = AddressType.IPv6
        var host = gethostbyname2(hostnameCStr, AF_INET6)
        if host == nil {
            type = AddressType.IPv4
            host = gethostbyname(hostnameCStr)
        }

        guard host != nil else {
            return nil
        }

        // Create an array containing the address.
        var address: [UInt8]!
        if type == .IPv4 {
            address = [UInt8](repeating: 0, count: 4)
            for i in 0..<4 {
                address![i] = UInt8(bitPattern: host!.pointee.h_addr_list[0]![i])
            }
        } else {
            address = [UInt8](repeating: 0, count: 16)
            for i in 0..<16 {
                address![i] = UInt8(bitPattern: host!.pointee.h_addr_list[0]![i])
            }
        }

        self.type = type
        self.address = address
        self.hostname = hostname
    }

    /// String representation of the IPv4/IPv6 address.
    public var addressString: String {
        var s = ""

        if type == .IPv4 {
            for i in 0..<4 {
                if s.count > 0 {
                    s += "."
                }

                s += address[i].description
            }
        } else {
            // First, find the longest sequence of zeros.
            var maxZeroCount = 0
            var maxZeroStart = 0
            var zeroCount = 0
            var zeroStart = 0
            for i in 0..<16 {
                if address[i] == 0 {
                    if zeroCount == 0 {
                        zeroStart = i
                    }

                    zeroCount += 1
                    if zeroCount > maxZeroCount {
                        maxZeroCount = zeroCount
                        maxZeroStart = zeroStart
                    }
                } else {
                    zeroCount = 0
                }
            }

            // Now build the string, shortening the longest sequence of zeros.
            for i in 0..<16 {
                if maxZeroCount > 1 && i >= maxZeroStart && i < maxZeroStart + maxZeroCount {
                    if i == maxZeroStart {
                        s += ":"
                    }
                    continue
                }

                if s.count > 0 {
                    s += ":"
                }

                s += String(address[i], radix: 16, uppercase: false)
            }
        }

        return s
    }

    /// Hostname if set, otherwise the IPv4/IPv6 address.
    public var description: String {
        return hostname ?? addressString
    }
}
