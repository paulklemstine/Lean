"""
Numerical demonstrations for the corrected-product torsor of normalized q-series.
=================================================================================

A Laurent series  f = q^{-1} + a_0 + a_1 q + a_2 q^2 + ...  is called *normalized*.
Normalized series are NOT closed under multiplication (a product of m of them has a
pole of order m), but they ARE closed under the *corrected product*

        f * g  :=  q . f . g          (written `cmul` below).

Everything in this file is exact rational (or exact integer) arithmetic on truncated
one-unit coordinates:  a normalized series f corresponds to the power series
u = q f = 1 + u_1 q + u_2 q^2 + ...  with constant term 1, and in these coordinates
the corrected product is ORDINARY multiplication of power series.

Demonstrated results
--------------------
 1. The pole-order obstruction and the uniqueness of the q^1 correction.
 2. Closure of the corrected product and the commutative group law
    (identity q^{-1}, inverse q^{-2} f^{-1}).
 3. The iterate identity  f^{*n} = q^{n-1} f^n.
 4. Linear growth of the depth invariant:  c_k(f^{*n}) = n c_k(f).
 5. Quadratic growth at twice the depth: c_2k(f^{*n}) = n c_2k(f) + C(n,2) c_k(f)^2.
 6. The exact finite binomial expansion, and polynomial degree exactly j at level jk.
 7. Finite determination: the level-m invariant is pinned by floor(m/k)+1 iterates.
 8. Unique corrected roots and complex one-parameter subgroups via the binomial series.
 9. Monstrous moonshine: the q- and q^3-coefficients of the iterates of
    J = q^{-1} + 196884 q + 21493760 q^2 + 864299970 q^3 + ...
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import Dict, List, Sequence, Tuple

Scalar = Fraction

# ----------------------------------------------------------------------------------
# Truncated power series arithmetic (one-unit coordinates)
# ----------------------------------------------------------------------------------


def ps_trunc(coeffs: Sequence[Scalar], prec: int) -> List[Scalar]:
    """Truncate/pad a coefficient list to exactly `prec` coefficients (degrees 0..prec-1)."""
    out: List[Scalar] = [Fraction(0)] * prec
    for i in range(min(prec, len(coeffs))):
        out[i] = Fraction(coeffs[i])
    return out


def ps_mul(a: Sequence[Scalar], b: Sequence[Scalar], prec: int) -> List[Scalar]:
    """Cauchy product of two truncated power series, modulo q^prec."""
    out: List[Scalar] = [Fraction(0)] * prec
    for i, ai in enumerate(a[:prec]):
        if ai == 0:
            continue
        for j, bj in enumerate(b[: prec - i]):
            if bj != 0:
                out[i + j] += ai * bj
    return out


def ps_pow(a: Sequence[Scalar], n: int, prec: int) -> List[Scalar]:
    """n-th power of a truncated power series by binary exponentiation."""
    result = ps_trunc([Fraction(1)], prec)
    base = ps_trunc(a, prec)
    e = n
    while e > 0:
        if e & 1:
            result = ps_mul(result, base, prec)
        base = ps_mul(base, base, prec)
        e >>= 1
    return result


def ps_inv_one_unit(a: Sequence[Scalar], prec: int) -> List[Scalar]:
    """Inverse of a power series with constant term 1 (triangular recursion)."""
    assert Fraction(a[0]) == 1, "expected a one-unit (constant term 1)"
    out: List[Scalar] = [Fraction(0)] * prec
    out[0] = Fraction(1)
    for m in range(1, prec):
        s = Fraction(0)
        for i in range(1, m + 1):
            if i < len(a):
                s += Fraction(a[i]) * out[m - i]
        out[m] = -s
    return out


def ps_sub(a: Sequence[Scalar], b: Sequence[Scalar], prec: int) -> List[Scalar]:
    return [Fraction(a[i] if i < len(a) else 0) - Fraction(b[i] if i < len(b) else 0)
            for i in range(prec)]


# ----------------------------------------------------------------------------------
# Normalized Laurent series, stored by their one-unit coordinate u = q f
# ----------------------------------------------------------------------------------


class Normalized:
    """A normalized Laurent series q^{-1} + a_0 + a_1 q + ..., truncated.

    Internally we store the one-unit u = q f = 1 + a_0 q + a_1 q^2 + ...
    The level-k invariant is c_k = [q^k] u = [q^{k-1}] f;  c_0 = 1 always.
    """

    __slots__ = ("u", "prec")

    def __init__(self, u: Sequence[Scalar], prec: int) -> None:
        self.prec = prec
        self.u = ps_trunc(u, prec)
        assert self.u[0] == 1, "one-unit coordinate must have constant term 1"

    # --- constructors -------------------------------------------------------------
    @staticmethod
    def identity(prec: int) -> "Normalized":
        """The base point q^{-1}, the identity of the corrected product."""
        return Normalized([Fraction(1)], prec)

    @staticmethod
    def from_laurent_tail(tail: Sequence[Scalar], prec: int) -> "Normalized":
        """Build q^{-1} + tail[0] + tail[1] q + tail[2] q^2 + ..."""
        return Normalized([Fraction(1)] + [Fraction(t) for t in tail], prec)

    # --- group operations ---------------------------------------------------------
    def cmul(self, other: "Normalized") -> "Normalized":
        """The corrected product f * g = q f g (= ordinary product of one-units)."""
        prec = min(self.prec, other.prec)
        return Normalized(ps_mul(self.u, other.u, prec), prec)

    def cinv(self) -> "Normalized":
        """The corrected inverse q^{-2} f^{-1} (= inverse of the one-unit)."""
        return Normalized(ps_inv_one_unit(self.u, self.prec), self.prec)

    def cpow_nat(self, n: int) -> "Normalized":
        """The n-th corrected-product iterate f^{*n} = q^{n-1} f^n."""
        return Normalized(ps_pow(self.u, n, self.prec), self.prec)

    # --- invariants ---------------------------------------------------------------
    def c(self, k: int) -> Scalar:
        """Level-k invariant: the coefficient of q^{k-1} in f."""
        return self.u[k] if k < self.prec else Fraction(0)

    def depth(self) -> int:
        """First level k >= 1 with c_k != 0; 0 means 'indistinguishable from q^{-1}'."""
        for k in range(1, self.prec):
            if self.u[k] != 0:
                return k
        return 0

    def laurent_coeff(self, n: int) -> Scalar:
        """Coefficient of q^n in f itself (n >= -1)."""
        return self.c(n + 1)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Normalized) and self.u == other.u

    def __repr__(self) -> str:
        terms = ["q^-1"]
        for k in range(1, min(self.prec, 5)):
            a = self.u[k]
            if a != 0:
                power = k - 1
                mono = "" if power == 0 else (" q" if power == 1 else f" q^{power}")
                terms.append(f"{a}{mono}")
        return " + ".join(terms) + " + ..."


# ----------------------------------------------------------------------------------
# Laurent-level arithmetic, used only to double-check the corrected product
# ----------------------------------------------------------------------------------


def laurent_of(f: Normalized) -> Dict[int, Scalar]:
    """Dictionary  exponent -> coefficient  for the Laurent series f."""
    return {k - 1: f.u[k] for k in range(f.prec) if f.u[k] != 0}


def laurent_mul(a: Dict[int, Scalar], b: Dict[int, Scalar], lo: int, hi: int) -> Dict[int, Scalar]:
    """Product of two Laurent dictionaries, keeping exponents in [lo, hi]."""
    out: Dict[int, Scalar] = {}
    for i, ai in a.items():
        for j, bj in b.items():
            e = i + j
            if lo <= e <= hi:
                out[e] = out.get(e, Fraction(0)) + ai * bj
    return {e: c for e, c in out.items() if c != 0}


def laurent_order(a: Dict[int, Scalar]) -> int:
    return min(a) if a else 0


def laurent_shift(a: Dict[int, Scalar], m: int) -> Dict[int, Scalar]:
    """Multiply by q^m."""
    return {e + m: c for e, c in a.items()}


def is_normalized_laurent(a: Dict[int, Scalar]) -> bool:
    """Check: coefficient of q^{-1} is 1 and nothing below."""
    return a.get(-1, Fraction(0)) == 1 and all(e >= -1 for e in a)


# ----------------------------------------------------------------------------------
# Binomial-series machinery: corrected roots and complex one-parameter subgroups
# ----------------------------------------------------------------------------------


def binomial_generalized(r: Fraction, d: int) -> Fraction:
    """The generalized binomial coefficient C(r,d) = r(r-1)...(r-d+1)/d!."""
    num = Fraction(1)
    for i in range(d):
        num *= r - i
    den = Fraction(1)
    for i in range(1, d + 1):
        den *= i
    return num / den


def cpow_rational(f: Normalized, r: Fraction) -> Normalized:
    """The corrected power f^{*r} for a rational exponent r.

    Obtained by substituting w = q f - 1 into the binomial series (1+X)^r; the
    substitution terminates at each truncation order because w has zero constant term.
    """
    prec = f.prec
    w = ps_sub(f.u, [Fraction(1)], prec)
    acc: List[Scalar] = [Fraction(0)] * prec
    power: List[Scalar] = ps_trunc([Fraction(1)], prec)  # w^0
    for d in range(prec):
        coeff = binomial_generalized(r, d)
        if coeff != 0:
            for i in range(prec):
                acc[i] += coeff * power[i]
        power = ps_mul(power, w, prec)
        if all(x == 0 for x in power):
            break
    return Normalized(acc, prec)


def binomial_weights(f: Normalized, k: int, m: int) -> List[Scalar]:
    """The n-independent weights omega_d = [q^m] (q f - 1)^d for d = 0..floor(m/k)."""
    prec = f.prec
    w = ps_sub(f.u, [Fraction(1)], prec)
    weights: List[Scalar] = []
    power = ps_trunc([Fraction(1)], prec)
    for _ in range(m // k + 1):
        weights.append(power[m] if m < prec else Fraction(0))
        power = ps_mul(power, w, prec)
    return weights


def invariant_from_weights(weights: Sequence[Scalar], n: int) -> Scalar:
    """Evaluate sum_d C(n,d) omega_d -- the level-m invariant of the n-th iterate."""
    return sum((Fraction(comb(n, d)) * w for d, w in enumerate(weights)), Fraction(0))


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------

PREC = 24


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_obstruction() -> None:
    banner("1. The pole-order obstruction and the uniqueness of the correction")
    f = Normalized.from_laurent_tail([Fraction(3), Fraction(-1), Fraction(7)], PREC)
    g = Normalized.from_laurent_tail([Fraction(0), Fraction(5), Fraction(2)], PREC)
    print(f"f = {f}")
    print(f"g = {g}")
    lf, lg = laurent_of(f), laurent_of(g)
    prod = laurent_mul(lf, lg, -4, 6)
    print(f"order(f) = {laurent_order(lf)},  order(g) = {laurent_order(lg)},"
          f"  order(f g) = {laurent_order(prod)}")
    print(f"f g normalized?  {is_normalized_laurent(prod)}   (never: the pole is double)")
    for m in range(0, 4):
        shifted = laurent_shift(prod, m)
        print(f"  q^{m} f g normalized?  {is_normalized_laurent(shifted)}")
    print("=> m = 1 is the unique monomial repair; this is the corrected product.")


def demo_group_law() -> None:
    banner("2. Closure and the commutative group law (identity q^{-1})")
    f = Normalized.from_laurent_tail([Fraction(3), Fraction(-1), Fraction(7)], PREC)
    g = Normalized.from_laurent_tail([Fraction(0), Fraction(5), Fraction(2)], PREC)
    h = Normalized.from_laurent_tail([Fraction(-2), Fraction(1, 3)], PREC)
    e = Normalized.identity(PREC)
    star_fg = f.cmul(g)
    print(f"f * g = {star_fg}")
    print(f"  is normalized (leading coefficient of the one-unit = 1): {star_fg.u[0] == 1}")
    print(f"  matches q.f.g at the Laurent level: "
          f"{laurent_of(star_fg) == laurent_mul(laurent_shift(laurent_of(f), 1), laurent_of(g), -1, PREC - 2)}")
    print(f"associativity  (f*g)*h == f*(g*h):        {f.cmul(g).cmul(h) == f.cmul(g.cmul(h))}")
    print(f"commutativity  f*g == g*f:                {f.cmul(g) == g.cmul(f)}")
    print(f"identity       q^{{-1}} * f == f:           {e.cmul(f) == f}")
    print(f"inverse        (q^{{-2}} f^{{-1}}) * f == q^{{-1}}: {f.cinv().cmul(f) == e}")


def demo_iterates() -> None:
    banner("3. Iterates: f^{*n} = q^{n-1} f^n")
    f = Normalized.from_laurent_tail([Fraction(2), Fraction(-3)], PREC)
    for n in (2, 3, 4):
        lhs = laurent_of(f.cpow_nat(n))
        rhs = laurent_of(f)
        acc = {0: Fraction(1)}
        for _ in range(n):
            acc = laurent_mul(acc, rhs, -n, PREC - 2)
        rhs_shifted = {e: c for e, c in laurent_shift(acc, n - 1).items() if e <= PREC - 2}
        lhs_cut = {e: c for e, c in lhs.items() if e <= PREC - 2}
        print(f"  n = {n}:  f^(*n) == q^{n - 1} f^n  ->  {lhs_cut == rhs_shifted}")


def demo_linear_and_quadratic() -> None:
    banner("4-5. Linear growth at the depth, quadratic growth at twice the depth")
    # a 3-deep series: c_1 = c_2 = 0, c_3 != 0
    f = Normalized([Fraction(1), Fraction(0), Fraction(0), Fraction(5),
                    Fraction(-2), Fraction(0), Fraction(11)], PREC)
    k = f.depth()
    print(f"f has depth k = {k}, depth invariant c_k = {f.c(k)}, c_2k = {f.c(2 * k)}")
    print(f"{'n':>3} | {'c_k(f^{*n})':>14} | {'n c_k':>14} | {'c_2k(f^{*n})':>16} | "
          f"{'n c_2k + C(n,2) c_k^2':>24}")
    for n in range(0, 7):
        it = f.cpow_nat(n)
        lin_pred = Fraction(n) * f.c(k)
        quad_pred = Fraction(n) * f.c(2 * k) + Fraction(comb(n, 2)) * f.c(k) ** 2
        assert it.c(k) == lin_pred and it.c(2 * k) == quad_pred
        print(f"{n:>3} | {str(it.c(k)):>14} | {str(lin_pred):>14} | "
              f"{str(it.c(2 * k)):>16} | {str(quad_pred):>24}")
    print("All predictions match exactly.")


def demo_binomial_expansion() -> None:
    banner("6-7. Exact finite binomial expansion, degrees, and finite determination")
    f = Normalized([Fraction(1), Fraction(0), Fraction(3), Fraction(-1),
                    Fraction(4), Fraction(0), Fraction(2), Fraction(9)], PREC)
    k = f.depth()
    print(f"f has depth k = {k}, c_k = {f.c(k)}")
    for m in (2, 4, 5, 6, 8, 10):
        weights = binomial_weights(f, k, m)
        ok = all(f.cpow_nat(n).c(m) == invariant_from_weights(weights, n) for n in range(0, 9))
        deg_bound = m // k
        print(f"  level m = {m:>2}: weights (omega_0..omega_{deg_bound}) = "
              f"{[str(w) for w in weights]}, "
              f"predicted degree <= {deg_bound}, expansion exact for n = 0..8: {ok}")
    j = 3
    m = j * k
    weights = binomial_weights(f, k, m)
    print(f"\n  top weight at level jk = {m} (j = {j}) is omega_j = {weights[j]}, "
          f"and c_k^j = {f.c(k) ** j}  ->  equal: {weights[j] == f.c(k) ** j}")
    print("  so the level-jk invariant has degree exactly j in the iteration count.")

    m = 9
    dbound = m // k
    print(f"\n  finite determination at level m = {m}: an orbit invariant of a {k}-deep series")
    print(f"  is a polynomial of degree <= {dbound}, hence pinned down by the "
          f"{dbound + 1} iterates n = 0..{dbound}.")
    samples = [f.cpow_nat(n).c(m) for n in range(dbound + 1)]
    # recover the binomial weights from the samples by finite differences
    recovered: List[Scalar] = []
    diffs = list(samples)
    while diffs:
        recovered.append(diffs[0])
        diffs = [diffs[i + 1] - diffs[i] for i in range(len(diffs) - 1)]
    true_weights = binomial_weights(f, k, m)
    print(f"  weights recovered from the samples n = 0..{dbound}: "
          f"{[str(w) for w in recovered]}")
    print(f"  true weights:                                  "
          f"{[str(w) for w in true_weights]}   "
          f"(equal: {recovered == true_weights})")
    extrapolated = all(f.cpow_nat(n).c(m) == invariant_from_weights(recovered, n)
                       for n in range(dbound + 1, 16))
    print(f"  extrapolation to the unseen iterates n = {dbound + 1}..15 is exact: "
          f"{extrapolated}")


def demo_roots_and_flow() -> None:
    banner("8. Unique corrected roots and the complex one-parameter subgroup")
    f = Normalized.from_laurent_tail([Fraction(0), Fraction(7), Fraction(-4), Fraction(1)], PREC)
    k = f.depth()
    print(f"f = {f}   (depth {k}, c_k = {f.c(k)})")
    for n in (2, 3, 5):
        root = cpow_rational(f, Fraction(1, n))
        back = root.cpow_nat(n)
        print(f"  the corrected {n}-th root f^(*1/{n}) recovers f when iterated {n} times: "
              f"{back == f}")
        print(f"      and its depth invariant is c_k/{n} = {root.c(k)} "
              f"(= {f.c(k)}/{n}: {root.c(k) == f.c(k) / n})")
    print("\n  exponent law f^(*r) * f^(*s) = f^(*(r+s)) on rational exponents:")
    for r, s in ((Fraction(1, 2), Fraction(1, 3)), (Fraction(-2, 5), Fraction(7, 4))):
        lhs = cpow_rational(f, r).cmul(cpow_rational(f, s))
        rhs = cpow_rational(f, r + s)
        print(f"      r = {r}, s = {s}: {lhs == rhs}")
    print("\n  linearity of the depth invariant in the exponent, c_k(f^(*r)) = r c_k(f):")
    for r in (Fraction(1, 2), Fraction(-3), Fraction(22, 7)):
        val = cpow_rational(f, r).c(k)
        print(f"      r = {str(r):>5}:  c_k(f^(*r)) = {str(val):>10}  "
              f"vs r c_k(f) = {r * f.c(k)}   ({val == r * f.c(k)})")
    print("\n  torsion-freeness spot check: no non-trivial f has f^(*n) = q^{-1}")
    e = Normalized.identity(PREC)
    print(f"      f^(*n) == q^{{-1}} for some 1 <= n <= 20 ?  "
          f"{any(f.cpow_nat(n) == e for n in range(1, 21))}")


def demo_moonshine() -> None:
    banner("9. Monstrous moonshine: iterating J = q^-1 + 196884 q + 21493760 q^2 + ...")
    coeffs: List[Fraction] = [Fraction(c) for c in
                              [0, 196884, 21493760, 864299970, 20245856256,
                               333202640600, 4252023300096, 44656994071935]]
    J = Normalized.from_laurent_tail(coeffs, PREC)
    k = J.depth()
    print(f"J is {k}-deep (its constant term vanishes); depth invariant c_2(J) = {J.c(2)}")
    print(f"level-4 invariant c_4(J) = [q^3] J = {J.c(4)}")
    print()
    print(f"{'n':>3} | {'[q^1] J^(*n)':>16} | {'196884 n':>16} | {'[q^3] J^(*n)':>20} | "
          f"{'864299970 n + C(n,2) 196884^2':>32}")
    for n in range(0, 7):
        it = J.cpow_nat(n)
        lin = Fraction(196884 * n)
        quad = Fraction(864299970) * n + Fraction(comb(n, 2)) * Fraction(196884) ** 2
        assert it.c(2) == lin and it.c(4) == quad
        print(f"{n:>3} | {str(it.c(2)):>16} | {str(lin):>16} | {str(it.c(4)):>20} | "
              f"{str(quad):>32}")
    n = 2
    value = 864299970 * n + comb(n, 2) * 196884 ** 2
    print(f"\n  the corrected square J^(*2) = q J^2 has q^3-coefficient "
          f"{value} = 2*864299970 + 196884^2")
    print(f"  and 196884^2 = {196884 ** 2} is exactly the top binomial weight "
          f"(the square of the depth invariant).")
    print("\n  higher levels: at level 2j the invariant is a polynomial of degree exactly j")
    for j in (1, 2, 3):
        m = 2 * j
        weights = binomial_weights(J, 2, m)
        print(f"      level {m:>2}: leading weight omega_{j} = {weights[j]} "
              f"= 196884^{j} ({weights[j] == Fraction(196884) ** j})")


def main() -> None:
    demo_obstruction()
    demo_group_law()
    demo_iterates()
    demo_linear_and_quadratic()
    demo_binomial_expansion()
    demo_roots_and_flow()
    demo_moonshine()
    print()
    print("All demonstrations completed; every printed identity was verified exactly.")


if __name__ == "__main__":
    main()
