"""Numerical demonstrations of the Iwasawa invariant pair (mu, lambda).

This self-contained script models the two classical Iwasawa invariants of an
integer polynomial and verifies, on concrete examples, the structural results:

  * mu and lambda are additive under multiplication;
  * the pair (mu, lambda) is a monoid homomorphism into (N x N, +);
  * both invariants are monotone under divisibility;
  * lambda equals the order of vanishing at 0 of the mod-p reduction;
  * finite-product formulas turn products into sums;
  * the iterated Matsuno twist formula.

A polynomial f = a_0 + a_1 X + ... + a_n X^n is represented by the list of its
integer coefficients [a_0, a_1, ..., a_n] (low degree first).
"""

from __future__ import annotations

from math import gcd
from functools import reduce as _reduce
from typing import List, Tuple


# --------------------------------------------------------------------------- #
#  Basic polynomial arithmetic over the integers                              #
# --------------------------------------------------------------------------- #

Poly = List[int]


def trim(f: Poly) -> Poly:
    """Remove trailing (high-degree) zero coefficients; keep [0] for the zero poly."""
    g = list(f)
    while len(g) > 1 and g[-1] == 0:
        g.pop()
    return g


def is_zero(f: Poly) -> bool:
    return all(c == 0 for c in f)


def poly_mul(f: Poly, g: Poly) -> Poly:
    """Multiply two integer polynomials."""
    if is_zero(f) or is_zero(g):
        return [0]
    out = [0] * (len(f) + len(g) - 1)
    for i, a in enumerate(f):
        for j, b in enumerate(g):
            out[i + j] += a * b
    return trim(out)


def poly_prod(polys: List[Poly]) -> Poly:
    """Product of a finite family of polynomials."""
    return _reduce(poly_mul, polys, [1])


# --------------------------------------------------------------------------- #
#  Content, primitive part, and p-adic valuation                              #
# --------------------------------------------------------------------------- #

def content(f: Poly) -> int:
    """Content of f: the (nonnegative) gcd of all coefficients."""
    return _reduce(gcd, (abs(c) for c in f), 0)


