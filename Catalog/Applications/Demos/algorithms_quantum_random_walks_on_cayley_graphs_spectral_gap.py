#!/usr/bin/env python3
"""
Quantum Random Walks on Cayley Graphs: Algorithms
===================================================

Implements the core algorithms for computing spectral gaps, mixing times,
and simulating quantum/classical random walks on Cayley graphs.

Algorithms:
1. CayleyGraph: Build Cayley graphs from group presentations
2. SpectralGapComputer: Compute spectral gap via eigenvalue decomposition
3. ClassicalWalkSimulator: Simulate classical random walks
4. QuantumWalkSimulator: Simulate quantum random walks
5. MixingTimeEstimator: Estimate mixing times from TV distance curves

Complexity analysis included in docstrings.
"""

import numpy as np
from typing import Callable
from itertools import permutations


class CayleyGraph:
    """Cayley graph Cay(G, S) for a finite group G with generating set S.

    Time complexity: O(|G| · |S|) to construct
    Space complexity: O(|G|²) for adjacency matrix

    Attributes:
        N: Order of the group |G|
        d: Degree of the graph |S|
        adjacency: N x N adjacency matrix
        elements: List of group elements
    """

    def __init__(self, elements: list, multiply: Callable, generators: list):
        """Build Cayley graph.

        Args:
            elements: List of all group elements
            multiply: Binary operation (g, h) -> g*h
            generators: List of generators (must be symmetric: s in S => s^{-1} in S)
        """
        self.elements = elements
        self.N = len(elements)
        self.d = len(generators)
        self.elem_to_idx = {self._hashable(e): i for i, e in enumerate(elements)}

        self.adjacency = np.zeros((self.N, self.N))
        for i, g in enumerate(elements):
            for s in generators:
                h = multiply(g, s)
                j = self.elem_to_idx[self._hashable(h)]
                self.adjacency[i][j] = 1

    @staticmethod
    def _hashable(x):
        if isinstance(x, (list, np.ndarray)):
            return tuple(x)
        return x

    def transition_matrix(self) -> np.ndarray:
        """Return the transition matrix P = (1/d) · A.

        For a d-regular graph, P_{ij} = A_{ij}/d.
        Time: O(N²)
        """
        return self.adjacency / self.d

    def normalized_adjacency(self) -> np.ndarray:
        """Return normalized adjacency matrix M = D^{-1/2} A D^{-1/2}.

        For regular graphs, this equals A/d = P.
        Time: O(N²)
        """
        return self.adjacency / self.d


class SpectralGapComputer:
    """Compute spectral gap of a Cayley graph.

    The spectral gap γ = 1 - |λ₂| where λ₂ is the second-largest
    eigenvalue of the transition matrix P.

    Time complexity: O(N³) for eigenvalue decomposition
    Space complexity: O(N²) for the matrix
    """

    @staticmethod
    def compute(graph: CayleyGraph) -> float:
        """Compute spectral gap.

        Returns:
            γ = 1 - max_{i≥1} |λ_i| where λ_i are eigenvalues of P
        """
        P = graph.transition_matrix()
        eigenvalues = np.linalg.eigvalsh(P)
        eigenvalues = np.sort(np.abs(eigenvalues))[::-1]
        return 1.0 - eigenvalues[1]

    @staticmethod
    def all_eigenvalues(graph: CayleyGraph) -> np.ndarray:
        """Return all eigenvalues of the transition matrix, sorted by magnitude."""
        P = graph.transition_matrix()
        eigenvalues = np.linalg.eigvalsh(P)
        return np.sort(eigenvalues)[::-1]


