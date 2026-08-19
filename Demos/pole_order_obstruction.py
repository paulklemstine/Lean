"""
The Pole-Order Obstruction for Products of Normalized q-Series
==============================================================

Numerical demonstration of the results:

  * Orders add:  ord(f*g) = ord(f) + ord(g),  with equality (no cancellation),
    because the coefficient field is an integral domain.

  * Pole-Order Theorem: a product of m NORMALIZED series
        f = q^{-1} + a_0 + a_1 q + a_2 q^2 + ...
    has order EXACTLY -m and leading coefficient EXACTLY 1.

  * Non-closure: the product is normalized  <=>  m = 1.

  * Unique correction: ord(q^k * prod) = 0  <=>  k = m.

  * Unit structure: q^m * prod(f_i) = prod(U(f_i)) is a power series with
    constant term 1, hence a UNIT of C[[q]] (we exhibit its inverse).

  * Unique factorization: every normalized f equals q^{-1} * U(f) with
    U(f) a power series of constant term 1, uniquely.

  * Newton identities past the pole:
        coeff at q^{1-m}  =  sum_i a_i
      2*coeff at q^{2-m}  =  2*sum_i b_i + (sum_i a_i)^2 - sum_i a_i^2
    where f_i = q^{-1} + a_i + b_i q + ...

  * Monster specialization: 194 normalized trace series give a pole of order
    exactly 194; with the moonshine normalization a_i = 0 the coefficient at
    q^{-193} vanishes and the coefficient at q^{-192} is the character sum
    sum_g c_g(1).

  * The two-factor moonshine instance
        J * T_{2A} = q^{-2} + 0*q^{-1} + 201256 + ...
    with 201256 = 196884 + 4372.

All arithmetic is exact (Python integers / Fractions). Run with:  python demo.py
"""

from __future__ import annotations

import random
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple

Scalar = Fraction

# ----------------------------------------------------------------------------
# Truncated Laurent series
# ----------------------------------------------------------------------------


class Laurent:
    """A formal Laurent series truncated to a finite window of exponents.

    The series is stored as a starting exponent ``val`` together with a list of
    coefficients, ``coeffs[j]`` being the coefficient of ``q**(val + j)``.  The
    window is *exact*: every coefficient in degrees ``val .. val+len-1`` is
    correct, and nothing is claimed beyond.
    """

    __slots__ = ("val", "coeffs")

    def __init__(self, val: int, coeffs: Sequence[Scalar]) -> None:
        self.val: int = val
        self.coeffs: List[Scalar] = [Fraction(c) for c in coeffs]

    # -- basic accessors ----------------------------------------------------

    def __len__(self) -> int:
        return len(self.coeffs)

    def coeff(self, n: int) -> Scalar:
        """Coefficient of ``q**n`` (zero outside the stored window)."""
        j = n - self.val
        if 0 <= j < len(self.coeffs):
            return self.coeffs[j]
        return Fraction(0)

    def order(self) -> float | int:
        """Smallest exponent with nonzero coefficient; ``inf`` if all vanish.

        Returning ``math.inf`` for the zero series mirrors the convention that
        the order takes values in Z u {infinity}, with infinity absorbing under
        addition.  This convention is *required* for unrestricted additivity.
        """
        for j, c in enumerate(self.coeffs):
            if c != 0:
                return self.val + j
        return float("inf")

    def leading_coeff(self) -> Scalar:
        for c in self.coeffs:
            if c != 0:
                return c
        return Fraction(0)

    # -- ring operations ----------------------------------------------------

    def __mul__(self, other: "Laurent") -> "Laurent":
        n = min(len(self), len(other))
        out: List[Scalar] = [Fraction(0)] * n
        for i, a in enumerate(self.coeffs):
            if a == 0 or i >= n:
                continue
            for j, b in enumerate(other.coeffs):
                if i + j >= n:
                    break
                out[i + j] += a * b
        return Laurent(self.val + other.val, out)

    def shift(self, k: int) -> "Laurent":
        """Multiply by ``q**k``."""
        return Laurent(self.val + k, list(self.coeffs))

    def truncate(self, n: int) -> "Laurent":
        return Laurent(self.val, self.coeffs[:n])

    # -- display ------------------------------------------------------------

    def __repr__(self) -> str:
        parts: List[str] = []
        for j, c in enumerate(self.coeffs):
            if c == 0:
                continue
            e = self.val + j
            cs = str(c) if c.denominator != 1 else str(c.numerator)
            if e == 0:
                parts.append(cs)
            elif e == 1:
                parts.append(f"{cs}*q")
            else:
                parts.append(f"{cs}*q^{e}")
        return " + ".join(parts) + " + ..." if parts else "0"


