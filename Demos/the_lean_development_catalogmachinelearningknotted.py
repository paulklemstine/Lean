"""
demo.py -- Numerical demonstrations of the Cyclotomic Bridge for
Torus-Knot Orbital-Angular-Momentum (OAM) Spectra.

For an odd prime p, the T(2,p) torus-knot Alexander polynomial is the
alternating geometric sum

    A_p(X) = 1 - X + X^2 - ... + X^{p-1},

and this demo verifies, purely numerically and symbolically-by-hand:

  * the master identity   (X+1) * A_n(X) = X^n + 1;
  * the cyclotomic identification  A_p = Phi_{2p}  (coefficient equality);
  * that the complex roots of A_p are exactly the primitive 2p-th roots
    of unity (unit modulus, correct arguments, no spurious roots);
  * the channel count  deg A_p = phi(2p) = phi(p) = p - 1;
  * the determinant  A_n(-1) = n  and the 3-colorability criterion;
  * the crystalline/metallic contrast with the figure-eight knot,
    whose Alexander roots are the golden-ratio powers phi^{+/-2}.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple


# --------------------------------------------------------------------------
# Polynomial utilities (coefficients low-degree-first)
# --------------------------------------------------------------------------

def alexander_torus(n: int) -> List[int]:
    """Coefficients of A_n(X) = sum_{i=0}^{n-1} (-1)^i X^i (low degree first)."""
    return [(-1) ** i for i in range(n)]


def poly_mul(a: List[int], b: List[int]) -> List[int]:
    """Multiply two integer polynomials (coefficients low-degree-first)."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return result


def poly_eval(coeffs: List[int], x: complex) -> complex:
    """Evaluate a polynomial at x by Horner's method."""
    acc: complex = 0
    for c in reversed(coeffs):
        acc = acc * x + c
    return acc


def totient(n: int) -> int:
    """Euler's totient function."""
    result = n
    m = n
    p = 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


def cyclotomic(m: int) -> List[int]:
    """Coefficients of the m-th cyclotomic polynomial via the recursion
    X^m - 1 = prod_{d | m} Phi_d(X), computed by exact polynomial division."""
    # Start with X^m - 1
    numerator = [-1] + [0] * (m - 1) + [1]
    for d in range(1, m):
        if m % d == 0:
            numerator = poly_divide_exact(numerator, cyclotomic(d))
    return numerator


def poly_divide_exact(num: List[int], den: List[int]) -> List[int]:
    """Exact division of integer polynomials num / den (assumes it divides)."""
    num = num[:]
    quotient = [0] * (len(num) - len(den) + 1)
    for i in range(len(quotient) - 1, -1, -1):
        coeff = num[i + len(den) - 1] // den[-1]
        quotient[i] = coeff
        for j, dj in enumerate(den):
            num[i + j] -= coeff * dj
    return quotient


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_master_identity(n: int) -> None:
    """(X+1) * A_n = X^n + 1."""
    lhs = poly_mul(alexander_torus(n), [1, 1])  # multiply by (X + 1)
    rhs = [1] + [0] * (n - 1) + [1]             # X^n + 1
    print(f"  (X+1)*A_{n}      = {lhs}")
    print(f"  X^{n}+1          = {rhs}")
    print(f"  identity holds  : {lhs == rhs}")


def demo_cyclotomic_identification(p: int) -> None:
    """A_p == Phi_{2p} coefficient-wise."""
    a = alexander_torus(p)
    phi = cyclotomic(2 * p)
    print(f"  A_{p}            = {a}")
    print(f"  Phi_{2 * p}          = {phi}")
    print(f"  A_p == Phi_2p   : {a == phi}")


def primitive_roots(m: int) -> List[complex]:
    """The primitive m-th roots of unity."""
    return [cmath.exp(2j * math.pi * k / m) for k in range(m) if math.gcd(k, m) == 1]


def demo_root_set(p: int) -> None:
    """Roots of A_p are exactly the primitive 2p-th roots of unity."""
    coeffs = alexander_torus(p)
    prim = primitive_roots(2 * p)
    # Confirm each primitive 2p-th root is a root of A_p
    max_resid = max(abs(poly_eval(coeffs, z)) for z in prim)
    moduli = [abs(z) for z in prim]
    print(f"  # primitive 2p-th roots        : {len(prim)}  (= p-1 = {p - 1})")
    print(f"  max |A_p(zeta)| over these     : {max_resid:.2e}")
    print(f"  all on unit circle (|z|=1)     : {all(abs(m - 1) < 1e-9 for m in moduli)}")


def demo_channel_count(p: int) -> None:
    """deg A_p = phi(2p) = phi(p) = p-1."""
    deg = len(alexander_torus(p)) - 1
    print(f"  deg A_{p} = {deg},  phi(2p) = {totient(2 * p)},  "
          f"phi(p) = {totient(p)},  p-1 = {p - 1}")


def demo_determinant(n: int) -> None:
    """A_n(-1) = n; 3 | det iff n=3 (for prime n)."""
    det = poly_eval(alexander_torus(n), -1).real
    print(f"  A_{n}(-1) = {det:.0f}  (knot determinant = {abs(det):.0f});  "
          f"3 | det : {int(det) % 3 == 0}")


def demo_figure_eight() -> None:
    """Figure-eight: Delta = X^2 - 3X + 1, roots phi^{+/-2} off the circle."""
    coeffs = [1, -3, 1]  # 1 - 3X + X^2
    b = 3
    disc = b * b - 4
    r1 = (b + math.sqrt(disc)) / 2
    r2 = (b - math.sqrt(disc)) / 2
    phi = (1 + math.sqrt(5)) / 2
    print(f"  Delta_4_1(X) = X^2 - 3X + 1,  discriminant b^2-4 = {disc} (>0)")
    print(f"  roots        = {r1:.6f}, {r2:.6f}")
    print(f"  phi^2, phi^-2 = {phi ** 2:.6f}, {phi ** -2:.6f}")
    print(f"  roots off unit circle          : {abs(r1) > 1 + 1e-9}")
    print(f"  determinant |Delta(-1)|        : {abs(poly_eval(coeffs, -1).real):.0f}")


def main() -> None:
    print("=" * 70)
    print("Cyclotomic Bridge for Torus-Knot OAM Spectra -- numerical demo")
    print("=" * 70)

    for p in (3, 5, 7, 11):
        label = {3: "trefoil", 5: "cinquefoil"}.get(p, f"T(2,{p})")
        print(f"\n### p = {p}  ({label})")
        print("- master identity:")
        demo_master_identity(p)
        print("- cyclotomic identification:")
        demo_cyclotomic_identification(p)
        print("- exact root set:")
        demo_root_set(p)
        print("- channel count:")
        demo_channel_count(p)
        print("- determinant / colorability:")
        demo_determinant(p)

    print("\n### figure-eight knot (4_1) -- the metallic exception")
    demo_figure_eight()

    print("\nDone.")


if __name__ == "__main__":
    main()
