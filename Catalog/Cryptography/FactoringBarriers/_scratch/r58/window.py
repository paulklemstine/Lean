"""The window that survives He-Sahai arXiv:2608.06681.

VERIFIED FROM THE PAPER (hesahai.txt):
  Thm 1.1:  AP n-divisor set, log H = o(sqrt n)  =>  L >= (sqrt(8/27)-o(1)) n^(3/4)/sqrt(log n)
  Cor 1.2:  no such AP with  L <= n^(2b+o(1)), H <= exp(n^(a+o(1)))  whenever  a < 1/2 AND b < 3/8.
  Remark 4.2: does NOT disprove the rank-2 (GAP) version.  Decisive step is
               (u+ic) - (u+jc) = (i-j)c; rank-2 differences have two free
               coefficients, so the at-most-one-intersection argument fails.

Umans-Wang (uw.txt, verified):
  Prop 3.4: AP Version  ==>  Strong (rank-2) Version.
  Conj 5.1/Thm 5.5: Strong PREFACTORED (a,b) => deterministic factoring in
                     N^(max(a,b)/2 + o(1)).
  Section 3 counting constraint:  a >= 1 - 2b.

SO: combine the two.  A point (a,b) survives He-Sahai and yields a factoring
improvement iff
      a < 1/2      (He-Sahai's height hypothesis must be satisfiable: log H = n^a = o(sqrt n))
      b >= 3/8     (otherwise Cor 1.2 refutes the AP version outright)
      a >= 1 - 2b  (Umans-Wang's own counting argument)
and the exponent obtained is max(a,b)/2.
"""
import math

def survives(a, b):
    """True if (a,b) is not refuted by He-Sahai Cor 1.2."""
    return not (a < 0.5 and b < 0.375)

def uw_consistent(a, b):
    return a >= 1 - 2*b - 1e-12

def exponent(a, b):
    return max(a, b)/2

def feasible(a, b):
    return survives(a,b) and uw_consistent(a,b)

print("=== The feasible region (AP route), after He-Sahai ===")
print(f"{'alpha':>7} {'beta':>7} {'a>=1-2b':>9} {'a<1/2':>7} {'b>=3/8':>8} "
      f"{'feasible':>9} {'exp=':>8} {'vs 1/5=0.2':>11}")
grid = [0.25, 0.30, 1/3, 0.375, 0.40, 0.45, 0.49, 0.5]
for b in grid:
    for a in [1/3, 0.375, 0.40, 0.45, 0.49]:
        c1 = uw_consistent(a,b); c2 = a < 0.5; c3 = b >= 0.375
        f = feasible(a,b)
        e = exponent(a,b) if f else None
        print(f"{a:7.3f} {b:7.3f} {str(c1):>9} {str(c2):>7} {str(c3):>8} "
              f"{str(f):>9} {(f'{e:.4f}' if f else '-'):>8} "
              f"{(f'{e-0.2:+.4f}' if f else '-'):>11}")
    print()

print("=== Minimise max(a,b)/2 over the feasible region ===")
best = None
for i in range(100, 500):
    a = i/1000
    for j in range(100, 500):
        b = j/1000
        if feasible(a,b):
            e = exponent(a,b)
            if best is None or e < best[0]:
                best = (e,a,b)
e,a,b = best
print(f"  optimum: alpha={a:.3f}, beta={b:.3f}, exponent={e:.4f}  (vs Harvey 1/5 = 0.2000)")
print(f"  improvement factor in exponent: {0.2/e:.4f}x  -> N^{e:.4f} vs N^0.2")
print(f"  note alpha + 2*beta = {a+2*b:.4f}   (Umans-Wang counting needs >= 1)")
print()
print("=== Sanity: the REFUTED point and the HE-Sahai bound ===")
print(f"  He-Sahai lower bound at beta=1/3:  L >= n^(3/4)/sqrt(log n)")
print(f"  Umans-Wang need at beta=1/3:      L <= n^(2/3)")
print(f"  ratio: n^(1/12)/sqrt(log n) -> infinity, so (1/3,1/3) is refuted with room to spare.")
print(f"  exponent had (1/3,1/3) held: max(1/3,1/3)/2 = {1/6:.4f}")
print(f"  exponent at the surviving corner (1/4,3/8): {max(0.25,0.375)/2:.4f}")
print(f"  -> the refutation costs us N^(1/6) and leaves N^(3/16) as the best case.")
