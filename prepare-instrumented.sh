#! /bin/bash

testcase_root=$(pwd)
#echo $testcase_root

spec_root=${testcase_root}"/spec2006"
spec_build_root=${testcase_root}"/spec2006/benchspec/CPU2006"
#echo $spec_root

recfa_root=$testcase_root/../ReCFA

gcc_bin_root=$recfa_root/spec_gcc/O0
llvm_bin_root=$recfa_root/spec_llvm/O0


case_names=(400.perlbench 401.bzip2 403.gcc 429.mcf 433.milc 445.gobmk 456.hmmer 462.libquantum 464.h264ref 470.lbm 482.sphinx3)
#458.sjeng cannot be instrumented.

<<comment
for name in ${case_names[@]} ; do
   echo ${name:4}
done
comment

declare -A gcc_md5
declare -A llvm_md5

get_gcc_bin(){
cd $gcc_bin_root
for i in `ls`; do
   for case_name in ${case_names[@]} ; do
      name=${case_name:4}
      if [[ $name = "sphinx3" ]]; then
         name="sphinx"
      fi
      if [[ $i = $name* ]] && [[ $i = *"_instru" ]]; then
         bin_path=$(pwd)/$i
         tar_dir=$spec_build_root/$case_name"/exe/"
         if [[ -f $bin_path ]] && [[ -d $tar_dir ]]; then
            cp $bin_path $tar_dir
            res_string=$(md5sum $bin_path | cut -d" " -f 1)
            gcc_md5[$name]=$res_string
         fi
      fi
   done
done
}

get_llvm_bin(){
cd $llvm_bin_root
for i in `ls`; do
   for case_name in ${case_names[@]} ; do
      name=${case_name:4}
      if [[ $name = "sphinx3" ]]; then
         name="sphinx"
      fi
      if [[ $i = $name* ]] && [[ $i = *"_instru" ]]; then
         bin_path=$(pwd)/$i
         tar_dir=$spec_build_root/$case_name"/exe/"
         if [[ -f $bin_path ]] && [[ -d $tar_dir ]]; then
            cp $bin_path $tar_dir
            res_string=$(md5sum $bin_path | cut -d" " -f 1)
            llvm_md5[$name]=$res_string
         fi
      fi
   done
done
}

get_gcc_bin
get_llvm_bin
cd .

#echo ${!gcc_md5[@]}
#echo ${gcc_md5[@]}

#echo ${!llvm_md5[@]}
#echo ${llvm_md5[@]}

patch_config(){
  config=$1
  instru_config=$2
  CP=$3

  cat /dev/null > $instru_config
  tag=false
  cur_case=""
  while read line
  do
    if [[ $tag = false ]] && [[ $line != "__MD5__" ]]; then
       if [[ $line = "ext"* ]]; then
          echo "ext = "$CP"_O0_instru" >> $instru_config
       else
          echo $line >> $instru_config
       fi
       continue
    fi

    if [[ $line = "__MD5__" ]]; then
      tag=true
      echo $line >> $instru_config
      continue
    fi

    if [[ $tag = true ]]; then
      if [[ $line = "400.perlbench=base="$CP"_O0=default:" ]]; then
         echo "400.perlbench=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="perlbench"
         continue
      elif [[ $line = "401.bzip2=base="$CP"_O0=default:" ]]; then
         echo "401.bzip2=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="bzip2"
         continue
      elif [[ $line = "403.gcc=base="$CP"_O0=default:" ]]; then
         echo "403.gcc=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="gcc"
         continue
      elif [[ $line = "429.mcf=base="$CP"_O0=default:" ]]; then
         echo "429.mcf=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="mcf"
         continue
      elif [[ $line = "433.milc=base="$CP"_O0=default:" ]]; then
         echo "433.milc=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="milc"
         continue
      elif [[ $line = "445.gobmk=base="$CP"_O0=default:" ]]; then
         echo "445.gobmk=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="gobmk"
         continue
      elif [[ $line = "456.hmmer=base="$CP"_O0=default:" ]]; then
         echo "456.hmmer=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="hmmer"
         continue
      elif [[ $line = "458.sjeng=base=gcc_O0=default:" ]]; then
         echo $line >> $instru_config
         cur_case="sjeng"
         continue
      elif [[ $line = "462.libquantum=base="$CP"_O0=default:" ]]; then
         echo "462.libquantum=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="libquantum"
         continue
      elif [[ $line = "464.h264ref=base="$CP"_O0=default:" ]]; then
         echo "464.h264ref=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="h264ref"
         continue
      elif [[ $line = "470.lbm=base="$CP"_O0=default:" ]]; then
         echo "470.lbm=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="lbm"
         continue
      elif [[ $line = "482.sphinx3=base="$CP"_O0=default:" ]]; then
         echo "482.sphinx3=base="$CP"_O0_instru=default:" >> $instru_config
         cur_case="sphinx"
         continue
      fi
      if [[ $line != "exemd5="* ]]; then
         echo $line >> $instru_config
      elif [[ $cur_case != "" ]]; then
         if [[ $cur_case = "sjeng" ]]; then
            echo $line >> $instru_config
         elif [[ $CP = "gcc" ]]; then
            echo "exemd5="${gcc_md5[$cur_case]} >> $instru_config
         elif [[ $CP = "llvm" ]]; then
            echo "exemd5="${llvm_md5[$cur_case]} >> $instru_config
         fi
      fi
    fi
  done < $config
}

patch_config "$spec_root/config/gcc-O0.cfg" "$spec_root/config/gcc-O0-instru.cfg" "gcc"
patch_config "$spec_root/config/llvm-O0.cfg" "$spec_root/config/llvm-O0-instru.cfg" "llvm"

