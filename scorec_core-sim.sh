#//#!bash -l
set -x
set -e

wget http://fluid.colorado.edu/~matthb2/buildscripts/viznodes_deps.sh
source viznodes_deps.sh

rm -rf build prefix PartitionWrapper
cp -rv $SIM_BASE_PATH/code/PartitionWrapper ./
cd PartitionWrapper
make CC=mpicc CXX=mpicxx PARALLEL=mpich OPTFLAGS="-fPIC" -f Makefile.custom
cd ../

mkdir build
export WK=$PWD
cd build

wget http://www.scorec.rpi.edu/pumi/pumi_test_meshes.tar.gz
tar xvvzf pumi_test_meshes.tar.gz
mv meshes test_meshes


cmake -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DCMAKE_Fortran_FLAGS="$FLAGS" -DCMAKE_INSTALL_PREFIX=$WK/prefix -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DIS_TESTING=True -DENABLE_THREADS=$WANT_THREADS -DMETIS_LIBRARY=$PARMETIS/lib/libmetis.a -DPARMETIS_LIBRARY="$PARMETIS/lib/libparmetis.a" -DPARMETIS_INCLUDE_DIR=$PARMETIS/include -DZOLTAN_LIBRARY=$ZOLTAN/lib/libzoltan.a -DZOLTAN_INCLUDE_DIR=$ZOLTAN/include -DMESHES=$PWD/test_meshes -DENABLE_ZOLTAN=ON -DPCU_COMPRESS=ON -DSIM_MPI=mpich -DSIM_PARASOLID=ON -DSIM_ACIS=ON $SIM_CONF_FLAG -DCMAKE_PREFIX_PATH="$SIM_BASE_PATH/lib/$SIM_ARCHOS_STR/psKrnl;$SIM_BASE_PATH/lib;$SIM_BASE_PATH/lib/$SIM_ARCHOS_STR;$SIM_BASE_PATH/lib/$SIM_ARCHOS_STR/acisKrnl;$SIM_BASE_PATH/include;$WK/PartitionWrapper;$EXTRA_PREFIX_PATH" ../core-sim

make -j2
make install
#set +e
#make test

#rc=$?
#echo "Cating the test log"
#cat ./Testing/Temporary/LastTest.log
ctest -VV --timeout 5000
#exit $rc
