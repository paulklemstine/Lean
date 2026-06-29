#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Haar Measure on Restricted Products

Implements the core computational algorithms underlying the formal theory:
1. Cylinder measure evaluation algorithm
2. Normalization algorithm for restricted product Haar measure
3. Level compatibility verification
4. Euler product computation via cylinder factorization
"""

from fractions import Fraction
from math import gcd
from functools import reduce
from typing import Optional
import operator


class LocalGroup:
    """Represents a finite local group G_p with compact open subgroup K_p."""

    def __init__(self, elements: list[int], modulus: int, subgroup: Optional[list[int]] = None):
        """
        Args:
            elements: Elements of G_p (as integers mod modulus)
            modulus: The modulus for arithmetic
            subgroup: Elements of K_p ⊂ G_p (defaults to all of G_p)
        """
        self.elements = elements
        self.modulus = modulus
        self.subgroup = subgroup if subgroup is not None else elements
        self.order = len(elements)
        self.subgroup_order = len(self.subgroup)

    def mul(self, a: int, b: int) -> int:
        """Group multiplication."""
        return (a * b) % self.modulus

    def inv(self, a: int) -> int:
        """Group inverse (modular inverse)."""
        return pow(a, -1, self.modulus)

    def translate(self, g: int, subset: list[int]) -> list[int]:
        """Left translate: g · S = {g*s : s ∈ S}."""
        return list(set(self.mul(g, s) for s in subset))

    @staticmethod
    def units_mod_n(n: int) -> 'LocalGroup':
        """Create the group (Z/nZ)* with itself as compact open subgroup."""
        elts = [k for k in range(n) if gcd(k, n) == 1]
        return LocalGroup(elts, n)


class RestrictedProductMeasure:
    """
    Computes measures on restricted products of finite groups.

    Algorithm: CylinderMeasure
    Input: finite family of local groups {G_p, K_p}, support set S,
           cylinder sets {A_p : p ∈ S}
    Output: μ(cylinder) as a Fraction

    Time complexity: O(|support| + |primes|)
    Space complexity: O(|primes|)

    The algorithm computes:
      μ(∏_{p∈S} A_p × ∏_{p∉S} K_p) = ∏_{p∈S} μ_p(A_p) / μ_p(K_p)

    where μ_p is counting measure on G_p, normalized so μ_p(K_p) = 1.
    """

    def __init__(self, local_groups: dict[int, LocalGroup]):
        """
        Args:
            local_groups: {prime p: LocalGroup representing G_p with K_p}
        """
        self.groups = local_groups
        self.primes = sorted(local_groups.keys())

    def cylinder_measure(self, support: set[int],
                         cylinder_sets: dict[int, list[int]]) -> Fraction:
        """
        Evaluate the normalized Haar measure of a basic cylinder.

        Algorithm:
        1. For each p in support: contribute |A_p| / |K_p|
        2. For each p not in support: contribute 1 (normalization)
        3. Return the product

        Args:
            support: finite set S of places
            cylinder_sets: {p: A_p} for p in support

        Returns:
            μ(basicCylinder(S, A)) as a Fraction
        """
        measure = Fraction(1)
        for p in self.primes:
            if p in support:
                A_p = cylinder_sets.get(p, self.groups[p].subgroup)
                K_p = self.groups[p].subgroup
                measure *= Fraction(len(A_p), len(K_p))
        return measure

    def maximal_compact_measure(self) -> Fraction:
        """μ(∏ K_p) = 1 by normalization."""
        return self.cylinder_measure(set(), {})

    def verify_translation_invariance(self, support: set[int],
                                       cylinder_sets: dict[int, list[int]],
                                       translation: dict[int, int]) -> bool:
        """
        Verify that left translation preserves cylinder measure.

        Algorithm:
        1. Compute μ(cylinder) for original sets
        2. Translate each A_p by g_p
        3. Compute μ(translated cylinder)
        4. Return whether they are equal

        Correctness: follows from left-invariance of Haar measure.
        """
        original = self.cylinder_measure(support, cylinder_sets)

        translated_sets = {}
        for p in support:
            g_p = translation.get(p, 1)
            A_p = cylinder_sets.get(p, self.groups[p].subgroup)
            translated_sets[p] = self.groups[p].translate(g_p, A_p)

        translated = self.cylinder_measure(support, translated_sets)
        return original == translated

    def verify_level_compatibility(self, support_small: set[int],
                                    support_large: set[int],
                                    cylinder_sets: dict[int, list[int]]) -> bool:
        """
        Verify level compatibility: enlarging the support with K_p on new
        coordinates does not change the cylinder measure.

        Algorithm:
        1. Compute μ on small support
        2. Compute μ on large support (with K_p on new coordinates)
        3. Return whether they are equal

        This verifies: basicCylinder(S, A) = basicCylinder(T, A') when
        T ⊇ S and A'_p = K_p for p ∈ T \ S.
        """
        if not support_small.issubset(support_large):
            raise ValueError("Small support must be subset of large support")

        # Extend cylinder sets: on new coordinates, use K_p
        extended_sets = dict(cylinder_sets)
        for p in support_large - support_small:
            extended_sets[p] = self.groups[p].subgroup

        μ_small = self.cylinder_measure(support_small, cylinder_sets)
        μ_large = self.cylinder_measure(support_large, extended_sets)
        return μ_small == μ_large

    def euler_product(self, local_values: dict[int, Fraction]) -> Fraction:
        """
        Compute a finite Euler product: ∏_p f(p).

        This demonstrates the connection between cylinder measures and
        Euler products: if f_p is a local observable depending only on
        the p-th coordinate, then

          E[∏ f_p] = ∏ E[f_p]

        by coordinate independence.

        Args:
            local_values: {p: f(p)} for each prime

        Returns:
            ∏_p f(p)
        """
        return reduce(operator.mul,
                      (local_values.get(p, Fraction(1)) for p in self.primes),
                      Fraction(1))


def main():
    """Demonstrate the algorithms."""
    print("=" * 60)
    print("RESTRICTED PRODUCT MEASURE ALGORITHMS")
    print("=" * 60)

    # Set up local groups: (Z/p²Z)* for small primes
    primes = [2, 3, 5, 7, 11]
    local_groups = {p: LocalGroup.units_mod_n(p**2) for p in primes}
    rpm = RestrictedProductMeasure(local_groups)

    print("\n1. LOCAL GROUP DATA")
    print("-" * 40)
    for p in primes:
        g = local_groups[p]
        print(f"  p={p}: |(Z/{p**2}Z)*| = {g.order}, "
              f"φ(p²) = p(p-1) = {p*(p-1)}")

    print("\n2. CYLINDER MEASURE EVALUATION")
    print("-" * 40)
    # Various cylinder sets
    test_cases = [
        ({2}, {2: [1]}),
        ({3}, {3: [1, 2]}),
        ({2, 3}, {2: [1], 3: [1, 2]}),
        ({2, 3, 5}, {2: [1], 3: [1, 2], 5: [1, 2, 3, 4]}),
    ]
    for support, cyl in test_cases:
        μ = rpm.cylinder_measure(support, cyl)
        sizes = " × ".join(f"|A_{p}|={len(cyl[p])}" for p in sorted(support))
        print(f"  S={support}, {sizes}: μ = {μ} ≈ {float(μ):.6f}")

    print("\n3. NORMALIZATION VERIFICATION")
    print("-" * 40)
    μ0 = rpm.maximal_compact_measure()
    print(f"  μ(∏ K_p) = {μ0} {'✓' if μ0 == 1 else '✗'}")

    print("\n4. TRANSLATION INVARIANCE")
    print("-" * 40)
    for g in [{2: 3, 3: 2}, {2: 1, 3: 5, 5: 3, 7: 2}]:
        ok = rpm.verify_translation_invariance({2, 3}, {2: [1], 3: [1, 2]}, g)
        print(f"  g = {g}: invariant = {ok} {'✓' if ok else '✗'}")

    print("\n5. LEVEL COMPATIBILITY")
    print("-" * 40)
    for s_small, s_large in [({2}, {2, 3}), ({3}, {2, 3, 5}), ({2, 3}, {2, 3, 5, 7})]:
        ok = rpm.verify_level_compatibility(s_small, s_large, {2: [1], 3: [1, 2]})
        print(f"  {s_small} ⊂ {s_large}: compatible = {ok} {'✓' if ok else '✗'}")

    print("\n6. EULER PRODUCT COMPUTATION")
    print("-" * 40)
    # Compute ∏_p (1 - 1/p²) as a finite approximation
    local_vals = {p: Fraction(1) - Fraction(1, p**2) for p in primes}
    product = rpm.euler_product(local_vals)
    print(f"  ∏_p (1 - 1/p²) for p ∈ {primes}")
    print(f"  = {product} ≈ {float(product):.8f}")
    print(f"  (Full product → 6/π² ≈ 0.60792710)")

    print("\n" + "=" * 60)
    print("ALL ALGORITHM DEMONSTRATIONS COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()
