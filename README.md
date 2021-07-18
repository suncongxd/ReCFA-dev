# Development Repo of Resilient Control-Flow Attestation #

Repo for the dev of ReCFA.

## A checker to summarize the related offsets under instrumentation.

## Setup ##

#### Build SPEC CPU2006 C benchmarks

- `tar xvf sos_spec06.tar.xz` at this directory.
- `cd spec2006`
- `./install.sh` and type `yes` to confirm the installation.
- `cp ../spec_configs/*.cfg config/`
- `cd ..`
- `./batch-make-on-spec.sh gcc` or `./batch-make-on-spec.sh llvm`
- `./patch-spec-src.sh`

#### Build and configure typearmor at Ubuntu 16.04

- OS: ubuntu 16.04.1, dyninst version: 9.3.1

- System configuration
  ```
  sudo apt-get update
  sudo apt-get upgrade
  sodo apt-get install build-essential cmake m4 texlive-latex-base flex bison zlib1g-dev libboost-all-dev libelf-dev libiberty-dev

  ```
  Note: Do not install libdwarf-dev using apt.
- Install dyninst
  ```
  cd ~/dyninst-9.3.1
  mkdir install
  cd install
  cmake .. -DCMAKE_INSTALL_PREFIX=`pwd`
  make -j2
  make install
  ```
  - Keep the network connected (This procedure will download several components)
  - To install dyninst 10.1 for ReCFA follows the similar instructions.

- Install typearmor
  ```
  cd ~/typearmor
  mkdir out
  . ./envsetup
  cd static
  make
  make install
  cd ../di-opt
  make
  make install
  ```
  - make the directory "out" is important, otherwise typearmor reports segment fault.

- Deploying dyninst-10.1.0 for ReCFA, add to `~/.bashrc`
  ```
DYNINST_HOME=~/dyninst-10.1.0
export DYNINST_INCLUDE=$DYNINST_HOME/install/include
export DYNINST_LIB=$DYNINST_HOME/install/lib
export DYNINSTAPI_RT_LIB=$DYNINST_LIB/libdyninstAPI_RT.so
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYNINST_LIB
export PATH=$PATH:$DYNINST_INCLUDE:$DYNINSTAPI_RT_LIB
  ```

#### Build csfilter.jar

```
cd csfilter
make
make clean
```
Then, copy `csfilter.jar` to the `bin` of ReCFA.

### Contributor ###

* **Yumei Zhang** - School of Cyber-Engineering, Xidian University.
* **Xinzhi Liu** - School of Cyber-Engineering, Xidian University.
* **Cong Sun** - School of Cyber-Engineering, Xidian University. CONTACT: suncong AT xidian DOT edu DOT cn


