"""
Stone Duality for Neural Networks: Algorithms
================================================
Implements the core algorithms for computing activation Boolean algebras,
Stone duality maps, and related quantities for ReLU neural networks.
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional, FrozenSet
from dataclasses import dataclass
from itertools import product
from math import comb


@dataclass
class Hyperplane:
    """Hyperplane w · x + b = 0 in R^n."""
    w: np.ndarray  # weight vector (n,)
    b: float       # bias

    def eval(self, x: np.ndarray) -> float:
        """Evaluate the affine function w · x + b."""
        return float(np.dot(self.w, x) + self.b)

    def sign(self, x: np.ndarray) -> bool:
        """True if x is on the positive side."""
        return self.eval(x) > 0


@dataclass
class HyperplaneArrangement:
    """A collection of m hyperplanes in R^n.

    Attributes:
        hyperplanes: List of Hyperplane objects
        n: dimension of the ambient space
        m: number of hyperplanes
    """
    hyperplanes: List[Hyperplane]

    @property
    def n(self) -> int:
        return self.hyperplanes[0].w.shape[0] if self.hyperplanes else 0

    @property
    def m(self) -> int:
        return len(self.hyperplanes)

    def activation_pattern(self, x: np.ndarray) -> Tuple[bool, ...]:
        """Compute the activation pattern σ(x) ∈ {0,1}^m.

        The Stone dual map: R^n → {0,1}^m.

        Time complexity: O(nm)
        """
        return tuple(h.sign(x) for h in self.hyperplanes)

    def enumerate_regions(self, n_samples: int = 100000,
                          bounds: float = 10.0) -> Dict[Tuple[bool, ...], int]:
        """Enumerate realized activation regions by random sampling.

        Returns a dict mapping activation patterns to sample counts.

        Time complexity: O(n_samples * n * m)
        Space complexity: O(2^m) worst case for the pattern dict
        """
        regions: Dict[Tuple[bool, ...], int] = {}
        for _ in range(n_samples):
            x = np.random.uniform(-bounds, bounds, size=self.n)
            p = self.activation_pattern(x)
            regions[p] = regions.get(p, 0) + 1
        return regions

    def zaslavsky_bound(self) -> int:
        """Compute the Zaslavsky upper bound on number of regions.

        For m hyperplanes in R^n: sum_{k=0}^{n} C(m, k).

        Time complexity: O(n)
        """
        return sum(comb(self.m, k) for k in range(self.n + 1))


def compute_activation_boolean_algebra(
    arr: HyperplaneArrangement,
    n_samples: int = 100000
) -> Dict[str, object]:
    """Compute the activation Boolean algebra of a hyperplane arrangement.

    Algorithm:
    1. Sample random points to discover realized activation patterns
    2. The Boolean algebra = powerset of realized patterns
    3. Each element is a union of activation regions

    Returns:
        Dictionary with:
        - 'atoms': set of realized patterns
        - 'n_atoms': number of atoms
        - 'algebra_size': 2^n_atoms
        - 'zaslavsky_bound': theoretical upper bound
        - 'exponential_bound': 2^m

    Time complexity: O(n_samples * n * m + 2^m) for enumeration
    Space complexity: O(2^m) for the pattern dictionary
    """
    regions = arr.enumerate_regions(n_samples)
    atoms = set(regions.keys())

    return {
        'atoms': atoms,
        'n_atoms': len(atoms),
        'algebra_size': 2 ** len(atoms),
        'zaslavsky_bound': arr.zaslavsky_bound(),
        'exponential_bound': 2 ** arr.m,
        'region_samples': regions,
    }


def stone_dual_map(
    arr: HyperplaneArrangement,
    points: np.ndarray
) -> np.ndarray:
    """Compute the Stone dual map for a batch of points.

    Maps each point x ∈ R^n to its activation pattern σ(x) ∈ {0,1}^m.

    Args:
        arr: hyperplane arrangement
        points: (N, n) array of N points in R^n

    Returns:
        (N, m) boolean array of activation patterns

    Time complexity: O(N * n * m)
    """
    N = points.shape[0]
    m = arr.m
    patterns = np.zeros((N, m), dtype=bool)
    for j, h in enumerate(arr.hyperplanes):
        vals = points @ h.w + h.b
        patterns[:, j] = vals > 0
    return patterns


def verify_tropical_equality(
    W: np.ndarray,
    bias: np.ndarray,
    readout: np.ndarray,
    c: float,
    x: np.ndarray
) -> Tuple[float, float, bool]:
    """Verify that ReLU network = tropical affine on each region.

    For a single-layer ReLU network with readout:
      f(x) = c + sum_i readout_i * max(W_i · x + b_i, 0)

    On the activation region of x, this equals the tropical affine function:
      g_σ(x) = c + sum_{i: σ_i=True} readout_i * (W_i · x + b_i)

    Returns:
        (relu_value, tropical_value, are_equal)

    Time complexity: O(n * m)
    """
    pre = W @ x + bias
    relu_out = np.maximum(pre, 0)
    relu_val = c + np.dot(readout, relu_out)

    # Compute tropical value using activation pattern
    pattern = pre > 0
    tropical_val = c + sum(
        readout[i] * pre[i] for i in range(len(pre)) if pattern[i]
    )

    return relu_val, tropical_val, np.isclose(relu_val, tropical_val)


def shattering_test(
    arr: HyperplaneArrangement,
    points: List[np.ndarray]
) -> Tuple[bool, int]:
    """Test if the arrangement hypothesis class shatters a set of points.

    The hypothesis class consists of all functions x ↦ (σ(x) ∈ P)
    for subsets P of activation patterns. A set S is shattered if
    every labeling f: S → {0,1} is realized by some P.

    Returns:
        (is_shattered, n_dichotomies)

    Time complexity: O(|S| * n * m + 2^(n_distinct_patterns))
    """
    patterns = [arr.activation_pattern(x) for x in points]
    distinct = list(set(patterns))

    # If patterns are not all distinct, S cannot be shattered
    if len(distinct) < len(points):
        # Find which points share a pattern
        for i in range(len(points)):
            for j in range(i + 1, len(points)):
                if patterns[i] == patterns[j]:
                    return False, 0

    # Count distinct dichotomies
    n_points = len(points)
    dichotomies = set()
    for subset_mask in range(2 ** len(distinct)):
        P = set()
        for k in range(len(distinct)):
            if subset_mask & (1 << k):
                P.add(distinct[k])
        labeling = tuple(patterns[i] in P for i in range(n_points))
        dichotomies.add(labeling)

    is_shattered = len(dichotomies) == 2 ** n_points
    return is_shattered, len(dichotomies)


def compute_vc_dimension_bound(
    arr: HyperplaneArrangement,
    max_test_size: int = 8,
    n_trials: int = 100
) -> int:
    """Estimate an upper bound on the VC dimension of an arrangement
    hypothesis class by random sampling.

    Tries to find the largest shattered set.

    Returns:
        Lower bound on VC dimension (largest shattered set found)

    Time complexity: O(n_trials * max_test_size * 2^max_test_size * n * m)
    """
    best = 0
    for size in range(1, max_test_size + 1):
        found = False
        for _ in range(n_trials):
            points = [np.random.uniform(-5, 5, size=arr.n)
                      for _ in range(size)]
            shattered, _ = shattering_test(arr, points)
            if shattered:
                found = True
                best = max(best, size)
                break
        if not found:
            break
    return best


# Example usage
if __name__ == "__main__":
    np.random.seed(42)

    # Create a hyperplane arrangement
    n, m = 2, 4
    hyperplanes = [Hyperplane(np.random.randn(n), np.random.randn())
                   for _ in range(m)]
    arr = HyperplaneArrangement(hyperplanes)

    # Compute activation Boolean algebra
    result = compute_activation_boolean_algebra(arr)
    print(f"Hyperplane arrangement: {m} hyperplanes in R^{n}")
    print(f"Number of atoms: {result['n_atoms']}")
    print(f"Boolean algebra size: {result['algebra_size']}")
    print(f"Zaslavsky bound: {result['zaslavsky_bound']}")
    print(f"Exponential bound: {result['exponential_bound']}")

    # Stone dual map
    points = np.random.randn(10, n)
    patterns = stone_dual_map(arr, points)
    print(f"\nStone dual map on 10 random points:")
    for i in range(min(5, len(points))):
        print(f"  x = {points[i]} -> σ = {patterns[i]}")

    # Verify tropical equality
    W = np.random.randn(m, n)
    bias = np.random.randn(m)
    readout = np.random.randn(m)
    x = np.random.randn(n)
    relu_val, trop_val, match = verify_tropical_equality(W, bias, readout, 0.0, x)
    print(f"\nTropical equality: ReLU = {relu_val:.4f}, tropical = {trop_val:.4f}, match = {match}")

    # VC dimension
    vc = compute_vc_dimension_bound(arr, max_test_size=6)
    print(f"\nVC dimension lower bound: {vc}")
    print(f"Theoretical bound (2^m): {2**m}")
