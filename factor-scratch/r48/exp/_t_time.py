import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
# in-regime (unk=57) and out (unk=96), time the smallest useful dims
for unk in (57,96):
    inst=top_bits_instance(256,1,1,2)
    p=inst['p']; a=(p>>unk)<<unk; X=1<<unk
    for (m,t) in ((8,8),(10,10),(12,12),(14,14)):
        tt=time.time()
        roots,diag=univariate_small_roots([a,1],inst['N'],X,m=m,t=t,mod_is_factor=True,cross_check=False)
        print("unk=%d dim=%2d %5.1fs roots=%s"%(unk,m+t,time.time()-tt,bool(roots)),flush=True)
