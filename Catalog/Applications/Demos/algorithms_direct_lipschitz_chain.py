#!/usr/bin/env python3
"""
Algorithms for the Lipschitz Chain Certification Framework.

Implements:
1. CertifiedRadius — compute the certified perturbation radius
2. DistinguisherRobustnessCheck — check if a distinguisher survives perturbation
3. LipschitzEstimator — estimate Lipschitz constants empirically
4. MarginCertifier — full certification pipeline
"""

import numpy as np
from dataclasses import dataclass
from typing import Callable, Optional, Tuple, List


# ─── Data types ────────────────────────────────────────────────────────

@dataclass
class CertificationResult:
    """Result of a Lipschitz certification."""
    certified_radius: float
    lipschitz_constant: float
    margin: float
    is_robust: bool
    residual_margin: Optional[float] = None


@dataclass
class DistinguisherResult:
    """Result of a distinguisher robustness check."""
    is_robust: bool
    original_separation: float
    perturbation_distance: float
    certified_radius: float
    residual_margin_lower_bound: float
    observed_residual: Optional[float] = None


# ─── Algorithm 1: Certified Radius ────────────────────────────────────

def certified_radius(K: float, m: float) -> float:
    """
    Compute the certified perturbation radius.

    Given a Lipschitz constant K > 0 and target margin m > 0,
    returns r* = m / K such that any perturbation within radius r*
    changes the functional by at most m.

    Theorem reference: lipschitz_margin_bound
        |f(x) - f(y)| ≤ K * d(x,y) and d(x,y) ≤ r ≤ m/K
        implies |f(x) - f(y)| ≤ m

    Args:
        K: Lipschitz constant (must be > 0)
        m: Target margin (must be > 0)

    Returns:
        Certified radius r* = m / K

    Complexity: O(1) time, O(1) space
    """
    if K <= 0:
        raise ValueError(f"Lipschitz constant must be positive, got {K}")
    if m <= 0:
        raise ValueError(f"Margin must be positive, got {m}")
    return m / K


# ─── Algorithm 2: Distinguisher Robustness Check ──────────────────────

def distinguisher_robustness_check(
    D: Callable[[np.ndarray], float],
    d: Callable[[np.ndarray, np.ndarray], float],
    K: float,
    P: np.ndarray,
    Q: np.ndarray,
    P_prime: np.ndarray
) -> DistinguisherResult:
    """
    Check if a distinguisher remains robust under perturbation.

    Theorem reference: distinguisher_radius_separation
        If |D(P) - D(Q)| ≥ m, D is K-Lipschitz, d(P,P') ≤ m/(2K),
        then |D(P') - D(Q)| ≥ m/2.

    Args:
        D: Distinguisher function
        d: Distance function
        K: Lipschitz constant of D
        P: Original distribution
        Q: Reference distribution
        P_prime: Perturbed distribution

    Returns:
        DistinguisherResult with robustness assessment

    Complexity: O(|α|) for finite types
    """
    m = abs(D(P) - D(Q))
    dist = d(P, P_prime)
    r_cert = m / (2 * K) if K > 0 else float('inf')
    is_robust = dist <= r_cert
    residual_lb = max(0.0, m / 2) if is_robust else max(0.0, m - K * dist)
    observed = abs(D(P_prime) - D(Q))

    return DistinguisherResult(
        is_robust=is_robust,
        original_separation=m,
        perturbation_distance=dist,
        certified_radius=r_cert,
        residual_margin_lower_bound=residual_lb,
        observed_residual=observed
    )


# ─── Algorithm 3: Lipschitz Constant Estimator ────────────────────────

