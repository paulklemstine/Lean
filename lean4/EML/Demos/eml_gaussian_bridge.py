#!/usr/bin/env python3
"""
EML–Gaussian Integer Bridge

Explores Research Direction 13: The connection between Pythagorean triples,
Gaussian integers, and EML encoding.

Key insight: Pythagorean triples correspond to norms of Gaussian integers,
and the Berggren tree corresponds to specific Gaussian integer multiplications.
The EML operator connects this to exponential/logarithmic structure.
"""

import math
import cmath
from typing import List, Tuple, Optional

# =============================================================================
# Gaussian Integers
# =============================================================================

class GaussianInt:
    """A Gaussian integer a + bi."""
    def __init__(self, a: int, b: int):
        self.a = a
        self.b = b

    def __repr__(self):
        if self.b == 0:
            return f"{self.a}"
        if self.a == 0:
            return f"{self.b}i"
        sign = "+" if self.b > 0 else "-"
        return f"{self.a} {sign} {abs(self.b)}i"

    def norm_sq(self) -> int:
        """Norm-squared: |a + bi|² = a² + b²."""
        return self.a**2 + self.b**2

    def __mul__(self, other: 'GaussianInt') -> 'GaussianInt':
        """Gaussian integer multiplication: (a+bi)(c+di) = (ac-bd) + (ad+bc)i."""
        return GaussianInt(
            self.a * other.a - self.b * other.b,
            self.a * other.b + self.b * other.a
        )

    def conjugate(self) -> 'GaussianInt':
        return GaussianInt(self.a, -self.b)

    def to_complex(self) -> complex:
        return complex(self.a, self.b)

# =============================================================================
# Pythagorean-Gaussian Connection
# =============================================================================

def gaussian_to_triple(z: GaussianInt) -> Tuple[int, int, int]:
    """Convert Gaussian integer to Pythagorean-like triple.
    If z = m + ni, then (m²-n², 2mn, m²+n²) is a Pythagorean triple."""
    m, n = z.a, z.b
    return (abs(m**2 - n**2), abs(2*m*n), m**2 + n**2)

