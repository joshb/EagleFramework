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

enum AddressType {
    case IPv4, IPv6
}

/// Represents an IPv4 or IPv6 address.
struct Address: Printable {
    var type: AddressType
    var address: [UInt8]
    var hostname: String?

    /**
     * Resolves an address from the given hostname.
     *
     * :param: hostname Hostname to resolve.
     * :returns: Address, or nil if the hostname could not be resolved.
     */
    static func fromHostname(hostname: String) -> Address? {
        let hostnameCStr = hostname.cStringUsingEncoding(1) // ASCII
        if hostnameCStr == nil {
            return nil
        }

        // Resolve the hostname. We try resolving an IPv6 address
        // first, and fall back to IPv4 if that fails.
        var type = AddressType.IPv6
        var host = gethostbyname2(hostnameCStr!, AF_INET6)
        if host == nil {
            type = AddressType.IPv4
            host = gethostbyname(hostnameCStr!)
            if host == nil {
                return nil
            }
        }

        // Create an array containing the address.
        var address: [UInt8]?
        if type == .IPv4 {
            address = [UInt8](count: 4, repeatedValue: 0)
            for i in 0..<4 {
                address![i] = UInt8(bitPattern: host.memory.h_addr_list[0][i])
            }
        } else {
            address = [UInt8](count: 16, repeatedValue: 0)
            for i in 0..<16 {
                address![i] = UInt8(bitPattern: host.memory.h_addr_list[0][i])
            }
        }

        return Address(type: type, address: address!, hostname: hostname)
    }

    /// String representation of the IPv4/IPv6 address.
    var addressString: String {
        var s = ""

        if type == .IPv4 {
            for i in 0..<4 {
                if count(s) > 0 {
                    s += "."
                }

                s += address[i].description
            }
        } else {
            for i in 0..<16 {
                if count(s) > 0 {
                    s += ":"
                }

                s += String(address[i], radix: 16, uppercase: false)
            }
        }

        return s
    }

    /// Hostname if set, otherwise the IPv4/IPv6 address.
    var description: String {
        return hostname ?? addressString
    }
}
