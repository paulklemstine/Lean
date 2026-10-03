import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
inst=top_bits_instance(256,1,1,2)
print("x0 width",(inst['p']-inst['a']).bit_length(),"X width",inst['X'].bit_length())
for m in (4,6,8,10):
    t=time.time()
    roots,diag=univariate_small_roots([inst['a'],1],inst['N'],inst['X'],m=m,t=1,mod_is_factor=True,cross_check=False)
    print("m=%d dim=%d %.2fs roots=%s"%(m,diag['dim'],time.time()-t,roots[:2]))
