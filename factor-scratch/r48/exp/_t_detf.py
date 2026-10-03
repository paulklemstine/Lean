import time, random
from fpylll import IntegerMatrix
from lll import _det_int
random.seed(2)
for d in (20,30,40,60):
    B=[[random.getrandbits(4000) for _ in range(d)] for _ in range(d)]
    t=time.time(); D1=_det_int(B); t1=time.time()-t
    M=IntegerMatrix(d,d)
    for i in range(d):
        for j in range(d): M[i,j]=B[i][j]
    t=time.time(); D2=M.det(); t2=time.time()-t
    print("d=%2d bareiss %.2fs fpylll %.4fs match=%s"%(d,t1,t2,D1==D2),flush=True)
