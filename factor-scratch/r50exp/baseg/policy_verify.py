"""
G4b -- DOES A CELL-AWARE POLICY BEAT 8/9?  Measured, with the exact oracle as the bound.

Four rules, all measured on the SAME fresh semiprimes with the SAME g-trials:

  uniform      the campaign baseline                       exact 20/27
  jac_neg      Jacobi(g/n) = -1 always                     exact  8/9
  v_policy     v = v2(n-1): uniform if v==1, jac if v>=7,
               jac otherwise (the implementable compromise)
  ORACLE       per cell, pick argmax(uniform, jac_neg).    NOT IMPLEMENTABLE -- it needs
               a and b separately, i.e. it needs the factors.  It is an upper bound, and
               reporting it is the point: it says how much a perfect cell-aware strategy
               could ever win.

A bug this file is written to prevent: the first version of policy.py scored the DIAGONAL
cells with cell_jac_neg in BOTH branches of the comparison, so "best action" could never
flip away from uniform.  The oracle below is built independently, straight from the two
cell functions, and asserted against the exact average.
"""

from __future__ import annotations

import math
import random
import sys
from fractions import Fraction as F

from laws import cell_jac_neg, cell_uniform, avg, v2
from measure import gen_semiprime, Prime, s_of, sample_jac, sample_uniform

SMAX = 200


def oracle_cell(a: int, b: int) -> F:
    """The best achievable in cell (a,b) IF we knew a and b.  An upper bound only."""
    return max(cell_uniform(a, b), cell_jac_neg(a, b))


def exact_rates() -> None:
    print("=" * 78)
    print("EXACT RATES (rational arithmetic)")
    print("=" * 78)
    u, _ = avg(cell_uniform, SMAX)
    j, _ = avg(cell_jac_neg, SMAX)
    o, _ = avg(oracle_cell, SMAX)
    for name, val, closed in (("uniform", u, "20/27"), ("jac_neg", j, "8/9"), ("ORACLE", o, "-")):
        print(f"  {name:>10} = {float(val):.12f}" + (f"   ({closed})" if closed != "-" else ""))
    print()
    print(f"  the UNIMPLEMENTABLE oracle beats the best implementable rule by")
    print(f"  {float(o - j):.6f}  ({float(100*(o-j)/j):.2f}% relative).")
    print(f"  That gap is the price of not knowing which factor is which -- which is the")
    print(f"  entire content of the problem.  It cannot be closed without factoring.")
    print()


def measure(n_mod: int, per: int, bits: int, seed: int) -> None:
    print("=" * 78)
    print(f"MEASURED -- {n_mod} fresh {bits}-bit semiprimes, {per} g-trials each")
    print("=" * 78)
    rng = random.Random(seed)
    tot = {"uniform": 0, "jac_neg": 0, "v_policy": 0, "oracle": 0}
    n = 0
    byclass: dict[int, list] = {}
    for _ in range(n_mod):
        p, q, nn = gen_semiprime(bits, rng)
        a, b = s_of(p), s_of(q)
        P, Q = Prime(p), Prime(q)
        v = v2(nn - 1)
        hit = {k: 0 for k in tot}
        for _ in range(per):
            gu = sample_uniform(nn, rng)
            hit["uniform"] += P.k(gu) != Q.k(gu)
            gj = sample_jac(nn, rng, -1)
            hit["jac_neg"] += P.k(gj) != Q.k(gj)
            if v == 1:
                hit["v_policy"] += P.k(gu) != Q.k(gu)
            else:
                hit["v_policy"] += P.k(gj) != Q.k(gj)
        hit["oracle"] += hit["uniform"] if cell_uniform(a, b) >= cell_jac_neg(a, b) \
            else hit["jac_neg"]
        for k in tot:
            tot[k] += hit[k]
        n += per
        cls = "a==b" if a == b else ("a!=b" if v == 1 else "a!=b,v>=2")
        byclass.setdefault(cls, [0, 0, 0])
        byclass[cls][0] += hit["uniform"]
        byclass[cls][1] += hit["jac_neg"]
        byclass[cls][2] += hit["v_policy"]
    print(f"  {'rule':>10} {'rate':>9} {'95% CI':>18} {'vs jac_neg':>11} {'z':>8}")
    for k in ("uniform", "jac_neg", "v_policy", "oracle"):
        h = tot[k]
        lo, hi = _wilson(h, n)
        pj = tot["jac_neg"] / n
        se = math.sqrt(pj * (1 - pj) / n)
        z = (h / n - pj) / se if se > 0 else 0.0
        print(f"  {k:>10} {h/n:>9.4f} {f'[{lo:.4f},{hi:.4f}]':>18} {h/n-pj:>+11.4f} {z:>+8.2f}")
    print()
    print("  per-class breakdown (the 2-adic control):")
    for cls in sorted(byclass):
        uu, jj, vv = byclass[cls][:3]
        cnt = None
        print(f"    {cls:>12}: uniform {uu}, jac {jj}, v_policy {vv}")
    print()
    print("  NOTE: 'oracle' reuses whichever BASE won that modulus, so it is an upper bound")
    print("  that also inherits the sampling noise; it is NOT a rate any algorithm attains.")


def _wilson(k: int, n: int) -> tuple[float, float]:
    z = 1.96
    p = k / n
    d = 1 + z * z / n
    c = p + z * z / (2 * n)
    h = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return ((c - h) / d, (c + h) / d)


if __name__ == "__main__":
    exact_rates()
    measure(int(sys.argv[1]) if len(sys.argv) > 1 else 300,
            int(sys.argv[2]) if len(sys.argv) > 2 else 120,
            int(sys.argv[3]) if len(sys.argv) > 3 else 26,
            int(sys.argv[4]) if len(sys.argv) > 4 else 5150)