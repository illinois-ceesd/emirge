#!/usr/bin/env python3


import sys
sys.path.insert(0, 'modules.zip')


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
