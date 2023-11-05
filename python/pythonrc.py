# https://docs.python.org/3/using/cmdline.html#envvar-PYTHONSTARTUP
# https://docs.python.org/3/library/readline.html#example
# https://github.com/python/cpython/blob/main/Lib/site.py @ enablerlcompleter()

import os
import pdb
import atexit
import readline
import numpy as np
import matplotlib.pyplot as plt

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

print("imported: os, pdb, np, plt")
