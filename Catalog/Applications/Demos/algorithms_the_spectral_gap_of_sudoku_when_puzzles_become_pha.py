#!/usr/bin/env python3
"""
Algorithms for Density-Indexed Spectral Filtration Analysis

Type-hinted implementations of the core algorithms for computing spectral gaps,
classifying phases, and estimating mixing times in constraint satisfaction problems.
"""

from typing import List, Tuple, Optional, Callable
from enum import Enum
import numpy as np


class SpectralPhase(Enum):
    """Phase classification for constraint satisfaction systems."""
    FAST_MIXING = "fast_mixing"
    CRITICAL_SLOWING = "critical_slowing"
    FROZEN = "frozen"


class MarkovKernel:
    """A row-stochastic transition matrix on a finite state space.

    Corresponds to the Lean 4 structure `SpectralFiltration.MarkovKernel`.
    """

    def __init__(self, prob: np.ndarray):
        """Initialize from a transition matrix.

        Args:
            prob: n×n matrix where prob[i,j] = P(i→j)

        Raises:
            ValueError: If matrix is not row-stochastic or has negative entries
        """
        if prob.ndim != 2 or prob.shape[0] != prob.shape[1]:
            raise ValueError("Transition matrix must be square")
        if np.any(prob < -1e-12):
            raise ValueError("All entries must be nonneg")
        row_sums = prob.sum(axis=1)
        if np.any(np.abs(row_sums - 1.0) > 1e-8):
            raise ValueError(f"Rows must sum to 1, got sums: {row_sums}")
        self.prob = prob
        self.n = prob.shape[0]

    @staticmethod
    def identity(n: int) -> 'MarkovKernel':
        """Identity kernel: P(i,i) = 1, P(i,j) = 0 for i ≠ j."""
        return MarkovKernel(np.eye(n))

    @staticmethod
    def uniform(n: int) -> 'MarkovKernel':
        """Uniform kernel: P(i,j) = 1/n for all i,j."""
        return MarkovKernel(np.ones((n, n)) / n)

    def is_doubly_stochastic(self, tol: float = 1e-8) -> bool:
        """Check if columns also sum to 1."""
        return bool(np.all(np.abs(self.prob.sum(axis=0) - 1.0) < tol))

    def is_reversible(self, pi: np.ndarray, tol: float = 1e-8) -> bool:
        """Check detailed balance: π(i)P(i,j) = π(j)P(j,i)."""
        n = self.n
        for i in range(n):
            for j in range(n):
                if abs(pi[i] * self.prob[i, j] - pi[j] * self.prob[j, i]) > tol:
                    return False
        return True


class ProbDist:
    """A probability distribution on a finite set.

    Corresponds to the Lean 4 structure `SpectralFiltration.ProbDist`.
    """

    def __init__(self, mass: np.ndarray):
        if np.any(mass < -1e-12):
            raise ValueError("All masses must be nonneg")
        if abs(mass.sum() - 1.0) > 1e-8:
            raise ValueError(f"Total mass must be 1, got {mass.sum()}")
        self.mass = mass
        self.n = len(mass)

    @staticmethod
    def uniform(n: int) -> 'ProbDist':
        return ProbDist(np.ones(n) / n)


def dirichlet_energy(P: MarkovKernel, pi: ProbDist, f: np.ndarray) -> float:
    """Compute the Dirichlet energy E(f,f).

    E(f,f) = (1/2) Σ_{i,j} π(i) P(i,j) (f(j) - f(i))²

    This is the discrete analogue of the Dirichlet integral ∫|∇f|² dμ.
    Corresponds to `SpectralFiltration.DirichletEnergy`.

    Returns:
        Non-negative real number (proved in Theorem 4.1)
    """
    n = P.n
    energy = 0.0
    for i in range(n):
        for j in range(n):
            energy += pi.mass[i] * P.prob[i, j] * (f[j] - f[i]) ** 2
    return 0.5 * energy


def weighted_mean(pi: ProbDist, f: np.ndarray) -> float:
    """Compute E_π[f] = Σ_i π(i) f(i)."""
    return float(np.dot(pi.mass, f))


def weighted_variance(pi: ProbDist, f: np.ndarray) -> float:
    """Compute Var_π(f) = Σ_i π(i) (f(i) - E_π[f])²."""
    mean = weighted_mean(pi, f)
    return float(np.dot(pi.mass, (f - mean) ** 2))


def spectral_gap_variational(P: MarkovKernel, pi: ProbDist,
                              num_samples: int = 1000) -> float:
    """Estimate the spectral gap using the variational characterization.

    γ = inf { E(f,f) / Var_π(f) : Var_π(f) > 0 }

    Uses random sampling of test functions.

    Args:
        P: Markov kernel
        pi: Stationary distribution
        num_samples: Number of random test functions to try

    Returns:
        Lower bound on spectral gap
    """
    n = P.n
    min_ratio = float('inf')

    for _ in range(num_samples):
        f = np.random.randn(n)
        var = weighted_variance(pi, f)
        if var > 1e-12:
            energy = dirichlet_energy(P, pi, f)
            ratio = energy / var
            min_ratio = min(min_ratio, ratio)

    return min_ratio if min_ratio < float('inf') else 0.0


def spectral_gap_exact(P: MarkovKernel) -> float:
    """Compute the exact spectral gap via eigenvalue decomposition.

    γ = λ₁ - λ₂ where λ₁ ≥ λ₂ are the two largest eigenvalues.

    Returns:
        Exact spectral gap (non-negative by Theorem 4.1)
    """
    if P.n <= 1:
        return 0.0
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P.prob)))[::-1]
    return float(eigenvalues[0] - eigenvalues[1])


