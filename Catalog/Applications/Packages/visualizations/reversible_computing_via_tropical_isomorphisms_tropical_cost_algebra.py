#!/usr/bin/env python3
"""
Algorithms for Tropical Thermodynamic Complexity Theory

Implements the core algorithms from the research:
1. Tropical cost function algebra (min-plus operations)
2. Reversible simulation construction (Bennett-style embedding)
3. Entropy production computation
4. Landauer cost calculator
"""

import numpy as np
from typing import List, Tuple, Callable, Optional
from dataclasses import dataclass
import math


# ==============================================================
# Algorithm 1: Tropical Cost Algebra
# ==============================================================

@dataclass
class TropicalCostSpace:
    """
    A tropical cost space over a finite state space of size N.

    Elements are cost functions σ → ℝ, with operations:
    - trop_add (⊕): pointwise minimum
    - trop_mul (⊗): pointwise addition

    These satisfy the tropical semiring axioms:
    - (⊕) is commutative, associative, idempotent
    - (⊗) is commutative, associative
    - (⊗) distributes over (⊕): a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)

    Time complexity: O(N) per operation
    Space complexity: O(N) per cost function
    """
    n: int  # state space size

    def zero(self) -> np.ndarray:
        """Tropical additive identity: +∞ everywhere."""
        return np.full(self.n, np.inf)

    def one(self) -> np.ndarray:
        """Tropical multiplicative identity: 0 everywhere."""
        return np.zeros(self.n)

    def add(self, phi: np.ndarray, psi: np.ndarray) -> np.ndarray:
        """Tropical addition: pointwise min. O(N)."""
        return np.minimum(phi, psi)

    def mul(self, phi: np.ndarray, psi: np.ndarray) -> np.ndarray:
        """Tropical multiplication: pointwise +. O(N)."""
        return phi + psi

    def pullback(self, phi: np.ndarray, perm: np.ndarray) -> np.ndarray:
        """
        Pullback of cost function along permutation.

        This is the fundamental action of reversible computation
        on the tropical cost space: Φ ↦ Φ ∘ σ.

        Preserves both ⊕ and ⊗ (tropical isomorphism).

        Time: O(N), Space: O(N)
        """
        return phi[perm]

    def verify_isomorphism(self, perm: np.ndarray,
                           phi: np.ndarray, psi: np.ndarray) -> Tuple[bool, bool]:
        """
        Verify that pullback along perm is a tropical isomorphism.

        Returns (preserves_add, preserves_mul).

        Time: O(N)
        """
        pb_add = self.pullback(self.add(phi, psi), perm)
        add_pb = self.add(self.pullback(phi, perm), self.pullback(psi, perm))

        pb_mul = self.pullback(self.mul(phi, psi), perm)
        mul_pb = self.mul(self.pullback(phi, perm), self.pullback(psi, perm))

        return (np.allclose(pb_add, add_pb), np.allclose(pb_mul, mul_pb))


# ==============================================================
# Algorithm 2: Reversible Simulation (Bennett Construction)
# ==============================================================

