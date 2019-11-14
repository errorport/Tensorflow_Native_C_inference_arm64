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
SRCS=${MODELSRC} ${UTILSSRC}

OMODEL=${OBJDIR}/model.o
OUTILS=${OBJDIR}/utils.o
OINFERENCE=${BUILDDIR}/aimotive_inference
OBJ=${OMODEL} ${OUTILS}

MODEL_FILES=model/aimotive_test.h5 model/aimotive_test.json
MODEL_CONVERTER=model/model_to_cpp.py
MODEL_DEPS=${MODEL_FILES} ${MODEL_CONVERTER}

BINS=${OMODEL} ${OUTILS} ${OINFERENCE}
