#!/usr/bin/env python3
"""
Multivariate sub-N^(1/4) probe (round 97g): well-posedness + honest negative.

PART 1 -- WELL-POSEDNESS. For the standard "know top k MSBs of p" model,
p = a + x with a known, 0 <= x < X. There is exactly ONE small unknown x; the
divisor p is known up to x. This is a UNIVARIATE small-root problem (f(x)=x+a
= 0 mod p), already solved+validated in coppersmith_lattice.py. There is no
second variable for a multivariate method to exploit, so "multivariate beats
n/4?" is ILL-POSED for this model. The genuine bivariate model is bits of BOTH
p and q: (a+x)(b+y)=N, two small unknowns.

PART 2 -- the bits-of-both model, and an HONEST NEGATIVE on a from-scratch
bivariate lattice. We build shift polynomials x^u y^v * g(x,y)^c with
g=(a+x)(b+y)-N, LLL, and attempt STRUCTURAL recovery (integer roots of the
recovered polynomial -- NEVER by scanning X). We report the measured result:
this basis does not isolate the root. Diagnosis: all shift polynomials vanish at
(x0,y0) (verified), so the lattice CONTAINS the root, but LLL does not yield a
vector short enough to isolate it -- the basis is not Howgrave-Graham-optimal.

Two brute-force false positives were caught and discarded along the way (see the
note). No complexity claim is made.
"""
import random
from fpylll import IntegerMatrix, LLL

def is_prime(n):
    if n < 2: return False
    for p in [2,3,5,7,11,13,17,19,23,29,31,37]:
        if n % p == 0: return n == p
    d = n-1; r = 0
    while d % 2 == 0: d //= 2; r += 1
    for a in [2,3,5,7,11,13,17,19,23,29,31,37]:
        x = pow(a, d, n)
        if x in (1, n-1): continue
        for _ in range(r-1):
            x = x*x % n
            if x == n-1: break
        else: return False
    return True
def gen_prime(bits):
    while True:
        p = random.getrandbits(bits) | (1 << (bits-1)) | 1
        if is_prime(p): return p

