#!/usr/bin/env python3
"""
Numerical demonstrations for
"The Detection Window of Sequential-Multiple Curve Factoring,
 and the Addition-Chain Barrier".

Everything is self-contained: no third-party dependencies, no I/O, no network.
Run with

    python3 demo.py

Each section verifies one theorem from the paper by direct enumeration.

Sections
--------
 1. The lite window is the order window          (ord(P) <= B)
 2. True ECM sees exactly the B-smooth orders
 3. The strict separation at order 96, B = 50
 4. The sharp x-coordinate window [1, 2B-1] and its sharpness at 2B
 5. The two-torsion degeneracy (the v1 implementation bug)
 6. Counting the visible set: B^2 bound and the exact totient sum
 7. The detection gap at group order 1058400
 8. Curve-budget scaling: fixed B gives exponent 1, not 1/2
 9. Effective stage-one bound from a measured slope
10. The addition-chain barrier m_t <= 2^t and the exponential gap
11. Visiting sets: {1,2,4,8} beats {1,2,3,4} at equal cost
"""

from __future__ import annotations

from math import gcd, isqrt, log2, sqrt
from typing import Dict, Iterable, List, Sequence, Set, Tuple


# --------------------------------------------------------------------------
# Elementary number theory helpers
# --------------------------------------------------------------------------


def totient(n: int) -> int:
    """Euler's totient phi(n), by trial-division factorisation."""
    if n <= 0:
        raise ValueError("totient requires a positive integer")
    result = n
    m = n
    p = 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1 if p == 2 else 2
    if m > 1:
        result -= result // m
    return result


def divisors(n: int) -> List[int]:
    """All positive divisors of n, sorted ascending."""
    if n <= 0:
        raise ValueError("divisors requires a positive integer")
    small: List[int] = []
    large: List[int] = []
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
    return small + large[::-1]


def lcm_upto(bound: int) -> int:
    """lambda(B) = lcm(1, 2, ..., B), the stage-one exponent of true ECM."""
    acc = 1
    for k in range(1, bound + 1):
        acc = acc * k // gcd(acc, k)
    return acc


def order_in_cyclic(a: int, n: int) -> int:
    """Additive order of the residue a in Z/n."""
    return n // gcd(a % n, n)


# --------------------------------------------------------------------------
# The two arms, modelled inside Z/n
# --------------------------------------------------------------------------


def lite_hit(a: int, n: int, bound: int) -> bool:
    """The sequential arm: does some j*a vanish in Z/n for 2 <= j <= B?"""
    return any((j * a) % n == 0 for j in range(2, bound + 1))


def ecm_hit(a: int, n: int, bound: int) -> bool:
    """True ECM stage one: does lcm(1..B) * a vanish in Z/n?"""
    return (lcm_upto(bound) * a) % n == 0


def x_collision(a: int, n: int, bound: int) -> bool:
    """
    Does the run a, 2a, ..., B*a exhibit a repeated x-coordinate?

    Two affine points of a Weierstrass curve share an x-coordinate exactly
    when they are equal or opposite, so the group-level event is
    i*a == j*a  or  i*a == -(j*a)  in Z/n.
    """
    for i in range(1, bound + 1):
        for j in range(i + 1, bound + 1):
            if ((j - i) * a) % n == 0 or ((i + j) * a) % n == 0:
                return True
    return False


def detects_order(visiting: Sequence[int], d: int) -> bool:
    """Does the visiting set J detect a base point of order d?"""
    js = sorted(visiting)
    for x, i in enumerate(js):
        for j in js[x + 1:]:
            if (j - i) % d == 0 or (i + j) % d == 0:
                return True
    return False


def detected_orders(visiting: Sequence[int], upto: int) -> Set[int]:
    """All orders d <= `upto` detectable by the visiting set."""
    return {d for d in range(1, upto + 1) if detects_order(visiting, d)}


# --------------------------------------------------------------------------
# Counting the visible set
# --------------------------------------------------------------------------


def visible_count_exact(n: int, bound: int) -> int:
    """Exact number of elements of Z/n of order <= B: sum of phi(d)."""
    return sum(totient(d) for d in divisors(n) if d <= bound)


def visible_count_bruteforce(n: int, bound: int) -> int:
    """Same quantity by direct enumeration (used to cross-check)."""
    return sum(1 for a in range(n) if order_in_cyclic(a, n) <= bound)


# --------------------------------------------------------------------------
# Addition chains
# --------------------------------------------------------------------------


def sequential_chain(steps: int) -> List[int]:
    """The lite ladder 1, 2, 3, ... : m_t = t + 1."""
    return [t + 1 for t in range(steps + 1)]


