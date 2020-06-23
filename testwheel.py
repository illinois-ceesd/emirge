#!/usr/bin/env python3


import sys
sys.path.insert(0, 'grudge-2015.1-py3-none-any.whl')
sys.path.insert(0, 'dagrt-2019.4-py3-none-any.whl')
sys.path.insert(0, 'leap-2019.5-py3-none-any.whl')
sys.path.insert(0, 'loo.py-2019.1-py3-none-any.whl')
sys.path.insert(0, 'meshmode-2016.1-py3-none-any.whl')


import dagrt
import grudge
import loopy
import meshmode
import leap


print(dagrt.__file__)
print(grudge.__file__)
print(loopy.__file__)
print(meshmode.__file__)
print(leap.__file__)
