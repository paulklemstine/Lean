import time, random
from fpylll import IntegerMatrix, LLL
random.seed(1)
for d,bits in ((20,1200),(40,1200),(60,2400),(80,2400)):
    B=[[random.getrandbits(bits) for _ in range(d)] for _ in range(d)]
    M=IntegerMatrix(d,d)
    for i in range(d):
        for j in range(d): M[i,j]=B[i][j]
    t=time.time(); LLL.reduction(M); print("fpylll d=%d %d-bit: %.3fs"%(d,bits,time.time()-t))
