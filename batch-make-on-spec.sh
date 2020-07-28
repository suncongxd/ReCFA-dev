#! /bin/bash

testcase_root=$(pwd)
#echo $testcase_root

spec_root=${testcase_root}"/spec2006/"
spec_build_root=${testcase_root}"/spec2006/benchspec/CPU2006"
#echo $spec_root

case_names=(400.perlbench 401.bzip2 403.gcc 429.mcf 433.milc 445.gobmk 456.hmmer 458.sjeng 462.libquantum 464.h264ref 470.lbm 482.sphinx3)

cd ${spec_root}
source shrc

cd config/

runspec --config=rrcfa.cfg --action=build ${case_names[@]}

for name in ${case_names[@]}
do
  cd $spec_build_root"/"$name"/exe"
  for i in `ls`
  do
    if [[ $i == *".cfa" ]]; then
      bin_path=$spec_build_root"/"$name"/exe/"$i
      bin_store=$spec_build_root"/"$name"/exe/"$i"_bak"
      cp -f $bin_path $bin_store
    fi
  done
done
