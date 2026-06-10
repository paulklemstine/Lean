#!/usr/bin/env python3
"""
Tropical Origami: Algorithms

This module implements the core computational algorithms for tropical origami mechanics:
1. Tropical validity checker
2. Tropical energy optimizer (gradient-free min-plus descent)
3. Miura fold finder
4. Tropical stress equilibrium checker
5. Row-shift canonical form computation
"""

import numpy as np
from typing import Optional, Tuple, List


class TropicalCreasePattern:
    """Represents a tropical origami crease pattern.

    The crease pattern is encoded by a real matrix C of shape (m, n),
    where m = number of constraints (vertices) and n = number of creases.
    """

    def __init__(self, C: np.ndarray):
        """Initialize with crease matrix C of shape (m, n)."""
        self.C = np.array(C, dtype=float)
        self.m, self.n = self.C.shape

    def row_values(self, w: np.ndarray, i: int) -> np.ndarray:
        """Compute C[i,:] + w for row i."""
        return self.C[i, :] + w

    def row_min(self, w: np.ndarray, i: int) -> float:
        """Minimum of C[i,j] + w[j] over j."""
        return np.min(self.row_values(w, i))

    def row_gap(self, w: np.ndarray, i: int) -> float:
        """Gap between 2nd smallest and smallest value in row i."""
        vals = np.sort(self.row_values(w, i))
        return vals[1] - vals[0] if len(vals) > 1 else 0.0

    def row_balanced(self, w: np.ndarray, i: int) -> Tuple[bool, List[int]]:
        """Check if row i is balanced at weight w.

        Returns:
            (is_balanced, list_of_minimizer_indices)
        """
        vals = self.row_values(w, i)
        min_val = np.min(vals)
        minimizers = list(np.where(np.isclose(vals, min_val, atol=1e-12))[0])
        return len(minimizers) >= 2, minimizers

    def is_valid(self, w: np.ndarray) -> bool:
        """Check if w is a tropically valid fold state.

        Time complexity: O(m * n)
        """
        return all(self.row_balanced(w, i)[0] for i in range(self.m))

    def tropical_energy(self, w: np.ndarray) -> float:
        """Compute tropical energy at weight w.

        Energy = sum of row gaps. Energy >= 0, and Energy = 0 iff w is valid.

        Time complexity: O(m * n log n)
        """
        return sum(self.row_gap(w, i) for i in range(self.m))

    def stress_equilibrium(self, sigma: np.ndarray) -> bool:
        """Check tropical stress equilibrium for transpose.

        For each column j, checks if min_i(C[i,j] + sigma[i]) is attained >= 2 times.

        Time complexity: O(m * n)
        """
        for j in range(self.n):
            vals = self.C[:, j] + sigma
            min_val = np.min(vals)
            count = np.sum(np.isclose(vals, min_val, atol=1e-12))
            if count < 2:
                return False
        return True

    def find_valid_fold(self, max_iter: int = 1000, lr: float = 0.1,
                        tol: float = 1e-10) -> Tuple[Optional[np.ndarray], float]:
        """Find a tropically valid fold state using min-plus descent.

        Algorithm:
        1. Start with w = 0
        2. For each unbalanced row, identify the unique minimizer
        3. Increase w at that minimizer to match the second-smallest value
        4. Repeat until all rows are balanced or max_iter reached

        Args:
            max_iter: Maximum number of iterations
            lr: Learning rate for gradient steps (unused in exact mode)
            tol: Tolerance for convergence

        Returns:
            (w_optimal, energy) where w_optimal is None if no valid fold found

        Time complexity: O(max_iter * m * n)
        """
        w = np.zeros(self.n)

        for iteration in range(max_iter):
            energy = self.tropical_energy(w)
            if energy < tol:
                return w, energy

            # Find the most unbalanced row
            worst_row = -1
            worst_gap = 0.0
            for i in range(self.m):
                gap = self.row_gap(w, i)
                if gap > worst_gap:
                    worst_gap = gap
                    worst_row = i

            if worst_row < 0:
                return w, energy

            # Find the unique minimizer and second minimizer
            vals = self.row_values(w, worst_row)
            sorted_indices = np.argsort(vals)
            j_min = sorted_indices[0]
            second_val = vals[sorted_indices[1]]

            # Adjust: increase w[j_min] so that row becomes balanced
            adjustment = second_val - vals[j_min]
            w[j_min] += adjustment

        return w if self.is_valid(w) else None, self.tropical_energy(w)

    def canonical_form(self) -> np.ndarray:
        """Compute the row-shift canonical form of C.

        Subtracts C[i, 0] from each row, making the first column all zeros.
        Row-shift equivalent matrices have the same canonical form.

        Returns:
            Canonical matrix D with D[i, 0] = 0 for all i.

        Time complexity: O(m * n)
        """
        return self.C - self.C[:, 0:1]

    def is_miura(self) -> bool:
        """Check if C is a Miura (Monge equality) matrix.

        Tests: C[i1,j1] + C[i2,j2] = C[i1,j2] + C[i2,j1]
        for all i1 < i2, j1 < j2.

        Time complexity: O(m^2 * n^2)
        """
        for i1 in range(self.m):
            for i2 in range(i1+1, self.m):
                for j1 in range(self.n):
                    for j2 in range(j1+1, self.n):
                        lhs = self.C[i1,j1] + self.C[i2,j2]
                        rhs = self.C[i1,j2] + self.C[i2,j1]
                        if not np.isclose(lhs, rhs, atol=1e-12):
                            return False
        return True

    def miura_decomposition(self) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """If C is a Miura matrix, decompose as C[i,j] = f[i] + g[j].

        Returns:
            (f, g) such that C[i,j] ≈ f[i] + g[j], or None if not Miura.

        Time complexity: O(m * n)
        """
        if not self.is_miura():
            return None
        # f[i] = C[i, 0], g[j] = C[0, j] - C[0, 0]
        f = self.C[:, 0].copy()
        g = self.C[0, :] - self.C[0, 0]
        return f, g


