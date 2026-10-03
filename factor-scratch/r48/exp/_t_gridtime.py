import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
inst=top_bits_instance(256,1,1,4)   # KNOWN-BAD: must fail on all
p=inst['p']; unk=inst['unknown']; a=(p>>unk)<<unk; X=1<<unk
for (m,t) in ((8,8),(12,12),(16,16),(8,16),(16,8),(20,20),(12,24),(24,12),(28,28)):
    t0=time.time()
    roots,diag=univariate_small_roots([a,1],inst['N'],X,m=m,t=t,mod_is_factor=True,cross_check=False)
    print("dim=%2d %6.1fs roots=%s"%(m+t,time.time()-t0,bool(roots)),flush=True)
