
source ../doc/load_hpl_modules_frontier.sh

SRC_DIR=..
export LD_LIBRARY_PATH=/opt/rocm-4.5.2/llvm/lib:${LD_LIBRARY_PATH}
export HIPCC_COMPILE_FLAGS_APPEND="$HIPCC_COMPILE_FLAGS_APPEND -fopenmp --offload-arch=gfx90a"
rm -rf CMakeCache.txt CMakeFiles externals Makefile driver.x86_64
cmake \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DCMAKE_BUILD_TYPE=Release \
    $SRC_DIR 2>&1 | tee CMAKE.OUTPUT
#   -DCMAKE_HIP_COMPILER_FORCED=True \

make VERBOSE=1 -j1 2>&1 | tee MAKE.OUTPUT
