"""
Divisor Factorization of Torus-Knot OAM Spectra -- numerical demonstrations.

A T(2,n) torus-knot Alexander polynomial is the alternating geometric sum
    A_n(X) = 1 - X + X^2 - ... + X^{n-1}.
The central result (for every odd n) is the divisor factorization
    A_n(X) = prod_{d | n, d > 1} Phi_{2d}(X),
where Phi_m is the m-th cyclotomic polynomial. This script verifies the
factorization, the master identity prod_{d|n} Phi_{2d} = X^n + 1, the layer
count tau(n) - 1, the primality criterion, the prime-power stratification, and
the channel-count identity sum_{d|n, d>1} phi(2d) = n - 1.

Polynomials are represented as coefficient lists in ascending degree order with
exact integer coefficients. The code is self-contained (standard library only).
"""

from __future__ import annotations

import cmath
from math import gcd
from typing import List


# --------------------------------------------------------------------------- #
# Exact integer-polynomial arithmetic (ascending-degree coefficient lists)    #
# --------------------------------------------------------------------------- #
def poly_trim(p: List[int]) -> List[int]:
    """Remove trailing (high-degree) zero coefficients; keep [0] for zero."""
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def poly_mul(a: List[int], b: List[int]) -> List[int]:
    """Multiply two integer polynomials."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return poly_trim(result)


def poly_divmod(num: List[int], den: List[int]) -> tuple[List[int], List[int]]:
    """Exact polynomial division; returns (quotient, remainder)."""
    num = poly_trim(num)
    den = poly_trim(den)
    quo = [0] * max(1, len(num) - len(den) + 1)
    rem = list(num)
    while len(rem) >= len(den) and rem != [0]:
        deg_diff = len(rem) - len(den)
        # den is monic in our uses; divide leading coefficients.
        coeff = rem[-1] // den[-1]
        quo[deg_diff] = coeff
        for i, dc in enumerate(den):
            rem[deg_diff + i] -= coeff * dc
        rem = poly_trim(rem)
    return poly_trim(quo), rem


def divisors(n: int) -> List[int]:
    """All positive divisors of n in increasing order."""
    return [d for d in range(1, n + 1) if n % d == 0]


def euler_phi(n: int) -> int:
    """Euler's totient phi(n)."""
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def cyclotomic(m: int) -> List[int]:
    """The m-th cyclotomic polynomial via Phi_m = (X^m - 1) / prod_{d|m, d<m} Phi_d."""
    xm_minus_1 = [-1] + [0] * (m - 1) + [1]
    denom: List[int] = [1]
    for d in divisors(m):
        if d < m:
            denom = poly_mul(denom, cyclotomic(d))
    quo, rem = poly_divmod(xm_minus_1, denom)
    assert rem == [0], f"cyclotomic division failed for m={m}"
    return quo


# --------------------------------------------------------------------------- #
# The Alexander polynomial and its divisor factorization                      #
# --------------------------------------------------------------------------- #
def alexander_torus(n: int) -> List[int]:
    """A_n = 1 - X + X^2 - ... + X^{n-1}."""
    return [(-1) ** k for k in range(n)]


def divisor_factorization(n: int) -> List[int]:
    """prod_{d | n, d > 1} Phi_{2d}."""
    prod: List[int] = [1]
    for d in divisors(n):
        if d > 1:
            prod = poly_mul(prod, cyclotomic(2 * d))
    return prod


def oam_layers(n: int) -> List[int]:
    """The layer moduli 2d for nontrivial divisors d | n."""
    return [2 * d for d in divisors(n) if d > 1]


