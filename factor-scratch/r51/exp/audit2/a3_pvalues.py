#!/usr/bin/env python3
"""Do the paper's Fisher p-values reproduce from the paper's OWN counts?"""
from math import comb
from fractions import Fraction
from scipy.stats import fisher_exact

def f2(k1,n1,k2,n2,side="two"):
    S=k1+k2; tot=n1+n2
    def h(k):
        if k<0 or k>n1 or S-k>tot-n1: return Fraction(0)
        return Fraction(comb(S,k)*comb(tot-S,n1-k), comb(tot,n1))
    lo=max(0,S-(tot-n1)); hi=min(S,n1); obs=h(k1)
    if side=="two": return float(min(Fraction(1),sum(h(k) for k in range(lo,hi+1) if h(k)<=obs)))
    return float(sum(h(k) for k in range(0,k1+1) if h(k)<=obs))

print("u   counts                     two-sided   one-sided   paper p")
for u,a,b,c,d,pp in [(2.0,64,267,1224,4000,0.0000),(2.5,22,267,564,4000,0.0028),
                     (1.5,135,267,2404,4000,0.0000),(3.0,7,267,212,4000,1.0000)]:
    t=f2(a,b,c,d); o=f2(a,b,c,d,"one")
    print(f"{u:>3} {a:>4}/{b} vs {c:>5}/{d}   {t:.5f}      {o:.5f}     {pp}")
