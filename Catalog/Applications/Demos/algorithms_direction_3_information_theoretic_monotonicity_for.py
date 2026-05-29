"""
Information-Theoretic Monotonicity for Robustly Lorentzian Measures
===================================================================

Algorithms for computing entropy, mutual information, susceptibility,
and auditing the robustness properties of finite subset laws.

Implements the core computational pipeline described in the research paper:
  FinsetLaw → coordinate marginals → covariances → MI bounds → susceptibility
"""

import numpy as np
from math import comb, log, sqrt
from typing import List, Tuple, Dict, Optional
from itertools import combinations
from dataclasses import dataclass, field


@dataclass
class FinsetLaw:
    """A probability law on subsets of [n].
    
    Attributes:
        n: Number of coordinates.
        weights: Dictionary mapping frozensets to probabilities.
    """
    n: int
    weights: Dict[frozenset, float]

    def __post_init__(self):
        total = sum(self.weights.values())
        assert abs(total - 1.0) < 1e-10, f"Weights must sum to 1, got {total}"
        for w in self.weights.values():
            assert w >= -1e-15, f"Weights must be nonneg, got {w}"

    @classmethod
    def uniform_matroid(cls, n: int, k: int) -> 'FinsetLaw':
        """Uniform distribution on k-element subsets of [n]."""
        c = comb(n, k)
        weights = {}
        for subset in combinations(range(n), k):
            weights[frozenset(subset)] = 1.0 / c
        return cls(n=n, weights=weights)

    @classmethod
    def perturbed_matroid(cls, n: int, k: int, epsilon: float = 0.1) -> 'FinsetLaw':
        """Perturbed uniform matroid: adds random noise to weights."""
        np.random.seed(42)
        c = comb(n, k)
        base_weight = 1.0 / c
        weights = {}
        for subset in combinations(range(n), k):
            noise = np.random.uniform(-epsilon * base_weight, epsilon * base_weight)
            weights[frozenset(subset)] = max(base_weight + noise, 1e-15)
        total = sum(weights.values())
        weights = {k: v / total for k, v in weights.items()}
        return cls(n=n, weights=weights)


def coord_prob(mu: FinsetLaw, i: int) -> float:
    """Marginal probability P(i ∈ S)."""
    return sum(w for s, w in mu.weights.items() if i in s)


def pair_joint_prob(mu: FinsetLaw, i: int, j: int) -> float:
    """Joint probability P(i ∈ S ∧ j ∈ S)."""
    return sum(w for s, w in mu.weights.items() if i in s and j in s)


def coord_cov(mu: FinsetLaw, i: int, j: int) -> float:
    """Covariance Cov(1_{i∈S}, 1_{j∈S})."""
    return pair_joint_prob(mu, i, j) - coord_prob(mu, i) * coord_prob(mu, j)


def total_entropy(mu: FinsetLaw) -> float:
    """Shannon entropy H(μ) = -∑ w log w."""
    return -sum(w * log(w) for w in mu.weights.values() if w > 1e-30)


