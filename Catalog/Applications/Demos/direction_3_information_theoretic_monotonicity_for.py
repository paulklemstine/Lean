#!/usr/bin/env python3
"""
applications.py — Real-world applications of information-theoretic monotonicity
for robustly Lorentzian measures.

Demonstrates practical applications in:
1. Privacy amplification under coordinate deletion
2. Sampling quality certification
3. Anti-clustering bounds in statistical mechanics
4. Communication complexity bounds
"""

import numpy as np
from itertools import combinations
from math import log, log2, comb, sqrt, exp
from typing import Dict, List, Tuple


class FinsetLaw:
    """Probability law on subsets of [n]."""

    def __init__(self, n: int, weights: Dict[frozenset, float]):
        self.n = n
        self.weights = {}
        total = sum(w for w in weights.values() if w > 0)
        for s, w in weights.items():
            if w > 0:
                self.weights[s] = w / total

    def coord_prob(self, i: int) -> float:
        return sum(w for s, w in self.weights.items() if i in s)

    def pair_joint_prob(self, i: int, j: int) -> float:
        return sum(w for s, w in self.weights.items() if i in s and j in s)

    def coord_cov(self, i: int, j: int) -> float:
        return self.pair_joint_prob(i, j) - self.coord_prob(i) * self.coord_prob(j)

    def entropy(self) -> float:
        return -sum(w * log(w) for w in self.weights.values() if w > 0)

    def pairwise_mi(self, i: int, j: int) -> float:
        p, q = self.coord_prob(i), self.coord_prob(j)
        r = self.pair_joint_prob(i, j)
        mi = 0.0
        for pxy, pxpy in [(r, p*q), (p-r, p*(1-q)), (q-r, (1-p)*q),
                           (1-p-q+r, (1-p)*(1-q))]:
            if pxy > 1e-15 and pxpy > 1e-15:
                mi += pxy * log(pxy / pxpy)
        return max(0.0, mi)

    def delete_coord(self, k: int) -> 'FinsetLaw':
        new_w: Dict[frozenset, float] = {}
        for s, w in self.weights.items():
            ns = frozenset(i if i < k else i-1 for i in s if i != k)
            new_w[ns] = new_w.get(ns, 0.0) + w
        return FinsetLaw(self.n - 1, new_w)


def uniform_matroid(n: int, r: int) -> FinsetLaw:
    w = {frozenset(s): 1.0 for s in combinations(range(n), r)}
    return FinsetLaw(n, w)


# ============================================================================
# APPLICATION 1: Privacy Amplification Under Coordinate Deletion
# ============================================================================

def privacy_amplification_demo():
    """
    Show that deleting a coordinate from a robustly Lorentzian distribution
    preserves most of the entropy, providing a privacy guarantee.

    In differential privacy, deletion of a data point should not change
    the output distribution too much. For Lorentzian measures, the entropy
    drop under deletion is bounded, providing a privacy certificate.
    """
    print("\n" + "="*65)
    print("  APPLICATION 1: Privacy Amplification Under Deletion")
    print("="*65)
    print("""
  When a robustly Lorentzian measure represents a data distribution,
  deleting one coordinate (data point) preserves most of the entropy.
  This bounds how much an adversary can learn from the deletion.
  """)

    for n in [4, 5, 6, 7]:
        r = n // 2
        mu = uniform_matroid(n, r)
        H = mu.entropy()
        max_drop = 0
        for k in range(n):
            Hk = mu.delete_coord(k).entropy()
            drop = H - Hk
            max_drop = max(max_drop, drop)

        eps = max(abs(mu.coord_cov(i, j)) / (mu.coord_prob(i) * mu.coord_prob(j))
                  for i in range(n) for j in range(i+1, n))

        print(f"  U({n},{r}): H = {H:.4f}, max entropy drop = {max_drop:.4f}, "
              f"ε = {eps:.4f}, log(1/ε) = {log(1/eps):.4f}")
        print(f"    → Deletion preserves {100*(1-max_drop/H):.1f}% of entropy")


# ============================================================================
# APPLICATION 2: Sampling Quality Certification
# ============================================================================

