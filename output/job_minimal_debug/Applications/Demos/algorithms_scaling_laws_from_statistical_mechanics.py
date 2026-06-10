#!/usr/bin/env python3
"""
Algorithms for Neural Scaling Laws

Type-hinted implementations of the core algorithms derived from
the mathematical framework.
"""

from dataclasses import dataclass
import math
from typing import Optional


@dataclass
class PowerLawScaling:
    """A power-law scaling regime: L(x) = A · x^{-α} + L_∞"""
    exponent: float      # α > 0
    coefficient: float   # A > 0
    floor: float = 0.0   # L_∞ ≥ 0

    def __post_init__(self) -> None:
        assert self.exponent > 0, "Exponent must be positive"
        assert self.coefficient > 0, "Coefficient must be positive"
        assert self.floor >= 0, "Floor must be non-negative"

    def loss(self, x: float) -> float:
        """Compute L(x) = A · x^{-α} + L_∞"""
        assert x > 0, "x must be positive"
        return self.coefficient * x ** (-self.exponent) + self.floor

    def excess_loss(self, x: float) -> float:
        """Compute excess loss A · x^{-α}"""
        assert x > 0
        return self.coefficient * x ** (-self.exponent)


@dataclass
class DualScalingLaw:
    """Dual scaling law: L(N,P) = A·N^{-α} + B·P^{-β} + E"""
    alpha: float     # Data scaling exponent
    beta: float      # Parameter scaling exponent
    A: float         # Data coefficient
    B: float         # Parameter coefficient
    E: float = 0.0   # Irreducible entropy

    def __post_init__(self) -> None:
        assert self.alpha > 0 and self.beta > 0
        assert self.A > 0 and self.B > 0
        assert self.E >= 0

    def loss(self, N: float, P: float) -> float:
        """Compute L(N, P)"""
        return self.A * N ** (-self.alpha) + self.B * P ** (-self.beta) + self.E

    def data_loss(self, N: float) -> float:
        """Data contribution to excess loss"""
        return self.A * N ** (-self.alpha)

    def param_loss(self, P: float) -> float:
        """Parameter contribution to excess loss"""
        return self.B * P ** (-self.beta)


@dataclass
class HarmonicScalingExponent:
    """Harmonic scaling exponent: γ = αβ/(α+β)"""
    alpha: float
    beta: float

    def __post_init__(self) -> None:
        assert self.alpha > 0 and self.beta > 0

    @property
    def gamma(self) -> float:
        """The harmonic scaling exponent"""
        return self.alpha * self.beta / (self.alpha + self.beta)

    @property
    def gamma_reciprocal(self) -> float:
        """Equivalent: γ = 1/(1/α + 1/β)"""
        return 1.0 / (1.0 / self.alpha + 1.0 / self.beta)

    def data_compute_share(self) -> float:
        """Fraction of compute exponent allocated to data: β/(α+β)"""
        return self.beta / (self.alpha + self.beta)

    def param_compute_share(self) -> float:
        """Fraction of compute exponent allocated to parameters: α/(α+β)"""
        return self.alpha / (self.alpha + self.beta)


def spectral_to_scaling_exponent(s: float) -> float:
    """
    Map spectral decay rate to scaling exponent.

    Given kernel eigenvalues λ_k ∼ k^{-s} for s > 1,
    the data scaling exponent is α = (s-1)/s.

    Args:
        s: Spectral decay rate (must be > 1)

    Returns:
        Scaling exponent α ∈ (0, 1)
    """
    assert s > 1, f"Spectral decay rate must be > 1, got {s}"
    return (s - 1) / s


