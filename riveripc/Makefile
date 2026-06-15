CC      := cc
CFLAGS  := -Wall -Wextra -O2
PREFIX  ?= /usr/local

WAYLAND_CFLAGS  := $(shell pkg-config --cflags wayland-client)
WAYLAND_LIBS    := $(shell pkg-config --libs wayland-client)
WAYLAND_SCANNER := $(shell pkg-config --variable=wayland_scanner wayland-scanner)

PROTO_DIR := protocols

PROTO1_XML := $(PROTO_DIR)/river-status-unstable-v1.xml
PROTO1_C   := $(PROTO_DIR)/river-status-unstable-v1-protocol.c
PROTO1_H   := $(PROTO_DIR)/river-status-unstable-v1-client-protocol.h

PROTO_HEADERS := $(PROTO1_H)

SRCS := main.c $(PROTO1_C)
OBJS := $(SRCS:.c=.o)

all: riveripc

$(PROTO1_H): $(PROTO1_XML)
	$(WAYLAND_SCANNER) client-header $< $@

$(PROTO1_C): $(PROTO1_XML) $(PROTO1_H)
	$(WAYLAND_SCANNER) private-code $< $@

%.o: %.c $(PROTO_HEADERS)
	$(CC) $(CFLAGS) $(WAYLAND_CFLAGS) -c $< -o $@

riveripc: $(OBJS)
	$(CC) $(OBJS) $(WAYLAND_LIBS) -o $@

install: riveripc
	install -Dm755 riveripc $(DESTDIR)$(PREFIX)/bin/riveripc

clean:
	rm -f $(OBJS) $(PROTO1_C) $(PROTO1_H) riveripc

.PHONY: all install clean
