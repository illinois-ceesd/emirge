# emirge - environment for MirgeCom

[![CI test](https://github.com/illinois-ceesd/emirge/workflows/CI%20test/badge.svg)](https://github.com/illinois-ceesd/emirge/actions?query=workflow%3A%22CI+test%22+event%3Apush)

## Running wavelet0


### Prerequesites

You can run `./install.sh` to install the required packages, or follow the manual instructions below.

#### Install POCL

##### Installation with conda-miniforge

```bash
$ wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
# For Power8/9:
# $ wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-ppc64le.sh
# For MacOS:
# $ wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh

$ bash ./Miniforge3-Linux-x86_64.sh
# make sure the installer runs 'conda init' at the end of installation, or run it manually.

$ exec bash
$ conda install pocl
```

##### Installation with Spack

```bash
$ git clone git@github.com:spack/spack
$ source spack/share/spack/setup-env.sh
# Maybe edit your Spack config
# $ spack config edit packages
$ spack install pocl
```

#### Install Python packages

```bash
$ export CONDA=$HOME/miniforge3
$ export PATH=$HOME/miniforge3/bin:$PATH
$ export OCL_ICD_VENDORS=$HOME/miniforge3/etc/OpenCL/vendors/

$ pip install pyvisfile
$ for m in dagrt leap loopy meshmode grudge mirgecom; do cd $m && pip install -e . && cd ..; done
```

### Run wavelet0

```bash
$ cd mirgecom/examples; python wave-eager.py
```
