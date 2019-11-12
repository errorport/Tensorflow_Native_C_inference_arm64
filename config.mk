CC=aarch64-unknown-linux-gnu-gcc
CFLAGS=-std=c99 -static

RELEASE_FLAGS=-O2
DEBUG_FLAGS=-O0 -DDEBUG -g3 -ggdb

OBJDIR=build/obj

OBJ=${OBJDIR}/model.o
