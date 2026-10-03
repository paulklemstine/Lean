#!/usr/bin/env python3
"""Explicit witnesses: p | h(-kN).  How big can p be?  What is the k needed?"""
import math, random, time
import sympy, cypari2
pari = cypari2.Pari(); pari.default("parisizemax", 1<<30)
def h_of(D):
    if D % 4 not in (0,1): D = D*4
    return int(pari.qfbclassno(D))

print("="*78)
print("EXPLICIT WITNESSES  p | h(-4kN),  p,q = 3 mod 4")
print(f"{'p':>10} {'q':>10} {'k':>6} {'h(-4kN)':>22} {'h/p':>10} {'h bits':>7}")
found=[]
for p in [11,19,23,31,43,59,67,79,83,101,103,107,127,131,139,151,163,167,179]:
    qs=[x for x in sympy.primerange(p+1,3*p) if x%4==3]
    done=False
    for q in qs:
        N=p*q
        for k in range(1,400):
            h=h_of(-4*k*N)
            if h%p==0:
                found.append((p,q,k,h))
                print(f"{p:10d} {q:10d} {k:6d} {h:22d} {h//p:10d} {h.bit_length():7d}")
                done=True; break
        if done: break
    if not done:
        print(f"{p:10d} {'-':>10} {'-':>6} {'NO WITNESS k<=400':>22}")

print()
print("="*78)
print("STRUCTURE: is the rate ~1/p (random-integer null) or suppressed?")
print("  For each p, count hits over k=1..400 for several q; compare to 400*1/p.")
print(f"{'p':>6} {'1/p':>10} {'measured':>10} {'n':>7} {'ratio m*p':>10} {'z vs null':>10}")
for p in [11,19,23,31,43,59,67,79,83,101,127]:
    hits=0;n=0
    qs=[x for x in sympy.primerange(p+1,4*p) if x%4==3][:6]
    for q in qs:
        N=p*q
        for k in range(1,401):
            n+=1
            if h_of(-4*k*N)%p==0: hits+=1
    m=hits/n; null=1.0/p
    sd=math.sqrt(null*(1-null)/n) if n else 0
    z=(m-null)/sd if sd else 0
    print(f"{p:6d} {null:10.5f} {m:10.5f} {n:7d} {m*p:10.3f} {z:10.2f}")

print()
print("="*78)
print("LARGE-p WITNESS SEARCH: random search at p~2^20..2^30, k up to 20000")
print("  (the paper's regime was p~2^33 with 890 trials; expected hits ~890/2^33)")
t=time.time(); hits=0; n=0; wit=[]
for _ in range(60):
    bits=random.randint(20,30)
    p=sympy.randprime(2**(bits-1),2**bits)
    q=sympy.randprime(2**(bits-1),2**bits)
    if p==q: continue
    N=p*q
    for k in range(1,2001):
        n+=1
        h=h_of(-4*k*N)
        if h%p==0:
            hits+=1; wit.append((p,q,k,h,h.bit_length()))
            break
    if time.time()-t>150: break
print(f"  trials={n} (each = one (p,q) up to k=2000)  instances with a witness: {hits}")
for w in wit[:6]:
    print(f"    p={w[0]} ({w[0].bit_length()}b) q={w[1]} k={w[2]} h={w[3]} ({w[4]}b)")
print(f"  {time.time()-t:.0f}s")
