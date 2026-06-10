#!/usr/bin/env python3
"""
Algorithms for Graph-Cut Holographic Models

Implements the core algorithms from the holographic coding geometry framework:
1. Submodular profile computation
2. Syndrome defect and curvature tensor
3. Holographic code profile construction
4. Curvature-distance duality conjecture testing
5. Pythagorean entropy norm computation
"""

import math
import random
from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Tuple, Optional


# Type aliases
SetFn = Callable[[FrozenSet[int]], float]


class SubmodularProfile:
    """
    A normalized, nonneg, submodular set function.

    Represents the abstract min-cut entropy function on boundary regions
    of a holographic code.

    Time complexity:
        - Construction: O(1)
        - defect(X, Y): O(T_f) where T_f is time to evaluate f
        - verify_submodularity: O(4^n * T_f) for n-element ground set
    """

    def __init__(self, f: SetFn, ground_set: FrozenSet[int]):
        self.f = f
        self.ground_set = ground_set
        # Verify normalization
        assert abs(f(frozenset())) < 1e-10, "f(∅) must be 0"

    def defect(self, X: FrozenSet[int], Y: FrozenSet[int]) -> float:
        """
        Compute the submodular defect: f(X) + f(Y) - f(X∩Y) - f(X∪Y).

        Returns ≥ 0 for submodular functions (proved in Lean as
        SubmodularProfile.defect_nonneg).

        Args:
            X, Y: Subsets of the ground set

        Returns:
            The defect value (≥ 0)
        """
        return self.f(X) + self.f(Y) - self.f(X & Y) - self.f(X | Y)

    def curvature_tensor(self, X: FrozenSet[int], Y: FrozenSet[int],
                          Z: FrozenSet[int]) -> float:
        """
        Compute the curvature tensor K(X, Y, Z).

        K = defect(X,Y) + defect(Y,Z) + defect(X,Z)
          - defect(X, Y∪Z) - defect(Y, X∪Z) - defect(Z, X∪Y)

        Measures higher-order tripartite interaction beyond pairwise defects.
        """
        return (self.defect(X, Y) + self.defect(Y, Z) + self.defect(X, Z)
                - self.defect(X, Y | Z) - self.defect(Y, X | Z)
                - self.defect(Z, X | Y))

    def total_curvature(self, pairs: List[Tuple[FrozenSet[int], FrozenSet[int]]]) -> float:
        """
        Compute total curvature over a list of region pairs.

        Proved nonneg in Lean (total_curvature_nonneg) by list induction.
        """
        return sum(self.defect(X, Y) for X, Y in pairs)

    def is_modular_pair(self, X: FrozenSet[int], Y: FrozenSet[int],
                         tol: float = 1e-10) -> bool:
        """Check if (X, Y) is a modular pair (defect ≈ 0)."""
        return abs(self.defect(X, Y)) < tol

    def verify_submodularity(self, tol: float = 1e-10) -> bool:
        """
        Verify submodularity on all pairs of subsets.

        Time: O(4^n) where n = |ground_set|.
        """
        elems = list(self.ground_set)
        n = len(elems)
        subsets = []
        for k in range(n + 1):
            for combo in combinations(elems, k):
                subsets.append(frozenset(combo))

        for X in subsets:
            for Y in subsets:
                if self.defect(X, Y) < -tol:
                    return False
        return True

    def verify_nonnegativity(self, tol: float = 1e-10) -> bool:
        """Verify f(X) ≥ 0 for all subsets."""
        elems = list(self.ground_set)
        n = len(elems)
        for k in range(n + 1):
            for combo in combinations(elems, k):
                if self.f(frozenset(combo)) < -tol:
                    return False
        return True


class HolographicProfile:
    """
    A holographic code profile: entropy + area linked by the RT relation.

    S(X) = area(X) / 4 (Ryu-Takayanagi)

    Constructed from a submodular profile with a cardinality bound.
    """

    def __init__(self, submodular: SubmodularProfile):
        self.submodular = submodular
        self.S = submodular.f
        self.area = lambda X: 4 * submodular.f(X)

    def syndrome_defect(self, X: FrozenSet[int], Y: FrozenSet[int]) -> float:
        """Syndrome defect = entropy defect."""
        return self.submodular.defect(X, Y)

    def area_defect(self, X: FrozenSet[int], Y: FrozenSet[int]) -> float:
        """Area defect = 4 * syndrome defect (proved in Lean)."""
        return 4 * self.syndrome_defect(X, Y)


class PythagoreanTriple:
    """
    A Pythagorean triple (a, b, c) with a² + b² = c².

    Provides the entropy norm (a/c, b/c) lying on the unit circle.
    """

    def __init__(self, a: int, b: int, c: int):
        assert a > 0 and b > 0 and c > 0
        assert a**2 + b**2 == c**2, f"{a}² + {b}² ≠ {c}²"
        self.a = a
        self.b = b
        self.c = c

    def entropy_norm(self) -> Tuple[float, float]:
        """The entropy norm (a/c, b/c), guaranteed on S¹."""
        return (self.a / self.c, self.b / self.c)

    def verify_entropy_identity(self, tol: float = 1e-12) -> bool:
        """Verify (a/c)² + (b/c)² = 1."""
        ac, bc = self.entropy_norm()
        return abs(ac**2 + bc**2 - 1.0) < tol

    def submodularity_ratio(self) -> float:
        """a/c + b/c, guaranteed ≥ 1 (proved in Lean)."""
        return self.a / self.c + self.b / self.c

    @staticmethod
    def generate_from_formula(m: int, n: int) -> 'PythagoreanTriple':
        """Generate (m²-n², 2mn, m²+n²) for m > n > 0."""
        assert m > n > 0
        a = m**2 - n**2
        b = 2 * m * n
        c = m**2 + n**2
        return PythagoreanTriple(a, b, c)


