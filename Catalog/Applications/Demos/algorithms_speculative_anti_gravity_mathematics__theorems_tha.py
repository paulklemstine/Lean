"""
Anti-Gravity Theorems: Core Algorithms

Type-hinted implementations of the key algorithms from the anti-gravity
theorem framework.
"""
from typing import Dict, Set, List, Tuple, Optional
from collections import defaultdict


def forward_ball(
    adj: Dict[int, Set[int]],
    seed_set: Set[int],
    steps: int
) -> Set[int]:
    """
    Compute the forward reachability ball of radius `steps` from `seed_set`.

    This is the constructive analog of FwdBall from the Lean formalization.
    Starting from the seed set, at each step we add all out-neighbors of
    the current set.

    Args:
        adj: Adjacency list (directed graph)
        seed_set: Initial set of vertices
        steps: Number of expansion steps

    Returns:
        The set of all vertices reachable within `steps` from `seed_set`.
    """
    current = set(seed_set)
    for _ in range(steps):
        expansion = set()
        for v in current:
            expansion.update(adj.get(v, set()))
        current = current | expansion
    return current


def descendant_set(
    adj: Dict[int, Set[int]],
    vertex: int,
    n: int
) -> Set[int]:
    """
    Compute the descendant set (transitive closure from a vertex).

    Uses BFS, equivalent to FwdBallV with k = n steps.

    Args:
        adj: Adjacency list
        vertex: Starting vertex
        n: Number of vertices (upper bound on steps needed)

    Returns:
        Set of all vertices reachable from `vertex`.
    """
    return forward_ball(adj, {vertex}, n)


def gravitational_weight(
    adj: Dict[int, Set[int]],
    vertex: int,
    n: int
) -> int:
    """
    Compute the gravitational weight of a vertex.

    Weight(v) = |DescendantSet(v)| — the number of vertices reachable from v.

    Args:
        adj: Adjacency list
        vertex: Vertex to compute weight for
        n: Total number of vertices

    Returns:
        The gravitational weight (descendant count).
    """
    return len(descendant_set(adj, vertex, n))


def in_degree(
    adj: Dict[int, Set[int]],
    vertex: int,
    n: int
) -> int:
    """
    Compute the in-degree of a vertex.

    Args:
        adj: Adjacency list
        vertex: Target vertex
        n: Total number of vertices

    Returns:
        Number of edges pointing to `vertex`.
    """
    count = 0
    for u in range(n):
        if vertex in adj.get(u, set()):
            count += 1
    return count


def identify_anti_gravity(
    adj: Dict[int, Set[int]],
    n: int,
    tau: int
) -> List[Tuple[int, int, int, float]]:
    """
    Identify all anti-gravity vertices at threshold τ.

    A vertex v is anti-gravity if Weight(v) > τ · InDegree(v).
    This implements the constructive content of the existence theorem.

    Args:
        adj: Adjacency list
        n: Total number of vertices
        tau: Anti-gravity threshold

    Returns:
        List of (vertex, weight, in_degree, leverage) tuples for
        all anti-gravity vertices, sorted by leverage descending.
    """
    results = []
    for v in range(n):
        w = gravitational_weight(adj, v, n)
        d = in_degree(adj, v, n)
        if w > tau * d:
            leverage = w / max(d, 1)
            results.append((v, w, d, leverage))
    return sorted(results, key=lambda x: -x[3])


def total_weight(
    adj: Dict[int, Set[int]],
    n: int
) -> int:
    """Compute total weight across all vertices."""
    return sum(gravitational_weight(adj, v, n) for v in range(n))


def edge_count(
    adj: Dict[int, Set[int]],
    n: int
) -> int:
    """Compute total edge count (sum of in-degrees)."""
    return sum(in_degree(adj, v, n) for v in range(n))


def anti_gravity_density(
    adj: Dict[int, Set[int]],
    n: int,
    tau: int
) -> float:
    """
    Compute the anti-gravity density at threshold τ.

    Returns the fraction of vertices that are anti-gravity.
    Our theorem guarantees this is positive when TotalWeight > τ · EdgeCount.
    """
    ag_vertices = identify_anti_gravity(adj, n, tau)
    return len(ag_vertices) / n if n > 0 else 0.0


def verify_pigeonhole_theorem(
    adj: Dict[int, Set[int]],
    n: int,
    tau: int
) -> Dict[str, any]:
    """
    Verify the anti-gravity existence theorem on a concrete graph.

    Returns a report including whether the precondition holds and
    whether anti-gravity vertices exist (must be true when precondition holds).
    """
    tw = total_weight(adj, n)
    ec = edge_count(adj, n)
    ag = identify_anti_gravity(adj, n, tau)

    precondition = tw > tau * ec
    conclusion = len(ag) > 0

    return {
        'total_weight': tw,
        'edge_count': ec,
        'tau': tau,
        'tau_times_edges': tau * ec,
        'precondition_holds': precondition,
        'anti_gravity_exists': conclusion,
        'theorem_verified': (not precondition) or conclusion,
        'anti_gravity_count': len(ag),
        'anti_gravity_density': len(ag) / n if n > 0 else 0,
    }
