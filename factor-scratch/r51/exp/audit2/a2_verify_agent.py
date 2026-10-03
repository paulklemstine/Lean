#!/usr/bin/env python3
"""VERIFY the A2 sub-agent's claim that p | h(-kN) actually happens (paper says 0/890)."""
import cypari2, random
from math import isqrt
from sympy import nextprime
pari = cypari2.Pari()

def h_brute(D):
    n=0
    for a in range(1, isqrt(abs(D)//3)+2):
        for b in range(-a+1, a+1):
            num=b*b-D
            if num % (4*a): continue
            c=num//(4*a)
            if c < a: continue
            if a==c and b<0: continue
            n+=1
    return n

print("=== GROUND TRUTH: qfbclassno vs brute-force reduced-form count ===")
Ds=[-3,-4,-7,-8,-11,-15,-19,-20,-23,-24,-31,-35,-40,-43,-47,-51,-52,-55,-59,-67]
ok=sum(int(pari.qfbclassno(D))==h_brute(D) for D in Ds)
print(f"   self-test {ok}/{len(Ds)} agree -> qfbclassno {'TRUSTED' if ok==len(Ds) else 'NOT TRUSTED'}")
assert ok==len(Ds)

def h_kn(k,N):
    d=k*N
    if (-d) % 4 not in (0,1): return None      # not a valid discriminant
    return int(pari.qfbclassno(-d))

print()
print("=== A: N = 11*13 = 143, all VALID k in 1..20000 ===")
p,q,N=11,13,143
valid=[k for k in range(1,20001) if (-k*N)%4 in (0,1)]
found=[(k,h) for k in valid for h in [h_kn(k,N)] if h and h%p==0]
print(f"   {len(valid)} valid k;  hits with {p} | h : {len(found)}")
for k,h in found[:8]: print(f"      k={k:>6}  h(-kN)={h:>14} = {(h//p)}*{p}")

print()
print("=== B: the paper's regime, N ~ 2^38-2^40, k grid as in the paper ===")
random.seed(11)
KS=[1,2,3,4,5,6,8,12,16,24,32,64,128,256,1024,4096]
tot=hits=0; wit=[]
for _ in range(40):
    p=nextprime(random.randrange(2**18,2**19)); q=nextprime(random.randrange(2**19,2**20))
    N=p*q
    for k in KS:
        h=h_kn(k,N)
        if h is None: continue
        tot+=1
        if h%p==0: hits+=1; wit.append((p,q,k,h))
print(f"   trials {tot}, hits {hits}    (paper reports 0/640 and 0/890)")
for p,q,k,h in wit[:8]: print(f"      p={p} q={q} k={k:>5} h={h:>12} = {h//p}*p")
print(f"   -> {'0/890 REPLICATED' if hits==0 else 'AGENT CONFIRMED: p|h DOES fire'}")
