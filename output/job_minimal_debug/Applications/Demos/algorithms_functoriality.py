#!/usr/bin/env python3
"""
Tropical Functorial Surgery Calculus — Algorithms

Implements the core algorithms from the research paper:
1. Min-plus matrix multiplication (tropical convolution)
2. Iterated tropical power (all-pairs shortest paths)
3. Surgery pipeline optimizer
4. Tropical eigenvalue computation
5. Weighted automaton composition
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Min-Plus Matrix Multiplication
# ═══════════════════════════════════════════════════════════════════════

def min_plus_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication.

    Computes C[i,k] = min_j (A[i,j] + B[j,k])

    Time complexity: O(m·n·p) for m×n and n×p matrices
    Space complexity: O(m·p) for the output

    Args:
        A: m×n cost matrix
        B: n×p cost matrix

    Returns:
        m×p min-plus product matrix
    """
    m, n = A.shape
    n2, p = B.shape
    assert n == n2, f"Inner dimensions mismatch: {n} vs {n2}"

    C = np.full((m, p), np.inf)
    for i in range(m):
        for k in range(p):
            for j in range(n):
                val = A[i, j] + B[j, k]
                if val < C[i, k]:
                    C[i, k] = val
    return C


def min_plus_mul_with_witness(A: np.ndarray, B: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Min-plus multiplication with optimal intermediate state witness.

    Returns both the product matrix and a witness matrix W where
    W[i,k] = argmin_j (A[i,j] + B[j,k]).

    Time complexity: O(m·n·p)
    """
    m, n = A.shape
    n2, p = B.shape
    assert n == n2

    C = np.full((m, p), np.inf)
    W = np.full((m, p), -1, dtype=int)

    for i in range(m):
        for k in range(p):
            for j in range(n):
                val = A[i, j] + B[j, k]
                if val < C[i, k]:
                    C[i, k] = val
                    W[i, k] = j
    return C, W


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Matrix Power (All-Pairs Shortest Paths)
# ═══════════════════════════════════════════════════════════════════════

def tropical_power(W: np.ndarray, k: int) -> np.ndarray:
    """Compute k-th tropical power of a square matrix by repeated squaring.

    W^⊛k gives shortest paths using at most k edges.

    Time complexity: O(n³ · log k)
    Space complexity: O(n²)
    """
    n = W.shape[0]
    assert W.shape[1] == n, "Matrix must be square"
    assert k >= 1

    result = W.copy()
    base = W.copy()
    k -= 1

    while k > 0:
        if k % 2 == 1:
            result = min_plus_mul(result, base)
        base = min_plus_mul(base, base)
        k //= 2

    return result


def tropical_closure(W: np.ndarray) -> np.ndarray:
    """Compute tropical closure W* = I ⊛ W ⊛ W² ⊛ ... = all-pairs shortest paths.

    Equivalent to Floyd-Warshall.

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = min(D[i, j], D[i, k] + D[k, j])
    return D


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Surgery Pipeline Optimizer
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class Surgery:
    """A surgery between finite boundary state sets.

    Attributes:
        cost: m×n cost matrix where cost[i,j] is the transition cost
              from input state i to output state j
        name: optional label for the surgery
    """
    cost: np.ndarray
    name: str = ""

    @property
    def input_dim(self) -> int:
        return self.cost.shape[0]

    @property
    def output_dim(self) -> int:
        return self.cost.shape[1]


def compose_surgeries(s1: Surgery, s2: Surgery) -> Surgery:
    """Compose two surgeries via Bellman minimization.

    The composed surgery has cost(a,c) = min_b (s1.cost(a,b) + s2.cost(b,c)).

    Time complexity: O(m·n·p)
    """
    assert s1.output_dim == s2.input_dim, \
        f"Dimension mismatch: {s1.output_dim} vs {s2.input_dim}"
    return Surgery(
        cost=min_plus_mul(s1.cost, s2.cost),
        name=f"({s1.name} ∘ {s2.name})" if s1.name and s2.name else ""
    )


def compose_pipeline(surgeries: List[Surgery]) -> Surgery:
    """Compose a pipeline of surgeries left-to-right.

    By associativity (our proven theorem), grouping doesn't matter.

    Time complexity: O(sum of pairwise products)
    """
    assert len(surgeries) >= 1
    result = surgeries[0]
    for s in surgeries[1:]:
        result = compose_surgeries(result, s)
    return result


def optimal_path(surgeries: List[Surgery], start: int, end: int) -> Tuple[float, List[int]]:
    """Find the optimal path through a surgery pipeline.

    Returns (cost, path) where path lists the intermediate states
    chosen at each stage.

    Time complexity: O(n² · k) for k surgeries with max dimension n
    """
    k = len(surgeries)
    if k == 0:
        return (0.0, [start, end])

    # Forward pass: compute optimal costs
    n_stages = k + 1
    dims = [surgeries[0].input_dim] + [s.output_dim for s in surgeries]
    # dp[stage][state] = min cost to reach that state from start
    dp = [np.full(d, np.inf) for d in dims]
    parent = [np.full(d, -1, dtype=int) for d in dims]
    dp[0][start] = 0.0

    for t in range(k):
        S = surgeries[t].cost
        for j in range(dims[t + 1]):
            for i in range(dims[t]):
                val = dp[t][i] + S[i, j]
                if val < dp[t + 1][j]:
                    dp[t + 1][j] = val
                    parent[t + 1][j] = i

    # Backward pass: reconstruct path
    path = [end]
    for t in range(k, 0, -1):
        path.append(parent[t][path[-1]])
    path.reverse()

    return dp[k][end], path


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Tropical Eigenvalue (Critical Circuit)
# ═══════════════════════════════════════════════════════════════════════

def tropical_eigenvalue(W: np.ndarray) -> float:
    """Compute the tropical eigenvalue (minimum cycle mean) of a square matrix.

    The tropical eigenvalue λ satisfies W ⊛ v = λ + v for some vector v.
    It equals min over all cycles c of (weight(c) / length(c)).

    This is the critical circuit value in scheduling theory.

    Time complexity: O(n³) using Karp's algorithm
    """
    n = W.shape[0]

    # Compute D[k][i] = min weight path of exactly k edges from node 0 to i
    D = np.full((n + 1, n), np.inf)
    D[0, 0] = 0.0

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                if D[k - 1][j] + W[j, i] < D[k][i]:
                    D[k][i] = D[k - 1][j] + W[j, i]

    # Karp's formula: λ = min_i max_k (D[n][i] - D[k][i]) / (n - k)
    lambda_val = np.inf
    for i in range(n):
        if np.isinf(D[n][i]):
            continue
        max_val = -np.inf
        for k in range(n):
            if not np.isinf(D[k][i]):
                val = (D[n][i] - D[k][i]) / (n - k)
                max_val = max(max_val, val)
        lambda_val = min(lambda_val, max_val)

    return lambda_val


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Weighted Automaton Composition
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class WeightedAutomaton:
    """A weighted automaton as a tropical surgery.

    States correspond to boundary states; transitions carry costs.
    The transition on symbol σ is a Surgery (cost matrix).
    """
    transitions: dict  # symbol -> np.ndarray (cost matrix)
    initial_costs: np.ndarray  # cost to start in each state
    final_costs: np.ndarray    # cost to accept from each state
    n_states: int

    def process_word(self, word: List) -> float:
        """Compute the minimum-cost run on a word.

        Time complexity: O(|word| · n²)
        """
        n = self.n_states
        # current[i] = min cost to be in state i after processing prefix
        current = self.initial_costs.copy()

        for symbol in word:
            T = self.transitions[symbol]
            next_cost = np.full(n, np.inf)
            for j in range(n):
                for i in range(n):
                    val = current[i] + T[i, j]
                    if val < next_cost[j]:
                        next_cost[j] = val
            current = next_cost

        # Add final costs
        return min(current[i] + self.final_costs[i] for i in range(n))


def compose_automata(A1: WeightedAutomaton, A2: WeightedAutomaton) -> WeightedAutomaton:
    """Compose two weighted automata via tropical tensor product.

    The composed automaton has states (i,j) for states i of A1 and j of A2.
    This is the tropical analogue of the tensor product of linear maps.

    Time complexity: O(n₁² · n₂² · |Σ|) for construction
    """
    n1, n2 = A1.n_states, A2.n_states
    n = n1 * n2

    transitions = {}
    common_symbols = set(A1.transitions.keys()) & set(A2.transitions.keys())

    for symbol in common_symbols:
        T1 = A1.transitions[symbol]
        T2 = A2.transitions[symbol]
        T = np.full((n, n), np.inf)
        for i1 in range(n1):
            for i2 in range(n2):
                for j1 in range(n1):
                    for j2 in range(n2):
                        T[i1 * n2 + i2, j1 * n2 + j2] = T1[i1, j1] + T2[i2, j2]
        transitions[symbol] = T

    initial = np.full(n, np.inf)
    final = np.full(n, np.inf)
    for i1 in range(n1):
        for i2 in range(n2):
            initial[i1 * n2 + i2] = A1.initial_costs[i1] + A2.initial_costs[i2]
            final[i1 * n2 + i2] = A1.final_costs[i1] + A2.final_costs[i2]

    return WeightedAutomaton(transitions, initial, final, n)


# ═══════════════════════════════════════════════════════════════════════
# Main: Run all algorithm demonstrations
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Demo: Surgery pipeline
    print("\n--- Surgery Pipeline Optimization ---")
    pipeline = [
        Surgery(np.array([[1, 3, 7], [2, 1, 5]], dtype=float), "preprocess"),
        Surgery(np.array([[4, 2], [1, 3], [5, 1]], dtype=float), "transform"),
        Surgery(np.array([[2, 1, 3], [4, 2, 1]], dtype=float), "postprocess"),
    ]

    composed = compose_pipeline(pipeline)
    print(f"Pipeline: {' → '.join(s.name for s in pipeline)}")
    print(f"Composed cost matrix:\n{composed.cost}")

    cost, path = optimal_path(pipeline, start=0, end=2)
    print(f"Optimal path from state 0 to output 2: {path}, cost = {cost}")

    # Demo: Tropical eigenvalue
    print("\n--- Tropical Eigenvalue (Critical Circuit) ---")
    W = np.array([
        [np.inf, 2, np.inf],
        [np.inf, np.inf, 3],
        [1, np.inf, np.inf]
    ], dtype=float)
    lam = tropical_eigenvalue(W)
    print(f"Cycle matrix:\n{W}")
    print(f"Tropical eigenvalue (min cycle mean): {lam}")
    print(f"Expected: (2+3+1)/3 = {(2+3+1)/3}")

    # Demo: Weighted automaton
    print("\n--- Weighted Automaton Composition ---")
    aut = WeightedAutomaton(
        transitions={
            'a': np.array([[1, 3], [2, 1]], dtype=float),
            'b': np.array([[4, 2], [1, 5]], dtype=float),
        },
        initial_costs=np.array([0, np.inf]),
        final_costs=np.array([np.inf, 0]),
        n_states=2
    )
    word = ['a', 'b', 'a']
    cost = aut.process_word(word)
    print(f"Automaton processes word {''.join(word)} with minimum cost: {cost}")

    # Demo: Tropical closure = all-pairs shortest paths
    print("\n--- Tropical Closure (All-Pairs Shortest Paths) ---")
    G = np.array([
        [0, 1, np.inf, np.inf],
        [np.inf, 0, 2, np.inf],
        [np.inf, np.inf, 0, 3],
        [4, np.inf, np.inf, 0]
    ], dtype=float)
    D = tropical_closure(G)
    print(f"Graph adjacency:\n{G}")
    print(f"Shortest paths:\n{D}")

    print("\n" + "=" * 70)
    print("All algorithm demonstrations completed!")
    print("=" * 70)
