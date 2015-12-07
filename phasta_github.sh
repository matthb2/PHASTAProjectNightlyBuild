#//#!bash -l

set -x
set -e

rm viznodes_deps.sh
if [ ! -f `dirname $0`/viznodes_deps.sh ]; then
  wget http://fluid.colorado.edu/~matthb2/buildscripts/viznodes_deps.sh
  source viznodes_deps.sh
else
  source `dirname $0`/viznodes_deps.sh
fi

rm -rf build prefix
mkdir build
export WK=$PWD

rm -rf phastaChefTests.tar.gz phastaChefTests
wget www.scorec.rpi.edu/~cwsmith/phastaChefTests.tar.gz
tar xvvzf phastaChefTests.tar.gz

cd build

cmake -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DCMAKE_Fortran_FLAGS="$FLAGS" -DCMAKE_INSTALL_PREFIX=$WK/prefix -DPHASTA_COMPRESSIBLE=ON -DPHASTA_TESTING=ON -DCASES=$WK/phastaChefTests $EXTRA_CMAKE_FLAGS ../phasta

make -j2
#make install
#set +e
#make test

#rc=$?
#echo "Cating the test log"
#cat ./Testing/Temporary/LastTest.log
ctest -VV --timeout 5000
#exit $rc