class TropicalEnergyOptimizer:
    """Optimizer for tropical energy using various strategies."""

    @staticmethod
    def soft_energy(C: np.ndarray, w: np.ndarray, beta: float) -> float:
        """Compute the softened (dequantized) energy.

        E_β(C, w) = sum_i [-1/β · log(sum_j exp(-β(C[i,j] + w[j]))) - min_j(C[i,j] + w[j])]

        This converges to the tropical energy as β → ∞.

        Args:
            C: Crease matrix (m × n)
            w: Weight vector (n,)
            beta: Inverse temperature parameter

        Returns:
            Softened energy value
        """
        m = C.shape[0]
        total = 0.0
        for i in range(m):
            vals = C[i, :] + w
            min_val = np.min(vals)
            # Numerically stable log-sum-exp
            shifted = -beta * (vals - min_val)
            lse = min_val - (1.0/beta) * np.log(np.sum(np.exp(shifted)))
            total += (-lse - min_val)
        return total

    @staticmethod
    def gradient_descent(C: np.ndarray, beta: float = 10.0,
                         lr: float = 0.01, max_iter: int = 5000,
                         tol: float = 1e-8) -> Tuple[np.ndarray, List[float]]:
        """Minimize softened energy using gradient descent.

        Uses automatic differentiation via finite differences.

        Args:
            C: Crease matrix
            beta: Inverse temperature
            lr: Learning rate
            max_iter: Maximum iterations
            tol: Convergence tolerance

        Returns:
            (optimal_w, energy_history)
        """
        n = C.shape[1]
        w = np.zeros(n)
        history = []
        eps = 1e-7

        for _ in range(max_iter):
            e = TropicalEnergyOptimizer.soft_energy(C, w, beta)
            history.append(e)

            if e < tol:
                break

            # Finite difference gradient
            grad = np.zeros(n)
            for j in range(n):
                w_plus = w.copy()
                w_plus[j] += eps
                grad[j] = (TropicalEnergyOptimizer.soft_energy(C, w_plus, beta) - e) / eps

            w -= lr * grad

        return w, history


# ============================================================================
# Example usage
# ============================================================================
if __name__ == "__main__":
    print("Tropical Origami Algorithms — Examples\n")

    # Example 1: Finding valid folds
    C = np.array([
        [0.0, 1.0, 3.0],
        [2.0, 0.0, 1.0]
    ])
    pattern = TropicalCreasePattern(C)
    print(f"Crease pattern ({pattern.m}×{pattern.n}):\n{C}\n")

    w_opt, energy = pattern.find_valid_fold()
    print(f"Found fold: w = {w_opt}")
    print(f"Energy: {energy:.6f}")
    print(f"Valid: {pattern.is_valid(w_opt)}")
    # Stress equilibrium is on C^T, so sigma has dimension m (rows of C)
    # For non-square matrices, sigma = w doesn't directly apply as w has dim n
    # We verify stress on C^T which needs sigma of dim n = 3
    print(f"Stress equilibrium (C^T, \u03c3=w): {TropicalCreasePattern(C.T).stress_equilibrium(w_opt)}")
    print()

    # Example 2: Miura matrix
    f = np.array([1.0, 3.0, 2.0])
    g = np.array([0.0, 1.0, -1.0, 2.0])
    M = f[:, np.newaxis] + g[np.newaxis, :]
    miura = TropicalCreasePattern(M)
    print(f"Miura matrix ({miura.m}×{miura.n}):\n{M}")
    print(f"Is Miura: {miura.is_miura()}")
    decomp = miura.miura_decomposition()
    if decomp:
        f_dec, g_dec = decomp
        print(f"Decomposition: f={f_dec}, g={g_dec}")
    w_can = -g
    print(f"Canonical fold w=-g: {w_can}")
    print(f"Energy at canonical fold: {miura.tropical_energy(w_can):.6f}")
    print()

    # Example 3: Canonical form
    print("Row-shift canonical forms:")
    print(f"Original:\n{C}")
    print(f"Canonical:\n{pattern.canonical_form()}")
    D = C + np.array([[5], [-3]])
    pattern2 = TropicalCreasePattern(D)
    print(f"Row-shifted D:\n{D}")
    print(f"Canonical:\n{pattern2.canonical_form()}")
    print(f"Same canonical form: {np.allclose(pattern.canonical_form(), pattern2.canonical_form())}")
