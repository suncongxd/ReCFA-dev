- OS: ubuntu 18.04.4, dyninst version: 10.1.0
- OS: ubuntu 16.04.1, dyninst version: 9.3.1

- System configuration
  - Change the software sources (optional), then
  ```
  sudo apt-get update
  sudo apt-get upgrade
  sodo apt-get install build-essential cmake m4 texlive-latex-base flex bison zlib1g-dev libboost-all-dev libelf-dev libiberty-dev
  ```
- Install dyninst
  ```
  mkdir ~/dyninst
  ```
  - At the repo directory of dyninst, run
  ```
  cmake . -DCMAKE_INSTALL_PREFIX=~/dyninst
  ```
  - Keep the network connected, run
  ```
  make -j2
  sudo make install
  ```
  (This procedure will download several components)

