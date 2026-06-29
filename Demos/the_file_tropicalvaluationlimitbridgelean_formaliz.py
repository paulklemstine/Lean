"""
demo.py — Numerical demonstration of the Valuation–Tropicalization morphism bridge.

This self-contained script illustrates the main results of the package
"The Non-Archimedean Valuation as a Tropical Semiring Morphism, Up to Its Defect":

  * exact multiplicativity        tropVal(x*y) = tropVal(x) (+) tropVal(y)
  * sub-additivity                tropVal(x) (min) tropVal(y) <= tropVal(x+y)
  * additivity off the tie set    v(x) != v(y)  =>  v(x+y) = min(v(x), v(y))
  * defect locus subset tie set   v(x+y) != min(v(x), v(y))  =>  v(x) = v(y)
  * binary corner locus = tie set AttainedAtLeastTwice([a, b])  <=>  a == b
  * defects are corners           every additive defect of v is a corner point

We model K = Q with the p-adic valuation v_p, and Gamma = Z u {+infinity}.
Tropical multiplication is ordinary addition; tropical addition is min.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import combinations
from math import inf
from typing import List, Optional, Tuple, Union

Val = Union[int, float]  # an element of Gamma = Z u {+inf}; +inf is float('inf')


# --------------------------------------------------------------------------- #
# Section 1.  The non-Archimedean (p-adic) valuation v_p : Q -> Z u {+inf}
# --------------------------------------------------------------------------- #
def integer_valuation(n: int, p: int) -> Val:
    """v_p(n): the exponent of the prime p in the integer n; +inf for n = 0."""
    if n == 0:
        return inf
    count = 0
    n = abs(n)
    while n % p == 0:
        n //= p
        count += 1
    return count


def padic_valuation(x: Fraction, p: int) -> Val:
    """v_p(a/b) = v_p(a) - v_p(b); v_p(0) = +inf. (Algorithm 7.1)"""
    if x == 0:
        return inf
    num = integer_valuation(x.numerator, p)
    den = integer_valuation(x.denominator, p)
    return num - den  # both finite here since x != 0


# --------------------------------------------------------------------------- #
# Section 2.  Tropical semiring operations on Gamma = Z u {+inf}
#   tropical multiplication  (.)  =  ordinary addition (with +inf absorbing)
#   tropical addition        (+)  =  minimum
#   tropical mult identity   = 0  ;  tropical add identity = +inf
# --------------------------------------------------------------------------- #
def trop_mul(a: Val, b: Val) -> Val:
    """Tropical product = ordinary sum (+inf is absorbing)."""
    if a == inf or b == inf:
        return inf
    return a + b


def trop_add(a: Val, b: Val) -> Val:
    """Tropical sum = minimum."""
    return min(a, b)


# --------------------------------------------------------------------------- #
# Section 3.  Tropicalization map  tropVal = trop o v  (here just v itself,
#             since we identify Tropical(Gamma) with Gamma as a carrier).
# --------------------------------------------------------------------------- #
def trop_val(x: Fraction, p: int) -> Val:
    """tropVal(x) = trop(v_p(x)); on the carrier this is just v_p(x)."""
    return padic_valuation(x, p)


# --------------------------------------------------------------------------- #
# Section 4.  Defect detector  (Algorithm 7.2)
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class DefectReport:
    x: Fraction
    y: Fraction
    v_x: Val
    v_y: Val
    v_sum: Val
    predicted: Val      # min(v_x, v_y)
    is_defect: bool      # v_sum != predicted
    is_tie: bool         # v_x == v_y


def analyze_pair(x: Fraction, y: Fraction, p: int) -> DefectReport:
    """Compare v(x+y) with min(v x, v y) and record tie status."""
    vx, vy = trop_val(x, p), trop_val(y, p)
    vsum = trop_val(x + y, p)
    predicted = trop_add(vx, vy)
    return DefectReport(
        x=x, y=y, v_x=vx, v_y=vy, v_sum=vsum,
        predicted=predicted,
        is_defect=(vsum != predicted),
        is_tie=(vx == vy),
    )


# --------------------------------------------------------------------------- #
# Section 5.  Corner-locus predicate (Definition 2.4) and the Fin 2 checker
# --------------------------------------------------------------------------- #
def attained_at_least_twice(w: List[Val]) -> bool:
    """Brute-force: the global minimum of w is achieved by >= 2 distinct indices."""
    if len(w) < 2:
        return False
    m = min(w)
    return sum(1 for v in w if v == m) >= 2


def corner_two_monomials(a: Val, b: Val) -> bool:
    """Theorem 6.1: AttainedAtLeastTwice([a, b]) <=> a == b."""
    return a == b


# --------------------------------------------------------------------------- #
# Section 6.  Demonstrations
# --------------------------------------------------------------------------- #
def demo_multiplicativity(p: int) -> None:
    print(f"\n=== Exact multiplicativity (p = {p}) ===")
    samples: List[Tuple[Fraction, Fraction]] = [
        (Fraction(p ** 2), Fraction(p, 1)),
        (Fraction(6), Fraction(10)),
        (Fraction(1, p), Fraction(p ** 3)),
        (Fraction(7), Fraction(p)),
    ]
    for x, y in samples:
        lhs = trop_val(x * y, p)
        rhs = trop_mul(trop_val(x, p), trop_val(y, p))
        ok = lhs == rhs
        print(f"  v({x} * {y}) = {lhs:>4}   v(x) (.) v(y) = {rhs:>4}   match={ok}")
        assert ok, "multiplicativity must hold exactly"


def demo_subadditivity_and_defect(p: int) -> None:
    print(f"\n=== Sub-additivity, additivity off ties, and defects (p = {p}) ===")
    samples: List[Tuple[Fraction, Fraction]] = [
        (Fraction(p), Fraction(p ** 2)),       # different valuations: equality
        (Fraction(5), Fraction(7)),            # both v = 0, but no cancellation
        (Fraction(p), Fraction(2 * p)),        # tie v=1, sum=3p valuation 1: equality
        (Fraction(p), Fraction(p - p ** 2)),   # tie, leading parts cancel: DEFECT
        (Fraction(p), Fraction(-p)),           # x + (-x) = 0: maximal DEFECT
    ]
    for x, y in samples:
        r = analyze_pair(x, y, p)
        # sub-additivity always holds:
        assert r.predicted <= r.v_sum, "sub-additivity must hold"
        # additivity off the tie set (Theorem 3.1):
        if r.v_x != r.v_y:
            assert not r.is_defect, "must be additive off the tie set"
        # defect => tie (Theorem 3.2):
        if r.is_defect:
            assert r.is_tie, "every defect must be on the tie set"
        tag = "DEFECT" if r.is_defect else "ok    "
        tie = "tie " if r.is_tie else "    "
        print(f"  x={str(x):>8} y={str(y):>8} | v(x)={r.v_x} v(y)={r.v_y} "
              f"min={r.predicted} v(x+y)={r.v_sum} [{tag}] {tie}")


def demo_corner_equivalence(p: int) -> None:
    print(f"\n=== Binary corner locus = tie set, and defects are corners (p = {p}) ===")
    samples: List[Tuple[Fraction, Fraction]] = [
        (Fraction(p), Fraction(-p)),           # tie + defect -> corner
        (Fraction(p), Fraction(p - p ** 2)),   # tie + defect -> corner
        (Fraction(p), Fraction(p ** 2)),       # not a tie -> not a corner
    ]
    for x, y in samples:
        r = analyze_pair(x, y, p)
        w = [r.v_x, r.v_y]
        brute = attained_at_least_twice(w)
        closed = corner_two_monomials(r.v_x, r.v_y)
        assert brute == closed, "Theorem 6.1: corner <=> a == b"
        if r.is_defect:
            assert closed, "Theorem 6.2: every defect is a corner"
        print(f"  weights={w} | corner(brute)={brute} corner(a==b)={closed} "
              f"defect={r.is_defect}")


def demo_scale_invariance(p: int) -> None:
    print(f"\n=== Scale invariance of the corner locus (valuation -> infinity) ===")
    weights = [trop_val(Fraction(p), p), trop_val(Fraction(-p), p)]
    for t in (1, 2, 5, 100):
        scaled = [t * w for w in weights]
        print(f"  t={t:>4}: weights={scaled}  corner={attained_at_least_twice(scaled)}")
    print("  (corner membership is invariant under positive rescaling)")


def main() -> None:
    print("Valuation -> Tropical morphism: numerical demonstration")
    print("=" * 60)
    for p in (3, 5):
        demo_multiplicativity(p)
        demo_subadditivity_and_defect(p)
        demo_corner_equivalence(p)
        demo_scale_invariance(p)
    print("\nAll assertions passed: the morphism laws and 'defect = corner' hold.")


if __name__ == "__main__":
    main()
