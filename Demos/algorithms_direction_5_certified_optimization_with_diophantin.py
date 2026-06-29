#!/usr/bin/env python3
"""
Algorithms for Arithmetically Certified Optimization

Implements the core algorithms from the research paper on certified optimization
using Diophantine renormalization budgets.

Keywords: certified optimization, Diophantine approximation, gradient descent,
Fourier majorant, renormalization budget, quasi-periodic landscapes
"""

import math
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass


@dataclass
class DiophantineOptCertificate:
    """A Diophantine optimization certificate.

    Encodes the parameters needed to compute the certified optimization budget.

    Attributes:
        alpha: Diophantine quality parameter (> 0)
        C: Renormalization constant / initial certificate strength (> 0)
        K: Gradient perturbation bound per unit step size (> 0)
        eps: Step size for gradient descent (> 0)
    """
    alpha: float
    C: float
    K: float
    eps: float

    def __post_init__(self):
        assert self.alpha > 0, f"alpha must be positive, got {self.alpha}"
        assert self.C > 0, f"C must be positive, got {self.C}"
        assert self.K > 0, f"K must be positive, got {self.K}"
        assert self.eps > 0, f"eps must be positive, got {self.eps}"

    @property
    def budget(self) -> int:
        """Compute the certified optimization budget."""
        return compute_budget(self.alpha, self.C, self.K, self.eps)

    @property
    def depletion_rate(self) -> float:
        """Per-step certificate depletion rate."""
        return self.eps * self.K * self.alpha


def compute_budget(alpha: float, C: float, K: float, eps: float) -> int:
    """Compute the certified optimization budget: floor(C / (eps * K * alpha)).

    This is the verified algorithm from the research paper. Correctness
    is established by the Lean theorems `predictedBudget_spec` and
    `predictedBudget_is_largest`.

    Args:
        alpha: Diophantine quality parameter (> 0)
        C: Initial certificate strength (> 0)
        K: Gradient perturbation bound (> 0)
        eps: Step size (> 0)

    Returns:
        N = floor(C / (eps * K * alpha))

    Complexity: O(1) time and space.

    Examples:
        >>> compute_budget(0.1, 10.0, 2.0, 0.01)
        5000
        >>> compute_budget(0.5, 10.0, 2.0, 0.01)
        1000
    """
    assert alpha > 0 and C > 0 and K > 0 and eps > 0
    return int(math.floor(C / (eps * K * alpha)))


def remaining_certificate(alpha: float, C: float, K: float, eps: float, n: int) -> float:
    """Compute the remaining certificate at step n.

    R(n) = C - n * (eps * K * alpha)

    Correctness: R(n) >= 0 for all n <= budget (Theorem 2).

    Args:
        alpha, C, K, eps: Certificate parameters
        n: Current step number

    Returns:
        Remaining certificate value
    """
    return C - n * (eps * K * alpha)


def gradient_majorant(S: List[int], amplitudes: Dict[int, float]) -> float:
    """Compute the gradient majorant G(S,a) = sum_{k in S} |k| * |a_k|.

    This is a computable upper bound on the gradient magnitude of the
    quasi-periodic Fourier objective f(x) = sum_k a_k cos(kx).

    Correctness: |f'(x)| <= G(S,a) for all x (Theorem 3).

    Args:
        S: Frequency set (list of integers)
        amplitudes: Amplitude function a : k -> a_k

    Returns:
        Gradient majorant value

    Complexity: O(|S|) time.

    Examples:
        >>> gradient_majorant([1, 3, 7], {1: 1.0, 3: 0.5, 7: 0.1})
        3.2
    """
    return sum(abs(k) * abs(amplitudes.get(k, 0.0)) for k in S)


def certificate_from_fourier(
    S: List[int],
    amplitudes: Dict[int, float],
    alpha: float,
    C: float,
    eps: float
) -> DiophantineOptCertificate:
    """Create a Diophantine optimization certificate from Fourier data.

    Computes the gradient majorant K = G(S,a) from the frequency set and
    amplitudes, then constructs the certificate. This is the bridge from
    Fourier analysis to certified optimization (Theorem 3).

    Args:
        S: Frequency set
        amplitudes: Amplitude function
        alpha: Diophantine quality parameter
        C: Initial certificate strength
        eps: Step size

    Returns:
        DiophantineOptCertificate with K = gradient_majorant(S, amplitudes)
    """
    K = gradient_majorant(S, amplitudes)
    if K == 0:
        K = 1e-15  # Avoid division by zero for constant objectives
    return DiophantineOptCertificate(alpha=alpha, C=C, K=K, eps=eps)


