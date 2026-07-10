"""Numerical demonstrations for *Dyadic Surreal Numbers and Finite Birthdays*.

This self-contained script models the finite-birthday layer of Conway's
surreal numbers.  Every surreal number appearing here is a dyadic rational
``m / 2**n``; we model such a value by the exact fraction together with the
data needed to recover the surreal facts of the paper:

  * the birthday of the power of one half ``2**-n`` is exactly ``n + 1``;
  * the powers of one half are positive, strictly decreasing and distinct;
  * ``2**n * 2**-n = 1``   (rescaling law);
  * ``2**-m * 2**-n = 2**-(m+n)``   (exponent law);
  * the canonical map  ``m / 2**n  ->  m * 2**-n``  is an injective ring
    homomorphism onto the dyadic surreals.

Everything is checked with exact rational arithmetic, so the demonstrations
are mathematically faithful rather than floating-point approximations.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import gcd


# --------------------------------------------------------------------------- #
#  Powers of one half and their birthdays
# --------------------------------------------------------------------------- #
def pow_half(n: int) -> Fraction:
    """Return the dyadic value of the surreal power of one half ``2**-n``."""
    if n < 0:
        raise ValueError("n must be a natural number")
    return Fraction(1, 2 ** n)


def birthday_pow_half(n: int) -> int:
    """Birthday of ``2**-n`` in Conway's construction, which equals ``n + 1``.

    Base case ``2**0 = 1 = {0 | }`` is born on day 1; each midpoint
    ``2**-(n+1) = {0 | 2**-n}`` costs exactly one additional day.
    """
    if n < 0:
        raise ValueError("n must be a natural number")
    return n + 1


def is_finite_birthday(n: int) -> bool:
    """Every power of one half is born strictly before day omega."""
    return birthday_pow_half(n) < float("inf")  # always True; n + 1 is finite


# --------------------------------------------------------------------------- #
#  Dyadic rationals and the canonical embedding
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Dyadic:
    """A dyadic rational ``m / 2**n`` kept in lowest terms."""

    numerator: int   # the odd part times sign, once reduced
    exponent: int    # non-negative power of two in the denominator

    @staticmethod
    def of_fraction(q: Fraction) -> "Dyadic":
        """Build a Dyadic from a Fraction; raise if the value is not dyadic."""
        den = q.denominator
        exp = 0
        while den % 2 == 0:
            den //= 2
            exp += 1
        if den != 1:
            raise ValueError(f"{q} is not a dyadic rational")
        return Dyadic(q.numerator, exp)

    def value(self) -> Fraction:
        """The rational value ``numerator / 2**exponent``."""
        return Fraction(self.numerator, 2 ** self.exponent)


def dyadic_map(d: Dyadic) -> Fraction:
    """Canonical map  ``m / 2**n  ->  m * 2**-n``  into the surreals.

    Because our surreals-in-the-finite-layer are exactly dyadic rationals,
    the surreal value coincides with the ordinary rational value.
    """
    return d.numerator * pow_half(d.exponent)


def denominator_height(q: Fraction) -> int:
    """The exponent n such that q = m / 2**n in lowest dyadic form."""
    return Dyadic.of_fraction(q).exponent


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_birthdays(max_n: int = 8) -> None:
    print("== Birthdays of the powers of one half (birth(2^-n) = n + 1) ==")
    for n in range(max_n + 1):
        v = pow_half(n)
        print(f"  2^-{n:<2} = {str(v):>9}   birthday = {birthday_pow_half(n)}"
              f"   (< omega: {is_finite_birthday(n)})")
    print()


def demo_order(max_n: int = 6) -> None:
    print("== The half-powers are positive, strictly decreasing, distinct ==")
    values = [pow_half(n) for n in range(max_n + 1)]
    print("  sequence:", "  >  ".join(str(v) for v in values))
    assert all(v > 0 for v in values), "positivity failed"
    assert all(values[i + 1] < values[i] for i in range(len(values) - 1)), \
        "strict decrease failed"
    assert len(set(values)) == len(values), "distinctness failed"
    print("  positivity, strict decrease, and distinctness all verified.\n")


def demo_rescaling(max_n: int = 8) -> None:
    print("== Rescaling law:  2^n * 2^-n = 1 ==")
    for n in range(max_n + 1):
        lhs = (2 ** n) * pow_half(n)
        assert lhs == 1, f"rescaling failed at n={n}"
        print(f"  2^{n} * 2^-{n} = {lhs}")
    print()


def demo_exponent_law(max_m: int = 4, max_n: int = 4) -> None:
    print("== Exponent law:  2^-m * 2^-n = 2^-(m+n) ==")
    for m in range(max_m + 1):
        for n in range(max_n + 1):
            lhs = pow_half(m) * pow_half(n)
            rhs = pow_half(m + n)
            assert lhs == rhs, f"exponent law failed at (m,n)=({m},{n})"
    print(f"  verified for all 0 <= m <= {max_m}, 0 <= n <= {max_n}.")
    print(f"  e.g. 2^-2 * 2^-3 = {pow_half(2) * pow_half(3)} = 2^-5 "
          f"= {pow_half(5)}\n")


def demo_ring_homomorphism() -> None:
    print("== The dyadic map is a unital, additive, multiplicative injection ==")
    samples = [Fraction(3, 8), Fraction(-5, 16), Fraction(7, 4),
               Fraction(1, 1), Fraction(-1, 2), Fraction(11, 32)]
    ds = [Dyadic.of_fraction(q) for q in samples]

    # unitality
    assert dyadic_map(Dyadic.of_fraction(Fraction(1))) == 1
    print("  unital:            Phi(1) = 1")

    # additivity and multiplicativity
    for a in ds:
        for b in ds:
            sum_ab = Dyadic.of_fraction(a.value() + b.value())
            prod_ab = Dyadic.of_fraction(a.value() * b.value())
            assert dyadic_map(sum_ab) == dyadic_map(a) + dyadic_map(b)
            assert dyadic_map(prod_ab) == dyadic_map(a) * dyadic_map(b)
    print("  additive:          Phi(x + y) = Phi(x) + Phi(y)  (all pairs)")
    print("  multiplicative:    Phi(x * y) = Phi(x) * Phi(y)  (all pairs)")

    # injectivity: distinct dyadics map to distinct surreals
    images = [dyadic_map(d) for d in ds]
    assert len(set(images)) == len(set(q for q in samples))
    print("  injective:         distinct dyadics -> distinct surreals\n")


def demo_thirds_have_no_finite_birthday(depth: int = 6) -> None:
    print("== 1/3 is NOT dyadic: it has no finite birthday ==")
    try:
        Dyadic.of_fraction(Fraction(1, 3))
    except ValueError:
        print("  1/3 cannot be written as m / 2^n; it is born only at day omega.")
    # show the binary approximations closing in from both sides
    lower, upper = Fraction(0), Fraction(1)
    print("  simplest-midpoint approximations to 1/3:")
    for _ in range(depth):
        mid = (lower + upper) / 2
        if mid < Fraction(1, 3):
            lower = mid
        else:
            upper = mid
    print(f"    after {depth} bisections:  {lower}  <  1/3  <  {upper}\n")


def main() -> None:
    print(__doc__)
    demo_birthdays()
    demo_order()
    demo_rescaling()
    demo_exponent_law()
    demo_ring_homomorphism()
    demo_thirds_have_no_finite_birthday()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
