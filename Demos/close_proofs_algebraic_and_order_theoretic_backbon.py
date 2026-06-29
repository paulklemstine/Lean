"""
Stereographic Capacity Theory — numerical demonstrations.

This self-contained script demonstrates the central results of the algebraic and
order-theoretic backbone of the inverse stereographic chart:

    sigma(t)   = (2t/(1+t^2), (1-t^2)/(1+t^2))      inverse stereographic chart
    t (+) s    = (t+s)/(1-ts)                        tangent half-angle addition law
    Theta(t)   = 2*arctan(t)                         stereographic angle
    cap(t)     = 2t/(1+t^2)                          capacity coordinate

Demonstrated facts (all proved formally in the accompanying development):
  * sigma(t) lies on the unit circle for every t
  * the key identity (1-ts)^2 + (t+s)^2 = (1+t^2)(1+s^2)
  * sigma(t (+) s) is the rotation of sigma(t) by the angle of s
  * the 2x2 rotation matrices multiply: R(t) R(s) = R(t (+) s), det R(t) = 1
  * (R, (+)) is a partial abelian group: identity 0, commutative, associative
  * Theta is strictly increasing and Theta(t (+) s) = Theta(t) + Theta(s) on ts<1
  * cap(t) <= 1 with equality iff t = 1; and sigma(1/2) = (4/5, 3/5)

The demo uses only the Python standard library.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Tuple

Number = float  # demos run over floats; exact-rational variants use Fraction


# --------------------------------------------------------------------------- #
# Core definitions                                                            #
# --------------------------------------------------------------------------- #
def inv_stereo(t: Number) -> Tuple[Number, Number]:
    """Inverse stereographic chart sigma(t) = (2t/(1+t^2), (1-t^2)/(1+t^2))."""
    d = 1 + t * t
    return (2 * t / d, (1 - t * t) / d)


def stereo_add(t: Number, s: Number) -> Number:
    """Tangent half-angle addition law t (+) s = (t+s)/(1-ts). Partial: ts != 1."""
    denom = 1 - t * s
    if denom == 0:
        raise ZeroDivisionError("t (+) s undefined on the singular locus ts = 1")
    return (t + s) / denom


def stereo_angle(t: Number) -> Number:
    """Stereographic angle Theta(t) = 2*arctan(t), valued in (-pi, pi)."""
    return 2 * math.atan(t)


def capacity(t: Number) -> Number:
    """Capacity coordinate cap(t) = 2t/(1+t^2), the horizontal extent of sigma(t)."""
    return 2 * t / (1 + t * t)


def stereo_rot(t: Number) -> Tuple[Tuple[Number, Number], Tuple[Number, Number]]:
    """Rotation matrix R(t) = [[y, -x], [x, y]] with (x, y) = sigma(t)."""
    x, y = inv_stereo(t)
    return ((y, -x), (x, y))


def mat_mul(
    a: Tuple[Tuple[Number, Number], Tuple[Number, Number]],
    b: Tuple[Tuple[Number, Number], Tuple[Number, Number]],
) -> Tuple[Tuple[Number, Number], Tuple[Number, Number]]:
    """2x2 matrix multiplication."""
    return (
        (a[0][0] * b[0][0] + a[0][1] * b[1][0], a[0][0] * b[0][1] + a[0][1] * b[1][1]),
        (a[1][0] * b[0][0] + a[1][1] * b[1][0], a[1][0] * b[0][1] + a[1][1] * b[1][1]),
    )


def det2(m: Tuple[Tuple[Number, Number], Tuple[Number, Number]]) -> Number:
    """Determinant of a 2x2 matrix."""
    return m[0][0] * m[1][1] - m[0][1] * m[1][0]


def rotate(point: Tuple[Number, Number], s: Number) -> Tuple[Number, Number]:
    """Rotate (x1, y1) by the angle attached to s, per the addition-law RHS:
       (x1*y2 + y1*x2, y1*y2 - x1*x2) with (x2, y2) = sigma(s)."""
    x1, y1 = point
    x2, y2 = inv_stereo(s)
    return (x1 * y2 + y1 * x2, y1 * y2 - x1 * x2)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_on_circle() -> None:
    print("=" * 70)
    print("1. The chart lands on the unit circle:  x(t)^2 + y(t)^2 = 1")
    print("=" * 70)
    for t in [-3.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0, 7.0]:
        x, y = inv_stereo(t)
        print(f"  t = {t:5.2f} -> sigma = ({x:+.6f}, {y:+.6f}),  "
              f"x^2+y^2 = {x * x + y * y:.12f}")
    print()


def demo_key_identity() -> None:
    print("=" * 70)
    print("2. The algebraic miracle:  (1-ts)^2 + (t+s)^2 = (1+t^2)(1+s^2)")
    print("=" * 70)
    for t, s in [(2, 3), (-1, 4), (Fraction(1, 2), Fraction(2, 3)), (5, -7)]:
        lhs = (1 - t * s) ** 2 + (t + s) ** 2
        rhs = (1 + t * t) * (1 + s * s)
        print(f"  t={str(t):>6}, s={str(s):>6}:  LHS = {lhs}, RHS = {rhs}, "
              f"equal = {lhs == rhs}")
    print()


def demo_addition_law() -> None:
    print("=" * 70)
    print("3. Rotation IS the addition law:  sigma(t (+) s) = rotate(sigma(t), s)")
    print("=" * 70)
    for t, s in [(0.5, 0.3), (2.0, -1.0), (0.25, 0.75)]:
        lhs = inv_stereo(stereo_add(t, s))
        rhs = rotate(inv_stereo(t), s)
        print(f"  t={t:+.2f}, s={s:+.2f}")
        print(f"     sigma(t (+) s)      = ({lhs[0]:+.8f}, {lhs[1]:+.8f})")
        print(f"     rotate(sigma(t), s) = ({rhs[0]:+.8f}, {rhs[1]:+.8f})")
        print(f"     max abs diff        = "
              f"{max(abs(lhs[0]-rhs[0]), abs(lhs[1]-rhs[1])):.2e}")
    print()


def demo_matrix_law() -> None:
    print("=" * 70)
    print("4. Matrix realization:  R(t) R(s) = R(t (+) s),  det R(t) = 1")
    print("=" * 70)
    for t, s in [(0.5, 0.3), (1.5, -0.4)]:
        prod = mat_mul(stereo_rot(t), stereo_rot(s))
        target = stereo_rot(stereo_add(t, s))
        diff = max(abs(prod[i][j] - target[i][j]) for i in range(2) for j in range(2))
        print(f"  t={t:+.2f}, s={s:+.2f}:  ||R(t)R(s) - R(t(+)s)|| = {diff:.2e}, "
              f"det R(t) = {det2(stereo_rot(t)):.12f}")
    print()


def demo_group_laws() -> None:
    print("=" * 70)
    print("5. Partial abelian group:  identity 0, commutative, associative")
    print("=" * 70)
    t, s, u = 0.4, -0.7, 0.2
    print(f"  identity:      t (+) 0 = {stereo_add(t, 0.0):+.8f}   (t = {t:+.2f})")
    print(f"  commutative:   t(+)s = {stereo_add(t, s):+.8f}, "
          f"s(+)t = {stereo_add(s, t):+.8f}")
    lhs = stereo_add(stereo_add(t, s), u)
    rhs = stereo_add(t, stereo_add(s, u))
    print(f"  associative:   (t(+)s)(+)u = {lhs:+.8f}, "
          f"t(+)(s(+)u) = {rhs:+.8f}")
    print(f"  inverse:       t (+) (-t) = {stereo_add(t, -t):+.8f}")
    print()


def demo_order_embedding() -> None:
    print("=" * 70)
    print("6. Order embedding:  Theta strictly increasing; "
          "Theta(t(+)s) = Theta(t)+Theta(s) on ts<1")
    print("=" * 70)
    samples = [-2.0, -0.5, 0.0, 0.5, 2.0]
    print("  monotonicity:")
    for a, b in zip(samples, samples[1:]):
        print(f"     Theta({a:+.2f}) = {stereo_angle(a):+.5f} < "
              f"Theta({b:+.2f}) = {stereo_angle(b):+.5f}  -> "
              f"{stereo_angle(a) < stereo_angle(b)}")
    print("  intertwining (ts < 1):")
    for t, s in [(0.3, 0.4), (-0.5, 0.2)]:
        lhs = stereo_angle(stereo_add(t, s))
        rhs = stereo_angle(t) + stereo_angle(s)
        print(f"     t={t:+.2f}, s={s:+.2f}: Theta(t(+)s)={lhs:+.6f}, "
              f"Theta(t)+Theta(s)={rhs:+.6f}, diff={abs(lhs-rhs):.2e}")
    print()


def demo_capacity_and_pythagoras() -> None:
    print("=" * 70)
    print("7. Capacity bound cap(t) <= 1 (equality iff t=1) and the (3,4,5) point")
    print("=" * 70)
    print("  capacity samples:")
    for t in [0.0, 0.5, 0.9, 1.0, 1.1, 2.0, 5.0]:
        print(f"     cap({t:.2f}) = {capacity(t):+.8f}")
    print(f"  maximizer:   cap(1) = {capacity(1.0):.8f}  (the unique maximum)")
    p = inv_stereo(Fraction(1, 2))
    print(f"  Pythagoras:  sigma(1/2) = ({p[0]}, {p[1]})  -> (4/5, 3/5), the (3,4,5) triple")
    # Euclid's formula from rational addresses p/q:
    print("  Euclid's formula  (p,q) -> (2pq, q^2-p^2, p^2+q^2):")
    for p_, q_ in [(1, 2), (2, 3), (1, 4), (2, 5)]:
        a, b, c = 2 * p_ * q_, q_ * q_ - p_ * p_, p_ * p_ + q_ * q_
        print(f"     p={p_}, q={q_}: ({a}, {b}, {c}),  check a^2+b^2-c^2 = "
              f"{a * a + b * b - c * c}")
    print()


def main() -> None:
    print("\nSTEREOGRAPHIC CAPACITY THEORY — NUMERICAL DEMONSTRATIONS\n")
    demo_on_circle()
    demo_key_identity()
    demo_addition_law()
    demo_matrix_law()
    demo_group_laws()
    demo_order_embedding()
    demo_capacity_and_pythagoras()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