def one(width: int = 8) -> Laurent:
    return Laurent(0, [Fraction(1)] + [Fraction(0)] * (width - 1))


def q_pow(k: int, width: int = 8) -> Laurent:
    return Laurent(k, [Fraction(1)] + [Fraction(0)] * (width - 1))


def product(series: Iterable[Laurent], width: int = 8) -> Laurent:
    acc = one(width)
    for f in series:
        acc = acc * f
    return acc


# ----------------------------------------------------------------------------
# Normalized series and their unit parts
# ----------------------------------------------------------------------------


def normalized(tail: Sequence[Scalar]) -> Laurent:
    """Build ``q^{-1} + tail[0] + tail[1] q + tail[2] q^2 + ...``."""
    return Laurent(-1, [Fraction(1)] + [Fraction(t) for t in tail])


def is_normalized(f: Laurent) -> bool:
    """Coefficient at -1 equals 1 and everything below -1 vanishes."""
    if f.coeff(-1) != 1:
        return False
    return all(f.coeff(n) == 0 for n in range(f.val, -1))


def unit_part(f: Laurent) -> Laurent:
    """``U(f) = q * f``: a power series with constant term 1 when f is normalized."""
    return f.shift(1)


def invert_unit(u: Laurent) -> Laurent:
    """Inverse of a power series with nonzero constant term (recursive solve)."""
    assert u.val == 0 and u.coeff(0) != 0, "not a unit of C[[q]]"
    n = len(u)
    v: List[Scalar] = [Fraction(0)] * n
    v[0] = 1 / u.coeff(0)
    for k in range(1, n):
        s = sum(u.coeff(i) * v[k - i] for i in range(1, k + 1))
        v[k] = -s / u.coeff(0)
    return Laurent(0, v)


# ----------------------------------------------------------------------------
# Demo 1: orders add, exactly
# ----------------------------------------------------------------------------


def demo_order_additivity(trials: int = 200, seed: int = 20260819) -> None:
    print("=" * 74)
    print("1.  ORDERS ADD  --  ord(f*g) = ord(f) + ord(g), with EQUALITY")
    print("=" * 74)
    rng = random.Random(seed)
    ok = True
    for _ in range(trials):
        v1, v2 = rng.randint(-5, 5), rng.randint(-5, 5)
        # force nonzero leading coefficients
        f = Laurent(v1, [rng.choice([-3, -2, -1, 1, 2, 3])] + [rng.randint(-9, 9) for _ in range(11)])
        g = Laurent(v2, [rng.choice([-3, -2, -1, 1, 2, 3])] + [rng.randint(-9, 9) for _ in range(11)])
        h = f * g
        ok &= h.order() == f.order() + g.order()
        ok &= h.leading_coeff() == f.leading_coeff() * g.leading_coeff()
    print(f"  {trials} random pairs of Laurent series over Q")
    print(f"  ord(f*g) == ord(f)+ord(g) and lc(f*g) == lc(f)*lc(g) in all cases: {ok}")
    print("  (Equality, not merely '>=', because Q has no zero divisors.)\n")


# ----------------------------------------------------------------------------
# Demo 2: the pole-order theorem and non-closure
# ----------------------------------------------------------------------------


def random_normalized(rng: random.Random, width: int = 8) -> Laurent:
    return normalized([rng.randint(-50, 50) for _ in range(width - 1)])


def demo_pole_order(max_m: int = 8, seed: int = 11) -> None:
    print("=" * 74)
    print("2.  POLE-ORDER THEOREM  --  a product of m normalized series has")
    print("    order EXACTLY -m and leading coefficient EXACTLY 1")
    print("=" * 74)
    rng = random.Random(seed)
    print(f"  {'m':>3} | {'ord(prod)':>10} | {'lc(prod)':>9} | {'normalized?':>12}")
    print("  " + "-" * 46)
    for m in range(0, max_m + 1):
        factors = [random_normalized(rng, width=10) for _ in range(m)]
        P = product(factors, width=10)
        print(
            f"  {m:>3} | {str(P.order()):>10} | {str(P.leading_coeff()):>9} |"
            f" {str(is_normalized(P)):>12}"
        )
    print("\n  The product is normalized precisely in the row m = 1: NON-CLOSURE.")
    print("  For m >= 1 the product has a negative-degree coefficient equal to 1,")
    print("  so it is not a power series at all.\n")


# ----------------------------------------------------------------------------
# Demo 3: unique monomial correction and unit structure
# ----------------------------------------------------------------------------


