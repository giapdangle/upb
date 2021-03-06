#!/bin/sh
# Builds and runs all available benchmarks.  The tree will be built
# multiple times with a few different compiler flag combinations.
# The output will be dumped to stdout and to perf-tests.out.

set -e
MAKETARGET=benchmarks
if [ x$1 = xupb ]; then
  MAKETARGET=upb_benchmarks
fi

rm -f perf-tests.out

run_with_flags () {
  FLAGS=$1
  NAME=$2

  make clean
  echo "$FLAGS" > perf-cppflags
  make upb_benchmarks
  make upb_benchmark | sed -e "s/^/$NAME./g" | tee -a perf-tests.out
}

#if [ x`uname -m` = xx86_64 ]; then
  run_with_flags "-DNDEBUG -m32" "plain32"
  run_with_flags "-DNDEBUG -fomit-frame-pointer -m32" "omitfp32"
#fi

# Ideally we could test for x86-64 in deciding whether to compile with
# the JIT flag.
run_with_flags "-DNDEBUG -DUPB_USE_JIT_X64" "plain"
run_with_flags "-DNDEBUG -fomit-frame-pointer -DUPB_USE_JIT_X64" "omitfp"
