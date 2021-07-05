#!/bin/bash -x

toolfolder=${1}

if [ "X$GCC_ROOT" = X ]
then
    export GCC_PATH=$(which gcc) || exit 1
    export GCC_ROOT=$(echo $GCC_PATH | sed -e 's|/bin/gcc||')
    export GCC_VERSION=$(gcc -dumpversion) || exit 1
    export G77_ROOT=$GCC_ROOT
else
    export GCC_PATH
    export GCC_ROOT
    export GCC_VERSION
    export G77_ROOT=$GCC_ROOT
fi

export ARCH_FFLAGS="-cpp"
SCRAM_CXX11_ABI=1
echo '#include <string>' | g++ -x c++ -E -dM - | grep ' _GLIBCXX_USE_CXX11_ABI  *1' || SCRAM_CXX11_ABI=0
export SCRAM_CXX11_ABI
export COMPILER_VERSION=$(gcc -dumpversion)
export COMPILER_VERSION_MAJOR=$(echo $COMPILER_VERSION | cut -d'.' -f1)
export COMPILER_VERSION_MINOR=$(echo $COMPILER_VERSION | cut -d'.' -f2)

# Generic template for the toolfiles. 
# *** USE @VARIABLE@ plus associated environment variable to customize. ***
# DO NOT DUPLICATE the toolfile template.

cat << \EOF_TOOLFILE >${toolfolder}/gcc-cxxcompiler.xml
  <tool name="gcc-cxxcompiler" version="@GCC_VERSION@" type="compiler">
<client>
      <environment name="GCC_CXXCOMPILER_BASE" default="@GCC_ROOT@"/>
      <environment name="CXX" value="$GCC_CXXCOMPILER_BASE/bin/c++@COMPILER_NAME_SUFFIX@"/>
     </client>
    <flags CPPDEFINES="GNU_GCC _GNU_SOURCE @OS_CPPDEFINES@ @ARCH_CPPDEFINES@ @COMPILER_CPPDEFINES@"/>
    <flags CXXSHAREDOBJECTFLAGS="-fPIC @OS_CXXSHAREDOBJECTFLAGS@ @ARCH_CXXSHAREDOBJECTFLAGS@ @COMPILER_CXXSHAREDOBJECTFLAGS@"/>
    <flags CXXFLAGS="-O2 -pthread -pipe -Werror=main -Werror=pointer-arith"/>
    <flags CXXFLAGS="-Werror=overlength-strings -Wno-vla @OS_CXXFLAGS@ @ARCH_CXXFLAGS@ @COMPILER_CXXFLAGS@"/>
    <flags CXXFLAGS="-felide-constructors -fmessage-length=0"/>
    <flags CXXFLAGS="-Wall -Wno-non-template-friend -Wno-long-long -Wreturn-type"/>
    <flags CXXFLAGS="-Wextra -Wpessimizing-move -Wclass-memaccess"/>
    <flags CXXFLAGS="-Wno-cast-function-type -Wno-unused-but-set-parameter -Wno-ignored-qualifiers -Wno-deprecated-copy -Wno-unused-parameter"/>
    <flags CXXFLAGS="-Wunused -Wparentheses -Wno-deprecated -Werror=return-type"/>
    <flags CXXFLAGS="-Werror=missing-braces -Werror=unused-value"/>
    <flags CXXFLAGS="-Werror=unused-label"/>
    <flags CXXFLAGS="-Werror=address -Werror=format -Werror=sign-compare"/>
    <flags CXXFLAGS="-Werror=write-strings -Werror=delete-non-virtual-dtor"/>
    <flags CXXFLAGS="-Werror=strict-aliasing"/>
    <flags CXXFLAGS="-Werror=narrowing"/>
    <flags CXXFLAGS="-Werror=unused-but-set-variable -Werror=reorder"/>
    <flags CXXFLAGS="-Werror=unused-variable -Werror=conversion-null"/>
    <flags CXXFLAGS="-Werror=return-local-addr -Wnon-virtual-dtor"/>
    <flags CXXFLAGS="-Werror=switch -fdiagnostics-show-option"/>
    <flags CXXFLAGS="-Wno-unused-local-typedefs -Wno-attributes -Wno-psabi"/>