class ClassicalWalkSimulator:
    """Simulate classical random walk on a Cayley graph.

    At each step, the walker moves to a uniformly random neighbor.
    The distribution evolves as p_{t+1} = p_t · P.

    Time complexity: O(T · N²) for T steps
    Space complexity: O(N)
    """

    def __init__(self, graph: CayleyGraph):
        self.graph = graph
        self.P = graph.transition_matrix()
        self.N = graph.N

    def walk(self, steps: int, start: int = 0) -> list[np.ndarray]:
        """Simulate walk and return distributions at each step.

        Args:
            steps: Number of steps
            start: Starting vertex index (default: 0 = identity)

        Returns:
            List of probability distributions, one per step
        """
        p = np.zeros(self.N)
        p[start] = 1.0
        distributions = [p.copy()]

        for _ in range(steps):
            p = p @ self.P
            distributions.append(p.copy())

        return distributions

    def tv_distance_curve(self, steps: int, start: int = 0) -> np.ndarray:
        """Compute total variation distance to uniform at each step.

        TV(p, u) = (1/2) · Σ|p(x) - 1/N|

        Returns:
            Array of TV distances, shape (steps+1,)
        """
        uniform = np.ones(self.N) / self.N
        distributions = self.walk(steps, start)
        return np.array([0.5 * np.sum(np.abs(p - uniform)) for p in distributions])

    def mixing_time(self, epsilon: float = 0.25, max_steps: int = 10000) -> int:
        """Estimate mixing time: smallest t with TV(p_t, u) ≤ ε.

        Time: O(τ_mix · N²)
        """
        uniform = np.ones(self.N) / self.N
        p = np.zeros(self.N)
        p[0] = 1.0

        for t in range(max_steps):
            tv = 0.5 * np.sum(np.abs(p - uniform))
            if tv <= epsilon:
                return t
            p = p @ self.P

        return max_steps


class QuantumWalkSimulator:
    """Simulate quantum random walk on a Cayley graph.

    The quantum walk evolves on the Hilbert space ℓ²(G) ⊗ ℂ^d where
    d = |S| is the degree. The evolution uses a coin operator and shift.

    For the Grover walk:
    - Coin: C = 2|ψ><ψ| - I where |ψ> = (1/√d) Σ|s>
    - Shift: S|g,s> = |gs, s>

    Time complexity: O(T · (Nd)²) for T steps
    Space complexity: O((Nd)²) for the unitary
    """

    def __init__(self, graph: CayleyGraph, generators: list, multiply: Callable):
        self.graph = graph
        self.N = graph.N
        self.d = len(generators)
        self.dim = self.N * self.d  # Hilbert space dimension

        # Build shift operator
        self.S = np.zeros((self.dim, self.dim))
        for i, g in enumerate(graph.elements):
            for c, s in enumerate(generators):
                h = multiply(g, s)
                j = graph.elem_to_idx[graph._hashable(h)]
                # |g,c> -> |gs, c>
                self.S[j * self.d + c, i * self.d + c] = 1

        # Build Grover coin: C = 2|ψ><ψ| - I on each vertex's coin space
        psi = np.ones(self.d) / np.sqrt(self.d)
        coin_block = 2 * np.outer(psi, psi) - np.eye(self.d)
        self.C = np.kron(np.eye(self.N), coin_block)

        # Evolution operator U = S · C
        self.U = self.S @ self.C

    def walk(self, steps: int) -> list[np.ndarray]:
        """Simulate quantum walk, returning position probability at each step.

        The initial state is |0> ⊗ |ψ> where |ψ> = (1/√d)Σ|s>.

        Returns:
            List of probability distributions over G (marginalized over coin)
        """
        # Initial state: identity vertex, uniform coin
        state = np.zeros(self.dim, dtype=complex)
        for c in range(self.d):
            state[c] = 1.0 / np.sqrt(self.d)

        distributions = []
        for _ in range(steps + 1):
            # Marginalize over coin to get position probability
            prob = np.zeros(self.N)
            for v in range(self.N):
                for c in range(self.d):
                    prob[v] += np.abs(state[v * self.d + c]) ** 2
            distributions.append(prob)
            state = self.U @ state

        return distributions

    def tv_distance_curve(self, steps: int) -> np.ndarray:
        """Compute TV distance to uniform at each step."""
        uniform = np.ones(self.N) / self.N
        distributions = self.walk(steps)
        return np.array([0.5 * np.sum(np.abs(p - uniform)) for p in distributions])

    def time_averaged_tv(self, steps: int) -> np.ndarray:
        """Compute time-averaged TV distance (Cesaro mean).

        For quantum walks, the instantaneous distribution may not converge,
        but the time average does. This is the quantum analog of mixing.

        Time avg TV(T) = (1/T) Σ_{t=0}^{T-1} TV(p_t, u)
        """
        tv = self.tv_distance_curve(steps)
        return np.cumsum(tv) / np.arange(1, len(tv) + 1)


