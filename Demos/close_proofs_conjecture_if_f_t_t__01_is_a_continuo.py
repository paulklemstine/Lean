"""
demo.py — Numerical demonstrations of the Tropical Valuation Bridge.

This script illustrates, with concrete numbers, the main results connecting a
non-Archimedean valuation to tropical geometry:

  1. The ultrametric "winner-takes-all" rule:
         v(a + b) = min(v a, v b)            when v a != v b.
  2. Theorem 3.1 — unique strict minimum determines the sum's valuation.
  3. Theorem 4.1 (Kapranov, easy direction) — a point on {sum T_i = 0}
     tropicalizes onto the corner locus (the minimum valuation is attained
     at least twice).
  4. Corollary 4.2 — the classical line a*x + b*y + c = 0 yields a tropical
     corner among v(a*x), v(b*y), v(c).
  5. Theorem 4.3 — leading-term cancellation forces a corner even without
     exact vanishing.
  6. Theorem 5.6 — min-plus multiplicativity: eval(P (x) Q) = eval P + eval Q.

We model the field K as the rationals Q with the p-adic valuation v_p, whose
value group is Z with a formal +infinity for 0 (here represented by math.inf).

Run:  python demo.py
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from typing import Callable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Non-Archimedean valuation: the p-adic valuation on Q.
# ---------------------------------------------------------------------------

def p_adic_valuation(x: Fraction, p: int) -> float:
    """Additive p-adic valuation v_p(x).

    v_p(0) = +infinity; otherwise v_p(p^k * (a/b)) = k where p divides neither
    a nor b. This is an additive valuation: it satisfies
        v_p(x*y) = v_p(x) + v_p(y),
        v_p(x+y) >= min(v_p(x), v_p(y))   (ultrametric inequality).
    """
    if x == 0:
        return math.inf
    num, den = x.numerator, x.denominator
    k = 0
    n = abs(num)
    while n % p == 0:
        n //= p
        k += 1
    d = abs(den)
    while d % p == 0:
        d //= p
        k -= 1
    return float(k)


# ---------------------------------------------------------------------------
# Corner-locus predicate (Definition 2.1) and the Kapranov test (Algorithm B).
# ---------------------------------------------------------------------------

def attained_at_least_twice(weights: Sequence[float]) -> bool:
    """True iff the minimum of `weights` is attained by at least two indices.

    This is the formal `AttainedAtLeastTwice` predicate: the corner-locus /
    tropical-hypersurface condition. Note: a single weight (len == 1) can never
    satisfy it (boundary case, Theorem 2.2).
    """
    if len(weights) < 2:
        return False
    mu = min(weights)
    return sum(1 for w in weights if w == mu) >= 2


def valuation_of_sum_unique_min(values: Sequence[float]) -> Tuple[bool, float]:
    """Algorithm A: if a strict unique minimum exists, return its value as the
    valuation of the sum (Theorem 3.1). Returns (is_determined, value)."""
    mu = min(values)
    multiplicity = sum(1 for v in values if v == mu)
    if multiplicity == 1:
        return True, mu
    return False, mu


# ---------------------------------------------------------------------------
# Demo 1 & 2: winner-takes-all and unique-minimum sum rule.
# ---------------------------------------------------------------------------

def demo_winner_takes_all() -> None:
    print("=" * 70)
    print("DEMO 1/2: Ultrametric winner-takes-all (p = 3)")
    print("=" * 70)
    p = 3
    cases = [
        (Fraction(9), Fraction(2)),        # v=2 vs v=0  -> unique min 0
        (Fraction(81), Fraction(1, 27)),   # v=4 vs v=-3 -> unique min -3
        (Fraction(6), Fraction(15)),       # v=1 vs v=1  -> tie (cancellation possible)
    ]
    for a, b in cases:
        va, vb = p_adic_valuation(a, p), p_adic_valuation(b, p)
        vs = p_adic_valuation(a + b, p)
        print(f"  a={a}, b={b}:  v(a)={va}, v(b)={vb}, v(a+b)={vs}")
        if va != vb:
            assert vs == min(va, vb), "winner-takes-all violated!"
            print(f"      -> distinct valuations: v(a+b) = min = {min(va, vb)}  [Thm 3.1]")
        else:
            print(f"      -> tie at v={va}: cancellation possible, v(a+b) may jump up")
    print()


# ---------------------------------------------------------------------------
# Demo 3: Kapranov, easy direction.
# ---------------------------------------------------------------------------

def demo_kapranov(terms: Sequence[Fraction], p: int) -> None:
    """Given monomial values T_i with sum 0 and some T_i != 0, verify the
    tropicalized minimum is attained at least twice (Theorem 4.1)."""
    assert sum(terms) == 0, "point must lie on the hypersurface {sum T_i = 0}"
    assert any(t != 0 for t in terms), "need a nonzero term"
    weights = [p_adic_valuation(t, p) for t in terms]
    print(f"  T = {[str(t) for t in terms]}  (sum = {sum(terms)})")
    print(f"  tropicalized weights v(T_i) = {weights}")
    twice = attained_at_least_twice(weights)
    print(f"  minimum attained at least twice?  {twice}   [Kapranov, Thm 4.1]")
    assert twice, "Kapranov easy direction FAILED"


def demo_kapranov_examples() -> None:
    print("=" * 70)
    print("DEMO 3: Kapranov easy direction — solutions land on the corner locus")
    print("=" * 70)
    p = 3
    # Example: 3 + 6 - 9 = 0; weights v(3)=1, v(6)=1, v(-9)=2 -> min=1 twice.
    demo_kapranov([Fraction(3), Fraction(6), Fraction(-9)], p)
    print()
    # Example: 9 + 9 - 18 = 0; v(9)=2, v(9)=2, v(-18)=2 -> all tie.
    demo_kapranov([Fraction(9), Fraction(9), Fraction(-18)], p)
    print()


# ---------------------------------------------------------------------------
# Demo 4: classical line -> tropical corner (Corollary 4.2).
# ---------------------------------------------------------------------------

def demo_tropical_line() -> None:
    print("=" * 70)
    print("DEMO 4: Classical line a*x + b*y + c = 0 -> tropical line corner")
    print("=" * 70)
    p = 5
    # Pick a line and a point on it: a=1, b=1, c=-(x+y).
    a, b = Fraction(25), Fraction(1)
    x, y = Fraction(2), Fraction(5)
    c = -(a * x + b * y)
    assert a * x + b * y + c == 0
    terms = [a * x, b * y, c]
    weights = [p_adic_valuation(t, p) for t in terms]
    print(f"  a={a}, b={b}, c={c}, x={x}, y={y}")
    print(f"  terms (a*x, b*y, c) = {[str(t) for t in terms]}")
    print(f"  weights v = {weights}")
    print(f"  corner present?  {attained_at_least_twice(weights)}   [Cor 4.2]")
    assert attained_at_least_twice(weights)
    print()


# ---------------------------------------------------------------------------
# Demo 5: leading-term cancellation (Theorem 4.3) without exact vanishing.
# ---------------------------------------------------------------------------

def demo_leading_cancellation() -> None:
    print("=" * 70)
    print("DEMO 5: Leading-term cancellation forces a corner (Thm 4.3)")
    print("=" * 70)
    p = 3
    # 3 + (-3) + 81 = 81 != 0, but the two leading (v=1) terms cancel, so the
    # sum's valuation jumps to 4 > 1 = min weight.
    terms = [Fraction(3), Fraction(-3), Fraction(81)]
    weights = [p_adic_valuation(t, p) for t in terms]
    s = sum(terms)
    vs = p_adic_valuation(s, p)
    mu = min(weights)
    print(f"  T = {[str(t) for t in terms]}, sum = {s} (nonzero!)")
    print(f"  weights v = {weights}, min = {mu}, v(sum) = {vs}")
    print(f"  jump v(sum) > min?  {vs > mu}")
    print(f"  corner present?     {attained_at_least_twice(weights)}   [Thm 4.3]")
    assert vs > mu and attained_at_least_twice(weights)
    print()


# ---------------------------------------------------------------------------
# Min-plus tropical polynomials and multiplicativity (Section 5).
# ---------------------------------------------------------------------------

@dataclass
class TropPoly:
    """A tropical polynomial: lists of coefficients and exponent vectors.

    coeffs[i] is the tropical coefficient of monomial i;
    exps[i] is its exponent vector (length n).
    """
    coeffs: List[float]
    exps: List[List[float]]

    def term_val(self, x: Sequence[float], i: int) -> float:
        """Definition 5.2: coeff_i + <exp_i, x>."""
        return self.coeffs[i] + sum(e * xk for e, xk in zip(self.exps[i], x))

    def eval(self, x: Sequence[float]) -> float:
        """Definition 5.3: min over monomials of term_val."""
        return min(self.term_val(x, i) for i in range(len(self.coeffs)))

    def mul(self, other: "TropPoly") -> "TropPoly":
        """Definition 5.4: tropical product (add coeffs and exps pairwise)."""
        new_coeffs: List[float] = []
        new_exps: List[List[float]] = []
        for i, j in product(range(len(self.coeffs)), range(len(other.coeffs))):
            new_coeffs.append(self.coeffs[i] + other.coeffs[j])
            new_exps.append([a + b for a, b in zip(self.exps[i], other.exps[j])])
        return TropPoly(new_coeffs, new_exps)


def demo_min_plus_multiplicativity() -> None:
    print("=" * 70)
    print("DEMO 6: Min-plus multiplicativity  eval(P (x) Q) = eval P + eval Q")
    print("=" * 70)
    # Two univariate (n=1) tropical polynomials.
    P = TropPoly(coeffs=[0.0, 1.0, 3.0], exps=[[0.0], [1.0], [2.0]])
    Q = TropPoly(coeffs=[2.0, 0.0], exps=[[0.0], [1.0]])
    PQ = P.mul(Q)
    for x_val in (-2.0, -0.5, 0.0, 1.0, 3.5):
        x = [x_val]
        lhs = PQ.eval(x)
        rhs = P.eval(x) + Q.eval(x)
        print(f"  x={x_val:>5}:  eval(P(x)Q)={lhs:>6.2f}   "
              f"eval P + eval Q = {rhs:>6.2f}   match={math.isclose(lhs, rhs)}")
        assert math.isclose(lhs, rhs), "min-plus multiplicativity FAILED"
    print()


# ---------------------------------------------------------------------------
# Bonus: min-plus distributive law (Lemma 5.5), the engine of Demo 6.
# ---------------------------------------------------------------------------

def demo_inf_product_add() -> None:
    print("=" * 70)
    print("DEMO 7: Min-plus distributivity  min_{i,k}(f_i+g_k) = min f + min g")
    print("=" * 70)
    f: List[float] = [4.0, 1.0, 7.0]
    g: List[float] = [2.0, 5.0, 0.0, 3.0]
    lhs = min(fi + gk for fi in f for gk in g)
    rhs = min(f) + min(g)
    print(f"  f = {f}, g = {g}")
    print(f"  min over product = {lhs},   min f + min g = {rhs},   match={lhs == rhs}")
    assert lhs == rhs
    print()


def main() -> None:
    demo_winner_takes_all()
    demo_kapranov_examples()
    demo_tropical_line()
    demo_leading_cancellation()
    demo_min_plus_multiplicativity()
    demo_inf_product_add()
    print("All demonstrations passed: the bridge holds numerically.")


if __name__ == "__main__":
    main()
