"""
Tie geometry, effective bases, and corruption budgets for rank-correlation dials
================================================================================

Self-contained numerical demonstration of every result in the accompanying
paper.  Exact rational arithmetic (``fractions.Fraction``) is used everywhere a
theorem is stated exactly; floating point appears only for display and for the
continuous effective-base inversion.

Background in one paragraph
---------------------------
A statistic partitions a sample of size ``n`` into tie classes of sizes
``m_1, ..., m_k``.  The largest squared Spearman rank correlation attainable
against ANY response is

    sigma^2(L) = 1 - sum_j (m_j^3 - m_j) / (n^3 - n).

For the base-``p`` trailing-zero statistic (the ``p``-adic valuation) on
``{0, ..., p^b - 1}`` the profile is
``((p-1)p^(b-1), ..., (p-1)p, (p-1), 1)`` and the ceiling has the closed form

    sigma^2(p, b) = 3p/(p^2 + p + 1) * (1 + 1/(p^b (p^b + 1))).

The measurement under study recorded Spearman rho = 0.593, 0.618, 0.612 at
bit-width 76 (pooled 0.608), versus 0.648 at bit-width 64.

Run with::

    python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------
# Recorded data
# --------------------------------------------------------------------------

SEEDS_76: Tuple[Fraction, Fraction, Fraction] = (
    Fraction(593, 1000),
    Fraction(618, 1000),
    Fraction(612, 1000),
)
POOLED_76: Fraction = Fraction(608, 1000)
CI_76: Tuple[Fraction, Fraction] = (Fraction(588, 1000), Fraction(631, 1000))
BAND: Tuple[Fraction, Fraction] = (Fraction(55, 100), Fraction(85, 100))
POOLED_64: Fraction = Fraction(648, 1000)
COUNT_GAP: Fraction = Fraction(73, 1000)
COUNT_GAP_CI: Tuple[Fraction, Fraction] = (Fraction(45, 1000), Fraction(97, 1000))


# --------------------------------------------------------------------------
# 1. Tie corrections and the attainable ceiling
# --------------------------------------------------------------------------


def tie_correction(profile: Sequence[int]) -> Fraction:
    """Kendall tie correction T(L) = sum_j (m_j^3 - m_j) / 12."""
    return Fraction(sum(m**3 - m for m in profile), 12)


def attainable_ceiling(profile: Sequence[int]) -> Fraction:
    """Largest attainable rho^2 against a statistic with this tie profile."""
    n = sum(profile)
    if n < 2:
        raise ValueError("need at least two observations")
    return Fraction(1) - Fraction(sum(m**3 - m for m in profile), n**3 - n)


def valuation_profile(p: int, b: int) -> List[int]:
    """Tie profile of the base-p trailing-zero statistic on {0, ..., p^b - 1}."""
    if p < 2 or b < 0:
        raise ValueError("need p >= 2 and b >= 0")
    return [(p - 1) * p**k for k in range(b - 1, -1, -1)] + [1]


def pi_limit(p: float) -> float:
    """Asymptotic base-p ceiling pi(p) = 3p / (p^2 + p + 1)."""
    return 3.0 * p / (p * p + p + 1.0)


def pi_limit_exact(p: int) -> Fraction:
    """Exact asymptotic ceiling for an integer base."""
    return Fraction(3 * p, p * p + p + 1)


def ceiling_law(p: int, b: int) -> Fraction:
    """Closed form of the p-adic ceiling law (exact)."""
    Y = Fraction(p) ** b
    return pi_limit_exact(p) * (1 + 1 / (Y * (Y + 1)))


# --------------------------------------------------------------------------
# 2. The dominant-block law
# --------------------------------------------------------------------------


def dominant_block_bound(max_block: int, n: int) -> Fraction:
    """Profile-free lower bound rho^2 >= 1 - (M^2 - 1)/(n^2 - 1)."""
    return Fraction(1) - Fraction(max_block**2 - 1, n**2 - 1)


def required_concentration(rho: Fraction) -> float:
    """Smallest largest-class fraction M/n compatible with a ceiling of rho^2."""
    return math.sqrt(1.0 - float(rho) ** 2)


# --------------------------------------------------------------------------
# 3. The effective base
# --------------------------------------------------------------------------


def effective_base(r: float) -> float:
    """Continuous inverse of the ceiling law: the unique x > 1 with pi(x) = r."""
    if not 0.0 < r < 1.0:
        raise ValueError("r must lie strictly between 0 and 1")
    return ((3.0 - r) + math.sqrt(3.0 * (1.0 - r) * (3.0 + r))) / (2.0 * r)


def unique_integer_base(window: Tuple[float, float]) -> List[int]:
    """All integer bases p >= 2 whose asymptotic ceiling lies in the window."""
    lo, hi = window
    return [p for p in range(2, 64) if lo <= pi_limit(p) <= hi]


# --------------------------------------------------------------------------
# 4. Rank perturbation: Lipschitz law, budget, exact transposition
# --------------------------------------------------------------------------


def sum_sq_d(R: Sequence[Fraction], S: Sequence[Fraction]) -> Fraction:
    """Spearman's sum of squared rank differences."""
    return sum((a - b) ** 2 for a, b in zip(R, S))


