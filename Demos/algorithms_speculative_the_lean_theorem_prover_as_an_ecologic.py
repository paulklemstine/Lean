#!/usr/bin/env python3
"""
Algorithms for Fitness Landscape Theory

Type-hinted implementations of the core algorithms from the
Ecological Niche Theory of Mathematics.
"""

from typing import Dict, List, Tuple, Set, Optional
from dataclasses import dataclass
import math


# ─── Data Structures ────────────────────────────────────────────────────────

@dataclass
class ProofModule:
    """A proof module characterized by theorem count and code complexity."""
    name: str
    theorems: int
    complexity: int

    def fitness(self) -> float:
        """Fitness = theorems / complexity."""
        if self.complexity == 0:
            return 0.0
        return self.theorems / self.complexity


@dataclass
class FitnessLandscape:
    """A fitness landscape on a finite graph."""
    vertices: List[str]
    adj: Dict[str, List[str]]
    fitness: Dict[str, float]


# ─── Algorithm 1: Local Optima Detection ────────────────────────────────────

def find_local_optima(L: FitnessLandscape) -> List[str]:
    """
    Find all local optima in a fitness landscape.

    A vertex v is a local optimum if f(v) >= f(u) for all neighbors u.

    Time complexity: O(|V| + |E|)

    Args:
        L: A fitness landscape

    Returns:
        List of vertex names that are local optima
    """
    optima: List[str] = []
    for v in L.vertices:
        is_optimum = True
        for u in L.adj.get(v, []):
            if L.fitness[u] > L.fitness[v]:
                is_optimum = False
                break
        if is_optimum:
            optima.append(v)
    return optima


def find_strict_local_optima(L: FitnessLandscape) -> List[str]:
    """
    Find all strict local optima (f(v) > f(u) for all neighbors u).

    Time complexity: O(|V| + |E|)
    """
    optima: List[str] = []
    for v in L.vertices:
        is_strict = True
        for u in L.adj.get(v, []):
            if L.fitness[u] >= L.fitness[v]:
                is_strict = False
                break
        if is_strict:
            optima.append(v)
    return optima


# ─── Algorithm 2: Valley Depth Computation ──────────────────────────────────

def compute_valley_depth(
    L: FitnessLandscape,
    walk: List[str]
) -> float:
    """
    Compute the valley depth of a walk in a fitness landscape.

    Valley depth = min(f(start), f(end)) - min_{v in walk} f(v)

    This measures how far below the endpoints the walk dips.
    The Valley Crossing Theorem guarantees this is > 0 for walks
    between strict local optima.

    Args:
        L: A fitness landscape
        walk: List of vertex names forming a valid walk

    Returns:
        The valley depth (non-negative if walk is between local optima)
    """
    if len(walk) < 2:
        return 0.0
    endpoint_min = min(L.fitness[walk[0]], L.fitness[walk[-1]])
    walk_min = min(L.fitness[v] for v in walk)
    return endpoint_min - walk_min


def find_optimal_bottleneck_path(
    L: FitnessLandscape,
    source: str,
    target: str
) -> Tuple[List[str], float]:
    """
    Find the path from source to target that maximizes the minimum
    fitness along the way (the bottleneck path).

    Uses a modified Dijkstra's algorithm with max-min instead of addition.

    Time complexity: O(|V|² + |E|)

    Args:
        L: A fitness landscape
        source: Starting vertex
        target: Ending vertex

    Returns:
        (optimal_path, bottleneck_value)
    """
    n = len(L.vertices)
    # bottleneck[v] = best bottleneck value from source to v
    bottleneck: Dict[str, float] = {v: -math.inf for v in L.vertices}
    bottleneck[source] = L.fitness[source]
    prev: Dict[str, Optional[str]] = {v: None for v in L.vertices}
    visited: Set[str] = set()

    for _ in range(n):
        # Pick unvisited vertex with highest bottleneck
        best_v = None
        best_val = -math.inf
        for v in L.vertices:
            if v not in visited and bottleneck[v] > best_val:
                best_v = v
                best_val = bottleneck[v]

        if best_v is None or best_v == target:
            break

        visited.add(best_v)

        for u in L.adj.get(best_v, []):
            # Bottleneck through best_v to u
            new_val = min(bottleneck[best_v], L.fitness[u])
            if new_val > bottleneck[u]:
                bottleneck[u] = new_val
                prev[u] = best_v

    # Reconstruct path
    path: List[str] = []
    v: Optional[str] = target
    while v is not None:
        path.append(v)
        v = prev[v]
    path.reverse()

    return path, bottleneck[target]


