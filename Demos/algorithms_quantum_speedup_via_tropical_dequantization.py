#!/usr/bin/env python3
"""
Tropical Dequantization — Algorithm Implementations

Complete implementations of the tropical algorithms from the research paper,
with docstrings, type hints, and example usage.
"""

import numpy as np
from typing import Dict, List, Set, Tuple, Optional, Callable
from dataclasses import dataclass

INF = float('inf')


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass
class BranchingProgram:
    """A weighted branching program (finite DAG with edge weights).

    Attributes:
        states: List of state identifiers.
        next: Mapping from each state to its list of successors.
        weights: Mapping from (source, target) to edge weight.
        accepting: Set of accepting states.
    """
    states: List[int]
    next: Dict[int, List[int]]
    weights: Dict[Tuple[int, int], float]
    accepting: Set[int]

    @property
    def edge_count(self) -> int:
        """Total number of edges."""
        return sum(len(succs) for succs in self.next.values())

    @property
    def eval_cost(self) -> int:
        """Evaluation cost: edges + states."""
        return self.edge_count + len(self.states)


# ============================================================================
# Algorithm 1: Tropical Bellman Value Recursion
# ============================================================================

def tropical_value_bounded(
    bp: BranchingProgram,
    depth: int,
    state: int,
    memo: Optional[Dict[Tuple[int, int], float]] = None
) -> float:
    """Compute the tropical value at bounded depth via memoized recursion.

    This is the min-plus analogue of amplitude propagation:
    - Accepting states have value 0 (success at no additional cost)
    - Non-accepting states at depth 0 have value ∞ (unreachable)
    - At depth d+1, value = min over successors of (weight + value at depth d)

    Args:
        bp: The branching program.
        depth: Maximum recursion depth.
        state: Current state.
        memo: Memoization dictionary (created if None).

    Returns:
        The minimum cost of reaching an accepting state from `state`
        within `depth` steps.

    Complexity: O(edge_count + |states|) with memoization.

    Example:
        >>> bp = BranchingProgram(
        ...     states=[0, 1, 2],
        ...     next={0: [1, 2], 1: [], 2: []},
        ...     weights={(0,1): 3, (0,2): 5},
        ...     accepting={1, 2}
        ... )
        >>> tropical_value_bounded(bp, 2, 0)
        3.0
    """
    if memo is None:
        memo = {}

    key = (depth, state)
    if key in memo:
        return memo[key]

    if state in bp.accepting:
        memo[key] = 0.0
        return 0.0

    if depth == 0:
        memo[key] = INF
        return INF

    successors = bp.next.get(state, [])
    if not successors:
        memo[key] = INF
        return INF

    value = min(
        bp.weights.get((state, t), INF) + tropical_value_bounded(bp, depth - 1, t, memo)
        for t in successors
    )
    memo[key] = value
    return value


def tropical_value_full(bp: BranchingProgram, state: int) -> float:
    """Compute the tropical value with depth = number of states (sufficient for DAGs).

    Args:
        bp: The branching program (should be acyclic).
        state: Starting state.

    Returns:
        The minimum cost of any accepting path from `state`.
    """
    return tropical_value_bounded(bp, len(bp.states), state)


# ============================================================================
# Algorithm 2: Softmin Computation
# ============================================================================

def softmin(energies: np.ndarray, beta: float) -> float:
    """Compute the softmin (negative free energy) of an energy landscape.

    softmin(E, β) = -(1/β) · log(Σ exp(-β · E(x)))

    This is the smooth approximation to min(E) that converges to the
    true minimum as β → ∞ (zero-temperature / tropical limit).

    Args:
        energies: Array of energy values.
        beta: Inverse temperature (must be > 0).

    Returns:
        The softmin value.

    Complexity: O(n) where n = len(energies).

    Numerical stability: Uses the log-sum-exp trick to avoid overflow.

    Example:
        >>> softmin(np.array([1.0, 2.0, 3.0]), beta=10.0)  # ≈ 1.0
    """
    assert beta > 0, "Inverse temperature must be positive"

    # Log-sum-exp trick for numerical stability
    shifted = -beta * energies
    max_val = np.max(shifted)
    log_sum = max_val + np.log(np.sum(np.exp(shifted - max_val)))

    return -(1.0 / beta) * log_sum


