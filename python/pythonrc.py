# https://docs.python.org/3/using/cmdline.html#envvar-PYTHONSTARTUP
# https://docs.python.org/3/library/readline.html#example
# https://github.com/python/cpython/blob/main/Lib/site.py @ enablerlcompleter()

import os
import atexit
import readline

python_history = os.path.join(
    os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state"),
    "python_history",
)

try:
    readline.read_history_file(python_history)
except OSError:
    pass

# Prevent creation of default history if empty.
if readline.get_current_history_length() == 0:
    readline.add_history("# Dummy entry")

def _write_python_history(p):
    import readline

    try:
        readline.write_history_file(p)
    except OSError:
        pass


atexit.register(_write_python_history, python_history)

del (python_history, _write_python_history, atexit, readline)


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

import numpy as np
import pandas as pd
import sympy as sym
import torch

def xorb(x: bytes, y: bytes) -> bytes:
    return bytes(a ^ b for a, b in zip(x, y))

def xors(x: str, y: str, encoding: str = "utf-8") -> str:
    return xor_bytes(x.encode(encoding), y.encode(encoding)).decode(encoding)

def readb(path: str) -> bytes:
    with open(path, "rb") as f: return f.read()

def reads(path: str) -> str:
    with open(path, "r") as f: return f.read()

def writeb(xs: bytes, path: str) -> None:
    with open(path, "wb") as f: f.write(xs)

def writes(xs: str, path: str) -> None:
    with open(path, "w") as f: f.write(xs)