def prim_part(f: Poly) -> Poly:
    """Primitive part of f: f divided by its content."""
    c = content(f)
    if c == 0:
        return [0]
    return trim([a // c for a in f])


def padic_val_int(p: int, n: int) -> int:
    """The p-adic valuation of a nonzero integer n."""
    if n == 0:
        raise ValueError("p-adic valuation of 0 is undefined here")
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


# --------------------------------------------------------------------------- #
#  The two Iwasawa invariants                                                 #
# --------------------------------------------------------------------------- #

def mu_inv(p: int, f: Poly) -> int:
    """The Iwasawa mu-invariant: the p-adic valuation of the content of f.

    Equivalently, the minimum of the p-adic valuations of the coefficients.
    """
    return padic_val_int(p, content(f))


def reduce_mod_p(p: int, f: Poly) -> Poly:
    """Reduce each coefficient of f modulo p."""
    return [c % p for c in f]


def lambda_inv(p: int, f: Poly) -> int:
    """The Iwasawa lambda-invariant: the trailing degree of the mod-p reduction
    of the primitive part of f (the first index with a nonzero reduced coefficient).
    """
    r = reduce_mod_p(p, prim_part(f))
    for i, c in enumerate(r):
        if c != 0:
            return i
    raise ValueError("reduction of a primitive polynomial should be nonzero")


def root_multiplicity_at_zero(p: int, f: Poly) -> int:
    """Order of vanishing at 0 of the mod-p reduction of the primitive part:
    the largest m with X^m dividing the reduced primitive part.
    """
    r = reduce_mod_p(p, prim_part(f))
    m = 0
    while m < len(r) and r[m] == 0:
        m += 1
    return m


# --------------------------------------------------------------------------- #
#  The Matsuno twist factor  p^k * X^(c k)                                     #
# --------------------------------------------------------------------------- #

def twist_factor(p: int, c: int, k: int) -> Poly:
    """The modelled quadratic-twist factor  p^k * X^(c*k)."""
    poly = [0] * (c * k + 1)
    poly[c * k] = p ** k
    return poly


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #

def show(title: str) -> None:
    print("\n" + "=" * 68)
    print(title)
    print("=" * 68)


def demo_additivity() -> None:
    show("1.  Additivity of mu and lambda under multiplication")
    p = 3
    f = [3, 0, 6]          # 3 + 6 X^2  = 3 * (1 + 2 X^2)
    g = [0, 9, 9]          # 9 X + 9 X^2 = 9 X * (1 + X)
    fg = poly_mul(f, g)
    print(f"p = {p}")
    print(f"f  = {f},   mu={mu_inv(p, f)}, lambda={lambda_inv(p, f)}")
    print(f"g  = {g},   mu={mu_inv(p, g)}, lambda={lambda_inv(p, g)}")
    print(f"fg = {fg},  mu={mu_inv(p, fg)}, lambda={lambda_inv(p, fg)}")
    assert mu_inv(p, fg) == mu_inv(p, f) + mu_inv(p, g)
    assert lambda_inv(p, fg) == lambda_inv(p, f) + lambda_inv(p, g)
    print("  mu(fg)  = mu(f)  + mu(g)      verified")
    print("  lam(fg) = lam(f) + lam(g)     verified")


def demo_homomorphism() -> None:
    show("2.  The pair (mu, lambda) as a monoid homomorphism")
    p = 5
    polys = [[5, 0, 10], [0, 0, 1], [25, 5]]
    prod = poly_prod(polys)
    lhs = (mu_inv(p, prod), lambda_inv(p, prod))
    rhs = (
        sum(mu_inv(p, f) for f in polys),
        sum(lambda_inv(p, f) for f in polys),
    )
    print(f"p = {p}")
    for f in polys:
        print(f"  f = {f}: (mu, lam) = ({mu_inv(p, f)}, {lambda_inv(p, f)})")
    print(f"  (mu, lam) of the product      = {lhs}")
    print(f"  sum of (mu, lam) over factors = {rhs}")
    assert lhs == rhs
    print("  homomorphism identity verified")


def demo_divisibility() -> None:
    show("3.  Monotonicity under divisibility")
    p = 2
    f = [2, 0, 2]          # 2 + 2 X^2
    h = [0, 4, 1]          # 4 X + X^2
    g = poly_mul(f, h)     # f divides g
    print(f"p = {p};  f | g")
    print(f"  f: (mu, lam) = ({mu_inv(p, f)}, {lambda_inv(p, f)})")
    print(f"  g: (mu, lam) = ({mu_inv(p, g)}, {lambda_inv(p, g)})")
    assert mu_inv(p, f) <= mu_inv(p, g)
    assert lambda_inv(p, f) <= lambda_inv(p, g)
    print("  mu(f) <= mu(g)  and  lam(f) <= lam(g)   verified")


def demo_root_multiplicity() -> None:
    show("4.  lambda equals the order of vanishing at 0")
    p = 7
    for f in [[7, 0, 0, 3], [0, 0, 14, 7, 2], [1, 7, 49]]:
        lam = lambda_inv(p, f)
        rm = root_multiplicity_at_zero(p, f)
        print(f"  f = {f}: lambda = {lam}, rootMult_0 = {rm}")
        assert lam == rm
    print("  lambda = rootMultiplicity at 0   verified")


def demo_twist() -> None:
    show("5.  The Matsuno twist factor and iterated twist")
    p = 2
    print(f"p = {p}")
    for c, k in [(2, 3), (1, 4), (3, 2)]:
        t = twist_factor(p, c, k)
        print(f"  twist(c={c}, k={k}) = p^{k} X^{c*k}: "
              f"mu = {mu_inv(p, t)} (=k), lambda = {lambda_inv(p, t)} (=c*k)")
        assert mu_inv(p, t) == k
        assert lambda_inv(p, t) == c * k

    f = [1, 0, 3]          # nonzero base characteristic element
    cs, ks = [2, 1, 3], [3, 4, 2]
    twists = [twist_factor(p, c, k) for c, k in zip(cs, ks)]
    twisted = poly_prod([f] + twists)
    lhs = lambda_inv(p, twisted)
    rhs = lambda_inv(p, f) + sum(c * mu_inv(p, t) for c, t in zip(cs, twists))
    print(f"  lambda(f * prod twists)                 = {lhs}")
    print(f"  lambda(f) + sum c_i * mu(twist_i)       = {rhs}")
    assert lhs == rhs
    print("  iterated Matsuno twist formula verified")


def main() -> None:
    demo_additivity()
    demo_homomorphism()
    demo_divisibility()
    demo_root_multiplicity()
    demo_twist()
    print("\nAll demonstrations passed.\n")


if __name__ == "__main__":
    main()
