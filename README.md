# Development Repo of Resilient Control-Flow Attestation #

Repo for the dev of RRCFA.

## Benchmarks

Benchmarks include SPEC CPU2006 C benchmarks

## A checker to summarize the related offsets under instrumentation.

## Setup ##

#### Build and summarize SPEC CPU2006 benchmarks

- `tar xvf sos_spec06.tar.xz` at this directory.
- `cd spec2006`
- `./install.sh` and type `yes` to confirm the installation.
- `cp ../spec_configs/*.cfg config/`
- `cd ..`
- `./batch-make-on-spec.sh gcc` or `./batch-make-on-spec.sh llvm`
- `./patch-spec-src.sh`


### Contributor ###

* **Yumei Zhang** - School of Cyber-Engineering, Xidian University.
* **Xinzhi Liu** - School of Cyber-Engineering, Xidian University.
* **Cong Sun** - School of Cyber-Engineering, Xidian University. CONTACT: suncong AT xidian DOT edu DOT cn


