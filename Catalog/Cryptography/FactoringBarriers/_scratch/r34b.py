import math, random
from sympy import isprime, gcd, nextprime

print("=== TEST 2: is a^N - c ever denser than a^N - 1 ?  (c=1 should win) ===")
for p,q in [(23,47),(101,107),(251,419)]:
    N=p*q; g=int(gcd(p-1,q-1)); dp=int(gcd(N-1,p-1)); dq=int(gcd(N-1,q-1))
    R1=dp*(q-1)+dq*(p-1)-2*dp*dq
    best=0; nc=0
    for c in range(2,60):
        if pow(c,dp,p)!=1: continue
        if pow(c,dq,q)==1: continue
        best=max(best, dp*(q-1)); nc+=1
    print(f"  p={p:4d} q={q:4d} g={g:3d}: c=1 -> {R1:6d} revealing; best one-sided c!=1 -> {best:6d}"
          f"  (ratio c=1/best = {(R1/best if best else float('inf')):.3f}; {nc} such c found)")

print()
print("=== TEST 3: NEAR-ORTHOGONALITY  gcd(g1,g2) | 2,  g1=gcd(p-1,q-1), g2=gcd(p-1,q+1) ===")
bad=0; n=0
random.seed(7)
for _ in range(4000):
    p=int(nextprime(random.randint(3,10**6))); q=int(nextprime(random.randint(3,10**6)))
    if p==q: continue
    n+=1
    g1=int(gcd(p-1,q-1)); g2=int(gcd(p-1,q+1))
    if int(gcd(g1,g2)) not in (1,2): bad+=1
    # also: gcd(N+1,p-1) and gcd(N+1,q-1) are NOT equal in general
print(f"  checked {n} prime pairs; violations of gcd(g1,g2)|2 : {bad}")
for p,q in [(251,419),(23,47)]:
    N=p*q
    print(f"  p={p:4d} q={q:4d}: gcd(N-1,p-1)={int(gcd(N-1,p-1)):4d}  gcd(N-1,q-1)={int(gcd(N-1,q-1)):4d}  <-- SYMMETRIC (file's blindness)"
          f"  ||  gcd(N+1,p-1)={int(gcd(N+1,p-1)):4d}  gcd(N+1,q-1)={int(gcd(N+1,q-1)):4d}  <-- ASYMMETRIC")

print()
print("=== TEST 4: CROSSED CLASS  q = k(p-1) - 1  =>  gcd(p-1,q+1)=p-1, density -> 1, ONE gcd ===")
for k in [2,3,4]:
    for p in range(101,4000):
        if not isprime(p): continue
        q=k*(p-1)-1
        if not isprime(q): continue
        N=p*q
        dp=int(gcd(N+1,p-1)); dq=int(gcd(N+1,q-1))
        R=dp*(q-1)+dq*(p-1)-2*dp*dq; phi=(p-1)*(q-1)
        # brute force a few bases: is EVERY a revealing?
        trial=0; fails=0
        for a in range(2, min(p,400)):
            g=math.gcd(pow(a,N+1,N)-1,N)
            if g in (p,q): trial+=1
            else: fails+=1
        print(f"  k={k} p={p:5d} q={q:6d} dp={dp:5d} dq={dq:3d}  density={R/phi:.6f}"
              f"  brute: {trial} reveal / {fails} fail out of {min(p,400)-2}")
        break