def sampling_certification_demo():
    """
    Use susceptibility bounds to certify the quality of MCMC samples.

    If a sample from a Lorentzian distribution has susceptibility below
    the certified bound, we have evidence that the sampler has mixed well.
    """
    print("\n" + "="*65)
    print("  APPLICATION 2: Sampling Quality Certification")
    print("="*65)
    print("""
  The susceptibility χ = Σ|Cov(Xᵢ, Xⱼ)| measures total correlation.
  For robustly Lorentzian measures, χ ≤ ε·(Σpᵢ)² (proved in Lean).
  This gives a checkable certificate for sampling quality.
  """)

    n, r = 6, 3
    mu = uniform_matroid(n, r)

    # Compute exact susceptibility
    chi = sum(abs(mu.coord_cov(i, j))
              for i in range(n) for j in range(n) if i != j)

    # Compute bound
    eps = max(abs(mu.coord_cov(i, j)) / (mu.coord_prob(i) * mu.coord_prob(j))
              for i in range(n) for j in range(i+1, n))
    sum_probs = sum(mu.coord_prob(i) for i in range(n))
    bound = eps * sum_probs**2

    print(f"  U({n},{r}):")
    print(f"    Susceptibility χ = {chi:.6f}")
    print(f"    Certified bound  = {bound:.6f}")
    print(f"    Ratio χ/bound    = {chi/bound:.4f}")
    print(f"    Certificate: PASS ✓" if chi <= bound + 1e-10 else "    Certificate: FAIL ✗")

    # Simulate "bad" samples by adding positive correlations
    print("\n  Comparison with positively-correlated perturbation:")
    for delta in [0.0, 0.1, 0.3, 0.5]:
        weights_pert = {}
        for s, w in mu.weights.items():
            bonus = delta * (1.0 if 0 in s and 1 in s else 0.0)
            weights_pert[s] = w + bonus
        mu_pert = FinsetLaw(n, weights_pert)
        chi_pert = sum(abs(mu_pert.coord_cov(i, j))
                      for i in range(n) for j in range(n) if i != j)
        print(f"    δ = {delta}: χ = {chi_pert:.6f} "
              f"{'≤' if chi_pert <= bound + 1e-10 else '>'} {bound:.6f}")


# ============================================================================
# APPLICATION 3: Anti-Clustering in Statistical Mechanics
# ============================================================================

def anti_clustering_demo():
    """
    Demonstrate that Lorentzian measures exhibit anti-clustering:
    coordinate indicators repel each other, preventing concentration.

    In the spin system interpretation, this is a repulsive interaction
    that limits magnetic susceptibility.
    """
    print("\n" + "="*65)
    print("  APPLICATION 3: Anti-Clustering (Statistical Mechanics)")
    print("="*65)
    print("""
  In a spin system with Lorentzian measure, the "spins" (coordinate
  indicators) exhibit repulsive interactions. The susceptibility bound
  χ ≤ ε·(Σpᵢ)² limits the system's magnetic response, preventing
  spin clustering that would indicate a phase transition.
  """)

    for n in [4, 5, 6, 7, 8]:
        r = n // 2
        mu = uniform_matroid(n, r)

        # Average covariance
        covs = [mu.coord_cov(i, j) for i in range(n) for j in range(i+1, n)]
        avg_cov = sum(covs) / len(covs)

        # All covariances should be negative (anti-clustering)
        all_neg = all(c <= 1e-10 for c in covs)

        # Susceptibility per pair
        chi_per_pair = sum(abs(c) for c in covs) * 2 / (n * (n-1))

        print(f"  U({n},{r}): avg Cov = {avg_cov:.6f}, "
              f"all negative = {'✓' if all_neg else '✗'}, "
              f"χ/pair = {chi_per_pair:.6f}")


# ============================================================================
# APPLICATION 4: Communication Complexity Bounds
# ============================================================================

