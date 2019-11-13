CC=aarch64-unknown-linux-gnu-gcc
CFLAGS=-std=c99 -static

RELEASE_FLAGS=-O2
DEBUG_FLAGS=-O0 -DDEBUG -g3 -ggdb

SRCDIR=src
BUILDDIR=build
OBJDIR=build/obj

MODELSRC=model/model.c
OMODEL=${OBJDIR}/model.o

OBJ=${OMODEL}
