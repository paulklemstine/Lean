#!/usr/bin/env python3
"""
Algorithms for emergent theorem discovery in idempotent algebras.

Implements:
1. Generic monotone closure operator with convergence tracking
2. Rule-based inference engine with derivation trees
3. Tropical Bellman-Ford with depth stratification
4. Min-plus matrix power iteration (Kleene star)
"""

from typing import Dict, List, Set, Tuple, Optional, Callable
from dataclasses import dataclass, field
import numpy as np


# ============================================================
# Algorithm 1: Generic Monotone Closure
# ============================================================

@dataclass
class ClosureResult:
    """Result of monotone closure computation."""
    fixed_point: Set
    chain: List[Set]
    stabilization_step: int
    cardinality_trace: List[int]

    def __repr__(self):
        return (f"ClosureResult(|C|={len(self.fixed_point)}, "
                f"N={self.stabilization_step})")


def monotone_closure(step: Callable[[Set], Set],
                     initial: Set,
                     universe_size: int = None,
                     max_iter: int = 10000) -> ClosureResult:
    """
    Compute the least fixed point of a monotone extensive operator.

    Algorithm (Knaster-Tarski iteration):
        T(0) = initial
        T(n+1) = step(T(n))
        Stop when T(N) = T(N+1)

    Complexity:
        Time: O(N × cost(step)), where N ≤ |universe|
        Space: O(|universe|) for the current set

    Args:
        step: Monotone extensive operator (S ⊆ step(S) and S ⊆ T → step(S) ⊆ step(T))
        initial: Starting set (axioms)
        universe_size: Optional bound for verification
        max_iter: Safety limit

    Returns:
        ClosureResult with the fixed point and convergence data
    """
    chain = [set(initial)]
    card_trace = [len(initial)]
    current = set(initial)

    for i in range(max_iter):
        next_set = step(current)

        # Verify extensivity
        assert current.issubset(next_set), \
            f"Step {i}: extensivity violated (lost elements)"

        chain.append(set(next_set))
        card_trace.append(len(next_set))

        if next_set == current:
            return ClosureResult(
                fixed_point=current,
                chain=chain,
                stabilization_step=i,
                cardinality_trace=card_trace
            )
        current = next_set

    raise RuntimeError(f"Did not stabilize within {max_iter} iterations")


# ============================================================
# Algorithm 2: Rule-Based Inference Engine
# ============================================================

@dataclass
class InferenceRule:
    """An inference rule: premises ⊢ conclusion."""
    premises: frozenset
    conclusion: object
    name: str = ""
    weight: float = 1.0


@dataclass
class DerivationNode:
    """A node in a derivation tree."""
    formula: object
    rule_name: str
    children: List['DerivationNode'] = field(default_factory=list)
    depth: int = 0

    def pretty(self, indent=0) -> str:
        prefix = "  " * indent
        if not self.children:
            return f"{prefix}[{self.formula}] ({self.rule_name})"
        lines = [f"{prefix}[{self.formula}] by {self.rule_name}"]
        for child in self.children:
            lines.append(child.pretty(indent + 1))
        return "\n".join(lines)


def build_step_rules(rules: List[InferenceRule]) -> Callable[[Set], Set]:
    """Build a one-step consequence operator from inference rules."""
    def step(s: Set) -> Set:
        result = set(s)
        for r in rules:
            if r.premises.issubset(s):
                result.add(r.conclusion)
        return result
    return step


def find_derivation(rules: List[InferenceRule],
                    axioms: Set,
                    target: object,
                    memo: Dict = None) -> Optional[DerivationNode]:
    """
    Find a derivation tree for target from axioms using rules.

    Algorithm (backward chaining with memoization):
        1. If target ∈ axioms, return leaf node
        2. For each rule with conclusion = target:
           a. Recursively derive all premises
           b. If all premises derivable, return tree

    Complexity:
        Time: O(|rules| × |derivable|) with memoization
        Space: O(|derivable|) for memo table
    """
    if memo is None:
        memo = {}

    if target in memo:
        return memo[target]

    if target in axioms:
        node = DerivationNode(target, "axiom", depth=0)
        memo[target] = node
        return node

    for r in rules:
        if r.conclusion == target:
            children = []
            max_depth = 0
            ok = True
            for p in r.premises:
                child = find_derivation(rules, axioms, p, memo)
                if child is None:
                    ok = False
                    break
                children.append(child)
                max_depth = max(max_depth, child.depth)
            if ok:
                node = DerivationNode(
                    target, r.name or str(r),
                    children, depth=max_depth + 1
                )
                memo[target] = node
                return node

    memo[target] = None
    return None


# ============================================================
# Algorithm 3: Tropical Bellman-Ford
# ============================================================

INF = float('inf')


@dataclass
class BellmanResult:
    """Result of Bellman-Ford computation."""
    distances: Dict
    stabilization_step: int
    history: List[Dict]
    parent: Dict  # For path reconstruction


