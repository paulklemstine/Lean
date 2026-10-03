import time, math
from control import top_bits_instance
from coppersmith import univariate_lattice
from reduce import det, reduce_fpylll
inst=top_bits_instance(256,1,1,2); p,N=inst['p'],inst['N']
for unk in (57,):
    a=(p>>unk)<<unk; X=1<<unk
    for (m,t) in ((8,8),(12,12),(16,16),(20,20)):
        t0=time.time(); rows,scale=univariate_lattice([a,1],N,X,m,t); tb=time.time()-t0
        t0=time.time(); D=abs(det(rows)); td=time.time()-t0
        t0=time.time(); R=reduce_fpylll(rows); tr=time.time()-t0
        print("dim=%2d build %.2fs det %.2fs lll %.2fs"%(m+t,tb,td,tr),flush=True)
