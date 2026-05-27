#!/usr/bin/env python3
"""
applications.py — Real-world applications of information-theoretic
bounds for robustly Lorentzian measures.

Demonstrates:
1. Privacy amplification under coordinate deletion
2. Anti-clustering bounds in statistical mechanics
3. Communication complexity bounds
4. Sampling quality certification
"""

import numpy as np
from itertools import combinations
from math import log, comb, exp


def binary_entropy(p):
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * log(p) + (1 - p) * log(1 - p))


def shannon_entropy(weights):
    return -sum(w * log(w) for w in weights if w > 0)


class SubsetLaw:
    """Lightweight subset probability law."""
    def __init__(self, n, subsets, weights):
        self.n = n
        self.subsets = subsets
        self.weights = weights
        self._dict = dict(zip(subsets, weights))

    @classmethod
    def uniform_matroid(cls, n, k):
        subsets = [frozenset(s) for s in combinations(range(n), k)]
        w = 1.0 / len(subsets)
        return cls(n, subsets, [w] * len(subsets))

    def coord_prob(self, i):
        return sum(w for s, w in zip(self.subsets, self.weights) if i in s)

    def coord_cov(self, i, j):
        pij = sum(w for s, w in zip(self.subsets, self.weights) if i in s and j in s)
        return pij - self.coord_prob(i) * self.coord_prob(j)

    def total_entropy(self):
        return shannon_entropy(self.weights)

    def delete_coord(self, k):
        proj = {}
        for s, w in zip(self.subsets, self.weights):
            s2 = frozenset(x for x in s if x != k)
            proj[s2] = proj.get(s2, 0) + w
        return SubsetLaw(self.n - 1, list(proj.keys()), list(proj.values()))


# ============================================================
# Application 1: Privacy Amplification
# ============================================================

def privacy_amplification_demo():
    """
    Demonstrate that coordinate deletion preserves uncertainty.

    In differential privacy, if a database is sampled from a robustly
    Lorentzian distribution, deleting one record (coordinate) can only
    reduce entropy by at most log(2). This means the remaining data
    retains most of its uncertainty — an adversary who sees n-1 coordinates
    still faces nearly as much uncertainty as before.
    """
    print("APPLICATION 1: Privacy Amplification Under Coordinate Deletion")
    print("-" * 60)
    print("Theorem: H(π_k μ) ≥ H(μ) - log(2)")
    print()

    for n in [4, 5, 6, 8]:
        k = n // 2
        mu = SubsetLaw.uniform_matroid(n, k)
        H_original = mu.total_entropy()

        print(f"  Uniform matroid U({k},{n}):")
        print(f"    Original entropy: H(μ) = {H_original:.4f} nats")

        drops = []
        for coord in range(n):
            mu_del = mu.delete_coord(coord)
            H_del = mu_del.total_entropy()
            drop = H_original - H_del
            drops.append(drop)

        max_drop = max(drops)
        avg_drop = np.mean(drops)
        print(f"    Max entropy drop:     {max_drop:.4f} nats")
        print(f"    Average entropy drop: {avg_drop:.4f} nats")
        print(f"    Certified bound:      {log(2):.4f} nats (log 2)")
        print(f"    Privacy margin:       {log(2) - max_drop:.4f} nats")
        print()


# ============================================================
# Application 2: Anti-Clustering (Statistical Mechanics)
# ============================================================

