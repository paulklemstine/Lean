#!/usr/bin/env python3
"""
algorithms.py — Quantum de Finetti Theorem: Core Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

import numpy as np
from math import comb
from typing import List, Tuple, Optional


def symmetric_subspace_dim(d: int, k: int) -> int:
    """
    Compute the dimension of the symmetric subspace Sym^k(C^d).

    The symmetric subspace is the subspace of (C^d)^⊗k invariant
    under all permutations of the k tensor factors.

    Formula: C(d+k-1, k)

    Args:
        d: dimension of single-particle Hilbert space
        k: number of particles

    Returns:
        Dimension of symmetric subspace
    """
    return comb(d + k - 1, k)


def de_finetti_bound(d: int, k: int, n: int) -> float:
    """
    Compute the finite quantum de Finetti approximation bound.

    For a permutation-symmetric state on n copies of C^d,
    the reduced state on k ≤ n copies is within trace distance
    2kd²/n of the nearest mixture of i.i.d. states.

    Args:
        d: dimension of single-particle space
        k: number of systems in reduced state
        n: total number of systems

    Returns:
        Upper bound on trace distance to nearest i.i.d. mixture
    """
    if n == 0:
        return float('inf')
    return 2.0 * k * d**2 / n


def conjectured_de_finetti_bound(d: int, k: int, n: int) -> float:
    """
    Conjectured tighter de Finetti bound: kd(d-1)/n.

    Always ≤ the standard bound 2kd²/n.

    Args:
        d: dimension of single-particle space
        k: number of systems in reduced state
        n: total number of systems

    Returns:
        Conjectured upper bound
    """
    if n == 0:
        return float('inf')
    return k * d * (d - 1) / n


def classical_embed(p: np.ndarray) -> np.ndarray:
    """
    Embed a classical probability distribution as a diagonal density matrix.

    This is the canonical map from classical to quantum probability.

    Args:
        p: probability vector (nonneg, sums to 1)

    Returns:
        Diagonal density matrix diag(p₁, ..., p_d)
    """
    return np.diag(p.astype(complex))


def measure_basis(rho: np.ndarray) -> np.ndarray:
    """
    Measure a density matrix in the computational basis.

    Extracts the diagonal entries (Born probabilities).

    Args:
        rho: density matrix

    Returns:
        Probability vector of measurement outcomes
    """
    return np.real(np.diag(rho))


def purity(rho: np.ndarray) -> float:
    """
    Compute the purity Tr(ρ²) of a density matrix.

    Ranges from 1/d (maximally mixed) to 1 (pure state).
    For classical (diagonal) states, equals the Herfindahl-Hirschman Index.

    Args:
        rho: density matrix

    Returns:
        Purity value in [1/d, 1]
    """
    return float(np.real(np.trace(rho @ rho)))


def linear_entropy(rho: np.ndarray) -> float:
    """
    Compute the linear entropy S_L(ρ) = 1 - Tr(ρ²).

    Measures mixedness; vanishes for pure states.
    For classical states, equals the Gini-Simpson diversity index.

    Args:
        rho: density matrix

    Returns:
        Linear entropy value in [0, (d-1)/d]
    """
    return 1.0 - purity(rho)


def herfindahl_index(p: np.ndarray) -> float:
    """
    Compute the Herfindahl-Hirschman Index (HHI) = Σpᵢ².

    Equivalent to quantum purity for classical states.
    Used in economics for market concentration and in ecology
    for species diversity (Simpson concentration index).

    Args:
        p: probability or market share vector

    Returns:
        HHI value in [1/d, 1]
    """
    return float(np.sum(p**2))


def gini_simpson_index(p: np.ndarray) -> float:
    """
    Compute the Gini-Simpson diversity index = 1 - Σpᵢ².

    Equivalent to linear entropy for classical states.

    Args:
        p: probability vector

    Returns:
        Diversity index in [0, (d-1)/d]
    """
    return 1.0 - herfindahl_index(p)


def random_density_matrix(d: int, rng: Optional[np.random.Generator] = None) -> np.ndarray:
    """
    Generate a random density matrix from the Hilbert-Schmidt ensemble.

    Uses the Ginibre ensemble: ρ = AA†/Tr(AA†) where A is a random
    complex Gaussian matrix.

    Args:
        d: dimension
        rng: random number generator

    Returns:
        Random d×d density matrix
    """
    if rng is None:
        rng = np.random.default_rng()
    A = rng.standard_normal((d, d)) + 1j * rng.standard_normal((d, d))
    rho = A @ A.conj().T
    return rho / np.trace(rho)


def random_unitary(d: int, rng: Optional[np.random.Generator] = None) -> np.ndarray:
    """
    Generate a Haar-random unitary matrix.

    Uses QR decomposition of a random complex Gaussian matrix.

    Args:
        d: dimension
        rng: random number generator

    Returns:
        d×d unitary matrix
    """
    if rng is None:
        rng = np.random.default_rng()
    H = rng.standard_normal((d, d)) + 1j * rng.standard_normal((d, d))
    Q, R = np.linalg.qr(H)
    # Fix the phase to get Haar-distributed unitaries
    D = np.diag(R)
    Ph = np.diag(D / np.abs(D))
    return Q @ Ph


def verify_purity_invariance(d: int, num_trials: int = 100) -> Tuple[bool, float]:
    """
    Numerically verify that purity is unitarily invariant.

    Tests Tr((UρU†)²) = Tr(ρ²) for random ρ and U.

    Args:
        d: dimension
        num_trials: number of random trials

    Returns:
        (all_passed, max_error) tuple
    """
    rng = np.random.default_rng(42)
    max_error = 0.0

    for _ in range(num_trials):
        rho = random_density_matrix(d, rng)
        U = random_unitary(d, rng)
        rho_rotated = U @ rho @ U.conj().T
        error = abs(purity(rho) - purity(rho_rotated))
        max_error = max(max_error, error)

    return max_error < 1e-10, max_error


def verify_purity_bounds(d: int, num_trials: int = 1000) -> Tuple[bool, float, float]:
    """
    Numerically verify 1/d ≤ Σpᵢ² ≤ 1 for random distributions.

    Args:
        d: dimension
        num_trials: number of random distributions to test

    Returns:
        (all_passed, min_purity, max_purity) tuple
    """
    rng = np.random.default_rng(42)
    min_pur = float('inf')
    max_pur = float('-inf')

    for _ in range(num_trials):
        p = rng.dirichlet(np.ones(d))
        pur = herfindahl_index(p)
        min_pur = min(min_pur, pur)
        max_pur = max(max_pur, pur)

    passed = min_pur >= 1/d - 1e-10 and max_pur <= 1 + 1e-10
    return passed, min_pur, max_pur


if __name__ == "__main__":
    # Quick smoke test
    print("Symmetric subspace dimensions for d=2:")
    for k in range(6):
        print(f"  Sym^{k}(C²) has dim {symmetric_subspace_dim(2, k)}")

    print(f"\nPurity invariance verified: {verify_purity_invariance(4)}")
    print(f"Purity bounds verified (d=5): {verify_purity_bounds(5)}")

    rho = random_density_matrix(3)
    print(f"\nRandom 3×3 density matrix purity: {purity(rho):.6f}")
    print(f"Linear entropy: {linear_entropy(rho):.6f}")
