# cython: language_level=3

from libc.stdint cimport uint8_t, uint16_t, uint32_t, uint64_t, int32_t, int64_t

cdef extern from "liburing.h" nogil:

    # Core structs (declared as 'struct' to match C headers)
    struct io_uring:
        pass

    struct io_uring_sqe:
        uint8_t opcode
        uint8_t flags
        uint16_t ioprio
        int32_t fd
        uint64_t off
        uint64_t addr
        uint32_t len
        uint64_t user_data

    struct io_uring_cqe:
        uint64_t user_data
        int32_t res
        uint32_t flags

cdef extern from "<linux/stat.h>" nogil:
    # statx struct for IORING_OP_STATX
    struct statx:
        uint64_t stx_size

cdef extern from "liburing.h" nogil:
    # Queue lifecycle
    int io_uring_queue_init(unsigned int entries, io_uring* ring, unsigned int flags)
    void io_uring_queue_exit(io_uring* ring)

    # SQE acquisition and submission
    io_uring_sqe* io_uring_get_sqe(io_uring* ring)
    int io_uring_submit(io_uring* ring)

    # CQE consumption
    int io_uring_peek_cqe(io_uring* ring, io_uring_cqe** cqe_ptr)
    void io_uring_cqe_seen(io_uring* ring, io_uring_cqe* cqe)

    # eventfd registration
    int io_uring_register_eventfd(io_uring* ring, int fd)

    # SQE preparation helpers
    void io_uring_prep_openat(io_uring_sqe* sqe, int dfd, const char* path,
                              int flags, unsigned int mode)
    void io_uring_prep_close(io_uring_sqe* sqe, int fd)
    void io_uring_prep_read(io_uring_sqe* sqe, int fd, void* buf,
                            unsigned int nbytes, uint64_t offset)
    void io_uring_prep_write(io_uring_sqe* sqe, int fd, const void* buf,
                             unsigned int nbytes, uint64_t offset)
    void io_uring_prep_statx(io_uring_sqe* sqe, int dfd, const char* path,
                             int flags, unsigned int mask, statx* statxbuf)
    void io_uring_prep_ftruncate(io_uring_sqe* sqe, int fd, int64_t len)