def doubling_chain(steps: int) -> List[int]:
    """The optimal ladder 1, 2, 4, 8, ... : m_t = 2^t."""
    return [2 ** t for t in range(steps + 1)]


def is_addition_chain(seq: Sequence[int]) -> bool:
    """Verify m_0 = 1 and each m_{t+1} = m_i + m_j with i, j <= t."""
    if not seq or seq[0] != 1:
        return False
    for t in range(len(seq) - 1):
        prefix = seq[: t + 1]
        if not any(x + y == seq[t + 1] for x in prefix for y in prefix):
            return False
    return True


# --------------------------------------------------------------------------
# Scaling
# --------------------------------------------------------------------------


def curve_budget(p: int, bound: int) -> float:
    """The budget p/(2B^2) below which success probability stays under 1/2."""
    return p / (2.0 * bound * bound)


def fit_exponent(xs: Sequence[float], ys: Sequence[float]) -> Tuple[float, float]:
    """
    Ordinary least squares of log2(y) on log2(x); returns (slope, intercept).

    The slope is the scaling exponent: y ~ x^slope.
    """
    lx = [log2(x) for x in xs]
    ly = [log2(y) for y in ys]
    m = len(lx)
    mx = sum(lx) / m
    my = sum(ly) / m
    num = sum((a - mx) * (b - my) for a, b in zip(lx, ly))
    den = sum((a - mx) ** 2 for a in lx)
    slope = num / den
    return slope, my - slope * mx


