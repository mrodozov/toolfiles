#!/bin/bash -x

toolfolder=${1}

GCC_PATH=`which gcc` || exit 1
GCC_ROOT=`echo $GCC_PATH | sed -e 's|/bin/gcc||'`
G77__ROOT=$GCC_ROOT
export GCC_ROOT
export G77__ROOT

# General substitutions
perl -p -i -e 's|\@([^@]*)\@|$ENV{$1}|g' ${toolfolder}/llvm-f77compiler.xml
