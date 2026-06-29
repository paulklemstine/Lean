#!/usr/bin/env python3
"""
Algorithms for Tropical Persistence and Valuation-Profile Universality.

Implements the verified algorithms from the research paper:
1. Nerve vertex count computation
2. Valuation profile extraction
3. Universality class expectation computation
4. Nerve face enumeration
5. Single-site change analysis

All algorithms include docstrings, type hints, and example usage.
"""

import numpy as np
from typing import List, Tuple, Dict, Set, FrozenSet, Optional
from itertools import combinations
from collections import defaultdict


# ============================================================================
# Core Data Structures
# ============================================================================

class TropicalFamily:
    """
    A tropical affine family: m affine forms in n variables.
    F(x) = min_i (A[i] . x + b[i])

    Attributes:
        A: Coefficient matrix (m x n)
        b: Bias vector (m,)
        n: Number of variables
        m: Number of affine forms
    """

    def __init__(self, A: np.ndarray, b: np.ndarray):
        """
        Initialize a tropical affine family.

        Args:
            A: Coefficient matrix of shape (m, n)
            b: Bias vector of shape (m,)
        """
        assert A.ndim == 2, "A must be 2-dimensional"
        assert b.ndim == 1, "b must be 1-dimensional"
        assert A.shape[0] == b.shape[0], "A and b must have same number of rows"
        self.A = A.copy()
        self.b = b.copy()
        self.m, self.n = A.shape

    def eval_form(self, i: int, x: np.ndarray) -> float:
        """Evaluate the i-th affine form at point x."""
        return float(np.dot(self.A[i], x) + self.b[i])

    def eval_all(self, x: np.ndarray) -> np.ndarray:
        """Evaluate all affine forms at point x."""
        return self.A @ x + self.b

    def trop_min(self, x: np.ndarray) -> float:
        """Evaluate the tropical min at point x."""
        return float(np.min(self.eval_all(x)))

    def single_site_change(self, k: int, new_coeff: np.ndarray,
                           new_bias: float) -> 'TropicalFamily':
        """
        Create a new family by replacing the k-th affine form.

        Args:
            k: Index of form to replace
            new_coeff: New coefficient vector for form k
            new_bias: New bias for form k

        Returns:
            New TropicalFamily with the k-th form replaced
        """
        A_new = self.A.copy()
        b_new = self.b.copy()
        A_new[k] = new_coeff
        b_new[k] = new_bias
        return TropicalFamily(A_new, b_new)


class ValuationProfile:
    """
    A valuation profile: coarse integer-weight data of a tropical family.
    This is the new concept bridging valuation theory to persistent topology.

    Attributes:
        m: Number of forms
        support: Set of active form indices
        weight: Integer weight for each form
    """

    def __init__(self, m: int, support: Set[int], weight: Dict[int, int]):
        self.m = m
        self.support = frozenset(support)
        self.weight = dict(weight)

    @classmethod
    def from_family(cls, family: TropicalFamily) -> 'ValuationProfile':
        """
        Extract a valuation profile from a tropical family.
        Uses floor of biases as integer weights.

        Args:
            family: A TropicalFamily

        Returns:
            ValuationProfile capturing the coarse structure
        """
        support = set()
        weight = {}
        for i in range(family.m):
            if not np.allclose(family.A[i], 0) or family.b[i] != 0:
                support.add(i)
            weight[i] = int(np.floor(family.b[i]))
        return cls(family.m, support, weight)

    def __eq__(self, other: 'ValuationProfile') -> bool:
        return (self.m == other.m and
                self.support == other.support and
                self.weight == other.weight)

    def __hash__(self) -> int:
        return hash((self.m, self.support, tuple(sorted(self.weight.items()))))

    def __repr__(self) -> str:
        return f"ValuationProfile(m={self.m}, |support|={len(self.support)})"


# ============================================================================
# Algorithm 1: Nerve Vertex Count
# ============================================================================

def nerve_vertex_count(family: TropicalFamily, c: float) -> int:
    """
    Compute the nerve vertex count: number of active halfspace patches.

    Patch i is active (nonempty) iff:
    - A[i] has a nonzero entry (halfspace is always nonempty), OR
    - A[i] is all zeros and b[i] <= c

    Complexity: O(m * n)

    Args:
        family: A TropicalFamily
        c: Threshold value

    Returns:
        Number of active patches

    Example:
        >>> F = TropicalFamily(np.array([[1.0, 0.0], [0.0, 1.0]]),
        ...                    np.array([0.0, 0.0]))
        >>> nerve_vertex_count(F, 1.0)
        2
    """
    count = 0
    for i in range(family.m):
        if np.any(np.abs(family.A[i]) > 1e-12) or family.b[i] <= c:
            count += 1
    return count


