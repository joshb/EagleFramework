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

#include <fcntl.h>
#include <netinet/in.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>

#include "CUtil.h"

int myClose(int fd) {
    return close(fd);
}

int myBind(int ipv4, const uint8_t *address, uint16_t port) {
    int fd;

    if(ipv4) {
        fd = socket(AF_INET, SOCK_STREAM, 0);
        if(fd == -1)
            return -1;

        int value = 1;
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &value, sizeof(value));

        struct sockaddr_in sin;
        bzero(&sin, sizeof(sin));
        sin.sin_family = AF_INET;
        sin.sin_port = htons(port);
        memcpy(&sin.sin_addr, address, 4);
        socklen_t len = sizeof(sin);

        if(bind(fd, (struct sockaddr *)&sin, len) == -1) {
            close(fd);
            return -1;
        }
    } else {
        fd = socket(AF_INET6, SOCK_STREAM, 0);
        if(fd == -1)
            return -1;

        int value = 1;
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &value, sizeof(value));

        struct sockaddr_in6 sin;
        bzero(&sin, sizeof(sin));
        sin.sin6_family = AF_INET6;
        sin.sin6_port = htons(port);
        memcpy(&sin.sin6_addr, address, 16);
        socklen_t len = sizeof(sin);

        if(bind(fd, (struct sockaddr *)&sin, len) == -1) {
            close(fd);
            return -1;
        }
    }

    if(listen(fd, 0) == -1) {
        close(fd);
        return -1;
    }

    return fd;
}

int myAccept(int fd, int ipv4, uint8_t *address, uint16_t *port) {
    int new_fd;

    if(ipv4) {
        struct sockaddr_in sin;
        bzero(&sin, sizeof(sin));
        socklen_t len = sizeof(sin);

        new_fd = accept(fd, (struct sockaddr *)&sin, &len);
        if(new_fd == -1)
            return -1;

        memcpy(address, &sin.sin_addr, 4);
        *port = ntohs(sin.sin_port);
    } else {
        struct sockaddr_in6 sin;
        bzero(&sin, sizeof(sin));
        socklen_t len = sizeof(sin);

        new_fd = accept(fd, (struct sockaddr *)&sin, &len);
        if(new_fd == -1)
            return -1;

        memcpy(address, &sin.sin6_addr, 16);
        *port = ntohs(sin.sin6_port);
    }

    // Make the socket non-blocking.
    if(fcntl(new_fd, F_SETFL, O_NONBLOCK) == -1) {
        close(new_fd);
        return -1;
    }

    return new_fd;
}

ssize_t mySend(int fd, const char *s, size_t length) {
    return send(fd, s, length, 0);
}

ssize_t myRecv(int fd, char *s, size_t length) {
    return recv(fd, s, length, 0);
}

long getMilliseconds()
{
    struct timeval tv;
    if(gettimeofday(&tv, NULL) == -1)
        return 0;
    return ((long)tv.tv_sec * 1000) + ((long)tv.tv_usec / 1000);
}
