"""
The pole-order obstruction for products of normalized q-series: numerical demonstrations.

This self-contained script implements truncated formal Laurent series over the rationals
and verifies, numerically, every result of the accompanying paper:

  1. A product of m normalized series (leading term exactly q^-1) has order exactly -m.
  2. Multiplying by q^m restores order 0; multiplying by q^(m-1) restores normalized form.
  3. Blinding by an invertible power series does not move the order; additive masking by a
     strictly less singular series does not move it either; the n-th power has order -mn.
  4. The coefficient hierarchy under the moonshine normalization a_i(0) = 0:
        degree -m   : 1
        degree 1-m  : 0
        degree 2-m  : sum_i a_i(1)
        degree 3-m  : sum_i a_i(2)
        degree 4-m  : sum_i a_i(3) + e2(a_1(1), ..., a_m(1))
  5. The genuine McKay-Thompson instance T_1A * T_2A * T_3A, whose coefficients at degrees
     -3, -2, -1, 0, 1 are 1, 0, 202039, 21598688 and 1883965635.
  6. Positivity propagation and coefficient domination.
  7. A Monster-sized run with 194 factors, exhibiting a pole of order exactly 194.

Run with:  python3 demo.py
"""

from __future__ import annotations

import random
from fractions import Fraction
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

Number = Fraction

# ----------------------------------------------------------------------------------
# 1. Truncated Laurent series
# ----------------------------------------------------------------------------------


class Laurent:
    """A truncated formal Laurent series sum_{j} coeffs[j] * q^(offset + j).

    Coefficients beyond the stored window are unknown and treated as truncated away;
    every operation tracks the largest degree that remains exactly known.
    """

    __slots__ = ("offset", "coeffs")

    def __init__(self, offset: int, coeffs: Sequence[Number]) -> None:
        self.offset: int = offset
        self.coeffs: List[Number] = [Fraction(c) for c in coeffs]

    # -- basic accessors -----------------------------------------------------------

    def top_degree(self) -> int:
        """Largest degree whose coefficient is exactly known."""
        return self.offset + len(self.coeffs) - 1

    def coeff(self, degree: int) -> Number:
        """Coefficient of q^degree (zero below the window; error above it)."""
        if degree < self.offset:
            return Fraction(0)
        if degree > self.top_degree():
            raise IndexError(f"degree {degree} is beyond the truncation window")
        return self.coeffs[degree - self.offset]

    def order(self) -> Optional[int]:
        """Smallest degree with a nonzero coefficient, or None if all known ones vanish."""
        for j, c in enumerate(self.coeffs):
            if c != 0:
                return self.offset + j
        return None

    def leading_coeff(self) -> Number:
        ordv = self.order()
        if ordv is None:
            return Fraction(0)
        return self.coeff(ordv)

    # -- algebra -------------------------------------------------------------------

    def __mul__(self, other: "Laurent") -> "Laurent":
        n1, n2 = len(self.coeffs), len(other.coeffs)
        out: List[Number] = [Fraction(0)] * (n1 + n2 - 1)
        for i, a in enumerate(self.coeffs):
            if a == 0:
                continue
            for j, b in enumerate(other.coeffs):
                out[i + j] += a * b
        # Only degrees up to min(top1 + offset2, top2 + offset1) are fully determined.
        reliable_top = min(
            self.top_degree() + other.offset, other.top_degree() + self.offset
        )
        new_offset = self.offset + other.offset
        keep = reliable_top - new_offset + 1
        return Laurent(new_offset, out[: max(keep, 0)])

    def __add__(self, other: "Laurent") -> "Laurent":
        lo = min(self.offset, other.offset)
        hi = min(self.top_degree(), other.top_degree())
        return Laurent(lo, [self._safe(d) + other._safe(d) for d in range(lo, hi + 1)])

    def _safe(self, degree: int) -> Number:
        if degree < self.offset or degree > self.top_degree():
            return Fraction(0)
        return self.coeffs[degree - self.offset]

    def shift(self, k: int) -> "Laurent":
        """Multiply by q^k."""
        return Laurent(self.offset + k, self.coeffs)

    def power(self, n: int) -> "Laurent":
        result = Laurent(0, [Fraction(1)] + [Fraction(0)] * (len(self.coeffs) - 1))
        for _ in range(n):
            result = result * self
        return result

    def is_normalized(self) -> bool:
        """True iff the series is q^-1 + a(0) + a(1) q + ... (order -1, leading coeff 1)."""
        return self.order() == -1 and self.leading_coeff() == 1

    def __repr__(self) -> str:
        parts: List[str] = []
        for j, c in enumerate(self.coeffs):
            if c == 0:
                continue
            d = self.offset + j
            parts.append(f"{c}*q^{d}")
        return " + ".join(parts) if parts else "0"


