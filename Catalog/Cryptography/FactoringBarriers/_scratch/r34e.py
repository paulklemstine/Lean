import math, sys
from sympy import isprime, gcd, nextprime
def P(*a): print(*a); sys.stdout.flush()

P("=== TEST 6b CORRECTED: measured trials for c=1, E=N-1, at controlled g ===")
P("   theory: p-1=gA, q-1=gB, trials = phi/R = A*B/(A+B-2); balanced A=B -> A^2/(2(A-1)) ~ A/2")
P("   g = p^beta => A = p^(1-beta) => trials ~ N^{(1-beta)/2}/2")
P("")
P("   bits   beta    g=p^beta   A=(p-1)/g     predicted trials   MEASURED trials (from formula)   MEASURED N-exp")
for bits in [16,20,24]:
    Pbit=1<<bits
    for beta in [0.25,0.5]:
        g=Pbit**beta; A=(Pbit-1)/g
        pred=A/2
        # real: find primes p,q with gcd(p-1,q-1)=g exactly and p~q~Pbit
        p=int(nextprime(Pbit)); q=None; c=int(nextprime(p))
        while c<4*Pbit:
            if isprime(c) and int(gcd(p-1,c-1))==int(g) and c>p: q=c; break
            c=int(nextprime(c))
        if q is None: P(f"   {bits:3d}  {beta:4.2f}   {int(g):6d}   {A:8.1f}   {pred:14.1f}   (no balanced prime pair found)"); continue
        N=p*q; gg=int(gcd(p-1,q-1))
        dp=int(gcd(N-1,p-1)); dq=int(gcd(N-1,q-1))
        R=dp*(q-1)+dq*(p-1)-2*dp*dq; phi=(p-1)*(q-1)
        tr=phi/R
        Nexp=math.log(tr)/math.log(N) if tr>1 else 0.0
        P(f"   {bits:3d}  {beta:4.2f}   {gg:6d}   {A:8.1f}   {pred:14.1f}   {tr:20.2f}   {Nexp:8.4f}   (predicted (1-beta)/2 = {(1-beta)/2:.4f})")

P("")
P("=== TEST 8: MATCHED-promise head-to-head. same p, same M. Euler q=1 mod M vs Crossed q=-1 mod M ===")
p=2003   # p-1 = 2002 = 2*7*11*13
def findq(M,sign):
    c=int(nextprime(M)); 
    while c<10**7:
        if isprime(c) and c%M==sign: return c
        c=int(nextprime(c))
    return None
P(f"   p={p} (p-1={p-1}), M ranges over divisors of p-1; compare reveal DENSITY at identical promise size M")
P(f"   {'M':>6} {'q=1 mod M':>12} {'Euler dens':>12} {'Euler tr':>12} | {'q=-1 mod M':>12} {'Cross dens':>12} {'Cross tr':>10}")
for M in [2,7,11,13,14,22,26,77,91,143,154,182,286,1001,2002]:
    q1=findq(M,1); q2=findq(M,M-1)
    def dens(p,q,E):
        N=p*q; dp=int(gcd(E,p-1)); dq=int(gcd(E,q-1))
        R=dp*(q-1)+dq*(p-1)-2*dp*dq; phi=(p-1)*(q-1)
        return R/phi, phi/R
    if q1:
        d1,t1=dens(p,q1,p*q1-1); s1=f"{q1:12d} {d1:12.6f} {t1:12.1f}"
    else: s1=f"{'-':>12} {'-':>12} {'-':>12}"
    if q2:
        d2,t2=dens(p,q2,p*q2+1); s2=f"{q2:12d} {d2:12.6f} {t2:10.3f}"
    else: s2=f"{'-':>12} {'-':>12} {'-':>10}"
    P(f"   {M:6d} {s1} | {s2}")
