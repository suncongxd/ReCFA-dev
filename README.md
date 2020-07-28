# Development Repo of Resilient Remote Control-Flow Attestation #

Private repo for the dev of RRCFA.

## Benchmarks

Benchmarks include:

1. SPEC CPU2006 C benchmarks
2. nginx 1.16.0

## A checker to summarize the related offsets under instrumentation.

## Setup ##

#### Build and summarize SPEC CPU2006 benchmarks

- `tar xvf sos_spec06.tar.xz` at this directory.
- `cd spec2006`
- `./install.sh` and type `yes` to confirm the installation.
- `cp ../rrcfa.cfg config/`
- `cd ..`
- `./batch-make-on-spec.sh`

#### Build Nginx

- `cd nginx`
- `./build-nginx.sh`


### Contributor ###

* **Yumei Zhang** - School of Cyber-Engineering, Xidian University.
* **Cong Sun** - School of Cyber-Engineering, Xidian University. CONTACT: suncong AT xidian DOT edu DOT cn