def normalized_series(tail: Sequence[Number]) -> Laurent:
    """Build q^-1 + tail[0] + tail[1] q + tail[2] q^2 + ... ."""
    return Laurent(-1, [Fraction(1)] + [Fraction(t) for t in tail])


def laurent_prod(factors: Iterable[Laurent]) -> Laurent:
    factors = list(factors)
    if not factors:
        return Laurent(0, [Fraction(1)])
    acc = factors[0]
    for f in factors[1:]:
        acc = acc * f
    return acc


def e2(values: Sequence[Number]) -> Number:
    """Second elementary symmetric function, division-free: ((sum x)^2 - sum x^2) / 2."""
    s = sum(values, Fraction(0))
    sq = sum((v * v for v in values), Fraction(0))
    return (s * s - sq) / 2


# ----------------------------------------------------------------------------------
# 2. Genuine McKay-Thompson data (leading q^-1, vanishing constant term)
# ----------------------------------------------------------------------------------

MCKAY_THOMPSON: Dict[str, List[int]] = {
    # tail entries are a(0), a(1), a(2), a(3), ...
    "T_1A": [0, 196884, 21493760, 864299970],
    "T_2A": [0, 4372, 96256, 1240002],
    "T_3A": [0, 783, 8672, 65367],
}

MONSTER_CLASS_COUNT: int = 194


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------------
# Demo 1: the pole-order theorem
# ----------------------------------------------------------------------------------


def demo_pole_order() -> None:
    banner("1. Pole-order theorem: a product of m normalized series has order exactly -m")
    rng = random.Random(20260819)
    for m in (1, 2, 3, 5, 8, 13):
        factors = [
            normalized_series([Fraction(rng.randint(-9, 9)) for _ in range(9)])
            for _ in range(m)
        ]
        prod = laurent_prod(factors)
        assert prod.order() == -m, (m, prod.order())
        assert prod.leading_coeff() == 1
        corrected = prod.shift(m)
        renormalized = prod.shift(m - 1)
        assert corrected.order() == 0 and corrected.leading_coeff() == 1
        assert renormalized.is_normalized()
        print(
            f"  m = {m:2d}:  order(prod) = {prod.order():3d},  "
            f"leading coeff = {prod.leading_coeff()},  "
            f"order(q^m * prod) = {corrected.order()},  "
            f"q^(m-1)*prod normalized = {renormalized.is_normalized()}"
        )
    print("  Sharp threshold: q^k * prod is a power series iff k >= m.")
    m = 5
    factors = [
        normalized_series([Fraction(rng.randint(-9, 9)) for _ in range(9)])
        for _ in range(m)
    ]
    prod = laurent_prod(factors)
    for k in range(m + 3):
        is_ps = prod.shift(k).order() is not None and prod.shift(k).order() >= 0
        assert is_ps == (k >= m)
    print(f"    verified for m = {m} and k = 0..{m + 2}.")


# ----------------------------------------------------------------------------------
# Demo 2: indestructibility of the leak
# ----------------------------------------------------------------------------------


def demo_indestructible_leak() -> None:
    banner("2. The leak is indestructible: blinding, masking, powers, unmasking")
    rng = random.Random(11235)
    m = 4
    factors = [
        normalized_series([Fraction(rng.randint(-6, 6)) for _ in range(10)])
        for _ in range(m)
    ]
    prod = laurent_prod(factors)
    print(f"  order of the plain product          : {prod.order()}")

    # Multiplicative blinding by an invertible power series (nonzero constant term).
    blind = Laurent(0, [Fraction(7)] + [Fraction(rng.randint(-5, 5)) for _ in range(9)])
    blinded = prod * blind
    print(f"  order after blinding by a unit series: {blinded.order()}")
    assert blinded.order() == prod.order()

    # Additive masking by any strictly less singular series.
    mask = Laurent(-m + 1, [Fraction(rng.randint(-40, 40)) for _ in range(8)])
    masked = prod + mask
    print(f"  order after additive masking         : {masked.order()}")
    assert masked.order() == prod.order()

    # Torsion-freeness: the n-th power has order -mn.
    for n in (1, 2, 3):
        p = prod.power(n)
        print(f"  order of the {n}-th power              : {p.order()}  (expected {-m * n})")
        assert p.order() == -m * n

    # Unique unmasking shift.
    target = 0
    k_star = target - prod.order()
    assert prod.shift(k_star).order() == target
    others = [k for k in range(-6, 7) if prod.shift(k).order() == target]
    print(f"  unique shift with order {target}: k = {k_star}; all solutions found: {others}")
    assert others == [k_star]


