"""
Algorithms for auditing information-theoretic profiles of robustly Lorentzian measures.

Implements the computational methods underlying the formal theorems in
LorentzianInfoTheory.lean, providing:
- FinsetLaw construction and validation
- Coordinate marginals, covariances, and joint probabilities
- Entropy computation (Shannon entropy)
- Deletion pushforward and deletion entropy
- Chi-squared divergence and mutual information bounds
- Spin susceptibility computation
- Full audit of the certified theorem inequalities

All functions operate on probability measures over subsets of {0, 1, ..., n-1},
represented as dictionaries mapping frozensets to nonneg weights summing to 1.
"""

import numpy as np
from math import log, log2, comb
from itertools import combinations
from typing import Dict, Tuple, List, Optional, FrozenSet

# Type alias
SubsetLaw = Dict[FrozenSet[int], float]


def uniform_matroid_law(n: int, r: int) -> SubsetLaw:
    """Construct the uniform distribution over all r-element subsets of {0,...,n-1}.

    This is the canonical example of a strongly log-concave / Lorentzian measure.

    Args:
        n: Ground set size
        r: Rank (subset size)

    Returns:
        Dictionary mapping each r-subset to weight 1/C(n,r)
    """
    total = comb(n, r)
    law = {}
    for subset in combinations(range(n), r):
        law[frozenset(subset)] = 1.0 / total
    return law


def perturbed_matroid_law(n: int, r: int, epsilon: float, seed: int = 42) -> SubsetLaw:
    """Construct a perturbation of the uniform matroid law.

    Adds noise proportional to epsilon, then renormalizes.

    Args:
        n: Ground set size
        r: Rank
        epsilon: Perturbation strength (0 = uniform)
        seed: Random seed

    Returns:
        Perturbed probability law
    """
    rng = np.random.RandomState(seed)
    base = uniform_matroid_law(n, r)
    total = comb(n, r)
    noisy = {}
    for s, w in base.items():
        noise = rng.uniform(-epsilon / total, epsilon / total)
        noisy[s] = max(w + noise, 1e-15)
    Z = sum(noisy.values())
    return {s: w / Z for s, w in noisy.items()}


def validate_law(law: SubsetLaw, tol: float = 1e-10) -> bool:
    """Check nonnegativity and normalization."""
    total = sum(law.values())
    return all(v >= -tol for v in law.values()) and abs(total - 1.0) < tol


def coord_prob(law: SubsetLaw, i: int) -> float:
    """Marginal probability P(i ∈ S)."""
    return sum(w for s, w in law.items() if i in s)


def pair_joint_prob(law: SubsetLaw, i: int, j: int) -> float:
    """Joint probability P(i ∈ S ∧ j ∈ S)."""
    return sum(w for s, w in law.items() if i in s and j in s)


def coord_cov(law: SubsetLaw, i: int, j: int) -> float:
    """Covariance Cov(1_{i∈S}, 1_{j∈S})."""
    return pair_joint_prob(law, i, j) - coord_prob(law, i) * coord_prob(law, j)


def xlogx(x: float) -> float:
    """Compute x * log(x) with convention 0 * log(0) = 0."""
    if x <= 0:
        return 0.0
    return x * log(x)


def total_entropy(law: SubsetLaw) -> float:
    """Shannon entropy H(μ) = -∑ w log w."""
    return -sum(xlogx(w) for w in law.values())