def rho_rank(R: Sequence[Fraction], S: Sequence[Fraction]) -> Fraction:
    """Spearman's rho in d^2 form."""
    n = len(R)
    return Fraction(1) - Fraction(6) * sum_sq_d(R, S) / Fraction(n**3 - n)


def lipschitz_bound(n: int, corrupted: int) -> Fraction:
    """Maximal |delta rho| achievable by re-ranking `corrupted` observations."""
    return Fraction(6 * corrupted * (n - 1) ** 2, n**3 - n)


def corruption_budget(n: int, delta: Fraction) -> int:
    """Minimum number of re-ranked observations needed to move rho by delta."""
    exact = delta * n / 6
    return math.ceil(exact)


def extremal_swap_increment(n: int) -> Fraction:
    """Exact change in rho from transposing the two extreme ranks."""
    return Fraction(12 * (n - 1), n * (n + 1))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_recorded_data() -> None:
    banner("0.  The recorded measurement at bit-width 76")
    mean = sum(SEEDS_76) / 3
    print(f"  seeds            : {[f'{float(s):.3f}' for s in SEEDS_76]}")
    print(f"  seed mean        : {float(mean):.6f}")
    print(f"  pooled           : {float(POOLED_76):.6f}"
          f"   (|pooled - mean| = {float(abs(POOLED_76 - mean)):.6f} < 0.001)")
    print(f"  CI               : [{float(CI_76[0]):.3f}, {float(CI_76[1]):.3f}]")
    inside = all(BAND[0] <= v <= BAND[1] for v in (*SEEDS_76, POOLED_76, *CI_76))
    print(f"  inside band [0.55, 0.85]? {inside}")
    print(f"  advantage over plain count: {float(COUNT_GAP):+.3f} "
          f"CI [{float(COUNT_GAP_CI[0]):.3f}, {float(COUNT_GAP_CI[1]):.3f}]  "
          f"-> strictly positive: {COUNT_GAP_CI[0] > 0}")


def demo_ceiling_law() -> None:
    banner("1.  The p-adic ceiling law, verified exactly against the definition")
    print("     sigma^2(p,b) = 3p/(p^2+p+1) * (1 + 1/(p^b (p^b+1)))")
    print()
    print(f"  {'p':>3} {'b':>4} {'direct from profile':>26} {'closed form':>26} {'agree':>7}")
    for p, b in [(2, 1), (2, 4), (2, 10), (2, 20), (3, 8), (5, 6), (7, 5), (7, 12)]:
        direct = attainable_ceiling(valuation_profile(p, b))
        closed = ceiling_law(p, b)
        print(f"  {p:>3} {b:>4} {float(direct):>26.18f} {float(closed):>26.18f}"
              f" {str(direct == closed):>7}")
    print()
    print("  Asymptotic ceilings pi(p) = 3p/(p^2+p+1), strictly decreasing:")
    for p in range(2, 11):
        print(f"    pi({p}) = {str(pi_limit_exact(p)):>8} = {pi_limit(p):.6f}"
              f"   (rho = {math.sqrt(pi_limit(p)):.6f})")