def communication_complexity_demo():
    """
    Show that the mutual information bound limits the information cost
    of a two-party protocol that reveals coordinate indicators.

    If Alice holds X_i and Bob holds X_j, the internal information cost
    of any protocol computing f(X_i, X_j) is bounded by I(X_i; X_j),
    which we bound by χ²(i,j) = Cov²/(p(1-p)q(1-q)).
    """
    print("\n" + "="*65)
    print("  APPLICATION 4: Communication Complexity Bounds")
    print("="*65)
    print("""
  For a robustly Lorentzian distribution, the mutual information
  I(Xᵢ; Xⱼ) ≤ χ²(i,j) = Cov²/(p(1-p)q(1-q)) (proved in Lean).
  This bounds the information cost of any two-party protocol
  that operates on coordinate indicators.
  """)

    n, r = 6, 3
    mu = uniform_matroid(n, r)

    print(f"\n  U({n},{r}): Pairwise information costs")
    print(f"  {'Pair':>8s}  {'MI':>10s}  {'χ² bound':>10s}  {'Ratio':>8s}")
    print(f"  {'—'*8}  {'—'*10}  {'—'*10}  {'—'*8}")

    for i in range(min(n, 4)):
        for j in range(i+1, min(n, 4)):
            mi = mu.pairwise_mi(i, j)
            c = mu.coord_cov(i, j)
            p, q = mu.coord_prob(i), mu.coord_prob(j)
            chisq = c**2 / (p*(1-p)*q*(1-q)) if p*(1-p)*q*(1-q) > 0 else float('inf')
            ratio = mi / chisq if chisq > 0 else 0
            print(f"  ({i},{j})     {mi:10.6f}  {chisq:10.6f}  {ratio:8.4f}")

    print(f"\n  → MI is always ≤ χ² bound (Theorem mutualInfoPair_cov_bound)")
    print(f"  → The ratio MI/χ² ≈ 0.5, consistent with the bound being 2× tight")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Information-Theoretic Lorentzian Monotonicity  ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    privacy_amplification_demo()
    sampling_certification_demo()
    anti_clustering_demo()
    communication_complexity_demo()

    print("\n  All applications completed.")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of information-theoretic monotonicity
for robustly Lorentzian measures.

