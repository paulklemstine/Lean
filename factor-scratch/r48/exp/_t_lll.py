import random, time
from lll import lll, verify, _det_int, row_log2norm
random.seed(7)
bad=0
for trial in range(40):
    d=random.choice([5,8,12,16]); 
    B=[[random.getrandbits(400) for _ in range(d)] for _ in range(d)]
    R=lll(B); probs=verify(B,R)
    if probs: bad+=1; print("FAIL d=%d"%d,probs)
print("LLL self-test: 40 random lattices, failures =",bad)
for d in (20,30,40,50,60):
    B=[[random.getrandbits(2000) for _ in range(d)] for _ in range(d)]
    t=time.time(); R=lll(B); el=time.time()-t
    print("d=%d 2000-bit: %.2fs  verify=%s"%(d,el,verify(B,R) or "ok"))
