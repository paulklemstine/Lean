#!/usr/bin/env python3
"""
Algorithms for Tropical Trace Semantics

Implements the core algorithms from the research paper:
1. Weighted trace cost computation
2. Optimal potential function via Bellman-Ford (Karp's algorithm variant)
3. Tropical spectral radius (maximum cycle mean) computation
4. Gauge transformation / amortized cost reweighting
"""

from __future__ import annotations
import numpy as np
from typing import Callable, Dict, List, Optional, Tuple


# ── Data Structures ───────────────────────────────────────────────────────

class WeightedAutomaton:
    """
    A deterministic weighted automaton over a finite state space.

    Attributes:
        n_states: Number of states.
        n_ops: Number of operations.
        step: Transition function (state, op) → state.
        cost: Cost function (state, op) → ℝ.
    """

    def __init__(self, n_states: int, n_ops: int,
                 step: Callable[[int, int], int],
                 cost: Callable[[int, int], float]):
        self.n_states = n_states
        self.n_ops = n_ops
        self.step = step
        self.cost = cost

    def run(self, s: int, w: List[int]) -> int:
        """Execute word w from state s, return final state."""
        for a in w:
            s = self.step(s, a)
        return s

    def trace_cost(self, s: int, w: List[int]) -> float:
        """Compute total cost of trace w from state s.

        Time complexity: O(|w|)
        Space complexity: O(1)
        """
        total = 0.0
        for a in w:
            total += self.cost(s, a)
            s = self.step(s, a)
        return total

    def amortized_cost(self, potential: Callable[[int], float],
                       s: int, a: int) -> float:
        """Compute amortized cost: c(s,a) + φ(step(s,a)) - φ(s).

        Time complexity: O(1)
        """
        return self.cost(s, a) + potential(self.step(s, a)) - potential(s)

    def transition_matrix(self) -> np.ndarray:
        """Build the min-plus transition matrix.

        A[i][j] = min_{a : step(i,a)=j} cost(i,a)

        Time complexity: O(n_states * n_ops)
        Space complexity: O(n_states²)
        """
        INF = float('inf')
        A = np.full((self.n_states, self.n_states), INF)
        for s in range(self.n_states):
            for a in range(self.n_ops):
                t = self.step(s, a)
                c = self.cost(s, a)
                A[s][t] = min(A[s][t], c)
        return A

    def gauge_transform(self, potential: Callable[[int], float]) -> 'WeightedAutomaton':
        """Return a new automaton with gauge-transformed costs.

        New cost: c'(s,a) = c(s,a) + φ(step(s,a)) - φ(s)

        This preserves total cost up to boundary terms (Theorem B).

        Time complexity: O(1) (lazy)
        """
        original_cost = self.cost
        original_step = self.step

        def new_cost(s: int, a: int) -> float:
            return original_cost(s, a) + potential(original_step(s, a)) - potential(s)

        return WeightedAutomaton(self.n_states, self.n_ops, self.step, new_cost)


# ── Algorithm 1: Maximum Cycle Mean (Karp's Algorithm) ────────────────────

def maximum_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the maximum cycle mean of a weighted digraph (= tropical spectral radius).

    Uses Karp's algorithm.

    Given a weight matrix A where A[i][j] is the weight of edge i→j
    (inf if no edge), computes:
        ρ = max over all cycles C of (weight(C) / length(C))

    Algorithm:
        1. Compute F[k][j] = max weight of any k-edge walk ending at j.
        2. ρ = max_j min_k (F[n][j] - F[k][j]) / (n - k)

    Time complexity: O(n³) where n = number of states.
    Space complexity: O(n²).

    Args:
        A: n×n weight matrix. A[i][j] = weight of edge i→j (use -inf for no edge
           in the max-plus convention, or +inf in min-plus; here we use max-plus).

    Returns:
        Maximum cycle mean, or -inf if no cycle exists.
    """
    n = A.shape[0]
    NEG_INF = float('-inf')

    # F[k][j] = max weight of any walk of exactly k edges ending at j
    F = np.full((n + 1, n), NEG_INF)

    # Base case: 0-edge walks from any source have weight 0
    for j in range(n):
        F[0][j] = 0.0

    # Fill: F[k][j] = max_i (F[k-1][i] + A[i][j])
    for k in range(1, n + 1):
        for j in range(n):
            for i in range(n):
                if F[k - 1][i] > NEG_INF and A[i][j] > NEG_INF:
                    F[k][j] = max(F[k][j], F[k - 1][i] + A[i][j])

    # Karp's formula: ρ = max_j min_{0≤k<n} (F[n][j] - F[k][j]) / (n - k)
    rho = NEG_INF
    for j in range(n):
        if F[n][j] > NEG_INF:
            min_val = float('inf')
            for k in range(n):
                if F[k][j] > NEG_INF:
                    val = (F[n][j] - F[k][j]) / (n - k)
                    min_val = min(min_val, val)
            if min_val < float('inf'):
                rho = max(rho, min_val)

    return rho


# ── Algorithm 2: Optimal Potential via Bellman-Ford ───────────────────────

def optimal_potential(A: np.ndarray, B: float) -> Optional[np.ndarray]:
    """
    Find a potential function φ such that A[i][j] + φ[j] - φ[i] ≤ B
    for all edges (i,j), or determine that no such potential exists.

    This is equivalent to finding a feasible solution to the system of
    difference constraints: φ[j] - φ[i] ≤ B - A[i][j].

    Uses the Bellman-Ford algorithm on the constraint graph.

    Time complexity: O(n³) (n iterations of n² edge relaxations).
    Space complexity: O(n).

    Args:
        A: n×n transition weight matrix (inf = no edge).
        B: Target uniform amortized bound.

    Returns:
        Potential vector φ of length n, or None if B < tropical spectral radius.
    """
    n = A.shape[0]
    INF = float('inf')

    # Difference constraints: φ[j] - φ[i] ≤ B - A[i][j]
    # Bellman-Ford: add source node connected to all with weight 0
    phi = np.zeros(n)

    for iteration in range(n):
        updated = False
        for i in range(n):
            for j in range(n):
                if A[i][j] < INF:
                    # Constraint: phi[j] ≤ phi[i] + (B - A[i][j])
                    new_val = phi[i] + (B - A[i][j])
                    if new_val < phi[j] - 1e-12:
                        phi[j] = new_val
                        updated = True
        if not updated:
            break

    # Check for negative cycles (B is infeasible)
    for i in range(n):
        for j in range(n):
            if A[i][j] < INF:
                if phi[i] + (B - A[i][j]) < phi[j] - 1e-10:
                    return None  # B < spectral radius

    return phi


# ── Algorithm 3: Verify Amortized Bound ──────────────────────────────────

def verify_amortized_bound(aut: WeightedAutomaton,
                           potential: Callable[[int], float],
                           B: float) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Verify that a potential function certifies a uniform amortized bound B.

    Checks: ∀ s,a: cost(s,a) + φ(step(s,a)) - φ(s) ≤ B

    Time complexity: O(n_states * n_ops)

    Args:
        aut: Weighted automaton.
        potential: Potential function.
        B: Claimed uniform bound.

    Returns:
        (True, None) if bound holds; (False, (s,a)) for a counterexample.
    """
    for s in range(aut.n_states):
        for a in range(aut.n_ops):
            amort = aut.amortized_cost(potential, s, a)
            if amort > B + 1e-10:
                return False, (s, a)
    return True, None