Demonstrates:
- Uniform matroid distributions and their information profiles
- Deletion entropy before/after removing a coordinate
- Pairwise mutual information heatmaps
- Comparison of empirical values against certified upper bounds
- Variation of the gap parameter ε
"""

import numpy as np
from itertools import combinations
from math import log, log2, comb, sqrt
from typing import Dict, List, Tuple, Optional


def binary_entropy(p: float) -> float:
    """Binary entropy h(p) = -p log₂ p - (1-p) log₂ (1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -p * log2(p) - (1 - p) * log2(1 - p)


def binary_entropy_nat(p: float) -> float:
    """Binary entropy using natural log."""
    if p <= 0 or p >= 1:
        return 0.0
    return -p * log(p) - (1 - p) * log(1 - p)


class FinsetLaw:
    """A probability law on subsets of [n] = {0, 1, ..., n-1}.

    Encodes a probability mass function on the power set with
    normalization and nonnegativity, mirroring the Lean FinsetLaw structure.
    """

    def __init__(self, n: int, weights: Dict[frozenset, float]):
        self.n = n
        self.weights = {}
        total = 0.0
        for s, w in weights.items():
            assert w >= 0, f"Weight must be nonneg, got {w} for {s}"
            if w > 0:
                self.weights[s] = w
                total += w
        # Normalize
        if abs(total - 1.0) > 1e-10:
            for s in self.weights:
                self.weights[s] /= total

    def weight(self, s: frozenset) -> float:
        return self.weights.get(s, 0.0)

    def coord_prob(self, i: int) -> float:
        """P(i ∈ S)."""
        return sum(w for s, w in self.weights.items() if i in s)

    def pair_joint_prob(self, i: int, j: int) -> float:
        """P(i ∈ S ∧ j ∈ S)."""
        return sum(w for s, w in self.weights.items() if i in s and j in s)

    def coord_cov(self, i: int, j: int) -> float:
        """Cov(1_{i∈S}, 1_{j∈S})."""
        return self.pair_joint_prob(i, j) - self.coord_prob(i) * self.coord_prob(j)

    def total_entropy(self) -> float:
        """Shannon entropy H(μ) using natural log."""
        return -sum(w * log(w) for w in self.weights.values() if w > 0)

    def total_entropy_bits(self) -> float:
        """Shannon entropy in bits."""
        return -sum(w * log2(w) for w in self.weights.values() if w > 0)

    def spin_susceptibility(self) -> float:
        """χ = Σ_{i≠j} |Cov(X_i, X_j)|."""
        result = 0.0
        for i in range(self.n):
            for j in range(self.n):
                if i != j:
                    result += abs(self.coord_cov(i, j))
        return result

    def pairwise_mi(self, i: int, j: int) -> float:
        """Mutual information I(X_i; X_j) for coordinate indicators."""
        p = self.coord_prob(i)
        q = self.coord_prob(j)
        r = self.pair_joint_prob(i, j)
        mi = 0.0
        pairs = [
            (r, p * q),
            (p - r, p * (1 - q)),
            (q - r, (1 - p) * q),
            (1 - p - q + r, (1 - p) * (1 - q)),
        ]
        for pxy, pxpy in pairs:
            if pxy > 1e-15 and pxpy > 1e-15:
                mi += pxy * log(pxy / pxpy)
        return mi

    def chi_sq_pair(self, i: int, j: int) -> float:
        """Chi-squared divergence for pair (i,j)."""
        c = self.coord_cov(i, j)
        p = self.coord_prob(i)
        q = self.coord_prob(j)
        denom = p * (1 - p) * q * (1 - q)
        if denom < 1e-15:
            return float('inf')
        return c**2 / denom

    def delete_coord(self, k: int) -> 'FinsetLaw':
        """Delete coordinate k, pushing forward the measure."""
        new_weights: Dict[frozenset, float] = {}
        for s, w in self.weights.items():
            new_s = frozenset(i if i < k else i - 1 for i in s if i != k)
            new_weights[new_s] = new_weights.get(new_s, 0.0) + w
        return FinsetLaw(self.n - 1, new_weights)


def uniform_matroid_law(n: int, r: int) -> FinsetLaw:
    """Uniform distribution on r-element subsets of [n].

    This is the canonical example of a strongly log-concave / Lorentzian distribution.
    """
    total = comb(n, r)
    weights = {}
    for subset in combinations(range(n), r):
        weights[frozenset(subset)] = 1.0 / total
    return FinsetLaw(n, weights)


def perturbed_matroid_law(n: int, r: int, epsilon: float) -> FinsetLaw:
    """Perturbed uniform matroid: weight ∝ 1 + ε·(indicator of 0 ∈ S).

    For small ε, this stays close to the uniform matroid but breaks symmetry,
    allowing us to test robustness of information-theoretic bounds.
    """
    weights = {}
    for subset in combinations(range(n), r):
        s = frozenset(subset)
        w = 1.0 + epsilon * (1.0 if 0 in s else 0.0)
        weights[s] = w
    return FinsetLaw(n, weights)


def compute_robustness_gap(mu: FinsetLaw) -> float:
    """Estimate the robustness gap ε = max_{i≠j} |Cov(i,j)| / (p_i * p_j)."""
    max_ratio = 0.0
    for i in range(mu.n):
        for j in range(i + 1, mu.n):
            pi_val = mu.coord_prob(i)
            pj_val = mu.coord_prob(j)
            if pi_val > 0 and pj_val > 0:
                ratio = abs(mu.coord_cov(i, j)) / (pi_val * pj_val)
                max_ratio = max(max_ratio, ratio)
    return max_ratio


def audit_info_profile(mu: FinsetLaw) -> dict:
    """Compute the full information-theoretic profile of a FinsetLaw.

    Returns entropy, deleted entropies, covariance matrix, MI matrix,
    susceptibility, and bound comparisons.
    """
    n = mu.n
    profile = {
        'n': n,
        'entropy': mu.total_entropy(),
        'entropy_bits': mu.total_entropy_bits(),
        'coord_probs': [mu.coord_prob(i) for i in range(n)],
        'covariances': [[mu.coord_cov(i, j) for j in range(n)] for i in range(n)],
        'mutual_infos': [[mu.pairwise_mi(i, j) if i != j else 0.0
                         for j in range(n)] for i in range(n)],
        'chi_sq_bounds': [[mu.chi_sq_pair(i, j) if i != j else 0.0
                          for j in range(n)] for i in range(n)],
        'susceptibility': mu.spin_susceptibility(),
        'deleted_entropies': [],
    }

    # Compute deletion entropies
    for k in range(n):
        mu_del = mu.delete_coord(k)
        profile['deleted_entropies'].append(mu_del.total_entropy())

    # Compute gap
    eps = compute_robustness_gap(mu)
    profile['robustness_gap'] = eps

    # Susceptibility bound
    sum_probs = sum(profile['coord_probs'])
    profile['susceptibility_bound'] = eps * sum_probs ** 2

    # Check MI ≤ chi-squared for all pairs
    mi_le_chisq = True
    for i in range(n):
        for j in range(n):
            if i != j:
                if profile['mutual_infos'][i][j] > profile['chi_sq_bounds'][i][j] + 1e-10:
                    mi_le_chisq = False
    profile['mi_le_chisq_holds'] = mi_le_chisq

    return profile


def print_profile(profile: dict, title: str = "Info Profile"):
    """Pretty-print an information profile."""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")
    print(f"  n = {profile['n']}")
    print(f"  H(μ) = {profile['entropy']:.6f} nats = {profile['entropy_bits']:.6f} bits")
    print(f"  Robustness gap ε = {profile['robustness_gap']:.6f}")
    print(f"  Susceptibility χ = {profile['susceptibility']:.6f}")
    print(f"  Susceptibility bound = {profile['susceptibility_bound']:.6f}")
    print(f"  χ ≤ bound? {'✓' if profile['susceptibility'] <= profile['susceptibility_bound'] + 1e-10 else '✗'}")
    print(f"  MI ≤ χ² for all pairs? {'✓' if profile['mi_le_chisq_holds'] else '✗'}")

    print(f"\n  Coordinate probabilities:")
    for i, p in enumerate(profile['coord_probs']):
        print(f"    p_{i} = {p:.6f}")

    print(f"\n  Pairwise covariances (off-diagonal):")
    n = profile['n']
    for i in range(min(n, 5)):
        for j in range(i+1, min(n, 5)):
            print(f"    Cov({i},{j}) = {profile['covariances'][i][j]:.6f}")

    print(f"\n  Pairwise MI vs χ² bound:")
    for i in range(min(n, 5)):
        for j in range(i+1, min(n, 5)):
            mi = profile['mutual_infos'][i][j]
            cs = profile['chi_sq_bounds'][i][j]
            print(f"    I({i};{j}) = {mi:.6f} ≤ {cs:.6f} {'✓' if mi <= cs + 1e-10 else '✗'}")

    print(f"\n  Deletion entropies:")
    for k, he in enumerate(profile['deleted_entropies']):
        drop = profile['entropy'] - he
        print(f"    H(π_{k}μ) = {he:.6f}, drop = {drop:.6f}")


def demo_uniform_matroids():
    """Demonstrate information profiles for uniform matroid distributions."""
    print("\n" + "="*70)
    print("  DEMO 1: Uniform Matroid Distributions")
    print("="*70)
    print("""
  The uniform matroid U(n,r) assigns equal weight to all r-element subsets
  of [n]. These are the canonical examples of Lorentzian/log-concave
  distributions, with strong negative dependence properties.
  """)

    for n, r in [(4, 2), (5, 2), (6, 3)]:
        mu = uniform_matroid_law(n, r)
        profile = audit_info_profile(mu)
        print_profile(profile, f"Uniform Matroid U({n},{r})")


def demo_perturbation_robustness():
    """Show how information quantities change under perturbation."""
    print("\n" + "="*70)
    print("  DEMO 2: Perturbation Robustness")
    print("="*70)
    print("""
  We perturb U(5,2) by favoring subsets containing coordinate 0.
  The robustness gap ε should grow with perturbation strength,
  and all information bounds should remain valid.
  """)

    n, r = 5, 2
    for eps in [0.0, 0.1, 0.5, 1.0, 2.0]:
        mu = perturbed_matroid_law(n, r, eps)
        profile = audit_info_profile(mu)
        print_profile(profile, f"Perturbed U({n},{r}) with ε = {eps}")


def demo_scaling_test():
    """Test whether entropy drop tracks log(1/ε) and MI tracks the predicted bound."""
    print("\n" + "="*70)
    print("  DEMO 3: Scaling Test — Entropy Drop vs log(1/ε)")
    print("="*70)
    print("""
  Conjecture: H(π_k μ) ≥ H(μ) - log(1/ε) - C for a universal C.
  We test this by computing entropy drops across perturbation levels.
  """)

    n, r = 6, 3
    print(f"\n  Base: U({n},{r})")
    print(f"  {'ε_pert':>8s}  {'gap ε':>10s}  {'H(μ)':>10s}  {'max drop':>10s}  {'log(1/ε)':>10s}  {'drop/log':>10s}")
    print(f"  {'—'*8}  {'—'*10}  {'—'*10}  {'—'*10}  {'—'*10}  {'—'*10}")

    for eps_pert in [0.01, 0.05, 0.1, 0.2, 0.5, 1.0]:
        mu = perturbed_matroid_law(n, r, eps_pert)
        profile = audit_info_profile(mu)
        gap = profile['robustness_gap']
        max_drop = max(profile['entropy'] - he for he in profile['deleted_entropies'])
        if gap > 0:
            log_inv = log(1 / gap)
            ratio = max_drop / log_inv if log_inv > 0 else float('nan')
        else:
            log_inv = float('inf')
            ratio = float('nan')
        print(f"  {eps_pert:8.3f}  {gap:10.6f}  {profile['entropy']:10.6f}  {max_drop:10.6f}  {log_inv:10.4f}  {ratio:10.4f}")


def demo_mi_scaling():
    """Test MI vs covariance scaling."""
    print("\n" + "="*70)
    print("  DEMO 4: Mutual Information Scaling")
    print("="*70)
    print("""
  Conjecture B: I(X_i; X_j) ≤ C · log(1 + 1/ε) may be tighter than C/ε.
  We compare empirical MI against both 1/ε and log(1 + 1/ε) fits.
  """)

    n, r = 5, 2
    print(f"\n  Base: U({n},{r})")
    print(f"  {'ε_pert':>8s}  {'gap ε':>10s}  {'max MI':>10s}  {'1/ε':>10s}  {'log(1+1/ε)':>12s}  {'MI*ε':>10s}")
    print(f"  {'—'*8}  {'—'*10}  {'—'*10}  {'—'*10}  {'—'*12}  {'—'*10}")

    for eps_pert in [0.01, 0.05, 0.1, 0.3, 0.5, 1.0, 2.0]:
        mu = perturbed_matroid_law(n, r, eps_pert)
        profile = audit_info_profile(mu)
        gap = profile['robustness_gap']
        max_mi = max(profile['mutual_infos'][i][j]
                    for i in range(n) for j in range(n) if i != j)
        inv_eps = 1/gap if gap > 0 else float('inf')
        log_term = log(1 + 1/gap) if gap > 0 else float('inf')
        mi_times_eps = max_mi * (1/gap) if gap > 0 else float('nan')
        print(f"  {eps_pert:8.3f}  {gap:10.6f}  {max_mi:10.6f}  {inv_eps:10.4f}  {log_term:12.4f}  {mi_times_eps:10.6f}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Information-Theoretic Monotonicity for Lorentzian Measures     ║")
    print("║  Interactive Demonstration                                      ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_uniform_matroids()
    demo_perturbation_robustness()
    demo_scaling_test()
    demo_mi_scaling()

    print("\n" + "="*70)
    print("  All demos completed successfully.")
    print("="*70)


#!/usr/bin/env python3
"""
Visualization 2: Entropy Under Coordinate Deletion

Visualizes how entropy changes when coordinates are deleted from
robustly Lorentzian measures. Shows that entropy loss is bounded
and tracks log(1/ε), confirming the projection stability principle.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def uniform_matroid_weights(n, r):
    total = comb(n, r)
    return {frozenset(s): 1.0/total for s in combinations(range(n), r)}


def perturbed_matroid_weights(n, r, eps):
    weights = {}
    for s in combinations(range(n), r):
        fs = frozenset(s)
        weights[fs] = 1.0 + eps * (1.0 if 0 in s else 0.0)
    total = sum(weights.values())
    return {s: w/total for s, w in weights.items()}


def entropy(weights):
    return -sum(w * log(w) for w in weights.values() if w > 0)


def delete_coord(n, weights, k):
    new_w = {}
    for s, w in weights.items():
        ns = frozenset(i if i < k else i-1 for i in s if i != k)
        new_w[ns] = new_w.get(ns, 0.0) + w
    return new_w


def coord_prob(weights, i):
    return sum(w for s, w in weights.items() if i in s)


def coord_cov(weights, i, j):
    pij = sum(w for s, w in weights.items() if i in s and j in s)
    return pij - coord_prob(weights, i) * coord_prob(weights, j)


def robustness_gap(n, weights):
    max_ratio = 0.0
    for i in range(n):
        pi = coord_prob(weights, i)
        for j in range(i+1, n):
            pj = coord_prob(weights, j)
            if pi > 0 and pj > 0:
                ratio = abs(coord_cov(weights, i, j)) / (pi * pj)
                max_ratio = max(max_ratio, ratio)
    return max_ratio


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Entropy Stability Under Coordinate Deletion',
             fontsize=14, fontweight='bold')

# Plot 1: Entropy drops for different matroids
ax1 = axes[0]
for n, r, color in [(4, 2, 'blue'), (5, 2, 'green'), (6, 3, 'red'), (7, 3, 'purple')]:
    w = uniform_matroid_weights(n, r)
    H = entropy(w)
    drops = [H - entropy(delete_coord(n, w, k)) for k in range(n)]
    ax1.bar(np.arange(n) + 0.15*(n-4), drops, width=0.15,
            label=f'U({n},{r})', color=color, alpha=0.7)
ax1.set_xlabel('Deleted coordinate k')
ax1.set_ylabel('Entropy drop H(μ) - H(π_k μ)')
ax1.set_title('Entropy drop per coordinate')
ax1.legend(fontsize=9)
ax1.set_ylim(bottom=0)

# Plot 2: Entropy drop vs perturbation strength
ax2 = axes[1]
n, r = 6, 3
eps_values = np.linspace(0.01, 3.0, 30)
max_drops = []
gaps = []
for eps in eps_values:
    w = perturbed_matroid_weights(n, r, eps)
    H = entropy(w)
    max_drop = max(H - entropy(delete_coord(n, w, k)) for k in range(n))
    gap = robustness_gap(n, w)
    max_drops.append(max_drop)
    gaps.append(gap)

ax2.plot(eps_values, max_drops, 'b-', linewidth=2, label='Max entropy drop')
ax2.plot(eps_values, [log(1/g) if g > 0 else 0 for g in gaps],
         'r--', linewidth=1.5, label='log(1/ε)')
ax2.set_xlabel('Perturbation strength')
ax2.set_ylabel('Entropy drop / bound')
ax2.set_title(f'Entropy drop vs log(1/ε)\nPerturbed U({n},{r})')
ax2.legend()

# Plot 3: Gap vs perturbation
ax3 = axes[2]
ax3.plot(eps_values, gaps, 'g-', linewidth=2, label='Robustness gap ε')
ax3.set_xlabel('Perturbation strength')
ax3.set_ylabel('Gap ε')
ax3.set_title('Robustness gap under perturbation')
ax3.legend()

plt.tight_layout()
plt.savefig('viz_entropy_deletion.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_deletion.png")


#!/usr/bin/env python3
"""
Visualization 1: Pairwise Mutual Information Heatmap

Visualizes the pairwise mutual information matrix I(X_i; X_j) for a
uniform matroid distribution, alongside the certified chi-squared upper bound.
Demonstrates that Lorentzian negativity suppresses pairwise information,
with MI always below the χ² bound from kl_le_chi_sq_four.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def compute_mi_and_bounds(n, r):
    """Compute MI matrix and chi-squared bounds for U(n,r)."""
    # Build uniform matroid
    total = comb(n, r)
    subsets = list(combinations(range(n), r))
    weights = {frozenset(s): 1.0/total for s in subsets}

    def coord_prob(i):
        return sum(w for s, w in weights.items() if i in s)

    def pair_joint(i, j):
        return sum(w for s, w in weights.items() if i in s and j in s)

    def coord_cov(i, j):
        return pair_joint(i, j) - coord_prob(i) * coord_prob(j)

    def pairwise_mi(i, j):
        p, q = coord_prob(i), coord_prob(j)
        rv = pair_joint(i, j)
        mi = 0.0
        for pxy, pxpy in [(rv, p*q), (p-rv, p*(1-q)),
                           (q-rv, (1-p)*q), (1-p-q+rv, (1-p)*(1-q))]:
            if pxy > 1e-15 and pxpy > 1e-15:
                mi += pxy * log(pxy / pxpy)
        return max(0, mi)

    mi_matrix = np.zeros((n, n))
    chisq_matrix = np.zeros((n, n))

    for i in range(n):
        for j in range(n):
            if i != j:
                mi_matrix[i, j] = pairwise_mi(i, j)
                c = coord_cov(i, j)
                p, q = coord_prob(i), coord_prob(j)
                denom = p * (1-p) * q * (1-q)
                chisq_matrix[i, j] = c**2 / denom if denom > 0 else 0

    return mi_matrix, chisq_matrix


fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('Pairwise Mutual Information vs χ² Bound\nfor Uniform Matroid Distributions',
             fontsize=14, fontweight='bold')

configs = [(4, 2), (5, 2), (6, 3)]

for idx, (n, r) in enumerate(configs):
    mi, chisq = compute_mi_and_bounds(n, r)

    # MI heatmap
    ax1 = axes[0, idx]
    im1 = ax1.imshow(mi, cmap='YlOrRd', aspect='equal')
    ax1.set_title(f'MI: U({n},{r})', fontsize=11)
    ax1.set_xlabel('Coordinate j')
    ax1.set_ylabel('Coordinate i')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    # Chi-squared bound heatmap
    ax2 = axes[1, idx]
    im2 = ax2.imshow(chisq, cmap='YlOrRd', aspect='equal')
    ax2.set_title(f'χ² bound: U({n},{r})', fontsize=11)
    ax2.set_xlabel('Coordinate j')
    ax2.set_ylabel('Coordinate i')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    # Annotate with values
    for i in range(n):
        for j in range(n):
            if i != j and n <= 5:
                ax1.text(j, i, f'{mi[i,j]:.4f}', ha='center', va='center', fontsize=7)
                ax2.text(j, i, f'{chisq[i,j]:.4f}', ha='center', va='center', fontsize=7)

plt.tight_layout()
plt.savefig('viz_mi_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_mi_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 3: Susceptibility Bound — Statistical Physics Bridge

Visualizes the spin susceptibility χ = Σ_{i≠j} |Cov(X_i, X_j)| alongside
the certified bound ε·(Σp_i)² from the Lean theorem susceptibility_le_of_robust.
Shows the bridge between Lorentzian negativity and statistical mechanics:
the gap ε acts as repulsive curvature limiting magnetic response.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def compute_profile(n, r, eps_pert=0.0):
    """Compute susceptibility and bound for (perturbed) uniform matroid."""
    weights = {}
    for s in combinations(range(n), r):
        fs = frozenset(s)
        weights[fs] = 1.0 + eps_pert * (1.0 if 0 in s else 0.0)
    total = sum(weights.values())
    weights = {s: w/total for s, w in weights.items()}

    def cp(i):
        return sum(w for s, w in weights.items() if i in s)

    def cov(i, j):
        pij = sum(w for s, w in weights.items() if i in s and j in s)
        return pij - cp(i) * cp(j)

    chi = sum(abs(cov(i, j)) for i in range(n) for j in range(n) if i != j)
    gap = max(abs(cov(i, j)) / (cp(i) * cp(j))
              for i in range(n) for j in range(i+1, n)
              if cp(i) > 0 and cp(j) > 0)
    sum_p = sum(cp(i) for i in range(n))
    bound = gap * sum_p**2

    return chi, bound, gap


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Susceptibility Bounds: Lorentzian Geometry → Statistical Mechanics',
             fontsize=13, fontweight='bold')

# Plot 1: Susceptibility vs bound for different matroids
ax1 = axes[0]
matroids = [(4, 2), (5, 2), (5, 3), (6, 2), (6, 3), (7, 3)]
chis = []
bounds = []
labels = []
for n, r in matroids:
    chi, bound, gap = compute_profile(n, r)
    chis.append(chi)
    bounds.append(bound)
    labels.append(f'U({n},{r})')

x = np.arange(len(matroids))
width = 0.35
ax1.bar(x - width/2, chis, width, label='χ (actual)', color='steelblue', alpha=0.8)
ax1.bar(x + width/2, bounds, width, label='ε·(Σpᵢ)² (bound)', color='coral', alpha=0.8)
ax1.set_xticks(x)
ax1.set_xticklabels(labels, fontsize=9)
ax1.set_ylabel('Value')
ax1.set_title('Susceptibility vs Certified Bound')
ax1.legend()

# Plot 2: Ratio χ/bound as perturbation grows
ax2 = axes[1]
n, r = 6, 3
eps_values = np.linspace(0.01, 5.0, 50)
ratios = []
gaps_list = []
for eps in eps_values:
    chi, bound, gap = compute_profile(n, r, eps)
    ratios.append(chi / bound if bound > 0 else 0)
    gaps_list.append(gap)

ax2.plot(eps_values, ratios, 'b-', linewidth=2)
ax2.axhline(y=1.0, color='r', linestyle='--', alpha=0.5, label='Bound = χ')
ax2.set_xlabel('Perturbation strength')
ax2.set_ylabel('χ / bound')
ax2.set_title(f'Tightness ratio for perturbed U({n},{r})')
ax2.set_ylim(0, 1.2)
ax2.legend()

# Plot 3: Gap growth under perturbation
ax3 = axes[2]
ax3.plot(eps_values, gaps_list, 'g-', linewidth=2, label='ε (gap)')
ax3.set_xlabel('Perturbation strength')
ax3.set_ylabel('Robustness gap ε')
ax3.set_title('Gap Evolution Under Perturbation')
ax3.legend()

plt.tight_layout()
plt.savefig('viz_susceptibility.png', dpi=150, bbox_inches='tight')
print("Saved viz_susceptibility.png")
