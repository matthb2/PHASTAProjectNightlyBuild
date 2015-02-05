#//#!bash -l
set -x
set -e
SIM_SOFT="+simmodsuite-9.0-140927"

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
soft add $SIM_SOFT
TMPPATH=`soft-dbq $SIM_SOFT | grep LD_LIBRARY_PATH | head -n 1 | cut -f 2 -d ':'`
#stip the random kernel path
TMPPATH=`dirname $TMPPATH`
SIM_ARCHOS_STR=`basename $TMPPATH`
#strip archos
TMPPATH=`dirname $TMPPATH`
#stip "lib"
SIM_BASE_PATH=`dirname $TMPPATH`
fi

echo $COMPILER
if [[ $COMPILER == "pgi" ]] ; then
soft add +openmpi-pgi-1.6.5-thread
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
soft add +openmpi-sun-1.6.5-thread
soft add +sunstudio-12.3
export OMPI_CXX="sunCC -library=stlport4 "
export FLAGS="$FLAGS "
fi
if [[ $COMPILER == "clang" ]] ; then
soft add +openmpi-gnu-1.6.5-thread
export OMPI_CC=clang
export OMPI_CXX=clang++
export OMPI_F90=gfortran
export FLAGS="$FLAGS -Wall -Wextra"
fi


rm -rf build prefix PartitionWrapper
cp -rv $SIM_BASE_PATH/code/PartitionWrapper ./
cd PartitionWrapper
make CC=mpicc CXX=mpicxx PARALLEL=mpich -f Makefile.custom
cd ../

mkdir build
export WK=$PWD
cd build

svn co --non-interactive --trust-server-cert https://redmine.scorec.rpi.edu/anonsvn/meshes test_meshes

cmake -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DCMAKE_Fortran_FLAGS="$FLAGS" -DCMAKE_INSTALL_PREFIX=$WK/prefix -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DIS_TESTING=True -DENABLE_THREADS=ON -DMETIS_LIBRARY=$PARMETIS/lib/libmetis.a -DPARMETIS_LIBRARY="$PARMETIS/lib/libparmetis.a" -DPARMETIS_INCLUDE_DIR=$PARMETIS/include -DZOLTAN_LIBRARY=$ZOLTAN/lib/libzoltan.a -DZOLTAN_INCLUDE_DIR=$ZOLTAN/include -DMESHES=$PWD/test_meshes -DENABLE_ZOLTAN=ON -DPCU_COMPRESS=ON -DSIM_MPI=mpich -DSIM_PARASOLID=ON -DSIM_ACIS=ON -DCMAKE_PREFIX_PATH="$SIM_BASE_PATH/lib/$SIM_ARCHOS_STR/psKrnl;$SIM_BASE_PATH/lib;$SIM_BASE_PATH/lib/$SIM_ARCHOS_STR;$SIM_BASE_PATH/lib/$SIM_ARCHOS_STR/acisKrnl;$SIM_BASE_PATH/include;$WK/PartitionWrapper" ../core-sim

make -j2
make install
#set +e
#make test

#rc=$?
#echo "Cating the test log"
#cat ./Testing/Temporary/LastTest.log
ctest -VV
#exit $rc
