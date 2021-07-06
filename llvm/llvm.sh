#!/bin/bash -x

toolfolder=${1}

GCC_PATH=`which gcc` || exit 1
GCC_ROOT=`echo $GCC_PATH | sed -e 's|/bin/gcc||'`
G77_ROOT=$GCC_ROOT
export GCC_ROOT
export G77_ROOT

cat << \EOF_TOOLFILE >${toolfolder}/llvm-f77compiler.xml
  <tool name="llvm-f77compiler" version="@TOOL_VERSION@" type="compiler">
    <use name="gcc-f77compiler"/>
    <client>
      <environment name="FC" default="@G77_ROOT@/bin/gfortran"/>
    </client>
  </tool>
EOF_TOOLFILE

# General substitutions
perl -p -i -e 's|\@([^@]*)\@|$ENV{$1}|g' ${toolfolder}/llvm-f77compiler.xml