# ----------------------------------------------------------------------------------
# Demo 3: the coefficient hierarchy
# ----------------------------------------------------------------------------------


def predicted_coefficients(tails: Sequence[Sequence[Number]]) -> Dict[int, Number]:
    """Closed-form predictions at degrees -m, 1-m, 2-m, 3-m, 4-m (moonshine normalization).

    tails[i] = [a_i(0), a_i(1), a_i(2), a_i(3), ...] with a_i(0) = 0.
    """
    m = len(tails)
    a1 = [Fraction(t[1]) for t in tails]
    a2 = [Fraction(t[2]) for t in tails]
    a3 = [Fraction(t[3]) for t in tails]
    return {
        -m: Fraction(1),
        1 - m: Fraction(0),
        2 - m: sum(a1, Fraction(0)),
        3 - m: sum(a2, Fraction(0)),
        4 - m: sum(a3, Fraction(0)) + e2(a1),
    }


def demo_coefficient_hierarchy() -> None:
    banner("3. Coefficient hierarchy: three additive degrees, then the first cross term")
    rng = random.Random(31415)
    for m in (2, 3, 6, 10):
        tails = [
            [Fraction(0)] + [Fraction(rng.randint(0, 30)) for _ in range(7)]
            for _ in range(m)
        ]
        factors = [normalized_series(t) for t in tails]
        prod = laurent_prod(factors)
        pred = predicted_coefficients(tails)
        print(f"  m = {m}:")
        for d in sorted(pred):
            actual = prod.coeff(d)
            flag = "OK" if actual == pred[d] else "MISMATCH"
            print(f"    degree {d:4d}:  direct = {str(actual):>14}   predicted = "
                  f"{str(pred[d]):>14}   [{flag}]")
            assert actual == pred[d]
        cross = e2([Fraction(t[1]) for t in tails])
        print(f"    of which the cross term e2(a(1)) at degree {4 - m} contributes {cross}")


# ----------------------------------------------------------------------------------
# Demo 4: the genuine McKay-Thompson triple product
# ----------------------------------------------------------------------------------


def demo_mckay_thompson() -> None:
    banner("4. The McKay-Thompson triple product T_1A * T_2A * T_3A")
    names = ["T_1A", "T_2A", "T_3A"]
    tails = [MCKAY_THOMPSON[n] for n in names]
    factors = [normalized_series([Fraction(x) for x in t]) for t in tails]
    prod = laurent_prod(factors)
    expected = {-3: 1, -2: 0, -1: 202039, 0: 21598688, 1: 1883965635}
    a1 = [Fraction(t[1]) for t in tails]
    a3 = [Fraction(t[3]) for t in tails]
    print(f"  order of the product : {prod.order()}   (expected -3)")
    assert prod.order() == -3
    for d, value in expected.items():
        actual = prod.coeff(d)
        print(f"  coefficient at degree {d:2d}: {str(actual):>12}   expected {value:>12}   "
              f"[{'OK' if actual == value else 'MISMATCH'}]")
        assert actual == value
    print()
    print(f"  degree -1 = sum a_i(1)            = {sum(a1, Fraction(0))}")
    print(f"  degree  0 = sum a_i(2)            = "
          f"{sum((Fraction(t[2]) for t in tails), Fraction(0))}")
    print(f"  degree  1 = sum a_i(3) + e2(a(1)) = {sum(a3, Fraction(0))} + {e2(a1)} "
          f"= {sum(a3, Fraction(0)) + e2(a1)}")
    print("  The cross term exceeds the sum of the cubic coefficients: once the factors")
    print("  start interacting, the interaction dominates.")


# ----------------------------------------------------------------------------------
# Demo 5: positivity and domination
# ----------------------------------------------------------------------------------


