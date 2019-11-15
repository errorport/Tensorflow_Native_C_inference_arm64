include config.mk

DEBUG ?= 1
ifeq ($(DEBUG), 1)
	CFLAGS+=${DEBUG_FLAGS}
else
	CFLAGS+=${RELEASE_FLAGS}
endif

all:	options train_model gen_model ${BINS} postcompile

only_bin: options ${BINS}

options:
	@echo	"TF aarch64 native inference without TF - BencsikG"
	@echo	"CFLAGS  =	${CFLAGS}"
	@echo	"LDFLAGS =	${LDFLAGS}"
	@echo	"CC      =	${CC}"

train_model:
	@echo	"Training model"
	python 	model/toy_mnist_eval.py ${MODEL_H5_FILE} ${MODEL_JSON_FILE}

gen_model: ${MODEL_DEPS}
	@echo	"Generating the model sources"
	python model/model_to_cpp.py -a ${MODEL_JSON_FILE} -w ${MODEL_H5_FILE} -v1 -o model/model
	@echo	"Generating test set"
	python test/gen_test.py test/

${OMODEL}: ${MODELSRC}
	@echo	"Compiling model.o"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} -c -o $@ ${MODELSRC} -I model/

${OUTILS}: ${UTILSSRC}
	@echo	"Compiling utils.o"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} -c -o $@ ${UTILSSRC} -I src/

${OTEST}: ${TESTSRC}
	@echo	"Compiling test"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} $< -o $@ ${OUTILS} -I model/ -I src/ ${LDFLAGS}

${OINFERENCE}: ${SRCDIR}/inference.c ${OBJ} ${SRCS}
	@echo	"Compiling inference"
	mkdir -p '${@D}'
	${CC} ${CFLAGS} $< -o $@ ${SRCS} -I model/ -I src/ ${LDFLAGS}

postcompile:
	aarch64-unknown-linux-gnu-strip ${OINFERENCE}

run:
	qemu-aarch64 ${OINFERENCE} ${INPUT_FILE_NAME} -m 1M -cpu cortex-a53 -nographic 

runtest:
	qemu-aarch64 ${OTEST} -m 1M -cpu cortex-a53 -nographic 


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

