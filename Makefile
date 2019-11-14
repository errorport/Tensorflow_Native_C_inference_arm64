include config.mk

DEBUG ?= 1
ifeq ($(DEBUG), 1)
	CFLAGS+=${DEBUG_FLAGS}
else
	CFLAGS+=${RELEASE_FLAGS}
endif

all:	options gen_model ${BINS}

only_bin: options ${BINS}

options:
	@echo	"aimotive test aarch64 native inference - BencsikG"
	@echo	"CFLAGS  =	${CFLAGS}"
	@echo	"LDFLAGS =	${LDFLAGS}"
	@echo	"CC      =	${CC}"

gen_model: ${MODEL_DEPS}
	@echo	"Generating the model sources"
	python model/model_to_cpp.py -a model/aimotive_test.json -w model/aimotive_test.h5 -v1 -o model/model

${OMODEL}: ${MODELSRC}
	@echo	"Compiling model.o"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} -c -o $@ ${MODELSRC} -I model/

${OUTILS}: ${UTILSSRC}
	@echo	"Compiling utils.o"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} -c -o $@ ${UTILSSRC} -I src/

${OINFERENCE}: ${SRCDIR}/inference.c ${OBJ} ${SRCS}
	@echo	"Compiling aimotive_inference"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} $< -o $@ ${SRCS} -I model/ -I src/ ${LDFLAGS}

run:
	qemu-aarch64 ${BUILDDIR}/aimotive_inference -m 1M -cpu cortex-a53 -nographic 

clean:
	if [ -d "${BUILDDIR}" ]; then \
		rm -rf ${BUILDDIR}/; \
	fi
	if [ -f "${MODELSRC}" ]; then \
		rm ${MODELSRC};\
	fi
	if [ -f "model/model.h" ]; then \
		rm model/model.h;\
	fi

.PHONY:	all	options	run	clean

