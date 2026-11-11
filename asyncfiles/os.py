"""Async wrappers around os filesystem functions."""

from __future__ import annotations

import os as _os

from . import ospath as path
from .ospath import wrap


access = wrap(_os.access)
link = wrap(_os.link)
listdir = wrap(_os.listdir)
lstat = wrap(_os.lstat)
makedirs = wrap(_os.makedirs)
mkdir = wrap(_os.mkdir)
readlink = wrap(_os.readlink)
remove = wrap(_os.remove)
removedirs = wrap(_os.removedirs)
rename = wrap(_os.rename)
renames = wrap(_os.renames)
replace = wrap(_os.replace)
rmdir = wrap(_os.rmdir)
scandir = wrap(_os.scandir)
stat = wrap(_os.stat)
symlink = wrap(_os.symlink)
truncate = wrap(_os.truncate)
unlink = wrap(_os.unlink)

__all__ = [
    "access",
    "link",
    "listdir",
    "lstat",
    "makedirs",
    "mkdir",
    "path",
    "readlink",
    "remove",
    "removedirs",
    "rename",
    "renames",
    "replace",
    "rmdir",
    "scandir",
    "stat",
    "symlink",
    "truncate",
    "unlink",
    "wrap",
]

if hasattr(_os, "statvfs"):
    statvfs = wrap(_os.statvfs)
    __all__.append("statvfs")
