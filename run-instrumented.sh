#! /bin/bash

spec_root=$(pwd)/spec2006
gcc_cfg_path=$spec_root/config/gcc-O0-instru.cfg
llvm_cfg_path=$spec_root/config/llvm-O0-instru.cfg

case_nums=(400 401 403 429 433 445 456 462 464 470 482) #

run_gcc(){
  for case_num in ${case_nums[*]}; do
     #echo $case_num
     runspec -c $gcc_cfg_path -i test -n 1 --noreportable --nobuild -I --action run $case_num
  done
}

run_llvm(){
  for case_num in ${case_nums[*]}; do
     #echo $case_num
     runspec -c $llvm_cfg_path -i test -n 1 --noreportable --nobuild -I --action run $case_num
  done
}

run_gcc
#run_llvm

#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 400
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 401
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 403
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 429
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 433
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 445
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 456
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 462
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 464
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 470
#runspec -c $cfg_path -i test -n 1 --noreportable --nobuild -I --action run 482