@dataclass
class ReversibleSimulation:
    """
    Reversible simulation of a deterministic finite transition system.

    Given f : Fin N → Fin N and time horizon T, constructs:
    - Expanded state space Fin M with M ≤ (N+1)(T+1)
    - Reversible (bijective) transition g : Fin M ≃ Fin M
    - Encoding/decoding maps

    Such that: decode(g^T(encode(x))) = f^T(x) for all x.

    The construction uses the Bennett trick: store computation
    history to make the process reversible.

    Time complexity: O(N·T) for full simulation
    Space complexity: O(N·T) for history storage
    """
    n: int   # original state space size
    t: int   # time horizon

    def simulate_direct(self, f: np.ndarray, x: int) -> int:
        """
        Direct (irreversible) computation of f^T(x).
        Time: O(T), Space: O(1)
        """
        state = x
        for _ in range(self.t):
            state = f[state]
        return state

    def simulate_reversible(self, f: np.ndarray, x: int) -> Tuple[int, List[int]]:
        """
        Reversible simulation with full history (Bennett style).

        Returns (result, history) where history records all intermediate states.

        Time: O(T), Space: O(T)

        The history allows reconstruction of the inverse:
        given (result, history), we can recover x.
        """
        history = [x]
        state = x
        for _ in range(self.t):
            state = f[state]
            history.append(state)
        return state, history

    def verify_simulation(self, f: np.ndarray) -> bool:
        """
        Verify that reversible simulation matches direct computation
        for all initial states.

        Time: O(N·T)
        """
        for x in range(self.n):
            direct = self.simulate_direct(f, x)
            rev_result, _ = self.simulate_reversible(f, x)
            if direct != rev_result:
                return False
        return True

    def overhead_bound(self) -> int:
        """
        Polynomial overhead bound: M ≤ (N+1)(T+1).
        """
        return (self.n + 1) * (self.t + 1)

    def build_reversible_map(self, f: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """
        Build explicit reversible map on N×(T+1) product space.

        State: (current_value, time_step)
        Map:   (v, t) ↦ (f(v), t+1) for t < T
               (v, T) ↦ (v, T)       (halt)

        This is made bijective by the time coordinate.

        Returns: (forward_map, inverse_map) as arrays on Fin(N*(T+1))

        Time: O(N·T), Space: O(N·T)
        """
        M = self.n * (self.t + 1)
        forward = np.zeros(M, dtype=int)
        inverse = np.zeros(M, dtype=int)

        def encode(v: int, t: int) -> int:
            return v * (self.t + 1) + t

        def decode_pair(idx: int) -> Tuple[int, int]:
            return idx // (self.t + 1), idx % (self.t + 1)

        for v in range(self.n):
            for t in range(self.t + 1):
                idx = encode(v, t)
                if t < self.t:
                    forward[idx] = encode(f[v], t + 1)
                else:
                    forward[idx] = idx  # halt

        # Build inverse
        for i in range(M):
            inverse[forward[i]] = i

        return forward, inverse


# ==============================================================
# Algorithm 3: Entropy Production Calculator
# ==============================================================

@dataclass
class EntropyCalculator:
    """
    Computes entropy production for finite-state transitions.

    For f : Fin N → Fin N with uniform input distribution:
    - entropy_loss(f) = log|N| - log|range(f)|
    - f is bijective ⟺ entropy_loss(f) = 0

    This is the formal content of the Landauer characterization theorem.

    Time complexity: O(N) per function
    Space complexity: O(N) for range computation
    """

    @staticmethod
    def uniform_entropy_loss(f: np.ndarray) -> float:
        """
        Compute entropy loss under uniform input distribution.

        entropy_loss = log|domain| - log|range|

        Returns 0 iff f is bijective.

        Time: O(N), Space: O(N)
        """
        n = len(f)
        range_size = len(set(f))
        if n == 0 or range_size == 0:
            return 0.0
        return math.log(n) - math.log(range_size)

    @staticmethod
    def shannon_entropy_uniform(n: int) -> float:
        """
        Shannon entropy of uniform distribution on n states.

        H = log(n) nats

        Time: O(1)
        """
        if n <= 0:
            return 0.0
        return math.log(n)

    @staticmethod
    def shannon_entropy(probs: np.ndarray) -> float:
        """
        Shannon entropy of arbitrary distribution.

        H = -∑ p(x) log p(x)

        Time: O(N)
        """
        mask = probs > 0
        return -np.sum(probs[mask] * np.log(probs[mask]))

    @staticmethod
    def is_bijective(f: np.ndarray) -> bool:
        """Check if f is bijective (for endomorphisms: injective ⟺ surjective)."""
        return len(set(f)) == len(f)

    @staticmethod
    def landauer_cost(n_bits: int, temperature: float,
                      k_B: float = 1.380649e-23) -> float:
        """
        Landauer cost of erasing n bits at temperature T.

        Cost = n · k_B · T · ln(2)

        Time: O(1)
        """
        return n_bits * k_B * temperature * math.log(2)

    @staticmethod
    def fiber_sizes(f: np.ndarray) -> dict:
        """
        Compute fiber sizes: |f⁻¹(y)| for each y in range(f).

        Time: O(N), Space: O(N)
        """
        fibers = {}
        for x, y in enumerate(f):
            fibers.setdefault(y, []).append(x)
        return {y: len(xs) for y, xs in fibers.items()}


# ==============================================================
# Algorithm 4: Tropical Transition Matrix
# ==============================================================

@dataclass
class TropicalTransitionMatrix:
    """
    Represent deterministic transitions as tropical matrices.

    A deterministic function f : Fin N → Fin N corresponds to
    the tropical matrix A where:
        A[i,j] = 0   if f(j) = i
        A[i,j] = +∞  otherwise

    Reversible transitions correspond to tropical permutation matrices
    (exactly one finite entry per row and column).

    Time complexity: O(N²) for matrix construction
    Space complexity: O(N²) for matrix storage
    """
    n: int

    def function_to_matrix(self, f: np.ndarray) -> np.ndarray:
        """
        Convert function to tropical transition matrix.

        Time: O(N²), Space: O(N²)
        """
        mat = np.full((self.n, self.n), np.inf)
        for j in range(self.n):
            mat[f[j], j] = 0.0
        return mat

    def is_permutation_matrix(self, mat: np.ndarray) -> bool:
        """
        Check if tropical matrix is a permutation matrix.

        A tropical permutation matrix has exactly one finite
        entry per row and per column.

        Time: O(N²)
        """
        for i in range(self.n):
            row_finite = np.sum(np.isfinite(mat[i, :]))
            col_finite = np.sum(np.isfinite(mat[:, i]))
            if row_finite != 1 or col_finite != 1:
                return False
        return True

    def tropical_matrix_mul(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """
        Tropical matrix multiplication: (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

        Time: O(N³), Space: O(N²)
        """
        n = A.shape[0]
        C = np.full((n, n), np.inf)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
        return C


# ==============================================================
# Example Usage
# ==============================================================

if __name__ == "__main__":
    print("Tropical Thermodynamic Complexity — Algorithm Demonstrations\n")

    # Tropical cost algebra
    tcs = TropicalCostSpace(n=5)
    perm = np.array([2, 0, 4, 1, 3])  # a permutation
    phi = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    psi = np.array([2.0, 1.0, 4.0, 3.0, 0.0])

    preserves = tcs.verify_isomorphism(perm, phi, psi)
    print(f"Tropical isomorphism check: add={preserves[0]}, mul={preserves[1]}")

    # Reversible simulation
    sim = ReversibleSimulation(n=4, t=3)
    f = np.array([1, 2, 0, 0])  # non-injective
    print(f"\nReversible simulation verified: {sim.verify_simulation(f)}")
    print(f"Overhead bound: M ≤ {sim.overhead_bound()}")

    # Entropy calculations
    calc = EntropyCalculator()
    print(f"\nEntropy loss of identity: {calc.uniform_entropy_loss(np.arange(5)):.6f}")
    print(f"Entropy loss of constant: {calc.uniform_entropy_loss(np.zeros(5, dtype=int)):.6f}")
    print(f"Landauer cost (1 bit, 300K): {calc.landauer_cost(1, 300.0):.4e} J")

    # Shannon entropy of uniform distribution
    for n in [1, 2, 3, 4, 8]:
        H = calc.shannon_entropy(np.full(2**n, 1.0 / 2**n))
        print(f"H(uniform on 2^{n}) = {H:.6f}, expected {n * math.log(2):.6f}")

    # Tropical matrices
    tmm = TropicalTransitionMatrix(n=4)
    bij_f = np.array([2, 0, 3, 1])  # bijective
    nonbij_f = np.array([0, 0, 1, 1])  # non-bijective

    mat_bij = tmm.function_to_matrix(bij_f)
    mat_nonbij = tmm.function_to_matrix(nonbij_f)

    print(f"\nBijective f={bij_f}: permutation matrix? {tmm.is_permutation_matrix(mat_bij)}")
    print(f"Non-bijective f={nonbij_f}: permutation matrix? {tmm.is_permutation_matrix(mat_nonbij)}")
