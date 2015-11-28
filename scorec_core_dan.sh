#//#!bash -l
set +x

wget http://fluid.colorado.edu/~matthb2/buildscripts/viznodes_deps.sh
source viznodes_deps.sh

rm -rf build prefix

wget http://www.scorec.rpi.edu/pumi/pumi_test_meshes.tar.gz
tar xvvzf pumi_test_meshes.tar.gz
mv meshes test_meshes

export CMAKE_PREFIX_PATH=$PARMETIS:$ZOLTAN:$CMAKE_PREFIX_PATH

ctest -VV --timeout 5000 -D Nightly -S core/cdash/colorado.cmake \
  -D CTEST_SITE:STRING=`hostname` \
  -D CTEST_BUILD_NAME:STRING=`hostname`-$COMPILER \
  -D CTEST_DASHBOARD_ROOT:STRING=$PWD \
  -D MY_FLAGS:STRING="$FLAGS" \
  -D MY_LIBS:STRING="$LDF"

cd build
make install

rc=$?
echo "Cat'ing the test log"
cat ./Testing/Temporary/LastTest.log

exit $rc
