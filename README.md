# emirge - environment for MirgeCom

[![CI test](https://github.com/illinois-ceesd/emirge/workflows/CI%20test/badge.svg)](https://github.com/illinois-ceesd/emirge/actions?query=workflow%3A%22CI+test%22+event%3Apush)

Emirge is a repository with some tools that captures a set of dependencies for [mirgecom](https://github.com/illinois-ceesd/mirgecom).

These dependencies are:

1. Miniforge/Conda and conda packages (e.g., pocl)
2. Pip packages (e.g., pyopencl)

# Installation

In most cases, running `./install.sh` should be sufficient to install all dependencies for emirge and mirgecom.

`./install.sh` takes several arguments:
- `--conda-prefix=DIR`: Install conda in `DIR` instead of the default directory (`./miniforge3`).
- `--env-name=NAME`: Create conda environment named `NAME` instead of the default (dgfem).
- `--install-prefix=DIR`: Install mirgecom and git pip packages to `DIR` instead of the default (./).
- `--branch=NAME`: Install the `NAME`d branch of mirgecom instead of the default branch (master).
- `--conda-pkgs=FILE`: Install additional conda packages from list specified in `FILE`.
- `--pip-pkgs=FILE`: Install additional pip packages from list specified in `FILE`.
- `--modules`: Install a modules.zip file that contains a copy of all python packages that are installed through git (see below for details).

## Testing the installation

Testing can be done by:

```bash
$ cd mirgecom/examples; ./run_examples.sh ./
```

## Running on systems with lots of nodes (>256)
On large systems, the file system can become a bottleneck for loading Python
packages. On these systems, it is recommended to create a zip file with the
modules to speed up the startup process. This can be done by specifying the
`--modules` parameter to `install.sh`, or by running `makezip.sh` after
installation.

See https://github.com/illinois-ceesd/planning/issues/26 for more details.


# Manual installation

Please use the instructions above instead.

## Running wavelet0


### Prerequesites

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

# In a new session, you may reactivate this environment using:
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
$ for m in pytools pymbolic dagrt leap loopy meshmode grudge mirgecom; do cd $m && pip install -e . && cd ..; done
```

### Run wavelet0

```bash
$ cd mirgecom/examples; python wave-eager.py
```
