import random, time
from lll import lll, verify
random.seed(7); bad=0
for trial in range(40):
    d=random.choice([5,8,12,16,20])
    B=[[random.getrandbits(400) for _ in range(d)] for _ in range(d)]
    R=lll(B,max_steps=60000); p=verify(B,R)
    if p: bad+=1; print("FAIL d=%d"%d,p)
print("LLL self-test (40 lattices, d<=20): failures =",bad)
for d,bits in ((30,1200),(40,1200),(50,1200),(60,2000)):
    random.seed(3)
    B=[[random.getrandbits(bits) for _ in range(d)] for _ in range(d)]
    t=time.time()
    try:
        R=lll(B); print("d=%d %d-bit: %.2fs verify=%s"%(d,bits,time.time()-t,verify(B,R) or "ok"))
    except Exception as e: print("d=%d %d-bit FAIL %s"%(d,bits,e))
