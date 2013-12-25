
    type errno_t is new int_t;
    type fcntl_t is new int_t;
    type whence_t is new int_t;
    type mntflags_t is new int_t;
    type amode_t is new uint_t;
    type ptrace_t is new int_t;
    type rlimkind_t is new int_t;
    type rwho_t is new int_t;

    type sigproc_t is access procedure(Sig : int_t);
    pragma Convention(C,sigproc_t);
    