class LipschitzEstimator:
    """
    Estimate the Lipschitz constant of a functional empirically.

    Uses random sampling to find the maximum ratio |f(μ) - f(ν)| / d(μ, ν).
    This provides a lower bound on the true Lipschitz constant.

    For certified upper bounds, use analytic methods (e.g., tropical certificates).
    """

    def __init__(
        self,
        f: Callable[[np.ndarray], float],
        d: Callable[[np.ndarray, np.ndarray], float],
        dim: int,
        safety_factor: float = 1.1
    ):
        """
        Args:
            f: The functional to analyze
            d: Distance function
            dim: Dimension of the probability simplex
            safety_factor: Multiplicative safety margin (default 1.1)
        """
        self.f = f
        self.d = d
        self.dim = dim
        self.safety_factor = safety_factor
        self.K_estimate = 0.0
        self.n_samples = 0
        self.witness_pair: Optional[Tuple[np.ndarray, np.ndarray]] = None

    def _random_dist(self) -> np.ndarray:
        """Sample a random distribution on the simplex."""
        x = np.random.exponential(1.0, size=self.dim)
        return x / x.sum()

    def estimate(self, n_pairs: int = 10000) -> float:
        """
        Estimate the Lipschitz constant using n_pairs random pairs.

        Args:
            n_pairs: Number of random pairs to test

        Returns:
            Estimated Lipschitz constant (with safety factor)

        Complexity: O(n_pairs * |α|) time
        """
        for _ in range(n_pairs):
            mu = self._random_dist()
            nu = self._random_dist()
            dist = self.d(mu, nu)
            if dist > 1e-12:
                ratio = abs(self.f(mu) - self.f(nu)) / dist
                if ratio > self.K_estimate:
                    self.K_estimate = ratio
                    self.witness_pair = (mu.copy(), nu.copy())
            self.n_samples += 1

        return self.K_estimate * self.safety_factor

    def refine_local(self, center: np.ndarray, radius: float, n_pairs: int = 5000) -> float:
        """
        Refine the estimate near a specific distribution.

        Args:
            center: Distribution to analyze locally
            radius: Perturbation radius (in TV distance)
            n_pairs: Number of pairs to test

        Returns:
            Local Lipschitz constant estimate
        """
        K_local = 0.0
        for _ in range(n_pairs):
            delta = np.random.randn(self.dim) * radius * 0.5
            mu = center + delta
            mu = np.maximum(mu, 1e-15)
            mu /= mu.sum()

            delta2 = np.random.randn(self.dim) * radius * 0.5
            nu = center + delta2
            nu = np.maximum(nu, 1e-15)
            nu /= nu.sum()

            dist = self.d(mu, nu)
            if dist > 1e-12:
                ratio = abs(self.f(mu) - self.f(nu)) / dist
                K_local = max(K_local, ratio)

        return K_local * self.safety_factor


# ─── Algorithm 4: Full Certification Pipeline ─────────────────────────

class MarginCertifier:
    """
    Full certification pipeline for information-theoretic functionals.

    Given a functional f, distance d, and target margin m:
    1. Estimates the Lipschitz constant K
    2. Computes the certified radius r* = m / K
    3. Verifies the bound empirically
    4. Provides robustness certificates for specific distributions
    """

    def __init__(
        self,
        f: Callable[[np.ndarray], float],
        d: Callable[[np.ndarray, np.ndarray], float],
        dim: int,
        margin: float
    ):
        self.f = f
        self.d = d
        self.dim = dim
        self.margin = margin
        self.estimator = LipschitzEstimator(f, d, dim)
        self.K: Optional[float] = None
        self.r_cert: Optional[float] = None

    def calibrate(self, n_pairs: int = 20000) -> CertificationResult:
        """
        Run the full calibration pipeline.

        Returns:
            CertificationResult with certified radius and Lipschitz constant
        """
        self.K = self.estimator.estimate(n_pairs)
        self.r_cert = certified_radius(self.K, self.margin)

        return CertificationResult(
            certified_radius=self.r_cert,
            lipschitz_constant=self.K,
            margin=self.margin,
            is_robust=True
        )

    def verify(self, center: np.ndarray, n_tests: int = 5000) -> Tuple[bool, float]:
        """
        Empirically verify the certification at a specific distribution.

        Returns:
            (all_passed, max_observed_change)
        """
        if self.r_cert is None:
            raise RuntimeError("Must calibrate first")

        max_change = 0.0
        f_center = self.f(center)
        all_passed = True

        for _ in range(n_tests):
            delta = np.random.randn(self.dim) * self.r_cert * 0.8
            perturbed = center + delta
            perturbed = np.maximum(perturbed, 1e-15)
            perturbed /= perturbed.sum()

            if self.d(center, perturbed) <= self.r_cert:
                change = abs(self.f(perturbed) - f_center)
                max_change = max(max_change, change)
                if change > self.margin + 1e-10:
                    all_passed = False

        return all_passed, max_change

    def check_distinguisher(
        self, P: np.ndarray, Q: np.ndarray, P_prime: np.ndarray
    ) -> DistinguisherResult:
        """Check distinguisher robustness for specific distributions."""
        if self.K is None:
            raise RuntimeError("Must calibrate first")
        return distinguisher_robustness_check(self.f, self.d, self.K, P, Q, P_prime)


