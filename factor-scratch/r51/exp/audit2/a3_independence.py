#!/usr/bin/env python3
"""A3: are #521's THREE defects actually independent?"""
from math import comb, sqrt, lgamma, log, exp

from fractions import Fraction

def fisher2(k1,n1,k2,n2):
    """Exact two-sided Fisher via Fractions (no float, no overflow)."""
    tot=n1+n2
    def h(k):
        if k<0 or k>n1 or k2-k<0 or k2-k>n2: return Fraction(0)
        return Fraction(comb(n1,k)*comb(n2,k2-k), comb(tot,k1+k))
    lo=max(0,k1-(n2-k2)); hi=min(n1,k1+k2)
    obs=h(k1)
    s=sum(h(k) for k in range(lo,hi+1) if h(k)<=obs)
    return float(min(Fraction(1),s))

def wilson(k,n,z=1.96):
    if n==0: return (0.0,1.0)
    ph=k/n; d=1+z*z/n
    c=(ph+z*z/(2*n))/d; h=z*sqrt(ph*(1-ph)/n+z*z/(4*n*n))/d
    return (max(0.,c-h),min(1.,c+h))

print("=== A3.1  RECOMPUTE paper's own table (#521 s10.5): CI vs Fisher p ===")
rows=[(1.5,135,267,2404,4000,0.841,0.0000,"[0.72, 0.96]"),
      (2.0, 64,267,1224,4000,0.783,0.0000,"[0.60, 1.01]"),
      (2.5, 22,267, 564,4000,0.584,0.0028,"[0.36, 0.93]"),
      (3.0,  7,267, 212,4000,0.495,1.0000,"[0.21, 1.14]")]
print(f"{'u':>4} {'class':>13} {'EC':>13} {'ratio':>7} {'ratioCI(computed)':>20} {'paperCI':>13} {'Fisher(computed)':>16} {'paperP':>8}  VERDICT")
for u,kc,nc,ke,ne,rp,pp,pci in rows:
    rc=kc/nc; re_=ke/ne; r=rc/re_
    lr =sqrt((1/rc-1+1/nc)/kc) if kc>0 else 1.0
    rlo=r*sqrt(max(1e-12,1-1.96*lr)); rhi=r*sqrt(1+1.96*lr)
    p=fisher2(kc,nc,ke,ne)
    ci_has1 = rlo<1.0
    verdict=""
    if ci_has1 and p<0.01: verdict="** INCONSISTENT: CI contains 1.0 but p<0.01 **"
    elif p>0.05 and not ci_has1: verdict="INCONSISTENT (other way)"
    else: verdict="consistent"
    print(f"{u:>4} {kc:>4}/{nc:<4}={rc:.3f} {ke:>5}/{ne:<4}={re_:.3f} {r:>7.3f} [{rlo:.2f}, {rhi:.2f}]{'':>4} {pci:>13} {p:>16.5f} {pp:>8.4f}  {verdict}")

print()
print("  Interpretation: for a RATIO of two independent proportions, a 95% CI containing 1.0")
print("  and a Fisher p<0.01 cannot both be right.  The paper's u=2.0 row asserts both.")

print()
print("=== A3.2  SCALE-MATCHING ALONE (EC left at native MIXED parity) ===")
for u,c,e,r in [(1.5,.506,.601,.841),(2.0,.240,.306,.783),(2.5,.082,.141,.584),(3.0,.026,.053,.495)]:
    print(f"  u={u}: class={c:.3f}  EC(mixed)={e:.3f}  ratio={r:.3f}"
          + ("   <-- REVERSED, no parity matching used" if r<1 else ""))

print()
print("=== A3.3  PARITY MATCHING ALONE (odd-uniform control; paper's own claim) ===")
for u,c,o,r in [(1.5,.506,.518,.98),(2.0,.240,.244,.98),(2.5,.082,.100,.82),(3.0,.026,.036,.73)]:
    print(f"  u={u}: class={c:.3f}  odd-uniform={o:.3f}  ratio={r:.3f}"
          + ("   NULL, not a reversal" if r>0.9 else ""))

print()
print("=== A3.4  VERDICT ON INDEPENDENCE ===")
print("  E-6b  n=200/200, h<=1684 (11 bits), B=1000   -> defect 1 (self-referential baseline)")
print("  E-6c  n=25/25,    29-bit class numbers       -> defect 2 (half-bit scale offset)")
print("  E-7   n=25/25,    NO scale recorded at all   -> defects 3a(no scale)+3b(parity)")
print("  These are defects of THREE DIFFERENT experiments.  A defect of E-6c cannot")
print("  'independently explain' E-7's number.")
print("  Moreover for E-7: scale-matching ALONE already reverses (0.78, 0.58);")
print("  parity-matching ALONE gives NULL vs the parity-correct control (0.98),")
print("  i.e. NOT a reversal. So parity is NOT an independent route to the same verdict.")
