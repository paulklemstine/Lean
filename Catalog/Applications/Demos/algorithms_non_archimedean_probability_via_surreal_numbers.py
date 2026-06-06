#!/usr/bin/env python3
"""
Algorithms for Surreal Probability Theory

Type-hinted implementations of the core algorithms from the surreal probability
framework, operating on rational arithmetic for exact computation.
"""

from fractions import Fraction
from typing import List, Dict, Tuple, Optional, Callable
import itertools


def construct_zero_sum_weights(n: int) -> List[int]:
    """
    Construct a zero-sum weight vector with all distinct entries.
    
    Algorithm: Use weights (-floor(n/2), ..., -1, 0, 1, ..., ceil(n/2)-1)
    adjusted to sum to zero.
    
    Args:
        n: Number of elements (must be >= 1)
    
    Returns:
        List of n distinct integers summing to 0
    """
    if n == 1:
        return [0]
    # Start with -floor((n-1)/2) to ceil((n-1)/2)
    weights = list(range(-(n - 1) // 2, (n - 1) // 2 + 1))
    if len(weights) < n:
        weights.append(weights[-1] + 1)
    weights = weights[:n]
    # Adjust last weight to make sum zero
    weights[-1] = -sum(weights[:-1])
    return weights


def perturbed_uniform_pmf(
    n: int,
    weights: List[int],
    epsilon: Fraction
) -> List[Fraction]:
    """
    Compute the infinitesimally perturbed uniform PMF.
    
    μ(i) = 1/n + w(i) * ε
    
    Args:
        n: Number of elements
        weights: Zero-sum weight vector
        epsilon: The infinitesimal (or near-infinitesimal) value
    
    Returns:
        List of probabilities
    """
    base = Fraction(1, n)
    return [base + Fraction(w) * epsilon for w in weights]


def product_pmf(
    mu: List[Fraction],
    nu: List[Fraction]
) -> List[List[Fraction]]:
    """
    Compute the product PMF of two measures.
    
    (μ × ν)(i, j) = μ(i) * ν(j)
    
    Args:
        mu: First PMF
        nu: Second PMF
    
    Returns:
        2D array of product probabilities
    """
    return [[p * q for q in nu] for p in mu]


def bayesian_update(
    prior: List[Fraction],
    likelihood: List[Fraction]
) -> List[Fraction]:
    """
    Perform Bayesian update.
    
    posterior(i) = likelihood(i) * prior(i) / evidence
    where evidence = Σ likelihood(j) * prior(j)
    
    Args:
        prior: Prior PMF
        likelihood: Likelihood values P(data | hypothesis_i)
    
    Returns:
        Posterior PMF
    """
    evidence = sum(l * p for l, p in zip(likelihood, prior))
    if evidence <= 0:
        raise ValueError("Evidence must be positive")
    return [(l * p) / evidence for l, p in zip(likelihood, prior)]


def conditional_probability(
    pmf: List[Fraction],
    event: List[int]
) -> List[Fraction]:
    """
    Compute conditional probability P(· | event).
    
    Args:
        pmf: The probability mass function
        event: List of indices in the conditioning event
    
    Returns:
        Conditional PMF (0 outside event)
    """
    event_prob = sum(pmf[i] for i in event)
    if event_prob <= 0:
        raise ValueError("Cannot condition on zero-probability event")
    result = [Fraction(0)] * len(pmf)
    for i in event:
        result[i] = pmf[i] / event_prob
    return result


def discrimination_power(pmf: List[Fraction]) -> int:
    """
    Count the number of distinct probability values in the PMF.
    
    A fully discriminating measure has discrimination_power = n.
    The uniform measure has discrimination_power = 1.
    
    Args:
        pmf: Probability mass function
    
    Returns:
        Number of distinct probability values
    """
    return len(set(pmf))


def information_content(pmf: List[Fraction]) -> Dict[str, object]:
    """
    Compute information-theoretic properties of a surreal PMF.
    
    Returns:
        Dictionary with:
        - 'discrimination_power': number of distinct probabilities
        - 'fully_discriminating': whether all probabilities are distinct
        - 'is_uniform': whether all probabilities are equal
        - 'max_prob': maximum probability
        - 'min_prob': minimum probability
        - 'spread': max_prob - min_prob
    """
    dp = discrimination_power(pmf)
    max_p = max(pmf)
    min_p = min(pmf)
    return {
        'discrimination_power': dp,
        'fully_discriminating': dp == len(pmf),
        'is_uniform': dp == 1,
        'max_prob': float(max_p),
        'min_prob': float(min_p),
        'spread': float(max_p - min_p),
    }


def enumerate_valid_weights(n: int, bound: int) -> List[List[int]]:
    """
    Enumerate all valid perturbation weight vectors:
    - n integers, each in [-bound, bound]
    - summing to 0
    - all distinct (for full discrimination)
    
    Args:
        n: Number of elements
        bound: Maximum absolute weight
    
    Returns:
        List of valid weight vectors
    """
    valid = []
    values = range(-bound, bound + 1)
    for combo in itertools.permutations(values, n):
        w = list(combo)
        if sum(w) == 0 and len(set(w)) == n:
            valid.append(w)
    return valid


def infinitesimal_partial_sums(
    n_terms: int,
    eps_bound: Fraction
) -> List[Tuple[int, Fraction, bool]]:
    """
    Demonstrate the non-Archimedean impossibility:
    if ε < 1/(k+1) for all k, then k·ε < k/(k+1) < 1.
    
    Args:
        n_terms: Number of terms to compute
        eps_bound: Upper bound function (here: 1/(k+1))
    
    Returns:
        List of (k, upper_bound_on_sum, sum_less_than_1)
    """
    results = []
    for k in range(1, n_terms + 1):
        bound = Fraction(k, k + 1)
        results.append((k, bound, bound < 1))
    return results


if __name__ == "__main__":
    print("=== Surreal Probability Algorithms ===\n")
    
    # Construct weights
    for n in [3, 5, 7]:
        w = construct_zero_sum_weights(n)
        print(f"Zero-sum weights for n={n}: {w} (sum={sum(w)})")
    
    # Enumerate valid weights for small cases
    print(f"\nValid weight vectors for n=3, bound=2:")
    valid = enumerate_valid_weights(3, 2)
    for v in valid[:10]:
        print(f"  {v}")
    print(f"  Total: {len(valid)}")
    
    # Information content comparison
    eps = Fraction(1, 10000)
    uniform = perturbed_uniform_pmf(4, [0, 0, 0, 0], Fraction(0))
    perturbed = perturbed_uniform_pmf(4, [-3, -1, 1, 3], eps)
    
    print(f"\nInformation content (uniform): {information_content(uniform)}")
    print(f"Information content (perturbed): {information_content(perturbed)}")