# ─── Utility functions ────────────────────────────────────────────────

def total_variation(p: np.ndarray, q: np.ndarray) -> float:
    """Total variation distance."""
    return 0.5 * np.abs(p - q).sum()

def hellinger_distance(p: np.ndarray, q: np.ndarray) -> float:
    """Hellinger distance."""
    return np.sqrt(0.5 * np.sum((np.sqrt(p) - np.sqrt(q)) ** 2))

def channel_mi(W: np.ndarray) -> Callable[[np.ndarray], float]:
    """Create a mutual information functional for a fixed channel."""
    def mi(p: np.ndarray) -> float:
        joint = p[:, None] * W
        px = joint.sum(axis=1)
        py = joint.sum(axis=0)
        result = 0.0
        for i in range(joint.shape[0]):
            for j in range(joint.shape[1]):
                if joint[i, j] > 0 and px[i] > 0 and py[j] > 0:
                    result += joint[i, j] * np.log(joint[i, j] / (px[i] * py[j]))
        return result
    return mi


# ─── Example usage ────────────────────────────────────────────────────

if __name__ == "__main__":
    np.random.seed(42)

    # Setup
    n_in, n_out = 6, 4
    W = np.random.exponential(1.0, size=(n_in, n_out))
    W = W / W.sum(axis=1, keepdims=True)

    mi_func = channel_mi(W)
    margin = 0.05  # 0.05 nats

    # Full certification
    certifier = MarginCertifier(mi_func, total_variation, n_in, margin)
    result = certifier.calibrate(n_pairs=15000)

    print(f"Lipschitz constant K = {result.lipschitz_constant:.4f}")
    print(f"Target margin m = {result.margin}")
    print(f"Certified radius r* = {result.certified_radius:.6f}")

    # Verify
    p_test = np.ones(n_in) / n_in
    passed, max_change = certifier.verify(p_test)
    print(f"Verification: {'PASSED' if passed else 'FAILED'}")
    print(f"Max observed change within r*: {max_change:.6f}")

    # Distinguisher check
    P = np.array([0.3, 0.2, 0.15, 0.15, 0.1, 0.1])
    Q = np.array([0.05, 0.05, 0.1, 0.3, 0.25, 0.25])
    delta = np.random.randn(n_in) * 0.02
    P_prime = P + delta
    P_prime = np.maximum(P_prime, 1e-10)
    P_prime /= P_prime.sum()

    dist_result = certifier.check_distinguisher(P, Q, P_prime)
    print(f"\nDistinguisher check:")
    print(f"  Original separation: {dist_result.original_separation:.6f}")
    print(f"  Perturbation distance: {dist_result.perturbation_distance:.6f}")
    print(f"  Certified radius: {dist_result.certified_radius:.6f}")
    print(f"  Robust: {dist_result.is_robust}")
    print(f"  Residual margin bound: {dist_result.residual_margin_lower_bound:.6f}")
    print(f"  Observed residual: {dist_result.observed_residual:.6f}")