def demo_flatness() -> None:
    banner("2.  Flatness: tie geometry cannot produce bit-width dependence")
    c64, c72, c76 = (ceiling_law(2, b) for b in (64, 72, 76))
    print(f"  sigma^2(2,64) - 6/7 = {float(c64 - Fraction(6,7)):.6e}")
    print(f"  sigma^2(2,72) - 6/7 = {float(c72 - Fraction(6,7)):.6e}")
    print(f"  sigma^2(2,76) - 6/7 = {float(c76 - Fraction(6,7)):.6e}")
    d72_76 = c72 - c76
    d64_76 = c64 - c76
    print()
    print(f"  ceiling change 72 -> 76 : {float(d72_76):.6e}"
          f"   (positive: {d72_76 > 0}, below 1e-43: {d72_76 < Fraction(1, 10**43)})")
    print(f"  ceiling change 64 -> 76 : {float(d64_76):.6e}")
    drop = POOLED_64 - POOLED_76
    print(f"  recorded dial drop      : {float(drop):.6f}")
    ratio = drop / d64_76
    print(f"  drop / ceiling change   : {float(ratio):.3e}"
          f"   (exceeds 1e30: {ratio > 10**30})")
    print()
    print("  => the observed 0.648 -> 0.608 movement is not a tie effect.")


def demo_dominant_block() -> None:
    banner("3.  The dominant-block law: how concentrated must a profile be?")
    print("     sigma^2 >= 1 - (M^2-1)/(n^2-1) >= 1 - (M/n)^2 , for EVERY profile")
    print()
    n = 1_000_000
    print(f"  n = {n:,}")
    print(f"  {'M/n':>8} {'lower bound on rho^2':>24} {'lower bound on rho':>20}")
    for frac in (0.10, 0.25, 0.50, 0.60, 0.75, 0.79, 0.90):
        M = int(frac * n)
        lb = dominant_block_bound(M, n)
        print(f"  {frac:>8.2f} {float(lb):>24.6f} {math.sqrt(max(float(lb),0.0)):>20.6f}")
    print()
    need = required_concentration(POOLED_76)
    print(f"  To reach a ceiling of rho = {float(POOLED_76)}, a profile needs its")
    print(f"  largest class to hold at least {need:.4%} of the sample.")
    print()
    for b in (8, 16, 32, 64, 76):
        prof = valuation_profile(2, b)
        n_b = sum(prof)
        print(f"    trailing-zero profile at bit-width {b:>2}: largest class = "
              f"{max(prof) / n_b:.1%} of sample, ceiling rho^2 = "
              f"{float(attainable_ceiling(prof)):.12f}")
    print()
    print("  Balanced profiles (largest class <= 50%) always satisfy rho^2 >= 3/4:")
    print(f"    0.608^2 = {float(POOLED_76**2):.6f} < 0.75  -> excluded at every bit-width.")


def demo_response_granularity() -> None:
    banner("4.  Response granularity raises the ceiling (nested model)")

    def nested_coefficient(nested: Sequence[Sequence[int]]) -> Fraction:
        fine = [m for block in nested for m in block]
        coarse = [sum(block) for block in nested]
        n = sum(fine)
        V = Fraction(n**3 - n, 12)
        return (V - tie_correction(coarse)) / (V - tie_correction(fine))

    examples = [
        [[3, 3, 2], [4, 4], [5]],
        [[10], [10], [10], [10]],
        [[1] * 8, [4, 4], [2, 2, 2, 2]],
        [[6, 6], [1, 1, 1, 1, 1, 1]],
    ]
    print(f"  {'nested profile':>34} {'coarse ceiling':>16} {'nested ceiling':>16} {'>=':>5}")
    for nested in examples:
        coarse = [sum(block) for block in nested]
        one_sided = attainable_ceiling(coarse)
        nest = nested_coefficient(nested)
        label = str([len(b) for b in nested]) + " over " + str(coarse)
        print(f"  {label:>34} {float(one_sided):>16.8f} {float(nest):>16.8f}"
              f" {str(nest >= one_sided):>5}")
    print()
    print("  Coarsening the response never lowers the attainable coefficient,")
    print("  so response ties cannot explain an attenuated correlation.")


