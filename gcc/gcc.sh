### RPM cms gcc-toolfile 16.0
## INCLUDE compilation_flags
# gcc has a separate spec file for the generating a 
# toolfile because gcc.spec could be not build because of the 
# "--use-system-compiler" option.

#%{expand:%(i=90; for v in %{package_vectorization}; do let i=$i+1 ; echo Source${i}: vectorization/$v; done)}
# Determine the GCC_ROOT if "use system compiler" is used.

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
$(echo '#include <string>' | g++ -x c++ -E -dM - | grep ' _GLIBCXX_USE_CXX11_ABI  *1' || SCRAM_CXX11_ABI=0)
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
#%ifarch x86_64
#for v in %{package_vectorization} ; do
#  uv=$(echo $v | tr [a-z-] [A-Z_] | tr '.' '_')
#  echo "    <flags CXXFLAGS_TARGETS_${uv}=\"$(%{cmsdist_directory}/vectorization/cmsdist_packages.py $v)\"/>" >> ${toolfolder}/gcc-cxxcompiler.xml
#done
#%endif
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

cat << \EOF_TOOLFILE >${toolfolder}/gcc-ccompiler.xml
  <tool name="gcc-ccompiler" version="@GCC_VERSION@" type="compiler">
    <client>
      <environment name="GCC_CCOMPILER_BASE" default="@GCC_ROOT@"/>
      <environment name="CC" value="$GCC_CCOMPILER_BASE/bin/gcc@COMPILER_NAME_SUFFIX@"/>
    </client>
    <flags CSHAREDOBJECTFLAGS="-fPIC @OS_CSHAREDOBJECTFLAGS@ @ARCH_CSHAREDOBJECTFLAGS@ @COMPILER_CSHAREDOBJECTFLAGS@"/>
    <flags CFLAGS="-O2 -pthread @OS_CFLAGS@ @ARCH_CFLAGS@ @COMPILER_CFLAGS@"/>
  </tool>
EOF_TOOLFILE

# Notice that on OSX we have a LIBDIR defined for f77compiler because gcc C++
# compiler (which comes from the system) does not know about where to find
# libgfortran. 
cat << \EOF_TOOLFILE >${toolfolder}/gcc-f77compiler.xml
  <tool name="gcc-f77compiler" version="@GCC_VERSION@" type="compiler">
    <lib name="gfortran"/>
    <lib name="m"/>
    <client>
      <environment name="GCC_F77COMPILER_BASE" default="@G77_ROOT@"/>
      <environment name="FC" default="$GCC_F77COMPILER_BASE/bin/gfortran"/>
      @ARCH_FORTRAN_LIBDIR@
    </client>
    <flags FFLAGS="-fno-second-underscore -Wunused -Wuninitialized -O2 @OS_FFLAGS@ @ARCH_FFLAGS@ @COMPILER_FFLAGS@"/>
    <flags FFLAGS="-std=legacy"/>
    <flags FOPTIMISEDFLAGS="-O2 @OS_FOPTIMISEDFLAGS@ @ARCH_FOPTIMISEDFLAGS@ @COMPILER_FOPTIMISEDFLAGS@"/>
    <flags FSHAREDOBJECTFLAGS="-fPIC @OS_FSHAREDOBJECTFLAGS@ @ARCH_FSHAREDOBJECTFLAGS@ @COMPILER_FSHAREDOBJECTFLAGS@"/>
  </tool>
EOF_TOOLFILE

# GCC tool file for explicitly linking against libstdc++fs
cat << \EOF_TOOLFILE >${toolfolder}/stdcxx-fs.xml
  <tool name="stdcxx-fs" version="@GCC_VERSION@">
    <lib name="stdc++fs"/>
  </tool>
EOF_TOOLFILE

# GCC tool file for explicitly linking against libatomic
cat << \EOF_TOOLFILE >${toolfolder}/gcc-atomic.xml
  <tool name="gcc-atomic" version="@GCC_VERSION@">
    <lib name="atomic"/>
    <client>
      <environment name="GCC_ATOMIC_BASE" default="@GCC_ROOT@"/>
    </client>
  </tool>
EOF_TOOLFILE

# GCC tool file for explicity linking gcc plugin library
cat << \EOF_TOOLFILE >${toolfolder}/gcc-plugin.xml
  <tool name="gcc-plugin" version="@GCC_VERSION@">
    <lib name="cc1plugin cp1plugin"/>
    <client>
      <environment name="GCC_PLUGIN_BASE" default="@GCC_PLUGIN_DIR@"/>
      <environment name="INCLUDE"   default="$GCC_PLUGIN_BASE/include"/>
      <environment name="LIBDIR"    default="$GCC_PLUGIN_BASE"/>
    </client>
  </tool>
EOF_TOOLFILE

cat << \EOF_TOOLFILE >${toolfolder}/ofast-flag.xml
  <tool name="ofast-flag" version="1.0">
    <flags CXXFLAGS="-Ofast"/>
    <ifarchitecture name="slc6_">
      <ifcompiler name="llvm">
        <flags CXXFLAGS="-fno-builtin"/>
      </ifcompiler>
    </ifarchitecture>
    <flags NO_RECURSIVE_EXPORT="1"/>
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

arch=`uname -m`
if [ $arch == x86_64 ] ; then
    #COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS $(%{cmsdist_directory}/vectorization/cmsdist_packages.py)"
    $(echo "vect")
fi
if [ $arch == aarch64 ] ; then
    COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS -fsigned-char -fsigned-bitfields"
    #echo "vect"
fi
if [ $arch == ppc64le ] ; then                                                                                                             
    #COMPILER_CXXFLAGS="$COMPILER_CXXFLAGS -fsigned-char -fsigned-bitfields %{ppc64le_build_flags}"
    $(echo "vect")                                                                                                                         
fi

export COMPILER_CXXFLAGS
# General substitutions
perl -p -i -e 's|\@([^@]*)\@|$ENV{$1}|g' ${toolfolder}/*.xml
