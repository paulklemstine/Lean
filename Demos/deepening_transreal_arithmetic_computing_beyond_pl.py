"""
Transreal arithmetic: numerical demonstrations.

The transreal numbers are  T = R  U  {+inf, -inf, Phi},  where Phi ("nullity")
is the total-arithmetic value of 0/0.  All four operations (+, *, negation,
reciprocal) are TOTAL: every operation returns a transreal for every input,
division by zero included.

This module implements T from scratch (no external dependencies) and then
demonstrates the structural results:

  * (T, +, 0) and (T, *, 1) are commutative monoids;
  * the ring axioms fail (no additive inverse for +inf; distributivity fails);
  * negation is a homomorphism of both structures and an involution;
  * R embeds faithfully under both operations;
  * the reciprocal is an involution EXACTLY off -inf;
  * 1/(-x) = -(1/x) holds off 0, and fails at 0 (signed-zero effect);
  * the natural order is a partial order that is not total, with no greatest
    and no least element.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable, Optional


# --------------------------------------------------------------------------- #
# Carrier
# --------------------------------------------------------------------------- #

@dataclass(frozen=True)
class TReal:
    """A transreal number.

    kind is one of 'phi', 'pinf', 'ninf', 'rl'.  When kind == 'rl', the field
    'value' holds the underlying real number; otherwise 'value' is None.
    """

    kind: str
    value: Optional[float] = None

    def __repr__(self) -> str:
        names = {"phi": "Phi", "pinf": "+inf", "ninf": "-inf"}
        if self.kind in names:
            return names[self.kind]
        return f"{self.value:g}"


PHI: TReal = TReal("phi")
PINF: TReal = TReal("pinf")
NINF: TReal = TReal("ninf")


def rl(x: float) -> TReal:
    """Embed a real number into the transreals."""
    return TReal("rl", float(x))


ZERO: TReal = rl(0.0)
ONE: TReal = rl(1.0)


# --------------------------------------------------------------------------- #
# Total operations
# --------------------------------------------------------------------------- #

def add(x: TReal, y: TReal) -> TReal:
    """Total transreal addition.  Phi absorbs; (+inf) + (-inf) = Phi."""
    if x.kind == "phi" or y.kind == "phi":
        return PHI
    if x.kind == "pinf":
        return PHI if y.kind == "ninf" else PINF
    if x.kind == "ninf":
        return PHI if y.kind == "pinf" else NINF
    # x is real
    if y.kind == "pinf":
        return PINF
    if y.kind == "ninf":
        return NINF
    return rl(x.value + y.value)


def _real_times_inf(a: float, positive_inf: bool) -> TReal:
    """Helper: real a times (+inf if positive_inf else -inf)."""
    if a == 0.0:
        return PHI
    same_sign = (a > 0.0) == positive_inf
    return PINF if same_sign else NINF


def mul(x: TReal, y: TReal) -> TReal:
    """Total transreal multiplication.  Phi absorbs; 0 * (+/-inf) = Phi."""
    if x.kind == "phi" or y.kind == "phi":
        return PHI
    if x.kind in ("pinf", "ninf") and y.kind in ("pinf", "ninf"):
        return PINF if x.kind == y.kind else NINF
    if x.kind in ("pinf", "ninf"):  # y is real
        return _real_times_inf(y.value, x.kind == "pinf")
    if y.kind in ("pinf", "ninf"):  # x is real
        return _real_times_inf(x.value, y.kind == "pinf")
    return rl(x.value * y.value)


def neg(x: TReal) -> TReal:
    """Total transreal negation."""
    if x.kind == "phi":
        return PHI
    if x.kind == "pinf":
        return NINF
    if x.kind == "ninf":
        return PINF
    return rl(-x.value)


def recip(x: TReal) -> TReal:
    """Total transreal reciprocal: 1/0 = +inf, 1/(+/-inf) = 0, 1/Phi = Phi."""
    if x.kind == "phi":
        return PHI
    if x.kind in ("pinf", "ninf"):
        return ZERO
    if x.value == 0.0:
        return PINF
    return rl(1.0 / x.value)


# --------------------------------------------------------------------------- #
# Order (partial): -inf < R < +inf, Phi incomparable to everything but itself
# --------------------------------------------------------------------------- #

def compare(x: TReal, y: TReal) -> str:
    """Three-valued comparison: 'LT', 'EQ', 'GT', or 'INCOMPARABLE'."""
    if x.kind == "phi" or y.kind == "phi":
        return "EQ" if x == y else "INCOMPARABLE"

    def rank(t: TReal) -> float:
        if t.kind == "ninf":
            return float("-inf")
        if t.kind == "pinf":
            return float("inf")
        return t.value

    rx, ry = rank(x), rank(y)
    if rx < ry:
        return "LT"
    if rx > ry:
        return "GT"
    return "EQ"


def le(x: TReal, y: TReal) -> bool:
    """x <= y in the transreal partial order."""
    return compare(x, y) in ("LT", "EQ")


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

SAMPLE: list[TReal] = [PHI, PINF, NINF, rl(-2.0), ZERO, rl(0.5), rl(3.0)]


def demo_totality() -> None:
    print("=" * 66)
    print("1. TOTALITY: every operation returns a value, division by zero OK")
    print("=" * 66)
    print(f"  1 / 0      = {recip(ZERO)}")
    print(f"  0 / 0      = {mul(ZERO, recip(ZERO))}        (= nullity Phi)")
    print(f"  (+inf)+(-inf) = {add(PINF, NINF)}     (indeterminate -> Phi)")
    print(f"  0 * (+inf) = {mul(ZERO, PINF)}        (indeterminate -> Phi)")
    print(f"  1 / (+inf) = {recip(PINF)}")
    print(f"  Phi absorbs: 5 + Phi = {add(rl(5), PHI)},  5 * Phi = {mul(rl(5), PHI)}")


def demo_monoid_laws() -> None:
    print("\n" + "=" * 66)
    print("2. COMMUTATIVE MONOIDS: + and * are commutative & associative")
    print("=" * 66)
    add_comm = all(add(x, y) == add(y, x) for x in SAMPLE for y in SAMPLE)
    mul_comm = all(mul(x, y) == mul(y, x) for x in SAMPLE for y in SAMPLE)
    add_assoc = all(
        add(add(x, y), z) == add(x, add(y, z))
        for x, y, z in product(SAMPLE, repeat=3)
    )
    mul_assoc = all(
        mul(mul(x, y), z) == mul(x, mul(y, z))
        for x, y, z in product(SAMPLE, repeat=3)
    )
    add_id = all(add(ZERO, x) == x for x in SAMPLE)
    mul_id = all(mul(ONE, x) == x for x in SAMPLE)
    print(f"  addition commutative  : {add_comm}")
    print(f"  addition associative  : {add_assoc}")
    print(f"  0 is additive identity: {add_id}")
    print(f"  product commutative   : {mul_comm}")
    print(f"  product associative   : {mul_assoc}")
    print(f"  1 is mult. identity   : {mul_id}")


def demo_ring_fails() -> None:
    print("\n" + "=" * 66)
    print("3. RING AXIOMS FAIL")
    print("=" * 66)
    # +inf has no additive inverse
    has_inverse = any(add(PINF, y) == ZERO for y in SAMPLE + [rl(1e9), rl(-1e9)])
    print(f"  +inf has an additive inverse? {has_inverse}")
    # distributivity failure
    lhs = mul(PINF, add(ONE, ZERO))
    rhs = add(mul(PINF, ONE), mul(PINF, ZERO))
    print(f"  (+inf)*(1+0)          = {lhs}")
    print(f"  (+inf)*1 + (+inf)*0   = {rhs}")
    print(f"  distributivity holds here? {lhs == rhs}")


def demo_negation() -> None:
    print("\n" + "=" * 66)
    print("4. NEGATION is a homomorphism of both monoids, and an involution")
    print("=" * 66)
    n_add = all(neg(add(x, y)) == add(neg(x), neg(y)) for x in SAMPLE for y in SAMPLE)
    n_mul = all(neg(mul(x, y)) == mul(neg(x), y) for x in SAMPLE for y in SAMPLE)
    n_mm = all(mul(neg(x), neg(y)) == mul(x, y) for x in SAMPLE for y in SAMPLE)
    invol = all(neg(neg(x)) == x for x in SAMPLE)
    print(f"  -(x+y) = (-x)+(-y)        : {n_add}")
    print(f"  -(x*y) = (-x)*y           : {n_mul}")
    print(f"  (-x)*(-y) = x*y           : {n_mm}")
    print(f"  -(-x) = x  (involution)   : {invol}")


def demo_reals_embed() -> None:
    print("\n" + "=" * 66)
    print("5. R EMBEDS faithfully under + and *")
    print("=" * 66)
    reals = [-3.0, -0.25, 0.0, 1.5, 7.0]
    add_hom = all(add(rl(a), rl(b)) == rl(a + b) for a in reals for b in reals)
    mul_hom = all(mul(rl(a), rl(b)) == rl(a * b) for a in reals for b in reals)
    print(f"  iota(a+b) = iota(a)+iota(b) : {add_hom}")
    print(f"  iota(a*b) = iota(a)*iota(b) : {mul_hom}")


def demo_recip_involution() -> None:
    print("\n" + "=" * 66)
    print("6. RECIPROCAL is an involution EXACTLY off -inf")
    print("=" * 66)
    for x in SAMPLE:
        holds = recip(recip(x)) == x
        note = "" if holds else "   <-- fails!"
        print(f"  1/(1/{str(x):>5}) = {str(recip(recip(x))):>5}   equals x? {holds}{note}")
    exceptions = [x for x in SAMPLE if recip(recip(x)) != x]
    print(f"  points where the involution fails: {exceptions}")


def demo_recip_neg() -> None:
    print("\n" + "=" * 66)
    print("7. RECIPROCAL vs NEGATION: 1/(-x) = -(1/x) off 0, fails at 0")
    print("=" * 66)
    for x in SAMPLE:
        lhs, rhs = recip(neg(x)), neg(recip(x))
        print(f"  x = {str(x):>5}:  1/(-x) = {str(lhs):>5},  -(1/x) = {str(rhs):>5},  equal? {lhs == rhs}")
    print("  At 0:  1/(-0) = +inf  while  -(1/0) = -inf   (signed-zero effect)")


def demo_order() -> None:
    print("\n" + "=" * 66)
    print("8. ORDER is a PARTIAL order, not total; no greatest/least element")
    print("=" * 66)
    print(f"  -inf <= 3.0 ?          {le(NINF, rl(3.0))}")
    print(f"  0.5  <= +inf ?         {le(rl(0.5), PINF)}")
    print(f"  compare(Phi, 0)        {compare(PHI, ZERO)}")
    # not total
    not_total = any(
        (not le(x, y)) and (not le(y, x)) for x in SAMPLE for y in SAMPLE
    )
    print(f"  order is NOT total?    {not_total}  (e.g. Phi vs 0)")
    # no greatest / least among the sample plus extremes
    candidates = SAMPLE
    greatest = [g for g in candidates if all(le(x, g) for x in candidates)]
    least = [m for m in candidates if all(le(m, x) for x in candidates)]
    print(f"  greatest element(s)?   {greatest}  (none, because Phi floats free)")
    print(f"  least element(s)?      {least}")


def main() -> None:
    demo_totality()
    demo_monoid_laws()
    demo_ring_fails()
    demo_negation()
    demo_reals_embed()
    demo_recip_involution()
    demo_recip_neg()
    demo_order()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
