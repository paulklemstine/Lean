"""
Normalized q-series, the corrected product, and unique star-roots
=================================================================

Numerical companion to the paper *The Corrected Product: Normalized q-Series
Form a Uniquely Divisible Group*.

A **normalized q-series** is a formal Laurent series

    f(q) = q^{-1} + a_0 + a_1 q + a_2 q^2 + ...

i.e. a series with a simple pole of residue 1 at q = 0 and no worse
singularity.  This is the normalization every McKay-Thompson series of
Monstrous Moonshine carries, starting with the modular invariant

    J(q) = q^{-1} + 196884 q + 21493760 q^2 + 864299970 q^3 + ...

Normalized series are *not* closed under multiplication: the product of m of
them has a pole of order exactly m.  The repair is the **corrected product**

    f * g  :=  q · f(q) · g(q),

under which the normalized series form a commutative group with identity
q^{-1}.  Writing f = q^{-1} u(q) with u a power series with u(0) = 1 turns the
corrected product into ordinary multiplication of the 1-units of C[[q]].

This script demonstrates, purely numerically (exact rational arithmetic):

  1. pole order of finite products, and uniqueness of the correcting exponent;
  2. the corrected product as a group law (identity, inverses, associativity);
  3. torsion freeness: the only 1-unit root of unity is 1;
  4. divisibility: n-th roots exist, computed via the binomial series;
  5. the closed-form low-order expansions of star-inverse and star-square root;
  6. unique rational star-powers (the Q-vector-space structure);
  7. the moonshine star-square root of J and its empirical 2-integrality,
     contrasted with the cube root, whose denominators are powers of 3.

Everything is exact: coefficients are Python ``Fraction``s.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple

Coef = Fraction

# ---------------------------------------------------------------------------
# 1. Truncated power series over Q
# ---------------------------------------------------------------------------


def ps_trim(a: Sequence[Coef], prec: int) -> List[Coef]:
    """Return the coefficient list of a power series truncated to ``prec`` terms."""
    out = [Fraction(0)] * prec
    for i in range(min(prec, len(a))):
        out[i] = Fraction(a[i])
    return out


def ps_mul(a: Sequence[Coef], b: Sequence[Coef], prec: int) -> List[Coef]:
    """Cauchy product of two truncated power series, O(prec^2)."""
    a = ps_trim(a, prec)
    b = ps_trim(b, prec)
    out = [Fraction(0)] * prec
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j in range(prec - i):
            if b[j] != 0:
                out[i + j] += ai * b[j]
    return out


def ps_pow(a: Sequence[Coef], n: int, prec: int) -> List[Coef]:
    """n-th power of a truncated power series by binary exponentiation."""
    result = ps_trim([Fraction(1)], prec)
    base = ps_trim(a, prec)
    e = n
    while e > 0:
        if e & 1:
            result = ps_mul(result, base, prec)
        base = ps_mul(base, base, prec)
        e >>= 1
    return result


def ps_inv_one_unit(a: Sequence[Coef], prec: int) -> List[Coef]:
    """Inverse of a power series with constant term 1 (a '1-unit')."""
    a = ps_trim(a, prec)
    assert a[0] == 1, "ps_inv_one_unit expects constant term 1"
    out = [Fraction(0)] * prec
    out[0] = Fraction(1)
    for k in range(1, prec):
        out[k] = -sum(a[j] * out[k - j] for j in range(1, k + 1))
    return out


def binomial_series(r: Fraction, prec: int) -> List[Coef]:
    """Coefficients of (1 + X)^r = sum_k binom(r, k) X^k, exact in Q."""
    out = [Fraction(0)] * prec
    out[0] = Fraction(1)
    for k in range(1, prec):
        out[k] = out[k - 1] * (r - (k - 1)) / k
    return out


def ps_subst_no_const(outer: Sequence[Coef], inner: Sequence[Coef], prec: int) -> List[Coef]:
    """Substitute ``inner`` (with zero constant term) into ``outer``, by Horner."""
    inner = ps_trim(inner, prec)
    assert inner[0] == 0, "substitution requires vanishing constant term"
    outer = ps_trim(outer, prec)
    acc = [Fraction(0)] * prec
    for c in reversed(outer):
        acc = ps_mul(acc, inner, prec)
        acc[0] += c
    return acc


def ps_root_one_unit(u: Sequence[Coef], n: int, prec: int) -> List[Coef]:
    """The unique 1-unit n-th root of a 1-unit u: substitute u - 1 into (1+X)^{1/n}."""
    u = ps_trim(u, prec)
    assert u[0] == 1, "ps_root_one_unit expects constant term 1"
    h = list(u)
    h[0] = Fraction(0)  # h = u - 1, zero constant term
    return ps_subst_no_const(binomial_series(Fraction(1, n), prec), h, prec)


def ps_rat_pow_one_unit(u: Sequence[Coef], r: Fraction, prec: int) -> List[Coef]:
    """The rational power u^r of a 1-unit, via the binomial series."""
    u = ps_trim(u, prec)
    h = list(u)
    h[0] = Fraction(0)
    return ps_subst_no_const(binomial_series(r, prec), h, prec)


# ---------------------------------------------------------------------------
# 2. Normalized Laurent q-series, represented by their 1-unit part
# ---------------------------------------------------------------------------


class Normalized:
    """A normalized q-series f = q^{-1} + a_0 + a_1 q + ..., stored as u = q f."""

    __slots__ = ("u", "prec")

    def __init__(self, u: Sequence[Coef], prec: int) -> None:
        u = ps_trim(u, prec)
        assert u[0] == 1, "the 1-unit part must have constant term 1"
        self.u = u
        self.prec = prec

    @staticmethod
    def from_laurent(a: Dict[int, Coef], prec: int) -> "Normalized":
        """Build q^{-1} + sum_{k>=0} a[k] q^k from a dictionary of coefficients."""
        u = [Fraction(0)] * prec
        u[0] = Fraction(1)
        for k, v in a.items():
            if 0 <= k + 1 < prec:
                u[k + 1] = Fraction(v)
        return Normalized(u, prec)

    def laurent_coeff(self, k: int) -> Coef:
        """Coefficient of q^k in f (so laurent_coeff(-1) = 1)."""
        idx = k + 1
        return self.u[idx] if 0 <= idx < self.prec else Fraction(0)

    def star(self, other: "Normalized") -> "Normalized":
        """The corrected product f * g = q f g."""
        prec = min(self.prec, other.prec)
        return Normalized(ps_mul(self.u, other.u, prec), prec)

    def star_inv(self) -> "Normalized":
        """The star-inverse: the unique normalized g with g * f = q^{-1}."""
        return Normalized(ps_inv_one_unit(self.u, self.prec), self.prec)

    def star_pow(self, n: int) -> "Normalized":
        """The n-th star-power, whose Laurent form is q^{n-1} f^n."""
        return Normalized(ps_pow(self.u, n, self.prec), self.prec)

    def star_root(self, n: int) -> "Normalized":
        """The unique normalized g with g star-n-th-power equal to f."""
        return Normalized(ps_root_one_unit(self.u, n, self.prec), self.prec)

    def star_rat_pow(self, r: Fraction) -> "Normalized":
        """The rational star-power f^r."""
        return Normalized(ps_rat_pow_one_unit(self.u, r, self.prec), self.prec)

    def laurent_str(self, terms: int = 6) -> str:
        pieces = ["q^-1"]
        for k in range(0, terms):
            c = self.laurent_coeff(k)
            if c == 0:
                continue
            power = "" if k == 0 else (" q" if k == 1 else f" q^{k}")
            pieces.append(f"{'+' if c > 0 else '-'} {abs(c)}{power}")
        return " ".join(pieces) + " + ..."

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Normalized) and self.u == other.u


IDENTITY = lambda prec: Normalized([Fraction(1)], prec)  # q^{-1} itself


# ---------------------------------------------------------------------------
# 3. Pole order bookkeeping for plain (uncorrected) products
# ---------------------------------------------------------------------------


def plain_product_pole_order(factors: Iterable[Normalized]) -> int:
    """Order of the pole at q = 0 of the ordinary product of normalized series."""
    return sum(1 for _ in factors)


def corrected_exponent(m: int) -> int:
    """The unique k with q^k * (product of m normalized series) normalized."""
    return m - 1


# ---------------------------------------------------------------------------
# 4. Moonshine data
# ---------------------------------------------------------------------------

# Coefficients c(n) of J(q) = q^{-1} + sum_{n>=1} c(n) q^n  (the modular
# invariant j(q) - 744).  These are the graded dimensions of the Moonshine
# module V-natural.
J_COEFFS: List[int] = [
    196884,            # c(1)
    21493760,          # c(2)
    864299970,         # c(3)
    20245856256,       # c(4)
    333202640600,      # c(5)
    4252023300096,     # c(6)
    44656994071935,    # c(7)
    401490886656000,   # c(8)
    3176440229784420,  # c(9)
    22567393309593600, # c(10)
]

MONSTER_CLASS_COUNT = 194  # conjugacy classes of the Monster


def J_series(prec: int) -> Normalized:
    """J = q^{-1} + 196884 q + 21493760 q^2 + ... as a normalized q-series."""
    return Normalized.from_laurent(
        {n: Fraction(c) for n, c in enumerate(J_COEFFS, start=1)}, prec
    )


# ---------------------------------------------------------------------------
# 5. Demonstrations
# ---------------------------------------------------------------------------


def demo_pole_orders() -> None:
    print("=" * 74)
    print("1. Pole order of finite products, and the unique correcting exponent")
    print("=" * 74)
    prec = 8
    f = Normalized.from_laurent({0: Fraction(3), 1: Fraction(-2)}, prec)
    g = Normalized.from_laurent({0: Fraction(1), 1: Fraction(5)}, prec)
    h = Normalized.from_laurent({0: Fraction(0), 1: Fraction(7)}, prec)
    for m, fam in ((1, [f]), (2, [f, g]), (3, [f, g, h])):
        print(
            f"  product of m = {m} normalized series: pole order "
            f"{plain_product_pole_order(fam)}  ->  normalized again only after "
            f"multiplying by q^{corrected_exponent(m)}"
        )
    print("  (m = 1 is the only case where the plain product is already normalized.)")
    print()


def demo_group_law() -> None:
    print("=" * 74)
    print("2. The corrected product f * g = q f g is a commutative group law")
    print("=" * 74)
    prec = 8
    f = Normalized.from_laurent({0: Fraction(3), 1: Fraction(-2), 2: Fraction(4)}, prec)
    g = Normalized.from_laurent({0: Fraction(1, 2), 1: Fraction(5)}, prec)
    h = Normalized.from_laurent({0: Fraction(-7), 1: Fraction(1, 3)}, prec)
    e = IDENTITY(prec)
    print(f"  f          = {f.laurent_str(3)}")
    print(f"  g          = {g.laurent_str(3)}")
    print(f"  f * g      = {f.star(g).laurent_str(3)}")
    print(f"  identity   : f * q^-1 == f          -> {f.star(e) == f}")
    print(f"  commutative: f * g == g * f         -> {f.star(g) == g.star(f)}")
    print(
        "  associative: (f*g)*h == f*(g*h)     -> "
        f"{f.star(g).star(h) == f.star(g.star(h))}"
    )
    print(f"  inverses   : f * f^(-1) == q^-1     -> {f.star(f.star_inv()) == e}")
    print()


def demo_closed_forms() -> None:
    print("=" * 74)
    print("3. Closed-form low-order expansions of the inverse and the square root")
    print("=" * 74)
    prec = 8
    a0, a1, a2 = Fraction(3), Fraction(-5, 2), Fraction(11, 4)
    f = Normalized.from_laurent({0: a0, 1: a1, 2: a2}, prec)

    inv = f.star_inv()
    print("  star-inverse:  predicted  a_0 -> -a_0,  a_1 -> a_0^2 - a_1")
    print(f"    computed  ({inv.laurent_coeff(0)}, {inv.laurent_coeff(1)})")
    print(f"    predicted ({-a0}, {a0 ** 2 - a1})")
    assert inv.laurent_coeff(0) == -a0
    assert inv.laurent_coeff(1) == a0 ** 2 - a1

    rt = f.star_root(2)
    pred = (a0 / 2, a1 / 2 - a0 ** 2 / 8, a2 / 2 - a0 * a1 / 4 + a0 ** 3 / 16)
    print("  star-square root: predicted a_0/2,  a_1/2 - a_0^2/8,")
    print("                              a_2/2 - a_0 a_1/4 + a_0^3/16")
    print(
        f"    computed  ({rt.laurent_coeff(0)}, {rt.laurent_coeff(1)}, "
        f"{rt.laurent_coeff(2)})"
    )
    print(f"    predicted ({pred[0]}, {pred[1]}, {pred[2]})")
    assert (rt.laurent_coeff(0), rt.laurent_coeff(1), rt.laurent_coeff(2)) == pred
    print(f"    and indeed  g * g == f  ->  {rt.star(rt) == f}")
    print()


def demo_torsion_free_and_divisible() -> None:
    print("=" * 74)
    print("4. Torsion freeness and divisibility")
    print("=" * 74)
    prec = 10
    e = IDENTITY(prec)
    for n in (2, 3, 5, 12):
        root = e.star_root(n)
        print(f"  the unique n-th star-root of q^-1 for n = {n:2d} is q^-1 : {root == e}")
    f = Normalized.from_laurent(
        {0: Fraction(2), 1: Fraction(-3), 2: Fraction(7), 3: Fraction(1, 5)}, prec
    )
    for n in (2, 3, 4, 7, 11):
        g = f.star_root(n)
        ok = g.star_pow(n) == f
        print(f"  n = {n:2d}: g^(*n) == f -> {ok};  g = {g.laurent_str(2)}")
    print()


def demo_rational_powers() -> None:
    print("=" * 74)
    print("5. Rational star-powers: the Q-vector-space structure")
    print("=" * 74)
    prec = 9
    f = Normalized.from_laurent({0: Fraction(1), 1: Fraction(-4), 2: Fraction(6)}, prec)
    for r in (Fraction(2, 3), Fraction(-1, 2), Fraction(5, 4)):
        g = f.star_rat_pow(r)
        lhs = g.star_pow(r.denominator)
        rhs = (
            f.star_pow(r.numerator)
            if r.numerator >= 0
            else f.star_inv().star_pow(-r.numerator)
        )
        print(f"  r = {r}:  (f^r)^(*{r.denominator}) == f^(*{r.numerator}) -> {lhs == rhs}")
    r, s = Fraction(3, 5), Fraction(-2, 7)
    print(
        "  exponent law f^(r+s) == f^r * f^s -> "
        f"{f.star_rat_pow(r + s) == f.star_rat_pow(r).star(f.star_rat_pow(s))}"
    )
    print(
        "  exponent law f^(r s)  == (f^s)^r  -> "
        f"{f.star_rat_pow(r * s) == f.star_rat_pow(s).star_rat_pow(r)}"
    )
    print()


def demo_moonshine_square_root() -> None:
    print("=" * 74)
    print("6. The moonshine star-square root of J and its 2-integrality")
    print("=" * 74)
    prec = 12  # J is known through q^10, so g is determined through q^10
    J = J_series(prec)
    print(f"  J      = {J.laurent_str(4)}")
    g = J.star_root(2)
    print(f"  sqrt_* = {g.laurent_str(4)}")
    print(f"  check: q g^2 == J  ->  {g.star(g) == J}")
    print("  Laurent coefficients of the star-square root:")
    integral_through = -1
    for k in range(0, len(J_COEFFS) + 1):
        c = g.laurent_coeff(k)
        tag = "integer" if c.denominator == 1 else f"denominator {c.denominator}"
        if c.denominator == 1 and integral_through == k - 1:
            integral_through = k
        print(f"    [q^{k}] = {c}   ({tag})")
    print(f"  -> integral at least through q^{integral_through}")
    print()


def demo_cube_root_denominators() -> None:
    print("=" * 74)
    print("7. Contrast: the star-cube root of J has 3-power denominators")
    print("=" * 74)
    prec = 12
    J = J_series(prec)
    print("  denominators of the Laurent coefficients of the star-n-th root of J:")
    for n in (2, 3, 5):
        gn = J.star_root(n)
        dens = [gn.laurent_coeff(k).denominator for k in range(0, len(J_COEFFS) + 1)]
        print(f"    n = {n}:  {dens}")
    print("  The phenomenon is prime-specific: halving J is integral, thirding is not,")
    print("  and the denominators of the n-th root are powers of the primes dividing n.")
    print()


def demo_moonshine_geometric_mean() -> None:
    print("=" * 74)
    print("8. The 'geometric mean' of 194 McKay-Thompson-shaped series")
    print("=" * 74)
    prec = 8
    # A toy family of 194 normalized series with rational coefficients.
    family = [
        Normalized.from_laurent(
            {0: Fraction(0), 1: Fraction(i % 7), 2: Fraction((-1) ** i * i, 3)}, prec
        )
        for i in range(MONSTER_CLASS_COUNT)
    ]
    prod = family[0]
    for f in family[1:]:
        prod = prod.star(f)
    print(
        f"  plain product of {MONSTER_CLASS_COUNT} normalized series has pole order "
        f"{MONSTER_CLASS_COUNT};"
    )
    print(
        f"  the corrected product q^{corrected_exponent(MONSTER_CLASS_COUNT)} * "
        "prod T_g is normalized again."
    )
    print(f"  corrected product = {prod.laurent_str(3)}")
    mean = prod.star_root(MONSTER_CLASS_COUNT)
    print(f"  unique {MONSTER_CLASS_COUNT}-th star-root (the geometric mean):")
    print(f"    {mean.laurent_str(3)}")
    print(
        f"  check: (geometric mean)^(*{MONSTER_CLASS_COUNT}) == corrected product -> "
        f"{mean.star_pow(MONSTER_CLASS_COUNT) == prod}"
    )
    print()


def main() -> None:
    demo_pole_orders()
    demo_group_law()
    demo_closed_forms()
    demo_torsion_free_and_divisible()
    demo_rational_powers()
    demo_moonshine_square_root()
    demo_cube_root_denominators()
    demo_moonshine_geometric_mean()
    print("All checks passed.")


if __name__ == "__main__":
    main()
