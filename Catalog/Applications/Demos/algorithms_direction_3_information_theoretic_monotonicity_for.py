#!/usr/bin/env python3
"""
algorithms.py — Algorithms for auditing information-theoretic profiles
of robustly Lorentzian measures.

Implements:
1. Coordinate marginal computation
2. Pairwise covariance computation
3. Pairwise mutual information computation
4. Deletion pushforward entropy
5. Robustness gap estimation
6. Full information profile audit

All algorithms correspond to definitions in the Lean formalization
(InfoTheoreticMonotonicity.lean).
"""

import numpy as np
from itertools import combinations
from math import log, comb
from typing import Dict, List, Tuple, Optional, NamedTuple
from dataclasses import dataclass, field


@dataclass
class InfoProfile:
    """Complete information-theoretic profile of a FinsetLaw.

    Fields mirror the Lean `auditRobustLorentzianInfoProfile` specification:
    - entropy: Shannon entropy H(μ) in nats
    - coord_probs: marginal probabilities p_i = P(i ∈ S)
    - covariances: covariance matrix Cov(1_{i∈S}, 1_{j∈S})
    - mutual_infos: pairwise MI matrix I(X_i; X_j)
    - chi_sq_bounds: chi-squared bounds on MI
    - susceptibility: total off-diagonal covariance χ
    - susceptibility_bound: certified upper bound ε·(Σp_i)²
    - deleted_entropies: entropies after deleting each coordinate
    - robustness_gap: estimated ε
    - mi_le_chisq_holds: whether MI ≤ χ² for all pairs
    """
    n: int
    entropy: float
    coord_probs: List[float] = field(default_factory=list)
    covariances: List[List[float]] = field(default_factory=list)
    mutual_infos: List[List[float]] = field(default_factory=list)
    chi_sq_bounds: List[List[float]] = field(default_factory=list)
    susceptibility: float = 0.0
    susceptibility_bound: float = 0.0
    deleted_entropies: List[float] = field(default_factory=list)
    robustness_gap: float = 0.0
    mi_le_chisq_holds: bool = True


def compute_coord_prob(n: int, weights: Dict[frozenset, float], i: int) -> float:
    """Compute P(i ∈ S) = Σ_{S ∋ i} μ(S).

    Complexity: O(|supp(μ)|)
    """
    return sum(w for s, w in weights.items() if i in s)


def compute_pair_joint_prob(n: int, weights: Dict[frozenset, float],
                           i: int, j: int) -> float:
    """Compute P(i ∈ S ∧ j ∈ S) = Σ_{S ∋ i,j} μ(S).

    Complexity: O(|supp(μ)|)
    """
    return sum(w for s, w in weights.items() if i in s and j in s)


def compute_coord_cov(n: int, weights: Dict[frozenset, float],
                     i: int, j: int) -> float:
    """Compute Cov(1_{i∈S}, 1_{j∈S}) = P(i,j ∈ S) - P(i ∈ S)·P(j ∈ S).

    Complexity: O(|supp(μ)|)
    """
    return (compute_pair_joint_prob(n, weights, i, j) -
            compute_coord_prob(n, weights, i) * compute_coord_prob(n, weights, j))


def compute_entropy(weights: Dict[frozenset, float]) -> float:
    """Compute Shannon entropy H(μ) = -Σ μ(S) log μ(S) (nats).

    Uses convention 0·log(0) = 0.
    Complexity: O(|supp(μ)|)
    """
    return -sum(w * log(w) for w in weights.values() if w > 0)


def compute_pairwise_mi(n: int, weights: Dict[frozenset, float],
                        i: int, j: int) -> float:
    """Compute mutual information I(X_i; X_j) for binary coordinate indicators.

    I(X_i; X_j) = Σ_{x,y} P(X_i=x, X_j=y) log(P(X_i=x, X_j=y) / (P(X_i=x)P(X_j=y)))

    This is the KL divergence D_KL(P_{ij} || P_i ⊗ P_j).

    Complexity: O(|supp(μ)|)
    """
    p = compute_coord_prob(n, weights, i)
    q = compute_coord_prob(n, weights, j)
    r = compute_pair_joint_prob(n, weights, i, j)

    mi = 0.0
    atoms = [
        (r, p * q),
        (p - r, p * (1 - q)),
        (q - r, (1 - p) * q),
        (1 - p - q + r, (1 - p) * (1 - q)),
    ]
    for pxy, pxpy in atoms:
        if pxy > 1e-15 and pxpy > 1e-15:
            mi += pxy * log(pxy / pxpy)
    return max(0.0, mi)


def compute_chi_sq_pair(n: int, weights: Dict[frozenset, float],
                        i: int, j: int) -> float:
    """Compute chi-squared divergence for coordinate pair (i,j).

    χ²(i,j) = c² / (p_i(1-p_i) · p_j(1-p_j))
    where c = Cov(X_i, X_j).

    This is the certified upper bound on MI from kl_le_chi_sq_four.

    Complexity: O(|supp(μ)|)
    """
    c = compute_coord_cov(n, weights, i, j)
    p = compute_coord_prob(n, weights, i)
    q = compute_coord_prob(n, weights, j)
    denom = p * (1 - p) * q * (1 - q)
    if denom < 1e-15:
        return float('inf')
    return c**2 / denom


