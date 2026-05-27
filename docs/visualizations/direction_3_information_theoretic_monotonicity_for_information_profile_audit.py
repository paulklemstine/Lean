#!/usr/bin/env python3
"""
algorithms.py — Algorithms for auditing entropy and mutual-information
profiles of robustly Lorentzian measures.

Implements:
- FinsetLaw construction and normalization
- Coordinate marginal computation
- Pairwise covariance matrix computation
- Mutual information computation (exact and chi-squared bound)
- Deletion pushforward entropy
- Robust Lorentzianity gap estimation
- Full information profile auditing

Complexity:
- Space: O(2^n) for storing subset weights
- Time: O(n^2 * 2^n) for full profile audit
"""

import numpy as np
from itertools import combinations
from math import log, comb
from typing import Dict, FrozenSet, List, Tuple, Optional


def binary_entropy(p: float) -> float:
    """Binary entropy H(p) = -p log p - (1-p) log(1-p).

    Uses natural logarithm. Convention: 0 log 0 = 0.

    Time: O(1)
    """
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * log(p) + (1 - p) * log(1 - p))


def shannon_entropy(weights: List[float]) -> float:
    """Shannon entropy H = -sum w_i log w_i.

    Time: O(|weights|)
    """
    return -sum(w * log(w) for w in weights if w > 0)


class FinsetLaw:
    """A probability mass function on subsets of [n].

    Attributes:
        n: Number of coordinates
        subsets: List of subsets with positive weight
        weights: Corresponding normalized weights

    Time complexity for construction: O(2^n)
    Space complexity: O(2^n)
    """

    def __init__(self, n: int, weight_dict: Dict[FrozenSet[int], float]):
        """Initialize from a dictionary of subset -> weight.

        Args:
            n: Number of coordinates
            weight_dict: Map from frozenset to nonneg weight
        """
        self.n = n
        self.subsets = []
        self.weights = []
        total = sum(w for w in weight_dict.values() if w > 0)
        if total <= 0:
            raise ValueError("Total weight must be positive")
        for s, w in weight_dict.items():
            if w > 0:
                self.subsets.append(s)
                self.weights.append(w / total)
        self._weight_dict = dict(zip(self.subsets, self.weights))

    @classmethod
    def uniform_matroid(cls, n: int, k: int) -> 'FinsetLaw':
        """Uniform distribution on k-element subsets of [n].

        Time: O(C(n,k))
        """
        d = {}
        for s in combinations(range(n), k):
            d[frozenset(s)] = 1.0
        return cls(n, d)

    @classmethod
    def perturbed_matroid(cls, n: int, k: int, delta: float = 0.1) -> 'FinsetLaw':
        """Perturbed matroid: weight ~ 1 + delta * sum(elements).

        Time: O(C(n,k))
        """
        d = {}
        for s in combinations(range(n), k):
            d[frozenset(s)] = 1.0 + delta * sum(s)
        return cls(n, d)

    def coord_prob(self, i: int) -> float:
        """Marginal probability P(i in S). Time: O(|support|)."""
        return sum(w for s, w in zip(self.subsets, self.weights) if i in s)

    def pair_joint_prob(self, i: int, j: int) -> float:
        """Joint probability P(i in S and j in S). Time: O(|support|)."""
        return sum(w for s, w in zip(self.subsets, self.weights) if i in s and j in s)

    def coord_cov(self, i: int, j: int) -> float:
        """Covariance Cov(1_i, 1_j). Time: O(|support|)."""
        return self.pair_joint_prob(i, j) - self.coord_prob(i) * self.coord_prob(j)

    def total_entropy(self) -> float:
        """Total entropy H(mu). Time: O(|support|)."""
        return shannon_entropy(self.weights)

    def mutual_info_coord(self, i: int, j: int) -> float:
        """Mutual information I(X_i; X_j). Time: O(|support|)."""
        pi = self.coord_prob(i)
        pj = self.coord_prob(j)
        pij = self.pair_joint_prob(i, j)
        p11, p10, p01, p00 = pij, pi - pij, pj - pij, 1 - pi - pj + pij
        vals = [max(v, 0) for v in [p00, p01, p10, p11]]
        return max(binary_entropy(pi) + binary_entropy(pj) - shannon_entropy(vals), 0.0)

    def chi_squared_bound(self, i: int, j: int) -> float:
        """Chi-squared upper bound on MI: cov^2/(pi(1-pi)*pj(1-pj)).

        This is the certified bound proved in Theorem 2.
        Time: O(|support|)
        """
        cov = self.coord_cov(i, j)
        pi, pj = self.coord_prob(i), self.coord_prob(j)
        denom = pi * (1 - pi) * pj * (1 - pj)
        return cov ** 2 / denom if denom > 0 else float('inf')

    def delete_coord_entropy(self, k: int) -> float:
        """Entropy after deleting coordinate k. Time: O(|support|)."""
        proj = {}
        for s, w in zip(self.subsets, self.weights):
            s_new = frozenset(x for x in s if x != k)
            proj[s_new] = proj.get(s_new, 0.0) + w
        return shannon_entropy(list(proj.values()))

    def susceptibility(self) -> float:
        """Total covariance (susceptibility). Time: O(n^2 * |support|)."""
        return sum(self.coord_cov(i, j) for i in range(self.n) for j in range(self.n))

    def robustly_lorentzian_gap(self) -> float:
        """Estimate maximal epsilon for robust Lorentzianity. Time: O(n^2 * |support|)."""
        if self.n <= 1:
            return min(self.coord_prob(0), 1 - self.coord_prob(0)) if self.n == 1 else 0.5

        eps_marginal = min(min(self.coord_prob(i), 1 - self.coord_prob(i))
                          for i in range(self.n))
        # Check negative dependence and cov control
        max_abs_cov = max(abs(self.coord_cov(i, j))
                          for i in range(self.n) for j in range(self.n) if i != j)
        # Need neg_dep: all off-diagonal covs ≤ 0
        all_neg = all(self.coord_cov(i, j) <= 1e-12
                      for i in range(self.n) for j in range(self.n) if i != j)
        if not all_neg:
            return 0.0
        return min(eps_marginal, max_abs_cov, 0.5)