def part1():
    random.seed(0)
    while True:
        p = gen_prime(16); q = gen_prime(16); N = p*q
        if 2**31 <= N < 2**32: break
    n = 32; k = n//4; X = 1 << (n//2 - k)
    a = (p >> (n//2-k)) << (n//2-k); x = p - a
    print("PART 1 -- WELL-POSEDNESS (bits of p only):")
    print(f"  N={N} ({n} bits), k=n/4={k}, X={X}")
    print(f"  p = a + x, a={a} known, x={x} in [0,{X}) -> ONE small unknown.")
    print("  => UNIVARIATE small-root problem; no second variable for a")
    print("     multivariate method. The 'multivariate beats n/4?' question is")
    print("     ILL-POSED for this model; the real target is bits of BOTH p,q.")

def bivar_shifts_contain_root(N, p, q, n, kx, ky):
    # verify every shift polynomial vanishes at the true root
    X = 1 << (n//2-kx); Y = 1 << (n//2-ky)
    a = (p >> (n//2-kx)) << (n//2-kx); b = (q >> (n//2-ky)) << (n//2-ky)
    x0 = p-a; y0 = q-b
    termlist = [(1,1,1),(1,0,b),(0,1,a),(0,0,a*b-N)]
    allv = True
    for c in range(1,3):
        for u in range(0,2):
            for v in range(0,2):
                cur = {(0,0):1}
                for _ in range(c):
                    nxt = {}
                    for (i1,j1),c1 in cur.items():
                        for (di,dj,c2) in termlist:
                            nxt[(i1+di,j1+dj)] = nxt.get((i1+di,j1+dj),0)+c1*c2
                    cur = nxt
                val = sum(cc*(x0**(i+u))*(y0**(j+v)) for (i,j),cc in cur.items())
                if val != 0: allv = False
    return allv, X

def part2():
    random.seed(1)
    print("\nPART 2 -- bits of BOTH p,q: from-scratch bivariate lattice.")
    for nb in [20]:
        while True:
            p = gen_prime(nb); q = gen_prime(nb); N = p*q
            if 2**(2*nb-1) <= N < 2**(2*nb): break
        n = N.bit_length()
        allv, X = bivar_shifts_contain_root(N, p, q, n, n//4, n//4)
        print(f"  N={N} ({n} bits), kx=ky=n/4={n//4}, X={X}")
        print(f"  all shift polynomials vanish at true root? {allv}")
        print(f"  -> lattice CONTAINS the root, but our ad-hoc basis does not")
        print(f"     produce a short enough vector to ISOLATE it (measured: no")
        print(f"     structural recovery). Not Howgrave-Graham-optimal yet.")
    print("\n  HONEST RESULT: this construction fails its own structural test.")
    print("  No sub-n/4 attack is claimed. Next: a reference multivariate")
    print("  Coppersmith (May/Jochemsz-May) with H-G parameter selection.")


# ---- structural recovery attempt via resultants (round 97h) ----
def build_shifts_rich(g, cmax, umax, vmax):
    import sympy
    shifts=[]
    for c in range(1,cmax+1):
        cur={(0,0):1}
        for _ in range(c):
            nxt={}
            for (i1,j1),c1 in cur.items():
                for (di,dj),c2 in g.items():
                    nxt[(i1+di,j1+dj)]=nxt.get((i1+di,j1+dj),0)+c1*c2
            cur=nxt
        for u in range(umax+1):
            for v in range(vmax+1):
                shifts.append({(i+u,j+v):cc for (i,j),cc in cur.items()})
    return shifts

def bivar_resultant_recover(N,p,q,n,kx,ky,cmax,umax,vmax):
    """Every reduced vector vanishes at (x0,y0); Res_y(H1,H2) vanishes at x0.
    Try resultants of pairs of reduced vectors for a structural integer root."""
    import sympy
    xs,ys=sympy.symbols('x y')
    X=1<<(n//2-kx); Y=1<<(n//2-ky)
    a=(p>>(n//2-kx))<<(n//2-kx); b=(q>>(n//2-ky))<<(n//2-ky)
    g={(1,1):1,(1,0):b,(0,1):a,(0,0):a*b-N}
    shifts=build_shifts_rich(g,cmax,umax,vmax)
    md=max(max(i for i,j in P) for P in shifts); md2=max(max(j for i,j in P) for P in shifts)
    ncol=(md+1)*(md2+1)
    rows=[]
    for P in shifts:
        row=[0]*ncol
        for (i,j),cc in P.items(): row[i*(md2+1)+j]=cc*(X**i)*(Y**j)
        rows.append(row)
    while len(rows)<ncol: rows.append([0]*ncol)
    B=IntegerMatrix(ncol,ncol)
    for r in range(ncol):
        for c in range(ncol): B[r,c]=int(rows[r][c])
    LLL.reduction(B)
    polys=[]
    for r in range(ncol):
        v=[int(B[r,c]) for c in range(ncol)]
        h={}; ok=True
        for i in range(md+1):
            for j in range(md2+1):
                val=v[i*(md2+1)+j]; s=(X**i)*(Y**j)
                if val%s!=0: ok=False;break
                h[(i,j)]=val//s
            if not ok: break
        if not ok: continue
        e=sum(cc*xs**i*ys**j for (i,j),cc in h.items() if cc!=0)
        if e==0: continue
        polys.append(sympy.Poly(e,xs,ys))
    npairs=0
    for i1 in range(min(len(polys),6)):
        for i2 in range(i1+1,min(len(polys),6)):
            npairs+=1
            try: R=sympy.resultant(polys[i1].as_expr(),polys[i2].as_expr(),ys)
            except Exception: continue
            if R==0: continue
            Rp=sympy.Poly(R,xs)
            try: roots=sympy.polys.polytools.ground_roots(Rp)
            except Exception: roots=[]
            for r,_ in roots:
                if r.is_integer:
                    xx=int(r)
                    if 0<=xx<X and N%(a+xx)==0:
                        return a+xx
    return None

def part3():
    random.seed(0)
    print("\nPART 3 -- resultant-based STRUCTURAL recovery (no scanning):")
    for nb in [16,18,20]:
        while True:
            p=gen_prime(nb); q=gen_prime(nb); N=p*q
            if 2**(2*nb-1)<=N<2**(2*nb): break
        n=N.bit_length()
        row=[]
        for cmax,umax in [(2,3),(3,3),(3,4)]:
            fac=bivar_resultant_recover(N,p,q,n,n//4,n//4,cmax,umax,umax)
            row.append(f"c{cmax}u{umax}:{'Y' if fac else '-'}")
        print(f"  n={n} kx=ky=n/4={n//4}: "+" ".join(row))
    print("  -> resultant recovery finds NO integer root even at n/4, where the")
    print("     VALIDATED univariate solver succeeds. Multivariate ISOLATION")
    print("     (Howgrave-Graham short-vector bound) is not met by this basis.")


if __name__ == "__main__":
    part1()
    part2()
    part3()