def demo_effective_base() -> None:
    banner("5.  The effective base of the recorded dial")
    window = (float(SEEDS_76[0]) ** 2, float(SEEDS_76[1]) ** 2)
    print(f"  squared seed window          : [{window[0]:.6f}, {window[1]:.6f}]")
    print(f"  integer bases inside window  : {unique_integer_base(window)}")
    print(f"  pi(6) = {pi_limit(6):.6f}   pi(7) = {pi_limit(7):.6f}   pi(8) = {pi_limit(8):.6f}")
    print()
    print(f"  {'observed rho':>14} {'r = rho^2':>12} {'effective base':>16} {'check pi(beta)':>16}")
    for label, rho in [("seed 1", SEEDS_76[0]), ("seed 2", SEEDS_76[1]),
                       ("seed 3", SEEDS_76[2]), ("pooled", POOLED_76),
                       ("CI low", CI_76[0]), ("CI high", CI_76[1])]:
        r = float(rho) ** 2
        beta = effective_base(r)
        print(f"  {label + ' ' + str(float(rho)):>14} {r:>12.6f} {beta:>16.6f}"
              f" {pi_limit(beta):>16.6f}")
    print()
    beta7 = effective_base(7.0 / 19.0)
    print(f"  calibration: beta(7/19) = {beta7:.12f}  (exactly 7)")
    b_pooled = effective_base(float(POOLED_76) ** 2)
    print(f"  pooled dial : beta = {b_pooled:.6f}  in (6.9, 7.05)?"
          f" {6.9 < b_pooled < 7.05}")
    print()
    print("  Self-duality  pi(x) = pi(1/x):")
    for x in (2.0, 7.0, b_pooled):
        print(f"    pi({x:.4f}) = {pi_limit(x):.10f}   pi(1/{x:.4f}) = {pi_limit(1/x):.10f}")
    print(f"    conjugate root of pi(x) = pooled^2 is 1/beta = {1.0 / b_pooled:.6f}")


def demo_corruption_budget() -> None:
    banner("6.  The corruption budget for a rank-level mechanism")
    delta = POOLED_64 - POOLED_76
    print(f"  target dial move delta = {float(delta)}")
    print(f"  {'n':>12} {'min re-ranked':>16} {'fraction':>12} {'one-swap move':>16}")
    for n in (1_000, 10_000, 100_000, 1_000_000):
        need = corruption_budget(n, delta)
        print(f"  {n:>12,} {need:>16,} {need / n:>12.4%}"
              f" {float(extremal_swap_increment(n)):>16.3e}")
    print()
    print("  The bound |delta rho| <= 6|A|/n is realised by explicit transpositions:")
    n = 12
    R = [Fraction(i) for i in range(1, n + 1)]
    S = list(R)
    S_swapped = list(R)
    S_swapped[0], S_swapped[-1] = S_swapped[-1], S_swapped[0]
    predicted = extremal_swap_increment(n)
    observed = rho_rank(R, S) - rho_rank(R, S_swapped)
    print(f"    n = {n}: extreme transposition moves rho by "
          f"{float(observed):.10f}")
    print(f"             closed form 12(n-1)/(n(n+1)) = {float(predicted):.10f}"
          f"   agree: {observed == predicted}")
    print(f"             Lipschitz bound for |A| = 2 : "
          f"{float(lipschitz_bound(n, 2)):.10f}")
    print()
    print("  Random re-ranking of a growing set, checked against the bound:")
    import random

    random.seed(20261170)
    n = 200
    R = [Fraction(i) for i in range(1, n + 1)]
    base = list(R)
    print(f"  {'|A|':>6} {'observed |d rho|':>20} {'Lipschitz bound':>20} {'valid':>7}")
    for size in (2, 10, 40, 100, 200):
        idx = random.sample(range(n), size)
        perturbed = list(base)
        vals = [perturbed[i] for i in idx]
        random.shuffle(vals)
        for i, v in zip(idx, vals):
            perturbed[i] = v
        moved = abs(rho_rank(R, base) - rho_rank(R, perturbed))
        bound = lipschitz_bound(n, size)
        print(f"  {size:>6} {float(moved):>20.10f} {float(bound):>20.10f}"
              f" {str(moved <= bound):>7}")


def main() -> None:
    demo_recorded_data()
    demo_ceiling_law()
    demo_flatness()
    demo_dominant_block()
    demo_response_granularity()
    demo_effective_base()
    demo_corruption_budget()
    banner("Summary")
    print("  * exact ceiling of the trailing-zero statistic : 6/7 in rho^2")
    print("  * flat to < 1e-43 between bit-widths 72 and 76")
    print("  * response coarsening raises, never lowers, the ceiling")
    print("  * reaching rho = 0.608 would need a tie class holding > 79% of the sample")
    print("  * effective base of the pooled dial            : ~6.97 (exactly 7 at r = 7/19)")
    print("  * corruption budget for the 0.04 drop          : >= n/150 re-ranked draws")


if __name__ == "__main__":
    main()