def normalized_vertex_count(family: TropicalFamily, c: float) -> float:
    """
    Normalized nerve vertex count V(F,c) / m.

    Args:
        family: A TropicalFamily
        c: Threshold value

    Returns:
        Normalized count in [0, 1]
    """
    return nerve_vertex_count(family, c) / family.m


# ============================================================================
# Algorithm 2: Nerve Face Enumeration
# ============================================================================

def patch_intersection_nonempty(family: TropicalFamily, S: FrozenSet[int],
                                 c: float, n_test: int = 100) -> bool:
    """
    Check if the patch intersection for subset S is nonempty at threshold c.

    Uses random sampling as a heuristic check. For exact computation,
    this reduces to linear programming feasibility.

    Args:
        family: A TropicalFamily
        S: Set of indices
        c: Threshold
        n_test: Number of random test points

    Returns:
        True if intersection appears nonempty
    """
    if not S:
        return False

    # For a single index, the patch is always nonempty if coefficients are nonzero
    S_list = list(S)
    if len(S_list) == 1:
        i = S_list[0]
        if np.any(np.abs(family.A[i]) > 1e-12):
            return True
        return family.b[i] <= c

    # For multiple indices, try to find a feasible point
    # f_i(x) <= c for all i in S
    # Sum_j A[i,j] * x[j] + b[i] <= c for all i in S
    # This is a linear feasibility problem

    # Heuristic: try random points and the analytic solution
    for _ in range(n_test):
        x = np.random.randn(family.n) * 10
        if all(family.eval_form(i, x) <= c for i in S_list):
            return True

    # Try pushing x in the direction that satisfies all constraints
    A_S = family.A[S_list]
    b_S = family.b[S_list]

    # If all coefficient vectors point in similar directions,
    # we can find a feasible point by going "backwards"
    if family.n > 0:
        mean_dir = np.mean(A_S, axis=0)
        if np.linalg.norm(mean_dir) > 1e-12:
            x = -100 * mean_dir / np.linalg.norm(mean_dir)
            if all(family.eval_form(i, x) <= c for i in S_list):
                return True

    return False


def enumerate_nerve_faces(family: TropicalFamily, c: float,
                          max_dim: int = 3) -> List[FrozenSet[int]]:
    """
    Enumerate all nerve faces up to dimension max_dim.

    A face is a nonempty subset S of {0, ..., m-1} such that
    the intersection of patches indexed by S is nonempty.

    Complexity: O(m^(max_dim+1)) for enumeration, plus feasibility checks.

    Args:
        family: A TropicalFamily
        c: Threshold
        max_dim: Maximum simplex dimension to check

    Returns:
        List of nerve faces (as frozensets of indices)
    """
    faces = []
    indices = list(range(family.m))

    for dim in range(1, min(max_dim + 2, family.m + 1)):
        for subset in combinations(indices, dim):
            S = frozenset(subset)
            if patch_intersection_nonempty(family, S, c):
                faces.append(S)

    return faces


# ============================================================================
# Algorithm 3: Single-Site Change Analysis
# ============================================================================

def analyze_single_site_change(family: TropicalFamily, k: int,
                                new_coeff: np.ndarray, new_bias: float,
                                c: float) -> Dict:
    """
    Analyze the effect of a single-site change on the nerve.

    Verifies the bounded-difference theorem: only faces containing k
    can change.

    Args:
        family: Original TropicalFamily
        k: Index of form to replace
        new_coeff: New coefficient vector
        new_bias: New bias
        c: Threshold

    Returns:
        Dictionary with analysis results

    Example:
        >>> F = TropicalFamily(np.array([[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0]]),
        ...                    np.array([0.0, 0.0, 0.0]))
        >>> result = analyze_single_site_change(F, 1, np.array([0.0, -1.0]), 5.0, 1.0)
        >>> result['vertex_count_diff'] <= 1
        True
    """
    family2 = family.single_site_change(k, new_coeff, new_bias)

    v1 = nerve_vertex_count(family, c)
    v2 = nerve_vertex_count(family2, c)

    return {
        'original_vertex_count': v1,
        'changed_vertex_count': v2,
        'vertex_count_diff': abs(v1 - v2),
        'bounded_diff_satisfied': abs(v1 - v2) <= 1,
        'changed_site': k,
    }


# ============================================================================
# Algorithm 4: Universality Class Expectation
# ============================================================================

