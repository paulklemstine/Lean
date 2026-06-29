#!/usr/bin/env python3
"""
Algorithms for Tropical Transfer Operators and Partition Functions

Implements the core algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass

INF = float('inf')


# =============================================================================
# Core Data Structures
# =============================================================================

@dataclass
class TropicalMatrix:
    """A matrix over the tropical (min-plus) semiring.

    Elements are in ℝ ∪ {∞}, where:
    - Tropical addition = min
    - Tropical multiplication = +
    - Additive identity = ∞
    - Multiplicative identity = 0
    """
    data: np.ndarray

    @property
    def shape(self) -> Tuple[int, int]:
        return self.data.shape

    @property
    def w(self) -> int:
        return self.data.shape[0]

    @staticmethod
    def identity(w: int) -> 'TropicalMatrix':
        """Tropical identity matrix: 0 on diagonal, ∞ elsewhere.

        Time: O(w²), Space: O(w²)
        """
        M = np.full((w, w), INF)
        np.fill_diagonal(M, 0.0)
        return TropicalMatrix(M)

    def __matmul__(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """Tropical matrix multiplication: (A⊗B)[i,j] = min_k (A[i,k] + B[k,j]).

        Time: O(w³), Space: O(w²)
        """
        w = self.w
        result = np.full((w, w), INF)
        for i in range(w):
            for j in range(w):
                for k in range(w):
                    result[i, j] = min(result[i, j],
                                       self.data[i, k] + other.data[k, j])
        return TropicalMatrix(result)

    def mul_vec(self, v: np.ndarray) -> np.ndarray:
        """Tropical matrix-vector product: (M⬝v)[j] = min_i (v[i] + M[i,j]).

        Time: O(w²), Space: O(w)
        """
        w = self.w
        result = np.full(w, INF)
        for j in range(w):
            for i in range(w):
                result[j] = min(result[j], v[i] + self.data[i, j])
        return result

    def __repr__(self) -> str:
        return f"TropicalMatrix(\n{self.data}\n)"


@dataclass
class MinPlusBP:
    """A layered min-plus branching program.

    Attributes:
        w: Width (number of nodes per layer)
        d: Depth (number of layers/transitions)
        edge_costs: List of d transfer matrices, each w×w
        start: Index of start node (0 ≤ start < w)
        accept: Index of accept node (0 ≤ accept < w)
    """
    w: int
    d: int
    edge_costs: List[TropicalMatrix]
    start: int
    accept: int

    def start_vec(self) -> np.ndarray:
        """Initial state vector: 0 at start, ∞ elsewhere.

        Time: O(w), Space: O(w)
        """
        v = np.full(self.w, INF)
        v[self.start] = 0.0
        return v

    def transfer_matrix(self, i: int) -> TropicalMatrix:
        """Transfer matrix at layer i.

        Time: O(1), Space: O(1)
        """
        return self.edge_costs[i]


# =============================================================================
# Algorithm 1: Layer State Computation (Bellman Propagation)
# =============================================================================

def compute_layer_states(bp: MinPlusBP) -> List[np.ndarray]:
    """Compute all layer states by iterative Bellman propagation.

    This implements the dynamic programming recurrence:
        state[0] = startVec
        state[k+1] = M_k ⬝ state[k]

    where M_k is the transfer matrix at layer k and ⬝ is tropical
    matrix-vector multiplication.

    Args:
        bp: A min-plus branching program

    Returns:
        List of d+1 state vectors, one per layer

    Time Complexity: O(d · w²)
    Space Complexity: O(d · w) for all states, O(w) if only final needed

    Pseudocode:
        BELLMAN-PROPAGATION(BP):
        1. state ← startVec(BP)
        2. states ← [state]
        3. for k = 0 to d-1:
        4.     state ← tropMulVec(M_k, state)
        5.     states.append(state)
        6. return states
    """
    states = [bp.start_vec()]
    state = states[0].copy()
    for k in range(bp.d):
        state = bp.transfer_matrix(k).mul_vec(state)
        states.append(state.copy())
    return states


# =============================================================================
# Algorithm 2: Transfer Product Computation
# =============================================================================

def compute_transfer_product(bp: MinPlusBP, up_to: Optional[int] = None
                             ) -> TropicalMatrix:
    """Compute the prefix product of transfer matrices.

    Computes M_0 ⊗ M_1 ⊗ ... ⊗ M_{i-1} in the tropical semiring.

    Args:
        bp: A min-plus branching program
        up_to: Number of matrices to include (default: all d)

    Returns:
        The tropical product matrix

    Time Complexity: O(i · w³)
    Space Complexity: O(w²)

    Pseudocode:
        TRANSFER-PRODUCT(BP, i):
        1. prod ← I_trop  (tropical identity)
        2. for k = 0 to i-1:
        3.     prod ← prod ⊗ M_k
        4. return prod
    """
    if up_to is None:
        up_to = bp.d
    prod = TropicalMatrix.identity(bp.w)
    for k in range(up_to):
        prod = prod @ bp.transfer_matrix(k)
    return prod


# =============================================================================
# Algorithm 3: Min-Cost Path Extraction
# =============================================================================

def min_cost_with_certificate(bp: MinPlusBP
                              ) -> Tuple[float, Optional[List[int]]]:
    """Compute minimum cost and extract an optimal path.

    Uses forward Bellman propagation followed by backward path tracing.

    Args:
        bp: A min-plus branching program

    Returns:
        (min_cost, optimal_path) where optimal_path is a list of node
        indices from start to accept, or None if no path exists.

    Time Complexity: O(d · w²) for propagation + O(d · w) for traceback
    Space Complexity: O(d · w)

    Pseudocode:
        MIN-COST-WITH-PATH(BP):
        1. states ← BELLMAN-PROPAGATION(BP)
        2. cost ← states[d][accept]
        3. if cost = ∞: return (∞, None)
        4. // Backward traceback
        5. path ← [accept]
        6. for k = d-1 downto 0:
        7.     for u = 0 to w-1:
        8.         if states[k][u] + M_k[u, path[0]] = states[k+1][path[0]]:
        9.             path.prepend(u)
        10.            break
        11. return (cost, path)
    """
    states = compute_layer_states(bp)
    cost = states[bp.d][bp.accept]

    if cost == INF:
        return cost, None

    # Backward traceback
    path = [bp.accept]
    for k in range(bp.d - 1, -1, -1):
        target = path[0]
        for u in range(bp.w):
            edge_cost = bp.edge_costs[k].data[u, target]
            if states[k][u] + edge_cost == states[k + 1][target]:
                path.insert(0, u)
                break

    return cost, path


# =============================================================================
# Algorithm 4: Tropical Partition Function at Finite Temperature
# =============================================================================

def partition_function(bp: MinPlusBP, temperature: float) -> float:
    """Compute the partition function Z(T) = Σ_p exp(-cost(p)/T).

    At temperature T > 0, this uses the log-sum-exp (softmin) operation
    instead of min. As T → 0, this converges to the tropical (min-plus)
    result.

    The "free energy" F = -T · log(Z) converges to the minimum path cost
    as T → 0 — this is the tropical/zero-temperature limit.

    Args:
        bp: A min-plus branching program
        temperature: Temperature parameter T > 0

    Returns:
        Free energy F = -T · log(Z)

    Time Complexity: O(d · w²) using softmin propagation
    Space Complexity: O(w)

    Pseudocode:
        SOFTMIN-PROPAGATION(BP, T):
        1. state ← startVec(BP)  // 0 at start, ∞ elsewhere
        2. for k = 0 to d-1:
        3.     for j = 0 to w-1:
        4.         new_state[j] ← -T · log(Σ_i exp(-(state[i] + M_k[i,j])/T))
        5.     state ← new_state
        6. return state[accept]
    """
    T = temperature

    # Initialize: 0 at start, ∞ elsewhere
    # In log-space: exp(-0/T) = 1 at start, exp(-∞/T) = 0 elsewhere
    state = bp.start_vec()

    for k in range(bp.d):
        M = bp.edge_costs[k].data
        new_state = np.full(bp.w, INF)
        for j in range(bp.w):
            # Compute softmin: -T * log(sum_i exp(-(state[i] + M[i,j])/T))
            costs = np.array([state[i] + M[i, j] for i in range(bp.w)])
            finite_costs = costs[costs < INF]
            if len(finite_costs) > 0:
                # Use log-sum-exp trick for numerical stability
                min_cost = np.min(finite_costs)
                new_state[j] = min_cost - T * np.log(
                    np.sum(np.exp(-(finite_costs - min_cost) / T))
                )
            # else: remains ∞
        state = new_state

    return state[bp.accept]


# =============================================================================
# Algorithm 5: Transfer Rank Estimation
# =============================================================================

def tropical_rank(M: TropicalMatrix, threshold: float = 1e-10) -> int:
    """Estimate the tropical rank of a matrix.

    The tropical rank is the minimum number of tropical rank-1 matrices
    whose tropical sum (pointwise min) equals M. This is an NP-hard problem
    in general, so we use a heuristic based on the "Barvinok rank" approach.

    We estimate via the ordinary rank of the "dequantized" matrix
    exp(-M/ε) for small ε, which provides an upper bound.

    Args:
        M: A tropical matrix
        threshold: Singular value threshold

    Returns:
        Estimated tropical rank (upper bound)

    Time Complexity: O(w³) via SVD
    Space Complexity: O(w²)
    """
    w = M.w
    # Replace INF with a large finite value for numerical computation
    data = M.data.copy()
    max_finite = np.max(data[data < INF]) if np.any(data < INF) else 0
    data[data == INF] = max_finite + 100

    # Dequantize: compute exp(-M/ε) for small ε
    epsilon = 0.1
    deq = np.exp(-data / epsilon)

    # Compute ordinary rank via SVD
    _, s, _ = np.linalg.svd(deq)
    rank = np.sum(s > threshold * s[0])
    return int(rank)


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    print("Tropical Transfer Operator Algorithms")
    print("=" * 50)

    # Create a sample branching program
    w, d = 4, 3
    np.random.seed(42)
    edge_costs = []
    for _ in range(d):
        M = np.random.randint(1, 10, (w, w)).astype(float)
        mask = np.random.random((w, w)) > 0.7
        M[mask] = INF
        edge_costs.append(TropicalMatrix(M))

    bp = MinPlusBP(w, d, edge_costs, start=0, accept=3)

    # Algorithm 1: Layer states
    print("\n1. Layer State Computation:")
    states = compute_layer_states(bp)
    for i, s in enumerate(states):
        s_str = [f"{x:.0f}" if x < INF else "∞" for x in s]
        print(f"   Layer {i}: [{', '.join(s_str)}]")

    # Algorithm 2: Transfer product
    print("\n2. Transfer Product:")
    prod = compute_transfer_product(bp)
    result = prod.mul_vec(bp.start_vec())
    r_str = [f"{x:.0f}" if x < INF else "∞" for x in result]
    print(f"   Product · startVec = [{', '.join(r_str)}]")

    # Algorithm 3: Min cost with path
    print("\n3. Min-Cost Path:")
    cost, path = min_cost_with_certificate(bp)
    print(f"   Cost: {cost}")
    print(f"   Path: {path}")

    # Algorithm 4: Partition function
    print("\n4. Partition Function (Temperature Sweep):")
    for T in [10.0, 1.0, 0.1, 0.01]:
        F = partition_function(bp, T)
        print(f"   T={T:6.2f}: F = {F:.4f}")
    print(f"   T→0:     min cost = {cost}")

    # Algorithm 5: Tropical rank
    print("\n5. Tropical Rank Estimation:")
    for i, M in enumerate(edge_costs):
        r = tropical_rank(M)
        print(f"   Layer {i} matrix rank ≤ {r}")
