include config.mk

DEBUG ?= 1
ifeq ($(DEBUG), 1)
	CFLAGS+=${DEBUG_FLAGS}
else
	CFLAGS+=${RELEASE_FLAGS}
endif

all:	options gen_model ${OMODEL} ${BUILDDIR}/aimotive_inference

aimotive_inference:
	if [ ! -d "build" ]; then \
		mkdir build; \
	fi

.c.o:
	${CC} -c ${CFLAGS} $<

options:
	@echo	"aimotive test aarch64 native inference - BencsikG"
	@echo	"CFLAGS	=	${CFLAGS}"
	@echo	"CC	=	${CC}"

gen_model:
	python model/model_to_cpp.py -a model/aimotive_test.json -w model/aimotive_test.h5 -v1 -o model/model

${OBJDIR}/model.o: ${MODELSRC}
	@echo	"Compiling model.o"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} -c -o $@ ${MODELSRC} -I model/

${BUILDDIR}/aimotive_inference: ${SRCDIR}/inference.c ${OBJ}
	@echo	"Compiling aimotive_inference"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} $< -o $@ -I model/ 

run:
	qemu-aarch64 ${BUILDDIR}/aimotive_inference -m 1M -cpu cortex-a53 -nographic 

clean:
	if [ -d "${BUILDDIR}" ]; then \
		rm -rf ${BUILDDIR}/; \
	fi

.PHONY:	all	options	run	clean

