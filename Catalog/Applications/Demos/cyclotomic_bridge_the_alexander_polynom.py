#!/usr/bin/env python3
"""
Cyclotomic-Alexander Bridge: Demonstrations

Numerical demonstrations of the cyclotomic bridge between Alexander polynomials
of torus knots T(2,p) and cyclotomic polynomials Φ_{2p}.
"""

import numpy as np
from typing import List


def alexander_poly_coeffs(n: int) -> List[int]:
    """Compute coefficients of Alexander polynomial of T(2,n).
    A_n(X) = sum_{i=0}^{n-1} (-1)^i X^i"""
    return [(-1)**i for i in range(n)]


def cyclotomic_poly_coeffs(n: int) -> List[int]:
    """Compute coefficients of the n-th cyclotomic polynomial Φ_n
    using the product formula."""
    # Start with X^n - 1 as numpy polynomial (highest degree first)
    poly = np.zeros(n + 1, dtype=int)
    poly[0] = 1   # X^n
    poly[-1] = -1  # -1

    # Divide by Φ_d for each proper divisor d of n
    for d in range(1, n):
        if n % d == 0:
            divisor_coeffs = cyclotomic_poly_coeffs(d)
            # Convert to numpy highest-degree-first
            div_np = np.array(divisor_coeffs[::-1], dtype=int)
            # Polynomial division
            q, r = np.polydiv(poly, div_np)
            poly = np.round(q).astype(int)

    # Convert back to lowest-degree-first
    return list(poly[::-1])


def eval_poly(coeffs: List[int], x: complex) -> complex:
    """Evaluate polynomial with given coefficients at x."""
    return sum(c * x**i for i, c in enumerate(coeffs))


def demo_negation_bridge():
    """Demonstrate Φ_{2p}(X) = Φ_p(-X) for odd primes."""
    print("=" * 60)
    print("NEGATION BRIDGE: Φ_{2p}(X) = Φ_p(-X)")
    print("=" * 60)

    primes = [3, 5, 7, 11, 13]
    for p in primes:
        phi_2p = cyclotomic_poly_coeffs(2 * p)
        phi_p = cyclotomic_poly_coeffs(p)

        # Compose with -X: coefficient of X^i gets multiplied by (-1)^i
        phi_p_neg = [(-1)**i * c for i, c in enumerate(phi_p)]

        match = phi_2p == phi_p_neg
        print(f"  p={p:2d}: Φ_{2*p:2d} = {phi_2p}")
        print(f"        Φ_{p:2d}(-X) = {phi_p_neg}")
        print(f"        Match: {match}")
        print()


def demo_alexander_cyclotomic_identity():
    """Demonstrate Alexander polynomial = cyclotomic polynomial."""
    print("=" * 60)
    print("CYCLOTOMIC BRIDGE: A_p = Φ_{2p}")
    print("=" * 60)

    primes = [3, 5, 7, 11, 13]
    for p in primes:
        alex = alexander_poly_coeffs(p)
        phi_2p = cyclotomic_poly_coeffs(2 * p)

        match = alex == phi_2p
        print(f"  T(2,{p:2d}): Alexander = {alex}")
        print(f"          Φ_{2*p:2d}       = {phi_2p}")
        print(f"          Match: {match}")
        print()


def demo_fox_normalization():
    """Demonstrate A_p(1) = 1 (Fox normalization)."""
    print("=" * 60)
    print("FOX NORMALIZATION: A_p(1) = 1")
    print("=" * 60)

    primes = [3, 5, 7, 11, 13, 17, 19, 23]
    for p in primes:
        coeffs = alexander_poly_coeffs(p)
        val_1 = sum(coeffs)
        val_neg1 = sum((-1)**i * c for i, c in enumerate(coeffs))
        print(f"  T(2,{p:2d}): A_{p}(1) = {val_1}, A_{p}(-1) = {val_neg1} (= det = {p})")


def demo_product_decomposition():
    """Demonstrate X^n + 1 = ∏_{d|n} Φ_{2d} for odd n."""
    print()
    print("=" * 60)
    print("PRODUCT DECOMPOSITION: X^n + 1 = ∏_{d|n} Φ_{2d}")
    print("=" * 60)

    def divisors(n):
        return sorted(d for d in range(1, n+1) if n % d == 0)

    def poly_mul(a, b):
        result = [0] * (len(a) + len(b) - 1)
        for i, ca in enumerate(a):
            for j, cb in enumerate(b):
                result[i+j] += ca * cb
        return result

    for n in [3, 5, 9, 15, 21]:
        # X^n + 1
        target = [1] + [0] * (n-1) + [1]

        # ∏_{d|n} Φ_{2d}
        product = [1]
        divs = divisors(n)
        for d in divs:
            phi_2d = cyclotomic_poly_coeffs(2 * d)
            product = poly_mul(product, phi_2d)

        match = product == target
        print(f"  n={n:2d}: divisors = {divs}")
        print(f"        ∏ Φ_{{2d}} = X^{n} + 1? {match}")


def demo_irreducibility():
    """Demonstrate irreducibility by showing no rational roots."""
    print()
    print("=" * 60)
    print("IRREDUCIBILITY: A_p has no rational roots")
    print("=" * 60)

    for p in [3, 5, 7, 11]:
        coeffs = alexander_poly_coeffs(p)
        roots_found = []
        for r in range(-5, 6):
            if eval_poly(coeffs, r) == 0:
                roots_found.append(r)

        print(f"  T(2,{p}): degree = {p-1}, integer roots: {roots_found if roots_found else 'none'}")
        print(f"          Irreducible over ℤ: YES (by cyclotomic theory)")


def demo_genus():
    """Demonstrate genus = (p-1)/2."""
    print()
    print("=" * 60)
    print("GENUS: g(T(2,p)) = (p-1)/2 = φ(2p)/2")
    print("=" * 60)

    from math import gcd

    def euler_totient(n):
        return sum(1 for k in range(1, n+1) if gcd(k, n) == 1)

    for p in [3, 5, 7, 11, 13, 17, 19]:
        genus = (p - 1) // 2
        tot = euler_totient(2 * p)
        print(f"  T(2,{p:2d}): genus = {genus}, φ(2·{p}) = {tot}, φ(2·{p})/2 = {tot//2}")


def demo_roots_on_unit_circle():
    """Show roots of A_p are primitive 2p-th roots of unity."""
    print()
    print("=" * 60)
    print("ROOTS: All roots are primitive 2p-th roots of unity")
    print("=" * 60)

    for p in [3, 5, 7]:
        coeffs = alexander_poly_coeffs(p)
        np_coeffs = np.array(coeffs[::-1], dtype=float)
        roots = np.roots(np_coeffs)

        print(f"  T(2,{p}): {p-1} roots")
        for i, r in enumerate(sorted(roots, key=lambda z: np.angle(z))):
            mag = abs(r)
            arg = np.angle(r) / np.pi
            print(f"    root {i+1}: |z| = {mag:.6f}, arg/π = {arg:.6f}")

        all_on_circle = all(abs(abs(r) - 1) < 1e-10 for r in roots)
        print(f"    All on unit circle: {all_on_circle}")
        print()


if __name__ == "__main__":
    demo_negation_bridge()
    demo_alexander_cyclotomic_identity()
    demo_fox_normalization()
    demo_product_decomposition()
    demo_irreducibility()
    demo_genus()
    demo_roots_on_unit_circle()
