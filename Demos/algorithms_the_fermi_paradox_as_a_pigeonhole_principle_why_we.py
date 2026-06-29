#!/usr/bin/env python3
"""
Algorithms for Fermi Paradox Filter Cascade Analysis

Type-hinted implementations of the core mathematical algorithms.
"""

import math
from dataclasses import dataclass


@dataclass
class DrakeParams:
    """Drake equation parameters as a filter cascade."""
    num_planets: float
    filter_probs: list[float]
    
    def expected_civilizations(self) -> float:
        """E[N] = num_planets * prod(filter_probs)."""
        prod = 1.0
        for p in self.filter_probs:
            prod *= p
        return self.num_planets * prod
    
    def silence_probability_lower_bound(self) -> float:
        """Lower bound on P(silence) via Markov's inequality: max(0, 1 - E[N])."""
        E = self.expected_civilizations()
        return max(0.0, 1.0 - E)
    
    def poisson_silence_probability(self) -> float:
        """Poisson estimate of P(silence) = e^{-E[N]}."""
        E = self.expected_civilizations()
        return math.exp(-E)


def filter_concentration(filter_probs: list[float]) -> tuple[float, int]:
    """
    Find the most restrictive filter step.
    
    Returns (min_prob, index) — the Great Filter location.
    By the Filter Concentration Theorem, this step has probability
    at most eps^(1/k) where eps = product of all probabilities.
    """
    if not filter_probs:
        return (1.0, -1)
    
    min_prob = min(filter_probs)
    min_idx = filter_probs.index(min_prob)
    return (min_prob, min_idx)


def critical_filter_count(num_planets: float, per_step_prob: float) -> int:
    """
    Compute the minimum number of filter steps k such that
    num_planets * per_step_prob^k < 1.
    
    Returns k = ceil(log(1/num_planets) / log(per_step_prob)).
    """
    if per_step_prob >= 1.0 or per_step_prob <= 0.0:
        raise ValueError("per_step_prob must be in (0, 1)")
    if num_planets <= 0:
        raise ValueError("num_planets must be positive")
    
    return math.ceil(math.log(1.0 / num_planets) / math.log(per_step_prob))


def temporal_overlap_probability(
    n_civilizations: int,
    lifetime_years: float,
    cosmic_time_years: float = 13.8e9
) -> float:
    """
    Compute the occupied fraction of cosmic time.
    
    If n * L / T < 1, temporal overlap is unlikely (pigeonhole).
    Returns the occupied fraction n * L / T.
    """
    return n_civilizations * lifetime_years / cosmic_time_years


def spatial_detection_fraction(
    comm_range_ly: float,
    universe_radius_ly: float = 4.4e10,
    dimension: int = 3
) -> float:
    """
    Compute the fraction of the universe within communication range.
    
    Returns (r/R)^d where r = comm_range, R = universe_radius, d = dimension.
    """
    return (comm_range_ly / universe_radius_ly) ** dimension


def bayesian_filter_update(
    prior_probs: list[float],
    observed_passed: list[bool]
) -> list[float]:
    """
    Bayesian update of Great Filter location probabilities.
    
    Given prior probabilities for each step being the Great Filter,
    and observations of which steps have been passed, compute the
    posterior probabilities.
    
    Steps that have been passed get posterior probability 0.
    Remaining steps are rescaled by 1/(1 - sum of eliminated probs).
    """
    eliminated_mass = sum(
        p for p, passed in zip(prior_probs, observed_passed) if passed
    )
    remaining_mass = 1.0 - eliminated_mass
    
    if remaining_mass <= 0:
        # All steps passed — no Great Filter
        return [0.0] * len(prior_probs)
    
    posterior = []
    for p, passed in zip(prior_probs, observed_passed):
        if passed:
            posterior.append(0.0)
        else:
            posterior.append(p / remaining_mass)
    
    return posterior


def multi_scale_expected(
    n_galaxies: float,
    n_stars_per_galaxy: float,
    n_planets_per_star: float,
    galactic_filter: float,
    stellar_filter: float,
    planetary_filter: float
) -> float:
    """
    Multi-scale Drake equation: filters at galactic, stellar, and planetary levels.
    
    E[N] = N_g * N_s * N_p * p_g * p_s * p_p
    """
    return (n_galaxies * n_stars_per_galaxy * n_planets_per_star *
            galactic_filter * stellar_filter * planetary_filter)


def pigeonhole_poisson_comparison(lam: float) -> dict[str, float]:
    """
    Compare pigeonhole (linear) and Poisson (exponential) silence bounds.
    
    Returns both bounds and the gap between them.
    """
    linear = 1.0 - lam  # Pigeonhole/Markov bound
    poisson = math.exp(-lam)  # Poisson probability
    
    return {
        "lambda": lam,
        "linear_bound": linear,
        "poisson_probability": poisson,
        "gap": poisson - linear,
        "ratio": poisson / linear if linear > 0 else float('inf'),
    }


if __name__ == "__main__":
    # Quick test
    params = DrakeParams(
        num_planets=1e10,
        filter_probs=[0.01, 0.01, 0.01, 0.01]
    )
    print(f"Drake E[N] = {params.expected_civilizations():.2e}")
    print(f"P(silence) >= {params.silence_probability_lower_bound():.6f}")
    print(f"P_Poisson(silence) = {params.poisson_silence_probability():.6f}")
    print(f"Critical k (p=0.1): {critical_filter_count(1e10, 0.1)}")
    
    # Bayesian update
    prior = [0.1, 0.1, 0.2, 0.3, 0.3]
    passed = [True, True, False, False, False]
    posterior = bayesian_filter_update(prior, passed)
    print(f"\nBayesian update:")
    print(f"  Prior: {prior}")
    print(f"  Passed: {passed}")
    print(f"  Posterior: {[f'{p:.3f}' for p in posterior]}")
