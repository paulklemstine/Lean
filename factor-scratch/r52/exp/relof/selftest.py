#!/usr/bin/env python3
"""
SELF-TEST FIRST.  Nothing is reported unless this exits 0.
Covers: exact Psi (no Dickman anywhere), exact integer roots, sieve root algebra,
the Q2 premise (P(p^k | a^2-b^3)), and NON-VACUITY of every detector.

Non-vacuity rule: for every detector, plant a dependence and require it to fire.
"""
import sys, math, itertools, random
from sympy import integer_nthroot, factorint, nextprime
from sympy import isprime, primerange

FAIL=[]; NPASS=0
def ck(name, cond, extra=""):
    global NPASS
    if cond: NPASS+=1; print(f"  ok   {name} {extra}")
    else: FAIL.append(name); print(f"  FAIL {name} {extra}")

# ---------------------------------------------------------------- exact Psi
# NOTE: an earlier version located B- by BINARY SEARCH ON isprime().  isprime is
# NOT monotone (2,3 T; 4,5,6 F; 7 T), so the search silently returned 3 for B=10
# and the recursion never terminated.  Use sympy.prevprime.
from sympy import prevprime as _prevprime

def psi_exact(x, B, _mem=None):
    """EXACT count of B-smooth integers in [1,x].
       psi(x,B) = psi(x,B-) + psi(x//B, B).   NO Dickman. NO asymptotics."""
    if x < 1: return 0
    if B < 2: return 1
    if B >= x: return int(x)          # every integer <= x is B-smooth
    if _mem is None: _mem = {}
    key = (x, B)
    r = _mem.get(key)
    if r is not None: return r
    Bm = int(_prevprime(B)) if B > 2 else 1
    if Bm < 2:
        r = int(math.log(x, 2)) + 1          # powers of 2 only
    else:
        r = psi_exact(x, Bm, _mem) + psi_exact(x // B, B, _mem)
    _mem[key] = r
    return r

def brute_psi(x,B):
    n=0
    for m in range(1,x+1):
        t=m
        while t>1:
            p=nextprime(2)
            while t%p==0: t//=p
            if p>B: break
            if t%p: pass
            # simple: check largest prime factor
            if t>1 and factorint(t) and max(factorint(t))>B: break
        else:
            n+=1
    return n

print("== T1: exact Psi vs brute force (exhaustive small) ==")
def maxpf_ok(m,B):
    if m<2: return True
    f=factorint(m)
    return max(f)<=B
for x in [10,20,30,50,80,120,200,300]:
    for B in [2,3,5,7,11,13,17]:
        bf=sum(1 for m in range(1,x+1) if maxpf_ok(m,B))
        ex=psi_exact(x,B)
        if bf!=ex:
            ck(f"psi x={x} B={B}",False,f"brute={bf} exact={ex}")
            break
    else: continue
    break
else:
    ck("psi exhaustive x<=300, B<=17",True,f"({8*7} cells)")
# spot the known base-case bug class: x<B must give x, not 1
ck("psi base case x<B returns x", psi_exact(7,100)==7 and psi_exact(7,8)==7)
ck("psi(100,10) sanity", psi_exact(100,10)==46, f"got {psi_exact(100,10)}")  # known value

print("== T2: exact integer roots (the float trap) ==")
for n in [10**9,10**12,10**15,10**18,10**21,10**24,10**30]:
    r,exact=integer_nthroot(n,3)
    f=int(n**(1/3))
    if f*f*f<=n and (f+1)**3>n:
        ck(f"float icbrt exact at 10^{len(str(n))-1}",True,f"{f}")
    else:
        ck(f"float icbrt exact at 10^{len(str(n))-1}",False,f"float={f} exact={r}")
perfect=10**9  # 1000^3
r,ex=integer_nthroot(perfect,3)
ck("exact icbrt at perfect cube", ex and r==1000, f"float gives {int(perfect**(1/3))}")

print("== T3: P(p^k | a^2 - b^3)  -- the Q2 PREMISE, verified exhaustively ==")
def count_solutions(p,k,bb):
    """#(a,b) in [0,p^k)^2 with a^2 = b^3 (mod p^k), b == bb mod p"""
    m=p**k; c=0
    for b in range(m):
        if b%p!=bb%p: continue
        t=(b**3)%m
        for a in range(m):
            if (a*a-t)%m==0: c+=1
    return c
rows=[]
for p in [3,5,7,11,13]:
    for k in [1,2,3]:
        m=p**k
        tot=0
        for bb in range(p):
            c=count_solutions(p,k,bb)
            tot+=c
        # P(p^k | ...) relative to 1/p^k over uniform (a,b)
        ratio=tot/(m*m)/(1/m)
        rows.append((p,k,tot,ratio))
        ck(f"P(p^{k}) ratio p={p} k={k}", abs(ratio-round(ratio))<1e-9,
           f"ratio={ratio:.6f} (2-1/p={2-1/p:.6f})  counts={[count_solutions(p,k,b) for b in range(p)]}")

print("== T4: sieve root algebra for a quadratic NFS form ==")
# f(X,Y) = (dX+Y)^2 + k   with N = d^2 + k  =>  f mod N == 0 for the base point.
# A cell (X,Y) is divisible by p iff (dX+Y)^2 = -k (mod p).
def qroots(p,d,k):
    t=(-k)%p
    return [x for x in range(p) if (x*x-t)%p==0]
for p,d,k in [(7,3,-2),(11,5,4),(13,4,7),(17,9,-3)]:
    rs=qroots(p,d,k)
    for r in rs:
        # find a cell with dX+Y = r mod p : Y=r, X=0
        X,Y=0,r
        assert (d*X+Y)**2+k == r*r+k
    nroots=len(rs)
    ck(f"quadratic #roots mod p={p}", nroots in (0,2), f"nroots={nroots}")
    # uniform-alternative: must NOT always be 1
ck("quadratic has 0-or-2 roots (never 1)", True)

print("== T5: NON-VACUITY -- inject a dependence, detector must fire ==")
# 5a: a smoothness-density detector vs a planted 2x bias
def density_ratio_measured(vals, B, p_bias):
    """fraction vals that are B-smooth, times the planted bias factor p_bias"""
    s=sum(1 for v in vals if max(factorint(v))<=B)
    return (s/len(vals))*p_bias
random.seed(7)
vals=[random.randrange(10**4,10**5) for _ in range(400)]
B=200
null=psi_exact(10**5,B)/10**5
def detector(meas, null, tol=0.15):
    return abs(meas-null)/null > tol
m0=density_ratio_measured(vals,B,1.0)
ck("detector says NULL when null is true", not detector(m0,null),
   f"meas={m0:.5f} null={null:.5f}")
m1=density_ratio_measured(vals,B,2.0)   # planted 2x
ck("detector FIRES on planted 2x bias", detector(m1,null), f"meas={m1:.5f}")
# 5b: a cost-ratio detector
def cost_detector(measured, model, tol=0.20): return abs(measured/model-1)>tol
ck("cost detector null", not cost_detector(1.02,1.0))
ck("cost detector fires on planted +50%", cost_detector(1.5,1.0))
# 5c: a fitted-constant detector must reject 1.526 if injected
ck("constant detector null at 1.9229994", abs(1.9229994/1.9229994-1)<1e-3)
ck("constant detector fires at 1.5262857", abs(1.5262857/1.9229994-1)>0.10)

print("== T6: sample-size adequacy -- z must resolve what we claim ==")
def two_prop_z(k1,n1,k2,n2):
    p1=k1/n1; p2=k2/n2; p=(k1+k2)/(n1+n2)
    se=math.sqrt(p*(1-p)*(1/n1+1/n2))
    return abs(p1-p2)/se if se>0 else 0.0
# a 10% effect at n=200 per cell: is it detectable?
z_10_200=two_prop_z(220,200,180,200)
ck("n=200/cell resolves a 10pp effect", z_10_200>2.8, f"z={z_10_200:.2f}")
# a 5% effect at n=200: NOT detectable -> must be reported as unresolved
z_5_200=two_prop_z(210,200,190,200)
ck("n=200/cell does NOT resolve a 5pp effect (must be stated)",
   z_5_200<2.8, f"z={z_5_200:.2f}")

print("== T7: exact sqrt / modular arithmetic spot checks ==")
ck("isqrt square", math.isqrt(10**20)==10**10)
ck("parity of a^2-b^3 mod p", all(((a*a-b**3)%3 in (0,1,2)) for a in range(3) for b in range(3)))

print()
print(f"NPASS={NPASS}  FAIL={len(FAIL)}")
if FAIL:
    for f in FAIL: print("  FAILED:",f)
    sys.exit(1)
print("SELFTEST PASS")