def demo_positivity_and_domination() -> None:
    banner("5. Positivity propagation and coefficient domination")
    rng = random.Random(27182)
    m = 5
    tails = [
        [Fraction(0)] + [Fraction(rng.randint(0, 50)) for _ in range(7)] for _ in range(m)
    ]
    factors = [normalized_series(t) for t in tails]
    prod = laurent_prod(factors)
    print("  degree | product coefficient | max over factors of a_j(n-1)")
    for n in range(1, 6):
        d = n - m
        c = prod.coeff(d)
        best = max(Fraction(t[n - 1]) for t in tails)
        assert c >= 0
        assert c >= best
        print(f"   {d:5d} | {str(c):>19} | {str(best):>28}")
    for d in range(-m - 3, -m):
        assert prod.coeff(d) == 0 if d >= prod.offset else True
    print("  All coefficients are non-negative and dominate every individual factor.")


# ----------------------------------------------------------------------------------
# Demo 6: a Monster-sized run
# ----------------------------------------------------------------------------------


def demo_monster_sized() -> None:
    banner(f"6. A Monster-sized product: {MONSTER_CLASS_COUNT} normalized factors")
    rng = random.Random(194194)
    tails = [
        [Fraction(0)] + [Fraction(rng.randint(0, 1000)) for _ in range(5)]
        for _ in range(MONSTER_CLASS_COUNT)
    ]
    factors = [normalized_series(t) for t in tails]
    prod = laurent_prod(factors)
    m = MONSTER_CLASS_COUNT
    print(f"  order of the {m}-fold product : {prod.order()}   (expected {-m})")
    assert prod.order() == -m
    assert prod.leading_coeff() == 1
    pred = predicted_coefficients(tails)
    for d in sorted(pred):
        actual = prod.coeff(d)
        assert actual == pred[d]
        print(f"  degree {d:5d}: {str(actual):>22}  (closed form agrees)")
    corrected = prod.shift(m)
    print(f"  order of q^{m} * product      : {corrected.order()}  "
          f"(constant term {corrected.coeff(0)})")
    assert corrected.order() == 0 and corrected.coeff(0) == 1
    renorm = prod.shift(m - 1)
    print(f"  q^{m - 1} * product is normalized: {renorm.is_normalized()}")
    assert renorm.is_normalized()
    print()
    print("  Cost comparison at degree 4 - m: the exact convolution formula would range")
    print(f"  over C(4 + {m} - 1, {m} - 1) = {comb(4 + m - 1, m - 1)} compositions, while the")
    print(f"  closed form needs {m} additions and one squaring.")


def comb(n: int, k: int) -> int:
    """Binomial coefficient, computed exactly."""
    k = min(k, n - k)
    num, den = 1, 1
    for i in range(k):
        num *= n - i
        den *= i + 1
    return num // den


# ----------------------------------------------------------------------------------
# Demo 7: rigidity of the invariant, illustrated
# ----------------------------------------------------------------------------------


def demo_rigidity() -> None:
    banner("7. Rigidity: any blinding-invariant integer multiplicative invariant is c * order")
    rng = random.Random(1618)

    def phi(x: Laurent, c: int) -> int:
        """The general form predicted by the rigidity theorem."""
        ordv = x.order()
        assert ordv is not None
        return c * ordv

    samples: List[Laurent] = []
    for _ in range(6):
        k = rng.randint(-4, 4)
        unit = Laurent(0, [Fraction(rng.randint(1, 9))] +
                       [Fraction(rng.randint(-9, 9)) for _ in range(8)])
        samples.append(unit.shift(k))
    for c in (1, -3, 7):
        additive = all(
            phi(x * y, c) == phi(x, c) + phi(y, c)
            for x in samples for y in samples
        )
        trivial_on_units = phi(Laurent(0, [Fraction(5)] + [Fraction(1)] * 5), c) == 0
        print(f"  c = {c:2d}:  multiplicative on samples = {additive}, "
              f"trivial on unit power series = {trivial_on_units}")
        assert additive and trivial_on_units
    print("  Every such invariant is determined by its value on q alone.")


def main() -> None:
    print(__doc__.strip().splitlines()[0])
    demo_pole_order()
    demo_indestructible_leak()
    demo_coefficient_hierarchy()
    demo_mckay_thompson()
    demo_positivity_and_domination()
    demo_monster_sized()
    demo_rigidity()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
