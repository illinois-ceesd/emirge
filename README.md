# emirge

emirge: environment for MirgeCom


## Running wavelet0


### Install prerequesites

```
$ conda install pocl
```

### Install Python packages and run wave-eager

```bash
$ for m in dagrt grudge leap loopy meshmode; do cd $m; pip install -e .; cd ..; done
$ cd mirgecom; python wave-eager.py
```