# ─── Algorithm 3: Max-Min Matrix Power ──────────────────────────────────────

def maxmin_matrix_multiply(
    A: List[List[float]],
    B: List[List[float]],
    n: int
) -> List[List[float]]:
    """
    Multiply two n×n matrices in the max-min (tropical) semiring.

    C[i][j] = max_k min(A[i][k], B[k][j])

    This is the fundamental operation for solving all-pairs
    bottleneck path problems.

    Time complexity: O(n³)
    """
    C = [[-math.inf] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = max(C[i][j], min(A[i][k], B[k][j]))
    return C


def maxmin_matrix_power(
    M: List[List[float]],
    n: int,
    power: int
) -> List[List[float]]:
    """
    Compute the k-th power of an n×n matrix in the max-min semiring.

    For a bottleneck matrix from a connected graph on n vertices,
    the (n-1)-th power gives the optimal all-pairs bottleneck values.

    Time complexity: O(n³ · power)
    """
    result = [[(-math.inf if i != j else math.inf) for j in range(n)] for i in range(n)]
    for _ in range(power):
        result = maxmin_matrix_multiply(result, M, n)
    return result


# ─── Algorithm 4: Module Composition with Mediant Bounds ────────────────────

def compose_modules(
    m1: ProofModule,
    m2: ProofModule,
    shared_theorems: int = 0,
    shared_code: int = 0
) -> Tuple[ProofModule, Dict[str, float]]:
    """
    Compose two proof modules with optional sharing.

    Returns the composed module and a dict of fitness bounds.

    The Mediant Inequality guarantees:
      min(f₁, f₂) ≤ f_composed ≤ max(f₁, f₂)  (without sharing)

    With shared infrastructure (shared_code > 0, shared_theorems = 0),
    the composed fitness can exceed both individual fitnesses.

    Args:
        m1, m2: Proof modules to compose
        shared_theorems: Theorems counted by both modules
        shared_code: Lines of shared infrastructure

    Returns:
        (composed_module, bounds_dict)
    """
    composed = ProofModule(
        name=f"{m1.name}⊕{m2.name}",
        theorems=m1.theorems + m2.theorems - shared_theorems,
        complexity=m1.complexity + m2.complexity - shared_code
    )

    f1, f2, fc = m1.fitness(), m2.fitness(), composed.fitness()
    bounds = {
        "f1": f1,
        "f2": f2,
        "f_composed": fc,
        "min_bound": min(f1, f2),
        "max_bound": max(f1, f2),
        "mediant_holds": (min(f1, f2) <= fc <= max(f1, f2)) if shared_code == 0 and shared_theorems == 0 else True,
        "superadditive": fc > max(f1, f2) if shared_code > 0 else False,
    }

    return composed, bounds


# ─── Main ───────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example landscape
    L = FitnessLandscape(
        vertices=["alg", "trans", "ana", "comb"],
        adj={
            "alg": ["trans"],
            "trans": ["alg", "ana", "comb"],
            "ana": ["trans"],
            "comb": ["trans"],
        },
        fitness={"alg": 8.0, "trans": 3.0, "ana": 7.0, "comb": 9.0}
    )

    print("Local optima:", find_local_optima(L))
    print("Strict local optima:", find_strict_local_optima(L))

    path, bv = find_optimal_bottleneck_path(L, "alg", "comb")
    print(f"Optimal bottleneck path alg→comb: {path}, value={bv}")

    # Module composition
    m1 = ProofModule("Algebra", 150, 2000)
    m2 = ProofModule("Analysis", 120, 3000)
    comp, bounds = compose_modules(m1, m2, shared_code=500)
    print(f"\nComposition: {comp}")
    print(f"Bounds: {bounds}")
