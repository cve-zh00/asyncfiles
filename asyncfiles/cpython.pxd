cdef extern from "Python.h":
    void PyMem_RawFree(void *p) nogil
    ctypedef enum PyGILState_STATE:
        pass
    ctypedef struct _object:
            pass
    ctypedef _object PyObject
    PyGILState_STATE PyGILState_Ensure()
    void PyGILState_Release(PyGILState_STATE)
