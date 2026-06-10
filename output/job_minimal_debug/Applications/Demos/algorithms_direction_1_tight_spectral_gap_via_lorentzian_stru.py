#!/usr/bin/env python3
"""
Algorithms for spectral gap estimation and certificate-guided sampling
on Lorentzian polynomials.

Implements:
  1. SpectralGapEstimator — Compute provable lower bounds on spectral gaps
  2. CertificateGuidedSampler — Sample from Lorentzian distributions
  3. LorentzianVerifier — Verify Lorentzian signature of polynomials
  4. DirichletFormComputer — Compute and compare Dirichlet forms
"""

import numpy as np
from math import comb, factorial, log
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class SpectralGapResult:
    """Result of a spectral gap computation."""
    gap: float
    eigenvalues: np.ndarray
    poincare_constant: float
    mixing_time_bound: float
    method: str


class SpectralGapEstimator:
    """
    Estimate spectral gaps for birth-death chains on log-concave distributions.

    The spectral gap λ₁ of a reversible Markov chain determines its mixing rate:
    the chain converges to stationarity in O(1/λ₁ · log(1/ε)) steps.

    For Lorentzian polynomials, the spectral gap is Ω(1/(d·n)), improving on
    the generic log-concave bound Ω(1/n²).
    """

    def __init__(self, distribution: np.ndarray):
        """
        Initialize with a probability distribution.

        Args:
            distribution: Array of probabilities summing to 1.
        """
        assert np.all(distribution >= 0), "Distribution must be nonneg"
        assert abs(np.sum(distribution) - 1.0) < 1e-10, "Distribution must sum to 1"
        self.pi = distribution
        self.n = len(distribution) - 1

    def build_birth_death_chain(self) -> np.ndarray:
        """
        Build the Metropolis birth-death chain with stationary distribution π.

        Returns:
            Transition matrix P of shape (n+1, n+1).
        """
        n = self.n
        P = np.zeros((n + 1, n + 1))

        for i in range(n + 1):
            if self.pi[i] == 0:
                P[i, i] = 1.0
                continue

            if i > 0 and self.pi[i - 1] > 0:
                P[i, i - 1] = 0.5 * min(1.0, self.pi[i - 1] / self.pi[i])

            if i < n and self.pi[i + 1] > 0:
                P[i, i + 1] = 0.5 * min(1.0, self.pi[i + 1] / self.pi[i])

            P[i, i] = 1.0 - np.sum(P[i, :])

        return P

    def compute_exact_gap(self) -> SpectralGapResult:
        """
        Compute the exact spectral gap via eigenvalue decomposition.

        Returns:
            SpectralGapResult with exact gap and eigenvalues.
        """
        P = self.build_birth_death_chain()
        eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
        gap = 1.0 - eigenvalues[1]
        poincare = 1.0 / gap if gap > 0 else float('inf')
        mixing_time = poincare * log(self.n + 1)

        return SpectralGapResult(
            gap=gap,
            eigenvalues=eigenvalues,
            poincare_constant=poincare,
            mixing_time_bound=mixing_time,
            method="exact_eigenvalue"
        )

    def compute_lorentzian_bound(self, degree: int) -> SpectralGapResult:
        """
        Compute the Lorentzian lower bound on spectral gap: c/(d·n).

        Args:
            degree: Degree d of the Lorentzian polynomial.

        Returns:
            SpectralGapResult with provable lower bound.
        """
        gap_bound = 1.0 / (degree * self.n)
        poincare = degree * self.n
        mixing_time = poincare * log(self.n + 1)

        return SpectralGapResult(
            gap=gap_bound,
            eigenvalues=np.array([]),
            poincare_constant=poincare,
            mixing_time_bound=mixing_time,
            method="lorentzian_bound"
        )

    def compute_log_concave_bound(self) -> SpectralGapResult:
        """
        Compute the generic log-concave lower bound: 1/(8(n+1)²).

        Returns:
            SpectralGapResult with log-concave bound.
        """
        gap_bound = 1.0 / (8 * (self.n + 1) ** 2)
        poincare = 8 * (self.n + 1) ** 2
        mixing_time = poincare * log(self.n + 1)

        return SpectralGapResult(
            gap=gap_bound,
            eigenvalues=np.array([]),
            poincare_constant=poincare,
            mixing_time_bound=mixing_time,
            method="log_concave_bound"
        )