def poly_str(p: List[int]) -> str:
    """Human-readable polynomial string."""
    terms = []
    for k, c in enumerate(p):
        if c == 0:
            continue
        mon = "1" if k == 0 else ("X" if k == 1 else f"X^{k}")
        terms.append(f"{c:+d}*{mon}" if k > 0 else f"{c:+d}")
    return " ".join(terms) if terms else "0"


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_factorization(n: int) -> None:
    a = poly_trim(alexander_torus(n))
    f = divisor_factorization(n)
    layers = oam_layers(n)
    ok = a == f
    print(f"n = {n}")
    print(f"  A_n            = {poly_str(a)}")
    print(f"  prod Phi_2d    = {poly_str(f)}")
    print(f"  layers (2d)    = {layers}   -> {len(layers)} layer(s)")
    print(f"  factorization holds: {ok}")
    print()


def demo_master_identity(n: int) -> None:
    prod: List[int] = [1]
    for d in divisors(n):
        prod = poly_mul(prod, cyclotomic(2 * d))
    xn_plus_1 = [1] + [0] * (n - 1) + [1]
    print(f"n = {n}: prod_(d|n) Phi_2d == X^{n}+1 : {prod == xn_plus_1}")


def demo_channel_count(n: int) -> None:
    deg = len(poly_trim(alexander_torus(n))) - 1
    totient_sum = sum(euler_phi(2 * d) for d in divisors(n) if d > 1)
    print(f"n = {n}: deg A_n = {deg},  sum phi(2d) = {totient_sum},  n-1 = {n - 1}")


def demo_primality(nmax: int) -> None:
    print(f"Single-layer (prime) detection for odd 3 <= n <= {nmax}:")
    for n in range(3, nmax + 1, 2):
        layers = oam_layers(n)
        detected_prime = len(layers) == 1
        print(f"  n = {n:2d}: layers = {len(layers)}  -> {'PRIME' if detected_prime else 'composite'}")


def demo_prime_power(p: int, k: int) -> None:
    a = poly_trim(alexander_torus(p ** k))
    nested: List[int] = [1]
    for i in range(1, k + 1):
        nested = poly_mul(nested, cyclotomic(2 * p ** i))
    print(f"p={p}, k={k}: A_(p^k) == prod_i Phi_(2 p^i) : {a == nested}")
    print(f"  nested layer moduli: {[2 * p ** i for i in range(1, k + 1)]}")


def demo_roots_on_circle(n: int) -> None:
    """Confirm the roots of A_n are 2n-th roots of unity of modulus 1 (except -1)."""
    a = poly_trim(alexander_torus(n))
    print(f"n = {n}: root moduli of A_n (should all be ~1):")
    # roots of X^n = -1 excluding X = -1
    roots = [cmath.exp(1j * cmath.pi * (2 * k + 1) / n) for k in range(n)]
    roots = [z for z in roots if abs(z + 1) > 1e-9]
    for z in roots:
        val = sum(c * z ** k for k, c in enumerate(a))
        print(f"    angle={cmath.phase(z):+.4f} rad  |z|={abs(z):.6f}  |A_n(z)|={abs(val):.2e}")


if __name__ == "__main__":
    print("=" * 70)
    print("DIVISOR FACTORIZATION OF T(2,n) TORUS-KNOT OAM SPECTRA")
    print("=" * 70)

    print("\n--- Divisor factorization A_n = prod_{d|n,d>1} Phi_2d ---\n")
    for n in [3, 5, 9, 15, 27]:
        demo_factorization(n)

    print("--- Master identity prod_{d|n} Phi_2d = X^n + 1 ---")
    for n in [3, 5, 9, 15, 21, 27]:
        demo_master_identity(n)

    print("\n--- Channel-count identity sum phi(2d) = n - 1 ---")
    for n in [3, 5, 9, 15, 27, 45]:
        demo_channel_count(n)

    print("\n--- Primality via single-layer criterion ---")
    demo_primality(21)

    print("\n--- Prime-power stratification ---")
    demo_prime_power(3, 3)
    demo_prime_power(5, 2)

    print("\n--- Roots of A_3 lie on the unit circle ---")
    demo_roots_on_circle(3)
