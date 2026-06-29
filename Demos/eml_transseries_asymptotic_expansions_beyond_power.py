"""
EML Transseries: Numerical and Symbolic Demonstrations
======================================================

A self-contained Python companion to the formal development of the field of
transseries modeled as Hahn series over the lexicographically ordered group of
transmonomials ``TransMono = Lex(Z ->f R)``.

A *transmonomial* is a product

    ... (e^(e^x))^a2 * (e^x)^a1 * x^a0 * (log x)^a(-1) ...

with finitely many nonzero real exponents indexed by an integer *tower height* h
(h = 0 is x, h = 1 is e^x, h = -1 is log x, h = 2 is e^(e^x), ...). We represent a
transmonomial as a dict mapping height -> real exponent (zero exponents omitted),
and a (truncated) transseries as a dict mapping transmonomial -> real coefficient.

This script demonstrates, with numbers you can check, the main formal theorems:

  * mono_lt_mono_of_height / mono_lt_mono_same : the lex order is dominance.
  * exp_dominates_pow                          : e^x beats x^a for every real a.
  * isLittleO_pow_exp                          : analytic shadow, x^n = o(e^x).
  * agreeToAllOrders_iff_eq                    : the asymptotic comparison theorem.
  * valueGroup_divisible / exists_nthRoot_term : monomial roots via real exponents.
  * laurent_value_group_not_divisible          : the Z obstruction (no sqrt of x).
  * expShift_var                               : the x |-> e^x automorphism.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Dict, List, Optional, Tuple

# A transmonomial: height (int) -> real exponent (float). Zero exponents omitted.
Mono = Dict[int, float]
# A finite transseries: list of (transmonomial, coefficient) with nonzero coeffs.
Series = List[Tuple[Mono, float]]


# --------------------------------------------------------------------------- #
# 1. Dominance comparison of transmonomials (mono_lt_mono_* )                  #
# --------------------------------------------------------------------------- #
def compare_mono(a: Mono, b: Mono) -> int:
    """Return -1, 0, +1 according to whether a < b, a == b, a > b in asymptotic
    dominance. Highest tower height is most significant; within a height the
    larger real exponent dominates (this is the lexicographic order of Field.lean,
    realizing `mono_lt_mono_of_height` and `mono_lt_mono_same`)."""
    heights = sorted(set(a) | set(b), reverse=True)  # highest height first
    for h in heights:
        ea, eb = a.get(h, 0.0), b.get(h, 0.0)
        if ea < eb:
            return -1
        if ea > eb:
            return 1
    return 0


def mono_mul(a: Mono, b: Mono) -> Mono:
    """Multiply transmonomials = add exponents (the group operation)."""
    out: Mono = {}
    for h in set(a) | set(b):
        e = a.get(h, 0.0) + b.get(h, 0.0)
        if e != 0.0:
            out[h] = e
    return out


def mono_str(m: Mono) -> str:
    """Human-readable rendering, e.g. {1:1, 0:0.5} -> 'e^x * x^0.5'."""
    names = {1: "e^x", 0: "x", -1: "log x", 2: "e^(e^x)", -2: "log(log x)"}
    if not m:
        return "1"
    parts = []
    for h in sorted(m, reverse=True):
        base = names.get(h, f"L[{h}]")
        e = m[h]
        parts.append(base if e == 1.0 else f"{base}^{e:g}")
    return " * ".join(parts)


# --------------------------------------------------------------------------- #
# 2. Leading-term / valuation extraction (orderTop, leadingCoeff)             #
# --------------------------------------------------------------------------- #
def leading_term(s: Series) -> Optional[Tuple[Mono, float]]:
    """The dominant (orderTop) transmonomial and its leading coefficient, or None
    for the zero series. Models `orderTop` and `leadingCoeff`."""
    nz = [(m, c) for (m, c) in s if c != 0.0]
    if not nz:
        return None
    best = nz[0]
    for term in nz[1:]:
        if compare_mono(term[0], best[0]) > 0:
            best = term
    return best


# --------------------------------------------------------------------------- #
# 3. Asymptotic comparison theorem (agreeToAllOrders_iff_eq)                  #
# --------------------------------------------------------------------------- #
def series_sub(a: Series, b: Series) -> Series:
    """a - b, collecting coefficients by transmonomial (keyed by sorted items)."""
    acc: Dict[Tuple[Tuple[int, float], ...], float] = {}
    keep: Dict[Tuple[Tuple[int, float], ...], Mono] = {}
    for m, c in a:
        k = tuple(sorted(m.items()))
        acc[k] = acc.get(k, 0.0) + c
        keep[k] = m
    for m, c in b:
        k = tuple(sorted(m.items()))
        acc[k] = acc.get(k, 0.0) - c
        keep[k] = m
    return [(keep[k], v) for k, v in acc.items() if abs(v) > 1e-12]


def agree_to_all_orders(a: Series, b: Series) -> bool:
    """True iff a - b has no surviving transmonomial, i.e. orderTop(a-b) = top.
    By `agreeToAllOrders_iff_eq` this holds iff a == b as transseries."""
    return leading_term(series_sub(a, b)) is None


# --------------------------------------------------------------------------- #
# 4. Monomial n-th root and the Laurent obstruction                          #
# --------------------------------------------------------------------------- #
def nth_root_mono(m: Mono, n: int) -> Mono:
    """The n-th root of a transmonomial: divide every real exponent by n
    (`valueGroup_divisible`, `exists_nthRoot_term`). Always defined over R."""
    if n <= 0:
        raise ValueError("n must be positive")
    return {h: e / n for h, e in m.items() if e != 0.0}


def laurent_has_sqrt(exponent: int) -> bool:
    """Whether x^exponent has a square root *inside the integer-exponent Laurent
    field*: possible only if the exponent is even. `laurent_value_group_not_
    divisible`: 2k = 1 is unsolvable in Z, so x itself has no Laurent square root."""
    return exponent % 2 == 0


# --------------------------------------------------------------------------- #
# 5. The exp-shift automorphism (expShift_var: x |-> e^x)                     #
# --------------------------------------------------------------------------- #
def exp_shift_mono(m: Mono) -> Mono:
    """Raise every tower height by one: x -> e^x, e^x -> e^(e^x), log x -> x."""
    return {h + 1: e for h, e in m.items()}


def exp_shift(s: Series) -> Series:
    return [(exp_shift_mono(m), c) for m, c in s]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_dominance() -> None:
    print("=" * 70)
    print("1. Dominance: the lexicographic order is asymptotic dominance")
    print("=" * 70)
    # exp_dominates_pow: e^x beats x^a for every real a, even huge a.
    e_x: Mono = {1: 1.0}
    for a in (1.0, 10.0, 1e6, 1e100):
        x_a: Mono = {0: a}
        rel = compare_mono(x_a, e_x)
        print(f"  x^{a:<8g} vs e^x : {mono_str(x_a):>14} < e^x  ->  {rel == -1}")
    # mono_lt_mono_same: larger exponent wins at the same height.
    print(f"  x^2 < x^3 (same height) : {compare_mono({0: 2.0}, {0: 3.0}) == -1}")
    # height dominance: e^(e^x) beats any power of e^x.
    print(f"  (e^x)^1000 < e^(e^x)     : {compare_mono({1: 1000.0}, {2: 1.0}) == -1}")


def demo_little_o() -> None:
    print("=" * 70)
    print("2. Analytic grounding: isLittleO_pow_exp (x^n / e^x -> 0)")
    print("=" * 70)
    n = 5
    for x in (5.0, 20.0, 50.0, 100.0):
        ratio = x ** n / math.exp(x)
        print(f"  x={x:<6g}  x^{n}/e^x = {ratio:.3e}")
    # double exponential dominance: (e^x)^n / e^(e^x) -> 0
    print("  isLittleO_expPow_expExp: (e^x)^3 / e^(e^x)")
    for x in (1.0, 2.0, 3.0):
        ratio = math.exp(x) ** 3 / math.exp(math.exp(x))
        print(f"  x={x:<6g}  (e^x)^3 / e^(e^x) = {ratio:.3e}")


def demo_comparison() -> None:
    print("=" * 70)
    print("3. Asymptotic comparison theorem (agree to all orders <-> equal)")
    print("=" * 70)
    a: Series = [({1: 1.0}, 1.0), ({0: 1.0}, 3.0), ({}, -7.0)]   # e^x + 3x - 7
    b: Series = [({}, -7.0), ({1: 1.0}, 1.0), ({0: 1.0}, 3.0)]   # same, reordered
    c: Series = [({1: 1.0}, 1.0), ({0: 1.0}, 3.0), ({}, -7.0), ({-1: 1.0}, 1e-9)]
    print(f"  a = e^x + 3x - 7")
    print(f"  a agrees to all orders with reorder(a) : {agree_to_all_orders(a, b)}")
    print(f"  a agrees with a + 1e-9*log x           : {agree_to_all_orders(a, c)}")
    print(f"  (difference leading term: {mono_str(leading_term(series_sub(c, a))[0])})")


def demo_roots() -> None:
    print("=" * 70)
    print("4. Roots & real closure: real exponents vs the Z obstruction")
    print("=" * 70)
    x: Mono = {0: 1.0}  # the monomial x (exponent 1 at height 0)
    sqrt_x = nth_root_mono(x, 2)
    print(f"  sqrt(x) in transseries  = {mono_str(sqrt_x)}   (exponent 1/2 in R)")
    print(f"  check (sqrt(x))^2 = x    : {mono_mul(sqrt_x, sqrt_x) == x}")
    cube = nth_root_mono({1: 3.0, 0: 6.0}, 3)
    print(f"  cbrt(e^(3x) * x^6)       = {mono_str(cube)}")
    print(f"  Laurent field: x has integer sqrt? {laurent_has_sqrt(1)}  "
          f"(2k=1 unsolvable in Z)")
    print(f"  Laurent field: x^2 has integer sqrt? {laurent_has_sqrt(2)}")


def demo_exp_shift() -> None:
    print("=" * 70)
    print("5. Exp-shift automorphism: x |-> e^x raises every tower height")
    print("=" * 70)
    s: Series = [({0: 1.0}, 1.0), ({-1: 1.0}, 2.0), ({}, 5.0)]  # x + 2 log x + 5
    shifted = exp_shift(s)
    print(f"  expShift(x + 2 log x + 5) = "
          f"{' + '.join(f'{c:g}*{mono_str(m)}' for m, c in shifted)}")
    print(f"  expShift(x) = e^x        : {exp_shift_mono({0: 1.0}) == {1: 1.0}}")
    print(f"  expShift(log x) = x      : {exp_shift_mono({-1: 1.0}) == {0: 1.0}}")
    print(f"  expShift(e^x) = e^(e^x)  : {exp_shift_mono({1: 1.0}) == {2: 1.0}}")


if __name__ == "__main__":
    demo_dominance()
    demo_little_o()
    demo_comparison()
    demo_roots()
    demo_exp_shift()
    print("=" * 70)
    print("All demonstrations completed.")
    print("=" * 70)
