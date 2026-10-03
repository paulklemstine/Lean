import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
inst=top_bits_instance(256,1,1,2); p=inst['p']
unk=57; a=(p>>unk)<<unk; X=1<<unk
for (m,t) in ((8,8),(12,12)):
    t0=time.time()
    roots,diag=univariate_small_roots([a,1],inst['N'],X,m=m,t=t,mod_is_factor=True,cross_check=False)
    print("m=%d t=%d %.1fs roots=%s vec0=2^%.1f HG=2^%.1f"%(m,t,time.time()-t0,bool(roots),diag['vec0_log2norm'],diag['hg_bound_log2']),flush=True)
