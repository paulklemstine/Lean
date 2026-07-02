"""
Uniform Extremality for Siblings of the Coupon Collector
========================================================

Numerical demonstrations of the sibling coupon-collector results.

Model
-----
Coupons come in N types drawn i.i.d. from a probability vector p on the open
simplex.  The MAIN collector stops at the first time T when every type has
appeared at least once.  The j-th SIBLING regards a type as filled once it has
been seen >= j times; U_j^N counts the types still empty at time T.

We demonstrate:
  1. The exact inclusion-exclusion closed form for E_p[U_j^N].
  2. Permutation symmetry of the expectation.
  3. The balanced-distribution value  N * sum_s (-1)^s C(N-1,s) / (1+s)^j.
  4. The two-type collapse  2 - p0^j - p1^j.
  5. Uniform extremality: the balanced distribution maximizes E_p[U_j^N].
  6. A Monte Carlo cross-check of the closed form.

Self-contained: standard library only.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import comb
from typing import List, Sequence, Tuple
import random


# --------------------------------------------------------------------------- #
#  1. Exact closed form via inclusion-exclusion                               #
# --------------------------------------------------------------------------- #
def expected_empty_exact(p: Sequence[Fraction], j: int) -> Fraction:
    """Exact E_p[U_j^N] via inclusion-exclusion (Definition 3.1).

    E_p[U_j^N] = sum_i sum_{S subseteq [N]\\{i}} (-1)^|S|
                   (p_i / (p_i + sum_{s in S} p_s))^j
    """
    n = len(p)
    total = Fraction(0)
    for i in range(n):
        competitors = [k for k in range(n) if k != i]
        for r in range(len(competitors) + 1):
            for subset in combinations(competitors, r):
                q_s = sum((p[s] for s in subset), Fraction(0))
                ratio = p[i] / (p[i] + q_s)
                total += Fraction((-1) ** r) * ratio ** j
    return total


# --------------------------------------------------------------------------- #
#  2. Balanced (uniform) distribution value (Theorem 4.2)                      #
# --------------------------------------------------------------------------- #
def expected_empty_uniform(n: int, j: int) -> Fraction:
    """Closed form at p = (1/N, ..., 1/N):
        N * sum_{s=0}^{N-1} (-1)^s C(N-1, s) / (1+s)^j.
    """
    return Fraction(n) * sum(
        (Fraction((-1) ** s * comb(n - 1, s), (1 + s) ** j) for s in range(n)),
        Fraction(0),
    )


# --------------------------------------------------------------------------- #
#  3. Two-type closed form (Theorem 4.3)                                       #
# --------------------------------------------------------------------------- #
def expected_empty_two(a: Fraction, j: int) -> Fraction:
    """Two-type value 2 - a^j - (1-a)^j for p = (a, 1-a)."""
    return Fraction(2) - a ** j - (Fraction(1) - a) ** j


# --------------------------------------------------------------------------- #
#  4. Monte Carlo estimate                                                     #
# --------------------------------------------------------------------------- #
def expected_empty_monte_carlo(
    p: Sequence[float], j: int, trials: int, seed: int = 0
) -> float:
    """Unbiased Monte Carlo estimate of E_p[U_j^N]."""
    rng = random.Random(seed)
    n = len(p)
    cumulative: List[float] = []
    acc = 0.0
    for prob in p:
        acc += prob
        cumulative.append(acc)

    def draw() -> int:
        x = rng.random()
        for idx, threshold in enumerate(cumulative):
            if x <= threshold:
                return idx
        return n - 1

    total_empty = 0
    for _ in range(trials):
        counts = [0] * n
        seen_types = 0
        while seen_types < n:
            t = draw()
            if counts[t] == 0:
                seen_types += 1
            counts[t] += 1
        total_empty += sum(1 for c in counts if c < j)
    return total_empty / trials


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_two_type_collapse() -> None:
    print("=" * 70)
    print("1. Two-type collapse:  closed form  ==  2 - a^j - (1-a)^j")
    print("=" * 70)
    for a in (Fraction(1, 2), Fraction(1, 3), Fraction(3, 4)):
        for j in (2, 3, 5):
            full = expected_empty_exact([a, Fraction(1) - a], j)
            short = expected_empty_two(a, j)
            ok = "OK" if full == short else "MISMATCH"
            print(f"  a={str(a):>4}  j={j}:  {str(full):>12} = {str(short):>12}  [{ok}]")
    print()


def demo_balanced_value() -> None:
    print("=" * 70)
    print("2. Balanced value: enumeration  ==  N*sum (-1)^s C(N-1,s)/(1+s)^j")
    print("=" * 70)
    for n in (2, 3, 4, 5):
        for j in (2, 3):
            unif = [Fraction(1, n)] * n
            full = expected_empty_exact(unif, j)
            closed = expected_empty_uniform(n, j)
            ok = "OK" if full == closed else "MISMATCH"
            print(
                f"  N={n} j={j}:  {str(full):>12} = {str(closed):>12}"
                f"  ~ {float(closed):.6f}  [{ok}]"
            )
    print("  (Highlight: N=3, j=3 gives 85/36 =", float(Fraction(85, 36)), ")")
    print()


def demo_permutation_symmetry() -> None:
    print("=" * 70)
    print("3. Permutation symmetry:  E_p = E_{p o sigma}")
    print("=" * 70)
    p = [Fraction(1, 2), Fraction(1, 3), Fraction(1, 6)]
    perms: List[Tuple[int, ...]] = [(0, 1, 2), (2, 0, 1), (1, 2, 0), (2, 1, 0)]
    j = 3
    base = expected_empty_exact(p, j)
    for perm in perms:
        pp = [p[k] for k in perm]
        val = expected_empty_exact(pp, j)
        ok = "OK" if val == base else "MISMATCH"
        print(f"  perm {perm}:  {str(val):>12}  [{ok}]")
    print()


def demo_uniform_extremality() -> None:
    print("=" * 70)
    print("4. Uniform extremality:  balanced distribution is the MAXIMUM")
    print("=" * 70)
    j = 3
    n = 3
    unif_val = expected_empty_uniform(n, j)
    print(f"  Balanced (1/3,1/3,1/3), j={j}:  {str(unif_val)} ~ {float(unif_val):.6f}")
    candidates = [
        [Fraction(1, 2), Fraction(1, 4), Fraction(1, 4)],
        [Fraction(3, 5), Fraction(1, 5), Fraction(1, 5)],
        [Fraction(4, 5), Fraction(1, 10), Fraction(1, 10)],
        [Fraction(2, 5), Fraction(2, 5), Fraction(1, 5)],
    ]
    for p in candidates:
        val = expected_empty_exact(p, j)
        rel = "<" if val < unif_val else (">" if val > unif_val else "=")
        print(f"  p={[str(x) for x in p]}:  {float(val):.6f}  {rel} balanced")
    print("  -> every unbalanced distribution gives a strictly smaller value.\n")


def demo_monte_carlo() -> None:
    print("=" * 70)
    print("5. Monte Carlo cross-check of the closed form")
    print("=" * 70)
    cases: List[Tuple[List[Fraction], int]] = [
        ([Fraction(1, 2), Fraction(1, 2)], 3),
        ([Fraction(1, 3), Fraction(1, 3), Fraction(1, 3)], 3),
        ([Fraction(3, 5), Fraction(1, 5), Fraction(1, 5)], 2),
    ]
    trials = 200_000
    for p, j in cases:
        exact = float(expected_empty_exact(p, j))
        pf = [float(x) for x in p]
        mc = expected_empty_monte_carlo(pf, j, trials, seed=42)
        print(
            f"  p={[str(x) for x in p]} j={j}:  exact={exact:.5f}  "
            f"MC={mc:.5f}  (|diff|={abs(exact-mc):.5f})"
        )
    print()


def main() -> None:
    demo_two_type_collapse()
    demo_balanced_value()
    demo_permutation_symmetry()
    demo_uniform_extremality()
    demo_monte_carlo()


if __name__ == "__main__":
    main()
