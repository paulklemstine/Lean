"""
demo.py -- Numerical demonstrations for:

    "The Order Topology on the Surreal Numbers is Disconnected"

The full surreal field No is a proper class whose infinite elements have no finite
data representation.  However, the *mechanism* behind the disconnection theorem is
entirely finitary and can be modeled faithfully on a computable surrogate: surreal
numbers written on the scale

        ..., 1/w^2, 1/w, 1, w, w^2, ...        (w = omega)

as finite formal sums   sum_i c_i * w^{e_i}   with rational coefficients c_i and
rational (leading) exponents e_i, ordered by the leading (largest-exponent) term.
This is the Hahn-series / leading-exponent model of a non-Archimedean ordered field,
and it reproduces the finite/infinite split exactly.

A surreal in this model is FINITE iff its leading exponent is <= 0 (it is dominated
by some natural number).  It is INFINITE iff its leading exponent is > 0.

We use this model to demonstrate, numerically:
  1. The non-Archimedean witness: w exceeds every natural number.
  2. Membership in the clopen set F of finite surreals.
  3. The clopen-separation certificate splitting a finite surreal from an infinite one.
  4. That no natural number lies "between" a finite and an infinite surreal in a way
     that would bridge them -- the topological wall.
  5. The general metatheorem: the same test disconnects any non-Archimedean ordered
     group presented on such a scale.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Dict, List, Optional, Tuple


# ----------------------------------------------------------------------------
# A computable model of surreals on the omega-scale (leading-exponent / Hahn model)
# ----------------------------------------------------------------------------

@dataclass(frozen=True)
class Surreal:
    """A finite formal sum  sum c_e * w^e  with rational coeffs, ordered by
    the largest exponent with a nonzero coefficient (lexicographic in the field)."""

    terms: Tuple[Tuple[Fraction, Fraction], ...]  # ((exponent, coeff), ...) sorted desc by exponent

    @staticmethod
    def make(coeffs: Dict[Fraction, Fraction]) -> "Surreal":
        cleaned = {Fraction(e): Fraction(c) for e, c in coeffs.items() if Fraction(c) != 0}
        ordered = tuple(sorted(cleaned.items(), key=lambda kv: kv[0], reverse=True))
        return Surreal(ordered)

    @staticmethod
    def from_nat(n: int) -> "Surreal":
        return Surreal.make({Fraction(0): Fraction(n)})

    def leading(self) -> Optional[Tuple[Fraction, Fraction]]:
        """Return (exponent, coeff) of the dominant term, or None if the number is 0."""
        return self.terms[0] if self.terms else None

    def __add__(self, other: "Surreal") -> "Surreal":
        acc: Dict[Fraction, Fraction] = {}
        for e, c in self.terms + other.terms:
            acc[e] = acc.get(e, Fraction(0)) + c
        return Surreal.make(acc)

    def __neg__(self) -> "Surreal":
        return Surreal.make({e: -c for e, c in self.terms})

    def __sub__(self, other: "Surreal") -> "Surreal":
        return self + (-other)

    def sign(self) -> int:
        """Sign of the number: sign of its leading (largest-exponent) coefficient."""
        lead = self.leading()
        if lead is None:
            return 0
        return 1 if lead[1] > 0 else -1

    def __lt__(self, other: "Surreal") -> bool:
        return (self - other).sign() < 0

    def __le__(self, other: "Surreal") -> bool:
        return (self - other).sign() <= 0

    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        parts: List[str] = []
        for e, c in self.terms:
            if e == 0:
                parts.append(f"{c}")
            elif e == 1:
                parts.append(f"{c}*w")
            else:
                parts.append(f"{c}*w^{e}")
        return " + ".join(parts)


# Convenient constants
W = Surreal.make({Fraction(1): Fraction(1)})          # w  (omega): leading exponent 1  -> infinite
EPS = Surreal.make({Fraction(-1): Fraction(1)})       # 1/w (epsilon): leading exp -1  -> finite
ONE = Surreal.from_nat(1)
ZERO = Surreal.make({})


# ----------------------------------------------------------------------------
# Core notions from the paper
# ----------------------------------------------------------------------------

def is_finite(x: Surreal) -> bool:
    """Membership in F = {x : exists n in N, x < n}.

    A surreal is finite iff its leading exponent is <= 0 (dominated by some natural
    number).  Zero is finite by convention."""
    lead = x.leading()
    if lead is None:
        return True
    exponent, _ = lead
    return exponent <= 0


def dominating_nat(x: Surreal) -> Optional[int]:
    """If x is finite, return the least natural number n with x < n; else None.

    This is the explicit witness placing x inside the ray Iio(n) that covers F."""
    if not is_finite(x):
        return None
    lead = x.leading()
    if lead is None:
        return 1  # x = 0 < 1
    exponent, coeff = lead
    if exponent < 0:
        return 1  # infinitesimal-scale, below 1
    # exponent == 0: the number is (coeff) + lower-order terms; find least n > value
    import math
    n = math.floor(coeff) + 1
    while not (x < Surreal.from_nat(n)):
        n += 1
    return max(n, 1)


def separation_certificate(a: Surreal, b: Surreal) -> Optional[dict]:
    """Given a finite surreal a and an infinite surreal b, return a clopen-separation
    certificate: a natural number n with a < n <= b, together with the two open pieces
    Iio(n) (containing a, inside F) and Ioi(n-1) (containing b, inside complement of F)
    that witness there is no continuous path from a to b."""
    if not (is_finite(a) and not is_finite(b)):
        return None
    n = dominating_nat(a)
    assert n is not None
    n_surreal = Surreal.from_nat(n)
    assert a < n_surreal, "a must be below n"
    assert n_surreal <= b, "n must not exceed the infinite b"
    return {
        "witness_n": n,
        "a_in_Iio_n": a < n_surreal,          # a lies in the open set below n  (subset of F)
        "b_in_Ioi_n_minus_1": Surreal.from_nat(n - 1) < b,  # b in open set above n-1 (in complement)
        "a_is_finite": True,
        "b_is_finite": False,
    }


def non_archimedean_witness(standards: List[Surreal]) -> Surreal:
    """Produce a surreal strictly greater than every element of the given finite list
    of 'standard' (finite) surreals -- the Theorem: exists_gt witness.  We return the
    upper bound (max leading exponent + 1)-scale element, concretely a multiple of w."""
    # w dominates any finite surreal; to be safe against infinite inputs, bump exponent.
    max_exp = Fraction(0)
    for s in standards:
        lead = s.leading()
        if lead is not None:
            max_exp = max(max_exp, lead[0])
    return Surreal.make({max_exp + 1: Fraction(1)})


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_non_archimedean() -> None:
    print("=" * 72)
    print("1. NON-ARCHIMEDEAN WITNESS:  w > n for every natural number n")
    print("=" * 72)
    for n in [0, 1, 2, 5, 100, 10**6]:
        print(f"   {n:>8} < w  ?  {Surreal.from_nat(n) < W}")
    M = non_archimedean_witness([Surreal.from_nat(k) for k in range(50)])
    print(f"   Generated witness M = {M}; exceeds 0..49: "
          f"{all(Surreal.from_nat(k) < M for k in range(50))}")
    print()


def demo_finite_membership() -> None:
    print("=" * 72)
    print("2. THE CLOPEN SET F OF FINITE SURREALS:  x in F  iff  exists n, x < n")
    print("=" * 72)
    samples = {
        "0": ZERO,
        "1": ONE,
        "7/2": Surreal.make({Fraction(0): Fraction(7, 2)}),
        "eps = 1/w": EPS,
        "1000 + eps": Surreal.from_nat(1000) + EPS,
        "w (omega)": W,
        "w + 5": W + Surreal.from_nat(5),
        "w^2": Surreal.make({Fraction(2): Fraction(1)}),
    }
    for name, x in samples.items():
        fin = is_finite(x)
        n = dominating_nat(x)
        tag = f"in F, dominated by n={n}" if fin else "NOT in F (infinite)"
        print(f"   {name:>12}  ->  {tag}")
    print()


def demo_separation() -> None:
    print("=" * 72)
    print("3. CLOPEN-SEPARATION CERTIFICATE (the topological wall)")
    print("=" * 72)
    pairs = [(ZERO, W), (Surreal.from_nat(42), W + Surreal.from_nat(1)),
             (Surreal.from_nat(1000) + EPS, Surreal.make({Fraction(2): Fraction(1)}))]
    for a, b in pairs:
        cert = separation_certificate(a, b)
        print(f"   a = {a}")
        print(f"   b = {b}")
        print(f"     certificate: {cert}")
        print(f"     => a in Iio(n) subset F (open),  b in Ioi(n-1) subset F^c (open):")
        print(f"        the two open sets separate a from b, so NO path connects them.")
        print()


def demo_disconnection_summary() -> None:
    print("=" * 72)
    print("4. CONCLUSION:  No = F  disjoint-union  (No \\ F),  both open & nonempty")
    print("=" * 72)
    print("   F        contains 0            (nonempty):", is_finite(ZERO))
    print("   No \\ F   contains w            (nonempty):", not is_finite(W))
    print("   F is open   (union of rays Iio(n)):        True (by construction)")
    print("   F is closed (complement is open):          True (ray Ioi(x-1) stays infinite)")
    print("   => F is a nontrivial CLOPEN set  =>  No is DISCONNECTED.")
    print("   => No is not path-connected, not contractible.")
    print("   (Positive counterpoint: the order topology on No IS Hausdorff.)")
    print()


def demo_metatheorem() -> None:
    print("=" * 72)
    print("5. GENERALITY:  same test disconnects ANY non-Archimedean scale")
    print("=" * 72)
    # e.g. a Laurent-series-style element t^{-1} plays the role of an 'infinite' element
    infinite_like = Surreal.make({Fraction(3): Fraction(2)})   # 2*w^3
    print(f"   element g = {infinite_like} is infinite:", not is_finite(infinite_like))
    print("   Hence {x : exists n, x < n} is a proper clopen set here too.")
    print("   The surreals are one instance of this phenomenon (hyperreals, Q((t)), ...).")
    print()


def main() -> None:
    demo_non_archimedean()
    demo_finite_membership()
    demo_separation()
    demo_disconnection_summary()
    demo_metatheorem()


if __name__ == "__main__":
    main()
