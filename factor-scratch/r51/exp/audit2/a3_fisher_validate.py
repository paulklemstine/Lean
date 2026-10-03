#!/usr/bin/env python3
"""Validate my Fisher + ratio-CI against scipy BEFORE trusting any verdict.
Lesson from round 48: a harness that only shows you it runs is not a harness."""
import numpy as np
from math import comb, sqrt, log
from fractions import Fraction
from scipy.stats import fisher_exact

def fisher_mine(k1,n1,k2,n2):
    tot=n1+n2; S=k1+k2
    def h(k):
        if k<0 or k>n1 or S-k>tot-n1: return Fraction(0)
        return Fraction(comb(S,k)*comb(tot-S,n1-k), comb(tot,n1))
    lo=max(0,S-(tot-n1)); hi=min(S,n1)
    obs=h(k1)
    return float(min(Fraction(1),sum(h(k) for k in range(lo,hi+1) if h(k)<=obs)))

def ratio_ci_katz(k1,n1,k2,n2):
    p1,p2=k1/n1,k2/n2; r=p1/p2
    se=sqrt((1-p1)/(n1*p1)+(1-p2)/(n2*p2))
    return r*exp_(-1.96*se), r*exp_(1.96*se)
def exp_(x): return np.exp(x)

print("=== SELF-TEST: my Fisher vs scipy.stats.fisher_exact ===")
cases=[(64,267,1224,4000),(22,267,564,4000),(135,267,2404,4000),(7,267,212,4000),
       (10,25,8,25),(18,25,11,25),(200,200,185,200),(50,100,50,100),(0,60,42,60)]
ok=True
for a,b,c,d in cases:
    mine=fisher_mine(a,b,c,d); _,sci=fisher_exact([[a,b-a],[c,d-c]])
    agree=abs(mine-sci)<1e-12; ok&=agree
    print(f"  {a}/{b} vs {c}/{d}:  mine={mine:.6g}  scipy={sci:.6g}  {'OK' if agree else '*** MISMATCH ***'}")
print("SELF-TEST", "PASS" if ok else "FAIL -- do not trust anything below")

print()
print("=== A3.1  #521 s10.5 table recomputed ===")
print(f"{'u':>4} {'class':>14} {'EC':>14} {'ratio':>7} {'Katz95 CI':>16} {'paper CI':>13} {'Fisher(mine)':>13} {'Fisher(scipy)':>14} {'paper p':>8}")
for u,kc,nc,ke,ne,pci,pp in [(1.5,135,267,2404,4000,"[0.72, 0.96]",0.0000),
                             (2.0, 64,267,1224,4000,"[0.60, 1.01]",0.0000),
                             (2.5, 22,267, 564,4000,"[0.36, 0.93]",0.0028),
                             (3.0,  7,267, 212,4000,"[0.21, 1.14]",1.0000)]:
    lo,hi=ratio_ci_katz(kc,nc,ke,ne)
    fm=fisher_mine(kc,nc,ke,ne); _,fs=fisher_exact([[kc,nc-kc],[ke,ne-ke]])
    flag=""
    if lo<1.0 and pp<0.01: flag="  <<< CI contains 1.0 but paper p<0.01: MUTUALLY EXCLUSIVE"
    if lo<1.0 and fs<0.01: flag+="  [Fisher also <0.01 => Fisher and Katz-CI DISAGREE]"
    print(f"{u:>4} {kc:>5}/{nc:<4}={kc/nc:.3f} {ke:>5}/{ne:<4}={ke/ne:.3f} {kc/nc/(ke/ne):>7.3f} [{lo:.2f}, {hi:.2f}] {pci:>13} {fm:>13.5f} {fs:>14.5f} {pp:>8.4f}{flag}")