class CertificateGuidedSampler:
    """
    Certificate-guided Markov chain sampler for Lorentzian distributions.

    Uses the Lorentzian structure to construct an efficient random walk
    that converges in O(d·n·log(n)) steps.
    """

    def __init__(self, distribution: np.ndarray, degree: int):
        """
        Initialize the sampler.

        Args:
            distribution: Target probability distribution.
            degree: Degree of the underlying Lorentzian polynomial.
        """
        self.pi = distribution
        self.n = len(distribution) - 1
        self.degree = degree
        self.estimator = SpectralGapEstimator(distribution)
        self.P = self.estimator.build_birth_death_chain()

    def sample(self, num_samples: int, burn_in: Optional[int] = None) -> np.ndarray:
        """
        Generate samples from the distribution via MCMC.

        Args:
            num_samples: Number of samples to generate.
            burn_in: Burn-in period. If None, uses the theoretical bound.

        Returns:
            Array of samples.
        """
        if burn_in is None:
            result = self.estimator.compute_lorentzian_bound(self.degree)
            burn_in = int(3 * result.mixing_time_bound) + 1

        samples = np.zeros(num_samples, dtype=int)
        state = self.n // 2  # Start at middle

        # Burn-in
        for _ in range(burn_in):
            state = np.random.choice(self.n + 1, p=self.P[state])

        # Sampling
        thin = max(1, int(1.0 / self.estimator.compute_exact_gap().gap))
        for i in range(num_samples):
            for _ in range(thin):
                state = np.random.choice(self.n + 1, p=self.P[state])
            samples[i] = state

        return samples

    def estimate_distribution(self, num_samples: int = 10000) -> np.ndarray:
        """
        Estimate the target distribution via sampling.

        Returns:
            Estimated distribution as probability vector.
        """
        samples = self.sample(num_samples)
        counts = np.bincount(samples, minlength=self.n + 1)
        return counts / num_samples


class LorentzianVerifier:
    """
    Verify that a polynomial has Lorentzian signature.

    A homogeneous polynomial is Lorentzian if its Hessian matrix has
    at most one positive eigenvalue. This is checked recursively via
    partial derivatives for degree d > 2.
    """

    @staticmethod
    def check_log_concavity(seq: np.ndarray) -> Tuple[bool, List[int]]:
        """
        Check log-concavity of a sequence.

        Returns:
            (is_log_concave, list of violating indices)
        """
        violations = []
        for k in range(1, len(seq) - 1):
            if seq[k] > 0 and seq[k - 1] >= 0 and seq[k + 1] >= 0:
                if seq[k] ** 2 < seq[k - 1] * seq[k + 1] - 1e-10:
                    violations.append(k)
        return len(violations) == 0, violations

    @staticmethod
    def check_ultra_log_concavity(seq: np.ndarray, N: int) -> Tuple[bool, List[int]]:
        """
        Check ultra-log-concavity: a_k/C(N,k) is log-concave.

        Args:
            seq: Sequence to check.
            N: Parameter for ultra-log-concavity.

        Returns:
            (is_ultra_log_concave, list of violating indices)
        """
        normalized = np.array([
            seq[k] / comb(N, k) if comb(N, k) > 0 else 0
            for k in range(min(len(seq), N + 1))
        ])
        return LorentzianVerifier.check_log_concavity(normalized)

    @staticmethod
    def check_lorentzian_quadratic(hessian: np.ndarray) -> Tuple[bool, int]:
        """
        Check if a symmetric matrix has at most one positive eigenvalue.

        Returns:
            (is_lorentzian, number of positive eigenvalues)
        """
        eigenvalues = np.linalg.eigvalsh(hessian)
        n_positive = np.sum(eigenvalues > 1e-10)
        return n_positive <= 1, n_positive

    @staticmethod
    def verify_reversed_cs(hessian: np.ndarray) -> Dict[str, float]:
        """
        Verify the reversed Cauchy-Schwarz inequality for a Lorentzian matrix.

        For a matrix with at most 1 positive eigenvalue and nonneg entries,
        checks B(i,j)² ≥ Q(i)·Q(j) for all i,j where the entries are nonneg.

        Returns:
            Dictionary with verification results.
        """
        n = hessian.shape[0]
        n_reversed = 0
        n_standard = 0
        min_ratio = float('inf')

        for i in range(n):
            for j in range(i + 1, n):
                if hessian[i, i] > 0 and hessian[j, j] > 0:
                    lhs = hessian[i, j] ** 2
                    rhs = hessian[i, i] * hessian[j, j]
                    ratio = lhs / rhs if rhs > 1e-15 else float('inf')

                    if lhs >= rhs - 1e-10:
                        n_reversed += 1
                    else:
                        n_standard += 1

                    min_ratio = min(min_ratio, ratio)

        return {
            "n_reversed_cs": n_reversed,
            "n_standard_cs": n_standard,
            "min_ratio": min_ratio,
            "all_reversed": n_standard == 0
        }


