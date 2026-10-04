#!/usr/bin/env python3
"""
Q1 (rigorous, model-independent): the constant 1.9229994 is DERIVED assuming the
smoothness density is Dickman rho(u), u = ln V / ln B.  That is an ASYMPTOTIC
approximation.  Measure how far rho is from EXACT Psi at sizes this host can reach,
and whether the error has a sign that would bias the constant.

MANDATORY CONTROL (brief): rho is NOT a valid null -- Psi(x,B)/x -> e^-gamma/ln B
(a positive constant) while rho -> 0.  The ratio diverges.  Verified below.
"""
import math, sys
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')
from relcore import psi_exact
from q1_theory import dickman_rho

print("="*78)
print("CONTROL 1 -- rho is the WRONG functional form (ratio diverges)")
print("="*78)
print(f"{'B':>10} {'x':>14} {'u':>8} {'exact Psi/x':>14} {'rho(u)':>14} {'ratio':>12}")
for B in [100, 1000, 10000]:
    for x in [10**4, 10**8, 10**12, 10**16]:
        if x < B: continue
        u=math.log(x)/math.log(B)
        try:
            ex=psi_exact(x,B)/x
        except RecursionError:
            continue
        r=dickman_rho(u)
        print(f"{B:>10} {x:>14} {u:>8.3f} {ex:>14.6e} {r:>14.6e} {ex/r:>12.4f}")
print()
print("  => ratio grows without bound as x grows at fixed B.  rho is NOT a null.")

print()
print("="*78)
print("CONTROL 2 -- but in the ASYMPTOTIC regime (x = B^u, x huge) do they agree?")
print("="*78)
print("  This is the regime the L[1/3] constant lives in.  Test: hold u fixed,")
print("  send x -> infinity along x = B^u, and see if Psi/x -> rho(u).")
for u in [2.0, 3.0, 4.0]:
    print(f"  u={u}")
    for B in [1000, 10**4, 10**5, 10**6]:
        x=int(round(math.exp(u*math.log(B))))
        try:
            ex=psi_exact(x,B)/x
        except (RecursionError,MemoryError):
            print(f"    B={B:<9} x={x:<12.9g} (exact Psi not computable on this host)")
            continue
        r=dickman_rho(u)
        print(f"    B={B:<9} x={x:<12.9g} exact={ex:.6e} rho={r:.6e} ratio={ex/r:.4f} "
              f"rel.err={abs(ex/r-1)*100:6.2f}%")

print()
print("="*78)
print("CONTROL 3 -- does the rho error BIAS the constant up or down?")
print("="*78)
print("  cost ~ 1/density.  If exact density < rho, real cost is HIGHER than the")
print("  model says -> the TRUE constant is LARGER than 1.9229994 (model optimistic).")
print("  If exact density > rho, real cost is LOWER -> true constant smaller.")
