#! /bin/bash

CP=$1

testcase_root=$(pwd)
#echo $testcase_root

spec_root=${testcase_root}"/spec2006/"
spec_build_root=${testcase_root}"/spec2006/benchspec/CPU2006"
#echo $spec_root

dest_binary_root=${testcase_root}"/spec_"$CP
for OL in O0 O1 O2 O3 ; do
  if [ ! -d $dest_binary_root"/"$OL ]
  then
     mkdir $dest_binary_root"/"$OL
  fi
done

case_names=(400.perlbench 401.bzip2 403.gcc 429.mcf 433.milc 445.gobmk 456.hmmer 458.sjeng 462.libquantum 464.h264ref 470.lbm 482.sphinx3) #  


one_pass () {
  CP=$1 # compiler
  OL=$2 # optimization level
  Name=$3 # case name

  cd ${spec_root}
  source shrc

  cd $spec_root"config"
  runspec --config=$CP"-"$OL.cfg --action=build $Name
}


build () {
  CP=$1

  for OL in O0 O1 O2 O3 ; do # 
    for name in ${case_names[@]} ; do
      one_pass $CP $OL $name

      cd $spec_build_root"/"$name"/exe"
      for i in `ls`
        do
        if [[ $i == *$CP"_"$OL ]]; then
          echo -e $spec_build_root"/"$name"/exe/"$i"==>"$dest_binary_root"/"$OL"/"$i"\n"
          cp -f $spec_build_root"/"$name"/exe/"$i $dest_binary_root"/"$OL"/"$i
        fi
      done
    done
  done
}




build $CP


<<comment
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

comment
