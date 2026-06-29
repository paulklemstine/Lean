#!/usr/bin/env python3
"""
algorithms.py — Certified Spectral Gap Algorithms

Implements the truncated certificate algorithm and related computational
tools for spectral gap estimation from Lorentzian curvature certificates.
"""

import numpy as np
from typing import List, Tuple, Optional


def spectral_gap(P: np.ndarray) -> float:
    """Compute spectral gap of a transition matrix.

    The spectral gap is defined as 1 - λ₂, where λ₂ is the second largest
    eigenvalue of P.

    Args:
        P: Row-stochastic transition matrix

    Returns:
        The spectral gap γ = 1 - λ₂
    """
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    if len(eigenvalues) < 2:
        return 1.0
    return 1.0 - eigenvalues[1]


def dirichlet_form(P: np.ndarray, mu: np.ndarray, f: np.ndarray) -> float:
    """Compute Dirichlet form E(f,f) = (1/2) sum_xy mu(x)P(x,y)(f(x)-f(y))².

    Args:
        P: Transition matrix
        mu: Stationary distribution
        f: Function on the state space

    Returns:
        The Dirichlet form value
    """
    n = len(f)
    result = 0.0
    for x in range(n):
        for y in range(n):
            result += mu[x] * P[x, y] * (f[x] - f[y]) ** 2
    return 0.5 * result


def variance(mu: np.ndarray, f: np.ndarray) -> float:
    """Compute variance Var_mu(f) = E[(f - E[f])²].

    Args:
        mu: Distribution
        f: Function

    Returns:
        Variance
    """
    mean = np.sum(mu * f)
    return np.sum(mu * (f - mean) ** 2)


def poincare_constant(P: np.ndarray, mu: np.ndarray, n_samples: int = 1000) -> float:
    """Estimate the Poincaré constant C_P = max Var(f)/E(f,f).

    Uses random test functions to estimate the constant.

    Args:
        P: Transition matrix
        mu: Stationary distribution
        n_samples: Number of random test functions

    Returns:
        Estimated Poincaré constant (lower bound on the true constant)
    """
    n = len(mu)
    max_ratio = 0.0

    for _ in range(n_samples):
        f = np.random.randn(n)
        v = variance(mu, f)
        d = dirichlet_form(P, mu, f)
        if d > 1e-12:
            ratio = v / d
            max_ratio = max(max_ratio, ratio)

    return max_ratio


class TruncatedCertificate:
    """Truncated spectral gap certificate.

    Implements the recursive refinement algorithm that produces monotonically
    improving lower bounds on the spectral gap.

    The algorithm computes κ_k = κ · (1 - ρ^k) where:
    - κ is the base certificate constant
    - ρ ∈ (0,1) is the contraction rate
    - k is the refinement depth

    Theorem: κ_k → κ as k → ∞, with error κ · ρ^k.
    """

    def __init__(self, kappa: float, rho: float = 0.5):
        """Initialize truncated certificate.

        Args:
            kappa: Base certificate constant κ > 0
            rho: Contraction rate ρ ∈ (0, 1)
        """
        assert kappa > 0, "Certificate constant must be positive"
        assert 0 < rho < 1, "Contraction rate must be in (0, 1)"
        self.kappa = kappa
        self.rho = rho

    def lower_bound(self, k: int) -> float:
        """Compute lower bound at depth k.

        Returns κ · (1 - ρ^k).
        """
        return self.kappa * (1.0 - self.rho ** k)

    def error_bound(self, k: int) -> float:
        """Compute error bound at depth k.

        Returns κ · ρ^k.
        """
        return self.kappa * self.rho ** k

    def depth_for_epsilon(self, epsilon: float) -> int:
        """Compute minimum depth k such that error ≤ ε.

        Solves κ · ρ^k ≤ ε for k.

        Args:
            epsilon: Target error

        Returns:
            Minimum depth k
        """
        assert epsilon > 0
        if epsilon >= self.kappa:
            return 0
        # κ · ρ^k ≤ ε  ⟺  k ≥ log(κ/ε) / log(1/ρ)
        k = np.log(self.kappa / epsilon) / np.log(1.0 / self.rho)
        return int(np.ceil(k))


class CurvatureControlledKernel:
    """A finite Markov kernel with curvature-certified spectral gap.

    Bundles a transition matrix with a curvature constant κ > 0 such that
    Var(f) ≤ κ⁻¹ · E(f,f) for all f.
    """

    def __init__(self, P: np.ndarray, mu: np.ndarray, kappa: float):
        """Initialize curvature-controlled kernel.

        Args:
            P: Row-stochastic transition matrix
            mu: Stationary distribution
            kappa: Curvature constant (certified spectral gap lower bound)
        """
        self.P = P
        self.mu = mu
        self.kappa = kappa
        self.n = len(mu)

    def verify_poincare(self, n_tests: int = 10000) -> Tuple[bool, float]:
        """Numerically verify the Poincaré inequality.

        Tests Var(f) ≤ κ⁻¹ · E(f,f) for random functions.

        Returns:
            (all_pass, worst_ratio) where worst_ratio = max Var(f)·κ / E(f,f)
        """
        worst_ratio = 0.0
        for _ in range(n_tests):
            f = np.random.randn(self.n)
            v = variance(self.mu, f)
            d = dirichlet_form(self.P, self.mu, f)
            if d > 1e-12:
                ratio = v * self.kappa / d
                worst_ratio = max(worst_ratio, ratio)

        return worst_ratio <= 1.0 + 1e-6, worst_ratio

    def mixing_time_bound(self, epsilon: float = 0.01) -> float:
        """Upper bound on mixing time.

        Returns (1/κ) · log(n/ε).
        """
        return (1.0 / self.kappa) * np.log(self.n / epsilon)


def build_partition_matroid_kernel(block_sizes: List[int]) -> CurvatureControlledKernel:
    """Build a curvature-controlled kernel for a partition matroid.

    Args:
        block_sizes: List of block sizes

    Returns:
        CurvatureControlledKernel instance
    """
    from demo import partition_exchange_matrix
    P, bases = partition_exchange_matrix(block_sizes)
    n = len(bases)
    mu = np.ones(n) / n
    gap = spectral_gap(P)
    return CurvatureControlledKernel(P, mu, gap)


# ──────────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Truncated Certificate Example ===")
    cert = TruncatedCertificate(kappa=0.25, rho=0.5)

    for eps in [0.1, 0.01, 0.001, 0.0001]:
        k = cert.depth_for_epsilon(eps)
        bound = cert.lower_bound(k)
        error = cert.error_bound(k)
        print(f"  ε={eps:.4f}: depth k={k}, κ_k={bound:.8f}, error={error:.8f}")

    print("\n=== Curvature Verification ===")
    from demo import partition_exchange_matrix
    P, bases = partition_exchange_matrix([2, 2, 2])
    n = len(bases)
    mu = np.ones(n) / n
    gap = spectral_gap(P)
    kernel = CurvatureControlledKernel(P, mu, gap)
    passed, worst = kernel.verify_poincare()
    print(f"  Poincaré check: {'PASS' if passed else 'FAIL'}, worst ratio = {worst:.6f}")
    print(f"  Mixing time bound (ε=0.01): {kernel.mixing_time_bound():.2f}")
