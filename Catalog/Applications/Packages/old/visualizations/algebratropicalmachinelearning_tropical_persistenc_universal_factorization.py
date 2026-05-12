#!/usr/bin/env python3
"""
Algorithms for Tropical Persistence Realization Duality

Implements the core algorithms from the formal theory:
1. Interleaving certificate distance computation
2. Stable kernel computation and barcode quotient construction
3. Certified barcode reconstruction from distance matrices
4. Stability analysis under perturbation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass, field


# ============================================================================
# Data Structures
# ============================================================================

@dataclass
class TropicalInterval:
    """A tropical persistence interval [birth, death).

    Attributes:
        birth: Birth time of the topological feature.
        death: Death time of the topological feature.
    """
    birth: float
    death: float

    @property
    def lifetime(self) -> float:
        """The persistence (lifetime) of this interval."""
        return self.death - self.birth

    def __repr__(self) -> str:
        return f"[{self.birth:.4f}, {self.death:.4f})"


@dataclass
class TropicalBarcode:
    """A tropical barcode: a finite multiset of tropical intervals.

    Attributes:
        intervals: List of tropical intervals comprising the barcode.
    """
    intervals: List[TropicalInterval] = field(default_factory=list)

    @property
    def size(self) -> int:
        """Number of intervals in the barcode."""
        return len(self.intervals)

    def __repr__(self) -> str:
        return f"Barcode({self.intervals})"


# ============================================================================
# Algorithm 1: Interleaving Certificate Distance
# ============================================================================

def interleaving_certificate_distance(
    x: np.ndarray,
    y: np.ndarray,
    shift_type: str = "additive"
) -> float:
    """Compute the interleaving certificate distance between two points.

    For the additive shift action F(ε)(x) = x + ε on R≥0^n:
    d_I(x, y) = inf{ε ≥ 0 : F(ε)(x) ≤ y ∧ F(ε)(y) ≤ x}

    For componentwise additive shift, this requires x_i + ε ≤ y_i AND y_i + ε ≤ x_i
    for all coordinates i. This forces 2ε ≤ 0, so ε = 0 and x = y.

    For the max-shift action (tropical), different bounds apply.

    Args:
        x: First point in R≥0^n.
        y: Second point in R≥0^n.
        shift_type: Type of shift action ("additive" or "bottleneck").

    Returns:
        The interleaving certificate distance.

    Time complexity: O(n) where n is the dimension.
    Space complexity: O(1).
    """
    if shift_type == "additive":
        # For additive shift: d(x,y) = 0 if x=y, else ∞
        if np.allclose(x, y):
            return 0.0
        else:
            return float('inf')
    elif shift_type == "bottleneck":
        # Bottleneck-style: max coordinate difference
        return float(np.max(np.abs(x - y)))
    else:
        raise ValueError(f"Unknown shift type: {shift_type}")


# ============================================================================
# Algorithm 2: Stable Kernel Computation
# ============================================================================

def compute_stable_kernel(
    generators: List[np.ndarray],
    functionals: Optional[List[callable]] = None,
    tolerance: float = 1e-10
) -> List[Set[int]]:
    """Compute the stable kernel equivalence classes of a generator set.

    Two generators i, j are in the stable kernel if φ(gen_i) = φ(gen_j) for
    all stable functionals φ. When functionals are coordinate projections,
    this reduces to checking equality of generator values.

    Args:
        generators: List of generator points in R^n.
        functionals: Optional list of functional evaluators. If None,
            uses coordinate projections.
        tolerance: Numerical tolerance for equality.

    Returns:
        List of equivalence classes (each a set of generator indices).

    Time complexity: O(n² · k) where n = |generators|, k = |functionals|.
    Space complexity: O(n²).
    """
    n = len(generators)

    if functionals is None:
        # Default: check direct equality of generators
        functionals = [lambda x, j=j: x[j] for j in range(generators[0].shape[0])]

    # Build equivalence classes by pairwise comparison
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(n):
        for j in range(i + 1, n):
            all_equal = all(
                abs(f(generators[i]) - f(generators[j])) < tolerance
                for f in functionals
            )
            if all_equal:
                union(i, j)

    # Collect classes
    classes_dict: Dict[int, Set[int]] = {}
    for i in range(n):
        root = find(i)
        if root not in classes_dict:
            classes_dict[root] = set()
        classes_dict[root].add(i)

    return list(classes_dict.values())


# ============================================================================
# Algorithm 3: Certified Barcode Reconstruction
# ============================================================================

def certified_barcode_reconstruction(
    generators: List[np.ndarray],
    distance_matrix: Optional[np.ndarray] = None,
    birth_death_map: Optional[callable] = None,
    tolerance: float = 1e-10
) -> Tuple[TropicalBarcode, List[Set[int]]]:
    """Reconstruct a certified barcode from generators and distance data.

    Algorithm:
    1. Compute pairwise distance matrix (if not provided).
    2. Find distance-zero equivalence classes.
    3. Assign birth/death values to each class.
    4. Return the barcode and class assignments.

    Args:
        generators: List of generator points.
        distance_matrix: Optional precomputed distance matrix.
        birth_death_map: Optional function mapping a generator to (birth, death).
            Defaults to (min coordinate, max coordinate).
        tolerance: Numerical tolerance.

    Returns:
        Tuple of (barcode, equivalence classes).

    Time complexity: O(n² · d) where n = |generators|, d = dimension.
    Space complexity: O(n²).

    Correctness guarantee (from certified_barcode_reconstruction theorem):
        If dist(i, j) = 0, then φ(gen_i) = φ(gen_j) for all stable functionals φ.
    """
    n = len(generators)

    # Step 1: Compute distance matrix
    if distance_matrix is None:
        distance_matrix = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                distance_matrix[i, j] = np.max(np.abs(generators[i] - generators[j]))

    # Step 2: Find distance-zero classes (union-find)
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(n):
        for j in range(i + 1, n):
            if distance_matrix[i, j] < tolerance:
                union(i, j)

    classes_dict: Dict[int, Set[int]] = {}
    for i in range(n):
        root = find(i)
        if root not in classes_dict:
            classes_dict[root] = set()
        classes_dict[root].add(i)
    classes = list(classes_dict.values())

    # Step 3: Assign birth/death to each class
    if birth_death_map is None:
        birth_death_map = lambda x: (float(np.min(x)), float(np.max(x)))

    intervals = []
    for cls in classes:
        rep = generators[min(cls)]  # canonical representative
        birth, death = birth_death_map(rep)
        intervals.append(TropicalInterval(birth=birth, death=death))

    barcode = TropicalBarcode(intervals=intervals)
    return barcode, classes


# ============================================================================
# Algorithm 4: Stability Analysis
# ============================================================================

def stability_analysis(
    generators: List[np.ndarray],
    functional: callable,
    perturbation_range: List[float] = None,
    n_trials: int = 100,
    seed: int = 42
) -> Dict[str, List[float]]:
    """Analyze stability of barcode reconstruction under perturbation.

    Tests the perturbation_stability theorem: functional values on generators
    are controlled by the distance matrix, even under perturbation.

    Args:
        generators: List of generator points.
        functional: A stable functional φ: R^n → R≥0.
        perturbation_range: List of perturbation magnitudes to test.
        n_trials: Number of random trials per perturbation level.
        seed: Random seed for reproducibility.

    Returns:
        Dictionary with keys:
            'epsilon': perturbation levels
            'max_violation': maximum stability violation at each level
            'avg_violation': average stability violation at each level
            'barcode_change': barcode size change at each level

    Time complexity: O(T · n² · d) per perturbation level,
        where T = n_trials, n = |generators|, d = dimension.
    """
    if perturbation_range is None:
        perturbation_range = [0.0, 0.01, 0.05, 0.1, 0.5, 1.0]

    rng = np.random.RandomState(seed)
    n = len(generators)

    # Exact distance matrix and barcode
    exact_dist = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            exact_dist[i, j] = np.max(np.abs(generators[i] - generators[j]))

    exact_barcode, _ = certified_barcode_reconstruction(generators, exact_dist)

    results = {
        'epsilon': perturbation_range,
        'max_violation': [],
        'avg_violation': [],
        'barcode_change': [],
    }

    for eps in perturbation_range:
        violations = []
        barcode_diffs = []

        for _ in range(n_trials):
            # Perturb distance matrix
            noise = rng.randn(n, n) * eps
            noise = (noise + noise.T) / 2
            np.fill_diagonal(noise, 0)
            perturbed = np.maximum(exact_dist + noise, 0)
            np.fill_diagonal(perturbed, 0)

            # Check stability: |φ(gen_i) - φ(gen_j)| ≤ D_perturbed(i,j)
            max_v = 0.0
            for i in range(n):
                for j in range(n):
                    diff = abs(functional(generators[i]) - functional(generators[j]))
                    bound = perturbed[i, j]
                    v = max(0, diff - bound)
                    max_v = max(max_v, v)
            violations.append(max_v)

            # Reconstruct barcode with perturbed distances
            perturbed_barcode, _ = certified_barcode_reconstruction(
                generators, perturbed)
            barcode_diffs.append(abs(perturbed_barcode.size - exact_barcode.size))

        results['max_violation'].append(max(violations))
        results['avg_violation'].append(np.mean(violations))
        results['barcode_change'].append(np.mean(barcode_diffs))

    return results


# ============================================================================
# Algorithm 5: Barcode Quotient Universal Factorization
# ============================================================================

def universal_factorization(
    generators: List[np.ndarray],
    functional: callable,
    tolerance: float = 1e-10
) -> Tuple[Dict[int, float], List[Set[int]]]:
    """Compute the universal factorization of a stable functional through
    the barcode quotient.

    Implements the constructive content of stable_func_factors_through_barcode:
    given φ and generators, compute the unique ψ such that φ = ψ ∘ π.

    Args:
        generators: List of generator points.
        functional: A stable functional φ.
        tolerance: Numerical tolerance.

    Returns:
        Tuple of:
            - ψ: Dict mapping class index → functional value
            - classes: The barcode quotient classes

    Time complexity: O(n²·d + n·k) where n = |generators|, d = dim, k = |functionals|.
    Space complexity: O(n²).

    Correctness guarantee (from stable_func_factors_through_barcode):
        ψ is the unique map satisfying φ(gen_i) = ψ(π(i)) for all i.
    """
    classes = compute_stable_kernel(generators, tolerance=tolerance)

    psi = {}
    for cls_idx, cls in enumerate(classes):
        rep = min(cls)
        psi[cls_idx] = functional(generators[rep])

    # Verify factorization
    for cls_idx, cls in enumerate(classes):
        for i in cls:
            val = functional(generators[i])
            assert abs(val - psi[cls_idx]) < tolerance, \
                f"Factorization failed: φ(gen_{i}) = {val} ≠ ψ(class_{cls_idx}) = {psi[cls_idx]}"

    return psi, classes


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    # Example: 5 generators in R^3 with some duplicates
    generators = [
        np.array([1.0, 2.0, 3.0]),
        np.array([1.0, 2.0, 3.0]),  # duplicate of 0
        np.array([4.0, 5.0, 6.0]),
        np.array([4.0, 5.0, 6.0]),  # duplicate of 2
        np.array([7.0, 8.0, 9.0]),
    ]

    print("=== Certified Barcode Reconstruction ===")
    barcode, classes = certified_barcode_reconstruction(generators)
    print(f"Barcode: {barcode}")
    print(f"Classes: {classes}")
    print()

    print("=== Universal Factorization ===")
    phi = lambda x: x[0]  # first coordinate projection
    psi, classes = universal_factorization(generators, phi)
    print(f"ψ values: {psi}")
    print(f"Classes: {classes}")
    print()

    print("=== Stability Analysis ===")
    results = stability_analysis(generators, phi)
    for eps, mv, av, bc in zip(
        results['epsilon'], results['max_violation'],
        results['avg_violation'], results['barcode_change']
    ):
        print(f"  ε={eps:.2f}: max_violation={mv:.6f}, "
              f"avg_violation={av:.6f}, barcode_change={bc:.1f}")