def demo_correction(m: int = 5, seed: int = 7) -> None:
    print("=" * 74)
    print("3.  UNIQUE CORRECTION AND UNIT STRUCTURE")
    print("=" * 74)
    rng = random.Random(seed)
    factors = [random_normalized(rng, width=8) for _ in range(m)]
    P = product(factors, width=8)
    print(f"  m = {m},  ord(prod) = {P.order()}")
    print(f"  {'k':>3} | {'ord(q^k * prod)':>16} | order zero?")
    print("  " + "-" * 42)
    for k in range(0, m + 4):
        Q = q_pow(k, width=8) * P
        print(f"  {k:>3} | {str(Q.order()):>16} | {Q.order() == 0}")
    print(f"\n  Exactly one exponent works, namely k = m = {m}.")

    U = q_pow(m, width=8) * P
    prod_units = product([unit_part(f) for f in factors], width=8)
    print(f"\n  q^{m} * prod  =  {U}")
    print(f"  prod of unit parts U(f_i) = {prod_units}")
    print(f"  equal:  {U.coeffs[: len(prod_units)] == prod_units.coeffs[: len(U)]}")
    print(f"  constant term = {U.coeff(0)}  ->  it is a UNIT of C[[q]]")
    inv = invert_unit(U)
    check = (U * inv).truncate(len(U))
    print(f"  explicit inverse: {inv}")
    print(f"  product with inverse = {check}\n")


# ----------------------------------------------------------------------------
# Demo 4: unique factorization f = q^{-1} * U(f)
# ----------------------------------------------------------------------------


def demo_factorization(seed: int = 3) -> None:
    print("=" * 74)
    print("4.  UNIQUE FACTORIZATION  f = q^{-1} * u,  u in C[[q]] with u(0) = 1")
    print("=" * 74)
    rng = random.Random(seed)
    f = random_normalized(rng, width=6)
    u = unit_part(f)
    back = q_pow(-1, width=6) * u
    print(f"  f          = {f}")
    print(f"  u = q * f  = {u}      (constant term {u.coeff(0)})")
    print(f"  q^{-1} * u = {back}")
    print(f"  recovers f: {[back.coeff(n) for n in range(-1, 4)] == [f.coeff(n) for n in range(-1, 4)]}")
    print("  Uniqueness: q is invertible, so u = q*f is forced.\n")


# ----------------------------------------------------------------------------
# Demo 5: Newton identities past the pole
# ----------------------------------------------------------------------------


def demo_newton(max_m: int = 6, seed: int = 99) -> None:
    print("=" * 74)
    print("5.  NEWTON-TYPE IDENTITIES FOR THE COEFFICIENTS PAST THE POLE")
    print("=" * 74)
    rng = random.Random(seed)
    print(f"  {'m':>3} | {'coeff q^{1-m}':>14} {'sum a_i':>10} | "
          f"{'2*coeff q^{2-m}':>16} {'Newton RHS':>12}")
    print("  " + "-" * 66)
    all_ok = True
    for m in range(1, max_m + 1):
        factors = [random_normalized(rng, width=8) for _ in range(m)]
        a = [f.coeff(0) for f in factors]
        b = [f.coeff(1) for f in factors]
        P = product(factors, width=8)
        lhs1 = P.coeff(1 - m)
        rhs1 = sum(a)
        lhs2 = 2 * P.coeff(2 - m)
        rhs2 = 2 * sum(b) + sum(a) ** 2 - sum(x * x for x in a)
        all_ok &= (lhs1 == rhs1) and (lhs2 == rhs2)
        print(f"  {m:>3} | {str(lhs1):>14} {str(rhs1):>10} | {str(lhs2):>16} {str(rhs2):>12}")
    print(f"\n  All identities hold: {all_ok}")
    print("  Equivalently coeff(q^{2-m}) = sum_i b_i + e_2(a),  e_2 the second")
    print("  elementary symmetric function, since (sum a)^2 - sum a^2 = 2*e_2(a).\n")


# ----------------------------------------------------------------------------
# Demo 6: the Monster -- pole of order exactly 194
# ----------------------------------------------------------------------------

# Genuine McKay-Thompson data for the two classes that opened moonshine.
# T_g = q^{-1} + c_g(1) q + c_g(2) q^2 + ...   (constant term 0)
MOONSHINE_DATA: Dict[str, Tuple[int, int]] = {
    "1A": (196884, 21493760),   # J = j - 744
    "2A": (4372, 96256),
}

MONSTER_CLASS_COUNT: int = 194


def moonshine_like_family(rng: random.Random, count: int, width: int = 8) -> List[Laurent]:
    """A family of ``count`` normalized series with vanishing constant terms.

    The first two entries carry the genuine coefficients of the McKay-Thompson
    series for the classes 1A and 2A; the remaining entries are illustrative
    stand-ins with the same shape (constant term 0), which is all the theorems
    below depend on.
    """
    family: List[Laurent] = []
    for name in ("1A", "2A"):
        c1, c2 = MOONSHINE_DATA[name]
        family.append(normalized([0, c1, c2] + [0] * (width - 4)))
    while len(family) < count:
        family.append(normalized([0] + [rng.randint(-10**4, 10**5) for _ in range(width - 2)]))
    return family[:count]


