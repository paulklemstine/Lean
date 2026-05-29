"""
Algorithms for the Fermi Paradox Pigeonhole Analysis

Implements:
1. Drake equation computation with uncertainty propagation
2. Tropical bottleneck identification (max-plus algebra)
3. Bayesian inference from silence
4. Monte Carlo simulation of civilization emergence
5. Great Filter threshold analysis
"""

import math
import random
from typing import Optional


class DrakeParams:
    """
    Parameters of the Drake equation.
    
    N = R* × f_p × n_e × f_l × f_i × f_c × L
    
    We combine factors into per_planet_prob = f_l × f_i × f_c
    and keep num_planets = R* × f_p × n_e × T (total habitable planets).
    
    Time complexity: O(1) for all computations.
    Space complexity: O(1).
    """
    
    def __init__(self, num_planets: int, per_planet_prob: float):
        assert 0 <= per_planet_prob <= 1, "Probability must be in [0, 1]"
        assert num_planets >= 0, "Number of planets must be non-negative"
        self.num_planets = num_planets
        self.per_planet_prob = per_planet_prob
    
    @property
    def expected_civilizations(self) -> float:
        """E[N] = n × p. O(1)."""
        return self.num_planets * self.per_planet_prob
    
    @property
    def filter_strength(self) -> float:
        """-ln(p). O(1)."""
        if self.per_planet_prob <= 0:
            return float('inf')
        return -math.log(self.per_planet_prob)
    
    @property
    def surprise_bits(self) -> float:
        """-log₂(p). O(1)."""
        if self.per_planet_prob <= 0:
            return float('inf')
        return -math.log2(self.per_planet_prob)
    
    def is_strong_filter(self) -> bool:
        """Whether p < 1/n (strong filter regime). O(1)."""
        if self.num_planets == 0:
            return True
        return self.per_planet_prob < 1.0 / self.num_planets
    
    def prob_zero_civilizations(self) -> float:
        """
        P(N=0) = (1-p)^n, exact Bernoulli calculation.
        Uses log to avoid underflow.
        O(1).
        """
        if self.per_planet_prob <= 0:
            return 1.0
        if self.per_planet_prob >= 1:
            return 0.0
        log_prob = self.num_planets * math.log1p(-self.per_planet_prob)
        return math.exp(log_prob)
    
    def prob_zero_poisson(self) -> float:
        """
        P(N=0) ≈ e^{-λ} where λ = n×p (Poisson approximation).
        Valid when n is large and p is small.
        O(1).
        """
        lam = self.expected_civilizations
        return math.exp(-lam)


def tropical_bottleneck_analysis(
    factor_names: list[str],
    factor_values: list[float]
) -> dict:
    """
    Identify the Great Filter bottleneck using tropical (max-plus) algebra.
    
    In the tropical semiring (ℝ ∪ {-∞}, max, +):
    - Addition becomes max (identifies dominant factor)
    - Multiplication becomes + (combines independent factors)
    
    The Drake equation product p₁ × p₂ × ... × pₖ becomes
    the tropical sum (-log p₁) ⊕ (-log p₂) ⊕ ... ⊕ (-log pₖ)
    where ⊕ = max finds the bottleneck.
    
    Time: O(k) where k = number of factors.
    Space: O(k).
    
    Args:
        factor_names: Names of Drake factors
        factor_values: Probability values (each in (0, 1])
    
    Returns:
        Dictionary with bottleneck analysis results
    """
    assert len(factor_names) == len(factor_values)
    k = len(factor_values)
    
    # Tropical representation: -log of each factor
    tropical = [-math.log(f) for f in factor_values]
    
    # Bottleneck = tropical max
    bottleneck_idx = max(range(k), key=lambda i: tropical[i])
    bottleneck_val = tropical[bottleneck_idx]
    
    # Total filter = tropical product = ordinary sum
    total = sum(tropical)
    
    # Dominance ratio: how much the bottleneck contributes
    dominance = bottleneck_val / total if total > 0 else 0
    
    # Rank all factors by filter strength
    ranked = sorted(range(k), key=lambda i: tropical[i], reverse=True)
    
    return {
        "factors": dict(zip(factor_names, factor_values)),
        "tropical_values": dict(zip(factor_names, tropical)),
        "bottleneck_name": factor_names[bottleneck_idx],
        "bottleneck_strength": bottleneck_val,
        "total_filter_strength": total,
        "bottleneck_dominance": dominance,
        "ranking": [(factor_names[i], tropical[i]) for i in ranked],
        "combined_probability": math.exp(-total),
    }