def softmin_bounds(energies: np.ndarray, beta: float) -> Tuple[float, float, float]:
    """Compute softmin and verify the sandwich bounds.

    Returns (lower_bound, softmin_value, upper_bound) where:
    - lower_bound = min(E) - log(n)/β
    - upper_bound = min(E)
    - lower_bound ≤ softmin_value ≤ upper_bound (guaranteed by theorem)

    Args:
        energies: Array of energy values.
        beta: Inverse temperature (must be > 0).

    Returns:
        Tuple of (lower_bound, softmin_value, upper_bound).
    """
    n = len(energies)
    min_E = np.min(energies)
    sm = softmin(energies, beta)
    lower = min_E - np.log(n) / beta
    upper = min_E
    return lower, sm, upper


# ============================================================================
# Algorithm 3: Tropical Search
# ============================================================================

def tropical_search(predicate: Callable[[int], bool], n: int) -> Optional[int]:
    """Find the minimum index satisfying a predicate via tropical aggregation.

    This is the tropical analogue of quantum search: instead of using
    quantum interference to find marked items, we use min-plus aggregation.

    Args:
        predicate: Function from index to bool (True = marked).
        n: Size of the search space.

    Returns:
        The minimum index i such that predicate(i) is True,
        or None if no such index exists.

    Complexity: O(n) — linear scan with min aggregation.

    Example:
        >>> tropical_search(lambda i: i % 7 == 0 and i > 0, 100)
        7
    """
    result = None
    for i in range(n):
        if predicate(i):
            if result is None or i < result:
                result = i
    return result


def tropical_search_divide_conquer(
    predicate: Callable[[int], bool],
    lo: int,
    hi: int
) -> Optional[int]:
    """Find the minimum marked index via divide-and-conquer.

    Splits the search space in half, recursively searches each half,
    and takes the minimum (tropical interference principle).

    Args:
        predicate: Function from index to bool.
        lo: Lower bound (inclusive).
        hi: Upper bound (exclusive).

    Returns:
        Minimum index in [lo, hi) satisfying predicate, or None.

    Complexity: O(hi - lo) total work, O(log(hi - lo)) recursion depth.
    """
    if lo >= hi:
        return None
    if hi - lo == 1:
        return lo if predicate(lo) else None

    mid = (lo + hi) // 2
    left = tropical_search_divide_conquer(predicate, lo, mid)
    right = tropical_search_divide_conquer(predicate, mid, hi)

    if left is None:
        return right
    if right is None:
        return left
    return min(left, right)  # Tropical interference: min of branch results


# ============================================================================
# Algorithm 4: Tropical Matrix Multiplication
# ============================================================================

def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication (min-plus).

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    This is the path-cost propagation operation: if A encodes 1-step costs
    and B encodes d-step costs, then A ⊗ B encodes (d+1)-step costs.

    Args:
        A: Matrix with entries in ℝ ∪ {∞} (use np.inf for no edge).
        B: Matrix with entries in ℝ ∪ {∞}.

    Returns:
        Tropical product matrix.

    Complexity: O(n³) for n×n matrices.
    """
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_power(W: np.ndarray, k: int) -> np.ndarray:
    """Compute the k-th tropical power of a weight matrix.

    W^k[i,j] = minimum cost of a walk of length exactly k from i to j.

    Args:
        W: Adjacency weight matrix (np.inf for no edge).
        k: Power (number of steps).

    Returns:
        W^k under tropical multiplication.
    """
    n = W.shape[0]
    result = np.full((n, n), INF)
    np.fill_diagonal(result, 0)  # Identity: 0 on diagonal, ∞ elsewhere

    base = W.copy()
    while k > 0:
        if k % 2 == 1:
            result = tropical_matmul(result, base)
        base = tropical_matmul(base, base)
        k //= 2
    return result


def all_pairs_shortest_paths(W: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths via tropical matrix closure.

    Computes W* = I ⊕ W ⊕ W² ⊕ ... = min over all walk lengths.

    Uses repeated squaring: O(n³ log n).

    Args:
        W: Adjacency weight matrix.

    Returns:
        Shortest-path distance matrix.
    """
    n = W.shape[0]
    # Start with identity
    D = W.copy()
    np.fill_diagonal(D, 0)

    # Floyd-Warshall (equivalent to tropical closure)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i, j] = min(D[i, j], D[i, k] + D[k, j])
    return D