@dataclass
class CertificateTracker:
    """Online certificate tracking for gradient descent.

    Tracks the remaining certificate resource during optimization,
    recording history for analysis and visualization.
    """
    cert: DiophantineOptCertificate
    history: List[Tuple[int, float, float]]  # (step, remaining_cert, actual_step_size)

    def __init__(self, cert: DiophantineOptCertificate):
        self.cert = cert
        self.history = []

    @property
    def budget(self) -> int:
        return self.cert.budget

    def record_step(self, step: int, actual_step_size: float):
        """Record a gradient descent step."""
        R = remaining_certificate(
            self.cert.alpha, self.cert.C, self.cert.K, self.cert.eps, step
        )
        self.history.append((step, R, actual_step_size))

    def is_certified(self, step: int) -> bool:
        """Check if step is within the certified budget."""
        return step <= self.budget

    def actual_depletion_rate(self) -> Optional[float]:
        """Estimate the actual per-step certificate depletion from history."""
        if len(self.history) < 2:
            return None
        total_depletion = sum(s * self.cert.alpha for _, _, s in self.history)
        return total_depletion / len(self.history)

    def conservatism_ratio(self) -> Optional[float]:
        """Estimate how conservative the budget is.

        Returns ratio of (estimated actual budget) / (predicted budget).
        Values > 1 indicate the prediction is conservative.
        """
        actual_rate = self.actual_depletion_rate()
        if actual_rate is None or actual_rate <= 0:
            return None
        actual_budget = math.floor(self.cert.C / actual_rate)
        return actual_budget / self.budget if self.budget > 0 else None


def compare_budgets(
    alpha1: float, alpha2: float, C: float, K: float, eps: float
) -> Tuple[int, int, bool]:
    """Compare budgets for two Diophantine quality parameters.

    Demonstrates Theorem 1: if alpha1 <= alpha2, then budget(alpha2) <= budget(alpha1).

    Args:
        alpha1, alpha2: Diophantine quality parameters (both > 0)
        C, K, eps: Other certificate parameters

    Returns:
        (budget1, budget2, monotonicity_holds)
    """
    b1 = compute_budget(alpha1, C, K, eps)
    b2 = compute_budget(alpha2, C, K, eps)
    monotone = (alpha1 <= alpha2 and b2 <= b1) or (alpha2 <= alpha1 and b1 <= b2)
    return b1, b2, monotone


# ==============================================================================
# Example usage
# ==============================================================================

if __name__ == "__main__":
    print("Algorithms for Arithmetically Certified Optimization")
    print("=" * 55)

    # Example 1: Basic budget computation
    print("\n--- Example 1: Budget Computation ---")
    budget = compute_budget(alpha=0.1, C=10.0, K=2.0, eps=0.01)
    print(f"Budget for alpha=0.1, C=10, K=2, eps=0.01: {budget}")

    # Example 2: Certificate from Fourier data
    print("\n--- Example 2: Certificate from Fourier Data ---")
    S = [1, 3, 7, 15]
    a = {1: 1.0, 3: 0.5, 7: 0.3, 15: 0.1}
    cert = certificate_from_fourier(S, a, alpha=0.05, C=5.0, eps=0.001)
    print(f"Frequency set: {S}")
    print(f"Gradient majorant K = {cert.K:.4f}")
    print(f"Certified budget: {cert.budget} steps")
    print(f"Depletion rate per step: {cert.depletion_rate:.6f}")

    # Example 3: Budget monotonicity
    print("\n--- Example 3: Budget Monotonicity (Theorem 1) ---")
    for a1, a2 in [(0.05, 0.1), (0.1, 0.5), (0.01, 1.0)]:
        b1, b2, mono = compare_budgets(a1, a2, C=10.0, K=2.0, eps=0.01)
        print(f"  alpha1={a1}, alpha2={a2}: budget1={b1}, budget2={b2}, "
              f"antitone={'✓' if mono else '✗'}")
