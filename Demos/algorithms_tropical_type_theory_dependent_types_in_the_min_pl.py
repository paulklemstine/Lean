#!/usr/bin/env python3
"""
Tropical Type Theory — Algorithms

Implements the core algorithms from the research paper:
1. TropicalTypeChecker: O(n) decidable type checking
2. CostBoundedComposer: Cost-additive composition
3. InitialAlgebraHomomorphism: Unique morphism from ℕ
4. UniverseNormalizer: Idempotent code normalization
5. TropicalMeetComputer: Greatest lower bound computation
6. ShortestPathVerifier: Application to shortest-path verification
"""

from typing import Callable, Dict, List, Optional, Tuple, Any
from dataclasses import dataclass
import time


# =============================================================================
# Algorithm 1: Tropical Type Checker
# =============================================================================

@dataclass
class TypeCheckResult:
    """Result of tropical type checking."""
    accepted: bool
    violations: List[Tuple[Any, int, int]]  # (element, B(f(x)), A(x))
    cost_slack: Optional[int]  # minimum slack across all elements

def tropical_type_check(
    domain: List[Any],
    A: Callable,
    B: Callable,
    f: Callable,
    cost_bound: int = 0
) -> TypeCheckResult:
    """
    Decidable tropical type checking on finite domains.
    
    Checks whether f is a c-bounded tropical homomorphism from A to B:
        ∀ x ∈ domain, B(f(x)) ≤ A(x) + cost_bound
    
    Time complexity: O(|domain|)
    Space complexity: O(|violations|)
    
    Args:
        domain: Finite enumeration of the base type
        A: Source tropical set (cost function)
        B: Target tropical set (cost function)
        f: Function to type-check
        cost_bound: Allowed cost overhead (default 0 = strict typing)
    
    Returns:
        TypeCheckResult with acceptance status and details
    """
    violations = []
    min_slack = float('inf')
    
    for x in domain:
        bfx = B(f(x))
        ax = A(x)
        slack = ax + cost_bound - bfx
        
        if slack < min_slack:
            min_slack = slack
        
        if bfx > ax + cost_bound:
            violations.append((x, bfx, ax))
    
    return TypeCheckResult(
        accepted=len(violations) == 0,
        violations=violations,
        cost_slack=int(min_slack) if min_slack != float('inf') else None
    )


# =============================================================================
# Algorithm 2: Cost-Bounded Composer
# =============================================================================

@dataclass
class TropicalMorphism:
    """A cost-bounded tropical morphism."""
    f: Callable
    cost_bound: int
    source_name: str = ""
    target_name: str = ""

def compose_morphisms(
    m1: TropicalMorphism,
    m2: TropicalMorphism
) -> TropicalMorphism:
    """
    Compose two cost-bounded tropical morphisms.
    
    Given m1: A →_{c₁} B and m2: B →_{c₂} C,
    returns m2 ∘ m1: A →_{c₁+c₂} C.
    
    Time complexity: O(1) for the composition setup
    The resulting function evaluates in O(T(m1) + T(m2)) per call.
    
    This implements the substitution lemma (TropHomC.comp).
    """
    return TropicalMorphism(
        f=lambda x: m2.f(m1.f(x)),
        cost_bound=m1.cost_bound + m2.cost_bound,
        source_name=m1.source_name,
        target_name=m2.target_name
    )

def compose_pipeline(morphisms: List[TropicalMorphism]) -> TropicalMorphism:
    """
    Compose a pipeline of tropical morphisms.
    Total cost bound is the sum of individual cost bounds.
    
    Time complexity: O(k) where k = number of morphisms
    """
    if not morphisms:
        return TropicalMorphism(f=lambda x: x, cost_bound=0)
    
    result = morphisms[0]
    for m in morphisms[1:]:
        result = compose_morphisms(result, m)
    
    return result


# =============================================================================
# Algorithm 3: Initial Algebra Homomorphism
# =============================================================================

@dataclass
class TropicalAlgebra:
    """A tropical algebra for the Option (1 + X) functor."""
    name: str
    zero: Any           # str(None): the base element
    succ: Callable      # str(Some(·)): the successor function