# ============================================================================
# Algorithm 5: Gibbs Sampling at Finite Temperature
# ============================================================================

def gibbs_sample(
    energies: np.ndarray,
    beta: float,
    n_samples: int = 1000,
    rng: Optional[np.random.Generator] = None
) -> np.ndarray:
    """Sample from the Gibbs distribution at inverse temperature β.

    P(x) ∝ exp(-β · E(x))

    As β → ∞, samples concentrate on the minimum-energy state
    (tropical limit).

    Args:
        energies: Array of energy values.
        beta: Inverse temperature.
        n_samples: Number of samples to draw.
        rng: Random number generator.

    Returns:
        Array of sampled indices.
    """
    if rng is None:
        rng = np.random.default_rng(42)

    # Compute probabilities (with numerical stability)
    log_weights = -beta * energies
    log_weights -= np.max(log_weights)  # Shift for stability
    weights = np.exp(log_weights)
    probabilities = weights / np.sum(weights)

    return rng.choice(len(energies), size=n_samples, p=probabilities)


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Tropical Dequantization — Algorithm Examples")
    print("=" * 50)

    # Example 1: Bellman recursion
    print("\n1. Tropical Bellman Value Recursion")
    bp = BranchingProgram(
        states=[0, 1, 2, 3, 4],
        next={0: [1, 2], 1: [3], 2: [3, 4], 3: [], 4: []},
        weights={(0,1): 3, (0,2): 1, (1,3): 2, (2,3): 5, (2,4): 1},
        accepting={3, 4}
    )
    val = tropical_value_full(bp, 0)
    print(f"   Optimal cost from state 0: {val}")
    print(f"   Edge count: {bp.edge_count}")
    print(f"   Eval cost: {bp.eval_cost}")

    # Example 2: Softmin
    print("\n2. Softmin Convergence")
    E = np.array([3.0, 1.0, 4.0, 1.5, 9.0, 2.6])
    for beta in [1, 10, 100]:
        lo, sm, hi = softmin_bounds(E, beta)
        print(f"   β={beta:>3}: softmin={sm:.4f}, min={hi:.4f}, gap={hi-sm:.6f}")

    # Example 3: Tropical search
    print("\n3. Tropical Search")
    result = tropical_search(lambda i: i in {7, 13, 25, 42}, 50)
    print(f"   Minimum marked index: {result}")

    result_dc = tropical_search_divide_conquer(
        lambda i: i in {7, 13, 25, 42}, 0, 50
    )
    print(f"   Divide-and-conquer result: {result_dc}")
    assert result == result_dc

    # Example 4: Tropical matrix
    print("\n4. Tropical Matrix (Shortest Paths)")
    W = np.array([
        [0, 3, INF, INF],
        [INF, 0, 1, INF],
        [INF, INF, 0, 2],
        [INF, INF, INF, 0],
    ])
    D = all_pairs_shortest_paths(W)
    print(f"   Shortest 0→3: {D[0,3]}")  # Should be 6

    # Example 5: Gibbs concentration
    print("\n5. Gibbs Sampling Concentration")
    E = np.array([0.5, 1.0, 2.0, 3.0, 5.0])
    for beta in [1, 10, 100]:
        samples = gibbs_sample(E, beta, n_samples=10000)
        freq_min = np.mean(samples == 0)
        print(f"   β={beta:>3}: P(ground state) = {freq_min:.4f}")

    print("\nAll examples completed successfully.")
