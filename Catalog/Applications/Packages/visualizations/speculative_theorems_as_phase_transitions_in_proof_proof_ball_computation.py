"""
Algorithms for Phase Transitions in Proof Space

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import Dict, List, Set, Tuple, Optional
import math


def proof_ball(
    adj: Dict[int, Set[int]],
    axioms: Set[int],
    k: int
) -> Set[int]:
    """
    Compute the proof ball of radius k around axiom set.

    Args:
        adj: Adjacency dict mapping vertex -> set of out-neighbors
        axioms: Initial set of axiom vertices
        k: Number of derivation steps

    Returns:
        Set of all vertices reachable within k steps.
    """
    ball = set(axioms)
    for _ in range(k):
        neighbors = set()
        for v in ball:
            neighbors |= adj.get(v, set())
        new_ball = ball | neighbors
        if new_ball == ball:
            break  # Saturation
        ball = new_ball
    return ball


def proof_density(
    adj: Dict[int, Set[int]],
    axioms: Set[int],
    universe_size: int,
    k: int
) -> float:
    """
    Compute the proof density ρ(k) = |Ball(S,k)| / |V|.

    Args:
        adj: Adjacency dict
        axioms: Initial axiom set
        universe_size: Total number of vertices |V|
        k: Number of steps

    Returns:
        Fraction of reachable statements at step k.
    """
    ball = proof_ball(adj, axioms, k)
    return len(ball) / universe_size


def vertex_expansion(
    adj: Dict[int, Set[int]],
    subset: Set[int],
    universe_size: int
) -> float:
    """
    Compute the vertex expansion ratio h for a subset S.

    h = |∂S| / |S| where ∂S = outNeighbors(S) \ S.

    Args:
        adj: Adjacency dict
        subset: The set S
        universe_size: Total |V|

    Returns:
        Expansion ratio, or 0 if S is empty.
    """
    if not subset:
        return 0.0
    boundary = set()
    for v in subset:
        for u in adj.get(v, set()):
            if u not in subset:
                boundary.add(u)
    return len(boundary) / len(subset)


def critical_step(
    adj: Dict[int, Set[int]],
    axioms: Set[int],
    universe_size: int
) -> int:
    """
    Find the critical step k_c where density first exceeds 1/2.

    This is the phase transition point.

    Args:
        adj: Adjacency dict
        axioms: Initial axiom set
        universe_size: Total |V|

    Returns:
        The critical step k_c, or -1 if density never exceeds 1/2.
    """
    ball = set(axioms)
    for k in range(universe_size + 1):
        if 2 * len(ball) > universe_size:
            return k
        neighbors = set()
        for v in ball:
            neighbors |= adj.get(v, set())
        new_ball = ball | neighbors
        if new_ball == ball:
            return -1  # Stabilized below 1/2
        ball = new_ball
    return -1


def density_trajectory(
    adj: Dict[int, Set[int]],
    axioms: Set[int],
    universe_size: int,
    max_steps: int
) -> List[float]:
    """
    Compute the full density trajectory ρ(0), ρ(1), ..., ρ(max_steps).

    Args:
        adj: Adjacency dict
        axioms: Initial axiom set
        universe_size: Total |V|
        max_steps: Maximum number of steps

    Returns:
        List of density values at each step.
    """
    densities = []
    ball = set(axioms)
    for k in range(max_steps + 1):
        densities.append(len(ball) / universe_size)
        neighbors = set()
        for v in ball:
            neighbors |= adj.get(v, set())
        new_ball = ball | neighbors
        if new_ball == ball:
            # Stabilized: fill rest with same value
            densities.extend([densities[-1]] * (max_steps - k))
            break
        ball = new_ball
    return densities


def entropy_rate(
    adj: Dict[int, Set[int]],
    axioms: Set[int],
    max_steps: int
) -> List[float]:
    """
    Compute the entropy rate at each step.

    entropy_rate(k) = log(|Ball(k+1)|) - log(|Ball(k)|)

    Args:
        adj: Adjacency dict
        axioms: Initial axiom set
        max_steps: Maximum number of steps

    Returns:
        List of entropy rates.
    """
    ball = set(axioms)
    sizes = [len(ball)]
    for k in range(max_steps):
        neighbors = set()
        for v in ball:
            neighbors |= adj.get(v, set())
        ball = ball | neighbors
        sizes.append(len(ball))

    rates = []
    for i in range(len(sizes) - 1):
        if sizes[i] > 0 and sizes[i + 1] > 0:
            rates.append(math.log(sizes[i + 1]) - math.log(sizes[i]))
        else:
            rates.append(0.0)
    return rates


def saturation_analysis(
    adj: Dict[int, Set[int]],
    axioms: Set[int],
    universe_size: int
) -> Tuple[bool, int, float]:
    """
    Determine if the system is complete or incomplete.

    Returns:
        (is_complete, saturation_step, final_density)
    """
    ball = set(axioms)
    for k in range(universe_size + 1):
        neighbors = set()
        for v in ball:
            neighbors |= adj.get(v, set())
        new_ball = ball | neighbors
        if len(new_ball) == universe_size:
            return (True, k + 1, 1.0)
        if new_ball == ball:
            return (False, k, len(ball) / universe_size)
        ball = new_ball
    return (False, universe_size, len(ball) / universe_size)


def generate_expander_graph(n: int, degree: int = 3) -> Dict[int, Set[int]]:
    """
    Generate a random regular graph (approximate expander).

    Args:
        n: Number of vertices
        degree: Out-degree of each vertex

    Returns:
        Adjacency dict.
    """
    import random
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        targets = set()
        while len(targets) < degree:
            t = random.randint(0, n - 1)
            if t != i:
                targets.add(t)
        adj[i] = targets
    return adj


def generate_incomplete_system(n: int) -> Dict[int, Set[int]]:
    """
    Generate a derivation system that is provably incomplete:
    two disconnected components.

    Args:
        n: Total number of vertices (must be ≥ 4)

    Returns:
        Adjacency dict where vertices 0..n//2-1 form one component.
    """
    half = n // 2
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    # First component: chain
    for i in range(half - 1):
        adj[i].add(i + 1)
    # Second component: chain
    for i in range(half, n - 1):
        adj[i].add(i + 1)
    return adj