def tropical_bellman_ford(vertices: List,
                          edges: List[Tuple],
                          source: object) -> BellmanResult:
    """
    Bellman-Ford shortest paths in the min-plus (tropical) semiring.

    Algorithm:
        d₀(v) = 0 if v = source, ∞ otherwise
        d_{n+1}(v) = min(d_n(v), min_{(u,v,w)∈E} d_n(u) + w)
        Stop when d_N = d_{N+1}

    Complexity:
        Time: O(|V| × |E|) — at most |V| relaxation passes
        Space: O(|V|) for distance array

    This is the tropical analogue of closure iteration:
    - Boolean closure: "is formula derivable?"
    - Tropical Bellman-Ford: "what is the minimum cost to derive it?"

    Args:
        vertices: List of vertex identifiers
        edges: List of (source, destination, weight) triples
        source: Source vertex

    Returns:
        BellmanResult with distances and convergence data
    """
    d = {v: 0 if v == source else INF for v in vertices}
    parent = {v: None for v in vertices}
    history = [dict(d)]

    for iteration in range(len(vertices)):
        new_d = dict(d)
        changed = False

        for u, v, w in edges:
            if d[u] + w < new_d[v]:
                new_d[v] = d[u] + w
                parent[v] = u
                changed = True

        history.append(dict(new_d))

        if not changed:
            return BellmanResult(d, iteration, history, parent)

        d = new_d

    return BellmanResult(d, len(vertices), history, parent)


def reconstruct_path(parent: Dict, source, target) -> List:
    """Reconstruct shortest path from parent pointers."""
    if parent[target] is None and target != source:
        return []
    path = [target]
    current = target
    while current != source:
        current = parent[current]
        if current is None:
            return []
        path.append(current)
    return list(reversed(path))


# ============================================================
# Algorithm 4: Min-Plus Matrix Powers (Kleene Star)
# ============================================================

def minplus_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus (tropical) matrix multiplication.

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    This replaces standard (×, +) with (+, min).
    """
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def kleene_star_truncated(M: np.ndarray, N: int) -> np.ndarray:
    """
    Compute truncated Kleene star: I ⊕ M ⊕ M² ⊕ ... ⊕ M^N

    In the min-plus semiring, this gives shortest paths of length ≤ N.

    Algorithm:
        K = I (identity: 0 on diagonal, ∞ elsewhere)
        P = I
        for i in 1..N:
            P = P ⊗ M
            K = K ⊕ P (elementwise min)
        return K

    Complexity:
        Time: O(N × n³) where n = matrix dimension
        Space: O(n²)
    """
    n = M.shape[0]
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)

    K = I.copy()
    P = I.copy()

    for _ in range(N):
        P = minplus_multiply(P, M)
        K = np.minimum(K, P)

    return K


def demonstrate_kleene_star():
    """Demonstrate Kleene star computation on demo graph."""
    # Adjacency matrix for demo graph
    M = np.full((4, 4), INF)
    M[0, 1] = 2
    M[1, 2] = 1
    M[0, 2] = 5
    M[2, 3] = 3

    print("Min-plus adjacency matrix M:")
    for i in range(4):
        row = [str(int(M[i, j])) if M[i, j] < INF else "∞" for j in range(4)]
        print(f"  {row}")

    for N in range(1, 5):
        K = kleene_star_truncated(M, N)
        print(f"\nKleene star truncated at N={N}:")
        for i in range(4):
            row = [str(int(K[i, j])) if K[i, j] < INF else "∞" for j in range(4)]
            print(f"  {row}")

    K3 = kleene_star_truncated(M, 3)
    K4 = kleene_star_truncated(M, 4)
    print(f"\nK*(3) == K*(4): {np.array_equal(K3, K4)}")
    print(f"Stabilization at N=3 ≤ |V|-1=3 ✓")

    print(f"\nShortest distances from vertex 0:")
    for j in range(4):
        d = K3[0, j]
        print(f"  d(0, {j}) = {int(d) if d < INF else '∞'}")


if __name__ == "__main__":
    # Demo 1: Monotone closure
    rules_demo = [
        InferenceRule(frozenset({0}), 1, "r1"),
        InferenceRule(frozenset({1}), 2, "r2"),
        InferenceRule(frozenset({0}), 2, "r3"),
        InferenceRule(frozenset({2}), 3, "r4"),
    ]

    step_fn = build_step_rules(rules_demo)
    result = monotone_closure(step_fn, {0})
    print("Monotone closure result:", result)
    print(f"Chain: {[sorted(s) for s in result.chain]}")

    # Demo 2: Derivation tree
    tree = find_derivation(rules_demo, {0}, 3)
    if tree:
        print(f"\nDerivation tree for 3:")
        print(tree.pretty())

    # Demo 3: Bellman-Ford
    bf = tropical_bellman_ford(
        [0, 1, 2, 3],
        [(0, 1, 2), (1, 2, 1), (0, 2, 5), (2, 3, 3)],
        0
    )
    print(f"\nBellman-Ford distances: {bf.distances}")
    print(f"Stabilization step: {bf.stabilization_step}")
    for v in [1, 2, 3]:
        path = reconstruct_path(bf.parent, 0, v)
        print(f"  Shortest path to {v}: {' → '.join(map(str, path))}")

    # Demo 4: Kleene star
    print()
    demonstrate_kleene_star()
