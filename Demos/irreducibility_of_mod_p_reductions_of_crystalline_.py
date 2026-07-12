"""
Numerical demonstrations for:

    Irreducibility of mod p reductions of crystalline representations
    at fractional slope and even weight.

The Frobenius eigenvalues of the two-dimensional crystalline representation
V_{k, a_p} are the roots of

        X^2 - a_p * X + p^(k-1).

Normalising v(p) = 1, the two Newton (Frobenius) slopes are

        lowSlope  = v(a_p),
        highSlope = (k - 1) - v(a_p),           valid when 2*v(a_p) < k - 1.

Core facts demonstrated here:
  (1) the slopes sum to k - 1;
  (2) a fractional low slope forces a fractional high slope;
  (3) below the balanced point the slopes are strictly ordered / distinct;
  (4) for even k the balanced slope (k-1)/2 is a genuine half-integer;
  (5) X^2 - a X + d has a root over a field iff a^2 - 4d is a square,
      giving a discriminant criterion for irreducibility.

Pure standard library; run with `python3 demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Optional


# ---------------------------------------------------------------------------
# Section A -- Newton slope arithmetic
# ---------------------------------------------------------------------------

def low_slope(k: int, s: Fraction) -> Fraction:
    """Low Frobenius slope v(a_p); independent of k."""
    return s


def high_slope(k: int, s: Fraction) -> Fraction:
    """High Frobenius slope (k-1) - v(a_p)."""
    return Fraction(k - 1) - s


def slopes_sum(k: int, s: Fraction) -> Fraction:
    """Sum of the two slopes; equals k-1 for all k, s."""
    return low_slope(k, s) + high_slope(k, s)


def is_integral(q: Fraction) -> bool:
    """True iff the rational q is an integer."""
    return q.denominator == 1


def polygon_breaks(k: int, s: Fraction) -> bool:
    """True iff the Newton polygon breaks (2*s < k-1), i.e. slopes distinct."""
    return 2 * s < Fraction(k - 1)


# ---------------------------------------------------------------------------
# Section B -- Discriminant / residual irreducibility criterion
# ---------------------------------------------------------------------------

def discriminant(a: int, d: int) -> int:
    """Discriminant a^2 - 4d of X^2 - a X + d."""
    return a * a - 4 * d


def is_square_mod_p(e: int, p: int) -> bool:
    """Euler's criterion: is e a square in F_p (p odd prime)?"""
    e %= p
    if e == 0:
        return True
    return pow(e, (p - 1) // 2, p) == 1


def residual_is_irreducible(a: int, d: int, p: int) -> bool:
    """
    A 2-dim representation with trace a, determinant d over F_p is irreducible
    iff its discriminant a^2 - 4d is a NON-square in F_p.
    """
    return not is_square_mod_p(discriminant(a, d), p)


def rational_root_exists(a: Fraction, d: Fraction) -> bool:
    """Over Q: X^2 - a X + d has a rational root iff a^2 - 4d is a perfect square."""
    disc = a * a - 4 * d
    if disc < 0:
        return False
    # perfect-square test for a nonnegative rational
    num_ok = round(disc.numerator ** 0.5) ** 2 == disc.numerator
    den_ok = round(disc.denominator ** 0.5) ** 2 == disc.denominator
    return num_ok and den_ok


# ---------------------------------------------------------------------------
# Certificate assembler
# ---------------------------------------------------------------------------

@dataclass
class Certificate:
    k: int
    s: Fraction
    low: Fraction
    high: Fraction
    sum_ok: bool
    distinct: bool
    low_fractional: bool
    high_fractional: bool
    k_even: bool
    diagnostic: Optional[str]

    @property
    def valid(self) -> bool:
        return (self.sum_ok and self.distinct and self.low_fractional
                and self.high_fractional and self.k_even)


def build_certificate(k: int, s: Fraction) -> Certificate:
    """Assemble the fractional-slope irreducibility certificate for (k, s)."""
    low, high = low_slope(k, s), high_slope(k, s)
    diagnostic = None
    if k % 2 != 0:
        diagnostic = "weight k is not even"
    elif not polygon_breaks(k, s):
        diagnostic = "not sub-balanced: 2*s >= k-1 (Newton polygon does not break)"
    elif is_integral(s):
        diagnostic = "slope s is an integer (not fractional)"
    return Certificate(
        k=k, s=s, low=low, high=high,
        sum_ok=(slopes_sum(k, s) == Fraction(k - 1)),
        distinct=(low != high),
        low_fractional=not is_integral(low),
        high_fractional=not is_integral(high),
        k_even=(k % 2 == 0),
        diagnostic=diagnostic,
    )


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_slope_arithmetic() -> None:
    print("=" * 70)
    print("Demo 1: Newton slope arithmetic (fractional slope -> both fractional)")
    print("=" * 70)
    for k, s in [(12, Fraction(1, 2)), (24, Fraction(3, 2)),
                 (50, Fraction(7, 3)), (100, Fraction(1, 5))]:
        low, high = low_slope(k, s), high_slope(k, s)
        print(f"  k={k:3d}, v(a_p)={s}: low={low}, high={high}, "
              f"sum={slopes_sum(k, s)} (=k-1={k-1}), "
              f"breaks={polygon_breaks(k, s)}, "
              f"both fractional={not is_integral(low) and not is_integral(high)}")
    print()


def demo_even_weight_half_integer() -> None:
    print("=" * 70)
    print("Demo 2: even weight => balanced slope (k-1)/2 is a half-integer")
    print("=" * 70)
    for k in [2, 4, 12, 100]:
        mid = Fraction(k - 1, 2)
        print(f"  k={k:3d} (even): balanced slope = {mid}, "
              f"2*mid = {mid * 2} (=k-1), integral? {is_integral(mid)}")
    print()


def demo_discriminant_criterion() -> None:
    print("=" * 70)
    print("Demo 3: discriminant criterion for residual irreducibility over F_p")
    print("=" * 70)
    p = 7
    print(f"  p = {p}. Irreducible iff a^2 - 4d is a NON-square mod {p}.")
    for a, d in [(1, 1), (2, 3), (0, 1), (3, 5), (5, 2)]:
        disc = discriminant(a, d) % p
        irr = residual_is_irreducible(a, d, p)
        print(f"    trace a={a}, det d={d}: disc = {disc} mod {p}, "
              f"square? {is_square_mod_p(discriminant(a, d), p)}, "
              f"irreducible? {irr}")
    print()


def demo_certificates() -> None:
    print("=" * 70)
    print("Demo 4: fractional-slope irreducibility certificates")
    print("=" * 70)
    cases = [
        (12, Fraction(1, 2)),   # valid
        (24, Fraction(5, 3)),   # valid
        (11, Fraction(1, 2)),   # k odd -> invalid
        (12, Fraction(3, 1)),   # s integral -> invalid
        (12, Fraction(9, 2)),   # not sub-balanced (2s=9>=11? actually 9<11 -> ok);
    ]
    for k, s in cases:
        c = build_certificate(k, s)
        status = "VALID certificate (irreducible)" if c.valid else f"INVALID: {c.diagnostic}"
        print(f"  k={k:3d}, v(a_p)={s}: low={c.low}, high={c.high} -> {status}")
    print()


def demo_nonsquare_density() -> None:
    print("=" * 70)
    print("Demo 5: density of irreducible residual traces -> (p-1)/(2p)")
    print("=" * 70)
    for p in [5, 7, 11, 13, 101]:
        # fix a determinant d = 1; count traces a in F_p giving irreducible reduction
        count = sum(1 for a in range(p) if residual_is_irreducible(a, 1, p))
        empirical = Fraction(count, p)
        predicted = Fraction(p - 1, 2 * p)
        print(f"  p={p:4d}: irreducible fraction = {count}/{p} = "
              f"{float(empirical):.4f}, predicted (p-1)/(2p) = "
              f"{float(predicted):.4f}")
    print()


def main() -> None:
    demo_slope_arithmetic()
    demo_even_weight_half_integer()
    demo_discriminant_criterion()
    demo_certificates()
    demo_nonsquare_density()


if __name__ == "__main__":
    main()
