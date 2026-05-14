#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Resource-Sensitive Prediction Logic

Implements the mathematical constructs from the bridge theorems:
1. Bayesian evidence computation and log-compression
2. Multiplicative-weights regret estimation
3. Local model correlation computation
4. Full resource inequality evaluation
5. Coherence-penalty budget allocation
"""

import math
from typing import List, Tuple, Optional


def normalize_belief(weights: List[float]) -> List[float]:
    """
    Normalize a list of nonneg weights into a valid belief state (simplex).

    Args:
        weights: Nonneg weights, not all zero.

    Returns:
        Probability distribution summing to 1.

    >>> normalize_belief([1, 2, 3])
    [0.16666666666666666, 0.3333333333333333, 0.5]
    """
    total = sum(weights)
    if total <= 0:
        n = len(weights)
        return [1.0 / n] * n
    return [w / total for w in weights]


def compute_evidence(belief: List[float], likelihoods: List[float]) -> float:
    """
    Compute evidence = Σ b_i · l_i for a belief state and likelihoods.

    Complexity: O(n)

    Args:
        belief: Valid probability distribution.
        likelihoods: Nonneg likelihood values.

    Returns:
        Evidence value (nonneg).

    >>> compute_evidence([0.5, 0.5], [2.0, 4.0])
    3.0
    """
    return sum(b * l for b, l in zip(belief, likelihoods))


def log_compress_evidence(belief: List[float], likelihoods: List[float]) -> float:
    """
    Compute log(1 + evidence), the information content of evidence.

    By Theorem 1, this is bounded by max(likelihoods).

    Complexity: O(n)

    Args:
        belief: Valid probability distribution.
        likelihoods: Nonneg likelihood values.

    Returns:
        log(1 + evidence) value.

    >>> round(log_compress_evidence([0.5, 0.5], [2.0, 4.0]), 4)
    1.3863
    """
    ev = compute_evidence(belief, likelihoods)
    return math.log(1 + ev)


def verify_evidence_bound(belief: List[float], likelihoods: List[float]) -> Tuple[float, float, bool]:
    """
    Verify Theorem 1: log(1 + evidence) ≤ M where M = max(likelihoods).

    Returns:
        (log_ev, M, is_valid)

    >>> verify_evidence_bound([0.5, 0.5], [2.0, 4.0])
    (1.3862943611198906, 4.0, True)
    """
    log_ev = log_compress_evidence(belief, likelihoods)
    M = max(likelihoods) if likelihoods else 0.0
    return (log_ev, M, log_ev <= M + 1e-12)


def regret_bound(n: int, T: int) -> float:
    """
    Compute the multiplicative-weights regret bound √(T · log(n) / 2).

    Complexity: O(1)

    Args:
        n: Number of experts (≥ 1).
        T: Time horizon (≥ 1).

    Returns:
        Regret upper bound.

    >>> round(regret_bound(10, 100), 4)
    10.7298
    """
    if n <= 1:
        return 0.0
    return math.sqrt(T * math.log(n) / 2)


def information_budget(n: int, T: int) -> float:
    """
    Compute the information budget T/2 + log(n)/2.

    By Theorem 4, regret_bound ≤ information_budget.

    Complexity: O(1)

    >>> round(information_budget(10, 100), 4)
    51.1513
    """
    return T / 2.0 + math.log(max(n, 1)) / 2.0


def coherence_value(H: float, n: int) -> float:
    """
    Compute coherence C = 1 - H/n.

    Args:
        H: Spectral entropy, 0 ≤ H ≤ n.
        n: Dimension.

    Returns:
        Coherence in [0, 1].

    >>> coherence_value(5, 10)
    0.5
    """
    return 1 - H / n if n > 0 else 0.0


def coherence_penalty(H: float, n: int) -> float:
    """
    Compute coherence penalty P = H/n (landscape entropy).

    coherence_value + coherence_penalty = 1 (conservation law).

    >>> coherence_penalty(5, 10)
    0.5
    """
    return H / n if n > 0 else 0.0


def local_model_correlation(
    probs: List[float],
    outcomes_i: List[bool],
    outcomes_j: List[bool]
) -> float:
    """
    Compute correlation E(i,j) = Σ_λ P(λ) · a_i(λ) · a_j(λ).

    By Theorem 6, |result| ≤ 1 always.

    Complexity: O(|hidden states|)

    Args:
        probs: Probability distribution over hidden states.
        outcomes_i: Measurement outcomes for site i.
        outcomes_j: Measurement outcomes for site j.

    Returns:
        Correlation in [-1, 1].

    >>> local_model_correlation([0.5, 0.5], [True, False], [True, True])
    0.0
    """
    corr = 0.0
    for p, oi, oj in zip(probs, outcomes_i, outcomes_j):
        ai = 1.0 if oi else -1.0
        aj = 1.0 if oj else -1.0
        corr += p * ai * aj
    return corr


def chsh_combination(E11: float, E12: float, E21: float, E22: float) -> float:
    """
    Compute CHSH quantity S = E11 - E12 + E21 + E22.

    By Theorem 8, |S| ≤ 4 when each |Eij| ≤ 1.

    >>> chsh_combination(1, -1, 1, 1)
    4
    """
    return E11 - E12 + E21 + E22


def full_resource_inequality(
    belief: List[float],
    likelihoods: List[float],
    H: float,
    n: int,
    correlation: float
) -> Tuple[float, float, bool]:
    """
    Evaluate the Full Resource Inequality (Theorem 10):
    log(1 + evidence) + coherencePenalty + correlation ≤ M + 2

    Args:
        belief: Valid belief state.
        likelihoods: Nonneg likelihoods.
        H: Spectral entropy.
        n: Dimension.
        correlation: Prediction correlation from local model.

    Returns:
        (lhs, rhs, is_valid)

    >>> lhs, rhs, valid = full_resource_inequality([0.5, 0.5], [1.0, 2.0], 1.0, 2, 0.5)
    >>> valid
    True
    """
    log_ev = log_compress_evidence(belief, likelihoods)
    cp = coherence_penalty(H, n)
    M = max(likelihoods) if likelihoods else 0.0
    lhs = log_ev + cp + correlation
    rhs = M + 2
    return (lhs, rhs, lhs <= rhs + 1e-12)


def optimal_coherence_allocation(
    total_budget: float,
    n: int,
    T: int
) -> Tuple[float, float]:
    """
    Given a total resource budget, optimally allocate between
    coherence penalty and regret bound.

    Strategy: minimize the maximum of regret and coherence cost
    under the constraint that they sum to at most the budget.

    Args:
        total_budget: Total available resource.
        n: Number of experts.
        T: Time horizon.

    Returns:
        (optimal_H, allocated_coherence_penalty)
    """
    rb = regret_bound(n, T)
    # Coherence penalty H/n can be at most 1
    # Regret is fixed at √(T log n / 2)
    # We allocate budget = rb + cp ≤ total_budget
    if rb >= total_budget:
        return (0.0, 0.0)  # All budget goes to regret
    remaining = total_budget - rb
    cp = min(remaining, 1.0)
    H = cp * n
    return (H, cp)


if __name__ == "__main__":
    import doctest
    doctest.testmod(verbose=True)

    print("\n--- Resource Allocation Example ---")
    n, T = 10, 100
    budget = 60.0
    H_opt, cp_opt = optimal_coherence_allocation(budget, n, T)
    rb = regret_bound(n, T)
    print(f"Experts: {n}, Horizon: {T}, Budget: {budget}")
    print(f"Regret bound: {rb:.4f}")
    print(f"Optimal H: {H_opt:.4f}, Coherence penalty: {cp_opt:.4f}")
    print(f"Total used: {rb + cp_opt:.4f} ≤ {budget}")
