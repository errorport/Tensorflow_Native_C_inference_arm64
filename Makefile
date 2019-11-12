include config.mk

all:	options aimotive_inference

aimotive_inference:
	if [ ! -d "build" ]; then \
		mkdir build; \
	fi

DEBUG ?= 1
ifeq ($(DEBUG), 1)
	CFLAGS+=${DEBUG_FLAGS}
else
	CFLAGS+=${RELEASE_FLAGS}
endif

all:	options gen_model ${OBJDIR}/model.o

.c.o:
	${CC} -c ${CFLAGS} $<

options:
	@echo	"aimotive test aarch64 native inference - BencsikG"
	@echo	"CFLAGS	=	${CFLAGS}"
	@echo	"CC	=	${CC}"

gen_model:
	python model/model_to_cpp.py -a model/aimotive_test.json -w model/aimotive_test.h5 -v1 -o model/model

${OBJDIR}/model.o: model/model.h model/model.c
	@echo	"Compiling model.o"
	mkdir -p '${@D}'
	${CC} -c ${CFLAGS} $< -o $@

run:
	qemu-aarch64 build/aimotive_inference -m 1M -cpu cortex-a53 -nographic 

clean:
	if [ -d "build" ]; then \
		rm -rf build/; \
	fi

.PHONY:	all	options	run	clean

