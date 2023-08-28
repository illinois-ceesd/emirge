# emirge - environment for MirgeCom

[![CI test](https://github.com/illinois-ceesd/emirge/workflows/CI%20test/badge.svg)](https://github.com/illinois-ceesd/emirge/actions?query=workflow%3A%22CI+test%22+event%3Apush)

Emirge is a repository with some tools that captures a set of dependencies for [mirgecom](https://github.com/illinois-ceesd/mirgecom), as well as mirgecom itself.

The mirgecom dependencies that emirge installs are:

1. Miniforge/Conda and conda packages (e.g., pocl)
2. Pip packages (e.g., pyopencl)

# Installation

In most cases, running `./install.sh` should be sufficient to install all packages and their dependencies.

`./install.sh` takes several arguments:
- `--install-prefix=DIR`: Install mirgecom and git pip packages to `DIR` instead of the default (./).
- `--conda-prefix=DIR`: Install conda in `DIR` instead of the default directory (`./miniforge3`).
- `--env-name=NAME`: Create conda environment named `NAME` instead of the default (ceesd).
- `--modules`: Install a modules.zip file that contains a copy of all python packages that are installed through git (see below for details).
- `--branch=NAME`: Install the `NAME`d branch of mirgecom instead of the default branch (main).
- `--fork=NAME` : Install mirgecom from a fork (default=illinois-ceesd).
- `--conda-pkgs=FILE`: Install additional conda packages from the list of package names specified in `FILE`.
- `--conda-env=FILE`: Obtain conda package versions from conda environment file FILE.
- `--pip-pkgs=FILE`: Install additional pip packages from the pip requirements file specified in `FILE`.
- `--git-ssh`: Use SSH-based URL to clone mirgecom.
- `--debug`: Show debugging output of this script (set -x).
- `--skip-clone`: Skip cloning mirgecom, assume it will be manually copied to the selected installation prefix.
- `--py-ver=VERSION`: Replace the Python version specified in the conda environment file with `VERSION` (e.g., `--py-ver=3.10`).
- `--help`: Print this help text.

# Testing the installation

Testing can be done by:

```bash
$ mirgecom/examples/run_examples.sh mirgecom/examples/
```