def audit_info_profile(mu: FinsetLaw) -> dict:
    """Compute the full information profile of a FinsetLaw.

    Returns a dictionary with:
    - entropy: total entropy H(mu)
    - coord_probs: array of marginal probabilities
    - cov_matrix: n×n covariance matrix
    - mi_matrix: n×n mutual information matrix
    - chi2_matrix: n×n chi-squared bound matrix
    - susceptibility: total covariance
    - susceptibility_bound: n/4
    - deletion_entropies: array of entropies after deleting each coordinate
    - max_entropy_drop: maximum entropy drop under deletion
    - gap: estimated robust Lorentzianity gap

    Time: O(n^2 * |support|)
    Space: O(n^2)
    """
    n = mu.n
    profile = {
        'entropy': mu.total_entropy(),
        'coord_probs': np.array([mu.coord_prob(i) for i in range(n)]),
        'cov_matrix': np.array([[mu.coord_cov(i, j) for j in range(n)] for i in range(n)]),
        'mi_matrix': np.array([[mu.mutual_info_coord(i, j) for j in range(n)] for i in range(n)]),
        'chi2_matrix': np.array([[mu.chi_squared_bound(i, j) if i != j else 0.0
                                  for j in range(n)] for i in range(n)]),
        'susceptibility': mu.susceptibility(),
        'susceptibility_bound': n / 4.0,
        'deletion_entropies': np.array([mu.delete_coord_entropy(k) for k in range(n)]),
        'gap': mu.robustly_lorentzian_gap(),
    }
    profile['max_entropy_drop'] = profile['entropy'] - min(profile['deletion_entropies'])
    return profile


def verify_bounds(profile: dict) -> dict:
    """Verify all proved bounds against the computed profile.

    Returns a dictionary of bound names → (satisfied: bool, value, bound).
    """
    n = len(profile['coord_probs'])
    eps = profile['gap']
    results = {}

    # Theorem: entropy nonneg
    results['entropy_nonneg'] = (profile['entropy'] >= -1e-12,
                                  profile['entropy'], 0.0)

    # Theorem: susceptibility ≤ n/4
    results['susceptibility_bound'] = (
        profile['susceptibility'] <= profile['susceptibility_bound'] + 1e-10,
        profile['susceptibility'], profile['susceptibility_bound']
    )

    # Theorem: entropy drop ≤ log(2)
    results['deletion_bound'] = (
        profile['max_entropy_drop'] <= log(2) + 1e-10,
        profile['max_entropy_drop'], log(2)
    )

    # Theorem: MI ≤ chi-squared bound
    for i in range(n):
        for j in range(i + 1, n):
            mi = profile['mi_matrix'][i, j]
            chi2 = profile['chi2_matrix'][i, j]
            results[f'mi_le_chi2_{i}_{j}'] = (mi <= chi2 + 1e-10, mi, chi2)

    # Theorem: chi-squared ≤ ε²/(ε(1-ε))² if gap > 0
    if eps > 0:
        gap_bound = eps ** 2 / (eps * (1 - eps)) ** 2
        for i in range(n):
            for j in range(i + 1, n):
                chi2 = profile['chi2_matrix'][i, j]
                results[f'chi2_gap_bound_{i}_{j}'] = (chi2 <= gap_bound + 1e-10,
                                                       chi2, gap_bound)

    return results


if __name__ == "__main__":
    # Example usage
    print("Auditing U(2,5) — uniform matroid of rank 2 on 5 elements")
    mu = FinsetLaw.uniform_matroid(5, 2)
    profile = audit_info_profile(mu)
    bounds = verify_bounds(profile)

    print(f"  Entropy: {profile['entropy']:.6f}")
    print(f"  Gap ε: {profile['gap']:.6f}")
    print(f"  Susceptibility: {profile['susceptibility']:.6f} ≤ {profile['susceptibility_bound']:.4f}")
    print(f"  Max entropy drop: {profile['max_entropy_drop']:.6f} ≤ log(2) = {log(2):.6f}")
    print(f"\n  Bound verification:")
    all_pass = True
    for name, (passed, val, bnd) in bounds.items():
        status = "✓" if passed else "✗"
        if not passed:
            all_pass = False
            print(f"    {status} {name}: {val:.6f} vs {bnd:.6f}")
    if all_pass:
        print("    All bounds verified ✓")
