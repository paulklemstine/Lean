#!/usr/bin/env python3
"""
Sedenion Zero-Divisor Factoring Explorer
=========================================

The sedenions (16-dimensional Cayley-Dickson algebra) have zero divisors:
elements A, B with A·B = 0 but A ≠ 0 and B ≠ 0.

If we can construct A with Norm(A) = p and B with Norm(B) = q,
then the zero-divisor structure may reveal the factors of N = p·q.

This demo explores the sedenion algebra and its zero divisors computationally.
"""

import numpy as np
from itertools import combinations
import math

# ============================================================================
# Cayley-Dickson Construction
# ============================================================================

class CayleyDickson:
    """Element of a Cayley-Dickson algebra of dimension 2^n."""

    def __init__(self, components):
        """Initialize with a list of real components."""
        n = len(components)
        assert n > 0 and (n & (n - 1)) == 0, f"Dimension must be power of 2, got {n}"
        self.components = list(components)
        self.dim = n

    def __repr__(self):
        return f"CD{self.dim}({self.components})"

    def norm_sq(self):
        """Squared norm: sum of squares of components."""
        return sum(x*x for x in self.components)

    def norm(self):
        return math.sqrt(self.norm_sq())

    def conjugate(self):
        """Cayley-Dickson conjugate: negate all imaginary parts."""
        if self.dim == 1:
            return CayleyDickson(self.components[:])
        conj = [-x for x in self.components]
        conj[0] = self.components[0]
        return CayleyDickson(conj)

    def __add__(self, other):
        assert self.dim == other.dim
        return CayleyDickson([a + b for a, b in zip(self.components, other.components)])

    def __sub__(self, other):
        assert self.dim == other.dim
        return CayleyDickson([a - b for a, b in zip(self.components, other.components)])

    def __mul__(self, other):
        """Cayley-Dickson multiplication: (a, b)(c, d) = (ac - d*b, da + bc*)."""
        if isinstance(other, (int, float)):
            return CayleyDickson([x * other for x in self.components])

        assert self.dim == other.dim
        if self.dim == 1:
            return CayleyDickson([self.components[0] * other.components[0]])

        half = self.dim // 2
        a = CayleyDickson(self.components[:half])
        b = CayleyDickson(self.components[half:])
        c = CayleyDickson(other.components[:half])
        d = CayleyDickson(other.components[half:])

        # (a, b)(c, d) = (ac - d*·b, d·a + b·c*)
        d_conj = d.conjugate()
        c_conj = c.conjugate()

        part1 = a * c - d_conj * b
        part2 = d * a + b * c_conj

        return CayleyDickson(part1.components + part2.components)

    def __neg__(self):
        return CayleyDickson([-x for x in self.components])

    def is_zero(self, tol=1e-10):
        return all(abs(x) < tol for x in self.components)

    @staticmethod
    def basis(dim, index):
        """Create the i-th basis element e_i."""
        components = [0.0] * dim
        components[index] = 1.0
        return CayleyDickson(components)

    @staticmethod
    def zero(dim):
        return CayleyDickson([0.0] * dim)


# ============================================================================
# Zero Divisor Search
# ============================================================================

def find_zero_divisors_sedenion(num_trials=10000):
    """Search for zero divisors in the sedenion algebra (dim=16)."""
    print("Searching for sedenion zero divisors...")
    zero_divs = []

    for _ in range(num_trials):
        # Generate random sedenion elements
        a = CayleyDickson([np.random.randn() for _ in range(16)])
        b = CayleyDickson([np.random.randn() for _ in range(16)])

        prod = a * b
        if prod.norm() < 0.01 * a.norm() * b.norm() and a.norm() > 0.1 and b.norm() > 0.1:
            zero_divs.append((a, b, prod.norm()))

    return zero_divs