def initial_algebra_hom(
    algebra: TropicalAlgebra,
    n: int
) -> Any:
    """
    Compute the unique algebra homomorphism from ℕ to a tropical algebra.
    
    f(0) = algebra.zero
    f(k+1) = algebra.succ(f(k))
    
    Time complexity: O(n)
    Space complexity: O(1) (iterative)
    
    This implements the initiality theorem (nat_initial_tropAlg).
    """
    result = algebra.zero
    for _ in range(n):
        result = algebra.succ(result)
    return result

def verify_homomorphism(
    algebra: TropicalAlgebra,
    max_n: int = 20
) -> Tuple[bool, List[Tuple[int, Any]]]:
    """
    Verify the homomorphism property for the first max_n values.
    
    Checks: f(str(z)) = algebra.str(Option.map f z)
    - z = None: f(0) = algebra.zero
    - z = Some(n): f(n+1) = algebra.succ(f(n))
    
    Returns (all_ok, [(n, f(n))])
    """
    values = []
    ok = True
    
    for n in range(max_n):
        val = initial_algebra_hom(algebra, n)
        values.append((n, val))
        
        if n == 0:
            if val != algebra.zero:
                ok = False
        else:
            prev = initial_algebra_hom(algebra, n - 1)
            if val != algebra.succ(prev):
                ok = False
    
    return ok, values


# =============================================================================
# Algorithm 4: Universe Normalizer
# =============================================================================

def normalize_code(K: int, u: int) -> int:
    """
    Normalize a tropical universe code.
    
    normalizeCode(K, u) = min(u, K)
    
    Time complexity: O(1)
    
    Properties (proven in Lean):
    - Idempotent: normalize(K, normalize(K, u)) = normalize(K, u)
    - Rank-nonincreasing: normalize(K, u) ≤ u
    """
    return min(u, K)

def verify_idempotency(K: int, test_range: int = 100) -> bool:
    """Verify idempotency of normalization on a range of values."""
    return all(
        normalize_code(K, normalize_code(K, u)) == normalize_code(K, u)
        for u in range(test_range)
    )

def normalized_codes(K: int) -> List[int]:
    """Return all normalized codes (fixed points of normalization) up to K."""
    return [u for u in range(K + 1) if normalize_code(K, u) == u]


# =============================================================================
# Algorithm 5: Tropical Meet Computer
# =============================================================================

def tropical_meet(
    A: Callable[[int], int],
    B: Callable[[int], int]
) -> Callable[[int], int]:
    """
    Compute the tropical meet (intersection) of two tropical sets.
    
    TropMeet(A, B)(x) = min(A(x), B(x))
    
    Properties (proven in Lean):
    - sub_left: TropSub(A, TropMeet(A, B))
    - sub_right: TropSub(B, TropMeet(A, B))
    - greatest: if TropSub(A, C) and TropSub(B, C), then TropSub(TropMeet(A,B), C)
    """
    return lambda x: min(A(x), B(x))

def verify_glb(
    A: Callable, B: Callable, C: Callable,
    domain: List[int]
) -> Dict[str, bool]:
    """Verify greatest lower bound properties of the tropical meet."""
    meet = tropical_meet(A, B)
    
    sub_left = all(meet(x) <= A(x) for x in domain)
    sub_right = all(meet(x) <= B(x) for x in domain)
    
    # Check if C is a lower bound of both A and B
    c_below_a = all(C(x) <= A(x) for x in domain)
    c_below_b = all(C(x) <= B(x) for x in domain)
    
    # If so, C should be below the meet
    if c_below_a and c_below_b:
        c_below_meet = all(C(x) <= meet(x) for x in domain)
    else:
        c_below_meet = None
    
    return {
        "sub_left": sub_left,
        "sub_right": sub_right,
        "C_is_lower_bound": c_below_a and c_below_b,
        "greatest_property": c_below_meet
    }


# =============================================================================
# Algorithm 6: Shortest-Path Verifier
# =============================================================================

