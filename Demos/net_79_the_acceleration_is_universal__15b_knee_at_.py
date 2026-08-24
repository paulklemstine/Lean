"""
Retained-Mass Knees, Pythagorean Decay Ratios, and the Localisation of
Budget Inversions
=====================================================================

Self-contained numerical demonstration of every quantitative claim in the
accompanying paper.  All arithmetic on knees is performed in *exact rational*
arithmetic (``fractions.Fraction``), so the reported knees are certified
values, not floating-point estimates.

Contents
--------
1.  Core definitions: attention profile, head mass, retained mass, knee.
2.  Geometric profiles: closed form, ratio monotonicity, the universal
    certificate ``r**K <= 1 - tau``.
3.  Pythagorean decay ratios: the universal short-leg budget of 13 keys at
    gate 0.985, its sharpness at (696, 697, 985), the unboundedness of
    long-leg budgets, and the forced inversion.
4.  The near-isosceles (Pell) branch and the closing gaps 10, 2, 1, 0.
5.  The measured scale x context surface: increments, amplification factors
    4 and 19, non-separability, sign change, least common budgets.
6.  Realizable inversion of two honest profiles and the explicit crossover
    bound (K+1)*M/(tau*c).

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import ceil, isqrt
from typing import Callable, Iterator, List, Sequence, Tuple

Rat = Fraction


# ----------------------------------------------------------------------
# 1. Core definitions
# ----------------------------------------------------------------------

def head_mass(w: Callable[[int], Rat], n: int) -> Rat:
    """H_w(n) = sum_{i<n} w(i)."""
    return sum((w(i) for i in range(n)), Rat(0))


def retained(w: Callable[[int], Rat], n: int, k: int) -> Rat:
    """R_w(n,k) = H_w(min(k,n)) / H_w(n), the retained attention mass."""
    if n <= 0:
        raise ValueError("context length must be positive")
    return head_mass(w, min(k, n)) / head_mass(w, n)


def knee(w: Callable[[int], Rat], n: int, tau: Rat) -> int:
    """k*(w,n,tau): least k with R_w(n,k) >= tau.  Exact, by scanning."""
    total = head_mass(w, n)
    target = tau * total
    acc = Rat(0)
    if acc >= target:
        return 0
    for k in range(1, n + 1):
        acc += w(k - 1)
        if acc >= target:
            return k
    return n


# ----------------------------------------------------------------------
# 2. Geometric profiles
# ----------------------------------------------------------------------

def geom_profile(r: Rat) -> Callable[[int], Rat]:
    """The geometric attention profile g_r(i) = r**i."""
    return lambda i: r ** i


def retained_geom_closed_form(r: Rat, n: int, k: int) -> Rat:
    """Closed form  (1 - r**min(k,n)) / (1 - r**n)  for a geometric profile."""
    m = min(k, n)
    return (1 - r ** m) / (1 - r ** n)


def knee_geom(r: Rat, n: int, tau: Rat) -> int:
    """Exact knee of a geometric profile, via the closed form.

    Returns the least k <= n with (1 - r**k) >= tau * (1 - r**n).
    """
    den = 1 - r ** n
    target = tau * den
    for k in range(0, n + 1):
        if 1 - r ** k >= target:
            return k
    return n


def universal_budget(r_bar: Rat, tau: Rat) -> int:
    """Least K with r_bar**K <= 1 - tau.

    By the exact geometric certificate, this K clears the gate at EVERY
    context length for every geometric profile with ratio at most r_bar.
    """
    slack = 1 - tau
    K, p = 0, Rat(1)
    while p > slack:
        K += 1
        p *= r_bar
    return K


# ----------------------------------------------------------------------
# 3. Pythagorean decay ratios
# ----------------------------------------------------------------------

def is_pyth_triple(a: int, b: int, c: int) -> bool:
    return a * a + b * b == c * c


def leg_ratio(x: int, c: int) -> Rat:
    return Rat(x, c)


def near_square_triple(m: int) -> Tuple[int, int, int]:
    """(2m+1, 2m(m+1), 2m(m+1)+1): long-leg ratio t/(t+1) tends to 1."""
    t = 2 * m * (m + 1)
    return (2 * m + 1, t, t + 1)


# ----------------------------------------------------------------------
# 4. The near-isosceles (Pell) branch
# ----------------------------------------------------------------------

def pell_branch(count: int) -> List[Tuple[int, int, int]]:
    """(a, a+1, c) with c^2 = 2a^2 + 2a + 1, via (a,c) -> (3a+2c+1, 4a+3c+2)."""
    out: List[Tuple[int, int, int]] = []
    a, c = 3, 5
    for _ in range(count):
        out.append((a, a + 1, c))
        a, c = 3 * a + 2 * c + 1, 4 * a + 3 * c + 2
    return out


# ----------------------------------------------------------------------
# 5. The measured surface
# ----------------------------------------------------------------------

CONTEXTS: Tuple[int, ...] = (512, 1024, 2048, 4096)
SMALL: Tuple[int, ...] = (16, 20, 24, 40)
LARGE: Tuple[int, ...] = (16, 16, 18, 56)


def increments(seq: Sequence[int]) -> List[int]:
    return [seq[j + 1] - seq[j] for j in range(len(seq) - 1)]


def additively_separable(rows: Sequence[Sequence[int]]) -> bool:
    """A surface is additive iff every row difference is constant."""
    base = rows[0]
    for row in rows[1:]:
        gaps = {row[j] - base[j] for j in range(len(base))}
        if len(gaps) != 1:
            return False
    return True


def multiplicatively_separable(rows: Sequence[Sequence[int]]) -> bool:
    """A surface is multiplicative iff every row ratio is constant."""
    base = rows[0]
    for row in rows[1:]:
        ratios = {Rat(row[j], base[j]) for j in range(len(base)) if base[j] != 0}
        if len(ratios) != 1:
            return False
    return True


# ----------------------------------------------------------------------
# 6. Realizable inversion and crossover localisation
# ----------------------------------------------------------------------

def prof_gap(i: int) -> Rat:
    """v(i) = (1/2)^i : a genuine spectral gap, no floor."""
    return Rat(1, 2) ** i


def prof_floor(i: int) -> Rat:
    """w(i) = (1/16)^i + 1/1000 : a steeper head, but a positive floor."""
    return Rat(1, 16) ** i + Rat(1, 1000)


def band_lower_bound(n: int, tau: Rat, c: Rat, M: Rat) -> Rat:
    """k*(w,n,tau) >= tau*n*c/M for a profile banded in [c, M]."""
    return tau * n * c / M


def crossover_bound(K: int, c: Rat, M: Rat, tau: Rat) -> int:
    """Least certified context: n >= (K+1)*M/(tau*c) forces the inversion."""
    return ceil((K + 1) * M / (tau * c))


# ----------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def main() -> None:
    tau_985 = Rat(985, 1000)
    tau_9 = Rat(9, 10)

    # ---------------------------------------------------------------- 1
    rule("1.  Retained mass and the knee: a first look")
    r = Rat(3, 5)
    n = 64
    print(f"Geometric profile with decay ratio r = {r}, context n = {n}")
    for k in (4, 8, 9, 12):
        direct = retained(geom_profile(r), n, k)
        closed = retained_geom_closed_form(r, n, k)
        assert direct == closed, "closed form disagrees with the definition"
        print(f"   R(n,{k:2d}) = {float(direct):.9f}   (closed form agrees exactly)")
    k9 = knee_geom(r, n, tau_985)
    assert k9 == knee(geom_profile(r), n, tau_985)
    print(f"   knee at gate 0.985 : k* = {k9}")

    # ---------------------------------------------------------------- 2
    rule("2.  Ratio monotonicity: slower decay never needs fewer keys")
    print("  r        k*(r, 64, 0.985)     R(64, 10)")
    prev = -1
    for num in (1, 2, 3, 4, 5, 6, 7, 8, 9):
        rr = Rat(num, 10)
        kk = knee_geom(rr, 64, tau_985)
        print(f"  {str(rr):5s}      {kk:4d}            {float(retained_geom_closed_form(rr,64,10)):.9f}")
        assert kk >= prev, "knee must be monotone in the decay ratio"
        prev = kk
    print("  -> knee is non-decreasing in r, and retained mass antitone.  OK")

    # ---------------------------------------------------------------- 3
    rule("3.  The universal Pythagorean short-leg budget at gate 0.985")
    r_bar = Rat(708, 1000)          # rational bound for 1/sqrt(2)
    K_exact = universal_budget(r_bar, tau_985)
    print(f"   short-leg ratio bound   r_bar = {r_bar}  (>= 1/sqrt2 = {1/2**0.5:.6f})")
    print(f"   exact certificate  r_bar^K <= 1 - tau  gives K = {K_exact}")
    # the crude tail-sum certificate r^K/(1-r) <= 1-tau
    K_crude, p = 0, Rat(1)
    while p / (1 - r_bar) > 1 - tau_985:
        K_crude += 1
        p *= r_bar
    print(f"   crude tail certificate  r_bar^K/(1-r_bar) <= 1 - tau  gives K = {K_crude}")
    print(f"   the {K_crude - K_exact}-key gap is exactly the 1/(1-r) loss")
    assert K_exact == 13 and K_crude == 16

    print("\n   Checking the bound over many Pythagorean triples (short leg, n = 64):")
    worst = 0
    checked = 0
    for m in range(2, 60):
        for k in range(1, m):
            if (m - k) % 2 == 1 and _gcd(m, k) == 1:
                a, b, c = m * m - k * k, 2 * m * k, m * m + k * k
                a, b = min(a, b), max(a, b)
                assert is_pyth_triple(a, b, c)
                kk = knee_geom(leg_ratio(a, c), 64, tau_985)
                worst = max(worst, kk)
                checked += 1
    print(f"   {checked} primitive triples checked;  max short-leg knee = {worst} <= 13.  OK")

    # ---------------------------------------------------------------- 4
    rule("4.  Sharpness: the near-isosceles triple (696, 697, 985)")
    a, b, c = 696, 697, 985
    assert is_pyth_triple(a, b, c)
    rr = leg_ratio(a, c)
    print(f"   {a}^2 + {b}^2 = {a*a+b*b} = {c}^2   ratio a/c = {float(rr):.9f}")
    r12 = retained_geom_closed_form(rr, 64, 12)
    r13 = retained_geom_closed_form(rr, 64, 13)
    print(f"   R(64,12) = {float(r12):.9f}  <  0.985   (12 keys FAIL)")
    print(f"   R(64,13) = {float(r13):.9f}  >= 0.985   (13 keys PASS)")
    print(f"   => k* = {knee_geom(rr, 64, tau_985)}: the universal budget 13 is attained")
    assert r12 < tau_985 <= r13 and knee_geom(rr, 64, tau_985) == 13

    # ---------------------------------------------------------------- 5
    rule("5.  No universal long-leg budget")
    print("   near-square triples (2m+1, 2m(m+1), 2m(m+1)+1), long-leg ratio t/(t+1)")
    print("     m       triple                      long ratio      k*(n=4m)")
    for m in (1, 3, 10, 30, 100):
        a, b, c = near_square_triple(m)
        assert is_pyth_triple(a, b, c)
        rr = leg_ratio(b, c)
        nn = 4 * m
        kk = knee_geom(rr, nn, tau_985)
        print(f"   {m:5d}   ({a:5d},{b:7d},{c:7d})    {float(rr):.8f}     {kk:5d}")
    print("   -> long-leg budget grows without bound as the ratio tends to 1")

    # ---------------------------------------------------------------- 6
    rule("6.  Forced inversion: (3,4,5) against (20,21,29) at context 64")
    rows = [(3, 4, 5), (20, 21, 29)]
    print("   triple          short ratio   k*short    long ratio   k*long")
    knees = []
    for (a, b, c) in rows:
        ks = knee_geom(leg_ratio(a, c), 64, tau_985)
        kl = knee_geom(leg_ratio(b, c), 64, tau_985)
        knees.append((ks, kl))
        print(f"   ({a:3d},{b:3d},{c:3d})     {float(Rat(a,c)):.8f}    {ks:3d}     "
              f"{float(Rat(b,c)):.8f}    {kl:3d}")
    (s1, l1), (s2, l2) = knees
    print(f"   short legs: {s1} < {s2}      long legs: {l1} > {l2}")
    print("   -> the ordering INVERTS: no triangle is uniformly cheaper")
    assert (s1, s2, l1, l2) == (9, 12, 19, 14)

    # ---------------------------------------------------------------- 7
    rule("7.  The Pell branch: the two leg budgets squeeze and meet")
    print("   k   triple                short  long   gap")
    prev_gap = None
    for idx, (a, b, c) in enumerate(pell_branch(5)):
        assert is_pyth_triple(a, b, c) and c * c == 2 * a * a + 2 * a + 1
        ks = knee_geom(leg_ratio(a, c), 64, tau_985)
        kl = knee_geom(leg_ratio(b, c), 64, tau_985)
        gap = kl - ks
        print(f"   {idx}   ({a:5d},{b:5d},{c:5d})    {ks:4d}  {kl:4d}   {gap:4d}")
        if prev_gap is not None:
            assert gap <= prev_gap, "the gap must not reopen along the branch"
        prev_gap = gap
    print("   -> gaps 10, 2, 1, 0, ... : the budgets meet at the universal value 13")

    # ---------------------------------------------------------------- 8
    rule("8.  The measured scale x context surface")
    print("   context:   " + "  ".join(f"{c:6d}" for c in CONTEXTS))
    print("   small  :   " + "  ".join(f"{v:6d}" for v in SMALL))
    print("   large  :   " + "  ".join(f"{v:6d}" for v in LARGE))
    ds, dl = increments(SMALL), increments(LARGE)
    print(f"\n   increments  small = {ds}     large = {dl}")
    print(f"   amplification: small {ds[2]} / {ds[1]} = {ds[2]//ds[1]}x, "
          f"large {dl[2]} / {dl[1]} = {dl[2]//dl[1]}x")
    assert ds[2] == 4 * ds[1] and dl[2] == 19 * dl[1]
    print(f"   additively separable?      {additively_separable([SMALL, LARGE])}")
    print(f"   multiplicatively separable? {multiplicatively_separable([SMALL, LARGE])}")
    assert not additively_separable([SMALL, LARGE])
    assert not multiplicatively_separable([SMALL, LARGE])
    gaps = [LARGE[j] - SMALL[j] for j in range(4)]
    print(f"   scale gaps (large - small): {gaps}   -> sign change at the last step")
    cross = min(j for j in range(4) if SMALL[j] < LARGE[j])
    print(f"   least index with small < large: j = {cross}  (context {CONTEXTS[cross]})")
    for j in (2, 3):
        print(f"   least budget covering both scales at {CONTEXTS[j]}: "
              f"{max(SMALL[j], LARGE[j])}")
    assert cross == 3

    # ---------------------------------------------------------------- 9
    rule("9.  A realizable inversion of two honest profiles (gate 0.9)")
    print("   v(i) = (1/2)^i                (spectral gap, no floor)")
    print("   w(i) = (1/16)^i + 1/1000      (steeper head, positive floor)")
    kv2, kw2 = knee(prof_gap, 2, tau_9), knee(prof_floor, 2, tau_9)
    print(f"\n   context     2 :  k*(v) = {kv2},  k*(w) = {kw2}   -> w is CHEAPER")
    assert (kv2, kw2) == (2, 1)
    print(f"   R_w(2,1) = {float(retained(prof_floor,2,1)):.9f} >= 0.9")
    print(f"   R_v(2,1) = {float(retained(prof_gap,2,1)):.9f} <  0.9")

    Kv = universal_budget(Rat(1, 2), tau_9)
    print(f"\n   v has a CONTEXT-FREE budget: (1/2)^{Kv} <= 1 - 0.9, so k*(v,n,0.9) <= {Kv}"
          " for every n")
    assert Kv == 4
    c_floor, M_cap = Rat(1, 1000), Rat(1001, 1000)
    lb = band_lower_bound(5000, tau_9, c_floor, M_cap)
    print(f"   w is banded in [{c_floor}, {M_cap}], so k*(w,5000,0.9) >= "
          f"tau*n*c/M = {float(lb):.6f} > 4")
    assert lb > 4
    print("   context  5000 :  k*(v) <= 4  <  k*(w)      -> v is CHEAPER")
    print("   => the ordering INVERTS with context.  No profile is uniformly better.")

    # --------------------------------------------------------------- 10
    rule("10. Localising the crossover")
    nb = crossover_bound(Kv, c_floor, M_cap, tau_9)
    print(f"   bound (K+1)*M/(tau*c) = ({Kv}+1)*{float(M_cap)}/"
          f"({float(tau_9)}*{float(c_floor)}) = "
          f"{float((Kv+1)*M_cap/(tau_9*c_floor)):.4f}")
    print(f"   => every context n >= {nb} certifies the inversion")
    assert nb == 5562
    first = next(n for n in range(2, 400)
                 if knee(prof_gap, n, tau_9) < knee(prof_floor, n, tau_9))
    print(f"   exact first crossover (both knees computed in full): n = {first}"
          f"  ({knee(prof_gap, first, tau_9)} < {knee(prof_floor, first, tau_9)})")
    print(f"   the certificate overshoots the truth by {nb/first:.1f}x: the band estimate")
    print("   is tight only for a FLAT profile, and w is steep near its head")
    assert first == 123
    print("\n   Scaling in the tail floor c  --  the crossover goes like M/(tau*c):")
    print("     floor c        certified crossover context")
    for denom in (1000, 2000, 5000, 10000, 100000):
        cc = Rat(1, denom)
        print(f"     1/{denom:<9d}    {crossover_bound(Kv, cc, 1 + cc, tau_9):>12d}")
    print("   -> a 10x smaller floor pushes the phase transition 10x further out.")

    rule("All assertions passed.")


def _gcd(x: int, y: int) -> int:
    while y:
        x, y = y, x % y
    return x


if __name__ == "__main__":
    main()
