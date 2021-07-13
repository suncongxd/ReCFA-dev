#! /bin/bash

testcase_root=$(pwd)
#echo $testcase_root

spec_root=${testcase_root}"/spec2006/"
spec_build_root=${testcase_root}"/spec2006/benchspec/CPU2006"
#echo $spec_root
spec_patch_root=${testcase_root}"/spec_patch"



#copy the patches
patch_gcc() {
  gcc_root=$spec_build_root"/403.gcc/"
  cp $spec_patch_root"/gcc_diff.patch" $gcc_root
  cd $gcc_root
  
  patch -s -p0 < gcc_diff.patch
  cd src

  cp $spec_patch_root"/Makefile-403gcc-gcc" ./Makefile
  make
  cp "gcc_base.gcc_O0" ${testcase_root}"/spec_gcc/O0/"
  make clean

  cp $spec_patch_root"/Makefile-403gcc-llvm" ./Makefile
  make
  cp "gcc_base.llvm_O0" ${testcase_root}"/spec_llvm/O0/"
  make clean
}


patch_hmmer() {
  hmmer_root=$spec_build_root"/456.hmmer/"
  cp $spec_patch_root"/hmmer_diff.patch" $hmmer_root
  cd $hmmer_root
  
  patch -s -p0 < hmmer_diff.patch
  cd src

  cp $spec_patch_root"/Makefile-456hmmer-gcc" ./Makefile
  make
  cp "hmmer_base.gcc_O0" ${testcase_root}"/spec_gcc/O0/"
  make clean

  cp $spec_patch_root"/Makefile-456hmmer-llvm" ./Makefile
  make
  cp "hmmer_base.llvm_O0" ${testcase_root}"/spec_llvm/O0/"
  make clean
}


patch_gcc
patch_hmmer


