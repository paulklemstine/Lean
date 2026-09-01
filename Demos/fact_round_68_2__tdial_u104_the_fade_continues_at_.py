#!/usr/bin/env python3
"""
Fading correlation ladders: floors, extinction, non-identifiability, and the
contraction audit.

Self-contained numerical demonstration of the results in the accompanying paper.
Everything is computed in exact rational arithmetic (fractions.Fraction) so that
each printed verdict is a genuine arithmetic fact, not a floating-point artefact.

The recorded ladder is the Spearman rank correlation between the trailing-zero
statistic T(x) = nu_2(x) of a uniformly drawn b-bit integer and a downstream
response, measured on the four-bit grid b = 96, 100, ..., 120:

    0.5739, 0.5436, 0.5005, 0.4880, 0.4621, 0.4847, 0.43636

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------- #
# The recorded data
# --------------------------------------------------------------------------- #

#: Rungs of the recorded ladder, indexed by k with bit-length b = 96 + 4k.
#: Rungs 0 and 1 are reconstructed from the reported step sizes -0.030, -0.043;
#: rung 2 (pooled 0.5005) and its three seeds are the recorded measurement of
#: this cycle; rungs 3..6 are later readings used for out-of-sample scoring.
REC_RUNGS: List[Fraction] = [
    Fraction(5739, 10000),   # b =  96  (reconstructed)
    Fraction(5436, 10000),   # b = 100  (reconstructed)
    Fraction(5005, 10000),   # b = 104  (recorded, pooled)
    Fraction(4880, 10000),   # b = 108
    Fraction(4621, 10000),   # b = 112
    Fraction(4847, 10000),   # b = 116  (rebound)
    Fraction(43636, 100000), # b = 120
]

#: Bit-length of rung k.
def bitlen(k: int) -> int:
    """Bit-length corresponding to ladder rung ``k`` (four-bit grid from 96)."""
    return 96 + 4 * k


#: The three seeds pooled into the bitlen-104 reading, and the interval.
SEEDS_104: Dict[int, Fraction] = {
    20261210: Fraction(493, 1000),
    20261211: Fraction(499, 1000),
    20261212: Fraction(509, 1000),
}
POOLED_104: Fraction = Fraction(500, 1000)
CI_104: Tuple[Fraction, Fraction] = (Fraction(456, 1000), Fraction(545, 1000))


# --------------------------------------------------------------------------- #
# Ladders and decrements
# --------------------------------------------------------------------------- #

def decrements(rungs: Sequence[Fraction]) -> List[Fraction]:
    """Return d_k = rho_k - rho_{k+1} for a finite ladder."""
    return [rungs[k] - rungs[k + 1] for k in range(len(rungs) - 1)]


def ladder_from_decrements(rho0: Fraction, d: Sequence[Fraction]) -> List[Fraction]:
    """Rebuild rho_0, ..., rho_n from a start value and its decrement sequence."""
    out = [rho0]
    for dk in d:
        out.append(out[-1] - dk)
    return out


def second_differences(rungs: Sequence[Fraction]) -> List[Fraction]:
    """Grid second differences (d_k - d_{k+1}); positive means deceleration."""
    d = decrements(rungs)
    return [d[k] - d[k + 1] for k in range(len(d) - 1)]


# --------------------------------------------------------------------------- #
# 1. The contraction audit
# --------------------------------------------------------------------------- #

def empirical_contraction_factor(rungs: Sequence[Fraction]) -> Tuple[Fraction, int]:
    """
    Least q with |d_{k+1}| <= q |d_k| for all consecutive recorded pairs.

    Returns (q_star, argmax_index).  Raises ValueError on a zero decrement.
    """
    d = decrements(rungs)
    best: Optional[Fraction] = None
    arg = -1
    for k in range(len(d) - 1):
        if d[k] == 0:
            raise ValueError(f"decrement d_{k} vanishes; ratio undefined")
        r = abs(d[k + 1]) / abs(d[k])
        if best is None or r > best:
            best, arg = r, k
    assert best is not None
    return best, arg


def contraction_audit(rungs: Sequence[Fraction]) -> None:
    """Print the full contraction audit of a ladder."""
    d = decrements(rungs)
    print("  k   bitlen    rho_k        d_k          |d_{k+1}|/|d_k|")
    print("  " + "-" * 58)
    for k, r in enumerate(rungs):
        dk = f"{float(d[k]):+.5f}" if k < len(d) else "     --  "
        if k < len(d) - 1 and d[k] != 0:
            ratio = f"{float(abs(d[k + 1]) / abs(d[k])):.4f}"
        else:
            ratio = "  --"
        print(f"  {k}   {bitlen(k):>6}   {float(r):.5f}    {dk}      {ratio:>8}")
    q_star, arg = empirical_contraction_factor(rungs)
    print()
    print(f"  empirical contraction factor q* = {q_star} = {float(q_star):.5f}")
    print(f"  attained at k = {arg}  (bitlen {bitlen(arg)} -> {bitlen(arg + 2)})")
    verdict = "CONTRACTIVE" if q_star < 1 else "NOT contractive"
    print(f"  verdict: {verdict}   (q* < 1 required for a tail-bound certificate)")


# --------------------------------------------------------------------------- #
# 2. The tail bound and the certified floor
# --------------------------------------------------------------------------- #

def tail_bound(d_n: Fraction, q: Fraction) -> Fraction:
    """|rho_{n+m} - rho_n| <= |d_n| / (1 - q) for every m, when 0 <= q < 1."""
    if not (0 <= q < 1):
        raise ValueError("tail bound requires 0 <= q < 1")
    return abs(d_n) / (1 - q)


def certified_floor(rho_n: Fraction, d_n: Fraction, q: Fraction) -> Fraction:
    """Explicit floor rho_n - |d_n|/(1-q) valid for every later rung."""
    return rho_n - tail_bound(d_n, q)


def geometric_ladder(rho0: Fraction, d0: Fraction, q: Fraction, n: int) -> List[Fraction]:
    """The exactly q-geometric ladder: the extremal case of the tail bound."""
    out, d = [rho0], d0
    for _ in range(n):
        out.append(out[-1] - d)
        d = d * q
    return out


# --------------------------------------------------------------------------- #
# 3. The harmonic trap
# --------------------------------------------------------------------------- #

def harmonic(n: int) -> Fraction:
    """Exact harmonic number H_n = 1 + 1/2 + ... + 1/n (H_0 = 0)."""
    total = Fraction(0)
    for k in range(1, n + 1):
        total += Fraction(1, k)
    return total


def harmonic_fade(rho0: Fraction, c: Fraction, n: int) -> Fraction:
    """Ladder with decrements d_k = c/(k+1): value rho_0 - c*H_n after n steps."""
    return rho0 - c * harmonic(n)


def harmonic_dyadic_bracket(m: int) -> Tuple[Fraction, Fraction]:
    """The classical bracket 1 + m/2 <= H_{2^m} <= 1 + m."""
    return Fraction(2 + m, 2), Fraction(1 + m)


def harmonic_extinction_rung(rho0: Fraction, c: Fraction) -> int:
    """
    Smallest m with 1 + m/2 >= rho_0/c, so the harmonic fade is provably
    extinguished by step 2**m.
    """
    m = 0
    while harmonic_dyadic_bracket(m)[0] * c < rho0:
        m += 1
    return m


# --------------------------------------------------------------------------- #
# 4. Non-identifiability: two continuations of the same past
# --------------------------------------------------------------------------- #

def cont_floor(observed: Sequence[Fraction], k: int) -> Fraction:
    """Floor continuation: (g_N/2)(1 + 2^{-(k-N)}) beyond the last observation."""
    N = len(observed) - 1
    if k <= N:
        return observed[k]
    return (observed[N] / 2) * (1 + Fraction(1, 2) ** (k - N))


def cont_death(observed: Sequence[Fraction], k: int) -> Fraction:
    """Extinction continuation: linear to exactly zero at rung N + 10."""
    N = len(observed) - 1
    if k <= N:
        return observed[k]
    return observed[N] - Fraction(k - N) * (observed[N] / 10)


def identification_gap(observed: Sequence[Fraction], horizon: int) -> List[Tuple[int, Fraction, Fraction, Fraction]]:
    """
    (k, death, floor, separation) for k from N to N + horizon, where the
    separation is |floor - death|.  The two continuations cross early (the
    floor continuation drops faster at first, then levels off), so the signed
    difference is not monotone; the separation is what a discriminating
    measurement must resolve.
    """
    N = len(observed) - 1
    rows = []
    for k in range(N, N + horizon + 1):
        lo, hi = cont_death(observed, k), cont_floor(observed, k)
        rows.append((k, lo, hi, abs(hi - lo)))
    return rows


# --------------------------------------------------------------------------- #
# 5. Curvature: convex laws decelerate
# --------------------------------------------------------------------------- #

def hyperbolic_second_difference(A: Fraction, C: Fraction, b: int) -> Tuple[Fraction, Fraction]:
    """
    For h(b) = A + C/b, return (direct second difference, closed form
    32C/(b(b+4)(b+8))).  The two must agree exactly.
    """
    def h(x: int) -> Fraction:
        return A + C / Fraction(x)
    direct = (h(b) - h(b + 4)) - (h(b + 4) - h(b + 8))
    closed = 32 * C / Fraction(b * (b + 4) * (b + 8))
    return direct, closed


def geometric_second_difference(A: Fraction, C: Fraction, q: Fraction, b: int) -> Tuple[Fraction, Fraction]:
    """
    For g(b) = A + C q^b, return (direct second difference, closed form
    C q^b (1 - q^4)^2).  The two must agree exactly.
    """
    def g(x: int) -> Fraction:
        return A + C * q ** x
    direct = (g(b) - g(b + 4)) - (g(b + 4) - g(b + 8))
    closed = C * q ** b * (1 - q ** 4) ** 2
    return direct, closed


# --------------------------------------------------------------------------- #
# 6. Secant extrapolation (a forecast, not a theorem)
# --------------------------------------------------------------------------- #

def secant_zero(b1: int, r1: Fraction, b2: int, r2: Fraction) -> Fraction:
    """Bit-length at which the straight line through (b1,r1),(b2,r2) reaches 0."""
    if r1 == r2:
        raise ValueError("horizontal secant never reaches zero")
    slope = (r2 - r1) / Fraction(b2 - b1)
    return Fraction(b1) - r1 / slope


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #

def rule(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


def main() -> None:
    rule("0.  THE RECORDED MEASUREMENT AT BITLEN 104")
    for seed, val in SEEDS_104.items():
        print(f"  seed {seed}:  rho = {float(val):.3f}")
    print(f"  pooled     :  rho = {float(POOLED_104):.3f}   "
          f"CI [{float(CI_104[0]):.3f}, {float(CI_104[1]):.3f}]  "
          f"(width {float(CI_104[1] - CI_104[0]):.3f})")
    print("  every seed below 0.55 for the first time.")

    rule("1.  THE CONTRACTION AUDIT OF THE RECORDED LADDER")
    contraction_audit(REC_RUNGS)
    q_star, _ = empirical_contraction_factor(REC_RUNGS)
    print()
    print(f"  q* = 4834/2260 = {float(q_star):.5f} >= 2, so NO q < 1 exists.")
    print("  The rebound d_4 = -0.0226 at bitlen 116 is retraced at bitlen 120")
    print("  by d_5 = +0.04834, more than 2.13 times its size.")
    print(f"  The plateau forecast assumed r <= 1/2; it is violated by a factor "
          f"{float(q_star * 2):.2f}.")

    rule("2.  WHAT CONTRACTION WOULD BUY (TAIL BOUND AND CERTIFIED FLOOR)")
    rho_n, d_n = REC_RUNGS[6], Fraction(4834, 100000)
    for q in (Fraction(1, 4), Fraction(1, 2), Fraction(3, 4), Fraction(9, 10)):
        tb = tail_bound(d_n, q)
        fl = certified_floor(rho_n, d_n, q)
        alive = "positive floor -> never extinguished" if fl > 0 else "no positive floor"
        print(f"  q = {str(q):>4}:  total remaining fade <= {float(tb):.5f},  "
              f"floor = {float(fl):+.5f}   ({alive})")
    print()
    print("  These certificates are VOID for the recorded ladder: the audit above")
    print(f"  shows its true factor is {float(q_star):.4f}, not any of these.")
    print()
    print("  Sharpness check -- the exactly geometric ladder with q = 1/2 attains")
    print("  the bound in the limit:")
    geo = geometric_ladder(rho_n, d_n, Fraction(1, 2), 12)
    print(f"    rho_n   = {float(geo[0]):.6f}")
    print(f"    rho_n+12= {float(geo[-1]):.6f}   "
          f"drop = {float(geo[0] - geo[-1]):.6f}   bound = {float(tail_bound(d_n, Fraction(1, 2))):.6f}")

    rule("3.  THE HARMONIC TRAP: SHRINKING STEPS THAT STILL KILL")
    rho0, c = REC_RUNGS[0], Fraction(303, 10000)
    print(f"  start rho_0 = {float(rho0):.4f}, decrements d_k = {float(c):.4f}/(k+1)")
    print("  (strictly positive, strictly decreasing, tending to zero)")
    print()
    for n in (0, 1, 2, 8, 32, 128):
        print(f"    after {n:>4} four-bit steps:  "
              f"rho = {float(harmonic_fade(rho0, c, n)):.5f}")
    above = all(harmonic_fade(rho0, c, n) > Fraction(33, 100) for n in range(129))
    print(f"  above 0.33 at every n <= 128, i.e. over a span of 512 bits")
    print(f"  (four times the entire recorded sweep)?  {above}")
    m = harmonic_extinction_rung(rho0, c)
    lo, _ = harmonic_dyadic_bracket(m)
    print(f"  yet provably extinguished by step 2^{m} "
          f"(since c*(1 + {m}/2) = {float(c * lo):.5f} >= {float(rho0):.5f})")
    print("  => vanishing decrements certify NOTHING about a floor.")

    rule("4.  NON-IDENTIFIABILITY: TWO FUTURES, ONE PAST")
    for k in range(len(REC_RUNGS)):
        ok = cont_floor(REC_RUNGS, k) == REC_RUNGS[k] == cont_death(REC_RUNGS, k)
        assert ok
    print("  both continuations reproduce all seven recorded rungs exactly: True")
    print()
    print("   k  bitlen     death        floor      separation")
    print("  " + "-" * 50)
    for k, lo, hi, gap in identification_gap(REC_RUNGS, 10):
        print(f"  {k:>2}  {bitlen(k):>6}   {float(lo):+.5f}    {float(hi):.5f}     {float(gap):.5f}")
    print()
    print(f"  floor continuation never falls below "
          f"{float(REC_RUNGS[6] / 2):.5f} = 0.21818")
    print(f"  death continuation equals exactly "
          f"{float(cont_death(REC_RUNGS, 16))} at rung 16 (bitlen 160)")
    k15 = 15
    print(f"  discriminating rung: bitlen {bitlen(k15)} -> gap "
          f"{float(cont_floor(REC_RUNGS, k15) - cont_death(REC_RUNGS, k15)):.5f} "
          f"vs CI width {float(CI_104[1] - CI_104[0]):.3f}")

    rule("5.  CURVATURE: EVERY CONVEX LAW DECELERATES, THE DATA DO NOT")
    A, C = Fraction(5, 14), Fraction(93, 5)
    for b in (96, 100, 104):
        direct, closed = hyperbolic_second_difference(A, C, b)
        print(f"  hyperbolic A + C/b at b={b}: direct={float(direct):.3e}  "
              f"closed=32C/(b(b+4)(b+8))={float(closed):.3e}  match={direct == closed}")
    Ag, Cg, qg = Fraction(1, 3), Fraction(3, 2), Fraction(99, 100)
    direct, closed = geometric_second_difference(Ag, Cg, qg, 8)
    print(f"  geometric A + C q^b at b=8:  direct={float(direct):.6e}  "
          f"closed=C q^b (1-q^4)^2={float(closed):.6e}  match={direct == closed}")
    print()
    d = decrements(REC_RUNGS)
    print(f"  observed: d_0 = {float(d[0]):+.4f} < d_1 = {float(d[1]):+.4f}  "
          "-> the fade ACCELERATES across bitlens 96-104")
    print("  => no hyperbolic and no geometric law, with ANY parameters, fits those three rungs.")
    sd = second_differences(REC_RUNGS)
    signs = [("convex" if s > 0 else "concave" if s < 0 else "flat") for s in sd]
    print(f"  grid second differences: "
          f"{[f'{float(s):+.4f}' for s in sd]}")
    print(f"  curvature signs        : {signs}")
    print("  => the ladder has BOTH a strictly convex and a strictly concave triple:")
    print("     no fixed-curvature-sign law of any kind reproduces it.")

    rule("6.  SECANT FORECASTS (HYPOTHESES, NOT THEOREMS)")
    z1 = secant_zero(52, Fraction(706, 1000), 104, REC_RUNGS[2])
    z2 = secant_zero(104, REC_RUNGS[2], 120, REC_RUNGS[6])
    print(f"  secant through bitlens  52 and 104 reaches zero at b = {float(z1):.1f}")
    print(f"  secant through bitlens 104 and 120 reaches zero at b = {float(z2):.1f}")
    print("  two independent secants place extinction in the window b = 228..231,")
    print("  but this is a linear hypothesis about unmeasured rungs, not a proof.")

    rule("SUMMARY")
    print("  * Fade dichotomy: floor or finite extinction; the criterion is")
    print("    summability of the decrements, not their decay.")
    print("  * Vanishing steps prove nothing (harmonic trap, section 3).")
    print("  * Finitely many rungs cannot identify the limit (section 4).")
    print("  * Contraction with q < 1 would identify it, via")
    print("        |rho_{n+m} - rho_n| <= |d_n| / (1 - q),")
    print("    giving the explicit floor rho_n - |d_n|/(1-q).")
    print(f"  * The recorded ladder has q* = {float(q_star):.4f} >= 2: no such certificate exists.")
    print("  * Therefore the plateau reading is a hypothesis about rungs not yet")
    print("    measured, not a consequence of the rungs that have been.")


if __name__ == "__main__":
    main()
