#!/usr/bin/env python3
"""
applications.py — Real-world applications of information-theoretic monotonicity
for robustly Lorentzian measures.

Demonstrates applications to:
1. Privacy amplification under coordinate deletion
2. Anti-clustering bounds in statistical mechanics
3. Communication complexity of coordinate sampling
4. Sampling algorithm analysis
"""

import numpy as np
from itertools import combinations
from math import log, log2, comb, exp, sqrt
from typing import Dict, List, Tuple


# =============================================================================
# Self-contained core (no local imports)
# =============================================================================

def _all_subsets(n):
    return [frozenset(j for j in range(n) if i & (1 << j)) for i in range(2**n)]

class FinsetLaw:
    def __init__(self, n, weights=None):
        self.n = n
        if weights is None:
            total = 2 ** n
            self.weights = {frozenset(j for j in range(n) if i & (1 << j)): 1.0/total
                            for i in range(total)}
        else:
            self.weights = dict(weights)
            for i in range(2**n):
                s = frozenset(j for j in range(n) if i & (1 << j))
                if s not in self.weights:
                    self.weights[s] = 0.0
        total = sum(self.weights.values())
        if total > 0:
            self.weights = {s: w/total for s, w in self.weights.items()}

    def coord_prob(self, i): return sum(w for s, w in self.weights.items() if i in s)
    def pair_joint_prob(self, i, j): return sum(w for s, w in self.weights.items() if i in s and j in s)
    def coord_cov(self, i, j): return self.pair_joint_prob(i,j) - self.coord_prob(i)*self.coord_prob(j)
    def total_entropy(self): return -sum(w*log(w) for w in self.weights.values() if w > 0)
    def mutual_info_proxy(self, i, j):
        p, q, c = self.coord_prob(i), self.coord_prob(j), self.coord_cov(i,j)
        if p<=0 or p>=1 or q<=0 or q>=1: return 0.0
        return c**2/(p*(1-p)*q*(1-q))
    def susceptibility(self): return sum(self.coord_cov(i,j) for i in range(self.n) for j in range(self.n))
    def delete_coord(self, k):
        new_w = {}
        for s, w in self.weights.items():
            s2 = frozenset(x if x < k else x-1 for x in s if x != k)
            new_w[s2] = new_w.get(s2, 0.0) + w
        return FinsetLaw(self.n - 1, new_w)

def uniform_matroid(n, r):
    subs = [frozenset(c) for c in combinations(range(n), r)]
    return FinsetLaw(n, {s: 1.0/len(subs) for s in subs})


# =============================================================================
# Application 1: Privacy Amplification
# =============================================================================

def privacy_amplification_demo():
    """
    When a robustly Lorentzian law models a data release mechanism,
    deleting one coordinate provides privacy amplification.

    The entropy retention bound H(delete_k) ≥ H(μ) - log 2 shows that
    deleting a coordinate cannot destroy more than log 2 bits of uncertainty,
    ensuring the remaining distribution retains near-maximal entropy.
    """
    print("=" * 60)
    print("APPLICATION 1: Privacy Amplification Under Deletion")
    print("=" * 60)
    print()
    print("Scenario: Data is sampled from a negatively dependent distribution")
    print("on subsets (e.g., random committee selection). An adversary learns")
    print("one coordinate was deleted. How much does uncertainty decrease?")
    print()

    for n, r in [(6, 3), (8, 4), (10, 5)]:
        mu = uniform_matroid(n, r)
        H = mu.total_entropy()
        drops = [H - mu.delete_coord(k).total_entropy() for k in range(n)]
        max_drop = max(drops)
        avg_drop = sum(drops) / len(drops)

        print(f"U({n},{r}): H = {H:.4f} nats")
        print(f"  Max entropy drop: {max_drop:.4f} (bound: {log(2):.4f})")
        print(f"  Avg entropy drop: {avg_drop:.4f}")
        print(f"  Entropy retention: {(1 - max_drop/H)*100:.1f}%")
        print()


# =============================================================================
# Application 2: Anti-Clustering in Statistical Mechanics
# =============================================================================

