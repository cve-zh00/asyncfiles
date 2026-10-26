
from . cimport uv
from posix.fcntl cimport (
    O_RDONLY, O_WRONLY, O_RDWR,
    O_CREAT, O_TRUNC, O_APPEND, O_EXCL, O_DSYNC, O_SYNC
)

cimport cython

cdef object new_future(object loop):
    # Callers take their own reference (ctx) with Py_INCREF; do not add one here.
    return loop.create_future()

cdef class FileMode:

    def __cinit__(self, bint readable, bint writable, bint plus, bint appending, bint created, int flags, bint binary):
        self.readable = readable
        self.writable = writable
        self.plus = plus
        self.appending = appending
        self.created = created
        self.flags = flags
        self.binary = binary


cpdef FileMode mode_to_posix(const char* mode):
    cdef:
        bint base_mode_found = False
        bint readable = False
        bint writable = False
        bint plus = False
        bint appending = False
        bint created = False
        bint binary = False
        bint text_mode = False

        int flags = 0
        bytes ch

    # Iteración sobre el modo
    for ch in mode:

        # BASE MODES
        if ch == b"r":
            if base_mode_found:
                raise ValueError("Invalid mode: duplicate base mode")
            base_mode_found = True
            readable = True

        elif ch == b"w":
            if base_mode_found:
                raise ValueError("Invalid mode: duplicate base mode")
            base_mode_found = True
            writable = True
            created = True
            flags |= O_CREAT | O_TRUNC | O_WRONLY

        elif ch == b"x":
            if base_mode_found:
                raise ValueError("Invalid mode: duplicate base mode")
            base_mode_found = True
            writable = True
            created = True
            flags |= O_EXCL | O_CREAT

        elif ch == b"a":
            if base_mode_found:
                raise ValueError("Invalid mode: duplicate base mode")
            base_mode_found = True
            writable = True
            created = True
            appending = True
            flags |= O_CREAT | O_APPEND

        # MODIFICADORES
        elif ch == b"+":
            if plus:
                raise ValueError("Invalid mode: duplicate '+'")
            plus = True
            readable = True
            writable = True

        elif ch == b"b":
            binary = True

        elif ch == b"t":
            text_mode = True

        elif ch == b"U":
            # legacy universal-newline, ignorado
            readable = True

        else:
            raise ValueError(f"Invalid mode character: {ch!r}")

    # VALIDACIONES
    if not base_mode_found:
        raise ValueError("Invalid mode: must contain 'r', 'w', 'x', or 'a'")

    # ACCESS MODE
    if readable and writable:
        flags = (flags & ~3) | O_RDWR
    elif readable:
        flags = (flags & ~3) | O_RDONLY
    else:
        flags = (flags & ~3) | O_WRONLY

    return FileMode(
        readable=readable,
        writable=writable,
        plus=plus,
        appending=appending,
        created=created,
        flags=flags,
        binary=binary,
    )
