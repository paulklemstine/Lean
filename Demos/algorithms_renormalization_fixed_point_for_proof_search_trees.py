#!/usr/bin/env python3
"""
Algorithms for Proof Search Tree Renormalization

Implements the core algorithms from the research paper:
1. Bounded rooted tree enumeration
2. Local profile computation from proof search trees
3. Renormalization operator construction
4. Fixed-point iteration with convergence guarantees
5. Universality class detection
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set, Any
from dataclasses import dataclass
from collections import Counter


# ============================================================================
# Data Structures
# ============================================================================

@dataclass
class TreeNode:
    """A node in a proof search tree."""
    children: List['TreeNode']
    label: Optional[str] = None
    depth: int = 0

    @property
    def branching(self) -> int:
        return len(self.children)

    def height(self) -> int:
        if not self.children:
            return 0
        return 1 + max(c.height() for c in self.children)


@dataclass
class NeighborhoodType:
    """
    Represents a rooted neighborhood isomorphism class.

    Encoded as a tuple: (branching, [child_types])
    where child_types are recursively NeighborhoodTypes.
    """
    branching: int
    child_types: Tuple  # tuple of NeighborhoodType encodings

    def to_tuple(self) -> tuple:
        """Convert to a hashable tuple representation."""
        return (self.branching, tuple(ct.to_tuple() if isinstance(ct, NeighborhoodType) else ct
                                      for ct in self.child_types))


# ============================================================================
# Algorithm 1: Enumerate Bounded Rooted Trees
# ============================================================================

def enumerate_bounded_trees(B: int, r: int) -> List[tuple]:
    """
    Enumerate all ordered rooted trees with branching ≤ B and height ≤ r.

    Returns a list of canonical tuple representations.

    Time complexity: O(C(B, r)) where C is the tree count recurrence.
    Space complexity: O(C(B, r))

    >>> len(enumerate_bounded_trees(2, 0))
    1
    >>> len(enumerate_bounded_trees(2, 1))
    3
    >>> len(enumerate_bounded_trees(2, 2))
    13
    """
    if r == 0:
        return [()]  # Single leaf

    # Get all trees of height ≤ r-1
    subtrees = enumerate_bounded_trees(B, r - 1)

    result = []
    for k in range(B + 1):
        # All ways to assign k children from subtree types
        # (ordered, with repetition)
        import itertools
        for children in itertools.product(subtrees, repeat=k):
            result.append((k, children))

    return result


def count_bounded_trees(B: int, r: int) -> int:
    """
    Count bounded rooted trees without enumeration.

    C(B, 0) = 1
    C(B, r+1) = Σ_{k=0}^{B} C(B, r)^k

    Time complexity: O(r · B)
    Space complexity: O(1)
    """
    if r == 0:
        return 1
    prev = count_bounded_trees(B, r - 1)
    return sum(prev ** k for k in range(B + 1))


# ============================================================================
# Algorithm 2: Extract Local Profile from a Proof Search Tree
# ============================================================================

def extract_neighborhood(node: TreeNode, radius: int) -> tuple:
    """
    Extract the radius-r neighborhood of a node as a canonical tuple.

    Time complexity: O(B^r) where B is the branching bound.

    Args:
        node: The center node
        radius: Neighborhood radius

    Returns:
        Canonical tuple representation of the neighborhood type.
    """
    if radius == 0:
        return ()  # leaf type
    child_types = tuple(
        extract_neighborhood(c, radius - 1) for c in node.children
    )
    return (len(node.children), child_types)


def compute_local_profile(
    tree: TreeNode,
    radius: int,
    target_depth: Optional[int] = None
) -> Dict[tuple, float]:
    """
    Compute the empirical local profile distribution of a proof search tree.

    For each node at the target depth, extract its radius-r neighborhood
    and compute the frequency distribution over neighborhood types.

    Time complexity: O(|T| · B^r)
    Space complexity: O(C(B, r))

    Args:
        tree: Root of the proof search tree
        radius: Neighborhood radius
        target_depth: Depth at which to sample (None = use all nodes)

    Returns:
        Dictionary mapping neighborhood type tuples to frequencies.
    """
    # Collect all nodes at target depth
    nodes = []
    _collect_nodes(tree, target_depth, 0, nodes)

    if not nodes:
        return {}

    # Extract neighborhood types
    type_counts: Counter = Counter()
    for node in nodes:
        nbhd_type = extract_neighborhood(node, radius)
        type_counts[nbhd_type] += 1

    # Normalize to frequencies
    total = sum(type_counts.values())
    return {t: c / total for t, c in type_counts.items()}


def _collect_nodes(
    node: TreeNode, target_depth: Optional[int], current_depth: int,
    result: List[TreeNode]
) -> None:
    """Helper: collect nodes at a given depth."""
    if target_depth is None or current_depth == target_depth:
        result.append(node)
    if target_depth is None or current_depth < target_depth:
        for child in node.children:
            _collect_nodes(child, target_depth, current_depth + 1, result)


# ============================================================================
# Algorithm 3: Renormalization Operator
# ============================================================================

@dataclass
class RenormalizationOperator:
    """
    A renormalization operator on the local profile space.

    Models the map from depth-n profile to depth-(n+1) profile
    after entropy normalization.

    Attributes:
        matrix: Linear part of the affine operator
        offset: Translation part
        contraction_ratio: Verified contraction ratio K < 1
    """
    matrix: np.ndarray
    offset: np.ndarray
    contraction_ratio: float

    def __call__(self, profile: np.ndarray) -> np.ndarray:
        """Apply the operator to a profile vector."""
        return self.matrix @ profile + self.offset

    @property
    def dim(self) -> int:
        return self.matrix.shape[0]

    def verify_contraction(self, n_samples: int = 1000) -> float:
        """
        Empirically verify the contraction ratio by sampling random pairs.

        Returns the maximum observed contraction ratio.
        """
        max_ratio = 0.0
        rng = np.random.RandomState(42)
        for _ in range(n_samples):
            x = rng.randn(self.dim)
            y = rng.randn(self.dim)
            d_in = np.linalg.norm(x - y, ord=np.inf)
            d_out = np.linalg.norm(self(x) - self(y), ord=np.inf)
            if d_in > 1e-10:
                max_ratio = max(max_ratio, d_out / d_in)
        return max_ratio

    @classmethod
    def from_branching_law(
        cls, branching_probs: np.ndarray, entropy_scale: float
    ) -> 'RenormalizationOperator':
        """
        Construct a renormalization operator from a branching probability law.

        Args:
            branching_probs: Probability of having k children, k=0,...,B
            entropy_scale: Entropy normalization parameter

        Returns:
            RenormalizationOperator with verified contraction ratio.
        """
        B = len(branching_probs) - 1
        dim = sum(1 for _ in range(B + 1))  # Simplified: 1D per branching count

        # Construct transition matrix from branching law
        # The matrix models how neighborhood type frequencies evolve
        M = np.zeros((dim, dim))
        for i in range(dim):
            for j in range(dim):
                # Weight by branching probability and entropy normalization
                M[i, j] = branching_probs[j] * np.exp(-entropy_scale * abs(i - j))

        # Normalize rows
        row_sums = M.sum(axis=1, keepdims=True)
        M = M / np.maximum(row_sums, 1e-10)

        # Scale to ensure contraction
        K = entropy_scale / (1 + entropy_scale)  # Contraction ratio from entropy
        sigma = np.linalg.norm(M, ord=2)
        if sigma > 0:
            M = M * (K / sigma)

        offset = np.ones(dim) / dim * (1 - K)  # Drift toward uniform

        return cls(matrix=M, offset=offset, contraction_ratio=K)


# ============================================================================
# Algorithm 4: Fixed-Point Iteration
# ============================================================================

def fixed_point_iteration(
    operator: RenormalizationOperator,
    initial_profile: np.ndarray,
    tol: float = 1e-12,
    max_iter: int = 10000
) -> Tuple[np.ndarray, int, List[float]]:
    """
    Compute the fixed point of a renormalization operator by iteration.

    By the Banach fixed-point theorem (our Theorem B), this converges
    to the unique fixed point at rate K^n.

    Time complexity: O(dim^2 · n_iter)
    Space complexity: O(dim)

    Args:
        operator: The renormalization operator
        initial_profile: Starting profile μ₀
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        (fixed_point, n_iterations, distance_history)
    """
    mu = initial_profile.copy()
    distances = []

    for n in range(max_iter):
        mu_next = operator(mu)
        d = np.linalg.norm(mu_next - mu, ord=np.inf)
        distances.append(d)

        if d < tol:
            return mu_next, n + 1, distances

        mu = mu_next

    return mu, max_iter, distances


def compute_convergence_rate(distances: List[float]) -> float:
    """
    Estimate the contraction ratio from observed distances.

    Takes the median ratio of successive distances (robust to noise).
    """
    ratios = []
    for i in range(1, len(distances)):
        if distances[i - 1] > 1e-15:
            ratios.append(distances[i] / distances[i - 1])
    return float(np.median(ratios)) if ratios else 0.0


# ============================================================================
# Algorithm 5: Universality Class Detection
# ============================================================================

def detect_universality_class(
    operators: List[RenormalizationOperator],
    tol: float = 1e-6
) -> List[List[int]]:
    """
    Partition a set of renormalization operators into universality classes.

    Two operators belong to the same class if they have the same fixed point
    (within tolerance).

    Time complexity: O(n_ops · dim^2 · max_iter + n_ops^2 · dim)
    Space complexity: O(n_ops · dim)

    Args:
        operators: List of renormalization operators
        tol: Tolerance for fixed-point comparison

    Returns:
        List of lists of operator indices, grouped by universality class.
    """
    fixed_points = []
    for op in operators:
        initial = np.ones(op.dim) / op.dim
        fp, _, _ = fixed_point_iteration(op, initial)
        fixed_points.append(fp)

    # Cluster by fixed-point proximity
    n = len(operators)
    visited = set()
    classes = []

    for i in range(n):
        if i in visited:
            continue
        current_class = [i]
        visited.add(i)
        for j in range(i + 1, n):
            if j not in visited:
                if np.linalg.norm(fixed_points[i] - fixed_points[j], ord=np.inf) < tol:
                    current_class.append(j)
                    visited.add(j)
        classes.append(current_class)

    return classes


# ============================================================================
# Algorithm 6: Total Variation Bound Computation
# ============================================================================

def total_variation_bound(
    contraction_ratio: float, initial_displacement: float
) -> float:
    """
    Compute the total variation bound from Theorem D.

    Σ_n dist(R^n(μ₀), R^{n+1}(μ₀)) ≤ d₀ / (1 - K)

    Time complexity: O(1)

    Args:
        contraction_ratio: K < 1
        initial_displacement: dist(μ₀, R(μ₀))

    Returns:
        Upper bound on total variation of the orbit.
    """
    if contraction_ratio >= 1:
        return float('inf')
    return initial_displacement / (1 - contraction_ratio)


def steps_to_precision(
    contraction_ratio: float, initial_displacement: float, epsilon: float
) -> int:
    """
    Compute the number of steps needed to reach distance ε from the fixed point.

    dist(R^n(μ₀), μ*) ≤ K^n · d₀ / (1 - K)
    So n ≥ log(ε(1-K)/d₀) / log(K)

    Time complexity: O(1)
    """
    if contraction_ratio <= 0 or contraction_ratio >= 1:
        return -1
    if initial_displacement <= 0:
        return 0

    bound = epsilon * (1 - contraction_ratio) / initial_displacement
    if bound >= 1:
        return 0

    return int(np.ceil(np.log(bound) / np.log(contraction_ratio)))


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  ALGORITHMS FOR PROOF SEARCH RENORMALIZATION")
    print("=" * 60)

    # Example 1: Tree enumeration
    print("\n--- Tree Enumeration ---")
    for B in [1, 2, 3]:
        for r in [0, 1, 2, 3]:
            c = count_bounded_trees(B, r)
            print(f"  |BoundedRootedTree({B}, {r})| = {c}")

    # Example 2: Construct and iterate a renormalization operator
    print("\n--- Fixed-Point Iteration ---")
    branching_probs = np.array([0.1, 0.3, 0.4, 0.2])  # B = 3
    op = RenormalizationOperator.from_branching_law(branching_probs, entropy_scale=2.0)
    print(f"  Contraction ratio K = {op.contraction_ratio:.4f}")
    print(f"  Verified ratio = {op.verify_contraction():.4f}")

    initial = np.ones(op.dim) / op.dim
    fp, n_iter, dists = fixed_point_iteration(op, initial)
    print(f"  Fixed point found in {n_iter} iterations")
    print(f"  Fixed point: {fp}")
    print(f"  Estimated K: {compute_convergence_rate(dists):.4f}")

    # Example 3: Universality class detection
    print("\n--- Universality Class Detection ---")
    ops = [
        RenormalizationOperator.from_branching_law(
            np.array([0.1, 0.3, 0.4, 0.2]), entropy_scale=2.0
        ),
        RenormalizationOperator.from_branching_law(
            np.array([0.2, 0.3, 0.3, 0.2]), entropy_scale=2.0
        ),
        RenormalizationOperator.from_branching_law(
            np.array([0.1, 0.3, 0.4, 0.2]), entropy_scale=2.0  # same as first
        ),
    ]
    classes = detect_universality_class(ops)
    print(f"  {len(ops)} operators → {len(classes)} universality classes")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: operators {cls}")

    # Example 4: Convergence bounds
    print("\n--- Convergence Bounds (Theorem D) ---")
    K, d0 = 0.5, 1.0
    print(f"  K = {K}, d₀ = {d0}")
    print(f"  Total variation bound: {total_variation_bound(K, d0):.4f}")
    print(f"  Steps to 10⁻⁶: {steps_to_precision(K, d0, 1e-6)}")
    print(f"  Steps to 10⁻¹²: {steps_to_precision(K, d0, 1e-12)}")
