#!/usr/bin/env python3
"""2b: P(p | h(-kN)) as a function of p, k.  The paper claims ~0 always."""
import random, time
import sympy, cypari2
pari = cypari2.Pari(); pari.default("parisizemax", 1<<30)
def h_of(D):
    if D % 4 not in (0,1): D = D*4
    return int(pari.qfbclassno(D))

random.seed(4242)
print("="*78)
print("P(p | h(-4kN))  vs p  -- q fixed just above p, k=1..60, 25 instances/cell")
print("     null expectation (random h): ~1/p")
print(f"{'p':>8} {'1/p':>12} {'measured':>10} {'n':>6} {'ratio':>8}")
rows=[]
for p in [3,7,11,19,23,31,43,59,79,101,151,199,251,307,401,503]:
    hits=0; n=0
    qs=[x for x in sympy.primerange(p+1, 4*p) if x%4==3]
    for _ in range(25):
        q=random.choice(qs); N=p*q
        for k in range(1,61):
            n+=1
            if h_of(-4*k*N) % p == 0: hits+=1
    m=hits/n
    rows.append((p,1.0/p,m,n))
    print(f"{p:8d} {1.0/p:12.5f} {m:10.4f} {n:6d} {m*p:8.3f}")

print()
print("="*78)
print("NULL HARNESS: rate of p | h(-4kN) for a p that does NOT divide N.")
print("  (If the harness returned ~0 here and ~1/p above, it works both ways.)")
for p in [7,23,101,401]:
    hits=0;n=0
    for _ in range(25):
        N=random.choice([x for x in sympy.primerange(10**6,2*10**6) if x%4==3])**2
        for k in range(1,61):
            n+=1
            if h_of(-4*k*N)%p==0: hits+=1
    print(f"  p={p:5d} (p does NOT divide N): {hits}/{n} = {hits/n:.4f}   1/p={1/p:.4f}")

print()
print("="*78)
print("LARGER p: the regime the paper measured (p ~ 2^33)")
for bits in [26, 32, 40]:
    t=time.time(); hits=0; n=0
    for _ in range(6):
        p=sympy.randprime(2**(bits-1), 2**bits)
        q=sympy.randprime(2**(bits-1), 2**bits)
        if q==p: continue
        N=p*q
        for k in [1,2,3,4,5,6,8,12,16,24,32,64,128,256,1024,4096]:
            n+=1
            if h_of(-4*k*N)%p==0: hits+=1
    print(f"  p~2^{bits}: {hits}/{n} hits  (expected ~ n/p = {n/2**(bits-1):.2e})  {time.time()-t:.0f}s")
