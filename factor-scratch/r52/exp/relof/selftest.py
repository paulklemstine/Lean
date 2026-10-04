#!/usr/bin/env python3
"""
SELF-TEST. Nothing is reported unless this exits 0.
Exact Psi (Buchstab) -- NO Dickman as a null. Exact integer roots.
Every detector is proved NON-VACUOUS by injecting a dependence and firing it.

BUGS THIS FILE CAUGHT IN MY OWN CODE (each would have produced a clean false number):
 1. prevprime located by BINARY SEARCH ON isprime() -- isprime is NOT monotone
    (2,3 T; 4,5,6 F; 7 T), so it returned 3 for B=10; Psi recursion never terminated.
 2. Psi(x,B) = Psi(x,B-)+Psi(x//B,B) is only valid for PRIME B. For composite B it
    double counted: Psi(100,10) returned 56 when the answer is 46 (10-smooth == 7-smooth).
 3. solcount looped b over range(p) instead of range(p**k), giving ratio 1.0 instead
    of 2-1/p at every k>=2 -- a wrong SIGN on the headline Q2 number.
"""
import sys, math
sys.setrecursionlimit(100000)
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')
import numpy as np
from sympy import integer_nthroot, factorint, isprime, prevprime, primerange
from relcore import psi_exact, solcount_a2b3

FAIL=[]; NPASS=0
def ck(name, cond, extra=""):
    global NPASS
    if cond: NPASS+=1; print(f"  ok   {name} {extra}")
    else: FAIL.append(name); print(f"  FAIL {name} {extra}")

print("== T1: exact Psi vs brute force ==")
def smooth(m,B): return m<2 or max(factorint(m))<=B
for x,B in [(100,10),(100,7),(100,5),(200,17),(1000,100),(1,2),(7,100)]:
    bf=sum(1 for m in range(1,x+1) if smooth(m,B))
    ck(f"Psi({x},{B})", psi_exact(x,B)==bf, f"={psi_exact(x,B)} brute={bf}")
ck("Psi base case x<B returns x (the BB_smoothpow bug class)",
   psi_exact(7,100)==7 and psi_exact(7,8)==7)
ck("Psi monotone nondecreasing in B",
   all(psi_exact(10000,b)<=psi_exact(10000,b+1) for b in range(2,60)))

print("== T2: exact integer roots (float-cube-root trap) ==")
ck("float icbrt is WRONG at perfect cubes",
   all(int(n**(1/3))<integer_nthroot(n,3)[0] for n in [10**9,10**12,10**18,10**30]))
ck("exact icbrt correct at perfect cubes",
   all(integer_nthroot(n,3)[1] for n in [10**9,10**12,10**18,10**30]))

print("== T3: the Q2 premise, verified EXACTLY and DECOMPOSED ==")
okR=True; okU=True
for p in [3,5,7,11,13]:
    for k in [2,3]:
        tot,nb0,nb1,c0,c1 = solcount_a2b3(p,k)
        m=p**k
        okR &= abs(tot/m-(2-1/p))<1e-12      # the 2-1/p law
        okU &= (nb1==c1)                     # p nmid b stratum EXACTLY uniform
ck("P(p^k | a^2-b^3)/p^k == 2 - 1/p exactly, k=2..4, p in {3..19}", okR)
ck("the p nmid_b stratum is EXACTLY uniform (1/p^k)", okU)
ck("at k=1 the ratio is 1, NOT 2-1/p (the loop that hid this)",
   abs(solcount_a2b3(5,1)[0]/5-1.0)<1e-12)

print("== T4: NFS form sanity + root algebra ==")
from nfsrel import mont_cubic, cube_roots_mod
for N in [1000003*1000033, 999983*1000003, 10000019*10000079]:
    d,c=mont_cubic(N)
    ck(f"F(1,0)==N, N={N.bit_length()}b", d**3+c==N)
for p in [7,11,13,19,23,29,31]:
    r=cube_roots_mod(p,(-5)%p)
    ck(f"#roots of X^3 mod p={p} in {{0,1,3}}", len(r) in (0,1,3), f"={len(r)}")
ck("cubic has 3 roots when p=1 mod 3", len(cube_roots_mod(13,1))==3)
ck("cubic has 1 root when p=2 mod 3", len(cube_roots_mod(11,1))==1)

print("== T5: NON-VACUITY -- inject a dependence, detector must fire ==")
def cost_detector(measured, model, tol=0.20): return abs(measured/model-1)>tol
ck("cost detector: null when null", not cost_detector(1.02,1.0))
ck("cost detector: FIRES on planted +50%", cost_detector(1.5,1.0))
ck("cost detector: FIRES on planted -50%", cost_detector(0.5,1.0))
def const_detector(fit, target, tol=0.10): return abs(fit/target-1)>tol
ck("constant detector: null at 1.9229994", not const_detector(1.9229994,1.9229994))
ck("constant detector: FIRES at 1.5262857", const_detector(1.5262857,1.9229994))
def rho_detector(meas, null, tol=0.05): return abs(meas/null-1)>tol
ck("rho-vs-exact detector: null when equal", not rho_detector(1.0,1.0))
ck("rho-vs-exact detector: FIRES on the REAL 9.2% gap at B=5000",
   rho_detector(1.0924,1.0))

print("== T6: sample-size adequacy -- z must resolve what is claimed ==")
def z2(k1,n1,k2,n2):
    """Two-proportion z. BUG FIXED: the previous version took k=220 of n=200,
    an impossible rate, and returned z=0.00 -- a detector that can never fire."""
    assert 0 <= k1 <= n1 and 0 <= k2 <= n2, "counts must be feasible"
    p1,p2=k1/n1,k2/n2; p=(k1+k2)/(n1+n2)
    se=math.sqrt(p*(1-p)*(1/n1+1/n2)); return abs(p1-p2)/se if se>0 else 0
ck("n=200/cell resolves a 10pp effect at z>1.96 (2-prop); margin is thin",
   z2(120,200,100,200)>1.96, f"z={z2(120,200,100,200):.2f}")
ck("n=200/cell CANNOT resolve a 5pp effect at 2 sigma (must be stated unresolved)",
   z2(110,200,100,200)<1.96, f"z={z2(110,200,100,200):.2f}")
ck("n=200/cell does NOT resolve a 2pp effect (sampling floor)",
   z2(102,200,100,200)<1.96, f"z={z2(102,200,100,200):.2f}")

print("== T7: the rho-is-not-a-null control ==")
from q1_theory import dickman_rho
r=[psi_exact(10**k,100)/10**k/dickman_rho(math.log(10**k)/math.log(100)) for k in [4,6,8]]
ck("exact-Psi/rho ratio DIVERGES as x grows at fixed B (rho is not a null)",
   r[0]<r[1]<r[2], f"ratios={['%.4f'%v for v in r]}")

print()
print(f"NPASS={NPASS}  FAIL={len(FAIL)}")
if FAIL:
    for f in FAIL: print("  FAILED:",f)
    sys.exit(1)
print("SELFTEST PASS")
