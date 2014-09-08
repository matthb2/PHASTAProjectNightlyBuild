#!/bin/bash -l
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

PARMETIS=/usr/local/parmetis/4.0.3-gnu-ompi-1.6.5-64bitidx
ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi
rm -rf build prefix
mkdir build
export WK=$PWD
cd build

if [[ $MODELER == "meshmodel" ]] ; then
cmake -DCMAKE_INSTALL_PREFIX=$WK/prefix -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DENABLE_PARMA=ON -DCMAKE_PREFIX_PATH=$PARMETIS -DZOLTAN_INCLUDE_DIR=$ZOLTAN/include -DZOLTAN_LIBRARY=$ZOLTAN/lib/libzoltan.a ../Cmake.SCOREC

fi

if [[ $MODELER == "parasolid" ]] ; then
cmake -DCMAKE_INSTALL_PREFIX=$WK/prefix -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DPUMI_GEOM_MODEL=parasolid -DPARASOLID_INSTALL_PREFIX=/usr/local/parasolid/latest -DENABLE_PARMA=ON -DCMAKE_PREFIX_PATH=$PARMETIS -DZOLTAN_INCLUDE_DIR=$ZOLTAN/include -DZOLTAN_LIBRARY=$ZOLTAN/lib/libzoltan.a ../Cmake.SCOREC

fi

if [[ $MODELER == "acis" ]] ; then
if [[ $COMPILER == "gcc" ]] ; then
export FLAGS="$FLAGS -fpermissive"
fi
cmake -DCMAKE_INSTALL_PREFIX=$WK/prefix -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DPUMI_GEOM_MODEL=acis -DACIS_INSTALL_PREFIX=/usr/local/acis/latest -DENABLE_PARMA=ON -DCMAKE_PREFIX_PATH=$PARMETIS -DZOLTAN_INCLUDE_DIR=$ZOLTAN/include -DZOLTAN_LIBRARY=$ZOLTAN/lib/libzoltan.a ../Cmake.SCOREC

fi

make
make install
