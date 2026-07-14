"""
demo.py — Numerical demonstration of the polynomial realization of the
mu-corrected sharp/flat lambda-difference (extended Matsuno formula).

This self-contained script implements, from scratch:

  * the arithmetic model:
        n_ell        = v_2((ell^2 - 1) / 8)           (2-adic depth)
        localTerm    = classical local contribution of a prime
        weightSum    = sum of 2^{n_ell} over primes dividing D
        lambdaDiffMu = lambdaDiff(D) + mu * weightSum(D)

  * genuine polynomial Iwasawa invariants on Z[X]:
        muInv(f)     = v_p(content(f))
        lambdaInv(f) = trailing degree of (primPart(f) mod p)

  * the characteristic element charElt(D, mu) and the two bridge theorems:
        muInv(charElt(D, mu))     == mu
        lambdaInv(charElt(D, mu)) == lambdaDiffMu(D, mu)

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import Callable, Dict, List


# ---------------------------------------------------------------------------
# p-adic valuations
# ---------------------------------------------------------------------------

def padic_val(p: int, n: int) -> int:
    """The p-adic valuation v_p(n) of a nonzero integer n (v_p(0) := 0)."""
    if n == 0:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


# ---------------------------------------------------------------------------
# The arithmetic model (extended Matsuno formula)
# ---------------------------------------------------------------------------

def prime_factors(n: int) -> List[int]:
    """Sorted list of distinct prime divisors of n (n >= 1)."""
    factors: List[int] = []
    d = 2
    m = n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


def depth(ell: int) -> int:
    """The 2-adic depth n_ell = v_2((ell^2 - 1) / 8) of an odd prime ell."""
    return padic_val(2, (ell * ell - 1) // 8)


def depth_law_holds(ell: int) -> bool:
    """Check 8 * 2^{n_ell} == 2^{v_2(ell-1) + v_2(ell+1)}."""
    lhs = 8 * 2 ** depth(ell)
    rhs = 2 ** (padic_val(2, ell - 1) + padic_val(2, ell + 1))
    return lhs == rhs


def local_term(ell: int, NE: int, order: Callable[[int], int]) -> int:
    """Classical local contribution of a prime ell to the lambda-difference."""
    if NE % ell == 0:
        return 2 ** depth(ell)
    if order(ell) % 2 == 0:
        return 2 ** (depth(ell) + 1)
    return 0


def lambda_diff(D: int, NE: int, order: Callable[[int], int]) -> int:
    """Classical (mu = 0) Matsuno lambda-difference of the twist E^D."""
    return sum(local_term(ell, NE, order) for ell in prime_factors(D))


def weight_sum(D: int) -> int:
    """Total local mu-weight W(D) = sum_{ell | D} 2^{n_ell}."""
    return sum(2 ** depth(ell) for ell in prime_factors(D))


def lambda_diff_mu(D: int, NE: int, mu: int, order: Callable[[int], int]) -> int:
    """The mu-corrected Matsuno lambda-difference Lambda(D, mu)."""
    return lambda_diff(D, NE, order) + mu * weight_sum(D)


# ---------------------------------------------------------------------------
# Genuine polynomial Iwasawa invariants on Z[X]
# ---------------------------------------------------------------------------

class IntPoly:
    """A sparse integer polynomial: {exponent: coefficient}, no zero coeffs."""

    def __init__(self, coeffs: Dict[int, int]) -> None:
        self.coeffs: Dict[int, int] = {e: c for e, c in coeffs.items() if c != 0}

    @staticmethod
    def one() -> "IntPoly":
        return IntPoly({0: 1})

    @staticmethod
    def monomial(exp: int, coeff: int = 1) -> "IntPoly":
        return IntPoly({exp: coeff})

    def is_zero(self) -> bool:
        return len(self.coeffs) == 0

    def __mul__(self, other: "IntPoly") -> "IntPoly":
        out: Dict[int, int] = {}
        for e1, c1 in self.coeffs.items():
            for e2, c2 in other.coeffs.items():
                out[e1 + e2] = out.get(e1 + e2, 0) + c1 * c2
        return IntPoly(out)

    def __pow__(self, n: int) -> "IntPoly":
        result = IntPoly.one()
        for _ in range(n):
            result = result * self
        return result

    def content(self) -> int:
        """The content: gcd of all coefficients (>= 0); content(0) := 0."""
        if self.is_zero():
            return 0
        return reduce(gcd, (abs(c) for c in self.coeffs.values()))

    def prim_part(self) -> "IntPoly":
        """The primitive part f / content(f)."""
        c = self.content()
        if c == 0:
            return IntPoly({})
        return IntPoly({e: coeff // c for e, coeff in self.coeffs.items()})

    def reduce_mod(self, p: int) -> Dict[int, int]:
        """Coefficients reduced modulo p, dropping the ones that vanish."""
        return {e: c % p for e, c in self.coeffs.items() if c % p != 0}


def mu_inv(p: int, f: IntPoly) -> int:
    """Polynomial mu-invariant: v_p(content(f))."""
    return padic_val(p, f.content())


def lambda_inv(p: int, f: IntPoly) -> int:
    """Polynomial lambda-invariant: trailing degree of (primPart(f) mod p)."""
    reduced = f.prim_part().reduce_mod(p)
    return min(reduced.keys())


# ---------------------------------------------------------------------------
# The bridge: the characteristic element
# ---------------------------------------------------------------------------

def char_elt(p: int, D: int, NE: int, mu: int,
             order: Callable[[int], int]) -> IntPoly:
    """charElt(D, mu) = (prod_{ell|D} X^{localTerm(ell)}) * (p * X^{W(D)})^mu."""
    result = IntPoly.one()
    for ell in prime_factors(D):
        result = result * IntPoly.monomial(local_term(ell, NE, order))
    mu_factor = IntPoly.monomial(weight_sum(D), p) ** mu
    return result * mu_factor


# ---------------------------------------------------------------------------
# Demonstration
# ---------------------------------------------------------------------------

def main() -> None:
    p = 2
    NE = 1
    order = lambda _ell: 1  # constantly odd -> classical local terms vanish

    print("=" * 70)
    print("2-adic depths and the depth law  8 * 2^{n_ell} = 2^{v2(l-1)+v2(l+1)}")
    print("=" * 70)
    for ell in [3, 5, 7, 11, 13, 17, 31]:
        print(f"  ell = {ell:3d}:  n_ell = {depth(ell)},  "
              f"2^n = {2**depth(ell):3d},  depth law holds: {depth_law_holds(ell)}")

    print()
    print("=" * 70)
    print("Bridge check:  muInv(charElt) == mu   and   lambdaInv == lambdaDiffMu")
    print("=" * 70)
    cases = [(3, 1), (5, 3), (7, 1), (15, 2), (105, 4), (231, 2)]
    for D, mu in cases:
        f = char_elt(p, D, NE, mu, order)
        mi = mu_inv(p, f)
        li = lambda_inv(p, f)
        ldm = lambda_diff_mu(D, NE, mu, order)
        ld = lambda_diff(D, NE, order)
        W = weight_sum(D)
        recovered = (li - ld) // W  # mu-recovery / inversion
        ok = (mi == mu) and (li == ldm) and (recovered == mu)
        print(f"  D={D:4d}, mu={mu}:  muInv={mi}  lambdaInv={li}  "
              f"lambdaDiffMu={ldm}  W(D)={W}  recovered mu={recovered}  "
              f"[{'OK' if ok else 'FAIL'}]")

    print()
    print("=" * 70)
    print("Non-vanishing & strict monotonicity of lambda in mu  (D = 15)")
    print("=" * 70)
    D = 15
    prev = -1
    for mu in range(0, 6):
        li = lambda_inv(p, char_elt(p, D, NE, mu, order))
        arrow = "  >" if li > prev else "  ="
        print(f"  mu={mu}:  lambdaInv(charElt(15, mu)) = {li}{arrow}")
        prev = li

    print()
    print("=" * 70)
    print("Coprime additivity:  lambdaInv(charElt(a*b)) = sum of the two parts")
    print("=" * 70)
    for a, b, mu in [(3, 5, 2), (7, 11, 1), (5, 21, 3)]:
        lab = lambda_inv(p, char_elt(p, a * b, NE, mu, order))
        la = lambda_inv(p, char_elt(p, a, NE, mu, order))
        lb = lambda_inv(p, char_elt(p, b, NE, mu, order))
        print(f"  a={a}, b={b}, mu={mu}:  L(ab)={lab}  L(a)+L(b)={la}+{lb}={la+lb}"
              f"  [{'OK' if lab == la + lb else 'FAIL'}]")


if __name__ == "__main__":
    main()
