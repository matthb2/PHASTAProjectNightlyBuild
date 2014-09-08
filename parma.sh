#!/bin/bash -l

#WARNING: this scripts expects that you've already run the SCOREC tools CMake build

export WK=$PWD
echo $COMPILER
if [[ $COMPILER == "pgi" ]] ; then
soft add +openmpi-pgi
soft add +pgi-64bit
export FLAGS=""
fi
if [[ $COMPILER == "gcc" ]] ; then
soft add +openmpi-gnu
soft add +gcc-4.8.1
export FLAGS="-Wall -Wextra -pedantic"
fi
if [[ $COMPILER == "sun" ]] ; then
soft add +openmpi-sun
soft add +sunstudio-12.3
export FLAGS=""
fi
if [[ $COMPILER == "clang" ]] ; then
soft add +openmpi-gnu
export OMPI_CC=clang
export OMPI_CXX=clang++
export OMPI_F90=gfortran
export FLAGS="-Wall -Wextra"
fi

export PKG_CONFIG_PATH=$WK/prefix/lib/pkgconfig:$PKG_CONFIG_PATH
mkdir parma-build
cd parma-build
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_PREFIX_PATH=$WK/build -DCMAKE_INSTALL_PREFIX=$WK/prefix ../parma
make
make install
cd $WK
