#!/bin/bash -x

toolfolder=${1}

if [ "X$GCC_ROOT" = X ]
then
    GCC_PATH=`which gcc` || exit 1
    GCC_VERSION=`gcc -dumpversion` || exit 1
    GCC_ROOT=`echo $GCC_PATH | sed -e 's|/bin/gcc||'`
    G77_ROOT=$GFORTRAN_MACOSX_ROOT
else
    G77_ROOT=$GCC_ROOT
fi
export GCC_ROOT
export G77_ROOT

# General substitutions
perl -p -i -e 's|\@([^@]*)\@|$ENV{$1}|g' ${toolfolder}/llvm-f77compiler.xml
