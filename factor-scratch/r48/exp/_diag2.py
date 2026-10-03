import random, time
from math import log2
import lll as L
for d,bits in ((20,1200),(20,400),(30,400)):
    random.seed(11)
    B=[[random.getrandbits(bits) for _ in range(d)] for _ in range(d)]
    t=time.time()
    try:
        R=L.lll(B,max_steps=3000); print("d=%d bits=%d ok %.2fs"%(d,bits,time.time()-t))
    except Exception as e:
        print("d=%d bits=%d %s (%.2fs)"%(d,bits,e,time.time()-t))
