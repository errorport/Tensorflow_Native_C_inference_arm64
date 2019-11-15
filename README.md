# Simple Tensorflow Native C inference for ARM64
Without Tensorflow API!

## Requirements

| Package | Version | Hint |
| ------- | ------- | ---- |
| qemu-aarch64 | 4.0.0 | with xattr |
| aarch64-unknown-linux-gnu-gcc | 8.3.0 | Tested with Gentoo 8.3.0-r1 p1.1 (crossdev-20190702) |
| GNU Make | 4.2.1 | |
| Python3 | 3.6.5 | |
| tensorflow | 2.0.0 | pip package |
| numpy | 1.14.5 | pip package |

## Compiling

For the first time, make does the hard job:

```sh
make
```

* Trains the model. (Check out the *model/toy\_mnist\_eval.py*)
* Generates the model sources and headers.
* Generates the test files. (Only for manual test.)
* Compiles the model object.
* Compiles the utility object.
* Compiles the inference executable.

See the __Makefile__ for more details.

## Running

One should pass a testfile's name to the run option like:

```sh
make run INPUT_FILE_NAME=test/x_test_00000
```

See the *test/* directory for more test files.

## Debug mode

It is possible to compile to debug.

```sh
make DEBUG=1
```

