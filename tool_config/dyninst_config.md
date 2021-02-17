- OS：ubuntu 18.04.4
- dyninst version：10.1.0

- System configuration
  - Change the software sources (optional), then
  ```
  sudo apt-get update
  sudo apt-get upgrade
  sodo apt-get install build-essential cmake m4 texlive-latex-base flex bison zlib1g-dev
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
  sudo make install
  ```
  (This procedure will download several components, e.g. intel tbb, boost, elfutils, etc.)

