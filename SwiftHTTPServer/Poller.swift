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

import Foundation

/// Polls a list of sockets for activity, and calls a closure
/// associated with a particular socket when it has data available.
class Poller {
    private var pollfds: [pollfd] = []
    private var closures: [Int32: (Int32) -> ()] = [:]

    /**
     * Adds a socket to be polled.
     *
     * :param: socket Integer representing the socket to be polled.
     * :param: closure Closure to execute when the socket has data available.
     */
    func addSocket(socket: Int32, closure: (Int32) -> ()) {
        pollfds.append(pollfd(fd: socket, events: Int16(POLLIN), revents: 0))
        closures[socket] = closure
    }

    /**
     * Remove a socket so that it is no longer polled.
     *
     * :param: socket Integer representing the socket to stop polling.
     */
    func removeSocket(socket: Int32) {
        var index = -1
        for i in 0..<pollfds.count {
            if pollfds[i].fd == socket {
                index = i
            }
        }

        if index != -1 {
            pollfds.removeAtIndex(index)
        }
    }

    /// Poll the sockets and execute closures for any that have data available.
    func run() {
        let sleepTime: Int32 = 1000

        if poll(&pollfds, nfds_t(pollfds.count), sleepTime) > 0 {
            for pfd in pollfds {
                if (pfd.revents & Int16(POLLIN)) == Int16(POLLIN) {
                    if let closure = closures[pfd.fd] {
                        closure(pfd.fd)
                    }
                }
            }
        }
    }
}
