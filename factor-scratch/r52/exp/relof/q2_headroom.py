#!/usr/bin/env python3
"""
Q2: Is the (2 - 1/p) excess divisibility of a^2-b^k values already captured by
the factor base + sieve, or is there headroom?

THEORY (proved, exact):
  #{(a,b) in [0,p^k)^2 : p^k | a^2 - b^3} = p^k (2 - 1/p)
  Decomposition:
    (i)  p _|_ b : rate EXACTLY uniform 1/p^k  (1+Legendre(b^3) roots, summed)
    (ii) p | b   : ALL the excess.
  So the excess is entirely the p|a AND p|b stratum.

NFS TRANSLATION -- is that stratum already sieved?
  Montgomery cubic F(x,y) = (d x+y)^3 + c,  N = d^3 + c.
  p | F  <=>  (dx+y)^3 = -c mod p.  The FB is {p : -c is a cube mod p}.
  A sieve cell (x,y) is MARKED by p iff p | F(x,y)  <=> p divides the TRUE value.
  => the sieve divides by p exactly on the p|F stratum, i.e. on ALL of the excess.
"""
import sys, math
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')
import numpy as np
from sympy import integer_nthroot, primerange, factorint
from relcore import psi_exact

def nroots_cubic(p, a):
    a%=p
    return sum(1 for x in range(p) if pow(x,3,p)==a)

print("="*72)
print("PART 1 -- the excess is exactly the p|a,p|b stratum (exhaustive, exact)")
print("="*72)
def exact_strata(p,k):
    m=p**k
    nb0=nb1=c0=0
    for b in range(m):
        t=pow(b,3,m)
        cc=sum(1 for a in range(m) if (a*a-t)%m==0)
        if b%p==0: nb0+=cc; c0+=1
        else: nb1+=cc
    return nb0,nb1,c0,m-c0
rows=[]
for p in [3,5,7,11,13,17,19,23]:
    for k in [1,2,3]:
        nb0,nb1,c0,c1=exact_strata(p,k)
        m=p**k
        unit_rate = nb1/(c1*m)      # per (a,b) with p∤b
        pb_rate   = nb0/(c0*m)
        rows.append((p,k,nb0,nb1,c0,c1,unit_rate,pb_rate,1/m,1/p,(nb0+nb1)/m))
print(f"{'p':>3}{'k':>3} | {'unit rate':>12} {'1/p^k':>12} {'EXACTLY uniform?':>17} | {'p|b rate':>10} {'1/p':>8}")
okU=okR=True
for p,k,nb0,nb1,c0,c1,ur,pr,unif,pv,tot in rows:
    if k>=2:
        eu = abs(ur-unif)<1e-12
        okU&=eu
        print(f"{p:>3}{k:>3} | {ur:>12.9f} {unif:>12.9f} {str(eu):>17} | {pr:>10.6f} {pv:>8.4f}")
    okR &= abs(tot-(2-1/p))<1e-12
print()
print(f"  ratio == 2-1/p EXACTLY for every (p,k) tested : {okR}")
print(f"  p_nmid_b stratum EXACTLY uniform (1/p^k)      : {okU}")

print()
print("="*72)
print("PART 2 -- NFS: does the ordinary sieve already capture it?")
print("="*72)
# The sieve marks a cell iff p | F(x,y).  For a cubic there are nroots in {0,1,3}.
print("  #roots of X^3=a mod p, and the sieve's implied mark rate:")
for p in [7,11,13,19,23,29,31]:
    a=(-5)%p
    r=nroots_cubic(p,a)
    print(f"   p={p:<3} nroots={r}  mark rate=r/p={r/p:.6f}   (uniform 1/p={1/p:.6f}, ratio={r:.3f})")
print()
print("  => For a CUBIC the excess factor is the root count (0,1,3) -- NOT 2-1/p.")
print("     The 2-1/p law belongs to the QUADRATIC/SPECIAL form a^2-b^k.")
print("     In BOTH cases the sieve's mark rate IS r_p/p: it divides by exactly the")
print("     primes that divide the true value, on exactly the cells where they do.")

# EMPIRICAL: measure P(p|F) over a box and compare to nroots/p
print()
print("  EMPIRICAL P(p | F(x,y)) on a real NFS box, vs r_p/p:")
N=1000003*1000033
d=integer_nthroot(N,3)[0]+1; c=N-d**3
assert d**3+c==N
X=Y=400
rng=np.random.default_rng(0)
xs=rng.integers(1,X+1,4000); ys=rng.integers(0,Y+1,4000)
for p in [7,11,13,19,23,29,31,37,41]:
    r=nroots_cubic(p,(-c)%p)
    if r==0: continue
    vals=np.array([(int(d*int(a))+int(b))**3+c for a,b in zip(xs,ys)],dtype=object)
    obs=np.mean([v%p==0 for v in vals])
    exp=r/p
    se=math.sqrt(max(exp*(1-exp),1e-12)/len(vals))
    z=(obs-exp)/se if se>0 else 0
    print(f"   p={p:<3} observed={obs:.4f}  r_p/p={exp:.4f}  z={z:+.2f}  {'OK' if abs(z)<3 else '*** OFF ***'}")

print()
print("="*72)
print("PART 3 -- HEADROOM: is there any (B,Y) where exact Psi beats the sieve model?")
print("="*72)
print("  Model claim: FB-smooth yield ~ Psi(V,B)/V.  Extra divisibility by p in the")
print("  FB is ALREADY inside Psi, because Psi(V,B) counts n with P+(n)<=B, i.e. n")
print("  divisible ONLY by primes <= B.  The p|a,p|b excess changes WHICH cells are")
print("  sieved out, not HOW MANY survive.  Test: does the measured yield match Psi?")
for BB in [200,500,1000,2000]:
    V=10**8
    pred=psi_exact(V,BB)/V
    print(f"   B={BB:<6} exact Psi(V,B)/V at V=1e8 = {pred:.6e}")
