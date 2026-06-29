"""
demo.py — Tropical extremal-support profiles of finitely supported rational sequences.

This script is a fully self-contained numerical companion to the results:

    * ord f  = least index of a nonzero coefficient   (valuation; ord 0 = +inf)
    * deg f  = greatest index of a nonzero coefficient (degree;    deg 0 = -inf)

    Tropical addition laws (INEQUALITIES, because of cancellation):
        min(ord f, ord g) <= ord(f + g)
        deg(f + g)        <= max(deg f, deg g)

    Exact convolution laws (EQUALITIES, via the unique extremal contributing pair
    and the absence of zero-divisors in Q):
        ord(f * g) = ord f + ord g
        deg(f * g) = deg f + deg g

    Downstream species corollary (binomial / exponential convolution a * b):
        ord(a (*) b) = ord a + ord b
        deg(a (*) b) = deg a + deg b

All sequences are modeled as dicts {index: Fraction}, with zero coefficients
omitted, mirroring the finitely supported `N ->_f Q` of the formal development.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, inf
from typing import Dict, Union

# A finitely supported rational sequence: index -> nonzero rational coefficient.
Seq = Dict[int, Fraction]
Ext = Union[int, float]  # an extended natural: an int, or +inf / -inf


# ---------------------------------------------------------------------------
# Core constructors and invariants
# ---------------------------------------------------------------------------

def normalize(f: Seq) -> Seq:
    """Drop zero coefficients so that `support` is exactly the keys."""
    return {n: c for n, c in f.items() if c != 0}


def support(f: Seq) -> list[int]:
    """The set of indices carrying a nonzero coefficient, sorted."""
    return sorted(normalize(f).keys())


def ord_index(f: Seq) -> Ext:
    """ord f: least index in the support; +inf for the zero sequence."""
    s = support(f)
    return min(s) if s else inf


def deg_index(f: Seq) -> Ext:
    """deg f: greatest index in the support; -inf for the zero sequence."""
    s = support(f)
    return max(s) if s else -inf


# ---------------------------------------------------------------------------
# Operations on sequences
# ---------------------------------------------------------------------------

def add(f: Seq, g: Seq) -> Seq:
    """Pointwise addition f + g."""
    out: Seq = dict(f)
    for n, c in g.items():
        out[n] = out.get(n, Fraction(0)) + c
    return normalize(out)


def cconv(f: Seq, g: Seq) -> Seq:
    """Ordinary Cauchy convolution: (f * g)_n = sum_{i+j=n} f_i g_j."""
    out: Seq = {}
    for i, a in f.items():
        for j, b in g.items():
            out[i + j] = out.get(i + j, Fraction(0)) + a * b
    return normalize(out)


def binconv(a: Seq, b: Seq) -> Seq:
    """Binomial (exponential) convolution: (a (*) b)_n = sum C(n,i) a_i b_{n-i}.

    This is the counting sequence of the structural product of two species.
    """
    out: Seq = {}
    for i, ai in a.items():
        for j, bj in b.items():
            n = i + j
            out[n] = out.get(n, Fraction(0)) + Fraction(comb(n, i)) * ai * bj
    return normalize(out)


# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------

def to_poly(f: Seq) -> str:
    """Render a sequence as a polynomial in x for human eyes."""
    f = normalize(f)
    if not f:
        return "0"
    parts = []
    for n in sorted(f):
        c = f[n]
        if n == 0:
            parts.append(f"{c}")
        elif n == 1:
            parts.append(f"{c}*x")
        else:
            parts.append(f"{c}*x^{n}")
    return " + ".join(parts)


def fmt(x: Ext) -> str:
    if x == inf:
        return "+inf (top)"
    if x == -inf:
        return "-inf (bot)"
    return str(x)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_extremal_indices() -> None:
    print("=" * 70)
    print("1. Order and degree of a finitely supported sequence")
    print("=" * 70)
    f = normalize({2: Fraction(3), 5: Fraction(7), 9: Fraction(-2)})
    print(f"  f = {to_poly(f)}")
    print(f"  ord f = {fmt(ord_index(f))}   (least index in support)")
    print(f"  deg f = {fmt(deg_index(f))}   (greatest index in support)")
    z: Seq = {}
    print(f"  ord 0 = {fmt(ord_index(z))},  deg 0 = {fmt(deg_index(z))}")
    print()


def demo_addition_inequalities() -> None:
    print("=" * 70)
    print("2. Tropical addition laws are INEQUALITIES (cancellation possible)")
    print("=" * 70)
    # Cancellation at the top: degree collapses.
    f = normalize({9: Fraction(1)})
    g = normalize({3: Fraction(1), 9: Fraction(-1)})
    s = add(f, g)
    print("  Top cancellation:")
    print(f"    f = {to_poly(f)},  g = {to_poly(g)}")
    print(f"    f + g = {to_poly(s)}")
    print(f"    deg(f+g) = {fmt(deg_index(s))}  <=  "
          f"max(deg f, deg g) = {fmt(max(deg_index(f), deg_index(g)))}   (STRICT)")
    # Cancellation at the bottom: order rises.
    p = normalize({2: Fraction(5), 4: Fraction(1)})
    q = normalize({2: Fraction(-5), 6: Fraction(1)})
    r = add(p, q)
    print("  Bottom cancellation:")
    print(f"    p = {to_poly(p)},  q = {to_poly(q)}")
    print(f"    p + q = {to_poly(r)}")
    print(f"    min(ord p, ord q) = {fmt(min(ord_index(p), ord_index(q)))}  <=  "
          f"ord(p+q) = {fmt(ord_index(r))}   (STRICT)")
    print()


def demo_convolution_exactness() -> None:
    print("=" * 70)
    print("3. Cauchy convolution: extremal indices add EXACTLY")
    print("=" * 70)
    f = normalize({2: Fraction(3), 5: Fraction(7), 9: Fraction(-2)})
    g = normalize({1: Fraction(4), 4: Fraction(-1), 6: Fraction(5)})
    h = cconv(f, g)
    print(f"  f = {to_poly(f)}")
    print(f"  g = {to_poly(g)}")
    print(f"  f * g = {to_poly(h)}")
    print(f"  ord(f*g) = {fmt(ord_index(h))}  =?=  "
          f"ord f + ord g = {ord_index(f) + ord_index(g)}")
    print(f"  deg(f*g) = {fmt(deg_index(h))}  =?=  "
          f"deg f + deg g = {deg_index(f) + deg_index(g)}")
    assert ord_index(h) == ord_index(f) + ord_index(g)
    assert deg_index(h) == deg_index(f) + deg_index(g)
    # The unique extremal contributing pair at index ord f + ord g.
    a, b = ord_index(f), ord_index(g)
    print(f"  Unique extremal pair at index {a + b}: (i,j) = ({a},{b}), "
          f"coeff = f_{a} * g_{b} = {f[a]} * {g[b]} = {f[a] * g[b]}")
    print("  => exactness PASSES.")
    print()


def demo_species_binomial() -> None:
    print("=" * 70)
    print("4. Species corollary: binomial convolution extremal profile")
    print("=" * 70)
    # a: minimal structure at size 1 (e.g. nonempty pointed gadget bounded to size 3)
    a = normalize({1: Fraction(1), 3: Fraction(2)})
    # b: minimal structure at size 2
    b = normalize({2: Fraction(1), 4: Fraction(3)})
    c = binconv(a, b)
    print(f"  a = {to_poly(a)}   (ord a = {fmt(ord_index(a))} = min structure size)")
    print(f"  b = {to_poly(b)}   (ord b = {fmt(ord_index(b))} = min structure size)")
    print(f"  a (*) b = {to_poly(c)}")
    print(f"  ord(a(*)b) = {fmt(ord_index(c))}  =?=  ord a + ord b = "
          f"{ord_index(a) + ord_index(b)}")
    print(f"  deg(a(*)b) = {fmt(deg_index(c))}  =?=  deg a + deg b = "
          f"{deg_index(a) + deg_index(b)}")
    assert ord_index(c) == ord_index(a) + ord_index(b)
    assert deg_index(c) == deg_index(a) + deg_index(b)
    n = ord_index(a) + ord_index(b)
    weight = comb(n, ord_index(a))
    print(f"  Minimal joint structure at size {n} exists in "
          f"C({n},{ord_index(a)}) = {weight} compatible block-splittings.")
    print("  => minimal sizes ADD under the structural product of species.")
    print()


def demo_randomized_check() -> None:
    print("=" * 70)
    print("5. Randomized stress test of all four laws")
    print("=" * 70)
    import random
    random.seed(2026)
    ok = True
    for _ in range(2000):
        f = normalize({random.randint(0, 8): Fraction(random.randint(-4, 4))
                       for _ in range(random.randint(0, 4))})
        g = normalize({random.randint(0, 8): Fraction(random.randint(-4, 4))
                       for _ in range(random.randint(0, 4))})
        s, h, bc = add(f, g), cconv(f, g), binconv(f, g)
        # Addition: inequalities.
        if not (min(ord_index(f), ord_index(g)) <= ord_index(s)):
            ok = False
        if not (deg_index(s) <= max(deg_index(f), deg_index(g))):
            ok = False
        # Convolution: exact (skip the all-zero degenerate, handled by +-inf algebra).
        if ord_index(h) != ord_index(f) + ord_index(g):
            ok = False
        if deg_index(h) != deg_index(f) + deg_index(g):
            ok = False
        if ord_index(bc) != ord_index(f) + ord_index(g):
            ok = False
        if deg_index(bc) != deg_index(f) + deg_index(g):
            ok = False
    print(f"  2000 random trials: {'ALL LAWS HOLD' if ok else 'FAILURE'}")
    print()


if __name__ == "__main__":
    demo_extremal_indices()
    demo_addition_inequalities()
    demo_convolution_exactness()
    demo_species_binomial()
    demo_randomized_check()
    print("All demonstrations complete.")
