from libc.stdint cimport int64_t, uint8_t, uint64_t
cdef extern from "uv.h" nogil:

    ctypedef enum uv_fs_type:
        UV_FS_OPEN
        UV_FS_CLOSE
        UV_FS_READ
        UV_FS_WRITE
        UV_FS_SENDFILE
        UV_FS_STAT
        UV_FS_FSTAT
        UV_FS_LSTAT
        UV_FS_RENAME
        UV_FS_UNLINK
        UV_FS_RMDIR
        UV_FS_MKDIR
        UV_FS_SCANDIR
        UV_FS_READDIR
        UV_FS_CHTIME
        UV_FS_FCHTIME
        UV_FS_ACCESS
        UV_FS_CHMOD
        UV_FS_FCHMOD
        UV_FS_UTIME
        UV_FS_FUTIME
        UV_FS_CWD
        UV_FS_DIRNAME
        UV_FS_REALPATH
        UV_FS_COPYFILE
        UV_FS_SEND_FILE


    enum UV_FS_EVENT:
            UV_RENAME
            UV_CHANGE

    enum UV_POLL_EVENT:
        UV_READABLE
        UV_WRITABLE
    ctypedef struct uv_loop_t

    ctypedef struct uv_req_t:
        void*      data

    ctypedef struct uv_stat_t:
        int64_t st_size

    ctypedef struct uv_buf_t:
        char*  base
        size_t len

    ctypedef struct uv_fs_t:
        void*       data
        uv_fs_type  fs_type
        char*       path
        ssize_t     result
        uv_stat_t   statbuf
    ctypedef void (*uv_fs_cb)(uv_fs_t* req)

    int uv_loop_init(uv_loop_t* loop)
    ctypedef enum uv_run_mode:
        UV_RUN_DEFAULT
        UV_RUN_ONCE
        UV_RUN_NOWAIT
    ctypedef struct uv_handle_t:
        void* data
        uv_loop_t* loop
        unsigned int flags
    ctypedef struct uv_idle_t:
        void* data
        uv_loop_t* loop
    ctypedef struct uv_fs_event_t:
            void *data
    ctypedef void (*uv_idle_cb)(uv_idle_t* handle) with gil
    ctypedef void (*uv_close_cb)(uv_handle_t* handle) with gil
    ctypedef void (*uv_fs_event_cb)(uv_fs_event_t* handle,
                                        const char* filename,
                                        int events,
                                        int status)
    int uv_fs_event_stop(uv_fs_event_t* handle)
    uv_loop_t* uv_default_loop()
    int        uv_run(uv_loop_t* loop, uv_run_mode mode)
    void       uv_stop(uv_loop_t* loop)
    int uv_fs_fsync(uv_loop_t*, uv_fs_t* req,
                        int fd,uv_fs_cb cb)
    int uv_fs_open  (uv_loop_t*, uv_fs_t* req,
                        const char* path, int flags, int mode, uv_fs_cb cb)
    int uv_fs_read  (uv_loop_t*, uv_fs_t* req,
                        int fd, const uv_buf_t* bufs, unsigned int nbufs,
                        int64_t offset, uv_fs_cb cb)
    int uv_fs_write (uv_loop_t*, uv_fs_t* req,
                        int fd, const uv_buf_t* bufs, unsigned int nbufs,
                        int64_t offset, uv_fs_cb cb)
    int uv_fs_stat(uv_loop_t*, uv_fs_t* req,
                        char* name_file, uv_fs_cb cb)
    int uv_fs_close (uv_loop_t*, uv_fs_t* req,
                        int fd, uv_fs_cb cb)
    int uv_fs_fstat (uv_loop_t*, uv_fs_t* req,
                        int fd, uv_fs_cb cb)
    void      uv_fs_req_cleanup(uv_fs_t* req)
    uv_buf_t  uv_buf_init(char* base, unsigned int len)
    int uv_guess_handle(int fd)
    int uv_idle_init(uv_loop_t*, uv_idle_t* idle)
    int uv_idle_start(uv_idle_t* idle, uv_idle_cb cb)
    int uv_idle_stop(uv_idle_t* idle)
    int uv_fs_event_init(uv_loop_t* loop, uv_fs_event_t* handle)
    int uv_fs_event_start(uv_fs_event_t* handle,
                            uv_fs_event_cb cb,
                            const char* path,
                            unsigned int flags)
    void uv_close(uv_handle_t* handle, uv_close_cb close_cb)
    # Poll sobre file descriptors (FD)
    ctypedef struct uv_poll_t:
        void* data  # campo genérico para contexto
    int uv_poll_init(uv_loop_t* loop, uv_poll_t* handle, int fd)
    int uv_poll_start(uv_poll_t* handle, int events,
                        void (*cb)(uv_poll_t*, int, int))
    int uv_poll_stop(uv_poll_t* handle)