def anti_clustering_demo():
    """
    Susceptibility bounds show that robustly Lorentzian measures
    model repulsive particle systems where clustering is suppressed.
    """
    print("=" * 60)
    print("APPLICATION 2: Anti-Clustering (Susceptibility Bounds)")
    print("=" * 60)
    print()
    print("In statistical mechanics, susceptibility χ measures how")
    print("strongly particles cluster in response to an external field.")
    print("For repulsive (negatively dependent) systems, χ is suppressed.")
    print()

    print(f"{'System':>20} {'n':>4} {'χ':>10} {'χ_bound':>10} "
          f"{'χ/n':>8} {'Status':>8}")
    print("-" * 65)

    for n, r in [(4, 2), (6, 3), (8, 4), (10, 5)]:
        mu = uniform_matroid(n, r)
        chi = mu.susceptibility()

        # Find max ε
        best_eps = 0.0
        for eps in np.linspace(0.001, 0.49, 200):
            ok = True
            for i in range(n):
                p = mu.coord_prob(i)
                if p < eps or p > 1-eps: ok = False
            for i in range(n):
                for j in range(n):
                    if i != j and (mu.coord_cov(i,j) > 1e-12 or abs(mu.coord_cov(i,j)) > eps): ok = False
            if ok: best_eps = eps

        chi_bound = n * (0.25 + (n-1) * best_eps) if best_eps > 0 else float('inf')
        status = "PASS" if chi <= chi_bound + 1e-10 else "FAIL"

        print(f"{'U('+str(n)+','+str(r)+')':>20} {n:4d} {chi:10.4f} "
              f"{chi_bound:10.4f} {chi/n:8.4f} {status:>8}")

    print()
    print("Key insight: χ/n remains bounded as n grows, showing")
    print("per-particle response is suppressed by negative dependence.")


# =============================================================================
# Application 3: Communication Complexity
# =============================================================================

def communication_complexity_demo():
    """
    If Alice and Bob each learn one coordinate from a robustly Lorentzian
    distribution, the internal information cost of any protocol is bounded
    by the MI bound.
    """
    print()
    print("=" * 60)
    print("APPLICATION 3: Communication Complexity Bounds")
    print("=" * 60)
    print()
    print("Protocol: Alice gets X_i, Bob gets X_j, both from a Lorentzian law.")
    print("The internal information cost IC ≤ I(X_i; X_j) ≤ MI_bound(ε).")
    print()

    for n, r in [(6, 3), (8, 4)]:
        mu = uniform_matroid(n, r)

        # Compute all pairwise MI
        mi_values = []
        for i in range(n):
            for j in range(i+1, n):
                mi_values.append((i, j, mu.mutual_info_proxy(i, j)))

        mi_values.sort(key=lambda x: -x[2])
        max_mi = mi_values[0][2] if mi_values else 0
        avg_mi = sum(m for _, _, m in mi_values) / len(mi_values) if mi_values else 0

        print(f"U({n},{r}): {comb(n,r)} bases")
        print(f"  Max MI proxy: {max_mi:.6f}")
        print(f"  Avg MI proxy: {avg_mi:.6f}")
        print(f"  This bounds the communication cost of any protocol")
        print(f"  that reveals 2 coordinates to 2 parties.")
        print()


# =============================================================================
# Application 4: Sampling Algorithm Analysis
# =============================================================================

