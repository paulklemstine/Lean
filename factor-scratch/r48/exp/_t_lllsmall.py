import random, time
from lll import lll, verify
random.seed(7)
bad=0
for trial in range(25):
    d=random.choice([5,8,12,16])
    B=[[random.getrandbits(400) for _ in range(d)] for _ in range(d)]
    R=lll(B); probs=verify(B,R)
    if probs: bad+=1; print("FAIL d=%d"%d,probs)
print("LLL self-test small: failures =",bad)
for d in (20,30,40):
    B=[[random.getrandbits(1200) for _ in range(d)] for _ in range(d)]
    t=time.time(); R=lll(B); print("d=%d 1200-bit: %.2fs verify=%s"%(d,time.time()-t,verify(B,R) or "ok"))
