import random, time
from lll import lll, verify
for d,bits,delta in ((30,1200,0.99),(30,1200,0.75),(40,1200,0.75),(40,1200,0.99)):
    random.seed(3)
    B=[[random.getrandbits(bits) for _ in range(d)] for _ in range(d)]
    t=time.time()
    try:
        R=lll(B,delta=delta,max_steps=200000); print("d=%d %d-bit delta=%.2f: %.2fs verify=%s"%(d,bits,delta,time.time()-t,verify(B,R,delta=delta) or "ok"))
    except Exception as e: print("d=%d delta=%.2f: %s (%.1fs)"%(d,delta,e,time.time()-t))
