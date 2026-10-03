import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
inst=top_bits_instance(256,1,1,4)
for (m,t) in ((8,8),(12,12),(20,20)):
    tt=time.time()
    roots,diag=univariate_small_roots([inst['a'],1],inst['N'],inst['X'],m=m,t=t,mod_is_factor=True,cross_check=False)
    print("BAD m=%d t=%d dim=%d %.2fs roots=%s"%(m,t,diag['dim'],time.time()-tt,roots),flush=True)
