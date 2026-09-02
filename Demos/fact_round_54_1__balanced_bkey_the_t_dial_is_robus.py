#!/usr/bin/env python3
"""
Numerical demonstration of the tie-attenuation theory of the capped
trailing-zero dial T_u(x) = min(v2(x), u) on b-bit key spaces.

Everything is computed in exact rational arithmetic (fractions.Fraction) and
only converted to floating point for display.

Results demonstrated
--------------------
1.  Arithmetic bridge:  the capped tie profile [2^(b-1), ..., 2^(b-u), 2^(b-u)]
    is literally the census of min(v2(x), u) on {0, ..., 2^b - 1}.
2.  Separation law:     rho^2(b,u) = (6/7)(1 - 8^-u)(1 + 1/(4^b - 1)).
3.  Rank-one law:       every 2x2 minor of the ceiling table vanishes exactly.
4.  Bit-length insensitivity:  |rho^2(b,u) - rho^2(b',u)| < 2 * 4^-b.
5.  Mass-fraction floor:  modal mass a < 1  =>  rho^2 > 1 - a^2;
    balanced (a <= 1/2)   =>  rho^2 > 3/4, rho > 0.866;
    sharpness: the profile [15, 1] reads rho = 0.4201 < 0.53.
6.  Coarsening law:     merging tie classes never raises the ceiling, and
    lowering the cap by one is exactly such a merge.
7.  Gap law:            rho^2(b,u) - rho^2(b,1) >= 3/32, but
    rho(b,u) - rho(b,1) < 0.07, with supremum sqrt(6/7) - sqrt(3/4).
8.  Attribution audit:  a recorded advantage of 0.10 forces >= 0.03 of slack
    in the bare-count reading.
9.  Balanced keys:      binomial profile C(b-1-k, w-1), hockey-stick sum,
    modal fraction w/b, two-sided pin at w = b/2.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, sqrt
from typing import Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core calculus: tie profiles and the tie ceiling
# ----------------------------------------------------------------------------


def tie_correction(profile: Sequence[int]) -> Fraction:
    """Kendall tie correction  T(L) = (1/12) * sum_i (m_i^3 - m_i)."""
    return Fraction(sum(m**3 - m for m in profile), 12)


def ceiling_sq(profile: Sequence[int]) -> Fraction:
    """Exact tie ceiling rho^2(L) = 1 - sum(m^3 - m) / (n^3 - n)."""
    n = sum(profile)
    if n < 2:
        raise ValueError("a tie ceiling needs at least two observations")
    return Fraction(1) - Fraction(sum(m**3 - m for m in profile), n**3 - n)


def ceiling(profile: Sequence[int]) -> float:
    """Tie ceiling rho(L), as a float."""
    return sqrt(float(ceiling_sq(profile)))


def modal_mass(profile: Sequence[int]) -> Fraction:
    """Fraction of the sample carried by the largest tie class."""
    return Fraction(max(profile), sum(profile))


# ----------------------------------------------------------------------------
# The two-knob family: capped trailing-zero profiles
# ----------------------------------------------------------------------------


def cap_blocks(u: int, b: int) -> List[int]:
    """Tie profile of T_u on {0, ..., 2^b - 1}, for 0 <= u <= b."""
    if not 0 <= u <= b:
        raise ValueError("require 0 <= u <= b")
    if u == 0:
        return [2**b]
    return [2 ** (b - 1 - k) for k in range(u)] + [2 ** (b - u)]


def v2(x: int) -> int:
    """2-adic valuation; v2(0) is taken as +infinity, encoded as a large int."""
    if x == 0:
        return 1 << 30
    return (x & -x).bit_length() - 1


def census_profile(u: int, b: int) -> List[int]:
    """Brute-force census of min(v2(x), u) over x < 2^b (audit; O(2^b))."""
    counts: Dict[int, int] = {}
    for x in range(2**b):
        t = min(v2(x), u)
        counts[t] = counts.get(t, 0) + 1
    return [counts[k] for k in sorted(counts)]


def separation_formula(b: int, u: int) -> Fraction:
    """(6/7) * (1 - 8^-u) * (1 + 1/(4^b - 1))."""
    cap = Fraction(6, 7) * (Fraction(1) - Fraction(1, 8**u))
    bit = Fraction(1) + Fraction(1, 4**b - 1)
    return cap * bit


# ----------------------------------------------------------------------------
# Balanced (fixed Hamming weight) key laws
# ----------------------------------------------------------------------------


def weight_blocks(b: int, w: int) -> List[int]:
    """Tie profile of the trailing-zero statistic on weight-w b-bit keys."""
    if not 1 <= w <= b:
        raise ValueError("require 1 <= w <= b")
    return [comb(b - 1 - k, w - 1) for k in range(b - w + 1)]


def weight_census(b: int, w: int) -> List[int]:
    """Brute-force census of the lowest-set-bit position on weight-w keys."""
    counts: Dict[int, int] = {}
    for x in range(1, 2**b):
        if bin(x).count("1") != w:
            continue
        k = v2(x)
        counts[k] = counts.get(k, 0) + 1
    return [counts[k] for k in sorted(counts)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_bridge() -> None:
    rule("1. Arithmetic bridge: the capped profile IS the valuation census")
    for b in (4, 6, 8):
        for u in range(1, min(b, 4) + 1):
            built = cap_blocks(u, b)
            seen = sorted(census_profile(u, b), reverse=True)
            ok = sorted(built, reverse=True) == seen
            print(f"  b={b:2d} u={u}:  profile {built}  sum={sum(built)}  "
                  f"census match: {ok}")


def demo_separation() -> None:
    rule("2. Separation law:  rho^2(b,u) = (6/7)(1 - 8^-u)(1 + 1/(4^b - 1))")
    print(f"  {'b':>3} {'u':>3} {'rho^2 (exact)':>28} {'formula matches':>16}"
          f" {'rho':>10}")
    for b in (8, 16, 32, 64):
        for u in (1, 2, 3, 4, 6, 8):
            if u > b:
                continue
            exact = ceiling_sq(cap_blocks(u, b))
            match = exact == separation_formula(b, u)
            shown = f"{float(exact):.12f}"
            print(f"  {b:>3} {u:>3} {shown:>28} {str(match):>16} "
                  f"{sqrt(float(exact)):>10.6f}")
    print(f"\n  saturation as u -> infinity:  sqrt(6/7)  = {sqrt(6/7):.6f}")
    print(f"  bare count (u = 1):           sqrt(3/4)  = {sqrt(3/4):.6f}")


def demo_rank_one() -> None:
    rule("3. Rank-one law: every 2x2 minor of the ceiling table vanishes")
    bs = [8, 16, 32, 64]
    us = [1, 2, 3, 4, 6, 8]
    table = {(b, u): ceiling_sq(cap_blocks(u, b)) for b in bs for u in us}
    worst = Fraction(0)
    for i, b in enumerate(bs):
        for bp in bs[i + 1:]:
            for j, u in enumerate(us):
                for up in us[j + 1:]:
                    minor = (table[(b, u)] * table[(bp, up)]
                             - table[(b, up)] * table[(bp, u)])
                    worst = max(worst, abs(minor))
    print(f"  checked all 2x2 minors over b in {bs}, u in {us}")
    print(f"  largest |minor| in exact rational arithmetic: {worst}")
    print("  => the ceiling table is exactly rank one: no knob interaction.")
    r0 = [table[(bs[0], u)] for u in us]
    for b in bs[1:]:
        ratios = {table[(b, u)] / r0[j] for j, u in enumerate(us)}
        print(f"  row b={b:2d} / row b={bs[0]}: {len(ratios)} distinct ratio(s) "
              f"= {float(next(iter(ratios))):.12f}")


def demo_insensitivity() -> None:
    rule("4. Bit-length insensitivity:  |rho^2(b,u) - rho^2(b',u)| < 2 * 4^-b")
    for b, bp in ((8, 16), (16, 32), (32, 64)):
        worst = max(abs(ceiling_sq(cap_blocks(u, b))
                        - ceiling_sq(cap_blocks(u, bp)))
                    for u in range(1, b + 1))
        bound = Fraction(2, 4**b)
        print(f"  b={b:2d} -> b'={bp:2d}:  max over u of |delta| = "
              f"{float(worst):.3e}   bound 2*4^-b = {float(bound):.3e}   "
              f"holds: {worst < bound}")


def demo_floor() -> None:
    rule("5. Floor laws: modal mass a  =>  rho^2 > 1 - a^2")
    print("  profile                          modal a      1 - a^2     rho^2"
          "      rho")
    examples: List[Tuple[str, List[int]]] = [
        ("cap_blocks(1, 8)  [parity]", cap_blocks(1, 8)),
        ("cap_blocks(4, 8)", cap_blocks(4, 8)),
        ("cap_blocks(8, 8)  [uncapped]", cap_blocks(8, 8)),
        ("weight_blocks(8, 4) [balanced]", weight_blocks(8, 4)),
        ("[15, 1]  (majority block)", [15, 1]),
        ("[848, 152] (near cliff)", [848, 152]),
        ("[900, 100] (past cliff)", [900, 100]),
    ]
    for name, prof in examples:
        a = modal_mass(prof)
        rs = ceiling_sq(prof)
        print(f"  {name:<32} {float(a):>7.4f} {float(1 - a * a):>11.6f} "
              f"{float(rs):>10.6f} {sqrt(float(rs)):>8.6f}")
    print("\n  balanced statistics (a <= 1/2) all satisfy rho > sqrt(3/4) = "
          f"{sqrt(0.75):.6f} > 0.53")
    print("  the cliff for the 0.53 floor is bracketed into a in [0.848, 0.938]:")
    for a_pct in (840, 847, 848, 900, 937, 938, 950):
        a = Fraction(a_pct, 1000)
        n = 100000
        prof = [int(a * n), n - int(a * n)]
        print(f"    a={float(a):.3f}: two-block ceiling rho = "
              f"{ceiling(prof):.6f}   certified bound sqrt(1-a^2) = "
              f"{sqrt(1 - float(a) ** 2):.6f}")


def demo_coarsening() -> None:
    rule("6. Coarsening law: merging tie classes never raises the ceiling")
    b = 10
    print(f"  b = {b}: lowering the cap merges the last two classes")
    for u in range(b, 0, -1):
        prof = cap_blocks(u, b)
        print(f"    u={u:2d}: {str(prof):<44} rho = {ceiling(prof):.6f}")
    print("\n  a generic merge:")
    for prof in ([9, 7, 5, 3], [16, 5, 3], [21, 3], [24]):
        n = sum(prof)
        r = ceiling(prof) if n >= 2 else 0.0
        print(f"    {str(prof):<20} n={n}  rho = {r:.6f}")


def demo_gap() -> None:
    rule("7. Gap law: >= 3/32 in rho^2, but < 0.07 in rho")
    print(f"  {'b':>3} {'u':>3} {'gap in rho^2':>16} {'>= 3/32':>9} "
          f"{'gap in rho':>12} {'< 0.07':>8}")
    worst = 0.0
    for b in (8, 16, 32, 64):
        for u in (2, 3, 4, 8):
            if u > b:
                continue
            g2 = ceiling_sq(cap_blocks(u, b)) - ceiling_sq(cap_blocks(1, b))
            g = ceiling(cap_blocks(u, b)) - ceiling(cap_blocks(1, b))
            worst = max(worst, g)
            print(f"  {b:>3} {u:>3} {float(g2):>16.6f} "
                  f"{str(g2 >= Fraction(3, 32)):>9} {g:>12.6f} "
                  f"{str(g < 0.07):>8}")
    print(f"\n  largest observed gap in rho: {worst:.6f}")
    print(f"  theoretical supremum sqrt(6/7) - sqrt(3/4) = "
          f"{sqrt(6 / 7) - sqrt(3 / 4):.6f}")


def demo_attribution() -> None:
    rule("8. Attribution audit: a recorded 0.10-0.15 advantage forces slack")
    for (b, u, r_t, r_c) in ((32, 4, 0.66, 0.56), (32, 4, 0.70, 0.55),
                             (64, 8, 0.62, 0.47)):
        cap_ceiling = ceiling(cap_blocks(u, b))
        cnt_ceiling = ceiling(cap_blocks(1, b))
        capacity_gap = cap_ceiling - cnt_ceiling
        observed = r_t - r_c
        forced = observed - capacity_gap
        print(f"  cell (b={b}, u={u}):  ceilings  T={cap_ceiling:.6f}  "
              f"count={cnt_ceiling:.6f}")
        print(f"    capacity gap available from tie resolution: "
              f"{capacity_gap:.6f}")
        print(f"    observed advantage r_T - r_C = {observed:.4f}"
              f"  -> forced slack in the bare-count reading >= {forced:.4f}")
        print(f"    bare count reads {r_c:.4f}, i.e. "
              f"{cnt_ceiling - r_c:.4f} below its own ceiling\n")


def demo_balanced_keys() -> None:
    rule("9. Balanced keys (fixed Hamming weight): binomial profiles")
    print("  hockey stick, modal fraction w/b, and the floor:")
    for b, w in ((8, 2), (8, 4), (12, 6), (16, 8), (20, 7), (20, 10)):
        prof = weight_blocks(b, w)
        total = sum(prof)
        print(f"  b={b:2d} w={w:2d}: profile {str(prof[:6]) + ('...' if len(prof) > 6 else ''):<34}"
              f" sum={total:<7} C(b,w)={comb(b, w):<7} "
              f"modal={float(modal_mass(prof)):.4f} (w/b={w / b:.4f}) "
              f"rho={ceiling(prof):.6f}")
    print("\n  census audit for small b (lowest set bit of weight-w keys):")
    for b, w in ((8, 3), (10, 5)):
        built = weight_blocks(b, w)
        seen = weight_census(b, w)
        print(f"    b={b} w={w}: built {built}")
        print(f"              census {seen}   match: {built == seen}")
    print("\n  two-sided pin at w = b/2  (3/4 < rho^2 <= 7/8 + 7/(8(n^2-1))):")
    for v in range(2, 9):
        prof = weight_blocks(2 * v, v)
        n = sum(prof)
        rs = ceiling_sq(prof)
        upper = Fraction(7, 8) + Fraction(7, 8 * (n * n - 1))
        print(f"    b={2 * v:2d} w={v:2d}: n={n:<7} rho^2={float(rs):.6f}  "
              f"in (0.75, {float(upper):.6f}]: "
              f"{Fraction(3, 4) < rs <= upper}   rho={sqrt(float(rs)):.6f}")
    print("\n  law-change capacity |rho(balanced) - rho(uniform)| < 0.07:")
    for v in range(2, 9):
        bal = ceiling(weight_blocks(2 * v, v))
        uni = ceiling(cap_blocks(2 * v, 2 * v))
        print(f"    b={2 * v:2d}: balanced {bal:.6f}   uniform {uni:.6f}   "
              f"|diff| = {abs(bal - uni):.6f}   < 0.07: "
              f"{abs(bal - uni) < 0.07}")


def main() -> None:
    print(__doc__)
    demo_bridge()
    demo_separation()
    demo_rank_one()
    demo_insensitivity()
    demo_floor()
    demo_coarsening()
    demo_gap()
    demo_attribution()
    demo_balanced_keys()
    rule("Summary")
    print("  * the ceiling factorises over (bitlen, cap): no interaction;")
    print("  * every balanced statistic has capacity above 0.866 > 0.53;")
    print("  * tie resolution buys at most 0.0598 in rho, so a recorded")
    print("    0.10-0.15 advantage is not a granularity artefact.")


if __name__ == "__main__":
    main()