# ── Algorithm 4: Tropical Matrix Power (Min-Plus) ────────────────────────

def minplus_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: C[i][j] = min_k (A[i][k] + B[k][j]).

    Time complexity: O(n³).
    """
    n = A.shape[0]
    INF = float('inf')
    C = np.full((n, n), INF)
    for i in range(n):
        for k in range(n):
            if A[i][k] < INF:
                for j in range(n):
                    if B[k][j] < INF:
                        C[i][j] = min(C[i][j], A[i][k] + B[k][j])
    return C


def minplus_power(A: np.ndarray, k: int) -> np.ndarray:
    """
    Compute k-th min-plus power of matrix A.

    A^k[i][j] = minimum weight of any k-step path from i to j.

    Time complexity: O(n³ log k) using repeated squaring.
    """
    n = A.shape[0]
    if k == 0:
        # Identity: 0 on diagonal, inf elsewhere
        I = np.full((n, n), float('inf'))
        np.fill_diagonal(I, 0.0)
        return I
    if k == 1:
        return A.copy()

    half = minplus_power(A, k // 2)
    result = minplus_matmul(half, half)
    if k % 2 == 1:
        result = minplus_matmul(result, A)
    return result


# ── Algorithm 5: Kleene Star (All-Pairs Shortest Paths) ──────────────────

def minplus_kleene_star(A: np.ndarray) -> np.ndarray:
    """
    Compute the min-plus Kleene star: A* = I ⊕ A ⊕ A² ⊕ A³ ⊕ ...

    A*[i][j] = minimum weight of any path from i to j (including empty path).

    Uses Floyd-Warshall.

    Time complexity: O(n³).
    Space complexity: O(n²).
    """
    n = A.shape[0]
    D = A.copy()
    # Set diagonal to 0 (empty path)
    for i in range(n):
        D[i][i] = min(D[i][i], 0.0)

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]
    return D


# ── Example Usage ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Trace Semantics — Algorithm Demonstrations")
    print("=" * 60)

    # Build a 3-state automaton
    transitions = {
        (0, 0): (1, 1.0), (0, 1): (2, 3.0),
        (1, 0): (2, 2.0), (1, 1): (0, 1.0),
        (2, 0): (0, 4.0), (2, 1): (1, 1.0),
    }

    aut = WeightedAutomaton(
        n_states=3, n_ops=2,
        step=lambda s, a: transitions[(s, a)][0],
        cost=lambda s, a: transitions[(s, a)][1],
    )

    # 1. Transition matrix
    A = aut.transition_matrix()
    print("\nTransition matrix (min-plus):")
    print(A)

    # 2. Maximum cycle mean
    # Convert to max-plus for Karp's algorithm
    A_max = np.where(A < float('inf'), A, float('-inf'))
    rho = maximum_cycle_mean(A_max)
    print(f"\nTropical spectral radius (max cycle mean): ρ = {rho:.4f}")

    # 3. Find optimal potential for B = rho
    phi = optimal_potential(A, rho)
    if phi is not None:
        print(f"\nOptimal potential for B = ρ: φ = {phi}")
        # Verify
        valid, cex = verify_amortized_bound(aut, lambda s: phi[s], rho)
        print(f"Verification: {'PASS' if valid else f'FAIL at {cex}'}")

    # 4. Min-plus powers
    print("\nMin-plus matrix powers (shortest k-step path weights):")
    for k in [1, 2, 3, 5]:
        Ak = minplus_power(A, k)
        print(f"  A^{k} diagonal (min cycle of length {k} from each state):")
        print(f"    {[f'{Ak[i][i]:.1f}' for i in range(3)]}")

    # 5. Kleene star
    D = minplus_kleene_star(A)
    print(f"\nKleene star (all-pairs shortest paths):")
    print(D)