def compute_deletion_pushforward(n: int, weights: Dict[frozenset, float],
                                 k: int) -> Dict[frozenset, float]:
    """Compute the pushforward of μ under deletion of coordinate k.

    For each subset S, map S to S \ {k} with appropriate reindexing.

    Complexity: O(|supp(μ)| · n)
    """
    new_weights: Dict[frozenset, float] = {}
    for s, w in weights.items():
        new_s = frozenset(i if i < k else i - 1 for i in s if i != k)
        new_weights[new_s] = new_weights.get(new_s, 0.0) + w
    return new_weights


def compute_robustness_gap(n: int, weights: Dict[frozenset, float]) -> float:
    """Estimate the robustness gap ε = max_{i≠j} |Cov(i,j)| / (p_i · p_j).

    This is the tightest ε such that RobustlyLorentzian μ ε could hold
    (assuming negative dependence).

    Complexity: O(n² · |supp(μ)|)
    """
    max_ratio = 0.0
    for i in range(n):
        pi = compute_coord_prob(n, weights, i)
        for j in range(i + 1, n):
            pj = compute_coord_prob(n, weights, j)
            if pi > 0 and pj > 0:
                cov = abs(compute_coord_cov(n, weights, i, j))
                ratio = cov / (pi * pj)
                max_ratio = max(max_ratio, ratio)
    return max_ratio


def compute_susceptibility(n: int, weights: Dict[frozenset, float]) -> float:
    """Compute spin susceptibility χ = Σ_{i≠j} |Cov(X_i, X_j)|.

    Complexity: O(n² · |supp(μ)|)
    """
    result = 0.0
    for i in range(n):
        for j in range(n):
            if i != j:
                result += abs(compute_coord_cov(n, weights, i, j))
    return result


def audit_robust_lorentzian_info_profile(
    n: int, weights: Dict[frozenset, float]
) -> InfoProfile:
    """Full information-theoretic audit of a FinsetLaw.

    Computes all quantities in the InfoProfile structure, checking
    certified bounds from the Lean theorems.

    Complexity: O(n² · |supp(μ)| + n · 2^n) for deletion entropies.

    Example:
        >>> from itertools import combinations
        >>> n, r = 4, 2
        >>> weights = {frozenset(s): 1/comb(n,r) for s in combinations(range(n), r)}
        >>> profile = audit_robust_lorentzian_info_profile(n, weights)
        >>> print(f"Entropy: {profile.entropy:.4f}")
        Entropy: 1.7918
    """
    profile = InfoProfile(n=n, entropy=compute_entropy(weights))

    # Marginals
    profile.coord_probs = [compute_coord_prob(n, weights, i) for i in range(n)]

    # Covariances
    profile.covariances = [
        [compute_coord_cov(n, weights, i, j) for j in range(n)]
        for i in range(n)
    ]

    # Mutual informations
    profile.mutual_infos = [
        [compute_pairwise_mi(n, weights, i, j) if i != j else 0.0
         for j in range(n)]
        for i in range(n)
    ]

    # Chi-squared bounds
    profile.chi_sq_bounds = [
        [compute_chi_sq_pair(n, weights, i, j) if i != j else 0.0
         for j in range(n)]
        for i in range(n)
    ]

    # Susceptibility
    profile.susceptibility = compute_susceptibility(n, weights)

    # Robustness gap
    profile.robustness_gap = compute_robustness_gap(n, weights)

    # Susceptibility bound
    sum_probs = sum(profile.coord_probs)
    profile.susceptibility_bound = profile.robustness_gap * sum_probs**2

    # Deletion entropies
    for k in range(n):
        del_weights = compute_deletion_pushforward(n, weights, k)
        profile.deleted_entropies.append(compute_entropy(del_weights))

    # Check MI ≤ χ²
    profile.mi_le_chisq_holds = all(
        profile.mutual_infos[i][j] <= profile.chi_sq_bounds[i][j] + 1e-10
        for i in range(n) for j in range(n) if i != j
    )

    return profile


# Example usage
if __name__ == "__main__":
    from math import comb

    print("Algorithm demo: Uniform matroid U(5,2)")
    n, r = 5, 2
    weights = {frozenset(s): 1.0/comb(n, r) for s in combinations(range(n), r)}
    profile = audit_robust_lorentzian_info_profile(n, weights)

    print(f"  Entropy: {profile.entropy:.6f} nats")
    print(f"  Gap ε: {profile.robustness_gap:.6f}")
    print(f"  Susceptibility: {profile.susceptibility:.6f}")
    print(f"  Susceptibility bound: {profile.susceptibility_bound:.6f}")
    print(f"  MI ≤ χ² holds: {profile.mi_le_chisq_holds}")
    print(f"  All negative covariance: {all(profile.covariances[i][j] <= 1e-10 for i in range(n) for j in range(n) if i != j)}")
