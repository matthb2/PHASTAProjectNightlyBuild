set -x
set -e
if [[ `hostname` == "buildbox-fbsd" ]] ; then
export LD_LIBRARY_PATH=/opt/hwloc/1.9.1-gcc49/lib/:/opt/openmpi/1.8.2-gcc49-thread/lib:/usr/local/lib/gcc49:$LD_LIBRARY_PATH
export PATH=/opt/openmpi/1.8.2-gcc49-thread/bin:$PATH

PARMETIS=/opt//parmetis/4.0.3-ompi_182-gcc49
ZOLTAN=/opt/zoltan/3.8-ompi182-gcc49
LDF="-DCMAKE_EXE_LINKER_FLAGS=' -lexecinfo '"
FLAGS="-lexecinfo"
WANT_THREADS=OFF #BSD Box only has two cores, and "core" has issues
echo 'WARNING: NOT ACTUALLY BUILDING THREAD SUPPORT'
function soft {
	echo "skipping soft"
}
else
SIM_SOFT="+simmodsuite-9.0-150430"
SIM_CONF_FLAG="-DSIM_PARASOLID_VERSION=270"
soft add $SIM_SOFT
TMPPATH=`soft-dbq $SIM_SOFT | grep LD_LIBRARY_PATH | head -n 1 | cut -f 2 -d ':'`
#stip the random kernel path
TMPPATH=`dirname $TMPPATH`
SIM_ARCHOS_STR=`basename $TMPPATH`
#strip archos
TMPPATH=`dirname $TMPPATH`
#stip "lib"
SIM_BASE_PATH=`dirname $TMPPATH`
PARMETIS=/usr/local/parmetis/4.0.3-gnu482-ompi-1.6.5-64bitidx
ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi
LDF=""
WANT_THREADS=$THREADS
fi

echo $COMPILER

if [[ $COMPILER == "pgi" ]] ; then
 WANT_THREADS=OFF #PGIs std::allocator is not thread safe
 EXTRA_CMAKE_FLAGS="-DCMAKE_PREFIX_PATH=/usr/local/bzip2/1.0.6-pic"
 EXTRA_PREFIX_PATH='/usr/local/bzip2/1.0.6-pic'
 if [[ $MPIIMPL == "openmpi" ]] ; then
  PARMETIS=/usr/local/parmetis/4.0.3-gnu482-ompi-1.6.5-64bitidx
  ZOLTAN=/usr/local/zoltan/trilinos_scorec-11.0.3-gnu482-ompi
  soft add +openmpi-pgi-1.8.4-thread
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
 EXTRA_CMAKE_FLAGS="-DCMAKE_PREFIX_PATH=/usr/local/bzip2/1.0.6-pic"
 EXTRA_PREFIX_PATH='/usr/local/bzip2/1.0.6-pic'
 if [[ $MPIIMPL == "openmpi" ]] ; then
  soft add +openmpi-gnu-1.8.4-thread
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