def compute_optimal_allocation(
    law: DualScalingLaw,
    compute: float,
    flops_per_token_param: float = 6.0,
) -> tuple[float, float, float]:
    """
    Find compute-optimal (N*, P*) minimizing L(N,P) subject to C = flops_factor·N·P.

    At optimality: α·A·N^{-α} = β·B·P^{-β}

    Args:
        law: The dual scaling law
        compute: Total compute budget C
        flops_per_token_param: FLOPs per token per parameter (default 6)

    Returns:
        (N_opt, P_opt, L_opt) — optimal data, parameters, and loss
    """
    # Use golden section search on log scale
    # N·P = C/flops_factor, so P = C/(flops_factor·N)
    budget = compute / flops_per_token_param

    # Define loss as function of log(N)
    def loss_of_log_n(log_n: float) -> float:
        N = math.exp(log_n)
        P = budget / N
        if P <= 0:
            return float('inf')
        return law.loss(N, P)

    # Golden section search
    a, b = 1.0, math.log(budget) - 1.0
    gr = (math.sqrt(5) + 1) / 2
    c = b - (b - a) / gr
    d = a + (b - a) / gr

    for _ in range(200):  # Sufficient for convergence
        if loss_of_log_n(c) < loss_of_log_n(d):
            b = d
        else:
            a = c
        c = b - (b - a) / gr
        d = a + (b - a) / gr

    log_n_opt = (a + b) / 2
    N_opt = math.exp(log_n_opt)
    P_opt = budget / N_opt
    L_opt = law.loss(N_opt, P_opt)

    return N_opt, P_opt, L_opt


def per_component_risk(
    eigenvalue: float,
    sigma_sq: float,
    f_sq: float,
    N: float,
) -> tuple[float, float, float]:
    """
    Compute per-component bias-variance decomposition.

    Args:
        eigenvalue: Kernel eigenvalue λ
        sigma_sq: Noise variance σ²
        f_sq: Squared target coefficient f²
        N: Number of samples

    Returns:
        (variance, bias_sq, total_risk) for this component
    """
    denom = N * eigenvalue + sigma_sq
    variance = sigma_sq * eigenvalue / denom
    bias_sq = sigma_sq**2 * f_sq / denom**2
    return variance, bias_sq, variance + bias_sq


def predict_compute_exponent(
    alpha: float,
    beta: float,
) -> dict[str, float]:
    """
    Predict all scaling quantities from data and parameter exponents.

    Returns a dictionary with:
    - gamma: compute scaling exponent
    - n_share: fraction of compute exponent for data
    - p_share: fraction of compute exponent for parameters
    - am_hm_gap: gap between arithmetic and harmonic means
    - efficiency: ratio of harmonic to arithmetic mean (1 = perfect)
    """
    H = HarmonicScalingExponent(alpha, beta)
    am = (alpha + beta) / 2

    return {
        "gamma": H.gamma,
        "n_share": H.data_compute_share(),
        "p_share": H.param_compute_share(),
        "am_hm_gap": am - H.gamma,
        "efficiency": H.gamma / am if am > 0 else 0.0,
    }


def fit_scaling_exponent(
    x_values: list[float],
    loss_values: list[float],
    floor_estimate: Optional[float] = None,
) -> tuple[float, float, float]:
    """
    Fit a power-law scaling regime L(x) = A·x^{-α} + L_∞ to data.

    Uses log-log linear regression after subtracting floor.

    Args:
        x_values: Resource values (e.g., dataset sizes)
        loss_values: Corresponding loss values
        floor_estimate: Estimated irreducible loss (if None, uses min loss)

    Returns:
        (alpha, A, floor) — fitted exponent, coefficient, and floor
    """
    if floor_estimate is None:
        floor_estimate = min(loss_values) * 0.9

    # Log-log regression on L - L_∞ vs x
    log_x = [math.log(x) for x in x_values]
    log_excess = [math.log(max(L - floor_estimate, 1e-30)) for L in loss_values]

    n = len(log_x)
    sum_x = sum(log_x)
    sum_y = sum(log_excess)
    sum_xy = sum(a * b for a, b in zip(log_x, log_excess))
    sum_x2 = sum(a * a for a in log_x)

    slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x**2)
    intercept = (sum_y - slope * sum_x) / n

    alpha = -slope
    A = math.exp(intercept)

    return alpha, A, floor_estimate


if __name__ == "__main__":
    # Quick test
    law = DualScalingLaw(alpha=0.34, beta=0.34, A=406.4, B=410.7, E=1.69)
    N, P, L = compute_optimal_allocation(law, 1e21)
    print(f"Optimal: N={N:.2e}, P={P:.2e}, L={L:.4f}")

    pred = predict_compute_exponent(0.34, 0.34)
    print(f"Predictions: {pred}")

    print(f"Spectral s=2.0 → α={spectral_to_scaling_exponent(2.0):.4f}")
    print(f"Spectral s=3.0 → α={spectral_to_scaling_exponent(3.0):.4f}")
