import time
from control import top_bits_instance
from coppersmith import univariate_small_roots
inst=top_bits_instance(256,1,1,2)
p,N,a=inst['p'],inst['N'],inst['a']
for unk in (56,60,62,63,64,66,68):
    aa=(p>>unk)<<unk; X=1<<unk
    got=None
    for m in (4,6,8,10,12,14,16,18,20):
        roots,diag=univariate_small_roots([aa,1],N,X,m=m,t=1,mod_is_factor=True,cross_check=False)
        if roots: got=(m,diag); break
    print("unk=%2d (leak %.1f%% of p) X=2^%d : %s"%(unk,100*(1-unk/p.bit_length()),unk,
        ("FOUND at m=%d"%got[0]) if got else "no root for m<=20"))