def mixing_time_bound(gap: float, num_states: int) -> float:
    """Compute mixing time bound: τ ≤ (1/γ) ln(n).

    Corresponds to `DensityIndexedSpectralFiltration.mixingTimeBound`.

    Args:
        gap: Spectral gap γ > 0
        num_states: Number of states n ≥ 1

    Returns:
        Upper bound on mixing time
    """
    if gap <= 0 or num_states <= 1:
        return 0.0
    return (1.0 / gap) * np.log(num_states)


class DensityIndexedSpectralFiltration:
    """The core novel structure: a DISF.

    Parameterizes a family of Markov chains by constraint density
    and captures the spectral gap phase transition.

    Corresponds to `SpectralFiltration.DensityIndexedSpectralFiltration`.
    """

    def __init__(self, grid_size: int,
                 solution_count: Callable[[int], float],
                 spectral_gap_fn: Callable[[int], float]):
        """Initialize a DISF.

        Args:
            grid_size: n for n×n grid (must be ≥ 2)
            solution_count: S(k) = expected solutions with k filled cells
            spectral_gap_fn: γ(k) = spectral gap with k filled cells
        """
        if grid_size < 2:
            raise ValueError("Grid size must be ≥ 2")
        self.grid_size = grid_size
        self._solution_count = solution_count
        self._spectral_gap = spectral_gap_fn

    def density(self, k: int) -> float:
        """Constraint density at k filled cells."""
        return k / (self.grid_size ** 2)

    def solution_count(self, k: int) -> float:
        """Number of solutions at k filled cells."""
        return self._solution_count(k)

    def spectral_gap(self, k: int) -> float:
        """Spectral gap at k filled cells."""
        return self._spectral_gap(k)

    def mixing_time(self, k: int) -> float:
        """Mixing time bound at k filled cells."""
        gap = self.spectral_gap(k)
        sol = self.solution_count(k)
        if gap <= 0 or sol <= 1:
            return 0.0
        return (1.0 / gap) * np.log(sol)

    def classify_phase(self, k: int, epsilon: float = 0.01) -> SpectralPhase:
        """Classify the spectral phase at k filled cells."""
        gap = self.spectral_gap(k)
        if gap == 0:
            return SpectralPhase.FROZEN
        elif gap < epsilon:
            return SpectralPhase.CRITICAL_SLOWING
        else:
            return SpectralPhase.FAST_MIXING

    def has_phase_transition(self) -> Optional[int]:
        """Find the critical clue count k_c, if it exists.

        Returns the smallest k where spectral gap drops to 0,
        or None if no phase transition is detected.
        """
        n_sq = self.grid_size ** 2
        for k in range(n_sq + 1):
            if self.spectral_gap(k) == 0 and k > 0:
                # Check that gap was positive before
                if any(self.spectral_gap(j) > 0 for j in range(k)):
                    return k
        return None


def spectral_gap_near_critical(C: float, d_c: float, nu: float,
                                d: float) -> float:
    """Model spectral gap near criticality: γ(d) = C(1 - d/d_c)^ν.

    Corresponds to `SpectralFiltration.spectralGapNearCritical`.

    When ν = 1 (mean-field), this gives linear decay (Theorem 5.2).
    """
    if d >= d_c:
        return 0.0
    return C * (1 - d / d_c) ** nu


# Sudoku-specific constants
SUDOKU_CRITICAL_DENSITY = 17 / 81  # ≈ 0.2099
SUDOKU_FREEZING_DENSITY = 30 / 81  # ≈ 0.3704


def classify_sudoku_clues(num_clues: int) -> SpectralPhase:
    """Classify Sudoku puzzle difficulty by spectral phase.

    Args:
        num_clues: Number of pre-filled cells (0 to 81)

    Returns:
        SpectralPhase classification
    """
    if num_clues > 30:
        return SpectralPhase.FROZEN
    elif num_clues >= 17:
        return SpectralPhase.CRITICAL_SLOWING
    else:
        return SpectralPhase.FAST_MIXING


if __name__ == "__main__":
    # Example: 3-state doubly stochastic chain
    print("Example: 3-state doubly stochastic chain")
    P = MarkovKernel(np.array([
        [0.5, 0.25, 0.25],
        [0.25, 0.5, 0.25],
        [0.25, 0.25, 0.5]
    ]))
    pi = ProbDist.uniform(3)

    print(f"Doubly stochastic: {P.is_doubly_stochastic()}")
    print(f"Reversible: {P.is_reversible(pi.mass)}")
    print(f"Spectral gap (exact): {spectral_gap_exact(P):.4f}")
    print(f"Spectral gap (variational): {spectral_gap_variational(P, pi):.4f}")

    f = np.array([1.0, 0.0, -1.0])
    print(f"Dirichlet energy of f={f}: {dirichlet_energy(P, pi, f):.4f}")
    print(f"Variance of f: {weighted_variance(pi, f):.4f}")
    print(f"Ratio E/Var: {dirichlet_energy(P, pi, f) / weighted_variance(pi, f):.4f}")

    # Identity chain
    print("\nIdentity chain (3 states):")
    I = MarkovKernel.identity(3)
    print(f"Spectral gap: {spectral_gap_exact(I):.4f}")
    print(f"Dirichlet energy of f={f}: {dirichlet_energy(I, pi, f):.4f}")

    # Mean-field model
    print("\nMean-field spectral gap model:")
    d_c = 17 / 81
    for d in [0.0, 0.05, 0.10, 0.15, 0.20]:
        gap = spectral_gap_near_critical(1.0, d_c, 1.0, d)
        print(f"  d = {d:.2f}, γ = {gap:.4f}")
