from .cpython cimport PyObject
from . cimport uv
from .context cimport FSReadContext


cdef class _ReadResult:
    cdef:
        FSReadContext* ctx
        Py_ssize_t bytes_read


cdef object _uv_oserror(int uv_err, str msg)
cdef void cb_open(uv.uv_fs_t* req) noexcept with gil
cdef void cb_close(uv.uv_fs_t* req) noexcept with gil
cdef void cb_write(uv.uv_fs_t* req) noexcept with gil
cdef void cb_read(uv.uv_fs_t* req) noexcept with gil
cdef void cb_readinto(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat(uv.uv_fs_t* req) noexcept with gil
cdef void cb_ftruncate(uv.uv_fs_t* req) noexcept with gil
cdef void cb_ignore(uv.uv_fs_t* req) noexcept with gil
cdef void cb_full_stat(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat_exists(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat_isfile(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat_isdir(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat_islink(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat_mtime(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat_atime(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat_ctime(uv.uv_fs_t* req) noexcept with gil
cdef void cb_access_bool(uv.uv_fs_t* req) noexcept with gil
cdef void cb_ptr_bytes(uv.uv_fs_t* req) noexcept with gil
cdef void cb_scandir_names_str(uv.uv_fs_t* req) noexcept with gil
cdef void cb_scandir_names_bytes(uv.uv_fs_t* req) noexcept with gil
cdef void cb_scandir_entries(uv.uv_fs_t* req) noexcept with gil
cdef void cb_statfs(uv.uv_fs_t* req) noexcept with gil
