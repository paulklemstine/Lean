#!/usr/bin/env python3
"""
Tropical Type Theory: Algorithms

Implements core algorithms arising from tropical type theory:
1. Tropical type checker (finite constraint satisfaction)
2. Tropical morphism composition with cost tracking
3. Initial algebra recursion (Bellman-style)
4. Universe code normalization
5. Shortest-path type inference
"""

from typing import Callable, List, Dict, Tuple, Optional, Any
from dataclasses import dataclass
import heapq


# ─── Algorithm 1: Tropical Type Checker ──────────────────────────────────

@dataclass
class TypeCheckResult:
    """Result of tropical type checking."""
    is_valid: bool
    violations: List[dict]
    max_slack: int  # Maximum slack needed to make it valid
    certificate: List[dict]  # Full verification trace

def tropical_type_check(
    domain: List[Any],
    A: Callable,
    B: Callable,
    f: Callable,
    cost_bound: int = 0
) -> TypeCheckResult:
    """
    Decidable tropical type checking.

    Checks whether f : A → B is a cost-c tropical homomorphism:
      ∀ x ∈ domain, B(f(x)) ≤ A(x) + cost_bound

    Complexity: O(|domain|) evaluations.

    Args:
        domain: Finite enumeration of the base type
        A: Cost function on domain
        B: Cost function on codomain
        f: Function to type-check
        cost_bound: Allowed cost slack (default 0 = strict)

    Returns:
        TypeCheckResult with validity, violations, and certificate
    """
    violations = []
    certificate = []
    max_slack_needed = 0

    for x in domain:
        ax = A(x)
        fx = f(x)
        bfx = B(fx)
        slack = bfx - ax
        max_slack_needed = max(max_slack_needed, slack)

        entry = {'x': x, 'A(x)': ax, 'f(x)': fx, 'B(f(x))': bfx,
                 'slack': slack, 'valid': bfx <= ax + cost_bound}
        certificate.append(entry)

        if bfx > ax + cost_bound:
            violations.append(entry)

    return TypeCheckResult(
        is_valid=len(violations) == 0,
        violations=violations,
        max_slack=max(0, max_slack_needed),
        certificate=certificate
    )


# ─── Algorithm 2: Tropical Morphism Composer ────────────────────────────

@dataclass
class CompositionResult:
    """Result of composing tropical morphisms."""
    total_cost: int
    intermediate_costs: List[int]
    is_valid: bool

def compose_tropical_morphisms(
    domain: List[Any],
    cost_fns: List[Callable],      # [A, B, C, ...]
    morphisms: List[Callable],      # [f: A→B, g: B→C, ...]
    cost_bounds: List[int]          # [c₁, c₂, ...]
) -> CompositionResult:
    """
    Compose a chain of cost-bounded tropical morphisms.

    Given morphisms f₁, f₂, ..., fₙ with costs c₁, c₂, ..., cₙ,
    verifies that the composition has cost ≤ c₁ + c₂ + ... + cₙ.

    Complexity: O(|domain| × n) where n is the chain length.

    Args:
        domain: Finite base type
        cost_fns: Cost functions [A₀, A₁, ..., Aₙ]
        morphisms: Functions [f₁, f₂, ..., fₙ] where fᵢ : Aᵢ₋₁ → Aᵢ
        cost_bounds: Cost bounds [c₁, c₂, ..., cₙ]

    Returns:
        CompositionResult with total cost bound and validity
    """
    assert len(morphisms) == len(cost_bounds)
    assert len(cost_fns) == len(morphisms) + 1

    total_cost = sum(cost_bounds)
    all_valid = True

    for x in domain:
        current = x
        for i, (f, c) in enumerate(zip(morphisms, cost_bounds)):
            ax = cost_fns[i](current)
            current = f(current)
            bfx = cost_fns[i + 1](current)
            if bfx > ax + c:
                all_valid = False

    return CompositionResult(
        total_cost=total_cost,
        intermediate_costs=cost_bounds,
        is_valid=all_valid
    )


# ─── Algorithm 3: Initial Algebra Recursion ──────────────────────────────

def initial_algebra_hom(
    zero_val: Any,
    succ_fn: Callable,
    n: int
) -> Any:
    """
    Compute the unique algebra homomorphism from ℕ to any algebra (A, str).

    This is the tropical analogue of the recursion principle:
      f(0) = str(None) = zero_val
      f(n+1) = str(Some(f(n))) = succ_fn(f(n))

    Complexity: O(n) applications of succ_fn.

    Args:
        zero_val: Image of 0 (= str(None))
        succ_fn: Successor function (= str ∘ Some)
        n: Natural number to map

    Returns:
        f(n) in the target algebra
    """
    result = zero_val
    for _ in range(n):
        result = succ_fn(result)
    return result


