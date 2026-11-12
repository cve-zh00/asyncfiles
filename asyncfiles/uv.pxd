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

    ctypedef struct uv_timespec_t:
        long tv_sec
        long tv_nsec

    ctypedef struct uv_stat_t:
        uint64_t st_dev
        uint64_t st_mode
        uint64_t st_nlink
        uint64_t st_uid
        uint64_t st_gid
        uint64_t st_rdev
        uint64_t st_ino
        int64_t st_size
        uint64_t st_blksize
        uint64_t st_blocks
        uint64_t st_flags
        uint64_t st_gen
        uv_timespec_t st_atim
        uv_timespec_t st_mtim
        uv_timespec_t st_ctim
        uv_timespec_t st_birthtim

    ctypedef struct uv_statfs_t:
        uint64_t f_type
        uint64_t f_bsize
        uint64_t f_blocks
        uint64_t f_bfree
        uint64_t f_bavail
        uint64_t f_files
        uint64_t f_ffree
        uint64_t f_spare[4]

    ctypedef enum uv_dirent_type_t:
        UV_DIRENT_UNKNOWN
        UV_DIRENT_FILE
        UV_DIRENT_DIR
        UV_DIRENT_LINK
        UV_DIRENT_FIFO
        UV_DIRENT_SOCKET
        UV_DIRENT_CHAR
        UV_DIRENT_BLOCK

    ctypedef struct uv_dirent_t:
        const char* name
        uv_dirent_type_t type

    enum:
        UV_EOF
        UV_FS_SYMLINK_DIR
        UV_FS_SYMLINK_JUNCTION
        UV_FS_COPYFILE_EXCL
        UV_FS_COPYFILE_FICLONE
        UV_FS_COPYFILE_FICLONE_FORCE

    ctypedef struct uv_buf_t:
        char*  base
        size_t len

    ctypedef struct uv_fs_t:
        void*       data
        uv_fs_type  fs_type
        void*       ptr
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
    int        uv_backend_fd(const uv_loop_t* loop)
    int        uv_backend_timeout(const uv_loop_t* loop)
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
                        const char* name_file, uv_fs_cb cb)
    int uv_fs_lstat(uv_loop_t*, uv_fs_t* req,
                        const char* path, uv_fs_cb cb)
    int uv_fs_close (uv_loop_t*, uv_fs_t* req,
                        int fd, uv_fs_cb cb)
    int uv_fs_fstat (uv_loop_t*, uv_fs_t* req,
                        int fd, uv_fs_cb cb)
    int uv_fs_ftruncate(uv_loop_t*, uv_fs_t* req,
                        int fd, int64_t offset, uv_fs_cb cb)
    int uv_fs_unlink(uv_loop_t*, uv_fs_t* req,
                        const char* path, uv_fs_cb cb)
    int uv_fs_mkdir(uv_loop_t*, uv_fs_t* req,
                        const char* path, int mode, uv_fs_cb cb)
    int uv_fs_rmdir(uv_loop_t*, uv_fs_t* req,
                        const char* path, uv_fs_cb cb)
    int uv_fs_rename(uv_loop_t*, uv_fs_t* req,
                        const char* path, const char* new_path, uv_fs_cb cb)
    int uv_fs_link(uv_loop_t*, uv_fs_t* req,
                        const char* path, const char* new_path, uv_fs_cb cb)
    int uv_fs_symlink(uv_loop_t*, uv_fs_t* req,
                        const char* path, const char* new_path, int flags, uv_fs_cb cb)
    int uv_fs_readlink(uv_loop_t*, uv_fs_t* req,
                        const char* path, uv_fs_cb cb)
    int uv_fs_realpath(uv_loop_t*, uv_fs_t* req,
                        const char* path, uv_fs_cb cb)
    int uv_fs_access(uv_loop_t*, uv_fs_t* req,
                        const char* path, int mode, uv_fs_cb cb)
    int uv_fs_scandir(uv_loop_t*, uv_fs_t* req,
                        const char* path, int flags, uv_fs_cb cb)
    int uv_fs_scandir_next(uv_fs_t* req, uv_dirent_t* ent)
    int uv_fs_copyfile(uv_loop_t*, uv_fs_t* req,
                        const char* path, const char* new_path, int flags, uv_fs_cb cb)
    int uv_fs_statfs(uv_loop_t*, uv_fs_t* req,
                        const char* path, uv_fs_cb cb)
    void      uv_fs_req_cleanup(uv_fs_t* req)
    const char* uv_err_name(int err)
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
