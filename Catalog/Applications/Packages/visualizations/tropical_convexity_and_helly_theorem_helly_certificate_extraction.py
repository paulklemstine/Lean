"""
Tropical Convexity Algorithms

Implementations of:
1. Bellman-Ford feasibility checker for difference constraints
2. Negative cycle extraction
3. Helly certificate computation
4. Tropical halfspace membership
5. Tropical convex hull computation
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass


@dataclass
class DiffConstraint:
    """A difference constraint: x[src] - x[tgt] <= weight."""
    src: int
    tgt: int
    weight: float

    def is_satisfied(self, x: np.ndarray) -> bool:
        """Check if x satisfies this constraint."""
        return x[self.src] - x[self.tgt] <= self.weight + 1e-12

    def __repr__(self) -> str:
        return f"x[{self.src}] - x[{self.tgt}] ≤ {self.weight}"


def bellman_ford(n: int, constraints: List[DiffConstraint]) -> Tuple[bool, Optional[np.ndarray], Optional[List[DiffConstraint]]]:
    """
    Bellman-Ford algorithm for difference constraint feasibility.

    Args:
        n: Number of variables (vertices 0..n-1)
        constraints: List of difference constraints

    Returns:
        (feasible, solution, negative_cycle)
        - If feasible: (True, x, None) where x satisfies all constraints
        - If infeasible: (False, None, cycle) where cycle is a negative-weight cycle

    Time complexity: O(n * m) where m = len(constraints)
    Space complexity: O(n + m)

    Example:
        >>> constraints = [DiffConstraint(0, 1, 3), DiffConstraint(1, 2, -1), DiffConstraint(2, 0, 2)]
        >>> feasible, x, _ = bellman_ford(3, constraints)
        >>> print(feasible)
        True
    """
    # Initialize distances (potentials)
    dist = np.zeros(n)
    parent = [-1] * n
    parent_edge = [None] * n

    # Relax edges n-1 times
    for iteration in range(n - 1):
        updated = False
        for c in constraints:
            if dist[c.src] > dist[c.tgt] + c.weight + 1e-12:
                dist[c.src] = dist[c.tgt] + c.weight
                parent[c.src] = c.tgt
                parent_edge[c.src] = c
                updated = True
        if not updated:
            break

    # Check for negative cycles (one more relaxation)
    for c in constraints:
        if dist[c.src] > dist[c.tgt] + c.weight + 1e-12:
            # Negative cycle detected — extract it
            cycle = _extract_negative_cycle(n, constraints, c.src, parent, parent_edge)
            return False, None, cycle

    return True, dist, None


def _extract_negative_cycle(
    n: int,
    constraints: List[DiffConstraint],
    start: int,
    parent: List[int],
    parent_edge: List[Optional[DiffConstraint]]
) -> List[DiffConstraint]:
    """Extract a negative cycle from Bellman-Ford parent pointers."""
    # Walk back n steps to ensure we're in the cycle
    v = start
    for _ in range(n):
        v = parent[v]

    # Now v is in the cycle — trace it
    cycle = []
    u = v
    while True:
        cycle.append(parent_edge[u])
        u = parent[u]
        if u == v:
            break

    cycle.reverse()
    return cycle


def helly_certificate(
    n: int,
    constraints: List[DiffConstraint],
    helly_number: Optional[int] = None
) -> Tuple[bool, Optional[np.ndarray], Optional[List[DiffConstraint]]]:
    """
    Find a Helly certificate: either a feasible solution or a small
    infeasibility witness.

    Args:
        n: Number of variables
        constraints: List of difference constraints
        helly_number: Maximum certificate size (default: n)

    Returns:
        (feasible, solution, certificate)
        - If feasible: (True, x, None)
        - If infeasible: (False, None, minimal_infeasible_subset)

    The minimal infeasible subset has size ≤ helly_number.

    Example:
        >>> constraints = [DiffConstraint(0, 1, 2), DiffConstraint(1, 0, -3)]
        >>> feasible, _, cert = helly_certificate(2, constraints)
        >>> print(feasible, len(cert))
        False 2
    """
    if helly_number is None:
        helly_number = n

    feasible, x, cycle = bellman_ford(n, constraints)
    if feasible:
        return True, x, None

    # We have a negative cycle — minimize it
    if cycle is not None and len(cycle) <= helly_number:
        return False, None, cycle

    # Greedy minimization: remove constraints one at a time
    remaining = list(constraints)
    for c in constraints:
        test = [r for r in remaining if r is not c]
        feasible_test, _, _ = bellman_ford(n, test)
        if not feasible_test:
            remaining = test

    return False, None, remaining


def tropical_min(a: np.ndarray, x: np.ndarray) -> float:
    """Compute tropMin(a, x) = min_i (a_i + x_i)."""
    return np.min(a + x)


def in_tropical_halfspace(a: np.ndarray, b: np.ndarray, x: np.ndarray) -> bool:
    """Check if x is in the tropical halfspace {x | tropMin(a,x) ≤ tropMin(b,x)}."""
    return tropical_min(a, x) <= tropical_min(b, x) + 1e-12


def tropical_combination(c1: float, x: np.ndarray, c2: float, y: np.ndarray) -> np.ndarray:
    """Compute the tropical combination: coordinatewise min(c1+x, c2+y)."""
    return np.minimum(c1 + x, c2 + y)


def tropical_convex_hull_2d(points: List[np.ndarray], n_samples: int = 1000) -> List[np.ndarray]:
    """
    Approximate the tropical convex hull of a set of points via random sampling.

    Args:
        points: List of points in R^n
        n_samples: Number of random combinations to generate

    Returns:
        List of sampled points in the tropical convex hull.

    Note: This is an approximation; the exact tropical convex hull
    is more complex to compute.

    Example:
        >>> pts = [np.array([0.0, 0.0]), np.array([1.0, 0.0]), np.array([0.0, 1.0])]
        >>> hull = tropical_convex_hull_2d(pts, 100)
        >>> len(hull)
        100
    """
    hull_points = list(points)
    for _ in range(n_samples):
        # Pick two random points
        i, j = np.random.choice(len(points), 2, replace=True)
        c1, c2 = np.random.randn(2) * 3
        combo = tropical_combination(c1, points[i], c2, points[j])
        hull_points.append(combo)
    return hull_points


def verify_cycle_certificate(cycle: List[DiffConstraint]) -> Tuple[bool, float]:
    """
    Independently verify that a list of constraints forms a negative cycle.

    Args:
        cycle: List of difference constraints

    Returns:
        (is_valid_cycle, total_weight)
        is_valid_cycle is True iff the constraints chain properly and
        the total weight is negative.

    Example:
        >>> cycle = [DiffConstraint(0, 1, 2), DiffConstraint(1, 0, -3)]
        >>> valid, weight = verify_cycle_certificate(cycle)
        >>> print(valid, weight)
        True -1.0
    """
    if not cycle:
        return False, 0.0

    # Check chaining: edge direction is tgt→src (constraint x[src]-x[tgt]≤w
    # means there's a directed edge from tgt to src with weight w)
    for i in range(len(cycle) - 1):
        if cycle[i].src != cycle[i + 1].tgt:
            return False, 0.0

    # Check cycle closure
    if cycle[-1].src != cycle[0].tgt:
        return False, 0.0

    total_weight = sum(c.weight for c in cycle)
    return total_weight < -1e-12, total_weight


if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Test Suite")
    print("=" * 60)

    # Test 1: Feasible system
    print("\nTest 1: Feasible system")
    constraints = [
        DiffConstraint(0, 1, 3),
        DiffConstraint(1, 2, -1),
        DiffConstraint(2, 0, 2),
    ]
    feasible, x, cycle = bellman_ford(3, constraints)
    print(f"  Feasible: {feasible}")
    if x is not None:
        print(f"  Solution: {x}")
        for c in constraints:
            print(f"    {c}: x[{c.src}]-x[{c.tgt}] = {x[c.src]-x[c.tgt]:.2f} ≤ {c.weight} {'✓' if c.is_satisfied(x) else '✗'}")

    # Test 2: Infeasible system
    print("\nTest 2: Infeasible system")
    constraints = [
        DiffConstraint(0, 1, 2),
        DiffConstraint(1, 2, 1),
        DiffConstraint(2, 0, -4),
    ]
    feasible, x, cycle = bellman_ford(3, constraints)
    print(f"  Feasible: {feasible}")
    if cycle:
        valid, weight = verify_cycle_certificate(cycle)
        print(f"  Negative cycle: {[str(c) for c in cycle]}")
        print(f"  Valid certificate: {valid}, weight = {weight}")

    # Test 3: Helly certificate
    print("\nTest 3: Helly certificate extraction")
    constraints = [
        DiffConstraint(0, 1, 2),
        DiffConstraint(1, 2, 1),
        DiffConstraint(2, 0, -4),
        DiffConstraint(0, 3, 10),
        DiffConstraint(3, 4, 10),
        DiffConstraint(4, 0, 10),
    ]
    feasible, x, cert = helly_certificate(5, constraints)
    print(f"  Feasible: {feasible}")
    if cert:
        print(f"  Certificate size: {len(cert)} (≤ n = 5)")
        print(f"  Certificate: {[str(c) for c in cert]}")
        valid, weight = verify_cycle_certificate(cert)
        print(f"  Valid: {valid}, weight = {weight}")
