#!/usr/bin/env python3
"""
IFP HINT-based lattice attack (round 109b) -- HONEST NEGATIVE RESULT.

WHAT WAS ATTEMPTED. The published subtle IFP bound (t ~ 2*alpha, Nuida-Itakura-
Kurosawa ePrint 2014/839; Feng-Nitaj-Pan ePrint 2023/1562) uses a 2-modulus lattice
(May-Ritzenhofen PKC'09) to factor N1 from a HINT z = p1 - p2 (not the exact
shared low part). Round 109 verified the CRISP corollary (exact shared part, poly
time). This script ATTEMPTED to derive the hint reduction myself and REPLICATED
it with the validated Coppersmith lattice (r97f).

THE ATTEMPT WAS WRONG (recorded deliberately). The first derivation claimed:
"hint z' == a (mod 2^v) => q1 = q10 + 2^v * j; since p1=N1/q1 | N1, f(j) =
q10 + 2^v*j == 0 (mod p1), a small-root problem." This is FALSE: at j = j_true,
f(j_true) = q1, which is NOT 0 and NOT a multiple of p1 (gcd(q1,p1)=1). So f has
no root modulo p1, and the Coppersmith lattice correctly finds nothing. The
empirical run confirms it: only the trivial v=alpha case (X=2^0, j=0) recovers;
every non-trivial v returns 0/4. The data caught the bad derivation -- exactly the
round-104 guard.

THE CORRECT reduction is a genuine 2-modulus lattice coupling q1 and q2 through
the hint z=p1-p2 (N1*q2 - N2*q1 = z*q1*q2), which is NOT a univariate small-root
problem and must be taken from May-Ritzenhofen 2009 rather than invented. Not
re-derived here.

CONCLUSION. The r109 polynomial-time IFP corollary (exact shared part) STANDS and
is verified. The subtler hint-based 2-modulus lattice bound is left OPEN (needs
the exact published construction); this script is a record of the failed
re-derivation, not a claimed result.
"""
import math, random
from math import gcd
from fpylll import IntegerMatrix, LLL

def is_prime(n):
    if n<2: return False
    for d in [2,3,5,7,11,13,17,19,23,29,31,37]:
        if n%d==0: return n==d
    dd=n-1;r=0
    while dd%2==0: dd//=2;r+=1
    for a in [2,3,5,7,11,13,17,19,23,29,31,37]:
        x=pow(a,dd,n)
        if x in (1,n-1): continue
        for _ in range(r-1):
            x=x*x%n
            if x==n-1: break
        else: return False
    return True
def gp(b):
    while True:
        p=random.getrandbits(b)|(1<<(b-1))|1
        if is_prime(p): return p

def coppersmith_linear(f0, f1, N, X, mmax=12, tmax=12):
    """Recover small root j of f(j)=f0+f1*j = 0 mod unknown divisor >= N^beta,
    |j|<X, via exact-integer small-root lattice (r97f style).
    f0,f1 are integers (the linear polynomial)."""
    f=[f0%N, f1%N]
    def polymul(u,v):
        r=[0]*(len(u)+len(v)-1)
        for a,ua in enumerate(u):
            if ua==0: continue
            for b,vb in enumerate(v): r[a+b]+=ua*vb
        return r
    best=None
    for m in range(2,mmax+1):
        for t in range(2,tmax+1):
            fpow=[[1]]
            for i in range(m+1): fpow.append(polymul(fpow[-1],f))
            Npow=[1]
            for i in range(m+1): Npow.append(Npow[-1]*N)
            rows=[]
            for i in range(m+1):
                w=Npow[m-i] if i<m else 1
                for jj in range(t):
                    g=[0]*jj+[(c*w)%N for c in fpow[i]]
                    rows.append([c*(X**k) for k,c in enumerate(g)])
            md=max(len(r) for r in rows); dim=len(rows)
            B=IntegerMatrix(dim,md)
            for r in range(dim):
                for c in range(md): B[r,c]=int(rows[r][c] if c<len(rows[r]) else 0)
            LLL.reduction(B)
            for r in range(dim):
                v=[int(B[r,c]) for c in range(md)]
                h=[];ok=True
                for k,vk in enumerate(v):
                    xk=X**k
                    if vk%xk!=0: ok=False;break
                    h.append(vk//xk)
                if not ok: continue
                while h and h[-1]==0: h.pop()
                if len(h)<=1: continue
                # find a root j with |j|<X by scanning (X is small here)
                found=None
                if X<=2000000:
                    for jcand in range(-int(X), int(X)):
                        val=0
                        for c in reversed(h): val=val*jcand+c
                        if val==0:
                            found=jcand; break
                else:
                    if len(h)==2 and h[1]!=0 and (-h[0])%h[1]==0:
                        jcand=(-h[0])//h[1]
                        if abs(jcand)<X: found=jcand
                if found is not None:
                    best=found
                    return best
    return best

def main():
    random.seed(0)
    print("IFP HINT attack: partial hint + Coppersmith lattice recovers p1.")
    print("f(j)=q10 + 2^v*j =0 mod p1; Coppersmith root < N^(1/4) => recover j.\n")
    # setup: p1 (alpha-ish bits) with low a bits shared to p2; hint z'=a mod 2^v
    alpha=24   # bits of q1
    for (alpha_p1, v) in [(40,20),(40,16),(48,20),(48,16),(56,24)]:
        if v > alpha: continue
        ok=0; tot=4
        for _ in range(tot):
            # build p1 as a prime of alpha_p1 bits
            p1=gp(alpha_p1)
            q1=gp(alpha)
            N1=p1*q1
            # shared low part a of p1 (the low v bits); hint z' = a mod 2^v
            a=p1 % (1<<v)
            # require a odd (so q1 invertible mod 2^v)
            if a%2==0: continue
            q10=(N1*pow(a,-1,1<<v))%(1<<v)
            X=1<<(alpha-v)   # j < 2^(alpha-v)
            # f(j) = q10 + 2^v * j
            j_true=(q1-q10)//(1<<v)
            if (q1-q10)%(1<<v)!=0: continue
            # run Coppersmith; check it finds a j giving a real factor
            j=coppersmith_linear(q10, 1<<v, N1, X, mmax=6,tmax=6)
            if j is not None:
                q_rec=q10+(1<<v)*j
                if q_rec>1 and N1%q_rec==0:
                    ok+=1
        n1 = alpha_p1+alpha
        cond = (alpha - v) < n1/4
        print(f"  p1_bits={alpha_p1} alpha={alpha} v={v}: X=2^{alpha-v} "
              f"coppersmith(cond {alpha-v}<n/4={n1//4})={cond} recovered {ok}/{tot}")

if __name__=="__main__":
    main()
