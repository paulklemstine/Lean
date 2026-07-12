"""
The Aleph-One Surface: Geometry Between the Dimensions
=======================================================

Numerical demonstrations of the three phenomena of the Hilbert cube
Q = product over N of [0,1]:

  1. Cardinality is blind to dimension: symbolic cardinal arithmetic showing
     |Q| = c = |R^n| for every n >= 1.
  2. Transfinite dimensionality: every finite cube [0,1]^n embeds into Q via
     padding-by-zero, with truncation as a continuous left inverse.
  3. Self-similarity: Q is homeomorphic to Q x Q and to Q x [0,1], realized as
     explicit coordinate reshufflings ("infinite hotel" bijections).

Everything is self-contained (standard library only) and uses type hints.
Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Sequence


# ---------------------------------------------------------------------------
# 1. Cardinal arithmetic:  cardinality cannot detect dimension
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Cardinal:
    """A cardinal of the form 2**exp, where the exponent is a *level*:
    level 0 -> a finite number n (stored in `finite`), level 'aleph0' -> aleph_0.

    We only need the ladder  n  <  aleph_0  <  c = 2**aleph_0  and the absorption
    laws  n * aleph_0 = aleph_0  and  aleph_0 * aleph_0 = aleph_0.
    """

    name: str  # human readable, e.g. "n", "aleph_0", "c"

    def __repr__(self) -> str:  # pragma: no cover - cosmetic
        return self.name


ALEPH0 = Cardinal("aleph_0")
CONTINUUM = Cardinal("c")  # c = 2**aleph_0


def continuum_pow_finite(n: int) -> Cardinal:
    """c ** n = c  for every finite n >= 1.

    Proof (squeeze):  c = c**1 <= c**n <= c**aleph_0 = c.
    """
    if n < 1:
        raise ValueError("need n >= 1")
    return CONTINUUM


def continuum_pow_aleph0() -> Cardinal:
    """c ** aleph_0 = c.

    (2**aleph_0)**aleph_0 = 2**(aleph_0 * aleph_0) = 2**aleph_0 = c.
    """
    return CONTINUUM


def card_hilbert_cube() -> Cardinal:
    """|Q| = |[0,1]| ** |N| = c ** aleph_0 = c."""
    return continuum_pow_aleph0()


def card_euclidean(n: int) -> Cardinal:
    """|R^n| = c ** n = c  for n >= 1."""
    return continuum_pow_finite(n)


def demo_cardinality() -> None:
    print("=" * 68)
    print("1. Cardinality is blind to dimension")
    print("=" * 68)
    print(f"|Q| = |[0,1]|^|N| = c^aleph_0 = {card_hilbert_cube()}")
    for n in (1, 2, 3, 10, 1000):
        cn = card_euclidean(n)
        same = cn == card_hilbert_cube()
        print(f"|R^{n:<4}| = c^{n:<4} = {cn}   equals |Q|? {same}")
    print("Under the Continuum Hypothesis, c = aleph_1, so |Q| = aleph_1.")
    print()


# ---------------------------------------------------------------------------
# 2. Transfinite dimensionality: padding / truncation round-trip
# ---------------------------------------------------------------------------

# A Hilbert-cube point is modelled as a function N -> [0,1]; we only ever probe
# finitely many coordinates, so we represent it as a callable.
HilbertPoint = Callable[[int], Fraction]


def cube_section(n: int, x: Sequence[Fraction]) -> HilbertPoint:
    """s_n : [0,1]^n -> Q,   place the n coordinates first, pad tail with 0."""
    if len(x) != n:
        raise ValueError("length mismatch")

    def point(k: int) -> Fraction:
        return x[k] if k < n else Fraction(0)

    return point


def cube_proj(n: int, p: HilbertPoint) -> list[Fraction]:
    """p_n : Q -> [0,1]^n,   read off the first n coordinates."""
    return [p(i) for i in range(n)]


def demo_embedding() -> None:
    print("=" * 68)
    print("2. Transfinite dimensionality: finite cubes embed in Q")
    print("=" * 68)
    for n, x in [
        (2, [Fraction(1, 3), Fraction(2, 5)]),
        (3, [Fraction(1, 7), Fraction(1, 2), Fraction(9, 10)]),
        (5, [Fraction(i + 1, 6) for i in range(5)]),
    ]:
        p = cube_section(n, x)
        recovered = cube_proj(n, p)
        tail = [p(k) for k in range(n, n + 3)]
        print(f"n={n}: x={x}")
        print(f"     padded tail (coords {n}..{n+2}) = {tail}  (all zero)")
        print(f"     p_n(s_n(x)) == x ?  {recovered == list(x)}")
    print("Since this works for every n, Q contains a copy of [0,1]^n for all n:")
    print("no finite dimension can hold Q.")
    print()


# ---------------------------------------------------------------------------
# 3. Self-similarity:  Q ~= Q x [0,1]   and   Q ~= Q x Q
# ---------------------------------------------------------------------------

def peel_forward(k: int) -> tuple[str, int]:
    """tau : N -> N + {*}.   Coordinate 0 becomes the extra '*' slot; every
    other coordinate k>=1 shifts down to k-1 in the main copy of N."""
    if k == 0:
        return ("star", 0)
    return ("nat", k - 1)


def peel_backward(tag: str, j: int) -> int:
    """Inverse of `peel_forward`."""
    if tag == "star":
        return 0
    return j + 1


def absorb_coordinate(p: HilbertPoint) -> tuple[HilbertPoint, Fraction]:
    """Realize Q ~= Q x [0,1]:  split p into a Q-part and one interval value."""
    extra = p(0)  # the coordinate sent to the '*' slot

    def q_part(j: int) -> Fraction:
        return p(peel_backward("nat", j))

    return q_part, extra


def unabsorb_coordinate(q_part: HilbertPoint, extra: Fraction) -> HilbertPoint:
    """Inverse: glue a Q-part and an interval value back into a single Q point."""

    def p(k: int) -> Fraction:
        tag, j = peel_forward(k)
        return extra if tag == "star" else q_part(j)

    return p


def split_coords(k: int) -> tuple[str, int]:
    """sigma : N -> N + N.   Even coordinates -> first copy, odd -> second."""
    return ("left", k // 2) if k % 2 == 0 else ("right", k // 2)


def self_square(p: HilbertPoint) -> tuple[HilbertPoint, HilbertPoint]:
    """Realize Q ~= Q x Q by de-interleaving even/odd coordinates."""
    return (lambda j: p(2 * j), lambda j: p(2 * j + 1))


def demo_self_similarity() -> None:
    print("=" * 68)
    print("3. Self-similarity: Q ~= Q x [0,1] and Q ~= Q x Q")
    print("=" * 68)

    # sample point with distinct, recognizable coordinates
    p: HilbertPoint = lambda k: Fraction(1, k + 2)
    depth = 6
    original = [p(k) for k in range(depth)]

    q_part, extra = absorb_coordinate(p)
    back = unabsorb_coordinate(q_part, extra)
    round_trip = [back(k) for k in range(depth)]
    print("Absorbing one coordinate  Q -> Q x [0,1] -> Q:")
    print(f"   original  coords 0..{depth-1}: {original}")
    print(f"   extracted interval value    : {extra}")
    print(f"   round-trip identical?        {round_trip == original}")

    left, right = self_square(p)
    rebuilt = []
    for k in range(depth):
        rebuilt.append(left(k // 2) if k % 2 == 0 else right(k // 2))
    print("Splitting into a square  Q -> Q x Q -> Q:")
    print(f"   even-coordinate copy  0..2 : {[left(j) for j in range(3)]}")
    print(f"   odd-coordinate  copy  0..2 : {[right(j) for j in range(3)]}")
    print(f"   reinterleaved identical?     {rebuilt == original}")
    print()
    print("A finite cube can never do this: [0,1]^n is never homeomorphic to")
    print("[0,1]^(n+1) or [0,1]^(2n).  The bijection N ~= N+{*} has no finite")
    print("analogue -- the counting obstruction shadows the topological one.")
    print()


def main() -> None:
    demo_cardinality()
    demo_embedding()
    demo_self_similarity()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