def triple_product_via_gaussian(t1: Tuple[int, int, int],
                                 t2: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Multiply two Pythagorean triples via Gaussian integers.
    Uses Brahmagupta-Fibonacci: (a₁²+b₁²)(a₂²+b₂²) = (a₁a₂-b₁b₂)² + (a₁b₂+a₂b₁)²."""
    a1, b1, c1 = t1
    a2, b2, c2 = t2
    return (abs(a1*a2 - b1*b2), abs(a1*b2 + a2*b1), c1*c2)

# =============================================================================
# EML on Complex Numbers
# =============================================================================

def eml_complex(x: complex, y: complex) -> complex:
    """EML operator on complex numbers: eml(x, y) = exp(x) - log(y)."""
    return cmath.exp(x) - cmath.log(y)

def eml_gaussian_norm(z: GaussianInt) -> float:
    """Compute |z|² via EML: |z|² = exp(2·Re(log(z))) + exp(2·Im(log(z)))...
    Actually |z|² = z·z̄, which in log-space is exp(log|z|² ) = exp(2·log|z|).
    """
    c = z.to_complex()
    if abs(c) == 0:
        return 0
    return math.exp(2 * math.log(abs(c)))

# =============================================================================
# Berggren via Gaussian Integers
# =============================================================================

def analyze_berggren_gaussian():
    """Analyze how Berggren transformations relate to Gaussian integer operations.

    Key observation: The Berggren matrices act on the vector (a, b, c) where
    a² + b² = c². If we write z = a + bi, then |z|² = c².
    The Berggren matrices can be seen as specific transformations in the
    Gaussian integer framework.
    """
    results = {}

    # Root: z = 3 + 4i, |z|² = 25 = 5²
    root = GaussianInt(3, 4)
    results['root'] = {
        'gaussian': str(root),
        'norm_sq': root.norm_sq(),
        'triple': (3, 4, 5),
    }

    # Euclid parametrization: z = m + ni gives triple (m²-n², 2mn, m²+n²)
    # For (3,4,5): m=2, n=1 → (4-1, 4, 4+1) = (3, 4, 5) ✓
    z_param = GaussianInt(2, 1)
    results['euclid_param'] = {
        'z': str(z_param),
        'z_squared': str(z_param * z_param),
        'triple_from_z': gaussian_to_triple(z_param),
    }

    # Product structure: multiplying Gaussian integers
    z1 = GaussianInt(2, 1)  # gives (3, 4, 5)
    z2 = GaussianInt(3, 2)  # gives (5, 12, 13)

    product = z1 * z2
    t1 = gaussian_to_triple(z1)
    t2 = gaussian_to_triple(z2)
    t_product = gaussian_to_triple(product)

    results['product'] = {
        'z1': str(z1), 'triple1': t1,
        'z2': str(z2), 'triple2': t2,
        'product': str(product), 'product_triple': t_product,
        'hyp_product': t1[2] * t2[2],
    }

    return results

# =============================================================================
# EML-Gaussian Angle Analysis
# =============================================================================

def eml_angle_analysis(depth: int = 4):
    """Analyze angles of Gaussian integers corresponding to Berggren tree triples.

    For a triple (a, b, c), the Gaussian integer z = a + bi has angle θ = arg(z).
    In EML terms: θ = Im(log(z)), and the triple lies on the EML manifold.
    """
    from pythagorean_bridge_explorer import generate_tree, BERGGREN

    angles = []
    norms = []

    def traverse(a, b, c, d):
        if a > 0 and b > 0:
            z = complex(a, b)
            theta = cmath.phase(z)
            r = abs(z)
            angles.append(math.degrees(theta))
            norms.append(r)
        if d < depth:
            from pythagorean_bridge_explorer import berggren_A, berggren_B, berggren_C
            for fn in [berggren_A, berggren_B, berggren_C]:
                na, nb, nc = fn(a, b, c)
                traverse(na, nb, nc, d + 1)

    traverse(3, 4, 5, 0)
    return angles, norms

# =============================================================================
# Demo
# =============================================================================

def run_demo():
    print("=" * 70)
    print("  EML–GAUSSIAN INTEGER BRIDGE")
    print("=" * 70)

    # Demo 1: Basic Gaussian-Pythagorean Connection
    print("\n🔢 Demo 1: Gaussian Integers → Pythagorean Triples")
    print("-" * 50)
    params = [(2,1), (3,2), (4,1), (4,3), (5,2), (5,4), (6,1), (6,5)]
    for m, n in params:
        z = GaussianInt(m, n)
        triple = gaussian_to_triple(z)
        a, b, c = triple
        ok = a**2 + b**2 == c**2
        print(f"  z = {z}  →  triple = {triple}  ✓ Pyth: {ok}")

    # Demo 2: Brahmagupta-Fibonacci via Gaussian Multiplication
    print("\n✖️  Demo 2: Triple Products via Gaussian Multiplication")
    print("-" * 50)
    z1 = GaussianInt(2, 1)  # (3, 4, 5)
    z2 = GaussianInt(3, 2)  # (5, 12, 13)
    z3 = GaussianInt(4, 1)  # (15, 8, 17)

    for zi, zj in [(z1, z2), (z1, z3), (z2, z3)]:
        product = zi * zj
        ti = gaussian_to_triple(zi)
        tj = gaussian_to_triple(zj)
        tp = gaussian_to_triple(product)
        print(f"  {zi} × {zj} = {product}")
        print(f"    {ti} ⊗ {tj} = {tp}")
        a, b, c = tp
        print(f"    Verify: {a}² + {b}² = {a**2+b**2} = {c}² = {c**2}  ✓={a**2+b**2==c**2}")

    # Demo 3: Berggren-Gaussian Analysis
    print("\n🌳 Demo 3: Berggren Tree in Gaussian Integer Space")
    print("-" * 50)
    results = analyze_berggren_gaussian()
    for key, val in results.items():
        print(f"  {key}:")
        for k, v in val.items():
            print(f"    {k}: {v}")

    # Demo 4: EML Encoding of Gaussian Norm
    print("\n🔬 Demo 4: EML Encoding of Gaussian Norms")
    print("-" * 50)
    gaussians = [
        GaussianInt(3, 4),
        GaussianInt(5, 12),
        GaussianInt(8, 15),
        GaussianInt(7, 24),
    ]
    for g in gaussians:
        exact_norm = g.norm_sq()
        eml_norm = eml_gaussian_norm(g)
        print(f"  |{g}|² = {exact_norm}  (EML: {eml_norm:.6f}, err: {abs(eml_norm - exact_norm):.2e})")

    # Demo 5: Complex EML operator
    print("\n🌀 Demo 5: EML on Complex Numbers")
    print("-" * 50)
    test_values = [
        (complex(1, 0), complex(1, 0)),
        (complex(0, math.pi), complex(1, 0)),
        (complex(1, math.pi/2), complex(1, 0)),
    ]
    for x, y in test_values:
        result = eml_complex(x, y)
        print(f"  eml({x}, {y}) = {result:.6f}")

    # Demo 6: Norm multiplicativity
    print("\n📊 Demo 6: Gaussian Norm Multiplicativity")
    print("-" * 50)
    pairs = [(GaussianInt(2, 1), GaussianInt(3, 2)),
             (GaussianInt(4, 1), GaussianInt(5, 2)),
             (GaussianInt(3, 4), GaussianInt(5, 12))]
    for z1, z2 in pairs:
        product = z1 * z2
        n1 = z1.norm_sq()
        n2 = z2.norm_sq()
        np = product.norm_sq()
        print(f"  |{z1}|² × |{z2}|² = {n1} × {n2} = {n1*n2}")
        print(f"  |{z1} × {z2}|² = |{product}|² = {np}")
        print(f"  Match: {n1 * n2 == np} ✓")

    print("\n" + "=" * 70)
    print("  Gaussian integer bridge exploration complete!")
    print("=" * 70)

if __name__ == '__main__':
    run_demo()
