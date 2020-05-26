# emirge - environment for MirgeCom

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
$ for m in dagrt grudge leap loopy meshmode; do cd $m && pip install -e . && cd ..; done
```

### Run wavelet0

```bash
$ cd mirgecom; python wave-eager.py
```