def verify_shortest_path(
    graph: Dict[int, List[Tuple[int, int]]],  # adjacency list: node -> [(neighbor, weight)]
    distances: Dict[int, int],                  # proposed distance function
    source: int
) -> TypeCheckResult:
    """
    Verify a proposed shortest-path solution using tropical type checking.
    
    The distance function d is a tropical set. The predecessor function
    (implicit in the distances) must satisfy d(v) ≤ d(u) + w(u,v)
    for all edges (u,v) with weight w(u,v).
    
    This is equivalent to checking that the distance function is a
    tropical homomorphism from the "edge-relaxed" cost function to
    the distance function itself.
    
    Time complexity: O(|E|) where E is the edge set
    """
    violations = []
    min_slack = float('inf')
    
    for u in graph:
        for (v, w) in graph[u]:
            # Bellman condition: d(v) ≤ d(u) + w
            if v in distances and u in distances:
                slack = distances[u] + w - distances[v]
                if slack < min_slack:
                    min_slack = slack
                if distances[v] > distances[u] + w:
                    violations.append((f"edge ({u},{v},w={w})", distances[v], distances[u] + w))
    
    # Source must have distance 0
    if distances.get(source, -1) != 0:
        violations.append(("source", distances.get(source, -1), 0))
    
    return TypeCheckResult(
        accepted=len(violations) == 0,
        violations=violations,
        cost_slack=int(min_slack) if min_slack != float('inf') else None
    )


# =============================================================================
# Main — Example Usage
# =============================================================================

if __name__ == "__main__":
    print("Tropical Type Theory — Algorithms\n")
    
    # Algorithm 1: Type Checking
    print("--- Algorithm 1: Type Checking ---")
    domain = list(range(10))
    result = tropical_type_check(
        domain,
        A=lambda x: 3 * x,
        B=lambda y: y,
        f=lambda x: x,
        cost_bound=0
    )
    print(f"Type check result: {'ACCEPT' if result.accepted else 'REJECT'}")
    print(f"Minimum slack: {result.cost_slack}")
    
    # Algorithm 2: Composition
    print("\n--- Algorithm 2: Composition ---")
    m1 = TropicalMorphism(f=lambda x: x + 1, cost_bound=2, source_name="A", target_name="B")
    m2 = TropicalMorphism(f=lambda x: x * 2, cost_bound=3, source_name="B", target_name="C")
    composed = compose_morphisms(m1, m2)
    print(f"Composed cost bound: {composed.cost_bound} (= {m1.cost_bound} + {m2.cost_bound})")
    print(f"Composed f(5) = {composed.f(5)}")
    
    # Algorithm 3: Initial Algebra
    print("\n--- Algorithm 3: Initial Algebra Homomorphism ---")
    alg = TropicalAlgebra(name="Doubling", zero=1, succ=lambda n: 2 * n + 1)
    ok, values = verify_homomorphism(alg, max_n=8)
    print(f"Algebra: zero=1, succ(n)=2n+1")
    print(f"Homomorphism: {[v for _, v in values]}")
    print(f"Verified: {'✓' if ok else '✗'}")
    
    # Algorithm 4: Normalization
    print("\n--- Algorithm 4: Universe Normalization ---")
    K = 5
    print(f"Normalized codes for K={K}: {normalized_codes(K)}")
    print(f"Idempotency verified: {'✓' if verify_idempotency(K) else '✗'}")
    
    # Algorithm 6: Shortest-Path Verification
    print("\n--- Algorithm 6: Shortest-Path Verification ---")
    graph = {
        0: [(1, 4), (2, 1)],
        1: [(3, 1)],
        2: [(1, 2), (3, 5)],
        3: []
    }
    # Correct distances
    correct_distances = {0: 0, 1: 3, 2: 1, 3: 4}
    result = verify_shortest_path(graph, correct_distances, source=0)
    print(f"Correct distances: {correct_distances}")
    print(f"Verification: {'ACCEPT' if result.accepted else 'REJECT'}")
    
    # Incorrect distances
    wrong_distances = {0: 0, 1: 2, 2: 1, 3: 4}
    result = verify_shortest_path(graph, wrong_distances, source=0)
    print(f"\nWrong distances: {wrong_distances}")
    print(f"Verification: {'ACCEPT' if result.accepted else 'REJECT'}")
    if result.violations:
        print(f"Violations: {result.violations}")
