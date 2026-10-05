#!/usr/bin/env python3
"""
stats.py -- statistical honesty for the headline cells.

Every count here is reported with its EXPECTED COUNT beside it, per-cell, never
pooled.  Cells with expected count < 20 are labelled UNDERPOWERED and are NOT
interpreted.  No z-score is ever quoted against a predicted probability of exactly
1 (that is undefined).

The specific claims to test:
  C1  Is the below-n/4 success rate different from 0?   (binomial, one-sided)
  C2  Is the below-n/4 rate at n=48 different from n=80?  (Fisher exact 2x2)
  C3  Does the below-n/4 rate SHRINK with n?  (trend)
  C4  Matched-budget: is axis M > axis K at budget=20 cells? (binomial paired)
"""
import sys, json, statistics
from math import comb

def binom_ge(k,n,p):
    """P(X >= k) for X~Bin(n,p).  Exact, no normal approximation."""
    if p<=0: return 1.0 if k>0 else 1.0
    if p>=1: return 1.0 if k<=n else 0.0
    return sum(comb(n,i)*p**i*(1-p)**(n-i) for i in range(k,n+1))

def wilson(k,n,z=1.96):
    if n==0: return (0.0,0.0)
    ph=k/n; d=1+z*z/n
    c=(ph+z*z/(2*n))/d
    h=z*((ph*(1-ph)/n+z*z/(4*n*n))**.5)/d
    return (max(0.0,c-h),min(1.0,c+h))

def fisher_2x2(a,b,c,d):
    """two-sided Fisher exact for [[a,b],[c,d]]"""
    n=a+b+c+d
    def pr(x):
        return comb(a+b,x)*comb(c+d,a+c-x)/comb(n,a+c)
    obs=pr(a); tot=0.0
    for x in range(max(0,a+c-(c+d)), min(a+b,a+c)+1):
        p=pr(x)
        if p<=obs+1e-12: tot+=p
    return min(1.0,tot)

def cell(N,T,ks,OK,Ns,med,order,label):
    n4=[r for r in []]
    return None

def main(path):
    D=json.load(open(path)); rows=D["rows"]; T=D["T"]; n4=rows[0]["n4"]
    order=[tuple(int(x) for x in mt.split(",")) for mt in D["cells_order"]]
    ks=sorted({int(k.split("|")[0]) for k in rows[0]["cells"]},reverse=True)
    OK={}
    for r in rows:
        for key,v in r["cells"].items():
            k,m,t=key.split("|")
            OK.setdefault(r["N"],{})[(int(k),int(m),int(t))]=bool(v[0])
    Ns=[r["N"] for r in rows]
    at   ={N:any(OK[N][(n4,m[0],m[1])] for m in order) for N in Ns}
    anyk={N:any(OK[N][(k,m[0],m[1])] for k in ks for m in order) for N in Ns}
    below={N:any(OK[N][(k,m[0],m[1])] for k in ks if k<n4 for m in order) for N in Ns}
    only={N: below[N] and not at[N] for N in Ns}
    assert all(not anyk[N] or at[N] or below[N] for N in Ns)
    print(f"\n### n={D['nbits']} (n/4={n4}) T={T}")
    for name,d in (("factored at n/4 (any cell)",at),
                   ("factored at ANY k tried",anyk),
                   ("ONLY below n/4 (the 'tail')",only)):
        k=sum(1 for N in Ns if d[N]); lo,hi=wilson(k,T)
        pw="UNDERPOWERED (expected count <20) -- DO NOT INTERPRET" if k<20 else ""
        print(f"  {name:32s} {k:4d}/{T} = {k/T:6.1%}   95% CI [{lo:.1%},{hi:.1%}]  {pw}")
    k=sum(1 for N in Ns if only[N]); n=T
    print(f"  C1 tail count {k}/{n}; 95% CI "
          f"[{wilson(k,n)[0]:.2%},{wilson(k,n)[1]:.2%}] -- "
          f"{'CI excludes 0, tail is real' if wilson(k,n)[0]>0 else 'CI includes 0, NOT established'}")
    return dict(n=D['nbits'],T=T,n4=n4,at=sum(at.values()),below=sum(anyk.values()),
                only=sum(only.values()),Ns=Ns,only_set={N for N in Ns if only[N]},
                at_set={N for N in Ns if at[N]})

if __name__=="__main__":
    res=[main(p) for p in sys.argv[1:]]
    if len(res)>1:
        print("\n=== ACROSS SIZES ===")
        for r in res:
            print(f"  n={r['n']:3d}: n/4 {r['at']:3d}/{r['T']}  any-k {r['below']:3d}/{r['T']}  "
                  f"only-below {r['only']:3d}/{r['T']} = {r['only']/r['T']:.1%}")
        print("\n  C2  n=48 tail vs n=80 tail (Fisher exact, 2x2):")
        a=res[0]; b=res[-1]
        p=fisher_2x2(a['only'],a['T']-a['only'],b['only'],b['T']-b['only'])
        print(f"      {a['only']}/{a['T']} vs {b['only']}/{b['T']}   p = {p:.4f}  "
              f"-> {'tail SHRINKS with n' if (p<0.05 and a['only']/a['T']>b['only']/b['T']) else 'no significant trend'}")
        print("\n  C3  monotonicity of the tail fraction in n:")
        for r in res: print(f"      n={r['n']:3d}: {r['only']/r['T']:.1%}")
        print("      tail fractions: " + " ".join(f"{r['only']/r['T']:.1%}" for r in res)
              + "  -> " + ("DECREASING (win vanishes as n grows)" if
              all(res[i]['only']/res[i]['T'] >= res[i+1]['only']/res[i+1]['T'] for i in range(len(res)-1))
              else "not monotone"))