def bellman_recursion(
    costs: List[List[float]],
    source: int = 0
) -> List[float]:
    """
    Bellman-Ford shortest paths as initial algebra recursion.

    Interprets shortest-path computation as recursive evaluation
    in a tropical algebra where:
    - The algebra is (ℝ∪{∞}, min, +)
    - str(None) = source distances = [∞,...,0,...,∞]
    - str(Some(d)) = relax all edges once

    This connects tropical inductive types to dynamic programming.

    Complexity: O(V × E) where V = |vertices|, E = |edges|.

    Args:
        costs: Adjacency matrix (∞ = no edge)
        source: Source vertex index

    Returns:
        Shortest distances from source to all vertices
    """
    n = len(costs)
    INF = float('inf')

    # str(None): initial distances
    dist = [INF] * n
    dist[source] = 0

    # str(Some(d)): relax all edges
    for _ in range(n - 1):
        new_dist = dist.copy()
        for u in range(n):
            for v in range(n):
                if dist[u] + costs[u][v] < new_dist[v]:
                    new_dist[v] = dist[u] + costs[u][v]
        dist = new_dist

    return dist


# ─── Algorithm 4: Universe Code Normalization ────────────────────────────

def normalize_code(u: int, K: int) -> int:
    """
    Normalize a tropical universe code.

    normalizeCode(K, u) = min(u, K)

    This is idempotent: normalize(normalize(u)) = normalize(u)
    and rank-nonincreasing: normalize(u) ≤ u.

    Args:
        u: Universe code (natural number)
        K: Complexity bound

    Returns:
        Normalized code
    """
    return min(u, K)


def universe_hierarchy(max_code: int, K: int) -> Dict[int, List[int]]:
    """
    Compute the tropical universe hierarchy.

    Groups codes by their normalized form, showing how
    codes above K collapse to the same normal form.

    Args:
        max_code: Maximum code to consider
        K: Complexity bound

    Returns:
        Dictionary mapping normalized codes to their equivalence classes
    """
    hierarchy = {}
    for u in range(max_code + 1):
        nu = normalize_code(u, K)
        if nu not in hierarchy:
            hierarchy[nu] = []
        hierarchy[nu].append(u)
    return hierarchy


# ─── Algorithm 5: Tropical Type Inference ────────────────────────────────

def infer_minimal_cost(
    domain: List[Any],
    B: Callable,
    f: Callable
) -> Callable:
    """
    Infer the minimal tropical set A such that f : A → B.

    The minimal A is: A(x) = B(f(x)) for all x.

    This is the principal type / tightest cost annotation.

    Complexity: O(|domain|).

    Args:
        domain: Finite base type
        B: Target cost function
        f: Function to type

    Returns:
        Minimal cost function A
    """
    cost_map = {}
    for x in domain:
        cost_map[x] = B(f(x))
    return lambda x: cost_map.get(x, 0)


def tropical_meet(A: Callable, B: Callable) -> Callable:
    """
    Compute the tropical meet (intersection) of two cost functions.

    TropMeet(A, B)(x) = min(A(x), B(x))

    This is the greatest lower bound in the tropical subtyping order.

    Args:
        A, B: Cost functions

    Returns:
        Meet cost function
    """
    return lambda x: min(A(x), B(x))


# ─── Demonstration ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Type checking
    print("\n--- Tropical Type Checker ---")
    domain = list(range(8))
    result = tropical_type_check(
        domain,
        A=lambda x: 2 * x + 5,
        B=lambda y: y + 1,
        f=lambda x: x + 2,
        cost_bound=0
    )
    print(f"Valid: {result.is_valid}")
    print(f"Min slack needed: {result.max_slack}")
    if result.violations:
        print(f"Violations at: {[v['x'] for v in result.violations]}")

    # Bellman-Ford as initial algebra
    print("\n--- Bellman Shortest Paths (Initial Algebra) ---")
    INF = float('inf')
    graph = [
        [0, 4, INF, INF, INF],
        [INF, 0, 1, INF, INF],
        [INF, INF, 0, 5, INF],
        [INF, INF, INF, 0, 3],
        [INF, INF, INF, INF, 0]
    ]
    dists = bellman_recursion(graph, source=0)
    print(f"Distances from vertex 0: {dists}")

    # Universe hierarchy
    print("\n--- Universe Hierarchy (K=4) ---")
    hierarchy = universe_hierarchy(10, K=4)
    for level, codes in sorted(hierarchy.items()):
        print(f"  Level {level}: codes {codes}")

    # Type inference
    print("\n--- Minimal Cost Inference ---")
    B = lambda y: y * y
    f = lambda x: x + 1
    A_min = infer_minimal_cost(domain, B, f)
    for x in domain:
        print(f"  x={x}: minimal A(x) = {A_min(x)}, B(f(x)) = {B(f(x))}")
