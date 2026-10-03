#!/usr/bin/env python3
"""A2 axis (1): ALGEBRA + TABLE + the 0/890 arithmetic."""
import math
from decimal import Decimal, getcontext
getcontext().prec = 60

def L_of(n): return n * math.log(2.0)

# --- the derivation, step by step, checked symbolically-by-substitution ---
print("="*78)
print("STEP 1.  (kN)^{1/4} = L[1/2]  with  L[1/2] := exp((1/2) sqrt(ln N ln ln N))")
print("  take ln of both sides:")
print("    (1/4)(ln k + ln N) = (1/2) sqrt(ln N * ln ln N)")
print("    (1/4)(ln k + L)    = (1/2) sqrt(L ln L)          [L := ln N]")
print("    ln k + L           = 2 sqrt(L ln L)")
print("    ln k               = 2 sqrt(L ln L) - L        <-- PAPER'S FORM: CORRECT")
print("  residual check: substitute back for random (k,N)")
rng_ok = True
for k,nb in [(3,24),(1,256),(97,1024),(5,4096)]:
    L = nb*math.log(2.0)
    N = None
    lnk = 2*math.sqrt(L*math.log(L)) - L      # formula under test
    k_recovered = math.exp(lnk)              # invert it
    lhs  = 0.25*(math.log(k_recovered) + L) if k_recovered>0 else 0.25*L
    if k_recovered==0: print(f'    k_in={k:5d}  N=2^{nb:<5d}: ln k={lnk:14.4f}  k_rec UNDERFLOWS to 0 (k astronomically < 1)'); continue
    rhs  = 0.5*math.sqrt(L*math.log(L))
    if abs(lhs-rhs) > 1e-9*max(1,abs(rhs)): rng_ok=False
    print(f"    k_in={k:5d}  N=2^{nb:<5d}: ln k={lnk:14.4f}  "
          f"k_rec={k_recovered:.6g}  |ln((kN)^.25)-.5sqrt(LlnL)|={abs(lhs-rhs):.2e}")
print("  -> derivation VERIFIED" if rng_ok else "  -> DERIVATION WRONG")

print()
print("STEP 2.  sign of 2 sqrt(L ln L) - L  <->  4 ln L vs L")
print("  2 sqrt(L ln L) < L  (both sides >0)")
print("  <=> 4 L ln L < L^2   (square both sides)")
print("  <=> 4 ln L < L       (divide by L>0)     <-- valid only for L>0 AND ln L>=0")
print("  NOTE the paper's next hop is:")
print("  '4 ln L < L  <=>  L < 8.6'   <-- DIRECTION CHECK")

def f(L): return 4*math.log(L) - L      # >0 iff 4lnL > L
# solve 4 ln L = L exactly by bisection on the upper branch
lo, hi = 4.0, 20.0
for _ in range(200):
    mid = 0.5*(lo+hi)
    if f(mid) > 0: lo = mid
    else: hi = mid
root_up = 0.5*(lo+hi)
# lower branch
lo2, hi2 = 1.0, 4.0
for _ in range(200):
    mid = 0.5*(lo2+hi2)
    if f(mid) < 0: lo2 = mid
    else: hi2 = mid
root_lo = 0.5*(lo2+hi2)
print(f"  roots of 4 ln L = L :  L = {root_lo:.6f}  and  L = {root_up:.6f}")
print(f"  f(L) at L=8.6       : {f(8.6):+.5f}   (PAPER SAYS 8.6 IS THE ROOT)")
print(f"  e^root_up          : {math.exp(root_up):.2f}   (PAPER SAYS N < 5400)")
print(f"  e^8.6              : {math.exp(8.6):.2f}")
print()
print("  DIRECTION: 4 ln L < L holds on which side?")
for L in [2.0, 5.0, 8.6, 9.0, 20.0, 100.0, 709.78]:
    print(f"    L={L:9.4f}  4lnL-L={f(L):+12.4f}  -> "
          f"2sqrt(LlnL) {'<' if f(L)<0 else '>'} L  =>  k {'< 1 (IMPOSSIBLE)' if f(L)<0 else '>= 1 (ok)'}")
print()
print("  ==> CORRECT:  4 ln L < L  <=>  L > %.4f  <=>  N > %.0f" % (root_up, math.exp(root_up)))
print("  ==> PAPER:   4 ln L < L  <=>  L <  8.6   <=>  N <  5400")
print("      *** THE PAPER'S EQUIVALENCE IS DIRECTIONALLY INVERTED ***")
print("      Its PROSE conclusion ('N > 5400' excluded) matches the corrected chain,")
print("      but the displayed chain says the opposite.")

print()
print("STEP 3.  ln k = 2 sqrt(L ln L) - L, recomputed")
print(f"  {'n':>7} {'L=ln N':>12} {'2 sqrt(L lnL)':>14} {'ln k':>12}   paper")
paper = {1024:-573, 2048:-1217, 4096:-2539}
for n in [256, 512, 1024, 2048, 4096, 16384]:
    L = L_of(n); lnk = 2*math.sqrt(L*math.log(L)) - L
    tag = f"{paper[n]}" if n in paper else ""
    agree = ""
    if n in paper:
        agree = "  MATCH" if abs(round(lnk)-paper[n])<=1 else f"  OFF BY {lnk-paper[n]:.2f}"
    print(f"  {n:7d} {L:12.4f} {2*math.sqrt(L*math.log(L)):14.4f} {lnk:12.2f}   {tag}{agree}")

print()
print("STEP 4.  the L[1/2] / L[1/3] table columns (all log2)")
def Lhalf_log2(n):
    L = L_of(n); return 0.5*math.sqrt(L*math.log(L))/math.log(2)
def Lthird_log2(n, c=(64/9)**(1/3)):
    L = L_of(n); return c*(L**(1/3))*(math.log(L)**(2/3))/math.log(2)
print(f"  {'n':>7} {'N^(1/4)':>9} {'L[1/2]':>9} {'L[1/3]':>9} {'d1/2':>10} {'d1/3':>10}")
tbl = {256:(21.87,46.66),1024:(49.24,86.77),4096:(108.38,156.50),16384:(234.90,276.52)}
for n in [256,1024,4096,16384]:
    a, b, c = 0.25*n, Lhalf_log2(n), Lthird_log2(n)
    pa, pb = tbl[n]
    print(f"  {n:7d} {a:9.2f} {b:9.2f} {c:9.2f} "
          f"{a-b:10.2f} {a-c:10.2f}   paper: {pa:.2f} / {pb:.2f}"
          f"   paper diffs: {pa-a:.2f} / {a-pb:.2f}")
print(f"  c for L[1/3] = (64/9)^(1/3) = {(64/9)**(1/3):.6f}")
print("  PAPER DEFINITION OF L[1/alpha]?  grep:")

print()
print("STEP 5.  the 0/890 arithmetic")
a1, na = 640, 40*16
a2, nb = 150, 30*5
print(f"  'N~2^66, 40 instances, 16 k-values'  -> 40*16 = {40*16}")
print(f"  'N~2^53, 30 instances, k<=5'        -> 30*5  = {30*5}")
print(f"  TOTAL = {na} + {nb} = {na+nb}")
print(f"  PAPER SAYS 890.   890 - {na+nb} = {890-(na+nb)}  *** ARITHMETIC ERROR ***")
print(f"  the 16 k-values in the paper: {len([1,2,3,4,5,6,8,12,16,24,32,64,128,256,1024,4096])} items")
