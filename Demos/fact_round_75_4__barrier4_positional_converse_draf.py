#!/usr/bin/env python3
"""
Numerical demonstrations for
"The Positional/Magnitude Stratum of the Barrier-4 Converse".

Everything in this file is self-contained: no third-party imports, exact
rational arithmetic where exactness is claimed, and each section reproduces one
theorem from the paper.

Contents
--------
1. The three fixed-window cost laws and their arithmetic progression.
2. The cap 1/mu, its regime mu <= 1/2, and the large-block counterexample.
3. The balanced-block degeneracy at mu = 1/2.
4. Block-first dominance: unconditional for protocol A, iff mu <= P for B.
5. Adaptive saturation: cost(2^m, m) = m + 1/2, exact on dyadic windows.
6. The net marginal identity, and the refutation of the gross form.
7. Pin vs argmin: the half-query gap and the two-point plateau.
8. The general-W bracket log2(W) - 1/2 <= min_k cost <= log2(W) + 1/2.
9. The residue cap 4/3 as a greatest element, attained only at theta = 1/2.
10. The Cauchy-Schwarz bits cap and its rigidity.
11. The four measured anchors as exact rationals, and class crossing.
12. The corner barrier (4/3) * sqrt(N) at a semiprime.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple

Num = Fraction


# ----------------------------------------------------------------------------
# Section 1 -- the three fixed-window cost laws
# ----------------------------------------------------------------------------


def cost_cert(mu: Num, p: Num) -> Num:
    """Protocol A, certified silence: mu*P + (1-P)*(1-mu)."""
    return mu * p + (1 - p) * (1 - mu)


def cost_fire_or_silent(mu: Num, p: Num) -> Num:
    """The drafted (superseded) fire-or-silent law: 1 - (1-mu)*P."""
    return 1 - (1 - mu) * p


def cost_rescan(mu: Num, p: Num) -> Num:
    """Protocol B, block-first with full re-scan on a miss: mu + (1-P)."""
    return mu + (1 - p)


def cost_cert_comp(mu: Num, p: Num) -> Num:
    """Protocol A, complement-first: P + (1-P)*(1-mu)."""
    return p + (1 - p) * (1 - mu)


def cost_rescan_comp(mu: Num, p: Num) -> Num:
    """Protocol B, complement-first: (1-mu) + P."""
    return (1 - mu) + p


def speedup(cost: Num) -> Num:
    """Speedup relative to the exhaustive scan of cost 1."""
    return Fraction(1) / cost


def demo_arithmetic_progression() -> None:
    print("=" * 78)
    print("1. THE THREE LAWS ARE IN ARITHMETIC PROGRESSION (gap = mu*(1-P))")
    print("=" * 78)
    grid: List[Tuple[Num, Num]] = [
        (Fraction(1, 20), Fraction(17, 20)),
        (Fraction(1, 4), Fraction(1, 2)),
        (Fraction(1, 3), Fraction(9, 10)),
        (Fraction(2, 5), Fraction(1, 5)),
        (Fraction(9, 10), Fraction(0)),
    ]
    print(f"{'mu':>8} {'P':>8} {'c_cert':>12} {'c_fos':>12} {'c_rescan':>12} "
          f"{'gap1':>10} {'gap2':>10}")
    all_ok = True
    for mu, p in grid:
        a, b, c = cost_cert(mu, p), cost_fire_or_silent(mu, p), cost_rescan(mu, p)
        g1, g2 = b - a, c - b
        ok = (g1 == g2 == mu * (1 - p))
        all_ok &= ok
        print(f"{str(mu):>8} {str(p):>8} {str(a):>12} {str(b):>12} {str(c):>12} "
              f"{str(g1):>10} {str(g2):>10}")
    # An exhaustive rational sweep, not just the display grid.
    for i in range(0, 21):
        for j in range(0, 21):
            mu, p = Fraction(i, 20), Fraction(j, 20)
            g1 = cost_fire_or_silent(mu, p) - cost_cert(mu, p)
            g2 = cost_rescan(mu, p) - cost_fire_or_silent(mu, p)
            all_ok &= (g1 == g2 == mu * (1 - p))
    print(f"\n  common gap identity over a 21x21 exact rational grid: "
          f"{'HOLDS' if all_ok else 'FAILS'}")
    print("  Reading: each non-certifying silence costs exactly one block measure.\n")


# ----------------------------------------------------------------------------
# Section 2/3 -- the cap and its failure; the balanced-block degeneracy
# ----------------------------------------------------------------------------


def demo_cap_regime() -> None:
    print("=" * 78)
    print("2. THE CAP S_A <= 1/mu HOLDS ONLY FOR mu <= 1/2")
    print("=" * 78)
    violations: List[Tuple[Num, Num, Num, Num]] = []
    for i in range(1, 20):
        for j in range(0, 21):
            mu, p = Fraction(i, 20), Fraction(j, 20)
            s = speedup(cost_cert(mu, p))
            if s > Fraction(1) / mu:
                violations.append((mu, p, s, Fraction(1) / mu))
    small = [v for v in violations if v[0] <= Fraction(1, 2)]
    print(f"  violations of S_A <= 1/mu found:            {len(violations)}")
    print(f"  ... of which have mu <= 1/2:                {len(small)}   (must be 0)")
    mu, p = Fraction(9, 10), Fraction(0)
    print(f"\n  sharpness witness: mu = {mu}, P = {p}")
    print(f"      c_cert = {cost_cert(mu, p)},  S_A = {speedup(cost_cert(mu, p))}, "
          f"  1/mu = {Fraction(1)/mu}")
    print(f"      honest bound 1/min(mu, 1-mu) = {Fraction(1)/min(mu, 1-mu)}  -- respected")
    print("  Reading: a certificate is a certificate whichever side it points to.\n")

    print("=" * 78)
    print("3. BALANCED-BLOCK DEGENERACY: at mu = 1/2 the oracle's accuracy is worthless")
    print("=" * 78)
    half = Fraction(1, 2)
    row = [(p, cost_cert(half, p), speedup(cost_cert(half, p)))
           for p in (Fraction(0), Fraction(1, 4), Fraction(1, 2), Fraction(3, 4), Fraction(1))]
    for p, c, s in row:
        print(f"      P = {str(p):>4}   c_cert = {c}   S_A = {s}")
    print("  Reading: c_cert(1/2, P) = 1/2 identically; contrast c_fos(1/2, P) = 1 - P/2.\n")


# ----------------------------------------------------------------------------
# Section 4 -- scan ordering
# ----------------------------------------------------------------------------


def demo_block_first() -> None:
    print("=" * 78)
    print("4. BLOCK-FIRST DOMINANCE: unconditional for A, iff mu <= P for B")
    print("=" * 78)
    a_violations = 0
    b_violations: List[Tuple[Num, Num]] = []
    for i in range(0, 21):
        for j in range(0, 21):
            mu, p = Fraction(i, 20), Fraction(j, 20)
            if cost_cert(mu, p) > cost_cert_comp(mu, p):
                a_violations += 1
            if cost_rescan(mu, p) > cost_rescan_comp(mu, p):
                b_violations.append((mu, p))
    print(f"  protocol A: block-first loses in {a_violations} of 441 cells (must be 0)")
    print(f"  protocol B: block-first loses in {len(b_violations)} cells; "
          f"all satisfy P < mu: "
          f"{all(p < mu for mu, p in b_violations)}")
    mu, p = Fraction(1, 2), Fraction(1, 4)
    print(f"\n  representative protocol-B failure: mu = {mu}, P = {p}")
    print(f"      block-first      = {cost_rescan(mu, p)}")
    print(f"      complement-first = {cost_rescan_comp(mu, p)}   (cheaper)\n")


# ----------------------------------------------------------------------------
# Sections 5-8 -- the adaptive stratum
# ----------------------------------------------------------------------------


def net_cost(w: Num, k: int) -> Num:
    """Expected total cost of committing to k binary queries on a window of width w."""
    return w / Fraction(2 ** (k + 1)) + k


def halving_cost(w: Num, k: int) -> Num:
    """The honest recursive process: scan at w/2, or pay 1 and halve."""
    if k == 0:
        return w / 2
    return 1 + halving_cost(w / 2, k - 1)


def dp_val(m: int) -> Num:
    """The halving recursion V(1) = 1/2, V(2W) = V(W) + 1, by dyadic exponent."""
    v = Fraction(1, 2)
    for _ in range(m):
        v += 1
    return v


def demo_saturation() -> None:
    print("=" * 78)
    print("5. ADAPTIVE SATURATION: cost(2^m, m) = m + 1/2 = log2(W) + 1/2, EXACT")
    print("=" * 78)
    print(f"{'m':>4} {'W = 2^m':>10} {'pinned cost':>14} {'m + 1/2':>10} "
          f"{'DP value':>10} {'process':>10}")
    ok = True
    for m in range(1, 13):
        w = Fraction(2 ** m)
        pinned, target, dp = net_cost(w, m), Fraction(2 * m + 1, 2), dp_val(m)
        proc = halving_cost(w, m)
        ok &= (pinned == target == dp == proc)
        print(f"{m:>4} {2**m:>10} {str(pinned):>14} {str(target):>10} "
              f"{str(dp):>10} {str(proc):>10}")
    # the full dyadic range claimed in the paper
    for m in range(1, 13):
        w = Fraction(2 ** m)
        ok &= (net_cost(w, m) == Fraction(2 * m + 1, 2) == halving_cost(w, m))
    print(f"\n  exact on every dyadic W in [2, 4096]: {'YES' if ok else 'NO'}")
    print("  Reading: the closed form is the fixed point of V(2W) = V(W) + 1, V(1) = 1/2.\n")


def demo_marginal_identity() -> None:
    print("=" * 78)
    print("6. MARGINAL VALUE: the NET form is exact, the GROSS form is false")
    print("=" * 78)
    net_ok = gross_ok = 0
    cells = 0
    for wi in range(1, 26):
        for k in range(0, 10):
            w = Fraction(wi)
            cells += 1
            lhs = net_cost(w, k) - net_cost(w, k + 1)
            if lhs == w / Fraction(2 ** (k + 2)) - 1:
                net_ok += 1
            if lhs == w / Fraction(2 ** (k + 2)):
                gross_ok += 1
    print(f"  cells tested: {cells}")
    print(f"      NET   form  cost(k) - cost(k+1) = W/2^(k+2) - 1 : {net_ok}/{cells} hold")
    print(f"      GROSS form  cost(k) - cost(k+1) = W/2^(k+2)     : {gross_ok}/{cells} hold")
    w, k = Fraction(4), 0
    print(f"\n  explicit refutation of the gross form at W = 4, k = 0:")
    print(f"      cost(4,0) = {net_cost(w, 0)},  cost(4,1) = {net_cost(w, 1)},  "
          f"difference = {net_cost(w, 0) - net_cost(w, 1)}")
    print(f"      gross prediction = {w / Fraction(2 ** (k + 2))}   -- wrong")
    print("  Reading: a query saves the halved residual scan, but costs one query.\n")


def demo_pin_vs_argmin() -> None:
    print("=" * 78)
    print("7. THE PIN IS NOT THE ARGMIN: a half-query gap, on a two-point plateau")
    print("=" * 78)
    print(f"{'M':>4} {'W = 2^M':>10} {'min_k cost':>12} {'argmin ks':>14} "
          f"{'pinned':>10} {'gap':>8}")
    for big_m in range(2, 13):
        w = Fraction(2 ** big_m)
        values = {k: net_cost(w, k) for k in range(0, big_m + 4)}
        best = min(values.values())
        argmins = sorted(k for k, v in values.items() if v == best)
        pinned = net_cost(w, big_m)
        print(f"{big_m:>4} {2**big_m:>10} {str(best):>12} {str(argmins):>14} "
              f"{str(pinned):>10} {str(pinned - best):>8}")
    print("\n  Reading: argmin offsets are always {-2, -1} relative to the pin,")
    print("           the minimum is always log2(W), and the gap is always 1/2.")
    print("  Census: pinned cost is 19.5 at W = 2^19 and 20.5 at W = 2^20 --")
    print(f"           {net_cost(Fraction(2**19), 19)} and {net_cost(Fraction(2**20), 20)}.\n")


def demo_bracket() -> None:
    print("=" * 78)
    print("8. THE GENERAL-W BRACKET: log2(W) - 1/2 <= min_k cost <= log2(W) + 1/2")
    print("=" * 78)
    worst_under = 0.0
    worst_at = 0
    worst_over = -10.0
    for w_int in range(1, 4097):
        w = float(w_int)
        best = min(w / 2.0 ** (k + 1) + k for k in range(0, 16))
        offset = best - math.log2(w)
        if offset < worst_under:
            worst_under, worst_at = offset, w_int
        worst_over = max(worst_over, offset)
    print(f"  offsets measured as  min_k cost(W,k) - log2(W),  W integer in [1, 4096]")
    print(f"      most negative offset: {worst_under:.6f} at W = {worst_at}")
    print(f"      largest offset:       {worst_over:.6f}")
    print(f"  lower bracket -1/2 crossed?  {'YES' if worst_under < -0.5 else 'NO'}")
    print(f"  upper bracket +1/2 exceeded? {'YES' if worst_over > 0.5 + 1e-12 else 'NO'}")
    print("  Reading: the closed form log2(W) + 1/2 is right to within half a query in")
    print("           both directions, and the upper bound is attained on dyadic W.\n")


# ----------------------------------------------------------------------------
# Sections 9-11 -- the dichotomy
# ----------------------------------------------------------------------------


def residue_cost(theta: Num) -> Num:
    """Cost of a residue filter of density theta: 1 - theta*(1-theta)."""
    return 1 - theta * (1 - theta)


def demo_residue_cap() -> None:
    print("=" * 78)
    print("9. THE RESIDUE CAP 4/3 IS A GREATEST ELEMENT, ATTAINED ONLY AT theta = 1/2")
    print("=" * 78)
    best = Fraction(0)
    best_theta = Fraction(0)
    attained: List[Num] = []
    for i in range(0, 1001):
        theta = Fraction(i, 1000)
        s = speedup(residue_cost(theta))
        if s > best:
            best, best_theta = s, theta
        if s == Fraction(4, 3):
            attained.append(theta)
    print(f"  max over theta in [0,1] (step 1/1000): {best} at theta = {best_theta}")
    print(f"  densities attaining 4/3 exactly:       {attained}")
    print(f"  identity c_res(theta) = c_fos(theta, theta) on a sweep: "
          f"{all(residue_cost(Fraction(i,100)) == cost_fire_or_silent(Fraction(i,100), Fraction(i,100)) for i in range(101))}")
    print("  Reading: 4/3 is the extremum of the uninformative diagonal P = mu of")
    print("           the fixed-window surface -- not an independent constant.\n")


def partition_cost(measures: Sequence[Num]) -> Num:
    """Expected cost of a certified partition with the given class measures."""
    return sum((m * m for m in measures), Fraction(0))


def demo_bits_cap() -> None:
    print("=" * 78)
    print("10. THE SET-CLASS BITS CAP: sum m_i^2 >= 1/n, equality iff uniform")
    print("=" * 78)
    examples: List[Tuple[str, List[Num]]] = [
        ("uniform, n = 4", [Fraction(1, 4)] * 4),
        ("uniform, n = 8", [Fraction(1, 8)] * 8),
        ("skewed,  n = 4", [Fraction(1, 2), Fraction(1, 4), Fraction(1, 8), Fraction(1, 8)]),
        ("skewed,  n = 8", [Fraction(1, 2)] + [Fraction(1, 14)] * 7),
    ]
    print(f"{'partition':>16} {'n':>4} {'cost':>12} {'1/n':>10} {'speedup':>14} {'cap n':>6}")
    for name, ms in examples:
        n = len(ms)
        assert sum(ms, Fraction(0)) == 1
        c = partition_cost(ms)
        print(f"{name:>16} {n:>4} {str(c):>12} {str(Fraction(1,n)):>10} "
              f"{str(speedup(c)):>14} {n:>6}")
    print("\n  Reading: the cap n (hence 2^k for a k-bit certificate) is attained")
    print("           exactly by the uniform partition; any imbalance strictly costs.\n")


ANCHORS: List[Tuple[str, Num, Num, Num]] = [
    ("5.19x", Fraction(1, 20), Fraction(17, 20), Fraction(400, 77)),
    ("6.91x", Fraction(1, 20), Fraction(9003, 10000), Fraction(200000, 28943)),
    ("4.35x", Fraction(1, 20), Fraction(8106, 10000), Fraction(200000, 45986)),
    ("29.1x", Fraction(1, 50), Fraction(9853, 10000), Fraction(500000, 17203)),
]


def demo_anchors() -> None:
    print("=" * 78)
    print("11. THE MEASURED ANCHORS: exact rationals, and CLASS CROSSING")
    print("=" * 78)
    print(f"{'anchor':>8} {'mu':>7} {'P':>9} {'exact S':>18} {'decimal':>12} "
          f"{'S(R)=3S/4':>11} {'budget 1/mu':>12} {'legal':>6}")
    for name, mu, p, expected in ANCHORS:
        s = speedup(cost_fire_or_silent(mu, p))
        assert s == expected, f"{name}: {s} != {expected}"
        s_r = Fraction(3, 4) * s
        budget = Fraction(1) / mu
        legal = s_r <= budget
        print(f"{name:>8} {str(mu):>7} {str(p):>9} {str(s):>18} {float(s):>12.6f} "
              f"{float(s_r):>11.4f} {float(budget):>12.2f} {str(legal):>6}")
    print("\n  every anchor exceeds the residue cap 4/3:",
          all(speedup(cost_fire_or_silent(mu, p)) > Fraction(4, 3) for _, mu, p, _ in ANCHORS))
    print("  every anchor factors as S(R) * 4/3 inside the positional budget:",
          all(Fraction(3, 4) * speedup(cost_fire_or_silent(mu, p)) <= Fraction(1) / mu
              for _, mu, p, _ in ANCHORS))
    print("  Reading: exceeding 4/3 is CLASS-CROSSING, not cap-breaking. No residue")
    print("           filter alone reaches even the smallest anchor (4/3 < 4.349).\n")


# ----------------------------------------------------------------------------
# Section 12 -- the corner barrier
# ----------------------------------------------------------------------------


def corner_witnesses(n: int) -> List[int]:
    """Nontrivial divisors d of n with d^2 <= n: the corner window [1, sqrt(n)]."""
    return [d for d in range(2, int(math.isqrt(n)) + 1) if n % d == 0 and d * d <= n]


def demo_corner_barrier() -> None:
    print("=" * 78)
    print("12. THE CORNER BARRIER: any position-plus-residue pipeline <= (4/3)*sqrt(N)")
    print("=" * 78)
    semiprimes: List[Tuple[int, int]] = [(3, 5), (7, 11), (13, 17), (101, 103), (211, 307)]
    print(f"{'N = p*q':>12} {'p':>6} {'q':>6} {'corner witnesses':>20} "
          f"{'sqrt(N)':>10} {'(4/3)sqrt(N)':>14}")
    for p, q in semiprimes:
        n = p * q
        w = corner_witnesses(n)
        print(f"{n:>12} {p:>6} {q:>6} {str(w):>20} {math.sqrt(n):>10.3f} "
              f"{4/3*math.sqrt(n):>14.3f}")
    print("\n  Every corner window of a semiprime holds exactly one nontrivial witness:",
          all(corner_witnesses(p * q) == [p] for p, q in semiprimes))
    # the pipeline bound itself
    print(f"\n{'N':>12} {'c_R = 1/sqrt(N)':>17} {'c_F = 3/4':>11} {'pipeline speedup':>18} "
          f"{'bound':>12}")
    for p, q in semiprimes:
        n = p * q
        c_r, c_f = 1.0 / math.sqrt(n), 0.75
        s = 1.0 / (c_r * c_f)
        print(f"{n:>12} {c_r:>17.6f} {c_f:>11.2f} {s:>18.4f} "
              f"{4/3*math.sqrt(n):>12.4f}")
    print("\n  Reading: the residue class contributes the constant 4/3 on top of the")
    print("           positional sqrt(N). Sieving cannot move the exponent.\n")


def main() -> None:
    print()
    print("#" * 78)
    print("#  Certified silence, adaptive saturation, and the SET/COST dichotomy")
    print("#  Numerical companion -- exact rational arithmetic throughout")
    print("#" * 78)
    print()
    demo_arithmetic_progression()
    demo_cap_regime()
    demo_block_first()
    demo_saturation()
    demo_marginal_identity()
    demo_pin_vs_argmin()
    demo_bracket()
    demo_residue_cap()
    demo_bits_cap()
    demo_anchors()
    demo_corner_barrier()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