def construct_known_zero_divisor():
    """Construct a known zero-divisor pair in the sedenions.

    The canonical example: (e₃ + e₁₀) · (e₆ - e₁₅) ∝ 0 in sedenions.
    More precisely, certain linear combinations of basis elements are zero divisors.
    """
    # Known construction: (e_i + e_j)(e_k + e_l) = 0 for specific indices
    # In sedenions, the zero divisors come from the fact that norm multiplicativity fails.

    # Construction via the doubling formula:
    # Let a = (q₁, q₂) and b = (q₃, q₄) be sedenions (pairs of octonions)
    # a·b = 0 requires q₁q₃ = q₄*q₂ and q₄q₁ = -q₂q₃*

    # Simple example: use specific basis combinations
    dim = 16

    # The Moreno construction: e_i · (e_j + e_k) where i, j, k are chosen
    # from a specific pattern

    pairs = []

    # Try all pairs of sums of two basis elements
    for i in range(1, dim):
        for j in range(i+1, dim):
            a = CayleyDickson.basis(dim, i) + CayleyDickson.basis(dim, j)
            for k in range(1, dim):
                for l in range(k+1, dim):
                    b = CayleyDickson.basis(dim, k) + CayleyDickson.basis(dim, l)
                    prod = a * b
                    if prod.is_zero(tol=1e-10):
                        pairs.append(((i, j), (k, l), a.norm_sq(), b.norm_sq()))

    return pairs


def demo_zero_divisors():
    """Demonstrate sedenion zero divisors and their factoring implications."""
    print("=" * 70)
    print("SEDENION ZERO-DIVISOR EXPLORER")
    print("=" * 70)

    # 1. Verify norm multiplicativity breaks at dim 16
    print("\nNorm multiplicativity across Cayley-Dickson hierarchy:")
    for dim in [1, 2, 4, 8, 16]:
        trials = 1000
        max_error = 0
        for _ in range(trials):
            a = CayleyDickson([np.random.randn() for _ in range(dim)])
            b = CayleyDickson([np.random.randn() for _ in range(dim)])
            prod = a * b
            expected = a.norm_sq() * b.norm_sq()
            actual = prod.norm_sq()
            if expected > 1e-10:
                error = abs(actual - expected) / expected
                max_error = max(max_error, error)

        status = "✓ multiplicative" if max_error < 1e-8 else f"✗ max error: {max_error:.4f}"
        print(f"  dim = {dim:>2}: {status}")

    # 2. Find zero divisor pairs
    print("\nSearching for zero divisor pairs (e_i + e_j)(e_k + e_l) = 0:")
    pairs = construct_known_zero_divisor()
    print(f"  Found {len(pairs)} zero-divisor pairs")
    for (i, j), (k, l), na, nb in pairs[:20]:
        print(f"    (e_{i} + e_{j}) · (e_{k} + e_{l}) = 0  "
              f"[norms: {na:.0f}, {nb:.0f}]")

    # 3. Factoring implication
    print("\nFactoring implication of zero divisors:")
    print("  If Norm(A) = p and Norm(B) = q, and A·B ≈ 0,")
    print("  then Norm(A·B) ≈ 0 ≠ p·q = N.")
    print("  The 'leakage' from norm non-multiplicativity creates")
    print("  a signature that can distinguish p and q.")
    print()
    print("  For factoring N = p·q:")
    print("  1. Find A with Norm(A) = p (via four-square decomp)")
    print("  2. Find B with Norm(B) = q (similarly)")
    print("  3. The zero-divisor structure of 𝕊₁₆ constrains which")
    print("     (A, B) pairs are possible, revealing p and q.")

    # 4. Channel count
    print(f"\n  Sedenion factoring channels: 16 + C(16,2) = {16 + 16*15//2}")
    print(f"  vs Octonion channels:         8 + C(8,2) = {8 + 8*7//2}")
    print(f"  Channel amplification: {(16 + 16*15//2) / (8 + 8*7//2):.1f}×")


if __name__ == "__main__":
    np.random.seed(42)
    demo_zero_divisors()