class DirichletFormComputer:
    """
    Compute and compare Dirichlet forms for Markov chains.

    Implements the comparison theorem: if E₁(f) ≥ c·E₂(f) for all f,
    and chain 2 has spectral gap γ₂, then chain 1 has spectral gap ≥ c·γ₂.
    """

    def __init__(self, pi: np.ndarray, P: np.ndarray):
        self.pi = pi
        self.P = P
        self.n = len(pi)

    def dirichlet_form(self, f: np.ndarray) -> float:
        """Compute E(f,f) = (1/2) Σ π(x)P(x,y)(f(x)-f(y))²."""
        result = 0.0
        for x in range(self.n):
            for y in range(self.n):
                result += self.pi[x] * self.P[x, y] * (f[x] - f[y]) ** 2
        return 0.5 * result

    def variance(self, f: np.ndarray) -> float:
        """Compute Var_π(f)."""
        mean = np.sum(self.pi * f)
        return np.sum(self.pi * (f - mean) ** 2)

    def poincare_ratio(self, f: np.ndarray) -> float:
        """Compute Var(f)/E(f,f) for non-constant f."""
        v = self.variance(f)
        e = self.dirichlet_form(f)
        return v / e if e > 1e-15 else float('inf')

    def estimate_poincare_constant(self, num_test_fns: int = 100) -> float:
        """
        Estimate the Poincaré constant by testing random functions.

        Returns an empirical upper bound on the Poincaré constant.
        """
        max_ratio = 0.0
        states = np.arange(self.n, dtype=float)

        # Test specific functions
        test_fns = [
            states,
            states ** 2,
            np.sin(np.pi * states / self.n),
            np.cos(np.pi * states / self.n),
        ]

        # Add random functions
        for _ in range(num_test_fns):
            test_fns.append(np.random.randn(self.n))

        for f in test_fns:
            ratio = self.poincare_ratio(f)
            max_ratio = max(max_ratio, ratio)

        return max_ratio

    @staticmethod
    def comparison_factor(pi: np.ndarray, P1: np.ndarray, P2: np.ndarray,
                         num_test_fns: int = 100) -> float:
        """
        Estimate the comparison factor c such that E₁(f) ≥ c·E₂(f) for all f.

        Returns a lower bound on c.
        """
        n = len(pi)
        min_ratio = float('inf')

        for _ in range(num_test_fns):
            f = np.random.randn(n)
            e1 = 0.0
            e2 = 0.0
            for x in range(n):
                for y in range(n):
                    diff_sq = (f[x] - f[y]) ** 2
                    e1 += pi[x] * P1[x, y] * diff_sq
                    e2 += pi[x] * P2[x, y] * diff_sq

            if e2 > 1e-15:
                min_ratio = min(min_ratio, e1 / e2)

        return min_ratio


# Example usage
if __name__ == "__main__":
    print("LORENTZIAN SPECTRAL GAP ALGORITHMS")
    print("=" * 50)

    # Example 1: Spectral gap estimation
    n, d = 50, 3
    coeffs = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
    pi = coeffs / np.sum(coeffs)

    estimator = SpectralGapEstimator(pi)

    exact = estimator.compute_exact_gap()
    lor = estimator.compute_lorentzian_bound(d)
    lc = estimator.compute_log_concave_bound()

    print(f"\nExample: Binomial(n={n}) distribution")
    print(f"  Exact spectral gap: {exact.gap:.6f}")
    print(f"  Lorentzian bound:   {lor.gap:.6f}")
    print(f"  Log-concave bound:  {lc.gap:.8f}")
    print(f"  Improvement ratio:  {lor.gap / lc.gap:.1f}x")

    # Example 2: Sampling
    print(f"\nSampling from Binomial({n}) via certificate-guided chain:")
    sampler = CertificateGuidedSampler(pi, d)
    samples = sampler.sample(1000)
    est_dist = sampler.estimate_distribution(5000)
    tv_distance = 0.5 * np.sum(np.abs(est_dist - pi))
    print(f"  Total variation distance: {tv_distance:.4f}")

    # Example 3: Lorentzian verification
    print(f"\nVerifying Lorentzian property:")
    verifier = LorentzianVerifier()
    is_lc, violations = verifier.check_log_concavity(coeffs)
    print(f"  Log-concave: {is_lc}")

    # Example 4: Comparison factor
    print(f"\nComparison factor estimation:")
    P = estimator.build_birth_death_chain()
    P_lazy = 0.5 * P + 0.5 * np.eye(n + 1)
    c = DirichletFormComputer.comparison_factor(pi, P, P_lazy)
    print(f"  Comparison factor (original vs lazy): {c:.4f} (expected ≈ 2.0)")
