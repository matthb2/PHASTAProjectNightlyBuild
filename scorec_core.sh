#//#!bash -l
set -x
set -e
if [[ `hostname` == "buildbox-fbsd" ]] ; then
export LD_LIBRARY_PATH=/opt/hwloc/1.9.1-gcc49/lib/:/opt/openmpi/1.8.2-gcc49-thread/lib:/usr/local/lib/gcc49:$LD_LIBRARY_PATH
export PATH=/opt/openmpi/1.8.2-gcc49-thread/bin:$PATH

PARMETIS=/opt//parmetis/4.0.3-ompi_182-gcc49
ZOLTAN=/opt/zoltan/3.8-ompi182-gcc49
LDF="-DCMAKE_EXE_LINKER_FLAGS=' -lexecinfo '"
FLAGS="-lexecinfo"
function soft {
	echo "skipping soft"
}
else
PARMETIS=/usr/local/parmetis/4.0.3-gnu482-ompi-1.6.5-64bitidx
ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi
LDF=""
fi

echo $COMPILER
if [[ $COMPILER == "pgi" ]] ; then
soft add +openmpi-pgi
soft add +pgi-64bit
export FLAGS="$FLAGS "
fi
if [[ $COMPILER == "gcc" ]] ; then
soft add +openmpi-gnu482-1.6.5-thread
soft add +gcc-4.8.2
export FLAGS="$FLAGS -Wall -Wextra -pedantic"
fi
if [[ $COMPILER == "gccsan" ]] ; then
soft add +openmpi-gnu482-1.6.5-thread
soft add +gcc-4.8.2
export FLAGS="$FLAGS -Wall -Wextra -pedantic -fsanitize=address"
fi
if [[ $COMPILER == "sun" ]] ; then
soft add +openmpi-sun
soft add +sunstudio-12.3
export FLAGS="$FLAGS "
fi
if [[ $COMPILER == "clang" ]] ; then
soft add +openmpi-gnu-1.6.5-thread
export OMPI_CC=clang
export OMPI_CXX=clang++
export OMPI_F90=gfortran
export FLAGS="$FLAGS -Wall -Wextra"
fi


rm -rf build prefix
mkdir build
export WK=$PWD
cd build

svn co http://redmine.scorec.rpi.edu/anonsvn/meshes test_meshes

cmake -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DCMAKE_Fortran_FLAGS="$FLAGS" -DCMAKE_INSTALL_PREFIX=$WK/prefix -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DIS_TESTING=True -DENABLE_THREADS=ON -DMETIS_LIBRARY=$PARMETIS/lib/libmetis.a -DPARMETIS_LIBRARY="$PARMETIS/lib/libparmetis.a" -DPARMETIS_INCLUDE_DIR=$PARMETIS/include -DZOLTAN_LIBRARY=$ZOLTAN/lib/libzoltan.a -DZOLTAN_INCLUDE_DIR=$ZOLTAN/include -DMESHES=$PWD/test_meshes -DENABLE_ZOLTAN=ON ../core

make -j2
make install
make test

rc=$?
echo "Cating the test log"
cat ./Testing/Temporary/LastTest.log

exit $rc