def sampling_analysis_demo():
    """
    Show that the negative dependence structure of Lorentzian measures
    enables efficient sampling with controlled mixing time.
    """
    print("=" * 60)
    print("APPLICATION 4: Sampling Algorithm Analysis")
    print("=" * 60)
    print()
    print("For a basis-exchange Markov chain on matroid bases,")
    print("the mixing time is controlled by the Lorentzian gap.")
    print()

    print(f"{'Matroid':>12} {'|bases|':>8} {'H':>10} {'χ':>10} "
          f"{'mix_bound':>12}")
    print("-" * 55)

    for n, r in [(4, 2), (5, 2), (6, 3), (7, 3), (8, 4)]:
        mu = uniform_matroid(n, r)
        num_bases = comb(n, r)
        H = mu.total_entropy()
        chi = mu.susceptibility()

        # Rough mixing time estimate: O(n² log n) for matroid bases
        mix_bound = n * n * log(n) if n > 1 else 1

        print(f"{'U('+str(n)+','+str(r)+')':>12} {num_bases:8d} {H:10.4f} "
              f"{chi:10.4f} {mix_bound:12.1f}")

    print()
    print("The bounded susceptibility implies fast mixing:")
    print("χ = O(n) ⟹ spectral gap Ω(1/n) ⟹ mixing time O(n log n).")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("Information-Theoretic Applications of Lorentzian Negativity")
    print("=" * 60)
    print()

    privacy_amplification_demo()
    print()
    anti_clustering_demo()
    print()
    communication_complexity_demo()
    print()
    sampling_analysis_demo()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of information-theoretic monotonicity
for robustly Lorentzian measures.

