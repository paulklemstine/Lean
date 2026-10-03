#!/usr/bin/env python3
"""
(1) POWER of the 0/890 measurement.
    If P(p|h) ~ 1/p, then at p~2^33 the expected hits in 890 trials is
    890/2^33 ~ 1e-7.  Zero is then the ONLY possible outcome and the
    measurement cannot distinguish "impossible" from "probability 1/p".
(2) Do LARGE-p witnesses exist?  targeted search.
"""
import math, random, time, json
import sympy, cypari2
pari=cypari2.Pari(); pari.default("parisizemax",1<<30)
def h_of(D):
    if D%4 not in (0,1): D=D*4
    return int(pari.qfbclassno(D))

print("="*78)
print("(1) POWER OF THE '0/890' MEASUREMENT")
for bits,ntrial,kk in [(33,890,1.0),(33,890,16),(30,150,5)]:
    p=2**bits
    print(f"  p ~ 2^{bits}, {ntrial} trials, {kk:.0f} k-values per trial")
    print(f"    null P(p|h) ~ 1/p = {1/p:.3e};  expected hits = {ntrial/p:.3e}")
    print(f"    -> observing 0 is {(1-1/p)**ntrial:.10f} likely EVEN IF p|h WERE")
    print(f"       a pure 1/p random event.  The test has NO power.")
print()
print("  The paper's OWN 0-hit cell was p~2^33 with 640 trials:")
print(f"    expected hits under the 1/p null: {640/2**33:.3e}")
print("  So the 'divisibility fails' leg is NOT evidence of impossibility.")
print()

print("="*78)
print("(2) GENUS THEORY CHECK: is 4 | h(-4pq) always for p,q = 3 mod 4?")
random.seed(11); bad=0; n=0
ps3=[x for x in sympy.primerange(3,20000) if x%4==3]
for i,p in enumerate(ps3[:300]):
    q=ps3[i+1]
    h=h_of(-4*p*q); n+=1
    if h%4!=0: bad+=1
print(f"  4 | h(-4pq): {n-bad}/{n}  ({'ALWAYS' if bad==0 else 'EXCEPTIONS: %d'%bad})")
print("  (matches genus theory: t=3 prime discriminants => 2-rank = 2 => 4|h)")
print()

print("="*78)
print("(3) LARGE-p WITNESSES: sweep k up to 20000 for p in 10^3..10^7")
print(f"{'p':>12} {'q':>12} {'k':>7} {'h(-4kN)':>24} {'h/p':>8} {'hbits':>6}")
random.seed(99)
wits=[]; t0=time.time()
for pb in [10**3,10**4,10**5,10**6,10**7]:
    found=False
    for trial in range(6):
        if time.time()-t0>280: break
        p=sympy.randprime(pb,pb*10)
        q=sympy.randprime(pb,pb*10)
        if p==q: continue
        N=p*q
        for k in range(1,20001):
            h=h_of(-4*k*N)
            if h%p==0:
                wits.append((p,q,k,h,h//p))
                print(f"{p:12d} {q:12d} {k:7d} {h:24d} {h//p:8d} {h.bit_length():6d}")
                found=True; break
        if found: break
    if not found: print(f"{pb:12d} {'-':>12} {'-':>7} {'no witness, k<=20000':>24}")
json.dump([[int(a),int(b),int(c),int(d)] for a,b,c,d,_ in wits],
          open('witnesses.json','w'))
print(f"  total witnesses found: {len(wits)}   ({time.time()-t0:.0f}s)")
