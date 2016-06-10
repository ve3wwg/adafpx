   type sigproc_t is access procedure(Sig : sig_t);
   pragma Convention(C,sigproc_t);
    
   type sigrest_t is access procedure;
   pragma Convention(C,sigrest_t);