def demo_monster(seed: int = 194) -> None:
    print("=" * 74)
    print("6.  THE MONSTER  --  194 conjugacy classes, pole of order exactly 194")
    print("=" * 74)
    rng = random.Random(seed)
    family = moonshine_like_family(rng, MONSTER_CLASS_COUNT, width=8)
    P = product(family, width=8)
    m = MONSTER_CLASS_COUNT

    print(f"  number of factors m           = {m}")
    print(f"  ord(prod)                     = {P.order()}   (expected {-m})")
    print(f"  leading coefficient           = {P.leading_coeff()}   (expected 1)")
    print(f"  coefficient at q^-193         = {P.coeff(1 - m)}   (expected 0)")
    char_sum = sum(f.coeff(1) for f in family)
    print(f"  coefficient at q^-192         = {P.coeff(2 - m)}")
    print(f"  sum of linear coefficients    = {char_sum}   (must agree)")
    print(f"  agreement                     = {P.coeff(2 - m) == char_sum}")

    print("\n  Unique correction: ord(q^k * prod) = 0 only for k = 194.")
    for k in (192, 193, 194, 195):
        print(f"    k = {k:>3} -> ord = {(q_pow(k, width=8) * P).order()}")

    U = q_pow(m, width=8) * P
    print(f"\n  q^194 * prod has constant term {U.coeff(0)} -> a unit of C[[q]].")
    print(f"  The product is NOT a power series: its coefficient at q^-194 is "
          f"{P.coeff(-m)} != 0.\n")


# ----------------------------------------------------------------------------
# Demo 7: the exact two-factor moonshine instance
# ----------------------------------------------------------------------------


def demo_J_times_T2A() -> None:
    print("=" * 74)
    print("7.  THE TWO-FACTOR INSTANCE  J * T_2A")
    print("=" * 74)
    J = normalized([0, 196884, 21493760, 864299970, 0, 0])
    T2A = normalized([0, 4372, 96256, 1240002, 0, 0])
    P = J * T2A
    print(f"  J    = {J}")
    print(f"  T_2A = {T2A}")
    print(f"  J * T_2A (first terms) = {P.truncate(4)}")
    print(f"\n  ord            = {P.order()}      (expected -2)")
    print(f"  coeff q^-2     = {P.coeff(-2)}       (expected 1)")
    print(f"  coeff q^-1     = {P.coeff(-1)}       (expected 0: both constant terms vanish)")
    print(f"  constant coeff = {P.coeff(0)}  (expected 196884 + 4372 = {196884 + 4372})")
    print(f"  match          = {P.coeff(0) == 196884 + 4372}")
    print("\n  196884 = 196883 + 1 and 4372 = 4371 + 1 are the two observations")
    print("  that opened moonshine; their sum appears as the level-2 Newton term.\n")


# ----------------------------------------------------------------------------
# Demo 8: the value-group caveat
# ----------------------------------------------------------------------------


def demo_value_group_caveat() -> None:
    print("=" * 74)
    print("8.  WHY THE VALUE GROUP MUST BE  Z u {infinity}")
    print("=" * 74)
    f = normalized([0, 1, 2])
    zero = Laurent(-1, [Fraction(0)] * 4)
    P = f * zero
    print("  Take one normalized series and one zero series (m = 2 'factors').")
    print(f"  ord(f)        = {f.order()}")
    print(f"  ord(0)        = {zero.order()}      (with the convention ord(0) = infinity)")
    print(f"  ord(f * 0)    = {P.order()}      -- additivity holds: -1 + inf = inf")
    print("  If instead one declared ord(0) = 0 to keep the order integer-valued,")
    print("  then 'a product of m normalized series has order -m' would read")
    print("  0 = -2, which is FALSE, and false silently.  The theorem's value")
    print("  group is part of the theorem.\n")


# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE POLE-ORDER OBSTRUCTION FOR PRODUCTS OF NORMALIZED q-SERIES")
    print("#" * 74)
    print()
    demo_order_additivity()
    demo_pole_order()
    demo_correction()
    demo_factorization()
    demo_newton()
    demo_monster()
    demo_J_times_T2A()
    demo_value_group_caveat()
    print("=" * 74)
    print("Summary:  ord is an additive valuation and a surjective group")
    print("homomorphism C((q))^x -> Z.  Normalized series sit in the fibre over")
    print("-1; a product of m of them sits in the fibre over -m; distinct fibres")
    print("are disjoint.  One integer decides everything.")
    print("=" * 74)


if __name__ == "__main__":
    main()
