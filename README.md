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

### Contributor ###

* **Yumei Zhang** - School of Cyber-Engineering, Xidian University.
* **Xinzhi Liu** - School of Cyber-Engineering, Xidian University.
* **Cong Sun** - School of Cyber-Engineering, Xidian University. CONTACT: suncong AT xidian DOT edu DOT cn