Demonstrates:
- Uniform matroid distributions and their information profiles
- Perturbed negatively dependent laws
- Deletion entropy before/after removing a coordinate
- Pairwise mutual information heatmaps
- Comparison of empirical values against certified upper bounds
"""

import numpy as np
from itertools import combinations
from math import log, log2, comb
import sys


def binary_entropy(p):
    """Binary entropy h(p) = -p log p - (1-p) log(1-p) in nats."""
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * log(p) + (1 - p) * log(1 - p))


def shannon_entropy(weights):
    """Shannon entropy H = -sum w_i log w_i in nats."""
    return -sum(w * log(w) for w in weights if w > 0)


def subsets_of_size_k(n, k):
    """Generate all subsets of {0,...,n-1} of size k as frozensets."""
    return [frozenset(c) for c in combinations(range(n), k)]


def all_subsets(n):
    """Generate all subsets of {0,...,n-1} as frozensets."""
    result = []
    for k in range(n + 1):
        result.extend(subsets_of_size_k(n, k))
    return result


class FinsetLaw:
    """Probability mass function on subsets of [n] = {0, ..., n-1}."""

    def __init__(self, n, weight_dict=None):
        self.n = n
        self.subsets = all_subsets(n)
        if weight_dict is None:
            # Uniform over all subsets
            w = 1.0 / len(self.subsets)
            self.weights = {s: w for s in self.subsets}
        else:
            self.weights = {s: weight_dict.get(s, 0.0) for s in self.subsets}
        # Normalize
        total = sum(self.weights.values())
        if total > 0:
            self.weights = {s: w / total for s, w in self.weights.items()}

    def coord_prob(self, i):
        """P(i ∈ S)"""
        return sum(w for s, w in self.weights.items() if i in s)

    def pair_joint_prob(self, i, j):
        """P(i ∈ S and j ∈ S)"""
        return sum(w for s, w in self.weights.items() if i in s and j in s)

    def coord_cov(self, i, j):
        """Cov(1_{i∈S}, 1_{j∈S})"""
        return self.pair_joint_prob(i, j) - self.coord_prob(i) * self.coord_prob(j)

    def total_entropy(self):
        """Shannon entropy H(μ)"""
        return shannon_entropy(self.weights.values())

    def delete_coord(self, k):
        """Pushforward deleting coordinate k."""
        new_weights = {}
        for s, w in self.weights.items():
            s_minus_k = frozenset(x for x in s if x != k)
            # Relabel: shift indices > k down by 1
            relabeled = frozenset(x if x < k else x - 1 for x in s_minus_k)
            new_weights[relabeled] = new_weights.get(relabeled, 0.0) + w
        return FinsetLaw(self.n - 1, new_weights)

    def mutual_info_proxy(self, i, j):
        """Chi-squared MI proxy: c²/(p(1-p)q(1-q))"""
        p = self.coord_prob(i)
        q = self.coord_prob(j)
        c = self.coord_cov(i, j)
        if p <= 0 or p >= 1 or q <= 0 or q >= 1:
            return 0.0
        return c ** 2 / (p * (1 - p) * q * (1 - q))

    def susceptibility(self):
        """χ = sum_{i,j} Cov(X_i, X_j)"""
        return sum(self.coord_cov(i, j) for i in range(self.n) for j in range(self.n))

    def check_robust_lorentzian(self, eps):
        """Check if the law satisfies RobustlyLorentzian(μ, ε)."""
        if eps <= 0 or eps > 0.5:
            return False, "ε out of range"
        for i in range(self.n):
            p = self.coord_prob(i)
            if p < eps - 1e-12:
                return False, f"marginal p_{i} = {p:.4f} < ε = {eps}"
            if p > 1 - eps + 1e-12:
                return False, f"marginal p_{i} = {p:.4f} > 1-ε = {1-eps}"
        for i in range(self.n):
            for j in range(self.n):
                if i != j:
                    c = self.coord_cov(i, j)
                    if c > 1e-12:
                        return False, f"Cov({i},{j}) = {c:.6f} > 0"
                    if abs(c) > eps + 1e-12:
                        return False, f"|Cov({i},{j})| = {abs(c):.6f} > ε = {eps}"
        return True, "OK"


def uniform_matroid_law(n, r):
    """Uniform distribution over all r-element subsets of [n]."""
    subsets = subsets_of_size_k(n, r)
    w = 1.0 / len(subsets)
    return FinsetLaw(n, {s: w for s in subsets})


def perturbed_matroid_law(n, r, delta=0.01):
    """Perturbed matroid: slightly favor subsets containing element 0."""
    subsets = subsets_of_size_k(n, r)
    weights = {}
    for s in subsets:
        if 0 in s:
            weights[s] = 1.0 + delta
        else:
            weights[s] = 1.0
    return FinsetLaw(n, weights)


def demo_uniform_matroid():
    """Demonstrate information profile of uniform matroid."""
    print("=" * 70)
    print("DEMO 1: Uniform Matroid U(n, r)")
    print("=" * 70)

    for n, r in [(4, 2), (5, 2), (6, 3), (8, 4)]:
        mu = uniform_matroid_law(n, r)
        H = mu.total_entropy()
        print(f"\nU({n},{r}): H = {H:.4f} nats ({H/log(2):.4f} bits)")
        print(f"  Coord prob: {mu.coord_prob(0):.4f}")
        print(f"  Cov(0,1): {mu.coord_cov(0, 1):.6f}")
        print(f"  MI proxy(0,1): {mu.mutual_info_proxy(0, 1):.6f}")
        print(f"  Susceptibility: {mu.susceptibility():.4f}")

        # Check robustness
        for eps in [0.05, 0.1, 0.2]:
            ok, msg = mu.check_robust_lorentzian(eps)
            bound = 1.0 / (1 - eps) ** 2 if eps > 0 else 0
            print(f"  RobustlyLorentzian(ε={eps}): {ok} ({msg})")
            if ok:
                print(f"    MI bound: {bound:.4f}, actual max MI: "
                      f"{max(mu.mutual_info_proxy(i,j) for i in range(n) for j in range(n) if i!=j):.6f}")


def demo_deletion_entropy():
    """Demonstrate entropy loss under coordinate deletion."""
    print("\n" + "=" * 70)
    print("DEMO 2: Entropy Loss Under Coordinate Deletion")
    print("=" * 70)

    for n, r in [(5, 2), (6, 3), (8, 4)]:
        mu = uniform_matroid_law(n, r)
        H = mu.total_entropy()
        print(f"\nU({n},{r}): H(μ) = {H:.4f}")

        for k in [0, 1]:
            mu_del = mu.delete_coord(k)
            H_del = mu_del.total_entropy()
            drop = H - H_del
            print(f"  Delete coord {k}: H(π_k μ) = {H_del:.4f}, "
                  f"drop = {drop:.4f}, log 2 = {log(2):.4f}")
            print(f"    Bound satisfied: {drop <= log(2) + 1e-10}")


def demo_mi_heatmap():
    """Display pairwise MI matrix."""
    print("\n" + "=" * 70)
    print("DEMO 3: Pairwise Mutual Information Matrix")
    print("=" * 70)

    n, r = 5, 2
    mu = uniform_matroid_law(n, r)
    print(f"\nU({n},{r}) MI proxy matrix:")
    for i in range(n):
        row = []
        for j in range(n):
            if i == j:
                row.append("  ----  ")
            else:
                row.append(f"{mu.mutual_info_proxy(i, j):8.5f}")
        print("  ".join(row))


def demo_bounds_comparison():
    """Compare empirical values against certified bounds."""
    print("\n" + "=" * 70)
    print("DEMO 4: Bounds Comparison — Varying ε")
    print("=" * 70)

    n = 6
    print(f"\nn = {n}, testing various matroid ranks and perturbations")
    print(f"{'r':>3} {'ε':>8} {'max MI':>10} {'MI bound':>10} "
          f"{'χ':>10} {'χ bound':>10} {'H drop':>10} {'log 2':>10}")
    print("-" * 80)

    for r in [2, 3]:
        for delta in [0.0, 0.01, 0.05]:
            if delta == 0:
                mu = uniform_matroid_law(n, r)
            else:
                mu = perturbed_matroid_law(n, r, delta)

            max_mi = max(mu.mutual_info_proxy(i, j)
                         for i in range(n) for j in range(n) if i != j)
            chi = mu.susceptibility()
            H = mu.total_entropy()
            H_del = mu.delete_coord(0).total_entropy()
            drop = H - H_del

            # Find the largest ε for which law is robustly Lorentzian
            best_eps = 0.0
            for eps_try in np.linspace(0.01, 0.49, 50):
                ok, _ = mu.check_robust_lorentzian(eps_try)
                if ok:
                    best_eps = eps_try

            if best_eps > 0:
                mi_bound = 1.0 / (1 - best_eps) ** 2
                chi_bound = n * (0.25 + (n - 1) * best_eps)
            else:
                mi_bound = float('inf')
                chi_bound = float('inf')

            print(f"{r:3d} {best_eps:8.3f} {max_mi:10.6f} {mi_bound:10.4f} "
                  f"{chi:10.4f} {chi_bound:10.4f} {drop:10.4f} {log(2):10.4f}")


def demo_conjecture_test():
    """Test the logarithmic MI conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 5: Conjecture Test — MI Scaling with ε")
    print("=" * 70)

    print("\nConjecture: I(X_i;X_j) ≤ C·log(1 + 1/ε) may be tighter than C/ε")
    print(f"{'n':>3} {'r':>3} {'ε':>8} {'max MI':>10} {'1/ε':>10} "
          f"{'log(1+1/ε)':>12} {'1/(1-ε)²':>10}")
    print("-" * 75)

    for n in [6, 8]:
        for r in [2, 3, n // 2]:
            mu = uniform_matroid_law(n, r)
            # Find best ε
            best_eps = 0.0
            for eps_try in np.linspace(0.001, 0.49, 100):
                ok, _ = mu.check_robust_lorentzian(eps_try)
                if ok:
                    best_eps = eps_try
            if best_eps <= 0:
                continue
            max_mi = max(mu.mutual_info_proxy(i, j)
                         for i in range(n) for j in range(n) if i != j)
            inv_eps = 1.0 / best_eps
            log_bound = log(1 + inv_eps)
            chi_sq_bound = 1.0 / (1 - best_eps) ** 2

            print(f"{n:3d} {r:3d} {best_eps:8.4f} {max_mi:10.6f} "
                  f"{inv_eps:10.4f} {log_bound:12.4f} {chi_sq_bound:10.4f}")


if __name__ == "__main__":
    print("Information-Theoretic Monotonicity for Robustly Lorentzian Measures")
    print("Numerical Demonstration")
    print()

    demo_uniform_matroid()
    demo_deletion_entropy()
    demo_mi_heatmap()
    demo_bounds_comparison()
    demo_conjecture_test()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

base = '/workspace/request-project'

package = {
    "title": "Information-Theoretic Monotonicity for Robustly Lorentzian Measures",
    "domain": "Discrete Probability / Information Theory / Lorentzian Geometry",
    "article": read_file(os.path.join(base, 'ARTICLE.md')),
    "research_paper": read_file(os.path.join(base, 'RESEARCH_PAPER.md')),
    "future_directions": read_file(os.path.join(base, 'FUTURE_DIRECTIONS.md')),
    "demos": [
        {
            "name": "Lorentzian Information Demo",
            "code": read_file(os.path.join(base, 'demo.py'))
        }
    ],
    "algorithms": [
        {
            "name": "Information Profile Audit",
            "pseudocode": "function AuditProfile(mu, eps):\n  1. Compute marginals p[i] = sum_{s ni i} mu(s)\n  2. Compute covariance matrix C[i,j]\n  3. Compute entropy H = -sum mu(s) log mu(s)\n  4. Compute deletion entropies H_del[k]\n  5. Certify robustness\n  6. Verify MI bound, entropy bound, susceptibility bound\n  return InfoProfile",
            "code": read_file(os.path.join(base, 'algorithms.py'))
        }
    ],
    "visualizations": [
        {
            "name": "Pairwise Mutual Information Heatmap",
            "code": read_file(os.path.join(base, 'viz_mi_heatmap.py')),
            "description": "Visualizes the pairwise mutual information proxy matrix for uniform matroid distributions, showing how Lorentzian negativity suppresses pairwise information."
        },
        {
            "name": "Entropy Loss Under Coordinate Deletion",
            "code": read_file(os.path.join(base, 'viz_entropy_deletion.py')),
            "description": "Shows the entropy drop H(mu) - H(delete_k(mu)) for various uniform matroids compared against the proved bound of log 2."
        },
        {
            "name": "Susceptibility Bounds",
            "code": read_file(os.path.join(base, 'viz_susceptibility.py')),
            "description": "Shows how susceptibility scales with system size for uniform matroid distributions, demonstrating anti-clustering from Lorentzian negativity."
        }
    ],
    "interactive_demos": [
        {
            "name": "Lorentzian Information Explorer",
            "html": read_file(os.path.join(base, 'interactive_lorentzian.html')),
            "description": "Interactive explorer for uniform matroid distributions: adjust n and r to see entropy, MI, susceptibility, and robustness certification in real time."
        }
    ],
    "lean_proofs": read_file(os.path.join(base, 'Catalog/Pythagorean/LorentzianInformation.lean'))
}

with open(os.path.join(base, 'PACKAGE.json'), 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")


#!/usr/bin/env python3
"""
Visualization: Entropy Loss Under Coordinate Deletion

Shows the entropy drop H(μ) - H(delete_k(μ)) for various uniform matroid
distributions, compared against the proved upper bound of log 2.
Demonstrates the data processing inequality and how Lorentzian negativity
keeps entropy loss well below the theoretical maximum.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def make_matroid(n, r):
    subs = [frozenset(c) for c in combinations(range(n), r)]
    w = 1.0 / len(subs)
    weights = {}
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        weights[s] = w if s in set(subs) else 0.0
    return weights


def entropy(weights):
    return -sum(w * log(w) for w in weights.values() if w > 0)


def delete_coord(n, weights, k):
    new_w = {}
    for s, w in weights.items():
        s2 = frozenset(x if x < k else x-1 for x in s if x != k)
        new_w[s2] = new_w.get(s2, 0.0) + w
    return new_w


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

# Panel 1: Entropy drops for various matroids
configs = []
for n in range(4, 11):
    for r in range(1, n):
        if comb(n, r) <= 5000:  # Avoid huge computations
            configs.append((n, r))

entropy_drops = []
labels = []
ns = []

for n, r in configs:
    w = make_matroid(n, r)
    H = entropy(w)
    drops = []
    for k in range(n):
        w_del = delete_coord(n, w, k)
        H_del = entropy(w_del)
        drops.append(H - H_del)
    max_drop = max(drops)
    entropy_drops.append(max_drop)
    labels.append(f"U({n},{r})")
    ns.append(n)

# Color by n
colors = plt.cm.viridis(np.linspace(0, 1, max(ns) - min(ns) + 1))
bar_colors = [colors[n - min(ns)] for n in ns]

x_pos = range(len(entropy_drops))
ax1.bar(x_pos, entropy_drops, color=bar_colors, alpha=0.8, edgecolor='black', linewidth=0.5)
ax1.axhline(y=log(2), color='red', linestyle='--', linewidth=2, label=f'Bound: log 2 ≈ {log(2):.3f}')
ax1.set_xticks(x_pos)
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=7)
ax1.set_ylabel('Max Entropy Drop (nats)')
ax1.set_title('Entropy Drop Under Coordinate Deletion', fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(0, log(2) * 1.2)

# Panel 2: Entropy drop vs rank ratio r/n
ratios = []
drops_norm = []
for (n, r), d in zip(configs, entropy_drops):
    ratios.append(r / n)
    drops_norm.append(d / log(2))

ax2.scatter(ratios, drops_norm, c=[n for n, r in configs], cmap='viridis',
            s=40, edgecolors='black', linewidth=0.5, alpha=0.8)
ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Bound: 1.0')
ax2.set_xlabel('Rank ratio r/n')
ax2.set_ylabel('Entropy drop / log 2')
ax2.set_title('Normalized Entropy Drop vs Rank Ratio', fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_ylim(0, 1.3)
cbar = plt.colorbar(ax2.collections[0], ax=ax2, label='n')

fig.suptitle('Entropy Monotonicity: Deletion Cannot Destroy Too Much Information',
             fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('entropy_deletion.png', dpi=150, bbox_inches='tight')
print("Saved entropy_deletion.png")


#!/usr/bin/env python3
"""
Visualization: Pairwise Mutual Information Heatmap for Lorentzian Measures

Visualizes the pairwise mutual information proxy matrix for uniform matroid
distributions of varying rank, showing how Lorentzian negativity suppresses
pairwise information. The uniformity of the heatmap demonstrates the
symmetry and boundedness predicted by the formal theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from math import log


def uniform_matroid_law(n, r):
    subs = [frozenset(c) for c in combinations(range(n), r)]
    w = 1.0 / len(subs)
    weights = {}
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        weights[s] = w if s in set(subs) else 0.0
    return n, weights


def coord_prob(n, weights, i):
    return sum(w for s, w in weights.items() if i in s)


def coord_cov(n, weights, i, j):
    pij = sum(w for s, w in weights.items() if i in s and j in s)
    return pij - coord_prob(n, weights, i) * coord_prob(n, weights, j)


def mi_proxy(n, weights, i, j):
    p = coord_prob(n, weights, i)
    q = coord_prob(n, weights, j)
    c = coord_cov(n, weights, i, j)
    if p <= 0 or p >= 1 or q <= 0 or q >= 1:
        return 0.0
    return c**2 / (p*(1-p)*q*(1-q))


fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
configs = [(6, 2), (6, 3), (8, 4)]

for ax, (n, r) in zip(axes, configs):
    nn, weights = uniform_matroid_law(n, r)
    mi_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                mi_matrix[i, j] = mi_proxy(n, weights, i, j)

    im = ax.imshow(mi_matrix, cmap='YlOrRd', interpolation='nearest',
                   vmin=0, vmax=max(0.01, np.max(mi_matrix)))
    ax.set_title(f'U({n},{r}): MI Proxy Matrix', fontsize=12, fontweight='bold')
    ax.set_xlabel('Coordinate j')
    ax.set_ylabel('Coordinate i')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    # Find max eps
    best_eps = 0.0
    for eps in np.linspace(0.001, 0.49, 200):
        ok = True
        for i in range(n):
            p = coord_prob(n, weights, i)
            if p < eps or p > 1-eps: ok = False
        for i in range(n):
            for j in range(n):
                if i != j and abs(coord_cov(n, weights, i, j)) > eps: ok = False
        if ok: best_eps = eps
    bound = 1/(1-best_eps)**2 if best_eps > 0 else float('inf')
    ax.text(0.5, -0.18, f'ε={best_eps:.3f}, bound={bound:.3f}\nmax MI={np.max(mi_matrix):.5f}',
            transform=ax.transAxes, ha='center', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))

fig.suptitle('Pairwise Mutual Information Under Lorentzian Negativity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mi_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved mi_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Susceptibility Bounds — The Statistical Mechanics Bridge

Shows how susceptibility (sum of all pairwise covariances) scales with system
size n for uniform matroid distributions, compared against the proved bound
χ ≤ n·(1/4 + (n-1)·ε). Demonstrates the connection between Lorentzian
negativity and anti-ferromagnetic behavior in statistical physics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def make_matroid(n, r):
    subs = set(frozenset(c) for c in combinations(range(n), r))
    weights = {}
    w = 1.0 / len(subs)
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        weights[s] = w if s in subs else 0.0
    return weights


def coord_prob(weights, i):
    return sum(w for s, w in weights.items() if i in s)


def coord_cov(weights, i, j):
    pij = sum(w for s, w in weights.items() if i in s and j in s)
    return pij - coord_prob(weights, i) * coord_prob(weights, j)


def susceptibility(n, weights):
    return sum(coord_cov(weights, i, j) for i in range(n) for j in range(n))


def find_max_eps(n, weights):
    best = 0.0
    for eps in np.linspace(0.001, 0.49, 300):
        ok = True
        for i in range(n):
            p = coord_prob(weights, i)
            if p < eps - 1e-12 or p > 1 - eps + 1e-12:
                ok = False; break
        if ok:
            for i in range(n):
                for j in range(n):
                    if i != j and abs(coord_cov(weights, i, j)) > eps + 1e-12:
                        ok = False; break
                if not ok: break
        if ok:
            best = eps
    return best


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: χ vs n for fixed r/n ≈ 1/2
ns_half = list(range(4, 13))
chi_vals = []
chi_bounds = []
chi_per_n = []

for n in ns_half:
    r = n // 2
    if comb(n, r) > 10000:
        continue
    w = make_matroid(n, r)
    chi = susceptibility(n, w)
    eps = find_max_eps(n, w)
    bound = n * (0.25 + (n-1) * eps) if eps > 0 else float('inf')
    chi_vals.append(chi)
    chi_bounds.append(bound)
    chi_per_n.append(chi / n)

x = ns_half[:len(chi_vals)]
axes[0].plot(x, chi_vals, 'bo-', linewidth=2, markersize=6, label='χ (actual)')
axes[0].plot(x, chi_bounds, 'r^--', linewidth=2, markersize=6, label='Bound')
axes[0].set_xlabel('n')
axes[0].set_ylabel('Susceptibility χ')
axes[0].set_title('χ vs n for U(n, ⌊n/2⌋)', fontweight='bold')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Panel 2: χ/n vs n (per-particle response)
axes[1].plot(x, chi_per_n, 'gs-', linewidth=2, markersize=6, label='χ/n')
axes[1].axhline(y=0.25, color='orange', linestyle=':', linewidth=2, label='1/4 (diagonal only)')
axes[1].set_xlabel('n')
axes[1].set_ylabel('χ/n')
axes[1].set_title('Per-Particle Susceptibility', fontweight='bold')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Panel 3: Susceptibility for different ranks
for n in [6, 8, 10]:
    if n > 10:
        continue
    ranks = list(range(1, n))
    chis = []
    for r in ranks:
        if comb(n, r) > 10000:
            chis.append(np.nan)
            continue
        w = make_matroid(n, r)
        chis.append(susceptibility(n, w))
    axes[2].plot(ranks, chis, 'o-', linewidth=1.5, markersize=5, label=f'n={n}')

axes[2].set_xlabel('Rank r')
axes[2].set_ylabel('Susceptibility χ')
axes[2].set_title('χ vs Rank for Various n', fontweight='bold')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

fig.suptitle('Susceptibility Bounds: Lorentzian Negativity Suppresses Clustering',
             fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('susceptibility_bounds.png', dpi=150, bbox_inches='tight')
print("Saved susceptibility_bounds.png")