EOF_TOOLFILE
if [[ $(arch) == x86_64 ]] ; then
for vv in ${PKG_VECTORIZATION} ; do
  uvv=$(echo $vv | tr [a-z-] [A-Z_] | tr '.' '_')
  echo "    <flags CXXFLAGS_TARGETS_${uvv}=\"${vv}\"/>" >> ${toolfolder}/gcc-cxxcompiler.xml
done
fi
cat << \EOF_TOOLFILE >>${toolfolder}/gcc-cxxcompiler.xml
    <flags LDFLAGS="@OS_LDFLAGS@ @ARCH_LDFLAGS@ @COMPILER_LDFLAGS@"/>
    <flags CXXSHAREDFLAGS="@OS_SHAREDFLAGS@ @ARCH_SHAREDFLAGS@ @COMPILER_SHAREDFLAGS@"/>
    <flags LD_UNIT="@OS_LD_UNIT@ @ARCH_LD_UNIT@ @COMPILER_LD_UNIT@"/>
    <runtime name="@OS_RUNTIME_LDPATH_NAME@" value="$GCC_CXXCOMPILER_BASE/@ARCH_LIB64DIR@" type="path"/>
    <runtime name="@OS_RUNTIME_LDPATH_NAME@" value="$GCC_CXXCOMPILER_BASE/lib" type="path"/>
    <runtime name="SCRAM_CXX11_ABI" value="@SCRAM_CXX11_ABI@"/>
    <runtime name="PATH" value="$GCC_CXXCOMPILER_BASE/bin" type="path"/>
    <ifrelease name="_ASAN">
      <runtime name="GCC_RUNTIME_ASAN" value="$GCC_CXXCOMPILER_BASE/@ARCH_LIB64DIR@/libasan.so" type="path"/>
    <elif name="_LSAN"/>
      <runtime name="GCC_RUNTIME_LSAN" value="$GCC_CXXCOMPILER_BASE/@ARCH_LIB64DIR@/libasan.so" type="path"/>
    <elif name="_UBSAN"/>
      <runtime name="GCC_RUNTIME_UBSAN" value="$GCC_CXXCOMPILER_BASE/@ARCH_LIB64DIR@/libubsan.so" type="path"/>
    <elif name="_TSAN"/>
      <runtime name="GCC_RUNTIME_TSAN" value="$GCC_CXXCOMPILER_BASE/@ARCH_LIB64DIR@/libtsan.so" type="path"/>
    </ifrelease>
    <runtime name="COMPILER_PATH"    value="@GCC_ROOT@"/>
  </tool>
EOF_TOOLFILE

export GCC_PLUGIN_DIR=$(gcc -print-file-name=plugin)

# NON-empty defaults
# First of all handle OS specific options.

export OS_SHAREDFLAGS="-shared -Wl,-E"
export OS_LDFLAGS="-Wl,-E -Wl,--hash-style=gnu"
export OS_RUNTIME_LDPATH_NAME="LD_LIBRARY_PATH"
export OS_CXXFLAGS="-Werror=overflow"

# Then handle OS + architecture specific options (maybe we should enable more
# aggressive optimizations for amd64 as well??)
# For some reason on mac, some of the header do not compile if this is
# defined.  Ignore for now.

export ARCH_LIB64DIR="lib64"
export ARCH_LD_UNIT="-r -z muldefs"

# Then handle compiler specific options. E.g. enable
# optimizations as they become available in gcc.

COMPILER_CXXFLAGS=
COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS -std=c++1z -ftree-vectorize"
COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS -Wstrict-overflow"
COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS -Werror=array-bounds -Werror=format-contains-nul -Werror=type-limits"
COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS -fvisibility-inlines-hidden"
COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS -fno-math-errno --param vect-max-version-for-alias-checks=50"
COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS -Xassembler --compress-debug-sections"
COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS $COMP_ARCH_SPECIFIC_FLAGS"

export COMPILER_CXXFLAGS
# General substitutions
$(perl -p -i -e 's|\@([^@]*)\@|$ENV{$1}|g' ${toolfolder}/*.xml)