def binary_entropy(p: float) -> float:
    """Binary entropy H(p) = -p log p - (1-p) log(1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -p * log(p) - (1 - p) * log(1 - p)


def delete_coord_weight(law: SubsetLaw, k: int) -> Dict[FrozenSet[int], float]:
    """Compute the deletion marginal weights.

    For each subset T not containing k:
        weight(T) = μ(T) + μ(T ∪ {k})
    """
    marginal = {}
    n_coords = set()
    for s in law:
        n_coords |= s

    for s, w in law.items():
        t = s - {k}
        marginal[t] = marginal.get(t, 0.0) + w
    return marginal


def delete_coord_entropy(law: SubsetLaw, k: int) -> float:
    """Entropy of the marginal after deleting coordinate k."""
    marginal = delete_coord_weight(law, k)
    return -sum(xlogx(w) for w in marginal.values())


def chi_sq_binary_pair(p: float, q: float, c: float) -> float:
    """Chi-squared divergence for a binary pair.

    χ²(X_i, X_j) = c² / (p(1-p) q(1-q))
    """
    denom = p * (1 - p) * q * (1 - q)
    if denom <= 0:
        return float('inf')
    return c ** 2 / denom


def mutual_info_bound(eps: float, p: float, q: float) -> float:
    """Upper bound on mutual information from robustness gap ε.

    I(X_i; X_j) ≤ ε² p q / ((1-p)(1-q))
    """
    denom = (1 - p) * (1 - q)
    if denom <= 0:
        return float('inf')
    return eps ** 2 * p * q / denom


def spin_susceptibility(law: SubsetLaw, n: int) -> float:
    """Total off-diagonal covariance magnitude χ = ∑_{i≠j} |Cov(X_i, X_j)|."""
    total = 0.0
    for i in range(n):
        for j in range(n):
            if i != j:
                total += abs(coord_cov(law, i, j))
    return total


def susceptibility_bound(law: SubsetLaw, n: int, eps: float) -> float:
    """Upper bound on susceptibility: ε · (∑ p_i)²."""
    total_p = sum(coord_prob(law, i) for i in range(n))
    return eps * total_p ** 2


def check_robustly_lorentzian(law: SubsetLaw, n: int, eps: float) -> Tuple[bool, str]:
    """Check if law satisfies the RobustlyLorentzian predicate with gap eps.

    Returns (True/False, diagnostic message).
    """
    if eps <= 0:
        return False, f"Gap ε = {eps} not positive"

    for i in range(n):
        pi = coord_prob(law, i)
        if pi <= 0:
            return False, f"Marginal p_{i} = {pi} not positive"
        if pi >= 1:
            return False, f"Marginal p_{i} = {pi} not < 1"

    for i in range(n):
        for j in range(i + 1, n):
            cov = coord_cov(law, i, j)
            if cov > 1e-10:
                return False, f"Cov({i},{j}) = {cov:.6f} > 0 (not negatively dependent)"
            pi, pj = coord_prob(law, i), coord_prob(law, j)
            if abs(cov) > eps * pi * pj + 1e-10:
                return False, f"|Cov({i},{j})| = {abs(cov):.6f} > ε·p_i·p_j = {eps * pi * pj:.6f}"

    return True, f"RobustlyLorentzian with gap {eps}"


class InfoProfile:
    """Complete information-theoretic profile of a FinsetLaw."""

    def __init__(self, law: SubsetLaw, n: int, eps: float):
        self.n = n
        self.eps = eps
        self.law = law

        # Marginals
        self.marginals = [coord_prob(law, i) for i in range(n)]

        # Covariance matrix
        self.cov_matrix = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                self.cov_matrix[i, j] = coord_cov(law, i, j)

        # Entropy
        self.entropy = total_entropy(law)

        # Deletion entropies
        self.deletion_entropies = [delete_coord_entropy(law, k) for k in range(n)]

        # Susceptibility
        self.susceptibility = spin_susceptibility(law, n)
        self.susceptibility_ub = susceptibility_bound(law, n, eps)

        # Pairwise MI bounds
        self.chi_sq = np.zeros((n, n))
        self.mi_bound = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                if i != j:
                    self.chi_sq[i, j] = chi_sq_binary_pair(
                        self.marginals[i], self.marginals[j], self.cov_matrix[i, j]
                    )
                    self.mi_bound[i, j] = mutual_info_bound(
                        eps, self.marginals[i], self.marginals[j]
                    )

        # Robustness check
        self.is_robust, self.robust_msg = check_robustly_lorentzian(law, n, eps)

    def check_theorem_bounds(self) -> Dict[str, Tuple[bool, str]]:
        """Check all proved theorem inequalities numerically."""
        results = {}

        # Theorem 1: Susceptibility bound
        t1_holds = self.susceptibility <= self.susceptibility_ub + 1e-10
        results["susceptibility_bound"] = (
            t1_holds,
            f"χ = {self.susceptibility:.6f} ≤ {self.susceptibility_ub:.6f}"
        )

        # Theorem 2: Chi-squared bounds (for all pairs)
        t2_all_hold = True
        for i in range(self.n):
            for j in range(i + 1, self.n):
                if self.chi_sq[i, j] > self.mi_bound[i, j] + 1e-10:
                    t2_all_hold = False
        results["chi_sq_bound"] = (
            t2_all_hold,
            f"All χ²(i,j) ≤ MI bound: {t2_all_hold}"
        )

        # Theorem 3: Entropy DPI (deletion ≤ total)
        t3_holds = all(de <= self.entropy + 1e-10 for de in self.deletion_entropies)
        results["entropy_dpi"] = (
            t3_holds,
            f"All H(π_k μ) ≤ H(μ): {t3_holds}"
        )

        # Theorem 4: Entropy deletion lower bound
        t4_holds = all(
            de >= self.entropy - log(2) - 1e-10
            for de in self.deletion_entropies
        )
        results["entropy_deletion_lb"] = (
            t4_holds,
            f"All H(π_k μ) ≥ H(μ) - log 2: {t4_holds}"
        )

        # Theorem 6: Shearer bound
        avg_del = np.mean(self.deletion_entropies)
        t6_holds = self.entropy <= avg_del + log(2) + 1e-10
        results["shearer_avg"] = (
            t6_holds,
            f"H(μ) = {self.entropy:.6f} ≤ avg_del + log2 = {avg_del + log(2):.6f}"
        )

        return results

    def summary(self) -> str:
        """Human-readable summary."""
        lines = [
            f"=== Info Profile: n={self.n}, ε={self.eps} ===",
            f"Entropy H(μ) = {self.entropy:.6f}",
            f"Marginals: {[f'{p:.4f}' for p in self.marginals]}",
            f"Susceptibility χ = {self.susceptibility:.6f}",
            f"Susceptibility bound = {self.susceptibility_ub:.6f}",
            f"Robustly Lorentzian: {self.robust_msg}",
            "",
            "Deletion entropies:",
        ]
        for k in range(self.n):
            lines.append(
                f"  H(π_{k} μ) = {self.deletion_entropies[k]:.6f} "
                f"(drop = {self.entropy - self.deletion_entropies[k]:.6f})"
            )
        lines.append("")
        lines.append("Theorem checks:")
        for name, (holds, msg) in self.check_theorem_bounds().items():
            status = "✓" if holds else "✗"
            lines.append(f"  [{status}] {name}: {msg}")
        return "\n".join(lines)


def audit_robust_lorentzian_info_profile(
    law: SubsetLaw, n: int, eps: float
) -> InfoProfile:
    """Main audit function: compute full info profile and check all bounds.

    Args:
        law: Probability law on subsets of {0,...,n-1}
        n: Ground set size
        eps: Robustness gap parameter

    Returns:
        InfoProfile with all computed quantities and bound checks
    """
    return InfoProfile(law, n, eps)


if __name__ == "__main__":
    # Example: uniform matroid on 5 elements, rank 2
    n, r = 5, 2
    law = uniform_matroid_law(n, r)

    # For uniform matroid U(n,r), the covariance can be computed:
    # p_i = r/n, Cov(i,j) = r(r-1)/(n(n-1)) - (r/n)^2 = -r(n-r)/(n^2(n-1))
    # |Cov| = r(n-r)/(n^2(n-1)), p_i*p_j = r^2/n^2
    # Gap: |Cov|/(p_i*p_j) = (n-r)/(r(n-1))
    eps = (n - r) / (r * (n - 1)) + 0.01  # slightly above exact gap

    profile = audit_robust_lorentzian_info_profile(law, n, eps)
    print(profile.summary())
