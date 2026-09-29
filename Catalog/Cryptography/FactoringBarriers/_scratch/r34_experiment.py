#!/usr/bin/env python3
"""ROUND 34 -- general-exponent reveal density. Re-derives and tests the
   generalization of AsymmetricExponent.card_revealing (E=N-1) to ARBITRARY E.
   If the idea is WRONG, TEST 1 and TEST 5 fail (brute force != formula).
   If RIGHT, both hold exactly, and TEST 4 shows density->1 on q = k(p-1)-1."""
import math, sys
from sympy import isprime, gcd, nextprime
def P(*a): print(*a); sys.stdout.flush()

# ---- THEOREM UNDER TEST -------------------------------------------------
# For N=pq, ANY exponent E>0, d_p=gcd(E,p-1), d_q=gcd(E,q-1):
#   #revealing bases = d_p*(q-1) + d_q*(p-1) - 2*d_p*d_q
#   #non-revealing    = d_p*d_q                      (the "both-liar" bases)
# E=N-1 recovers the file: d_p=d_q=g=gcd(p-1,q-1)  (Core.gcd_exp_symmetric)
# E=N+1 gives d_p=gcd(q+1,p-1),  d_q=gcd(p+1,q-1)  -- NOT equal in general.
# -----------------------------------------------------------------------
def R(p,q,E):
    dp=int(gcd(E,p-1)); dq=int(gcd(E,q-1))
    return dp*(q-1)+dq*(p-1)-2*dp*dq, dp, dq

P("TEST 1: brute force vs formula, 6 exponents x 4 semiprimes")
bad=0; n=0
for p,q in [(11,13),(23,47),(101,107),(251,419)]:
    N=p*q
    for E in [N-1,N+1,2*N+1,3*N-1,5*N+1,N]:
        br=sum(1 for a in range(1,N) if math.gcd(a,N)==1
               and math.gcd(pow(a,E,N)-1,N) in (p,q))
        f,_,_=R(p,q,E); n+=1
        if br!=f: bad+=1; P(f"  MISMATCH p={p} q={q} E={E} brute={br} formula={f}")
P(f"  {n-bad}/{n} exact  ->  {'THEOREM HOLDS' if bad==0 else 'THEOREM FALSE'}")

P("\nTEST 5: non-revealers == d_p*d_q exactly")
for p,q in [(101,199),(107,317),(109,431)]:
    N=p*q; f,dp,dq=R(p,q,N+1); phi=(p-1)*(q-1)
    P(f"  p={p:4d} q={q:4d}: phi-R={phi-f:6d}  d_p*d_q={dp*dq:6d}  {'EXACT' if phi-f==dp*dq else 'FALSE'}")

P("\nTEST 4: CROSSED class q = k(p-1)-1  =>  d_p = p-1, density -> 1, ONE gcd")
for k in [2,3,4]:
    for p in range(101,5000):
        if not isprime(p): continue
        q=k*(p-1)-1
        if not isprime(q): continue
        N=p*q; f,dp,dq=R(p,q,N+1); phi=(p-1)*(q-1)
        rv=sum(1 for a in range(2,min(p,300)) if math.gcd(pow(a,N+1,N)-1,N) in (p,q))
        tot=min(p,300)-2
        P(f"  k={k} p={p:5d} q={q:6d} d_p={dp:5d} d_q={dq:3d} density={f/phi:.6f} trials={phi/f:6.3f}"
          f"  brute {rv}/{tot} reveal")
        break

P("\nTEST 3: N-1 is SYMMETRIC (blind); N+1 is not.  gcd(g1,g2) | 2  (near-orthogonal)")
bad2=0; asym=0
import random; random.seed(3)
for _ in range(2000):
    p=int(nextprime(random.randint(3,10**6))); q=int(nextprime(random.randint(3,10**6)))
    if p==q: continue
    g1=int(gcd(p-1,q-1)); g2=int(gcd(p-1,q+1))
    if int(gcd(g1,g2)) not in (1,2): bad2+=1
    if int(gcd(p*q+1,p-1))!=int(gcd(p*q+1,q-1)): asym+=1
P(f"  2000 pairs: violations of gcd(g1,g2)|2 : {bad2}   N+1-asymmetric on {asym}/2000")

P("\nTEST 2: c != 1 is STRICTLY WORSE than c = 1 (the 'a^N-c' sub-idea is DEAD)")
for p,q in [(23,47),(59,83),(251,419)]:
    N=p*q; dp=int(gcd(N-1,p-1)); dq=int(gcd(N-1,q-1))
    R1=dp*(q-1)+dq*(p-1)-2*dp*dq
    best=max([dp*(q-1) for c in range(2,80)
              if pow(c,dp,p)==1 and pow(c,dq,q)!=1]+[0])
    P(f"  p={p:4d} q={q:4d} g={int(gcd(p-1,q-1)):3d}: c=1 -> {R1:6d} ; best c!=1 -> {best:6d}"
      f"  ratio={(R1/best if best else float('inf')):.3f}  c=1 {'WINS' if R1>best else 'LOSES'}")

P("\nTEST 6: MODERATE-g threshold for c=1,E=N-1. trials = A*B/(A+B-2), A=(p-1)/g")
P("   => g = p^beta  =>  trials ~ N^{(1-beta)/2}/2.  To match N^{1/4} you need beta=1/2, g ~ sqrt(p).")
for bits,beta in [(16,0.25),(16,0.5),(18,0.25),(18,0.5)]:
    Pbit=1<<bits; g=Pbit**beta; A=(Pbit-1)/g
    p=int(nextprime(Pbit)); c=int(nextprime(p))
    while c<6*Pbit:
        if isprime(c) and c>p and int(gcd(p-1,c-1))==int(g): break
        c=int(nextprime(c))
    N=p*c; f,_,_=R(p,c,N-1); phi=(p-1)*(c-1); tr=phi/f
    P(f"   2^{bits}: beta={beta} g={int(g):5d} A={A:9.1f} pred_trials={A/2:9.1f}"
      f"  MEASURED={tr:9.2f}  N-exp={math.log(tr)/math.log(N):.4f} (pred {(1-beta)/2:.4f})")
