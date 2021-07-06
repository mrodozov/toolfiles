#!/bin/bash -x

toolfolder=${1}

GCC_PATH=`which gcc` || exit 1
GCC_ROOT=`echo $GCC_PATH | sed -e 's|/bin/gcc||'`
G77_ROOT=$GCC_ROOT
OS_RUNTIME_LDPATH_NAME="LD_LIBRARY_PATH"
export OS_RUNTIME_LDPATH_NAME
export GCC_ROOT
export G77_ROOT

cat << \EOF_TOOLFILE >${toolfolder}/llvm-cxxcompiler.xml
  <tool name="llvm-cxxcompiler" version="@TOOL_VERSION@" type="compiler">
    <use name="gcc-cxxcompiler"/>
    <client>
      <environment name="LLVM_CXXCOMPILER_BASE" default="@TOOL_ROOT@"/>
      <environment name="CXX" value="$LLVM_CXXCOMPILER_BASE/bin/clang++"/>
    </client>
    # drop flags not supported by llvm
    # -Wno-non-template-friend removed since it's not supported, yet, by llvm.
    <flags REM_CXXFLAGS="-Wno-non-template-friend"/>
    <flags REM_CXXFLAGS="-Werror=format-contains-nul"/>
    <flags REM_CXXFLAGS="-Werror=maybe-uninitialized"/>
    <flags REM_CXXFLAGS="-Werror=unused-but-set-variable"/>
    <flags REM_CXXFLAGS="-Werror=return-local-addr"/>
    <flags REM_CXXFLAGS="-fipa-pta"/>
    <flags REM_CXXFLAGS="-fipa-pta"/>
    <flags REM_CXXFLAGS="-frounding-math"/>
    <flags REM_CXXFLAGS="-mrecip"/>
    <flags REM_CXXFLAGS="-fno-crossjumping"/>
    <flags REM_CXXFLAGS="-fno-aggressive-loop-optimizations"/>
    <flags REM_CXXFLAGS="-funroll-all-loops"/>
    <flags CXXFLAGS="-Wno-c99-extensions"/>
    <flags CXXFLAGS="-Wno-c++11-narrowing"/>
    <flags CXXFLAGS="-D__STRICT_ANSI__"/>
    <flags CXXFLAGS="-Wno-unused-private-field"/>
    <flags CXXFLAGS="-Wno-unknown-pragmas"/>
    <flags CXXFLAGS="-Wno-unused-command-line-argument"/>
    <flags CXXFLAGS="-Wno-unknown-warning-option"/>
    <flags CXXFLAGS="-ftemplate-depth=512"/>
    <flags CXXFLAGS="-Wno-error=potentially-evaluated-expression"/>
    <flags CXXFLAGS="-Wno-tautological-type-limit-compare"/>
    <flags CXXFLAGS="-fsized-deallocation"/>
    <runtime name="@OS_RUNTIME_LDPATH_NAME@" value="$LLVM_CXXCOMPILER_BASE/lib64" type="path"/>
    <runtime name="PATH" value="$LLVM_CXXCOMPILER_BASE/bin" type="path"/>
  </tool>
EOF_TOOLFILE

cat << \EOF_TOOLFILE >${toolfolder}/llvm-f77compiler.xml
  <tool name="llvm-f77compiler" version="@LLVM_VERSION@" type="compiler">
    <use name="gcc-f77compiler"/>
    <client>
      <environment name="FC" default="@G77_ROOT@/bin/gfortran"/>
    </client>
  </tool>
EOF_TOOLFILE


# General substitutions
perl -p -i -e 's|\@([^@]*)\@|$ENV{$1}|g' ${toolfolder}/llvm-f77compiler.xml
