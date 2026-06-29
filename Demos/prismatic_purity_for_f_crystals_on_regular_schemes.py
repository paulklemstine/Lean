"""
Prismatic Purity for F-Crystals on Regular Schemes
==================================================

Numerical companion to the formal development.  Every routine here is a direct,
self-contained numerical witness of one of the proved theorems:

  * hartogs_UFD              -> `hartogs_extend_over_Z` and `equalizer_intersection`
  * fibonacci_inter_eq_bot   -> `fibonacci_coprime_pairs` and `hartogs_extend_over_Z`
  * hartogs_dim_one / hartogs_Z -> `integrally_closed_witness`
  * regularLocalDimOne_isUFD -> `regular_dim_one_is_pid` (DVR illustration)
  * restriction_faithful     -> `restriction_is_faithful`

The mathematics: for a regular local ring R (a UFD, by Auslander-Buchsbaum) with
fraction field K, two coprime elements x, y carve out two affine charts
R[1/x], R[1/y] of the punctured spectrum.  A "section on the punctured spectrum"
is exactly an f in K that is x-integral AND y-integral, i.e.
    x^a * f in R   and   y^b * f in R   for some exponents a, b.
The Hartogs / purity statement says every such f already lies in R:
    R[1/x]  ∩  R[1/y]  =  R   (inside K).

We model the prototypical case R = Z, K = Q.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import gcd
from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1.  x-integrality:  does some power of x clear the denominator of f?
# ---------------------------------------------------------------------------

def is_x_integral(x: int, f: Fraction, max_exponent: int = 256) -> Optional[int]:
    """Return the least n with x**n * f in Z, or None if no such n <= max_exponent.

    This is the computable shadow of `IsXIntegral x f`: the predicate
    `exists n, (algebraMap R K x)^n * f in range`.
    """
    if f.denominator == 1:
        return 0
    if x in (0, 1, -1):
        return None
    power = 1
    for n in range(1, max_exponent + 1):
        power *= x
        if (power * f).denominator == 1:
            return n
    return None


# ---------------------------------------------------------------------------
# 2.  hartogs_UFD over Z:  cross-multiply, then cancel a coprime power
# ---------------------------------------------------------------------------

def hartogs_extend_over_Z(x: int, y: int, f: Fraction) -> int:
    """Given coprime x, y and an f that is both x-integral and y-integral, return
    the integer equal to f, executing exactly the `hartogs_UFD` proof.

    Proof recap (cross-multiply and cancel):
      from x^a * f = alpha in Z and y^b * f = beta in Z we get
        y^b * alpha = x^a * beta in Z;
      since gcd(x^a, y^b) = 1, x^a | alpha, say alpha = x^a * gamma;
      cancelling x^a (nonzero in Q) yields f = gamma in Z.
    """
    if gcd(x, y) != 1:
        raise ValueError(f"x={x}, y={y} are not coprime; hartogs_UFD does not apply")
    a = is_x_integral(x, f)
    b = is_x_integral(y, f)
    if a is None or b is None:
        raise ValueError(f"f={f} is not both x- and y-integral for x={x}, y={y}")

    alpha = x ** a * f            # alpha in Z (denominator 1)
    beta = y ** b * f             # beta  in Z (denominator 1)
    assert alpha.denominator == 1 and beta.denominator == 1
    alpha_i, beta_i = int(alpha), int(beta)

    # y^b * alpha = x^a * beta   (the cross-multiplied identity in Z)
    assert (y ** b) * alpha_i == (x ** a) * beta_i

    # x^a | alpha because gcd(x^a, y^b) = 1
    assert alpha_i % (x ** a) == 0, "coprimality should force divisibility"
    gamma = alpha_i // (x ** a)

    # Cancel x^a:  f == gamma
    assert Fraction(gamma) == f
    return gamma


# ---------------------------------------------------------------------------
# 3.  The equalizer:  R[1/x] ∩ R[1/y] = R  inside Q
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class EqualizerReport:
    x: int
    y: int
    sample: Fraction
    in_chart_x: bool
    in_chart_y: bool
    is_global: bool


def equalizer_intersection(x: int, y: int, samples: List[Fraction]) -> List[EqualizerReport]:
    """Witness `equalizer_inf`: a rational lies in BOTH charts R[1/x], R[1/y]
    iff it lies in R = Z.  For each sample report chart membership and the
    Hartogs conclusion.
    """
    reports: List[EqualizerReport] = []
    for f in samples:
        in_x = is_x_integral(x, f) is not None
        in_y = is_x_integral(y, f) is not None
        is_global = f.denominator == 1
        # The theorem: (in_x and in_y) == is_global, given gcd(x, y) = 1.
        if gcd(x, y) == 1:
            assert (in_x and in_y) == is_global, (
                f"equalizer_inf violated at f={f}")
        reports.append(EqualizerReport(x, y, f, in_x, in_y, is_global))
    return reports


# ---------------------------------------------------------------------------
# 4.  fibonacci_inter_eq_bot:  consecutive Fibonacci numbers are the coprime pair
# ---------------------------------------------------------------------------

def fibonacci_coprime_pairs(n: int) -> List[Tuple[int, int]]:
    """Return the first n pairs (F_k, F_{k+1}) of consecutive Fibonacci numbers.
    Consecutive Fibonacci numbers are coprime, so each pair is a legal (x, y)
    for `hartogs_UFD` / `equalizer_inf` -- this is exactly `fibonacci_inter_eq_bot`.
    """
    pairs: List[Tuple[int, int]] = []
    a, b = 1, 2  # F_2, F_3 (skip the two 1's so the pair is nontrivial)
    for _ in range(n):
        assert gcd(a, b) == 1
        pairs.append((a, b))
        a, b = b, a + b
    return pairs


# ---------------------------------------------------------------------------
# 5.  hartogs_dim_one / hartogs_Z:  integral closedness of Z in Q
# ---------------------------------------------------------------------------

def is_integral_over_Z(f: Fraction, monic_coeffs: List[int]) -> bool:
    """Check that f satisfies the monic integer polynomial x^d + c_{d-1} x^{d-1}
    + ... + c_0, with monic_coeffs = [c_0, ..., c_{d-1}] (the non-leading coeffs).
    """
    d = len(monic_coeffs)
    value = f ** d + sum(Fraction(monic_coeffs[i]) * f ** i for i in range(d))
    return value == 0


def integrally_closed_witness(f: Fraction, monic_coeffs: List[int]) -> Optional[int]:
    """`hartogs_Z`: if f in Q is integral over Z (root of a monic integer poly),
    then f is an integer.  Return that integer (or None if f is not integral)."""
    if not is_integral_over_Z(f, monic_coeffs):
        return None
    # Rational root theorem: a rational root of a monic integer poly is an integer.
    assert f.denominator == 1, "an algebraic integer in Q must be a rational integer"
    return int(f)


# ---------------------------------------------------------------------------
# 6.  regularLocalDimOne_isUFD:  a DVR (regular local dim 1) is a PID/UFD
# ---------------------------------------------------------------------------

def regular_dim_one_is_pid(p: int, elements: List[Fraction]) -> List[Tuple[Fraction, int]]:
    """Illustrate the dimension-1 stratum: Z localised at a prime p is a DVR with
    uniformiser p.  Every nonzero element factors uniquely as (unit) * p^v.  We
    return the p-adic valuation v of each element -- the data witnessing that the
    maximal ideal (p) is principal and the ring is a UFD (`regularLocalDimOne_isUFD`).
    """
    out: List[Tuple[Fraction, int]] = []
    for f in elements:
        if f == 0:
            continue
        v = 0
        num, den = f.numerator, f.denominator
        while num % p == 0:
            num //= p
            v += 1
        while den % p == 0:
            den //= p
            v -= 1
        out.append((f, v))
    return out


# ---------------------------------------------------------------------------
# 7.  restriction_faithful:  a Z-crystal map is determined on the generic point
# ---------------------------------------------------------------------------

def restriction_is_faithful(a_scalar: int, b_scalar: int) -> bool:
    """The trivial Z-crystal has endomorphisms = multiplication by an integer.
    Restriction to the generic point Spec Q is f |-> (f as a Q-linear map).  Since
    Z -> Q is injective, two endomorphisms with equal restriction are equal:
    this is `restriction_faithful` / `trivZ_faithful`.
    """
    def restrict(scalar: int):
        return lambda q: Fraction(scalar) * q  # Q-linear extension

    ra, rb = restrict(a_scalar), restrict(b_scalar)
    agree_on_generic = all(ra(Fraction(t)) == rb(Fraction(t))
                           for t in range(-5, 6))
    if agree_on_generic:
        assert a_scalar == b_scalar, "faithfulness: equal restriction => equal map"
    return agree_on_generic


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("PRISMATIC PURITY FOR F-CRYSTALS -- numerical witnesses")
    print("=" * 72)

    print("\n[1] hartogs_UFD over Z (cross-multiply & cancel coprime powers)")
    for x, y, f in [(3, 5, Fraction(7, 1)),
                    (8, 9, Fraction(11, 1)),
                    (2, 3, Fraction(-4, 1))]:
        g = hartogs_extend_over_Z(x, y, f)
        print(f"    x={x}, y={y}, f={f}  ->  extends to integer {g}")

    print("\n[2] equalizer_inf: R[1/x] ∩ R[1/y] = R  inside Q  (x=3, y=5)")
    samples = [Fraction(2, 1), Fraction(1, 3), Fraction(1, 5),
               Fraction(1, 15), Fraction(7, 2)]
    for r in equalizer_intersection(3, 5, samples):
        verdict = "GLOBAL (in Z)" if r.is_global else "not global"
        print(f"    f={str(r.sample):>5}  inR[1/3]={r.in_chart_x!s:>5}  "
              f"inR[1/5]={r.in_chart_y!s:>5}  ->  {verdict}")

    print("\n[3] fibonacci_inter_eq_bot: consecutive Fibonacci numbers are coprime")
    pairs = fibonacci_coprime_pairs(6)
    print(f"    coprime (x,y) pairs: {pairs}")
    x, y = pairs[3]
    f = Fraction(13, 1)
    print(f"    using (x,y)=({x},{y}), f={f}  ->  hartogs gives "
          f"{hartogs_extend_over_Z(x, y, f)}")

    print("\n[4] hartogs_Z: an algebraic integer that is rational is an integer")
    # x^2 - 5x + 6 = (x-2)(x-3): roots 2, 3 are integers
    for f in [Fraction(2, 1), Fraction(3, 1)]:
        n = integrally_closed_witness(f, [6, -5])
        print(f"    root f={f} of x^2-5x+6  ->  integer {n}")
    # 1/2 is NOT integral over Z (2x-1 is not monic over Z)
    print(f"    f=1/2 integral over Z via x^2-5x+6? "
          f"{integrally_closed_witness(Fraction(1, 2), [6, -5])}")

    print("\n[5] regularLocalDimOne_isUFD: Z_(p) is a DVR (uniformiser p=3)")
    for f, v in regular_dim_one_is_pid(3, [Fraction(9, 1), Fraction(2, 3),
                                           Fraction(1, 27), Fraction(5, 1)]):
        print(f"    f={str(f):>5}  ->  3-adic valuation {v}")

    print("\n[6] restriction_faithful over Z (trivZ_faithful)")
    print(f"    scalars (4,4) agree on generic point? {restriction_is_faithful(4, 4)}")
    print(f"    scalars (4,7) agree on generic point? {restriction_is_faithful(4, 7)}")

    print("\nAll numerical witnesses pass.")


if __name__ == "__main__":
    main()
