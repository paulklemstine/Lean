import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
inst=top_bits_instance(256,1,1,4)
print("KNOWN-BAD setup done, unk=",inst['unknown'],flush=True)
t=time.time()
roots,diag=univariate_small_roots([inst['a'],1],inst['N'],inst['X'],mod_is_factor=True,m=8,t=8,cross_check=False)
print("one param: %.2fs roots=%s"%(time.time()-t,roots),flush=True)
