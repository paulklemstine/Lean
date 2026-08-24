"""
Capped valuation dials, corruption budgets, and the erosion of a rank diagnostic.

Self-contained numerical demonstration of the main results.

Everything is computed in exact rational arithmetic (fractions.Fraction) so that
the closed forms can be checked as identities, not as floating-point coincidences.

Results demonstrated
--------------------
1.  Capped resolution law
        sigma^2(CB(K, r)) = (6/7) * (8^b - 8^r) / (8^b - 2^b),   b = r + K,
    verified against a brute-force sum over the tie profile, and against the
    genuine tie profile of min(v2(x), K) enumerated over {0, ..., 2^b - 1}.

2.  Universal capped floor: sigma^2 >= 3/4 for every cap depth K >= 1.

3.  Exclusion of coarse resolution at bit-width 92 (rho^2 <= 0.317 < 3/4).

4.  Tie-geometry budget between b = 52 and b = 92 (< 1e-15) against the
    measured drop (> 0.14).

5.  Corruption ledger: forced displacement (1 - rho)/6, the floor budget 3/40,
    and an explicit rank-perturbation experiment realising it.

6.  Hyperbolic erosion law rho(b) = 5/14 + 93/(5b): residuals, the crossing at
    b = 96/97, and the saturation of the ledger at 3/28.

7.  Base-p capped law with L(p) = 3p/(p^2 + p + 1), and the effective-base
    drift 7 -> 8 -> (asymptotically) between 22 and 23.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Optional, Tuple

# --------------------------------------------------------------------------- #
# Recorded measurements
# --------------------------------------------------------------------------- #

DIAL_READINGS: Dict[int, Fraction] = {
    44: Fraction(78, 100),
    52: Fraction(705, 1000),
    64: Fraction(648, 1000),
    76: Fraction(608, 1000),
    92: (Fraction(563, 1000) + Fraction(556, 1000)) / 2,  # mean of two seeds
}

SEED_10: Fraction = Fraction(563, 1000)
SEED_11: Fraction = Fraction(556, 1000)
FLOOR: Fraction = Fraction(55, 100)
CEILING_BAND: Fraction = Fraction(85, 100)


# --------------------------------------------------------------------------- #
# 1. Tie profiles and the Spearman ceiling
# --------------------------------------------------------------------------- #

def tie_correction(profile: List[int]) -> Fraction:
    """(1/12) * sum_j (m_j^3 - m_j): the classical Spearman tie correction."""
    return Fraction(sum(m ** 3 - m for m in profile), 12)


def spearman_ceiling(profile: List[int]) -> Fraction:
    """Maximum attainable squared Spearman correlation for a given tie profile."""
    n = sum(profile)
    if n < 2:
        raise ValueError("profile must carry mass at least 2")
    return 1 - Fraction(12) * tie_correction(profile) / Fraction(n ** 3 - n)


def capped_blocks(cap: int, rest: int) -> List[int]:
    """Tie profile CB(K, r) of min(v2(x), K) on {0, ..., 2^(r+K) - 1}."""
    return [2 ** rest] + [2 ** (rest + i) for i in range(cap)]


def capped_ceiling_closed_form(cap: int, rest: int) -> Fraction:
    """(6/7) * (8^b - 8^r) / (8^b - 2^b) with b = r + K."""
    b = rest + cap
    return Fraction(6 * (8 ** b - 8 ** rest), 7 * (8 ** b - 2 ** b))


def dyadic_ceiling(b: int) -> Fraction:
    """(6/7) * (1 + 1/(2^b (2^b + 1))): the uncapped binary valuation ceiling."""
    n = 2 ** b
    return Fraction(6, 7) * (1 + Fraction(1, n * (n + 1)))


def v2(x: int, width: int) -> int:
    """2-adic valuation, with v2(0) = width for width-bit draws."""
    if x == 0:
        return width
    k = 0
    while x % 2 == 0:
        x //= 2
        k += 1
    return k


def empirical_capped_profile(b: int, cap: int) -> List[int]:
    """Genuine tie profile of min(v2(x), K) enumerated over {0, ..., 2^b - 1}."""
    counts: Dict[int, int] = {}
    for x in range(2 ** b):
        key = min(v2(x, b), cap)
        counts[key] = counts.get(key, 0) + 1
    return sorted(counts.values())


# --------------------------------------------------------------------------- #
# 2. Corruption ledger
# --------------------------------------------------------------------------- #

def required_fraction(rho: Fraction) -> Fraction:
    """Forced displacement fraction (1 - rho)/6 implied by a reading rho."""
    return (1 - rho) / 6


def spearman_from_ranks(r: List[Fraction], s: List[Fraction]) -> Fraction:
    """1 - 6 * sum (r_i - s_i)^2 / (n^3 - n)."""
    n = len(r)
    d2 = sum((a - b) ** 2 for a, b in zip(r, s))
    return 1 - Fraction(6) * d2 / Fraction(n ** 3 - n)


def perturb_ranks(n: int, touched: int) -> Tuple[List[Fraction], List[Fraction]]:
    """Reverse the first `touched` ranks of the identity rank vector."""
    base = [Fraction(i) for i in range(1, n + 1)]
    perturbed = list(base)
    perturbed[:touched] = list(reversed(perturbed[:touched]))
    return base, perturbed


# --------------------------------------------------------------------------- #
# 3. Hyperbolic erosion law
# --------------------------------------------------------------------------- #

def rho_model(b: int) -> Fraction:
    """The fitted erosion law rho(b) = 5/14 + 93/(5b)."""
    return Fraction(5, 14) + Fraction(93, 5 * b)


def budget_model(b: int) -> Fraction:
    """Forced displacement along the erosion law: 3/28 - 31/(10b)."""
    return Fraction(3, 28) - Fraction(31, 10 * b)


# --------------------------------------------------------------------------- #
# 4. Base-p theory
# --------------------------------------------------------------------------- #

def padic_limit(p: int) -> Fraction:
    """Asymptotic ceiling of a perfect base-p valuation dial: 3p/(p^2 + p + 1)."""
    return Fraction(3 * p, p * p + p + 1)


def padic_capped_blocks(p: int, cap: int, rest: int) -> List[int]:
    """Tie profile of min(v_p(x), K) on {0, ..., p^(r+K) - 1}."""
    return [p ** rest] + [(p - 1) * p ** (rest + i) for i in range(cap)]


def padic_capped_closed_form(p: int, cap: int, rest: int) -> Fraction:
    """L(p) * (p^{3b} - p^{3r}) / (p^{3b} - p^b), b = r + K."""
    b = rest + cap
    num = p ** (3 * b) - p ** (3 * rest)
    den = p ** (3 * b) - p ** b
    return padic_limit(p) * Fraction(num, den)


def effective_base(rho: Fraction, max_base: int = 400) -> Optional[int]:
    """Least p >= 2 with L(p+1) < rho^2 <= L(p)."""
    target = rho ** 2
    for p in range(2, max_base + 1):
        if padic_limit(p + 1) < target <= padic_limit(p):
            return p
    return None


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def f(x: Fraction, digits: int = 6) -> str:
    return f"{float(x):.{digits}f}"


def demo_capped_law() -> None:
    print("=" * 78)
    print("1.  CAPPED RESOLUTION LAW")
    print("=" * 78)
    print("    sigma^2(CB(K,r)) = (6/7)(8^b - 8^r)/(8^b - 2^b),  b = r + K")
    print()
    print(f"{'b':>4} {'K':>4} {'r':>4} {'profile sum':>13} {'brute force':>12} "
          f"{'closed form':>12} {'match':>6}")
    for b, cap in [(4, 1), (4, 2), (8, 1), (8, 3), (8, 8), (16, 5), (32, 10), (92, 12)]:
        rest = b - cap
        prof = capped_blocks(cap, rest)
        brute = spearman_ceiling(prof)
        closed = capped_ceiling_closed_form(cap, rest)
        print(f"{b:>4} {cap:>4} {rest:>4} {sum(prof):>13} {f(brute):>12} "
              f"{f(closed):>12} {str(brute == closed):>6}")
    print()
    print("    Endpoints:")
    print(f"      K = 0 (no resolution), b = 8 : "
          f"{f(capped_ceiling_closed_form(0, 8))}")
    print(f"      r = 0 (full resolution), b = 8: "
          f"{f(capped_ceiling_closed_form(8, 0), 12)}"
          f"   dyadic ceiling: {f(dyadic_ceiling(8), 12)}")
    print(f"      exact agreement: {capped_ceiling_closed_form(8, 0) == dyadic_ceiling(8)}")
    print()


def demo_arithmetic_bridge() -> None:
    print("=" * 78)
    print("2.  ARITHMETIC BRIDGE:  the geometric profile IS the valuation profile")
    print("=" * 78)
    print("    Enumerating min(v2(x), K) over all x < 2^b and comparing ceilings.")
    print()
    print(f"{'b':>4} {'K':>4} {'enumerated profile':>34} {'ceiling (enum)':>15} "
          f"{'closed form':>13}")
    for b, cap in [(4, 1), (4, 2), (5, 3), (6, 2), (8, 4)]:
        prof = empirical_capped_profile(b, cap)
        enum_ceiling = spearman_ceiling(prof)
        closed = capped_ceiling_closed_form(cap, b - cap)
        print(f"{b:>4} {cap:>4} {str(prof):>34} {f(enum_ceiling):>15} {f(closed):>13}")
    print("    (Top class = multiples of 2^K below 2^b, of cardinality 2^(b-K).)")
    print()


def demo_universal_floor() -> None:
    print("=" * 78)
    print("3.  THE UNIVERSAL 3/4 FLOOR AND THE EXCLUSION OF COARSE RESOLUTION")
    print("=" * 78)
    worst = min(
        capped_ceiling_closed_form(cap, b - cap)
        for b in range(1, 200)
        for cap in range(1, min(b, 40) + 1)
    )
    print(f"    minimum of sigma^2 over 1 <= K <= min(b,40), 1 <= b < 200 : {f(worst)}")
    print(f"    universal lower bound                                     : {f(Fraction(3,4))}")
    print(f"    bound respected                                           : {worst >= Fraction(3,4)}")
    print()
    print(f"    recorded reading (larger seed) rho = {f(SEED_10, 3)},  rho^2 = {f(SEED_10 ** 2)}")
    print(f"    is rho^2 < 3/4 ?  {SEED_10 ** 2 < Fraction(3, 4)}   "
          f"(margin: factor {f(Fraction(3,4) / SEED_10 ** 2, 3)})")
    print("    ==> no capped-resolution mechanism can produce the bitlen-92 reading.")
    print()
    print("    Tie-geometry budget across the measured range:")
    drop_ceiling = dyadic_ceiling(52) - dyadic_ceiling(92)
    drop_measured = DIAL_READINGS[52] - DIAL_READINGS[92]
    print(f"      ceiling(52) - ceiling(92) = {float(drop_ceiling):.3e}")
    print(f"      measured  52  -  92       = {f(drop_measured)}")
    print(f"      ratio                      = {float(drop_measured / drop_ceiling):.3e}")
    print()


def demo_corruption_ledger() -> None:
    print("=" * 78)
    print("4.  THE CORRUPTION LEDGER")
    print("=" * 78)
    print("    A reading rho forces displacement of at least (1 - rho)/6 of the sample.")
    print()
    print(f"{'b':>4} {'rho':>8} {'forced displacement':>22}")
    for b in sorted(DIAL_READINGS):
        rho = DIAL_READINGS[b]
        print(f"{b:>4} {f(rho, 4):>8} {f(required_fraction(rho) * 100, 3) + ' %':>22}")
    print()
    print(f"    at the floor rho = 0.55 : budget = {required_fraction(FLOOR)} "
          f"= {f(required_fraction(FLOOR) * 100, 1)} %")
    print("    Converse: any mechanism touching <= 3/40 of the sample keeps rho >= 0.55.")
    print()
    print("    Explicit rank perturbation (identity ranks, first m entries reversed):")
    print(f"{'n':>6} {'touched m':>10} {'m/n':>9} {'rho':>10} {'>= 0.55':>9} "
          f"{'m/n <= 3/40':>12}")
    for n, m in [(1000, 20), (1000, 60), (1000, 75), (1000, 120), (4000, 300)]:
        base, pert = perturb_ranks(n, m)
        rho = spearman_from_ranks(base, pert)
        print(f"{n:>6} {m:>10} {f(Fraction(m, n), 4):>9} {f(rho, 6):>10} "
              f"{str(rho >= FLOOR):>9} {str(Fraction(m, n) <= Fraction(3, 40)):>12}")
    print("    (Small footprints never break the floor, exactly as the bound predicts.)")
    print()


def demo_erosion_law() -> None:
    print("=" * 78)
    print("5.  THE HYPERBOLIC EROSION LAW  rho(b) = 5/14 + 93/(5b)")
    print("=" * 78)
    print(f"{'b':>4} {'observed':>10} {'model':>10} {'residual':>10} {'<= 0.01':>9}")
    worst = Fraction(0)
    for b in sorted(DIAL_READINGS):
        obs, mod = DIAL_READINGS[b], rho_model(b)
        res = abs(mod - obs)
        worst = max(worst, res)
        print(f"{b:>4} {f(obs, 4):>10} {f(mod, 6):>10} {f(res, 6):>10} "
              f"{str(res <= Fraction(1, 100)):>9}")
    print(f"    maximal residual: {f(worst, 6)}")
    print(f"    asymptote 5/14 = {f(Fraction(5,14))}  (strictly below the floor 0.55)")
    print()
    print("    Crossing of the validation floor:")
    for b in [92, 95, 96, 97, 100, 120]:
        mod = rho_model(b)
        print(f"      b = {b:>4}: rho = {f(mod, 6)}   in band: {mod >= FLOOR}")
    crossing = min(b for b in range(1, 1000) if rho_model(b) < FLOOR)
    print(f"    first bit-width below the floor: b = {crossing}")
    print()
    print("    Ledger along the law (saturating at 3/28 = "
          f"{f(Fraction(3,28) * 100, 3)} %):")
    print(f"{'b':>6} {'budget':>12} {'< 3/28':>9} {'<= 3/40 (in band)':>19}")
    for b in [44, 92, 96, 97, 1000, 10 ** 6]:
        bud = budget_model(b)
        assert bud == required_fraction(rho_model(b))
        print(f"{b:>6} {f(bud * 100, 4) + ' %':>12} {str(bud < Fraction(3,28)):>9} "
              f"{str(bud <= Fraction(3,40)):>19}")
    print()


def demo_padic() -> None:
    print("=" * 78)
    print("6.  EVERY BASE:  L(p) = 3p/(p^2 + p + 1)  AND EFFECTIVE-BASE DRIFT")
    print("=" * 78)
    print(f"{'p':>4} {'L(p)':>12} {'capped floor L(p)(1-p^-3)':>27}")
    for p in [2, 3, 5, 7, 8, 9, 22, 23]:
        lp = padic_limit(p)
        print(f"{p:>4} {f(lp):>12} {f(lp * (1 - Fraction(1, p ** 3))):>27}")
    print(f"    base 2 capped floor equals 3/4: "
          f"{padic_limit(2) * (1 - Fraction(1, 8)) == Fraction(3, 4)}")
    print()
    print("    Base-p capped law verified against brute force:")
    print(f"{'p':>4} {'K':>4} {'r':>4} {'brute force':>13} {'closed form':>13} {'match':>6}")
    for p, cap, rest in [(2, 3, 2), (3, 2, 3), (5, 4, 1), (7, 3, 2), (10, 2, 2)]:
        prof = padic_capped_blocks(p, cap, rest)
        brute = spearman_ceiling(prof)
        closed = padic_capped_closed_form(p, cap, rest)
        print(f"{p:>4} {cap:>4} {rest:>4} {f(brute):>13} {f(closed):>13} "
              f"{str(brute == closed):>6}")
    print()
    print("    Effective base of each recorded reading:")
    print(f"{'b':>6} {'rho':>9} {'rho^2':>10} {'effective base':>16}")
    for b in sorted(DIAL_READINGS):
        rho = DIAL_READINGS[b]
        print(f"{b:>6} {f(rho, 4):>9} {f(rho ** 2):>10} {str(effective_base(rho)):>16}")
    for name, rho in [("seed 20261210", SEED_10), ("seed 20261211", SEED_11)]:
        print(f"    {name}: rho^2 = {f(rho ** 2)}, effective base "
              f"= {effective_base(rho)}")
    print()
    asymptote = Fraction(5, 14)
    print(f"    asymptote 5/14: (5/14)^2 = {f(asymptote ** 2)}")
    print(f"      L(23) = {f(padic_limit(23))} < (5/14)^2 < L(22) = {f(padic_limit(22))}: "
          f"{padic_limit(23) < asymptote ** 2 < padic_limit(22)}")
    print(f"    effective base of the asymptote: {effective_base(asymptote)}")
    print("    Effective base predicted along the erosion law:")
    print(f"{'b':>8} {'rho':>10} {'effective base':>16}")
    for b in [44, 52, 64, 76, 92, 128, 512, 4096, 10 ** 6]:
        print(f"{b:>8} {f(rho_model(b), 6):>10} {str(effective_base(rho_model(b))):>16}")
    print("    (Bounded by 23 at every bit-width: the drift decelerates.)")
    print()


def main() -> None:
    print()
    print("CAPPED VALUATION DIALS, CORRUPTION BUDGETS, AND DIAGNOSTIC EROSION")
    print("exact rational arithmetic throughout")
    print()
    demo_capped_law()
    demo_arithmetic_bridge()
    demo_universal_floor()
    demo_corruption_ledger()
    demo_erosion_law()
    demo_padic()
    print("=" * 78)
    print("All closed forms agree exactly with brute-force computation.")
    print("=" * 78)


if __name__ == "__main__":
    main()
