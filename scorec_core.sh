#//#!bash -l

set -x
set -e

if [ ! -f `dirname $0`/viznodes_deps.sh ]; then
  wget http://fluid.colorado.edu/~matthb2/buildscripts/viznodes_deps.sh
  source viznodes_deps.sh
else
  source `dirname $0`/viznodes_deps.sh
fi

rm -rf build prefix
mkdir build
export WK=$PWD
cd build

wget http://www.scorec.rpi.edu/pumi/pumi_test_meshes.tar.gz
tar xvvzf pumi_test_meshes.tar.gz

cmake -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DCMAKE_Fortran_FLAGS="$FLAGS" -DCMAKE_INSTALL_PREFIX=$WK/prefix -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DIS_TESTING=True -DENABLE_THREADS=$WANT_THREADS -DMETIS_LIBRARY=$PARMETIS/lib/libmetis.a -DPARMETIS_LIBRARY="$PARMETIS/lib/libparmetis.a" -DPARMETIS_INCLUDE_DIR=$PARMETIS/include -DZOLTAN_LIBRARY=$ZOLTAN/lib/libzoltan.a -DZOLTAN_INCLUDE_DIR=$ZOLTAN/include -DMESHES=$PWD/meshes -DENABLE_ZOLTAN=ON -DPCU_COMPRESS=ON $EXTRA_CMAKE_FLAGS ../core

make -j2
make install
#set +e
#make test

#rc=$?
#echo "Cating the test log"
#cat ./Testing/Temporary/LastTest.log
ctest -VV --timeout 5000
#exit $rc