class MixingTimeEstimator:
    """Estimate mixing times and verify theoretical bounds.

    Provides methods to:
    1. Estimate classical mixing time from TV distance curves
    2. Estimate quantum mixing time from time-averaged TV
    3. Compare with theoretical predictions from spectral gap
    """

    @staticmethod
    def classical_mixing_time(graph: CayleyGraph, epsilon: float = 0.25) -> dict:
        """Estimate classical mixing time and compare with theory.

        Returns dict with:
        - measured: Empirical mixing time
        - predicted: Theoretical bound (1/γ) · ln(N/ε)
        - spectral_gap: Computed γ
        - ratio: measured / predicted
        """
        gamma = SpectralGapComputer.compute(graph)
        N = graph.N
        predicted = (1.0 / gamma) * np.log(N / epsilon)

        sim = ClassicalWalkSimulator(graph)
        measured = sim.mixing_time(epsilon)

        return {
            "measured": measured,
            "predicted": predicted,
            "spectral_gap": gamma,
            "ratio": measured / predicted if predicted > 0 else float("inf"),
        }

    @staticmethod
    def quantum_mixing_time(
        graph: CayleyGraph,
        generators: list,
        multiply: Callable,
        epsilon: float = 0.25,
        max_steps: int = 500,
    ) -> dict:
        """Estimate quantum mixing time (time-averaged) and compare with theory.

        Returns dict with:
        - measured: Steps until time-averaged TV ≤ ε
        - predicted: Theoretical bound (1/√γ) · √(ln(N))
        - spectral_gap: Computed γ
        - speedup: classical/quantum mixing time ratio
        """
        gamma = SpectralGapComputer.compute(graph)
        N = graph.N
        predicted_q = (1.0 / np.sqrt(gamma)) * np.sqrt(np.log(N))
        predicted_cl = (1.0 / gamma) * np.log(N / epsilon)

        qsim = QuantumWalkSimulator(graph, generators, multiply)
        ta_tv = qsim.time_averaged_tv(max_steps)

        measured = max_steps
        for t, tv in enumerate(ta_tv):
            if tv <= epsilon:
                measured = t
                break

        return {
            "measured": measured,
            "predicted_quantum": predicted_q,
            "predicted_classical": predicted_cl,
            "spectral_gap": gamma,
            "speedup": predicted_cl / predicted_q if predicted_q > 0 else float("inf"),
        }


# ==================== Helper: Group constructors ====================

def cyclic_group(n: int) -> tuple:
    """Construct cyclic group Z_n with generators {1, n-1}."""
    elements = list(range(n))
    multiply = lambda a, b: (a + b) % n
    generators = [1, n - 1]
    return elements, multiply, generators


def symmetric_group(n: int) -> tuple:
    """Construct S_n with transposition generators."""
    elements = [list(p) for p in permutations(range(n))]
    multiply = lambda p, q: [p[q[i]] for i in range(n)]

    # All transpositions
    generators = []
    identity = list(range(n))
    for i in range(n):
        for j in range(i + 1, n):
            t = list(range(n))
            t[i], t[j] = t[j], t[i]
            generators.append(t)

    return elements, multiply, generators


def dihedral_group(n: int) -> tuple:
    """Construct dihedral group D_n of order 2n.

    Elements: (k, f) where k ∈ Z_n, f ∈ {0,1}
    Multiplication: (k₁, f₁)(k₂, f₂) = (k₁ + (-1)^{f₁} k₂, f₁ ⊕ f₂) mod n
    """
    elements = [(k, f) for k in range(n) for f in range(2)]
    def multiply(a, b):
        k1, f1 = a
        k2, f2 = b
        if f1 == 0:
            return ((k1 + k2) % n, f2)
        else:
            return ((k1 - k2) % n, (f1 + f2) % 2)

    # Generators: rotation r=(1,0), reflection s=(0,1)
    generators = [(1, 0), (n - 1, 0), (0, 1)]
    return elements, multiply, generators


if __name__ == "__main__":
    print("Algorithms module loaded. Run demo.py for demonstrations.")

    # Quick test
    elems, mult, gens = cyclic_group(8)
    G = CayleyGraph(elems, mult, gens)
    gap = SpectralGapComputer.compute(G)
    print(f"Z_8 spectral gap: {gap:.6f}")

    result = MixingTimeEstimator.classical_mixing_time(G)
    print(f"Classical mixing: measured={result['measured']}, predicted={result['predicted']:.1f}")
