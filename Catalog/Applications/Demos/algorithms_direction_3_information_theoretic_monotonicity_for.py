#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for auditing information-theoretic profiles
of robustly Lorentzian measures.

Implements:
1. FinsetLaw construction and manipulation
2. Information profile computation (entropy, MI, susceptibility)
3. Robustness certification
4. Deletion pushforward computation
5. Bound verification against proved theorems
"""

import numpy as np
from itertools import combinations
from math import log, log2, comb, exp
from typing import Dict, List, Tuple, Optional, FrozenSet, Set


# =============================================================================
# Core Data Structures
# =============================================================================

class FinsetLaw:
    """
    Probability mass function on subsets of [n] = {0, ..., n-1}.

    Corresponds to the Lean structure:
        structure FinsetLaw (n : ℕ) where
          weight : Finset (Fin n) → ℝ
          nonneg : ∀ s, 0 ≤ weight s
          total_one : ∑ s : Finset (Fin n), weight s = 1

    Time complexity: O(2^n) for initialization, O(2^n) for most queries.
    Space complexity: O(2^n) for weight storage.
    """

    def __init__(self, n: int, weights: Optional[Dict[FrozenSet[int], float]] = None):
        """
        Args:
            n: Number of coordinates
            weights: Dictionary mapping subsets (as frozensets) to probabilities.
                     If None, uniform over all subsets.
        """
        self.n = n
        self._subsets = None  # Lazy initialization
        if weights is None:
            total = 2 ** n
            self.weights = {self._idx_to_set(i): 1.0 / total for i in range(total)}
        else:
            self.weights = dict(weights)
            # Fill missing subsets with 0
            for i in range(2 ** n):
                s = self._idx_to_set(i)
                if s not in self.weights:
                    self.weights[s] = 0.0
        self._normalize()

    def _idx_to_set(self, idx: int) -> FrozenSet[int]:
        """Convert integer index to subset."""
        return frozenset(i for i in range(self.n) if idx & (1 << i))

    def _normalize(self):
        """Normalize weights to sum to 1."""
        total = sum(self.weights.values())
        if total > 0:
            self.weights = {s: w / total for s, w in self.weights.items()}

    @property
    def subsets(self) -> List[FrozenSet[int]]:
        if self._subsets is None:
            self._subsets = [self._idx_to_set(i) for i in range(2 ** self.n)]
        return self._subsets

    def coord_prob(self, i: int) -> float:
        """
        Compute P(i ∈ S) = ∑_{s : i ∈ s} μ(s).

        Time: O(2^n)
        """
        return sum(w for s, w in self.weights.items() if i in s)

    def pair_joint_prob(self, i: int, j: int) -> float:
        """
        Compute P(i ∈ S ∧ j ∈ S).

        Time: O(2^n)
        """
        return sum(w for s, w in self.weights.items() if i in s and j in s)

    def coord_cov(self, i: int, j: int) -> float:
        """
        Compute Cov(1_{i∈S}, 1_{j∈S}) = P(i,j ∈ S) - P(i ∈ S)·P(j ∈ S).

        Time: O(2^n)
        """
        return self.pair_joint_prob(i, j) - self.coord_prob(i) * self.coord_prob(j)

    def total_entropy(self) -> float:
        """
        Compute Shannon entropy H(μ) = -∑_S μ(S) log μ(S).

        Time: O(2^n)
        """
        return -sum(w * log(w) for w in self.weights.values() if w > 0)

    def mutual_info_proxy(self, i: int, j: int) -> float:
        """
        Compute chi-squared MI proxy: c²/(p(1-p)·q(1-q)).

        This is an upper bound on the true mutual information I(X_i; X_j)
        by the chi-squared divergence bound on KL divergence.

        Time: O(2^n)
        """
        p = self.coord_prob(i)
        q = self.coord_prob(j)
        c = self.coord_cov(i, j)
        if p <= 0 or p >= 1 or q <= 0 or q >= 1:
            return 0.0
        return c ** 2 / (p * (1 - p) * q * (1 - q))

    def delete_coord(self, k: int) -> 'FinsetLaw':
        """
        Compute deletion pushforward: marginalize out coordinate k.

        For each subset s not containing k, the new weight is
        μ(s) + μ(s ∪ {k}), with indices relabeled.

        Time: O(2^n)
        Space: O(2^(n-1))
        """
        new_weights: Dict[FrozenSet[int], float] = {}
        for s, w in self.weights.items():
            s_without_k = frozenset(x for x in s if x != k)
            relabeled = frozenset(x if x < k else x - 1 for x in s_without_k)
            new_weights[relabeled] = new_weights.get(relabeled, 0.0) + w
        return FinsetLaw(self.n - 1, new_weights)

    def susceptibility(self) -> float:
        """
        Compute susceptibility χ = ∑_{i,j} Cov(X_i, X_j).

        Time: O(n² · 2^n)
        """
        return sum(self.coord_cov(i, j)
                    for i in range(self.n) for j in range(self.n))


# =============================================================================
# Information Profile
# =============================================================================

class InfoProfile:
    """
    Complete information-theoretic profile of a FinsetLaw.

    Corresponds to the Lean structure:
        structure InfoProfile (n : ℕ) where
          entropy : ℝ
          coordMarginals : Fin n → ℝ
          susceptibility : ℝ
    """

    def __init__(self, mu: FinsetLaw):
        self.n = mu.n
        self.entropy = mu.total_entropy()
        self.coord_marginals = [mu.coord_prob(i) for i in range(mu.n)]
        self.coord_variances = [mu.coord_cov(i, i) for i in range(mu.n)]
        self.susceptibility = mu.susceptibility()

        # Pairwise covariance matrix
        self.cov_matrix = np.zeros((mu.n, mu.n))
        for i in range(mu.n):
            for j in range(mu.n):
                self.cov_matrix[i, j] = mu.coord_cov(i, j)

        # MI proxy matrix
        self.mi_matrix = np.zeros((mu.n, mu.n))
        for i in range(mu.n):
            for j in range(mu.n):
                if i != j:
                    self.mi_matrix[i, j] = mu.mutual_info_proxy(i, j)

        # Deletion entropies
        if mu.n > 0:
            self.deletion_entropies = [mu.delete_coord(k).total_entropy()
                                        for k in range(mu.n)]
        else:
            self.deletion_entropies = []

    def __repr__(self):
        lines = [
            f"InfoProfile(n={self.n})",
            f"  Entropy: {self.entropy:.6f}",
            f"  Marginals: {[f'{p:.4f}' for p in self.coord_marginals]}",
            f"  Max |Cov|: {np.max(np.abs(self.cov_matrix - np.diag(np.diag(self.cov_matrix)))):.6f}",
            f"  Max MI proxy: {np.max(self.mi_matrix):.6f}",
            f"  Susceptibility: {self.susceptibility:.6f}",
            f"  Deletion entropies: {[f'{h:.4f}' for h in self.deletion_entropies]}",
        ]
        return "\n".join(lines)


# =============================================================================
# Robustness Certification
# =============================================================================

def certify_robust_lorentzian(mu: FinsetLaw, eps: float) -> Tuple[bool, str]:
    """
    Check whether μ satisfies RobustlyLorentzian(μ, ε).

    Verifies:
    1. 0 < ε ≤ 1/2
    2. ∀ i, ε ≤ coordProb(i) ≤ 1 - ε
    3. ∀ i ≠ j, Cov(i,j) ≤ 0
    4. ∀ i ≠ j, |Cov(i,j)| ≤ ε

    Time: O(n² · 2^n)
    """
    tol = 1e-12

    if eps <= 0:
        return False, "ε must be positive"
    if eps > 0.5 + tol:
        return False, f"ε = {eps} > 1/2"

    for i in range(mu.n):
        p = mu.coord_prob(i)
        if p < eps - tol:
            return False, f"marginal p_{i} = {p:.6f} < ε = {eps}"
        if p > 1 - eps + tol:
            return False, f"marginal p_{i} = {p:.6f} > 1-ε = {1-eps}"

    for i in range(mu.n):
        for j in range(mu.n):
            if i != j:
                c = mu.coord_cov(i, j)
                if c > tol:
                    return False, f"Cov({i},{j}) = {c:.8f} > 0 (negative dependence violated)"
                if abs(c) > eps + tol:
                    return False, f"|Cov({i},{j})| = {abs(c):.8f} > ε = {eps}"

    return True, "Certified robustly Lorentzian"


def find_max_eps(mu: FinsetLaw, resolution: int = 1000) -> float:
    """
    Find the largest ε for which μ is robustly Lorentzian.

    Uses binary search.
    Time: O(log(resolution) · n² · 2^n)
    """
    lo, hi = 0.0, 0.5
    best = 0.0
    for _ in range(50):  # Binary search iterations
        mid = (lo + hi) / 2
        ok, _ = certify_robust_lorentzian(mu, mid)
        if ok:
            best = mid
            lo = mid
        else:
            hi = mid
    return best


# =============================================================================
# Bound Verification
# =============================================================================

def verify_mi_bound(mu: FinsetLaw, eps: float) -> Dict:
    """
    Verify the MI bound: mutualInfoProxy(i,j) ≤ 1/(1-ε)² for all i ≠ j.

    Time: O(n² · 2^n)
    """
    bound = 1.0 / (1 - eps) ** 2 if eps < 1 else float('inf')
    violations = []
    max_mi = 0.0

    for i in range(mu.n):
        for j in range(mu.n):
            if i != j:
                mi = mu.mutual_info_proxy(i, j)
                max_mi = max(max_mi, mi)
                if mi > bound + 1e-10:
                    violations.append((i, j, mi))

    return {
        'bound': bound,
        'max_mi': max_mi,
        'satisfied': len(violations) == 0,
        'violations': violations,
        'slack': bound - max_mi
    }


def verify_entropy_deletion(mu: FinsetLaw) -> Dict:
    """
    Verify H(delete_k(μ)) ≥ H(μ) - log 2 for all k.

    Time: O(n · 2^n)
    """
    H = mu.total_entropy()
    bound = log(2)
    results = []

    for k in range(mu.n):
        H_del = mu.delete_coord(k).total_entropy()
        drop = H - H_del
        results.append({
            'k': k,
            'H_original': H,
            'H_deleted': H_del,
            'drop': drop,
            'bound': bound,
            'satisfied': drop <= bound + 1e-10
        })

    return {
        'all_satisfied': all(r['satisfied'] for r in results),
        'max_drop': max(r['drop'] for r in results),
        'bound': bound,
        'details': results
    }


def verify_susceptibility_bound(mu: FinsetLaw, eps: float) -> Dict:
    """
    Verify χ ≤ n·(1/4 + (n-1)·ε).

    Time: O(n² · 2^n)
    """
    n = mu.n
    chi = mu.susceptibility()
    bound = n * (0.25 + (n - 1) * eps)

    return {
        'susceptibility': chi,
        'bound': bound,
        'satisfied': chi <= bound + 1e-10,
        'slack': bound - chi
    }


# =============================================================================
# Audit Pipeline
# =============================================================================

def audit_robust_lorentzian_info_profile(
    mu: FinsetLaw,
    eps: Optional[float] = None
) -> Dict:
    """
    Full audit of information-theoretic profile against proved bounds.

    If eps is None, automatically finds the largest valid ε.

    Time: O(n² · 2^n)
    """
    if eps is None:
        eps = find_max_eps(mu)

    profile = InfoProfile(mu)
    certified, cert_msg = certify_robust_lorentzian(mu, eps)

    mi_check = verify_mi_bound(mu, eps)
    entropy_check = verify_entropy_deletion(mu)
    suscept_check = verify_susceptibility_bound(mu, eps)

    return {
        'profile': profile,
        'eps': eps,
        'certified': certified,
        'cert_message': cert_msg,
        'mi_bound_check': mi_check,
        'entropy_deletion_check': entropy_check,
        'susceptibility_check': suscept_check,
        'all_bounds_hold': (mi_check['satisfied'] and
                            entropy_check['all_satisfied'] and
                            suscept_check['satisfied'])
    }


# =============================================================================
# Distribution Constructors
# =============================================================================

def uniform_matroid(n: int, r: int) -> FinsetLaw:
    """
    Uniform distribution over r-element subsets of [n].

    This is the canonical example of a strongly log-concave / Lorentzian
    distribution, arising from the uniform matroid of rank r on n elements.
    """
    subsets = [frozenset(c) for c in combinations(range(n), r)]
    w = 1.0 / len(subsets)
    return FinsetLaw(n, {s: w for s in subsets})


def perturbed_matroid(n: int, r: int, delta: float = 0.01) -> FinsetLaw:
    """
    Perturbed uniform matroid: slightly favors subsets containing element 0.
    """
    subsets = [frozenset(c) for c in combinations(range(n), r)]
    weights = {s: 1.0 + delta * (1 if 0 in s else 0) for s in subsets}
    return FinsetLaw(n, weights)


def determinantal_point_process(n: int, L: np.ndarray) -> FinsetLaw:
    """
    Construct a DPP with L-ensemble kernel L.

    P(S) ∝ det(L_S) where L_S is the submatrix of L indexed by S.
    DPPs are strongly log-concave and hence Lorentzian.
    """
    weights = {}
    for i in range(2 ** n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        if len(s) == 0:
            weights[s] = 1.0
        else:
            idx = sorted(s)
            submatrix = L[np.ix_(idx, idx)]
            det = np.linalg.det(submatrix)
            weights[s] = max(0, det)
    return FinsetLaw(n, weights)


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Auditing U(6,3) — Uniform matroid of rank 3 on 6 elements")
    print("=" * 60)

    mu = uniform_matroid(6, 3)
    result = audit_robust_lorentzian_info_profile(mu)

    print(f"\n{result['profile']}")
    print(f"\nOptimal ε: {result['eps']:.6f}")
    print(f"Certified: {result['certified']} ({result['cert_message']})")
    print(f"\nMI bound check: {'PASS' if result['mi_bound_check']['satisfied'] else 'FAIL'}")
    print(f"  Max MI: {result['mi_bound_check']['max_mi']:.6f}")
    print(f"  Bound: {result['mi_bound_check']['bound']:.6f}")
    print(f"\nEntropy deletion check: {'PASS' if result['entropy_deletion_check']['all_satisfied'] else 'FAIL'}")
    print(f"  Max drop: {result['entropy_deletion_check']['max_drop']:.6f}")
    print(f"  Bound (log 2): {result['entropy_deletion_check']['bound']:.6f}")
    print(f"\nSusceptibility check: {'PASS' if result['susceptibility_check']['satisfied'] else 'FAIL'}")
    print(f"  χ: {result['susceptibility_check']['susceptibility']:.6f}")
    print(f"  Bound: {result['susceptibility_check']['bound']:.6f}")
    print(f"\nAll bounds hold: {result['all_bounds_hold']}")
