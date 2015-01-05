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
 if [[ $MPIIMPL == "openmpi" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-gnu482-ompi-1.6.5-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi
  soft add +openmpi-pgi-1.6.5-thread 
 fi
 if [[ $MPIIMPL == "mpich" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-pgi410-mpich-3.1.3-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-pgi410-mpich313 
  soft add +mpich-pgi410-3.1.3
 fi
soft add +pgi-64bit
export FLAGS="$FLAGS "
fi

if [[ $COMPILER == "gcc" ]] ; then
 if [[ $MPIIMPL == "openmpi" ]] ; then
  soft add +openmpi-gnu482-1.6.5-thread
  PARMETIS=/usr/local/parmetis/4.0.3-gnu482-ompi-1.6.5-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi 
 fi
 if [[ $MPIIMPL == "mpich" ]] ; then 
  PARMETIS=/usr/local/parmetis/4.0.3-gnu-mpich-3.1.3-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu-mpich313
  soft add +mpich-gnu491-3.1.3 
 fi	
soft add +gcc-4.9.1
export FLAGS="$FLAGS -Wall -Wextra -pedantic"
fi

if [[ $COMPILER == "gccsan" ]] ; then
 if [[ $MPIIMPL == "openmpi" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-gnu482-ompi-1.6.5-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi
  soft add +openmpi-gnu482-1.6.5-thread
 fi
 if [[ $MPIIMPL == "mpich" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-gnu-mpich-3.1.3-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu-mpich313
  soft add +mpich-gnu491-3.1.3
 fi	
soft add +gcc-4.9.1
export FLAGS="$FLAGS -Wall -Wextra -pedantic -fsanitize=undefined"
fi

if [[ $COMPILER == "gcctsan" ]] ; then
 if [[ $MPIIMPL == "openmpi" ]] ; then
  soft add +openmpi-gnu482-1.6.5-thread
  PARMETIS=/usr/local/parmetis/4.0.3-gnu491-ompi-1.6.5-64bitidx-tsan
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu491-ompi-tsan
 fi
 if [[ $MPIIMPL == "mpich" ]] ; then 
 	PARMETIS=/usr/local/parmetis/4.0.3-gnu491-mpich-3.1.3-64bitidx-tsan
 	ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu491-mpich313-tsan
 	soft add +mpich-gnu491-3.1.3
 fi	
soft add +gcc-4.9.1
export FLAGS="$FLAGS -Wall -Wextra -pedantic -pie -fPIC -fsanitize=thread"
export TSAN_OPTIONS="history_size=7 verbosity=2"
fi

if [[ $COMPILER == "gccasan" ]] ; then
 if [[ $MPIIMPL == "openmpi" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-gnu482-ompi-1.6.5-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi
  soft add +openmpi-gnu482-1.6.5-thread
 fi
 if [[ $MPIIMPL == "mpich" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-gnu-mpich-3.1.3-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu-mpich313
  soft add +mpich-gnu491-3.1.3
 fi	
soft add +gcc-4.9.1
export FLAGS="$FLAGS -Wall -Wextra -pedantic -fsanitize=address"
fi

if [[ $COMPILER == "sun" ]] ; then
soft add +openmpi-sun-1.6.5-thread
soft add +sunstudio-12.3
export OMPI_CXX="sunCC -library=stlport4 "
export FLAGS="$FLAGS "
fi

if [[ $COMPILER == "clang" ]] ; then
 if [[ $MPIIMPL == "openmpi" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-gnu482-ompi-1.6.5-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi
  soft add +openmpi-gnu-1.6.5-thread
 fi
 if [[ $MPIIMPL == "mpich" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-gnu-mpich-3.1.3-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu-mpich313
  soft add +mpich-gnu-3.1.3
 fi
export OMPI_CC=clang
export OMPI_CXX=clang++
export OMPI_F90=gfortran
export FLAGS="$FLAGS -Wall -Wextra"
fi

if [[ `hostname` == "buildbox-fbsd" ]] ; then
  PARMETIS=/opt//parmetis/4.0.3-ompi_182-gcc49
  ZOLTAN=/opt/zoltan/3.8-ompi182-gcc49
fi

rm -rf build prefix
mkdir build
export WK=$PWD
cd build

svn co http://redmine.scorec.rpi.edu/anonsvn/meshes test_meshes

cmake -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DCMAKE_Fortran_FLAGS="$FLAGS" -DCMAKE_INSTALL_PREFIX=$WK/prefix -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DIS_TESTING=True -DENABLE_THREADS=ON -DMETIS_LIBRARY=$PARMETIS/lib/libmetis.a -DPARMETIS_LIBRARY="$PARMETIS/lib/libparmetis.a" -DPARMETIS_INCLUDE_DIR=$PARMETIS/include -DZOLTAN_LIBRARY=$ZOLTAN/lib/libzoltan.a -DZOLTAN_INCLUDE_DIR=$ZOLTAN/include -DMESHES=$PWD/test_meshes -DENABLE_ZOLTAN=ON ../core

make -j6
make install
#set +e
#make test

#rc=$?
#echo "Cating the test log"
#cat ./Testing/Temporary/LastTest.log
ctest -VV
#exit $rc
