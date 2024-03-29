# conda-toolchains

[Conda](https://anaconda.org) build recipes for RISC-V, OpenRISC and LM32 toolchains.

## Content

This repository contains conda recipes for building toolchains
(binutils + gcc cross-compiler) in different configurations using the
[crosstool-ng](https://github.com/crosstool-ng/crosstool-ng) generator.

Currently supported target architectures and configurations are:

* RISC-V 32-bit
  * nostdc
  * newlib
  * linux-musl
* OpenRISC (or1k)
  * nostdc
  * newlib
  * linux-musl
* LM32
  * nostdc
  * newlib

The repository contains also a `.ci.yml` file with an example of a CI/CD
configuration that can  be used to automatically generate the toolchains.

The CI system used is based on [GitLab CI](https://docs.gitlab.com/ee/ci/).

It follows the instructions described below, to create `toolchain-*` packages available on [Antmicro's conda channel](https://anaconda.org/antmicro/repo).

This repository uses patched versions of `crosstool-ng` and `musl`.
All patches are available in `recipe/patches`.

## Pre-built versions

To install the pre-built packages with Conda, call:

```
conda install -c antmicro {TOOLCHAIN_NAME}
```

To install them, run:

```
conda install -c antmicro {TOOLCHAIN_NAME}
```

## Building recipes

The instructions below are targeted for Ubuntu 18.04.
Please adapt package names for other distributions.

1. Download prerequisites:

```
sudo apt install file patch curl build-essential libncurses5-dev libncursesw5-dev
```

2. Install `anaconda`:

```
curl -O https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh
./Anaconda3-2019.03-Linux-x86_64.sh -b -p "$PWD/anaconda"
export PATH="$PWD/anaconda/bin:$PATH"
```

The instructions above download `anaconda`, install it in the current directory
and set the `PATH` environment variable accordingly to make the `conda` command accessible.

3. Build a selected toolchain:

```
export TOOLCHAIN_VARIANT=riscv32-linux-musl
conda build recipe/toolchains
```

The instructions above select toolchain configuration and start the build process.
Once the building is finished, the resulting conda package is located in `anaconda/conda-bld/linux-64/`.

A toolchain variant consists of three parts:

* architecture
  * riscv32
  * or1k
  * lm32
* variant
  * elf
  * linux
* standard library type
  * nostdc
  * newlib
  * musl