def test_curvature_distance_duality(
    profile: SubmodularProfile,
    num_samples: int = 1000
) -> Dict[str, float]:
    """
    Test the Curvature-Distance Duality Conjecture.

    Conjecture: |K(X,Y,Z)| ≤ (defect(X,Y) · defect(Y,Z) · defect(X,Z))^(2/3)

    Args:
        profile: A submodular profile
        num_samples: Number of random triples to test

    Returns:
        Dictionary with test results
    """
    elems = list(profile.ground_set)
    n = len(elems)

    # Generate all nonempty subsets
    subsets = []
    for k in range(1, n + 1):
        for combo in combinations(elems, k):
            subsets.append(frozenset(combo))

    violations = 0
    total_tests = 0
    max_ratio = 0.0

    for _ in range(min(num_samples, len(subsets)**3)):
        X = random.choice(subsets)
        Y = random.choice(subsets)
        Z = random.choice(subsets)

        K = abs(profile.curvature_tensor(X, Y, Z))
        dXY = profile.defect(X, Y)
        dYZ = profile.defect(Y, Z)
        dXZ = profile.defect(X, Z)

        product = dXY * dYZ * dXZ
        if product > 1e-15:
            bound = product ** (2/3)
            total_tests += 1
            if K > bound + 1e-10:
                violations += 1
            if bound > 0:
                max_ratio = max(max_ratio, K / bound)

    return {
        "total_tests": total_tests,
        "violations": violations,
        "violation_rate": violations / max(total_tests, 1),
        "max_ratio": max_ratio,
        "conjecture_holds": violations == 0
    }


def weighted_combination_submodularity(
    profiles: List[Tuple[float, SubmodularProfile]],
    X: FrozenSet[int],
    Y: FrozenSet[int]
) -> float:
    """
    Compute the weighted combination defect.

    Proved nonneg in Lean (submodular_weighted_combination) by list induction.
    """
    lhs = sum(w * p.f(X) for w, p in profiles) + sum(w * p.f(Y) for w, p in profiles)
    rhs = (sum(w * p.f(X & Y) for w, p in profiles) +
           sum(w * p.f(X | Y) for w, p in profiles))
    return lhs - rhs


# === Factory functions for common submodular profiles ===

def matroid_rank_profile(ground_set: FrozenSet[int], rank: int) -> SubmodularProfile:
    """Create a uniform matroid rank function (submodular)."""
    def f(S: FrozenSet[int]) -> float:
        return min(len(S), rank)
    return SubmodularProfile(f, ground_set)


def cut_entropy_profile(
    adjacency: Dict[int, Dict[int, float]],
    boundary: FrozenSet[int]
) -> SubmodularProfile:
    """
    Create a cut-entropy profile from a weighted graph.

    For X ⊆ boundary, f(X) = sum of weights of edges between X and boundary \ X.
    This is always submodular (graph cut functions).
    """
    def f(S: FrozenSet[int]) -> float:
        if not S:
            return 0.0
        complement = boundary - S
        total = 0.0
        for u in S:
            for v in complement:
                if v in adjacency.get(u, {}):
                    total += adjacency[u][v]
        return total

    return SubmodularProfile(f, boundary)


if __name__ == "__main__":
    print("=== Algorithm Tests ===\n")

    # Test 1: Matroid rank profile
    gs = frozenset({0, 1, 2, 3})
    profile = matroid_rank_profile(gs, 2)
    print(f"Matroid rank profile (rank 2, n=4):")
    print(f"  Submodular: {profile.verify_submodularity()}")
    print(f"  Nonnegative: {profile.verify_nonnegativity()}")

    # Test 2: Pythagorean triples
    triples = [PythagoreanTriple.generate_from_formula(m, n)
               for m in range(2, 8) for n in range(1, m)]
    print(f"\nGenerated {len(triples)} Pythagorean triples")
    all_valid = all(t.verify_entropy_identity() for t in triples)
    print(f"  All on unit circle: {all_valid}")

    # Test 3: Curvature-distance duality
    results = test_curvature_distance_duality(profile, 500)
    print(f"\nCurvature-Distance Duality Conjecture Test:")
    print(f"  Tests: {results['total_tests']}")
    print(f"  Violations: {results['violations']}")
    print(f"  Max ratio: {results['max_ratio']:.4f}")
    print(f"  Conjecture holds: {results['conjecture_holds']}")

    # Test 4: Cut entropy profile
    adj = {
        0: {1: 1.0, 2: 2.0, 3: 0.5},
        1: {0: 1.0, 2: 1.5, 3: 1.0},
        2: {0: 2.0, 1: 1.5, 3: 0.8},
        3: {0: 0.5, 1: 1.0, 2: 0.8},
    }
    boundary = frozenset({0, 1, 2, 3})
    cut_profile = cut_entropy_profile(adj, boundary)
    print(f"\nCut entropy profile:")
    print(f"  Submodular: {cut_profile.verify_submodularity()}")
    print(f"  f({{0}}) = {cut_profile.f(frozenset({0})):.2f}")
    print(f"  f({{0,1}}) = {cut_profile.f(frozenset({0, 1})):.2f}")
    print(f"  defect({{0}}, {{1}}) = {cut_profile.defect(frozenset({0}), frozenset({1})):.4f}")