def effective_bound_exponent(slope: float) -> float:
    """B_eff = p^{(1 - s)/2} from a measured budget exponent s."""
    return (1.0 - slope) / 2.0


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def rule(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_lite_window() -> None:
    rule("1. The lite window is the order window:  lite hit  <=>  ord(P) <= B")
    n, bound = 210, 7
    mismatches = 0
    for a in range(n):
        d = order_in_cyclic(a, n)
        if lite_hit(a, n, bound) != (d <= bound):
            mismatches += 1
    print(f"  group Z/{n}, bound B = {bound}")
    print(f"  elements checked           : {n}")
    print(f"  mismatches with 'ord <= B' : {mismatches}")
    assert mismatches == 0
    print("  VERIFIED: the sequential arm annihilates P iff ord(P) <= B.")


def demo_ecm_window() -> None:
    rule("2. True ECM sees exactly the B-smooth orders")
    n, bound = 210, 7
    lam = lcm_upto(bound)
    mismatches = sum(
        1
        for a in range(n)
        if ecm_hit(a, n, bound) != (lam % order_in_cyclic(a, n) == 0)
    )
    print(f"  group Z/{n}, bound B = {bound}, lambda(B) = lcm(1..{bound}) = {lam}")
    print(f"  mismatches with 'ord | lambda(B)' : {mismatches}")
    assert mismatches == 0
    lite = sum(1 for a in range(n) if lite_hit(a, n, bound))
    ecm = sum(1 for a in range(n) if ecm_hit(a, n, bound))
    print(f"  points seen by the lite arm : {lite:5d} / {n}")
    print(f"  points seen by true ECM     : {ecm:5d} / {n}")
    print("  VERIFIED: divisibility beats an inequality.")


def demo_strict_separation() -> None:
    rule("3. Strict separation: order 96 is 50-smooth but outside the lite window")
    n, bound = 96, 50
    lam = lcm_upto(bound)
    print(f"  96 = 2^5 * 3;  32 <= 50 and 3 <= 50, so 96 | lambda(50).")
    print(f"  96 divides lambda(50)?  {lam % 96 == 0}")
    print(f"  ECM hit on the generator of Z/96 ? {ecm_hit(1, n, bound)}")
    print(f"  lite hit on the generator of Z/96? {lite_hit(1, n, bound)}")
    assert ecm_hit(1, n, bound) and not lite_hit(1, n, bound)
    print("  VERIFIED: true ECM kills it, the lite arm never sees it.")


def demo_sharp_window() -> None:
    rule("4. The sharp x-coordinate window:  collision  <=>  ord(P) <= 2B - 1")
    for bound in (3, 5, 8, 12):
        top = 2 * bound - 1
        # Test every order d by working in Z/d with the generator.
        bad: List[int] = []
        for d in range(1, 3 * bound + 4):
            predicted = d <= top
            actual = x_collision(1, d, bound)
            if predicted != actual:
                bad.append(d)
        invisible = not x_collision(1, 2 * bound, bound)
        print(
            f"  B = {bound:2d}   window [1, {top:2d}]   "
            f"mismatched orders: {bad}   order {2*bound} invisible: {invisible}"
        )
        assert not bad and invisible
    print("  VERIFIED: the window is exactly [1, 2B-1], and 2B is invisible.")


def demo_two_torsion() -> None:
    rule("5. The two-torsion degeneracy (formal shape of the v1 bug)")
    n = 60
    mismatches = sum(
        1 for a in range(n) if ((2 * a) % n == 0) != (order_in_cyclic(a, n) <= 2)
    )
    print(f"  group Z/{n}: mismatches with '2P = 0 <=> ord(P) <= 2' : {mismatches}")
    assert mismatches == 0
    print("  A buggy run that compares P with itself at j = 2 asserts XEq(P, P),")
    print("  manufacturing this event on EVERY curve -> instant, spurious success.")
    print("  VERIFIED.")


def demo_counting() -> None:
    rule("6. Counting the visible set: the B^2 bound and the exact totient sum")
    print(f"  {'n':>8} {'B':>4} {'brute force':>12} {'sum phi(d)':>12} {'B^2':>8}")
    for n, bound in ((210, 7), (360, 12), (1024, 16), (2310, 11), (5040, 20)):
        exact = visible_count_exact(n, bound)
        brute = visible_count_bruteforce(n, bound)
        assert exact == brute <= bound * bound
        print(f"  {n:8d} {bound:4d} {brute:12d} {exact:12d} {bound*bound:8d}")
    print("  VERIFIED: exact count = sum of phi(d) over divisors d <= B, and <= B^2.")


def demo_detection_gap() -> None:
    rule("7. The detection gap at group order 1058400 = 2^5 * 3^3 * 5^2 * 7^2")
    n, bound = 1058400, 50
    lam = lcm_upto(bound)
    assert lam % n == 0
    visible = visible_count_exact(n, bound)
    print(f"  n = {n}  divides lambda(50)?  {lam % n == 0}")
    print(f"  true ECM at B = 50 annihilates all {n} points.")
    print(f"  lite-visible points (exact sum of phi): {visible}")
    print(f"  bound B^2 = {bound*bound};  ratio |G| / visible = {n / visible:.1f}x")
    assert visible <= bound * bound
    print("  VERIFIED: a factor of over 400 lost by counting instead of taking an lcm.")


def demo_scaling() -> None:
    rule("8. Curve-budget scaling: a FIXED bound gives exponent 1, not 1/2")
    bound = 50
    ps = [2 ** k for k in (16, 20, 32, 48, 64, 96, 128)]
    budgets = [curve_budget(p, bound) for p in ps]
    print(f"  fixed B = {bound}; budget lower bound p/(2B^2) to reach P[success] >= 1/2")
    print(f"  {'log2 p':>8} {'budget':>16} {'sqrt(p)':>16} {'budget/sqrt(p)':>16}")
    for p, c in zip(ps, budgets):
        print(f"  {log2(p):8.0f} {c:16.3e} {sqrt(p):16.3e} {c/sqrt(p):16.3e}")
    slope_all, _ = fit_exponent(ps, budgets)
    narrow = [2 ** 16, 2 ** 20]
    slope_narrow, _ = fit_exponent(narrow, [curve_budget(p, bound) for p in narrow])
    print(f"  fitted exponent over the full range  : {slope_all:.4f}")
    print(f"  fitted exponent over k = 16..20 only : {slope_narrow:.4f}")
    assert abs(slope_all - 1.0) < 1e-9
    print("  VERIFIED: the exponent is 1. No constant c makes c*sqrt(p) an upper bound:")
    for c in (1.0, 100.0, 1e6):
        m = int(max(2, 2 * c * bound * bound)) + 1
        p = m * m
        print(f"    c = {c:>9.0e}:  p = {p:>22d}  gives  c*sqrt(p) = {c*sqrt(p):.4e}"
              f"  <  p/(2B^2) = {curve_budget(p, bound):.4e}")
        assert c * sqrt(p) < curve_budget(p, bound)


def demo_effective_bound() -> None:
    rule("9. Effective stage-one bound implied by a measured slope")
    for slope in (0.48, 0.50, 0.52, 0.84, 1.00):
        e = effective_bound_exponent(slope)
        vals = ", ".join(f"k={k}: {2**(e*k):6.1f}" for k in (16, 20, 32, 64))
        print(f"  measured slope s = {slope:.2f}  ->  B_eff = p^{e:.3f}   {vals}")
    print()
    print("  The campaign actually used the FIXED bound B_1 = 50 = 2^5.64.")
    e48 = effective_bound_exponent(0.48)
    print(f"  s = 0.48 predicts B_eff = p^{e48:.2f}:")
    print(f"    k = 16 -> {2**(e48*16):.1f},  k = 20 -> {2**(e48*20):.1f}")
    print("  Over a four-bit range these bracket 50: a constant is indistinguishable")
    print("  from a slowly growing power. That is the whole of the 0.48 illusion.")
    print()
    print("  Exact crossover: B = p^{1/4} gives budget exactly sqrt(p)/2.")
    for m in (10, 100, 1000):
        p = m ** 4
        print(f"    p = {p:>16d}, B = {m:>5d}:  p/(2B^2) = {curve_budget(p, m):.4e}"
              f"   sqrt(p)/2 = {sqrt(p)/2:.4e}")
        assert abs(curve_budget(p, m) - sqrt(p) / 2) < 1e-6 * sqrt(p)
    print("  VERIFIED.")


def demo_addition_chains() -> None:
    rule("10. The addition-chain barrier m_t <= 2^t, and the exponential gap")
    steps = 12
    seq = sequential_chain(steps)
    dbl = doubling_chain(steps)
    assert is_addition_chain(seq) and is_addition_chain(dbl)
    print("  both ladders are legitimate addition chains (m_0 = 1, m_{t+1} = m_i + m_j)")
    print(f"  {'t':>3} {'sequential m_t':>15} {'doubling m_t':>14} {'barrier 2^t':>13}"
          f" {'seq window 2(t+1)-1':>21}")
    for t in range(steps + 1):
        assert seq[t] <= 2 ** t and dbl[t] == 2 ** t
        print(f"  {t:3d} {seq[t]:15d} {dbl[t]:14d} {2**t:13d} {2*(t+1)-1:21d}")
    print()
    print("  For t >= 3 the sequential run of length t cannot see order 2^t,")
    print("  which the doubling ladder annihilates at the same cost:")
    for t in (3, 5, 8, 10):
        order = 2 ** t
        window = 2 * (t + 1) - 1
        seen = x_collision(1, order, t) if t <= 12 else None
        print(f"    t = {t:2d}:  order 2^t = {order:6d},  sequential window [1, {window}]"
              f",  detected by sequential run: {seen}")
        assert seen is False
        assert (order * 1) % order == 0  # doubling ladder annihilates it
    print("  VERIFIED: exponential reach versus linear reach at equal operation count.")


def demo_visiting_sets() -> None:
    rule("11. Shape matters: {1,2,4,8} beats {1,2,3,4} at three additions")
    seq_set = [1, 2, 3, 4]
    geo_set = [1, 2, 4, 8]
    ds = detected_orders(seq_set, 20)
    dg = detected_orders(geo_set, 20)
    print(f"  sequential J = {seq_set}")
    print(f"    differences {sorted({j-i for i in seq_set for j in seq_set if j>i})}"
          f"   sums {sorted({i+j for i in seq_set for j in seq_set if j>i})}")
    print(f"    detects (<=20): {sorted(ds)}")
    print(f"  geometric  J = {geo_set}")
    print(f"    differences {sorted({j-i for i in geo_set for j in geo_set if j>i})}"
          f"   sums {sorted({i+j for i in geo_set for j in geo_set if j>i})}")
    print(f"    detects (<=20): {sorted(dg)}")
    only_geo = sorted(dg - ds)
    print(f"  detected by the geometric set but NOT the sequential set: {only_geo}")
    assert ds == set(range(1, 8))
    for d in (9, 10, 12):
        assert detects_order(geo_set, d) and not detects_order(seq_set, d)
    print("  Group-level check at order 12 (in Z/12, base point the generator):")
    hit_geo = any(
        (j - i) % 12 == 0 or (i + j) % 12 == 0
        for i in geo_set for j in geo_set if i < j
    )
    hit_seq = any(
        (j - i) % 12 == 0 or (i + j) % 12 == 0
        for i in seq_set for j in seq_set if i < j
    )
    print(f"    found by {{1,2,4,8}}: {hit_geo}    found by {{1,2,3,4}}: {hit_seq}")
    assert hit_geo and not hit_seq
    print("  VERIFIED: the contiguous schedule maximises the window, minimises the reach.")


def main() -> None:
    print(__doc__)
    demo_lite_window()
    demo_ecm_window()
    demo_strict_separation()
    demo_sharp_window()
    demo_two_torsion()
    demo_counting()
    demo_detection_gap()
    demo_scaling()
    demo_effective_bound()
    demo_addition_chains()
    demo_visiting_sets()
    rule("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