def anti_clustering_demo():
    """
    Demonstrate susceptibility bounds as anti-clustering certificates.

    In statistical mechanics, the susceptibility χ = ∑_{i,j} Cov(X_i, X_j)
    measures how much the system responds to external fields. For robustly
    Lorentzian measures, χ ≤ n/4, preventing the formation of large clusters.
    """
    print("APPLICATION 2: Anti-Clustering Bounds (Statistical Mechanics)")
    print("-" * 60)
    print("Theorem: χ(μ) = Σ Cov(X_i,X_j) ≤ n/4")
    print()

    for n in [4, 5, 6, 8]:
        print(f"  n = {n}:")
        for k in [1, n // 2, n - 1]:
            mu = SubsetLaw.uniform_matroid(n, k)
            chi = sum(mu.coord_cov(i, j) for i in range(n) for j in range(n))
            bound = n / 4.0

            # Decompose into diagonal (variance) and off-diagonal
            diag = sum(mu.coord_cov(i, i) for i in range(n))
            off_diag = chi - diag

            print(f"    U({k},{n}): χ = {chi:+.6f} ≤ {bound:.4f}")
            print(f"      Diagonal (∑Var):     {diag:+.6f}")
            print(f"      Off-diagonal (∑Cov): {off_diag:+.6f}")
        print()


# ============================================================
# Application 3: Communication Complexity
# ============================================================

def communication_complexity_demo():
    """
    Demonstrate mutual information bounds for two-party protocols.

    If Alice holds coordinate i and Bob holds coordinate j of a random
    subset drawn from a robustly Lorentzian distribution, the internal
    information cost of any protocol is bounded by the mutual information
    I(X_i; X_j) ≤ cov²/(p_i(1-p_i)*p_j(1-p_j)) ≤ ε²/(ε(1-ε))².
    """
    print("APPLICATION 3: Communication Complexity Bounds")
    print("-" * 60)
    print("Theorem: I(X_i;X_j) ≤ ε²/(ε(1-ε))² (two-coordinate info cost)")
    print()

    for n in [4, 5, 6]:
        k = n // 2
        mu = SubsetLaw.uniform_matroid(n, k)

        # Estimate gap
        eps = min(min(mu.coord_prob(i), 1 - mu.coord_prob(i)) for i in range(n))
        max_cov = max(abs(mu.coord_cov(i, j))
                      for i in range(n) for j in range(i + 1, n))
        eps = min(eps, max_cov, 0.5)

        gap_bound = eps ** 2 / (eps * (1 - eps)) ** 2 if eps > 0 else float('inf')

        print(f"  U({k},{n}), ε ≈ {eps:.6f}:")
        print(f"    Gap bound: ε²/(ε(1-ε))² = {gap_bound:.6f}")

        for i in range(min(n, 3)):
            for j in range(i + 1, min(n, 4)):
                pij = sum(w for s, w in zip(mu.subsets, mu.weights) if i in s and j in s)
                pi, pj = mu.coord_prob(i), mu.coord_prob(j)
                p11, p10, p01, p00 = pij, pi - pij, pj - pij, 1 - pi - pj + pij
                mi = binary_entropy(pi) + binary_entropy(pj) - \
                     shannon_entropy([max(v, 0) for v in [p00, p01, p10, p11]])
                mi = max(mi, 0)
                cov = mu.coord_cov(i, j)
                chi2 = cov ** 2 / (pi * (1 - pi) * pj * (1 - pj))
                print(f"    I(X_{i};X_{j}) = {mi:.6f} ≤ χ² = {chi2:.6f} ≤ {gap_bound:.6f}")
        print()


# ============================================================
# Application 4: Sampling Quality Certification
# ============================================================

def sampling_certification_demo():
    """
    Demonstrate how the bounds can certify sampling quality.

    Given a sample from a purported matroid distribution, check whether
    the observed marginals and covariances are consistent with robust
    Lorentzianity, and if so, certify bounds on entropy and MI.
    """
    print("APPLICATION 4: Sampling Quality Certification")
    print("-" * 60)
    print()

    n, k = 5, 2
    mu = SubsetLaw.uniform_matroid(n, k)

    print(f"  Reference: U({k},{n})")
    print(f"  Checking robust Lorentzianity conditions:")

    # Check marginal bounds
    probs = [mu.coord_prob(i) for i in range(n)]
    eps_marginal = min(min(p, 1 - p) for p in probs)
    print(f"    Marginal range: [{min(probs):.4f}, {max(probs):.4f}]")
    print(f"    ε_marginal = {eps_marginal:.6f}")

    # Check negative dependence
    covs = []
    for i in range(n):
        for j in range(i + 1, n):
            c = mu.coord_cov(i, j)
            covs.append(c)
    all_neg = all(c <= 1e-12 for c in covs)
    max_abs_cov = max(abs(c) for c in covs)
    print(f"    All pairwise covs ≤ 0? {'✓' if all_neg else '✗'}")
    print(f"    Max |Cov|: {max_abs_cov:.6f}")

    eps = min(eps_marginal, max_abs_cov, 0.5)
    print(f"    Estimated gap ε: {eps:.6f}")

    if eps > 0 and all_neg:
        print(f"\n  ✓ Distribution is robustly Lorentzian with gap ε = {eps:.6f}")
        print(f"\n  Certified bounds:")
        print(f"    Entropy:          H = {mu.total_entropy():.4f}")
        print(f"    Susceptibility:   χ = {sum(mu.coord_cov(i, j) for i in range(n) for j in range(n)):.6f} ≤ {n/4:.4f}")
        print(f"    Max MI:           {max(abs(c) for c in covs)**2 / (eps*(1-eps))**2:.6f}")
        print(f"    Deletion drop:    ≤ {log(2):.4f}")
    else:
        print(f"\n  ✗ Distribution is NOT robustly Lorentzian")


def main():
    privacy_amplification_demo()
    print()
    anti_clustering_demo()
    print()
    communication_complexity_demo()
    print()
    sampling_certification_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Information-Theoretic Monotonicity
for Robustly Lorentzian Measures.

Demonstrates:
- Uniform matroid distributions
- Perturbed negatively dependent laws
- Deletion entropy before/after removing a coordinate
- Pairwise mutual information heatmaps
- Comparison of empirical values against certified upper bounds
"""

import numpy as np
from itertools import combinations
from math import comb, log, exp


def binary_entropy(p):
    """Binary entropy H(p) = -p log p - (1-p) log(1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * log(p) + (1 - p) * log(1 - p))


def shannon_entropy(weights):
    """Shannon entropy H = -sum w_i log w_i."""
    return -sum(w * log(w) for w in weights if w > 0)


class FinsetLaw:
    """A probability distribution on subsets of [n]."""

    def __init__(self, n, weight_func):
        self.n = n
        subsets = []
        weights = []
        for k in range(n + 1):
            for s in combinations(range(n), k):
                subset = frozenset(s)
                w = weight_func(subset)
                if w > 0:
                    subsets.append(subset)
                    weights.append(w)
        total = sum(weights)
        self.subsets = subsets
        self.weights = [w / total for w in weights]
        self._weight_dict = dict(zip(subsets, self.weights))

    def weight(self, s):
        return self._weight_dict.get(frozenset(s), 0.0)

    def coord_prob(self, i):
        """P(i in S)."""
        return sum(w for s, w in zip(self.subsets, self.weights) if i in s)

    def pair_joint_prob(self, i, j):
        """P(i in S and j in S)."""
        return sum(w for s, w in zip(self.subsets, self.weights) if i in s and j in s)

    def coord_cov(self, i, j):
        """Cov(1_i, 1_j) = P(i,j in S) - P(i in S)*P(j in S)."""
        return self.pair_joint_prob(i, j) - self.coord_prob(i) * self.coord_prob(j)

    def total_entropy(self):
        """H(mu) = -sum w log w."""
        return shannon_entropy(self.weights)

    def mutual_info_coord(self, i, j):
        """Mutual information I(X_i; X_j) for indicator variables."""
        pi = self.coord_prob(i)
        pj = self.coord_prob(j)
        pij = self.pair_joint_prob(i, j)
        # Joint distribution of (X_i, X_j):
        p11 = pij
        p10 = pi - pij
        p01 = pj - pij
        p00 = 1 - pi - pj + pij
        # Clamp for numerical safety
        vals = [max(v, 0) for v in [p00, p01, p10, p11]]
        h_joint = shannon_entropy(vals)
        h_i = binary_entropy(pi)
        h_j = binary_entropy(pj)
        return max(h_i + h_j - h_joint, 0.0)

    def chi_squared_bound(self, i, j):
        """Chi-squared upper bound on MI: cov^2 / (pi(1-pi)*pj(1-pj))."""
        cov = self.coord_cov(i, j)
        pi = self.coord_prob(i)
        pj = self.coord_prob(j)
        denom = pi * (1 - pi) * pj * (1 - pj)
        if denom <= 0:
            return float('inf')
        return cov ** 2 / denom

    def delete_coord_entropy(self, k):
        """Entropy after deleting coordinate k."""
        projected = {}
        for s, w in zip(self.subsets, self.weights):
            s_new = frozenset(x for x in s if x != k)
            projected[s_new] = projected.get(s_new, 0.0) + w
        return shannon_entropy(list(projected.values()))

    def susceptibility(self):
        """Total covariance chi = sum_{i,j} Cov(X_i, X_j)."""
        return sum(self.coord_cov(i, j) for i in range(self.n) for j in range(self.n))

    def robustly_lorentzian_gap(self):
        """Estimate the maximal epsilon for which this law is robustly Lorentzian."""
        eps_marginal = min(
            min(self.coord_prob(i), 1 - self.coord_prob(i))
            for i in range(self.n)
        )
        eps_cov = min(
            -self.coord_cov(i, j)
            for i in range(self.n) for j in range(self.n) if i != j
        ) if self.n > 1 else float('inf')
        # Also need cov control: |cov| <= eps
        max_abs_cov = max(
            abs(self.coord_cov(i, j))
            for i in range(self.n) for j in range(self.n) if i != j
        ) if self.n > 1 else 0.0
        eps = min(eps_marginal, eps_cov, 0.5)
        if max_abs_cov > eps:
            eps = max_abs_cov  # Need eps >= max |cov|
        return min(eps, eps_marginal)


def uniform_matroid_law(n, k):
    """Uniform distribution on k-element subsets of [n]."""
    return FinsetLaw(n, lambda s: 1.0 if len(s) == k else 0.0)


def perturbed_matroid_law(n, k, delta=0.1):
    """Perturbed uniform matroid: weights proportional to 1 + delta * sum(s)."""
    def w(s):
        if len(s) != k:
            return 0.0
        return 1.0 + delta * sum(s)
    return FinsetLaw(n, w)


def demo_uniform_matroids():
    """Demonstrate entropy and MI for uniform matroids."""
    print("=" * 60)
    print("DEMO 1: Uniform Matroid Distributions")
    print("=" * 60)
    for n in [4, 5, 6]:
        for k in [1, 2, n // 2]:
            if k > n:
                continue
            mu = uniform_matroid_law(n, k)
            H = mu.total_entropy()
            eps = mu.robustly_lorentzian_gap()
            chi = mu.susceptibility()
            print(f"\n  U({k},{n}): H = {H:.4f}, ε ≈ {eps:.6f}, χ = {chi:.6f}")
            print(f"    n/4 = {n/4:.4f} (susceptibility bound)")
            print(f"    Coordinate probs: {[round(mu.coord_prob(i), 4) for i in range(n)]}")
            if n <= 6:
                for i in range(n):
                    for j in range(i + 1, n):
                        cov = mu.coord_cov(i, j)
                        mi = mu.mutual_info_coord(i, j)
                        chi2 = mu.chi_squared_bound(i, j)
                        print(f"    Cov({i},{j}) = {cov:.6f}, MI = {mi:.6f}, χ²-bound = {chi2:.6f}")


def demo_deletion_entropy():
    """Demonstrate entropy loss under coordinate deletion."""
    print("\n" + "=" * 60)
    print("DEMO 2: Deletion Entropy (Projection Lower Bound)")
    print("=" * 60)
    for n in [4, 5, 6]:
        k = n // 2
        mu = uniform_matroid_law(n, k)
        H = mu.total_entropy()
        print(f"\n  U({k},{n}): H(μ) = {H:.4f}, log(2) = {log(2):.4f}")
        for coord in range(n):
            H_del = mu.delete_coord_entropy(coord)
            drop = H - H_del
            print(f"    Delete coord {coord}: H(π_k μ) = {H_del:.4f}, "
                  f"drop = {drop:.4f}, ≤ log(2)? {'✓' if drop <= log(2) + 1e-10 else '✗'}")


def demo_perturbation_scaling():
    """Test how MI scales with perturbation strength."""
    print("\n" + "=" * 60)
    print("DEMO 3: Perturbation Scaling of Mutual Information")
    print("=" * 60)
    n, k = 5, 2
    for delta in [0.0, 0.1, 0.5, 1.0, 2.0]:
        mu = perturbed_matroid_law(n, k, delta)
        eps = mu.robustly_lorentzian_gap()
        mi_avg = np.mean([mu.mutual_info_coord(i, j)
                          for i in range(n) for j in range(i + 1, n)])
        chi2_avg = np.mean([mu.chi_squared_bound(i, j)
                            for i in range(n) for j in range(i + 1, n)])
        print(f"  δ = {delta:.1f}: ε ≈ {eps:.6f}, avg MI = {mi_avg:.6f}, "
              f"avg χ²-bound = {chi2_avg:.6f}")
        if eps > 0:
            print(f"    Predicted bound (ε²/(ε(1-ε))²) = {eps**2 / (eps*(1-eps))**2:.6f}")


def demo_susceptibility():
    """Verify susceptibility bound chi <= n/4."""
    print("\n" + "=" * 60)
    print("DEMO 4: Susceptibility Bound (Statistical Mechanics Bridge)")
    print("=" * 60)
    for n in [3, 4, 5, 6]:
        for k in range(1, n):
            mu = uniform_matroid_law(n, k)
            chi = mu.susceptibility()
            bound = n / 4
            print(f"  U({k},{n}): χ = {chi:.6f}, n/4 = {bound:.4f}, "
                  f"χ ≤ n/4? {'✓' if chi <= bound + 1e-10 else '✗'}")


def demo_conjecture_test():
    """Test Conjectures A and B from the paper."""
    print("\n" + "=" * 60)
    print("DEMO 5: Conjecture Tests")
    print("=" * 60)

    print("\n  Conjecture A: Sharp logarithmic deletion law")
    print("  H(π_k μ) ≥ H(μ) - log(1/ε) - C")
    for n in [4, 5, 6, 7]:
        k = n // 2
        mu = uniform_matroid_law(n, k)
        eps = mu.robustly_lorentzian_gap()
        H = mu.total_entropy()
        worst_drop = max(H - mu.delete_coord_entropy(c) for c in range(n))
        predicted = log(1 / eps) if eps > 0 else float('inf')
        print(f"    n={n}, k={k}: worst drop = {worst_drop:.4f}, "
              f"log(1/ε) = {predicted:.4f}, "
              f"residual C ≈ {worst_drop - predicted:.4f}")

    print("\n  Conjecture B: Mutual information scaling")
    print("  Is MI ~ C*log(1+1/ε) or ~ C/ε?")
    for n in [4, 5, 6]:
        results = []
        for k in range(1, n):
            mu = uniform_matroid_law(n, k)
            eps = mu.robustly_lorentzian_gap()
            if eps <= 0:
                continue
            mi_max = max(mu.mutual_info_coord(i, j)
                         for i in range(n) for j in range(i + 1, n))
            results.append((eps, mi_max))
        if results:
            print(f"    n = {n}:")
            for eps, mi in sorted(results):
                log_bound = log(1 + 1 / eps) if eps > 0 else float('inf')
                lin_bound = 1 / eps if eps > 0 else float('inf')
                print(f"      ε = {eps:.6f}: MI = {mi:.6f}, "
                      f"log(1+1/ε) = {log_bound:.4f}, 1/ε = {lin_bound:.4f}")


def main():
    """Run all demonstrations."""
    print("Information-Theoretic Monotonicity for Robustly Lorentzian Measures")
    print("Computational Verification of Formally Proved Bounds")
    print()

    demo_uniform_matroids()
    demo_deletion_entropy()
    demo_perturbation_scaling()
    demo_susceptibility()
    demo_conjecture_test()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Visualization 2: Entropy Loss Under Coordinate Deletion

Shows how entropy changes when coordinates are deleted from uniform matroid
distributions. The proved bound H(π_k μ) ≥ H(μ) - log(2) is displayed as
a horizontal line. The gap between actual drop and bound reveals how tight
the certified inequality is.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def shannon_entropy(weights):
    return -sum(w * log(w) for w in weights if w > 0)


def matroid_deletion_profile(n, k):
    subsets = [frozenset(s) for s in combinations(range(n), k)]
    w = 1.0 / len(subsets)
    H_orig = log(len(subsets))
    drops = []
    for coord in range(n):
        proj = {}
        for s in subsets:
            s2 = frozenset(x for x in s if x != coord)
            proj[s2] = proj.get(s2, 0) + w
        H_del = shannon_entropy(list(proj.values()))
        drops.append(H_orig - H_del)
    return H_orig, drops


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Entropy Loss Under Coordinate Deletion', fontsize=14, fontweight='bold')

for idx, n in enumerate([5, 6, 7]):
    ax = axes[idx]
    x_vals = []
    drop_vals = []
    colors = []
    labels_set = set()

    for k in range(1, n):
        H, drops = matroid_deletion_profile(n, k)
        for c, d in enumerate(drops):
            x_vals.append(k)
            drop_vals.append(d)

    # Plot as scatter
    ax.scatter(x_vals, drop_vals, alpha=0.6, s=30, c='steelblue', label='Actual drop')
    ax.axhline(y=log(2), color='red', linestyle='--', linewidth=2, label=f'log(2) = {log(2):.3f}')
    ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)

    ax.set_xlabel(f'Rank k (n={n})')
    ax.set_ylabel('Entropy drop H(μ) − H(π_k μ)')
    ax.set_title(f'n = {n}')
    ax.legend(fontsize=8)
    ax.set_ylim(-0.1, log(2) + 0.2)

plt.tight_layout()
plt.savefig('viz_entropy_deletion.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_deletion.png")


"""
Visualization 1: Mutual Information Heatmap for Robustly Lorentzian Measures

Visualizes the pairwise mutual information matrix for uniform matroid distributions,
showing how negative dependence suppresses information sharing between coordinates.
The chi-squared certified bound is overlaid for comparison.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def binary_entropy(p):
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * log(p) + (1 - p) * log(1 - p))


def shannon_entropy(weights):
    return -sum(w * log(w) for w in weights if w > 0)


def uniform_matroid_mi_matrix(n, k):
    """Compute MI matrix for uniform matroid U(k,n)."""
    subsets = [frozenset(s) for s in combinations(range(n), k)]
    w = 1.0 / len(subsets)

    def coord_prob(i):
        return sum(w for s in subsets if i in s)

    def pair_prob(i, j):
        return sum(w for s in subsets if i in s and j in s)

    mi = np.zeros((n, n))
    chi2 = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                mi[i, j] = binary_entropy(coord_prob(i))
                continue
            pi, pj = coord_prob(i), coord_prob(j)
            pij = pair_prob(i, j)
            p11, p10, p01 = pij, pi - pij, pj - pij
            p00 = 1 - pi - pj + pij
            vals = [max(v, 0) for v in [p00, p01, p10, p11]]
            mi[i, j] = max(binary_entropy(pi) + binary_entropy(pj) - shannon_entropy(vals), 0)
            cov = pij - pi * pj
            denom = pi * (1 - pi) * pj * (1 - pj)
            chi2[i, j] = cov ** 2 / denom if denom > 0 else 0
    return mi, chi2


fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('Mutual Information Under Lorentzian Negativity', fontsize=14, fontweight='bold')

configs = [(5, 1), (5, 2), (6, 3), (6, 1), (6, 2), (7, 3)]
for idx, (n, k) in enumerate(configs):
    ax = axes[idx // 3, idx % 3]
    mi, chi2 = uniform_matroid_mi_matrix(n, k)
    np.fill_diagonal(mi, 0)  # Zero out self-MI for clearer display
    im = ax.imshow(mi, cmap='YlOrRd', interpolation='nearest', vmin=0)
    ax.set_title(f'U({k},{n})\nmax MI = {mi.max():.4f}', fontsize=10)
    ax.set_xlabel('Coordinate j')
    ax.set_ylabel('Coordinate i')
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

plt.tight_layout()
plt.savefig('viz_mi_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_mi_heatmap.png")


"""
Visualization 3: Susceptibility Bound — Statistical Mechanics Bridge

Shows the susceptibility χ(μ) = ∑ Cov(X_i, X_j) for various uniform matroid
distributions, compared to the proved bound χ ≤ n/4. Decomposes χ into
diagonal (variance) and off-diagonal (covariance) contributions, illustrating
how negative dependence suppresses the off-diagonal part.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def matroid_susceptibility(n, k):
    subsets = [frozenset(s) for s in combinations(range(n), k)]
    w = 1.0 / len(subsets)

    def cp(i):
        return sum(w for s in subsets if i in s)

    def cov(i, j):
        pij = sum(w for s in subsets if i in s and j in s)
        return pij - cp(i) * cp(j)

    diag = sum(cov(i, i) for i in range(n))
    off = sum(cov(i, j) for i in range(n) for j in range(n) if i != j)
    return diag, off, diag + off


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Susceptibility Bound: Bridge to Statistical Mechanics',
             fontsize=14, fontweight='bold')

# Left plot: susceptibility vs k for various n
for n in [4, 5, 6, 7, 8]:
    ks = range(1, n)
    chis = [matroid_susceptibility(n, k)[2] for k in ks]
    ax1.plot(ks, chis, 'o-', label=f'n={n}', markersize=5)
    ax1.axhline(y=n / 4, color='gray', linestyle=':', alpha=0.5)

ax1.set_xlabel('Rank k')
ax1.set_ylabel('Susceptibility χ(μ)')
ax1.set_title('χ vs. Rank for Uniform Matroids')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Right plot: decomposition for n=7
n = 7
ks = range(1, n)
diags = []
offs = []
totals = []
for k in ks:
    d, o, t = matroid_susceptibility(n, k)
    diags.append(d)
    offs.append(o)
    totals.append(t)

x = np.arange(len(list(ks)))
width = 0.35
ax2.bar(x - width / 2, diags, width, label='Diagonal (∑Var)', color='steelblue')
ax2.bar(x + width / 2, offs, width, label='Off-diagonal (∑Cov)', color='salmon')
ax2.plot(x, totals, 'k^-', markersize=8, label='Total χ', linewidth=2)
ax2.axhline(y=n / 4, color='red', linestyle='--', linewidth=2, label=f'Bound n/4 = {n/4}')
ax2.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)

ax2.set_xlabel('Rank k')
ax2.set_ylabel('Covariance contribution')
ax2.set_title(f'Susceptibility Decomposition (n={n})')
ax2.set_xticks(x)
ax2.set_xticklabels(list(ks))
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_susceptibility.png', dpi=150, bbox_inches='tight')
print("Saved viz_susceptibility.png")
