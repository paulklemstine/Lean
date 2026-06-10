#!/usr/bin/env python3
"""
Spectral Proof Complexity: Core Algorithms

Type-hinted implementations of the key algorithms from the research:
1. Proof ball computation (BFS-based)
2. Depth class stratification
3. Directed conductance computation
4. Conductance-based proof length lower bound
5. Layered derivation depth analysis
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
import math


# ============================================================
# Algorithm 1: Proof Ball Computation
# ============================================================

def proof_ball(
    adj: Dict[int, Set[int]],
    initial: Set[int],
    max_steps: int
) -> List[Set[int]]:
    """
    Compute proof balls Ball(S, 0), Ball(S, 1), ..., Ball(S, max_steps).

    Pseudocode:
        B[0] ← S
        for k = 1 to max_steps:
            B[k] ← B[k-1] ∪ N⁺(B[k-1])
        return B

    Args:
        adj: Adjacency list representation of derivation graph
        initial: Initial axiom set S
        max_steps: Maximum number of derivation steps

    Returns:
        List of sets, where result[k] = Ball(S, k)
    """
    balls: List[Set[int]] = [set(initial)]

    for k in range(1, max_steps + 1):
        prev = balls[-1]
        neighbors: Set[int] = set()
        for v in prev:
            neighbors.update(adj.get(v, set()))
        new_ball = prev | neighbors
        balls.append(new_ball)

        # Early termination if stabilized
        if new_ball == prev:
            # Fill remaining steps
            while len(balls) <= max_steps:
                balls.append(new_ball)
            break

    return balls


# ============================================================
# Algorithm 2: Depth Class Stratification
# ============================================================

def depth_classes(
    adj: Dict[int, Set[int]],
    initial: Set[int],
    max_depth: int
) -> List[Set[int]]:
    """
    Compute depth classes D(S, 0), D(S, 1), ..., D(S, max_depth).

    Pseudocode:
        D[0] ← S
        B ← S
        for k = 1 to max_depth:
            B_new ← B ∪ N⁺(B)
            D[k] ← B_new \\ B
            if D[k] = ∅: break
            B ← B_new
        return D

    Args:
        adj: Adjacency list representation
        initial: Initial axiom set S
        max_depth: Maximum depth to compute

    Returns:
        List of sets, where result[k] = D(S, k) (depth class at step k)
    """
    classes: List[Set[int]] = [set(initial)]
    ball = set(initial)

    for k in range(1, max_depth + 1):
        neighbors: Set[int] = set()
        for v in ball:
            neighbors.update(adj.get(v, set()))
        new_ball = ball | neighbors
        depth_class = new_ball - ball
        classes.append(depth_class)
        if not depth_class:
            break
        ball = new_ball

    return classes


# ============================================================
# Algorithm 3: Directed Conductance Computation
# ============================================================

def boundary(adj: Dict[int, Set[int]], S: Set[int]) -> Set[int]:
    """Compute ∂⁺S = N⁺(S) \\ S."""
    neighbors: Set[int] = set()
    for v in S:
        neighbors.update(adj.get(v, set()))
    return neighbors - S


def directed_conductance_exact(
    adj: Dict[int, Set[int]],
    n: int
) -> float:
    """
    Compute exact directed conductance (exponential time).

    Pseudocode:
        φ ← ∞
        for each nonempty S ⊆ V with |S| ≤ |V|/2:
            φ ← min(φ, |∂⁺S| / |S|)
        return φ

    Warning: Exponential time — only use for n ≤ 20.
    """
    from itertools import combinations

    vertices = list(range(n))
    min_ratio = float('inf')

    for size in range(1, n // 2 + 1):
        for subset in combinations(vertices, size):
            S = set(subset)
            bdry = boundary(adj, S)
            ratio = len(bdry) / len(S)
            min_ratio = min(min_ratio, ratio)

    return min_ratio


def directed_conductance_approx(
    adj: Dict[int, Set[int]],
    n: int,
    num_samples: int = 1000
) -> float:
    """
    Approximate directed conductance via random sampling.

    Pseudocode:
        φ ← ∞
        repeat num_samples times:
            S ← random subset of size ≤ n/2
            φ ← min(φ, |∂⁺S| / |S|)
        return φ
    """
    import random

    min_ratio = float('inf')
    vertices = list(range(n))

    for _ in range(num_samples):
        size = random.randint(1, n // 2)
        S = set(random.sample(vertices, size))
        bdry = boundary(adj, S)
        ratio = len(bdry) / len(S) if S else float('inf')
        min_ratio = min(min_ratio, ratio)

    return min_ratio


# ============================================================
# Algorithm 4: Proof Length Lower Bound
# ============================================================

def proof_length_lower_bound(
    n: int,
    s: int,
    conductance: float
) -> float:
    """
    Compute the conductance-based proof length lower bound.

    From the ball growth theorem:
        Ball(S, k) ≥ (1 + φ)^k · |S|
    Since Ball(S, k) ≤ n, we need (1 + φ)^k ≤ n/|S|,
    giving k ≤ log(n/|S|) / log(1 + φ).

    The proof length from S to any target outside Ball(S, k) is > k.

    Args:
        n: Total number of vertices
        s: Size of initial axiom set
        conductance: Directed conductance φ

    Returns:
        Lower bound on proof length to reach a target outside Ball(S, k*)
        where k* = log(n/(2s)) / log(1 + φ)
    """
    if conductance <= 0 or s <= 0 or n <= 2 * s:
        return 0.0
    return math.log(n / (2 * s)) / math.log(1 + conductance)


# ============================================================
# Algorithm 5: Layered Derivation Analysis
# ============================================================

def analyze_layered_derivation(
    adj: Dict[int, Set[int]],
    layer_fn: Dict[int, int],
    initial: Set[int],
    max_k: int
) -> Dict[str, object]:
    """
    Analyze a layered derivation graph.

    Verifies:
    1. Layer consistency: every edge u → v has layer(v) = layer(u) + 1
    2. Tight bound: Ball(S, k) ⊆ {v : layer(v) ≤ k}
    3. Reports maximum layer reached at each step

    Args:
        adj: Adjacency list
        layer_fn: Layer assignment for each vertex
        initial: Initial set (should be layer-0 vertices)
        max_k: Maximum steps to analyze

    Returns:
        Dictionary with analysis results
    """
    # Check layer consistency
    violations: List[Tuple[int, int, int, int]] = []
    for u, neighbors in adj.items():
        for v in neighbors:
            if layer_fn.get(v, -1) != layer_fn.get(u, -1) + 1:
                violations.append((u, v, layer_fn.get(u, -1), layer_fn.get(v, -1)))

    # Compute balls and check layer bounds
    balls = proof_ball(adj, initial, max_k)
    step_analysis: List[Dict[str, object]] = []

    for k, ball_k in enumerate(balls):
        layers_in_ball = [layer_fn[v] for v in ball_k if v in layer_fn]
        max_layer = max(layers_in_ball) if layers_in_ball else -1
        bound_satisfied = all(layer_fn.get(v, 0) <= k for v in ball_k)

        step_analysis.append({
            'step': k,
            'ball_size': len(ball_k),
            'max_layer': max_layer,
            'bound_k': k,
            'bound_satisfied': bound_satisfied
        })

    return {
        'is_valid_layered': len(violations) == 0,
        'violations': violations[:10],  # First 10
        'step_analysis': step_analysis
    }


# ============================================================
# Algorithm 6: Reachable Component and Fixed Point Detection
# ============================================================

def reachable_component(
    adj: Dict[int, Set[int]],
    initial: Set[int],
    n: int
) -> Tuple[Set[int], int]:
    """
    Compute the reachable component and the stabilization step.

    Pseudocode:
        B ← S
        for k = 1 to n:
            B_new ← B ∪ N⁺(B)
            if B_new = B: return (B, k-1)  # Stabilized
            B ← B_new
        return (B, n)

    Returns:
        (reachable_component, stabilization_step)
    """
    ball = set(initial)
    for k in range(1, n + 1):
        neighbors: Set[int] = set()
        for v in ball:
            neighbors.update(adj.get(v, set()))
        new_ball = ball | neighbors
        if new_ball == ball:
            return (ball, k - 1)
        ball = new_ball
    return (ball, n)


# ============================================================
# Utility: Graph Builders
# ============================================================

def build_cayley_cycle(n: int, generators: List[int]) -> Dict[int, Set[int]]:
    """Build Cayley graph of ℤ/nℤ with given generators."""
    adj: Dict[int, Set[int]] = {}
    for i in range(n):
        adj[i] = {(i + g) % n for g in generators}
    return adj


def build_layered_graph(
    layers: int,
    width: int,
    connections_per_vertex: int = 2
) -> Tuple[Dict[int, Set[int]], Dict[int, int]]:
    """
    Build a layered derivation graph.

    Returns (adjacency list, layer function).
    """
    adj: Dict[int, Set[int]] = {}
    layer_fn: Dict[int, int] = {}
    n = layers * width

    for ell in range(layers):
        for i in range(width):
            v = ell * width + i
            layer_fn[v] = ell
            adj[v] = set()
            if ell < layers - 1:
                for j in range(min(connections_per_vertex, width)):
                    w = (ell + 1) * width + (i + j) % width
                    adj[v].add(w)

    return adj, layer_fn


if __name__ == "__main__":
    # Quick smoke test
    adj = build_cayley_cycle(20, [1, 2])
    balls = proof_ball(adj, {0}, 10)
    print(f"Ball sizes: {[len(b) for b in balls]}")

    classes = depth_classes(adj, {0}, 10)
    print(f"Depth class sizes: {[len(c) for c in classes]}")

    rc, stab = reachable_component(adj, {0}, 20)
    print(f"Reachable component: {len(rc)} vertices, stabilized at step {stab}")

    lb = proof_length_lower_bound(20, 1, 0.5)
    print(f"Proof length lower bound (n=20, s=1, φ=0.5): {lb:.2f}")