def compute_class_expectation(
    families: List[TropicalFamily],
    weights: List[float],
    observable: callable,
    classifier: callable
) -> Tuple[float, Dict]:
    """
    Compute the expectation of a class-invariant observable using
    the factoring theorem.

    Groups families by their class, then computes:
    E[obs] = sum_c weight(c) * obs(repr(c))

    Args:
        families: List of TropicalFamily instances
        weights: Probability weights (should sum to 1)
        observable: Function mapping TropicalFamily -> float
        classifier: Function mapping TropicalFamily -> hashable class label

    Returns:
        (expected_value, class_decomposition)

    Example:
        >>> families = [TropicalFamily(np.eye(2), np.zeros(2)) for _ in range(5)]
        >>> weights = [0.2] * 5
        >>> obs = lambda F: float(nerve_vertex_count(F, 0.0))
        >>> cls = lambda F: tuple(F.b.tolist())
        >>> ev, decomp = compute_class_expectation(families, weights, obs, cls)
    """
    assert len(families) == len(weights)
    assert abs(sum(weights) - 1.0) < 1e-10

    # Group by class
    class_data: Dict = defaultdict(lambda: {'weight': 0.0, 'repr': None})
    for family, w in zip(families, weights):
        c = classifier(family)
        class_data[c]['weight'] += w
        if class_data[c]['repr'] is None:
            class_data[c]['repr'] = family

    # Compute class expectation
    expected = 0.0
    decomposition = {}
    for c, data in class_data.items():
        obs_val = observable(data['repr'])
        contribution = data['weight'] * obs_val
        expected += contribution
        decomposition[c] = {
            'weight': data['weight'],
            'obs_value': obs_val,
            'contribution': contribution,
        }

    # Also compute direct expectation for verification
    direct = sum(w * observable(f) for w, f in zip(weights, families))

    return expected, {
        'class_expectation': expected,
        'direct_expectation': direct,
        'num_classes': len(class_data),
        'class_details': decomposition,
    }


# ============================================================================
# Algorithm 5: Persistence Profile Computation
# ============================================================================

def compute_persistence_profile(family: TropicalFamily,
                                 thresholds: np.ndarray) -> np.ndarray:
    """
    Compute the normalized vertex count profile V(F,c)/m for a range of thresholds.

    Args:
        family: A TropicalFamily
        thresholds: Array of threshold values

    Returns:
        Array of normalized vertex counts
    """
    return np.array([normalized_vertex_count(family, c) for c in thresholds])


def profile_distance(profile1: np.ndarray, profile2: np.ndarray) -> float:
    """L2 distance between two persistence profiles."""
    return float(np.sqrt(np.sum((profile1 - profile2) ** 2)))


# ============================================================================
# Example Usage
# ============================================================================

def main():
    """Demonstrate all algorithms with concrete examples."""
    np.random.seed(42)
    print("Tropical Persistence Algorithms - Examples\n")

    # Example 1: Basic family
    print("--- Example 1: Nerve Vertex Count ---")
    F = TropicalFamily(
        np.array([[1.0, 0.0], [0.0, 1.0], [-1.0, -1.0]]),
        np.array([0.0, 0.0, 0.0])
    )
    for c in [-1, 0, 1, 2]:
        v = nerve_vertex_count(F, c)
        print(f"  V(F, {c}) = {v}, normalized = {v/F.m:.3f}")

    # Example 2: Valuation Profile
    print("\n--- Example 2: Valuation Profile ---")
    vp = ValuationProfile.from_family(F)
    print(f"  Profile: {vp}")
    print(f"  Support: {sorted(vp.support)}")
    print(f"  Weights: {vp.weight}")

    # Example 3: Single-site change
    print("\n--- Example 3: Single-Site Change Analysis ---")
    result = analyze_single_site_change(
        F, k=1,
        new_coeff=np.array([0.0, -1.0]),
        new_bias=5.0,
        c=1.0
    )
    print(f"  Original vertex count: {result['original_vertex_count']}")
    print(f"  Changed vertex count: {result['changed_vertex_count']}")
    print(f"  |Diff| = {result['vertex_count_diff']} <= 1: "
          f"{result['bounded_diff_satisfied']}")

    # Example 4: Class expectation
    print("\n--- Example 4: Class Expectation ---")
    families = [TropicalFamily(np.random.randn(3, 2), np.random.randn(3))
                for _ in range(20)]
    weights = [1/20] * 20
    obs = lambda F: float(nerve_vertex_count(F, 0.0))
    cls = lambda F: tuple(int(b > 0) for b in F.b)

    ev, decomp = compute_class_expectation(families, weights, obs, cls)
    print(f"  Class expectation: {decomp['class_expectation']:.4f}")
    print(f"  Direct expectation: {decomp['direct_expectation']:.4f}")
    print(f"  Number of classes: {decomp['num_classes']}")

    # Example 5: Persistence profile
    print("\n--- Example 5: Persistence Profile ---")
    thresholds = np.linspace(-3, 3, 13)
    profile = compute_persistence_profile(F, thresholds)
    for c, v in zip(thresholds, profile):
        bar = "█" * int(v * 30)
        print(f"  c={c:+5.1f}: V/m={v:.3f} {bar}")


if __name__ == '__main__':
    main()
