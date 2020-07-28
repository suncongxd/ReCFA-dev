#! /bin/sh

work_path=$(dirname $0)
cd ./${work_path}
cd ../
bench_root=$(pwd)

#echo $bench_root

nginx_bin_dir=$bench_root"/nginx/bin"
nginx_dir=$bench_root"/nginx/nginx-1.16.0"

pcre_dir=$bench_root"/lib/pcre-8.43"
zlib_dir=$bench_root"/lib/zlib-1.2.11"

cd $nginx_dir

./configure --with-cc="gcc" --with-cc-opt="-O0 -mno-avx -fno-stack-protector -no-pie" --with-pcre=$pcre_dir --with-pcre-opt="-g -O0 -mno-avx -fno-stack-protector -no-pie" --with-zlib=$zlib_dir --with-zlib-opt="-g -O0 -mno-avx -fno-stack-protector -no-pie"

make

mv $nginx_dir"/objs/nginx" $nginx_bin_dir"/nginx"
