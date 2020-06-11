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

# Install Miniforge/conda:
$ bash ./Miniforge3-Linux-x86_64.sh

# Optional: create conda environment
$ export MY_CONDA=/path/to/installed/conda # Default installation path: $HOME/miniforge3
$ $MY_CONDA/bin/conda create -n dgfem
$ . $MY_CONDA/bin/activate dgfem

# Install required conda packages:
$ conda install pip pocl numpy pyopencl islpy flake8 mypy pudb

# Install optional conda packages:
$ conda install clinfo

# Make sure to reactivate the environment after installation:
. $MY_CONDA/bin/activate dgfem
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
$ pip install pyvisfile
$ for m in dagrt leap loopy meshmode grudge mirgecom; do cd $m && pip install -e . && cd ..; done
```

### Run wavelet0

```bash
$ cd mirgecom/examples; python wave-eager.py
```
