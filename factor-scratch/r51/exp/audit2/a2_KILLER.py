#!/usr/bin/env python3
"""A2 KILLER: the paper's own ln k = 2 sqrt(L ln L) - L is WRONG BY A FACTOR OF 2.

(kN)^{1/4} = L[1/2]  =>  kN = L[1/2]^4  =>  k = exp(4 sqrt(L ln L) - L)
so ln k = 4 sqrt(L ln L) - L, NOT 2 sqrt(L ln L) - L.

Check the boundary the paper states: ln k < 0 <=> 16 ln L < L  (NOT 4 ln L < L).
"""
from math import log, log2, sqrt, exp
import scipy.optimize as so

def Lhalf(N): return exp(sqrt(log(N)*log(log(N))))

print("=== 1. The paper's coefficient reproduces the paper's OWN numbers ===")
for n,claim in [(1024,-573),(2048,-1217),(4096,-2539)]:
    N=2**n; L=log(N)
    print(f"  n={n:>5}: 2*sqrt(L ln L)-L = {2*sqrt(L*log(L))-L:>10.2f}  (paper {claim})   |   CORRECT 4*sqrt(L ln L)-L = {4*sqrt(L*log(L))-L:>10.2f}")
print("  => the paper consistently used coefficient 2.  The derivation requires 4.")

print()
print("=== 2. The correct boundary ===")
f16=lambda L: L-16*log(L)
r=so.brentq(f16,10,200)
print(f"  ln k < 0  <=>  4 sqrt(L ln L) < L  <=>  16 ln L < L  <=>  L < {r:.4f}")
print(f"  => N < exp({r:.4f}) = {exp(r):.4e}      PAPER SAYS: L < 8.6 <=> N < 5400")
print(f"  => the paper's boundary is understated by {exp(r)/5400:.3e}x  ({__import__("math").log10(exp(r)/5400):.1f} orders of magnitude)")

print()
print("=== 3. DIRECT REFUTATION: at realistic N there IS a k with (kN)^{1/4} <= L[1/2] ===")
print(f"{'N':>12} {'n(bits)':>8} {'N^{1/4}':>12} {'L[1/2]':>12} {'claim holds?':>13} {'k with (kN)^1/4 = L[1/2]':>26}")
for N in [10**4,10**8,10**20,10**40,10**100,2**256,2**512,2**1024]:
    q=Lhalf(N); k4=q**4/N
    ok = (N**0.25) > q
    print(f"{N:>12.0e} {log2(N):>8.1f} {N**0.25:>12.3e} {q:>12.3e} {'YES' if ok else 'NO  <== REFUTED':>13} {k4:>26.4g}")

print()
print("=== 4. So what is the TRUE threshold for the paper's claim to hold? ===")
Nstar=exp(r)
print(f"  The claim '(kN)^{1/4} > L[1/2] for every k>=1' holds ONLY for N > {Nstar:.3e}")
print(f"  (n > {log2(Nstar):.1f} bits).  For N < {Nstar:.3e} it is FALSE -- there exists a")
print( "  k >= 1 making the class-group BSGS cost exactly L[1/2].")
print(f"  The paper states 5400 (n > 12.4 bits).  Over the entire range")
print(f"  5.4e3 < N < {Nstar:.1e} -- about {__import__("math").log10(Nstar/5400):.0f} orders of magnitude -- the")
print( "  paper's stated 'impossible' is in fact possible.")

print()
print("=== 5. WHERE THE REAL BLOCKER IS ===")
print("  Cost is tunable via k.  The cost argument therefore does NOT exclude the")
print("  route.  The live obstruction is the divisibility requirement p | h(-kN),")
print("  which the paper reports as a MEASUREMENT (0/890), not a proof.")
print("  => 'structurally excluded' is the wrong status word.  It should read")
print("     'cost-optimal k exists but the class group never contains p in 890 trials'.")
