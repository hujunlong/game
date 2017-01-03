# This file is referenced from the Skynet makefile
.PHONY: all skynet
UNAME ?= $(shell uname)
THIRD_LIB_ROOT ?= ./lib

SKYNET_ROOT ?= $(THIRD_LIB_ROOT)/skynet

CJSON_ROOT ?= $(THIRD_LIB_ROOT)/lua-cjson
CJSON_INC ?= ../skynet/3rd/lua

#SKYNET_BUILD_PATH ?= .
LUA_CLIB_PATH ?= server/luaclib
MCSERVICE_PATH ?= server/cservice

CFLAGS = -g -O2 -Wall -I$(LUA_INC) 

# lua
LUA_STATICLIB ?= $(SKYNET_ROOT)/3rd/lua/liblua.a
LUA_LIB ?= $(LUA_STATICLIB)
LUA_INC ?= $(SKYNET_ROOT)/3rd/lua

LUA_SOCKET_PATH ?= $(THIRD_LIB_ROOT)/lua-socket

ifeq ($(UNAME), Darwin)
SHARED ?= -fPIC -dynamiclib -Wl,-undefined,dynamic_lookup


#cmd for building skynet
SKYNET_MAKE_CMD =  make -C $(SKYNET_ROOT) macosx