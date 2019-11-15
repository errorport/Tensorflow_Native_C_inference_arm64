CC=aarch64-unknown-linux-gnu-gcc
CFLAGS=-std=c99 -static

RELEASE_FLAGS=-O2
DEBUG_FLAGS=-O0 -DDEBUG -g3 -ggdb

LDFLAGS=-lm

SRCDIR=src
BUILDDIR=build
OBJDIR=build/obj

MODELSRC=model/model.c
UTILSSRC=src/utils.c
TESTSRC=src/test.c
SRCS=${MODELSRC} ${UTILSSRC}

OMODEL=${OBJDIR}/model.o
OUTILS=${OBJDIR}/utils.o
OTEST=${BUILDDIR}/test
OINFERENCE=${BUILDDIR}/inference
OBJ=${OMODEL} ${OUTILS} ${OTEST}

MODEL_JSON_FILE=model/model.json
MODEL_H5_FILE=model/model.h5
MODEL_FILES=${MODEL_JSON_FILE} ${MODEL_H5_FILE}
MODEL_CONVERTER=model/model_to_cpp.py
MODEL_DEPS=${MODEL_FILES} ${MODEL_CONVERTER}

BINS=${OBJ} ${OINFERENCE} ${OTEST}

INPUT_FILE_NAME=
