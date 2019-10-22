#!/bin/bash
conda build --variants "{'ctng_target_platform': ['lm32-elf-nostdc'], 'ctng_target_platform_short': ['lm32-elf'], 'ctng_libc': ['nostdc'], 'ctng_cpu_arch': ['lm32']}" ../../recipe/binaries/ -c antmicro
conda build --variants "{'ctng_target_platform': ['lm32-elf-nostdc'], 'ctng_target_platform_short': ['lm32-elf'], 'ctng_libc': ['nostdc'], 'ctng_cpu_arch': ['lm32']}" ../../recipe/activation_scripts/ -c antmicro
