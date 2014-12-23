#//#!bash -l
set +x
if [[ `hostname` == "buildbox-fbsd" ]] ; then
export LD_LIBRARY_PATH=/opt/hwloc/1.9.1-gcc49/lib/:/opt/openmpi/1.8.2-gcc49-thread/lib:/usr/local/lib/gcc49:$LD_LIBRARY_PATH
export PATH=/opt/openmpi/1.8.2-gcc49-thread/bin:$PATH

PARMETIS=/opt//parmetis/4.0.3-ompi_182-gcc49
ZOLTAN=/opt/zoltan/3.8-ompi182-gcc49
LDF="-lexecinfo"
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
soft add +openmpi-pgi-1.6.5-thread
soft add +pgi-64bit
export FLAGS=""
fi
if [[ $COMPILER == "gcc" ]] ; then
soft add +openmpi-gnu482-1.6.5-thread
soft add +gcc-4.8.2
export FLAGS="-Wall -Wextra -pedantic -Wno-long-long"
fi
if [[ $COMPILER == "gccsan" ]] ; then
soft add +openmpi-gnu482-1.6.5-thread
soft add +gcc-4.8.2
export FLAGS="-Wall -Wextra -pedantic -Wno-long-long -fsanitize=address"
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
export FLAGS="-Wall -Wextra"
fi

rm -rf build prefix

svn co http://redmine.scorec.rpi.edu/anonsvn/meshes test_meshes

export CMAKE_PREFIX_PATH=$PARMETIS:$ZOLTAN:$CMAKE_PREFIX_PATH

ctest -VV -D Nightly -S core/cdash/colorado.cmake \
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