def binary_entropy(p: float) -> float:
    """Binary entropy H(p) = -p log p - (1-p) log(1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -p * log(p) - (1 - p) * log(1 - p)


def chi_sq_binary_pair(p: float, q: float, c: float) -> float:
    """Chi-squared divergence c² / (p(1-p)q(1-q))."""
    denom = p * (1 - p) * q * (1 - q)
    if denom < 1e-30:
        return float('inf')
    return c**2 / denom


def mutual_info_coord(mu: FinsetLaw, i: int, j: int) -> float:
    """Mutual information I(X_i; X_j) between coordinate indicators.
    
    Computed from the 2x2 joint distribution.
    """
    pi = coord_prob(mu, i)
    pj = coord_prob(mu, j)
    pij = pair_joint_prob(mu, i, j)
    
    # 2x2 table
    p11 = pij
    p10 = pi - pij
    p01 = pj - pij
    p00 = 1 - pi - pj + pij
    
    mi = 0.0
    for pxy, px, py in [(p11, pi, pj), (p10, pi, 1-pj),
                         (p01, 1-pi, pj), (p00, 1-pi, 1-pj)]:
        if pxy > 1e-30 and px > 1e-30 and py > 1e-30:
            mi += pxy * log(pxy / (px * py))
    return max(mi, 0.0)


def spin_susceptibility(mu: FinsetLaw) -> float:
    """Total off-diagonal covariance magnitude χ = ∑_{i≠j} |Cov(i,j)|."""
    chi = 0.0
    for i in range(mu.n):
        for j in range(mu.n):
            if i != j:
                chi += abs(coord_cov(mu, i, j))
    return chi


def set_size_variance(mu: FinsetLaw) -> float:
    """Variance of the set size |S|."""
    mean = sum(w * len(s) for s, w in mu.weights.items())
    second_moment = sum(w * len(s)**2 for s, w in mu.weights.items())
    return second_moment - mean**2


def susceptibility_bound(mu: FinsetLaw, epsilon: float) -> float:
    """Susceptibility bound: ε * (∑ pᵢ)²."""
    total_p = sum(coord_prob(mu, i) for i in range(mu.n))
    return epsilon * total_p**2


def fisher_info_bound(mu: FinsetLaw, epsilon: float) -> float:
    """Fisher information bound: ∑ pᵢ(1-pᵢ) + ε * (∑ pᵢ)²."""
    diag = sum(coord_prob(mu, i) * (1 - coord_prob(mu, i)) for i in range(mu.n))
    total_p = sum(coord_prob(mu, i) for i in range(mu.n))
    return diag + epsilon * total_p**2


@dataclass
class InfoProfile:
    """Complete information-theoretic profile of a FinsetLaw.
    
    Fields:
        n: number of coordinates
        entropy: Shannon entropy H(μ)
        coord_probs: marginal probabilities
        covariances: pairwise covariance matrix
        mutual_infos: pairwise MI matrix
        chi_sq_values: pairwise chi-squared divergences
        susceptibility: total off-diagonal |Cov|
        set_size_var: Var(|S|)
        sum_marginal_variances: ∑ pᵢ(1-pᵢ)
        epsilon_estimate: estimated robustness gap
        bounds_satisfied: dict of bound name → bool
    """
    n: int
    entropy: float
    coord_probs: List[float]
    covariances: List[List[float]]
    mutual_infos: List[List[float]]
    chi_sq_values: List[List[float]]
    susceptibility: float
    set_size_var: float
    sum_marginal_variances: float
    epsilon_estimate: float
    bounds_satisfied: Dict[str, bool] = field(default_factory=dict)


def estimate_lorentzian_gap(mu: FinsetLaw) -> float:
    """Estimate the robustness gap ε from the data.
    
    ε is the smallest value such that |Cov(i,j)| ≤ ε * pᵢ * pⱼ for all i≠j.
    """
    eps = 0.0
    for i in range(mu.n):
        for j in range(i + 1, mu.n):
            pi = coord_prob(mu, i)
            pj = coord_prob(mu, j)
            cov = abs(coord_cov(mu, i, j))
            if pi * pj > 1e-15:
                eps = max(eps, cov / (pi * pj))
    return eps


def check_negative_dependence(mu: FinsetLaw) -> bool:
    """Check if all off-diagonal covariances are ≤ 0."""
    for i in range(mu.n):
        for j in range(i + 1, mu.n):
            if coord_cov(mu, i, j) > 1e-10:
                return False
    return True


def audit_robust_lorentzian_info_profile(mu: FinsetLaw) -> InfoProfile:
    """Complete audit of information-theoretic properties.
    
    Computes all quantities and checks all theorem bounds.
    
    Time complexity: O(2^n * n²) — enumerate all subsets and pairs.
    Space complexity: O(n²) for the matrices.
    """
    n = mu.n
    
    # Coordinate marginals
    probs = [coord_prob(mu, i) for i in range(n)]
    
    # Covariance matrix
    covs = [[coord_cov(mu, i, j) for j in range(n)] for i in range(n)]
    
    # Mutual information matrix
    mis = [[mutual_info_coord(mu, i, j) if i != j else 0.0 for j in range(n)]
           for i in range(n)]
    
    # Chi-squared divergence matrix
    chis = [[chi_sq_binary_pair(probs[i], probs[j], covs[i][j])
             if i != j else 0.0 for j in range(n)]
            for i in range(n)]
    
    # Scalar quantities
    ent = total_entropy(mu)
    chi = spin_susceptibility(mu)
    var_s = set_size_variance(mu)
    sum_marg_var = sum(p * (1 - p) for p in probs)
    eps = estimate_lorentzian_gap(mu)
    
    # Check bounds
    bounds = {}
    
    # Theorem 1: Susceptibility bound χ ≤ ε * (∑ pᵢ)²
    susc_bound = susceptibility_bound(mu, eps)
    bounds['susceptibility_le_bound'] = chi <= susc_bound + 1e-10
    
    # Theorem 7: Off-diagonal covariance sum ≤ 0
    offdiag_sum = sum(covs[i][j] for i in range(n) for j in range(n) if i != j)
    bounds['offdiag_cov_nonpos'] = offdiag_sum <= 1e-10
    
    # Theorem 8: |Cov(i,j)| ≤ ε
    bounds['pairwise_cov_uniform'] = all(
        abs(covs[i][j]) <= eps + 1e-10
        for i in range(n) for j in range(n) if i != j
    )
    
    # Theorem 9: χ ≤ ε * n²
    bounds['susceptibility_le_eps_n_sq'] = chi <= eps * n**2 + 1e-10
    
    # Theorem 12: Fisher info bound
    fisher = fisher_info_bound(mu, eps)
    bounds['fisher_info_bound'] = chi + sum_marg_var <= fisher + 1e-10
    
    # Negative dependence
    bounds['negative_dependence'] = check_negative_dependence(mu)
    
    # MI ≤ χ² for all pairs
    bounds['mi_le_chi_sq'] = all(
        mis[i][j] <= chis[i][j] + 1e-10
        for i in range(n) for j in range(n) if i != j
    )
    
    # Variance concentration: Var(|S|) ≤ ∑ pᵢ(1-pᵢ) (under neg dep)
    if bounds['negative_dependence']:
        bounds['variance_concentration'] = var_s <= sum_marg_var + 1e-10
    
    return InfoProfile(
        n=n,
        entropy=ent,
        coord_probs=probs,
        covariances=covs,
        mutual_infos=mis,
        chi_sq_values=chis,
        susceptibility=chi,
        set_size_var=var_s,
        sum_marginal_variances=sum_marg_var,
        epsilon_estimate=eps,
        bounds_satisfied=bounds,
    )


def deletion_entropy(mu: FinsetLaw, k: int) -> float:
    """Entropy of the law after deleting coordinate k.
    
    The deletion pushforward maps S → S \\ {k}, collapsing subsets
    that differ only in the presence/absence of k.
    """
    new_weights: Dict[frozenset, float] = {}
    for s, w in mu.weights.items():
        projected = frozenset(x for x in s if x != k)
        new_weights[projected] = new_weights.get(projected, 0.0) + w
    return -sum(w * log(w) for w in new_weights.values() if w > 1e-30)


def projection_entropy(mu: FinsetLaw, coords: frozenset) -> float:
    """Entropy of the marginal law on a subset of coordinates.
    
    Projects each S to S ∩ coords.
    """
    new_weights: Dict[frozenset, float] = {}
    for s, w in mu.weights.items():
        projected = s & coords
        new_weights[projected] = new_weights.get(projected, 0.0) + w
    return -sum(w * log(w) for w in new_weights.values() if w > 1e-30)


if __name__ == "__main__":
    print("=" * 70)
    print("Information-Theoretic Audit: Uniform Matroid U(3,6)")
    print("=" * 70)
    
    mu = FinsetLaw.uniform_matroid(6, 3)
    profile = audit_robust_lorentzian_info_profile(mu)
    
    print(f"\nEntropy: {profile.entropy:.6f}")
    print(f"Estimated ε: {profile.epsilon_estimate:.6f}")
    print(f"Susceptibility: {profile.susceptibility:.6f}")
    print(f"Set size variance: {profile.set_size_var:.6f}")
    print(f"∑ pᵢ(1-pᵢ): {profile.sum_marginal_variances:.6f}")
    
    print("\nCoordinate probabilities:")
    print(f"  {[f'{p:.4f}' for p in profile.coord_probs]}")
    
    print("\nBound satisfaction:")
    for name, satisfied in profile.bounds_satisfied.items():
        status = "✓" if satisfied else "✗"
        print(f"  {status} {name}")
    
    print(f"\nDeletion entropies (removing each coordinate):")
    for k in range(mu.n):
        de = deletion_entropy(mu, k)
        print(f"  Delete coord {k}: H = {de:.6f} (drop = {profile.entropy - de:.6f})")
