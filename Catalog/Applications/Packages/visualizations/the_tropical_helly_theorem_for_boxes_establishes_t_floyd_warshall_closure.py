#!/usr/bin/env python3
"""
Algorithms for Tropical Band Systems

Implements the core algorithms from the tropical band geometry theory:
1. Bellman-Ford feasibility detection
2. Floyd-Warshall closure distance computation
3. Canonical potential construction
4. Negative cycle extraction
5. Helly certificate computation for laminar families

All algorithms have documented time/space complexity.

Keywords: tropical geometry, difference constraints, shortest paths,
Bellman-Ford, Floyd-Warshall, graph potentials, certificate complexity
"""

import numpy as np
from typing import Optional, Tuple, List


def floyd_warshall_closure(slack: np.ndarray) -> Tuple[np.ndarray, bool]:
    """Compute shortest-path closure of the slack matrix.

    This is the tropical analogue of transitive closure for
    difference constraint systems.

    Args:
        slack: n×n matrix where slack[i,j] = weight of edge i→j

    Returns:
        (dist, has_neg_cycle):
            dist[i,j] = shortest path weight from i to j
            has_neg_cycle = True if a negative cycle exists

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = slack.shape[0]
    dist = slack.copy()
    for i in range(n):
        dist[i, i] = min(dist[i, i], 0.0)

    for k in range(n):
        for i in range(n):
            for j in range(n):
                via_k = dist[i, k] + dist[k, j]
                if via_k < dist[i, j]:
                    dist[i, j] = via_k

    has_neg_cycle = any(dist[i, i] < -1e-12 for i in range(n))
    return dist, has_neg_cycle


def canonical_potential(lower: np.ndarray, upper: np.ndarray,
                        slack: np.ndarray) -> Tuple[Optional[np.ndarray], bool]:
    """Construct the canonical feasible potential for a tropical band system.

    The canonical potential is defined as:
        x[i] = max_j (lower[j] - dist[j, i])
    where dist is the shortest-path closure of the slack matrix.

    This is the tightest feasible assignment that respects all lower bounds
    through the lens of shortest-path propagation.

    Args:
        lower: array of lower bounds
        upper: array of upper bounds
        slack: n×n slack matrix

    Returns:
        (potential, feasible):
            potential = canonical feasible point, or None if infeasible
            feasible = True if the system is feasible

    Time complexity: O(n³) (dominated by Floyd-Warshall)
    Space complexity: O(n²)

    References:
        Corresponds to Theorem 1 (tropBand_feasible_iff_closedBounds)
        in the Lean formalization.
    """
    n = len(lower)
    dist, has_neg_cycle = floyd_warshall_closure(slack)

    if has_neg_cycle:
        return None, False

    # Construct potential
    x = np.full(n, -np.inf)
    for i in range(n):
        for j in range(n):
            x[i] = max(x[i], lower[j] - dist[j, i])

    # Verify upper bounds
    for i in range(n):
        if x[i] > upper[i] + 1e-10:
            return None, False

    # Verify slack constraints
    for i in range(n):
        for j in range(n):
            if x[i] > x[j] + slack[i, j] + 1e-10:
                return None, False

    return x, True


def extract_negative_cycle(slack: np.ndarray) -> Optional[Tuple[List[int], float]]:
    """Extract a negative-weight cycle from the slack graph.

    Uses Floyd-Warshall with predecessor tracking to reconstruct
    the actual cycle path.

    Args:
        slack: n×n slack matrix

    Returns:
        (cycle, weight) if a negative cycle exists, None otherwise
        cycle = list of vertex indices forming the cycle
        weight = total weight of the cycle

    Time complexity: O(n³)
    Space complexity: O(n²)

    References:
        Certificate for Theorem infeasible_of_negCycle
    """
    n = slack.shape[0]
    dist = np.full((n, n), np.inf)
    pred = np.full((n, n), -1, dtype=int)

    for i in range(n):
        dist[i, i] = 0
        for j in range(n):
            if slack[i, j] < np.inf:
                if i != j or slack[i, j] < 0:
                    dist[i, j] = min(dist[i, j], slack[i, j])
                pred[i, j] = i

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i, k] + dist[k, j] < dist[i, j] - 1e-12:
                    dist[i, j] = dist[i, k] + dist[k, j]
                    pred[i, j] = pred[k, j]

    # Find negative cycle
    for i in range(n):
        if dist[i, i] < -1e-10:
            # Reconstruct
            cycle = [i]
            j = pred[i, i]
            seen = {i}
            while j not in seen and j >= 0:
                seen.add(j)
                cycle.append(j)
                j = pred[i, j]
            cycle.append(j if j >= 0 else i)
            cycle.reverse()

            weight = sum(slack[cycle[k], cycle[k+1]]
                        for k in range(len(cycle)-1))
            return cycle, weight

    return None


def bellman_ford_feasibility(lower: np.ndarray, upper: np.ndarray,
                              slack: np.ndarray) -> Tuple[Optional[np.ndarray], bool]:
    """Check feasibility using Bellman-Ford style relaxation.

    Iteratively propagates lower bounds through slack constraints.
    Detects infeasibility via either upper bound violation or
    non-convergence (negative cycle).

    Args:
        lower: array of lower bounds
        upper: array of upper bounds
        slack: n×n slack matrix

    Returns:
        (point, feasible): feasible point or None

    Time complexity: O(n³)
    Space complexity: O(n)
    """
    n = len(lower)
    x = lower.copy()

    for iteration in range(n):
        changed = False
        for i in range(n):
            for j in range(n):
                if i == j:
                    continue
                # x[j] must be ≥ x[i] - slack[i, j]
                needed = x[i] - slack[i, j]
                if needed > x[j] + 1e-12:
                    if needed > upper[j] + 1e-10:
                        return None, False
                    x[j] = needed
                    changed = True
        if not changed:
            break

    # Check for negative cycle (one more iteration)
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            needed = x[i] - slack[i, j]
            if needed > x[j] + 1e-10:
                return None, False

    # Verify all constraints
    for i in range(n):
        if x[i] < lower[i] - 1e-10 or x[i] > upper[i] + 1e-10:
            return None, False
        for j in range(n):
            if x[i] > x[j] + slack[i, j] + 1e-10:
                return None, False

    return x, True


def helly_certificate_laminar(bands: list) -> Tuple[Optional[np.ndarray], bool]:
    """Compute global feasibility for a laminar family of bands.

    For laminar families (nested support structure), pairwise
    feasibility implies global feasibility. This algorithm
    constructs the global witness by intersecting (meeting) bands
    in order of support inclusion.

    Args:
        bands: list of TropBand-like objects with .lower, .upper, .slack

    Returns:
        (point, feasible): global feasible point or None

    Time complexity: O(m · n³) where m = number of bands
    Space complexity: O(n²)
    """
    if not bands:
        return np.array([]), True

    n = len(bands[0].lower)
    # Compute global meet
    lower = bands[0].lower.copy()
    upper = bands[0].upper.copy()
    slack = bands[0].slack.copy()

    for b in bands[1:]:
        lower = np.maximum(lower, b.lower)
        upper = np.minimum(upper, b.upper)
        slack = np.minimum(slack, b.slack)

    return canonical_potential(lower, upper, slack)


def verify_feasibility_certificate(lower: np.ndarray, upper: np.ndarray,
                                     slack: np.ndarray,
                                     x: np.ndarray) -> dict:
    """Verify that a point is a valid feasibility certificate.

    Returns detailed verification results for each constraint.

    Args:
        lower, upper, slack: band system parameters
        x: candidate feasible point

    Returns:
        dict with keys 'valid', 'lower_ok', 'upper_ok', 'slack_ok', 'violations'
    """
    n = len(lower)
    violations = []

    lower_ok = True
    for i in range(n):
        if x[i] < lower[i] - 1e-10:
            lower_ok = False
            violations.append(f"lower[{i}]={lower[i]:.4f} > x[{i}]={x[i]:.4f}")

    upper_ok = True
    for i in range(n):
        if x[i] > upper[i] + 1e-10:
            upper_ok = False
            violations.append(f"x[{i}]={x[i]:.4f} > upper[{i}]={upper[i]:.4f}")

    slack_ok = True
    for i in range(n):
        for j in range(n):
            if x[i] > x[j] + slack[i, j] + 1e-10:
                slack_ok = False
                violations.append(
                    f"x[{i}]-x[{j}]={x[i]-x[j]:.4f} > slack[{i},{j}]={slack[i,j]:.4f}")

    return {
        'valid': lower_ok and upper_ok and slack_ok,
        'lower_ok': lower_ok,
        'upper_ok': upper_ok,
        'slack_ok': slack_ok,
        'violations': violations
    }


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Band Algorithms — Examples")
    print("=" * 50)

    # Example 1: Feasible system
    print("\n1. Canonical Potential Construction")
    lower = np.array([0.0, 1.0, 2.0])
    upper = np.array([5.0, 6.0, 7.0])
    slack = np.array([
        [0.0, 3.0, 5.0],
        [4.0, 0.0, 2.0],
        [3.0, 6.0, 0.0]
    ])

    x, feasible = canonical_potential(lower, upper, slack)
    print(f"   Feasible: {feasible}")
    if feasible:
        print(f"   Canonical potential: {x}")
        cert = verify_feasibility_certificate(lower, upper, slack, x)
        print(f"   Certificate valid: {cert['valid']}")

    # Example 2: Negative cycle detection
    print("\n2. Negative Cycle Detection")
    slack_neg = np.array([
        [0.0, 1.0, 100.0],
        [100.0, 0.0, 1.0],
        [-3.0, 100.0, 0.0]
    ])

    result = extract_negative_cycle(slack_neg)
    if result:
        cycle, weight = result
        print(f"   Negative cycle: {cycle}")
        print(f"   Weight: {weight}")

    # Example 3: Bellman-Ford
    print("\n3. Bellman-Ford Feasibility")
    x, feasible = bellman_ford_feasibility(lower, upper, slack)
    print(f"   Feasible: {feasible}")
    if feasible:
        print(f"   Point: {x}")