def bayesian_silence_bound(
    planets_checked: int,
    confidence: float = 0.95
) -> float:
    """
    Bayesian upper bound on per-planet probability from observing silence.
    
    If we check m planets and find 0 civilizations, the (1-α) upper
    credible bound on p is -ln(α)/m.
    
    For a uniform prior on p, the posterior is Beta(1, m+1),
    and the (1-α) quantile is 1 - α^{1/(m+1)}.
    
    Time: O(1). Space: O(1).
    
    Args:
        planets_checked: Number of planets surveyed with null result
        confidence: Confidence level (default 0.95)
    
    Returns:
        Upper bound on per-planet probability
    """
    assert 0 < confidence < 1
    assert planets_checked > 0
    alpha = 1 - confidence
    # Beta posterior quantile
    return 1 - alpha ** (1.0 / (planets_checked + 1))


def monte_carlo_fermi(
    num_planets: int,
    per_planet_prob: float,
    num_simulations: int = 100000,
    seed: Optional[int] = None
) -> dict:
    """
    Monte Carlo simulation of civilization emergence.
    
    For each simulation, independently sample whether each planet
    develops a civilization (Bernoulli trial with probability p).
    
    Time: O(num_simulations) using Poisson approximation.
    Space: O(1) per simulation.
    
    Args:
        num_planets: Number of habitable planets
        per_planet_prob: Per-planet probability
        num_simulations: Number of Monte Carlo trials
        seed: Random seed for reproducibility
    
    Returns:
        Dictionary with simulation statistics
    """
    if seed is not None:
        random.seed(seed)
    
    lam = num_planets * per_planet_prob  # Poisson parameter
    
    # Use Poisson approximation (valid for large n, small p)
    counts = []
    zero_count = 0
    for _ in range(num_simulations):
        # Poisson random variable
        k = 0
        p_acc = math.exp(-lam)
        u = random.random()
        cum = p_acc
        while u > cum and k < 1000:
            k += 1
            p_acc *= lam / k
            cum += p_acc
        counts.append(k)
        if k == 0:
            zero_count += 1
    
    mean_count = sum(counts) / len(counts)
    max_count = max(counts)
    
    return {
        "lambda": lam,
        "simulations": num_simulations,
        "mean_civilizations": mean_count,
        "max_civilizations": max_count,
        "prob_zero": zero_count / num_simulations,
        "prob_zero_exact": math.exp(-lam),
        "prob_at_least_one": 1 - zero_count / num_simulations,
    }


def great_filter_threshold(
    target_prob: float,
    min_factor: float,
    max_factors: int = 20
) -> dict:
    """
    Find the minimum number of factors k such that
    min_factor^k < target_prob.
    
    This determines: how many independent "filter steps" are needed
    if each step has probability at least min_factor?
    
    Time: O(max_factors). Space: O(1).
    """
    results = {}
    for k in range(1, max_factors + 1):
        product = min_factor ** k
        results[k] = {
            "product": product,
            "below_target": product < target_prob,
        }
        if product < target_prob:
            return {
                "min_k": k,
                "target_prob": target_prob,
                "min_factor": min_factor,
                "critical_product": product,
                "all_results": results
            }
    return {
        "min_k": None,
        "message": f"Could not reach target with {max_factors} factors",
        "all_results": results
    }


# Example usage
if __name__ == "__main__":
    print("=== Drake Equation Analysis ===")
    drake = DrakeParams(10**10, 1e-11)
    print(f"Expected civilizations: {drake.expected_civilizations:.4f}")
    print(f"Strong filter? {drake.is_strong_filter()}")
    print(f"P(zero) exact: {drake.prob_zero_civilizations():.6f}")
    print(f"P(zero) Poisson: {drake.prob_zero_poisson():.6f}")
    print(f"Filter strength: {drake.filter_strength:.1f} nats")
    print(f"Surprise: {drake.surprise_bits:.1f} bits")
    
    print("\n=== Tropical Bottleneck ===")
    result = tropical_bottleneck_analysis(
        ["f_l (life)", "f_i (intelligence)", "f_c (communication)"],
        [0.1, 1e-4, 1e-6]
    )
    print(f"Bottleneck: {result['bottleneck_name']}")
    print(f"Dominance: {result['bottleneck_dominance']:.1%}")
    print(f"Ranking: {result['ranking']}")
    
    print("\n=== Monte Carlo Simulation ===")
    mc = monte_carlo_fermi(10**10, 1e-11, num_simulations=100000, seed=42)
    print(f"Mean civilizations: {mc['mean_civilizations']:.4f}")
    print(f"P(zero) simulated: {mc['prob_zero']:.4f}")
    print(f"P(zero) exact: {mc['prob_zero_exact']:.4f}")
    
    print("\n=== Great Filter Threshold ===")
    result = great_filter_threshold(1e-10, 1e-3)
    print(f"Minimum factors needed: {result['min_k']}")
    print(f"At k={result['min_k']}: product = {result['critical_product']:.2e}")
