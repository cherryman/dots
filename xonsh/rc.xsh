# vim: ft=python
# pyright: reportUnusedVariable=false
# pyright: reportUnusedImport=false
# pyright: reportWildcardImportFromLibrary=false

aliases['ls'] = ['eza']
aliases['tree'] = ['eza', '-T']
aliases['e'] = ['nvim']
aliases['l'] = ['ls', '-l']
aliases['tm'] = ['tmux']
aliases['tf'] = ['terraform']
aliases['g'] = ['git']
aliases['c'] = ['cargo']
aliases['n'] = ['nix']
aliases['nb'] = ['numbat']
aliases['py'] = ['python']
aliases['ipy'] = ['ipython']
aliases['x'] = ['xonsh']
aliases['j'] = ['just']

import os
import sys
import json
import math
import pdb
import hashlib
import pickle
from datetime import datetime
from pathlib import Path
from typing import *

from base64 import b64encode as b64e, b64decode as b64d
from base58 import b58encode as b58e, b58decode as b58d

import numpy as np

# imports a lot of useful stuff. obviates some of the above^
#
# hexdump, read, write, enhex, unhex, more, group,
# align, align_down, urlencode, urldecode, which, wget
#
# os, sys, time, requests, re, random
from pwn import *

def readb(path: str) -> bytes:
    with open(path, "rb") as f: return f.read()

def reads(path: str) -> str:
    with open(path, "r") as f: return f.read()

def writeb(xs: bytes, path: str) -> None:
    with open(path, "wb") as f:
        _ = f.write(xs)

def writes(xs: str, path: str) -> None:
    with open(path, "w") as f:
        _ = f.write(xs)

def xorb(x: bytes, y: bytes) -> bytes:
    return bytes(a ^ b for a, b in zip(x, y))

def xors(x: str, y: str, encoding: str = "utf-8") -> str:
    return xorb(x.encode(encoding), y.encode(encoding)).decode(encoding)

def _solsk_to_hex(path: str) -> str:
    return enhex(bytes(json.loads(reads(path))))

aliases['solsk-to-hex'] = lambda args: _solsk_to_hex(args[0])
