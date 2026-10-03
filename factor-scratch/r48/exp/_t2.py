import random, time
from lll import lll, verify
random.seed(7)
for d in (5,8,10):
    B=[[random.getrandbits(400) for _ in range(d)] for _ in range(d)]
    t=time.time()
    try:
        R=lll(B,max_steps=20000); print("d=%d ok %.2fs verify=%s"%(d,time.time()-t,verify(B,R) or "ok"))
    except Exception as e:
        print("d=%d FAIL %s (%.2fs)"%(d,e,time.time()-t))
