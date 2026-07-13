"""
Numerical demonstration of root-number reciprocity for Dirichlet characters
of prime modulus.

Central law (for a nontrivial Dirichlet character chi modulo a prime p):

        W(chi) * W(chi^{-1}) = 1,

where the root number is the normalized Gauss sum

        W(chi) = tau(chi) / (i^a * sqrt(p)),   a = 0 if chi even else 1,
        tau(chi) = sum_{x mod p} chi(x) * exp(2*pi*i*x/p).

The engine is the field-case Gauss-sum product  tau(chi)*tau(chi^{-1}) = chi(-1)*p.

This script is fully self-contained (standard library only).
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Dict, List, Tuple

Character = Callable[[int], complex]


# --------------------------------------------------------------------------- #
# Building Dirichlet characters modulo a prime p                              #
# --------------------------------------------------------------------------- #

def primitive_root(p: int) -> int:
    """Return a primitive root (generator of (Z/pZ)^*) for prime p."""
    if p == 2:
        return 1
    phi = p - 1
    # prime factors of phi
    factors: List[int] = []
    n = phi
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.append(n)
    for g in range(2, p):
        if all(pow(g, phi // q, p) != 1 for q in factors):
            return g
    raise ValueError(f"no primitive root found for {p}")


def make_character(p: int, k: int) -> Character:
    """
    Build the Dirichlet character chi_k modulo prime p defined by
    chi_k(g^j) = exp(2*pi*i*k*j/(p-1)), where g is a fixed primitive root,
    and chi_k(x) = 0 when p | x. k ranges over 0..p-2 (k=0 is trivial).
    """
    g = primitive_root(p)
    order = p - 1
    # discrete log table: value x -> exponent j with g^j = x (mod p)
    dlog: Dict[int, int] = {}
    cur = 1
    for j in range(order):
        dlog[cur] = j
        cur = (cur * g) % p

    def chi(x: int) -> complex:
        r = x % p
        if r == 0:
            return 0.0 + 0.0j
        j = dlog[r]
        return cmath.exp(2j * math.pi * k * j / order)

    return chi


def gauss_sum(p: int, chi: Character) -> complex:
    """tau(chi) = sum_{x=0}^{p-1} chi(x) * exp(2*pi*i*x/p)."""
    return sum(chi(x) * cmath.exp(2j * math.pi * x / p) for x in range(p))


def is_even(chi: Character) -> bool:
    """chi is even iff chi(-1) == 1."""
    return abs(chi(-1) - 1.0) < 1e-9


def inverse_character(chi: Character) -> Character:
    """Pointwise inverse character: chi^{-1}(x) = conj(chi(x)) on units, 0 else."""
    def inv(x: int) -> complex:
        v = chi(x)
        return v.conjugate() if abs(v) > 1e-12 else 0.0 + 0.0j
    return inv


def root_number(p: int, chi: Character) -> complex:
    """W(chi) = tau(chi) / (i^a * sqrt(p)), a = 0 if even else 1."""
    a = 0 if is_even(chi) else 1
    return gauss_sum(p, chi) / ((1j ** a) * math.sqrt(p))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_gauss_product(p: int) -> None:
    """Verify tau(chi)*tau(chi^{-1}) = chi(-1)*p for all nontrivial chi mod p."""
    print(f"\n=== Gauss-sum product  tau(chi)*tau(chi^-1) = chi(-1)*p   (p={p}) ===")
    for k in range(1, p - 1):
        chi = make_character(p, k)
        inv = inverse_character(chi)
        lhs = gauss_sum(p, chi) * gauss_sum(p, inv)
        rhs = chi(-1) * p
        err = abs(lhs - rhs)
        print(f"  k={k:2d}: tau*tau_inv = {lhs: .4f}   chi(-1)*p = {rhs: .4f}   "
              f"|err|={err:.2e}")


def demo_reciprocity(p: int) -> None:
    """Verify W(chi)*W(chi^{-1}) = 1 for all nontrivial chi mod p."""
    print(f"\n=== Root-number reciprocity  W(chi)*W(chi^-1) = 1   (p={p}) ===")
    max_err = 0.0
    for k in range(1, p - 1):
        chi = make_character(p, k)
        inv = inverse_character(chi)
        prod = root_number(p, chi) * root_number(p, inv)
        err = abs(prod - 1.0)
        max_err = max(max_err, err)
        parity = "even" if is_even(chi) else "odd"
        print(f"  k={k:2d} ({parity:4s}): W*W_inv = {prod: .6f}   |W|={abs(root_number(p,chi)):.4f}"
              f"   |err|={err:.2e}")
    print(f"  --> max reciprocity error over all nontrivial chi: {max_err:.2e}")


def demo_quadratic_sign(primes: List[int]) -> None:
    """
    The unique real (quadratic) character mod p is the Legendre symbol
    (k = (p-1)/2). Verify W(chi)^2 = 1 and report the sign W(chi).
    """
    print("\n=== Quadratic (real) character: W(chi)^2 = 1, and W(chi) = +1 ===")
    for p in primes:
        k = (p - 1) // 2
        chi = make_character(p, k)
        # sanity: this character is self-dual
        selfdual = all(abs(chi(x) - inverse_character(chi)(x)) < 1e-9 for x in range(1, p))
        w = root_number(p, chi)
        print(f"  p={p:3d}: self-dual={selfdual}   W={w: .6f}   W^2={ (w*w): .6f}")


def main() -> None:
    print("Root-number reciprocity for Dirichlet characters of prime modulus")
    print("=" * 68)
    demo_gauss_product(7)
    demo_reciprocity(7)
    demo_reciprocity(11)
    demo_quadratic_sign([3, 5, 7, 11, 13, 17, 19, 23])


if __name__ == "__main__":
    main()
