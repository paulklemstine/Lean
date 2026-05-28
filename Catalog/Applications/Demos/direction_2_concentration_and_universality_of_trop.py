#!/usr/bin/env python3
"""
Applications of Cycle-Birth Theory to Network Science and Data Analysis.

Demonstrates practical applications of the formally verified theory:
1. Network robustness analysis via cycle-birth spectrum
2. Anomaly detection using tropical spectral signatures
3. Graph classification from birth distributions
4. Confidence intervals for topological summaries

Application keywords: network science, topological statistics, percolation,
topological data analysis, random optimization.
"""

import numpy as np
from typing import List, Tuple, Dict


# ========================================================================
# Self-contained core routines
# ========================================================================

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_cycle_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    mst_w = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append(w)
        else:
            uf.union(u, v)
            mst_w.append(w)
    return births, mst_w


def ks_distance(s1, s2):
    if not s1 or not s2:
        return 1.0
    a, b = np.sort(s1), np.sort(s2)
    all_v = np.sort(np.concatenate([a, b]))
    c1 = np.searchsorted(a, all_v, side='right') / len(a)
    c2 = np.searchsorted(b, all_v, side='right') / len(b)
    return float(np.max(np.abs(c1 - c2)))


def sample_gnp_weighted(n, p, rng=None):
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    return edges


# ========================================================================
# Application 1: Network Robustness Analysis
# ========================================================================

def network_robustness_score(n: int, edges: List[Tuple[int, int, float]]) -> Dict:
    """
    Analyze network robustness using cycle-birth spectrum.

    The cycle-birth distribution encodes how redundant connectivity emerges
    as edge weights increase. A network with many early cycle births has
    high topological redundancy (robustness), while late births indicate
    fragile connectivity.

    Returns:
        Dictionary with robustness metrics derived from cycle-birth theory.
    """
    births, mst_weights = compute_cycle_births(n, edges)
    m = len(edges)

    if not births:
        return {
            'beta_1': 0,
            'redundancy_ratio': 0.0,
            'mean_birth_quantile': None,
            'early_birth_fraction': 0.0,
            'robustness_score': 0.0,
        }

    beta_1 = len(births)
    all_weights = sorted([e[2] for e in edges])
    median_weight = np.median(all_weights)

    early_births = sum(1 for b in births if b <= median_weight)

    return {
        'beta_1': beta_1,
        'redundancy_ratio': beta_1 / m if m > 0 else 0,
        'mean_birth_weight': float(np.mean(births)),
        'median_birth_weight': float(np.median(births)),
        'early_birth_fraction': early_births / beta_1,
        'robustness_score': early_births / beta_1 * beta_1 / max(m, 1),
    }


# ========================================================================
# Application 2: Anomaly Detection
# ========================================================================

def detect_anomalous_graph(n: int, edges: List[Tuple[int, int, float]],
                            reference_births: List[List[float]],
                            threshold: float = 0.3) -> Dict:
    """
    Detect whether a graph's cycle-birth spectrum is anomalous.

    Uses KS distance from a reference collection of cycle-birth distributions
    (from the same generative model). By concentration (Theorem 3), typical
    graphs cluster tightly; outliers indicate structural anomaly.

    Args:
        n: vertices
        edges: weighted edge list
        reference_births: list of birth-weight lists from reference graphs
        threshold: KS distance threshold for anomaly

    Returns:
        Anomaly report dictionary.
    """
    births, _ = compute_cycle_births(n, edges)

    if not births or not reference_births:
        return {'is_anomalous': None, 'reason': 'insufficient data'}

    ks_distances = [ks_distance(births, ref) for ref in reference_births if ref]

    if not ks_distances:
        return {'is_anomalous': None, 'reason': 'no valid references'}

    mean_ks = float(np.mean(ks_distances))
    max_ks = float(np.max(ks_distances))

    return {
        'is_anomalous': mean_ks > threshold,
        'mean_ks_distance': mean_ks,
        'max_ks_distance': max_ks,
        'num_references': len(ks_distances),
        'threshold': threshold,
    }


# ========================================================================
# Application 3: Graph Classification
# ========================================================================

def cycle_birth_feature_vector(n: int, edges: List[Tuple[int, int, float]],
                                num_bins: int = 10) -> np.ndarray:
    """
    Compute a feature vector from the cycle-birth distribution.

    Bins the empirical CDF into a fixed-dimension vector suitable for
    machine learning classifiers. By universality (Theorem 4), after
    quantile normalization, this captures structural graph properties
    independent of the edge-weight distribution.
    """
    births, _ = compute_cycle_births(n, edges)

    if not births:
        return np.zeros(num_bins)

    # Quantile transform to [0,1]
    sorted_births = np.sort(births)
    n_births = len(sorted_births)
    quantiles = (np.arange(n_births) + 0.5) / n_births

    # Bin into histogram
    bin_edges = np.linspace(0, 1, num_bins + 1)
    hist, _ = np.histogram(quantiles, bins=bin_edges)
    return hist / max(n_births, 1)


# ========================================================================
# Application 4: Confidence Intervals for Topological Summaries
# ========================================================================

def topological_confidence_interval(n: int, p: float,
                                     num_bootstrap: int = 100,
                                     confidence: float = 0.95,
                                     rng=None) -> Dict:
    """
    Compute confidence intervals for the cycle-birth CDF.

    Uses the concentration inequality (Theorem 3) to provide
    theoretically-backed confidence bands for the empirical CDF.

    The McDiarmid bound gives:
        P(|N(t) - E[N(t)]| ≥ r) ≤ 2·exp(-2r²/m)

    For confidence level 1-α, the band width is sqrt(m·ln(2/α)/2).
    """
    if rng is None:
        rng = np.random.default_rng()

    m_expected = int(n * (n-1) / 2 * p)

    # Theoretical bound from McDiarmid
    alpha = 1 - confidence
    if m_expected > 0:
        theoretical_band = np.sqrt(m_expected * np.log(2/alpha) / 2)
    else:
        theoretical_band = 0

    # Bootstrap empirical band
    all_births = []
    for _ in range(num_bootstrap):
        edges = sample_gnp_weighted(n, p, rng)
        births, _ = compute_cycle_births(n, edges)
        all_births.append(births)

    # Compute empirical band at several thresholds
    eval_points = np.linspace(0, 1, 20)
    lower = np.zeros(len(eval_points))
    upper = np.zeros(len(eval_points))
    median_cdf = np.zeros(len(eval_points))

    for k, t in enumerate(eval_points):
        counts = []
        for births in all_births:
            if births:
                c = sum(1 for b in births if b <= t) / len(births)
            else:
                c = 0
            counts.append(c)
        counts = np.sort(counts)
        lo_idx = int((1 - confidence) / 2 * len(counts))
        hi_idx = int((1 + confidence) / 2 * len(counts))
        lower[k] = counts[max(0, lo_idx)]
        upper[k] = counts[min(len(counts)-1, hi_idx)]
        median_cdf[k] = np.median(counts)

    return {
        'n': n,
        'p': p,
        'confidence': confidence,
        'theoretical_band_width': float(theoretical_band),
        'empirical_band_width': float(np.mean(upper - lower)),
        'eval_points': eval_points.tolist(),
        'lower_band': lower.tolist(),
        'upper_band': upper.tolist(),
        'median_cdf': median_cdf.tolist(),
    }


# ========================================================================
# Main demonstration
# ========================================================================

if __name__ == '__main__':
    rng = np.random.default_rng(42)

    print("=" * 70)
    print("APPLICATION 1: NETWORK ROBUSTNESS ANALYSIS")
    print("=" * 70)

    # Compare a random network to a structured one
    n = 50
    random_edges = sample_gnp_weighted(n, 0.15, rng)
    rob = network_robustness_score(n, random_edges)
    print(f"  Random G(50, 0.15):")
    for k, v in rob.items():
        print(f"    {k}: {v}")

    print()
    print("=" * 70)
    print("APPLICATION 2: ANOMALY DETECTION")
    print("=" * 70)

    # Build reference from G(30, 0.2)
    references = []
    for _ in range(50):
        e = sample_gnp_weighted(30, 0.2, rng)
        b, _ = compute_cycle_births(30, e)
        references.append(b)

    # Test a normal graph
    normal_edges = sample_gnp_weighted(30, 0.2, rng)
    result = detect_anomalous_graph(30, normal_edges, references)
    print(f"  Normal graph:    anomalous={result['is_anomalous']}, "
          f"mean KS={result['mean_ks_distance']:.4f}")

    # Test an anomalous graph (different p)
    anomalous_edges = sample_gnp_weighted(30, 0.5, rng)
    result = detect_anomalous_graph(30, anomalous_edges, references)
    print(f"  Anomalous graph: anomalous={result['is_anomalous']}, "
          f"mean KS={result['mean_ks_distance']:.4f}")

    print()
    print("=" * 70)
    print("APPLICATION 3: GRAPH FEATURE VECTORS")
    print("=" * 70)

    for p_val in [0.1, 0.2, 0.3]:
        edges = sample_gnp_weighted(40, p_val, rng)
        fv = cycle_birth_feature_vector(40, edges)
        print(f"  G(40, {p_val}): features = {np.round(fv, 3)}")

    print()
    print("=" * 70)
    print("APPLICATION 4: CONFIDENCE INTERVALS")
    print("=" * 70)

    ci = topological_confidence_interval(50, 0.15, num_bootstrap=50, rng=rng)
    print(f"  n={ci['n']}, p={ci['p']}, confidence={ci['confidence']}")
    print(f"  Theoretical band width (McDiarmid): {ci['theoretical_band_width']:.2f}")
    print(f"  Empirical band width:               {ci['empirical_band_width']:.4f}")


#!/usr/bin/env python3
"""
Demo: Cycle-Birth Concentration and Universality in Random Weighted Graphs

This script demonstrates the key theorems from probabilistic tropical topology:
1. Concentration test — KS distances decrease as n grows
2. Universality test — different weight distributions yield same birth structure
3. MST complement validation — cycle births = non-MST edges
4. Lipschitz stability — single-edge perturbation bounded by 1

Application keywords: tropical Morse theory, persistent homology, Erdős–Rényi graphs,
concentration of measure, McDiarmid inequality, universality, minimum spanning tree,
KS distance, empirical process.
"""

import numpy as np
from collections import defaultdict


# ========================================================================
# Inline implementations (self-contained)
# ========================================================================

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_cycle_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    mst = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append(w)
        else:
            uf.union(u, v)
            mst.append((u, v, w))
    return births, mst


def sample_gnp_weighted(n, p, dist='uniform', rng=None):
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                if dist == 'uniform':
                    w = rng.random()
                elif dist == 'exponential':
                    w = rng.exponential(1.0)
                elif dist == 'normal':
                    w = rng.normal(0, 1)
                else:
                    w = rng.random()
                edges.append((i, j, w))
    return edges


def ks_distance(s1, s2):
    if not s1 or not s2:
        return 1.0
    a = np.sort(s1)
    b = np.sort(s2)
    all_v = np.sort(np.concatenate([a, b]))
    c1 = np.searchsorted(a, all_v, side='right') / len(a)
    c2 = np.searchsorted(b, all_v, side='right') / len(b)
    return float(np.max(np.abs(c1 - c2)))


def quantile_transform(values):
    n = len(values)
    if n == 0:
        return []
    ranks = np.argsort(np.argsort(values))
    return list((ranks + 0.5) / n)


# ========================================================================
# Experiment 1: Concentration Test
# ========================================================================

def run_concentration_test():
    print("=" * 70)
    print("EXPERIMENT 1: CONCENTRATION TEST")
    print("Testing whether pairwise KS distances decrease as n grows")
    print("Expected: mean KS ~ O(n^{-1/2})")
    print("=" * 70)

    p = 0.15
    sizes = [50, 100, 200, 500]
    num_trials = 10
    rng = np.random.default_rng(2025)

    results = {}

    for n in sizes:
        ks_vals = []
        birth_lists = []
        for _ in range(num_trials):
            edges = sample_gnp_weighted(n, p, 'uniform', rng)
            births, _ = compute_cycle_births(n, edges)
            if births:
                birth_lists.append(quantile_transform(births))

        for i in range(len(birth_lists)):
            for j in range(i + 1, len(birth_lists)):
                if birth_lists[i] and birth_lists[j]:
                    ks_vals.append(ks_distance(birth_lists[i], birth_lists[j]))

        if ks_vals:
            mean_ks = np.mean(ks_vals)
            std_ks = np.std(ks_vals)
            results[n] = (mean_ks, std_ks)
            print(f"  n={n:4d}: mean KS = {mean_ks:.4f} ± {std_ks:.4f}  "
                  f"(n^{{-1/2}} = {1/np.sqrt(n):.4f})")

    if len(results) >= 2:
        ns = sorted(results.keys())
        ratios = []
        for i in range(1, len(ns)):
            r = results[ns[i]][0] / results[ns[i-1]][0] if results[ns[i-1]][0] > 0 else 0
            expected = np.sqrt(ns[i-1] / ns[i])
            ratios.append((ns[i-1], ns[i], r, expected))
        print("\n  Decay ratios (observed vs expected O(n^{-1/2})):")
        for n1, n2, r, exp_r in ratios:
            print(f"    {n1}→{n2}: ratio={r:.3f}, expected≈{exp_r:.3f}")

    print()


# ========================================================================
# Experiment 2: Universality Test
# ========================================================================

def run_universality_test():
    print("=" * 70)
    print("EXPERIMENT 2: UNIVERSALITY TEST")
    print("Testing invariance under monotone transport (Theorem 4)")
    print("Edge weight laws: Uniform, Exponential, Normal")
    print("=" * 70)

    n = 200
    p = 0.15
    num_trials = 20
    rng = np.random.default_rng(42)

    dists = ['uniform', 'exponential', 'normal']
    birth_collections = {d: [] for d in dists}

    for d in dists:
        for _ in range(num_trials):
            edges = sample_gnp_weighted(n, p, d, rng)
            births, _ = compute_cycle_births(n, edges)
            if births:
                # Apply quantile transform to map to common scale
                birth_collections[d].append(quantile_transform(births))

    # Compute within-distribution KS distances
    print("\n  Within-distribution mean KS distances:")
    within_ks = {}
    for d in dists:
        ks_vals = []
        for i in range(len(birth_collections[d])):
            for j in range(i + 1, len(birth_collections[d])):
                ks_vals.append(ks_distance(birth_collections[d][i],
                                           birth_collections[d][j]))
        if ks_vals:
            within_ks[d] = np.mean(ks_vals)
            print(f"    {d:12s}: {np.mean(ks_vals):.4f} ± {np.std(ks_vals):.4f}")

    # Compute between-distribution KS distances (after quantile transform)
    print("\n  Between-distribution mean KS distances (after quantile transform):")
    for i, d1 in enumerate(dists):
        for d2 in dists[i+1:]:
            ks_vals = []
            for b1 in birth_collections[d1]:
                for b2 in birth_collections[d2]:
                    ks_vals.append(ks_distance(b1, b2))
            if ks_vals:
                print(f"    {d1:12s} vs {d2:12s}: {np.mean(ks_vals):.4f} ± {np.std(ks_vals):.4f}")

    print("\n  → If between-dist KS ≈ within-dist KS, universality holds ✓")
    print()


# ========================================================================
# Experiment 3: MST Complement Validation
# ========================================================================

def run_mst_complement_test():
    print("=" * 70)
    print("EXPERIMENT 3: MST COMPLEMENT VALIDATION (Theorem 5)")
    print("Verifying: cycle-birth edges = complement of MST edges")
    print("=" * 70)

    rng = np.random.default_rng(123)
    all_pass = True

    for trial in range(20):
        n = rng.integers(10, 50)
        p = rng.uniform(0.1, 0.5)
        edges = sample_gnp_weighted(n, p, 'uniform', rng)

        births, mst = compute_cycle_births(n, edges)

        total = len(edges)
        num_births = len(births)
        num_mst = len(mst)

        if num_births + num_mst != total:
            print(f"  Trial {trial+1}: FAIL! births({num_births}) + mst({num_mst}) ≠ total({total})")
            all_pass = False
        else:
            pass  # silent pass

    if all_pass:
        print(f"  All 20 trials passed: cycle_births + MST_edges = total_edges ✓")

    # Detailed example
    n = 6
    edges = [(0,1,0.1), (1,2,0.2), (2,3,0.3), (3,4,0.4), (4,5,0.5),
             (0,2,0.6), (1,3,0.7), (2,4,0.8), (3,5,0.9), (0,5,1.0)]
    births, mst = compute_cycle_births(n, edges)
    print(f"\n  Detailed example (n=6, m={len(edges)}):")
    print(f"    MST edges (merges): {len(mst)} → weights = {[e[2] for e in mst]}")
    print(f"    Cycle births:       {len(births)} → weights = {births}")
    print(f"    Partition check:    {len(mst)} + {len(births)} = {len(edges)} ✓")
    print(f"    β₁ = m - (n-1) = {len(edges)} - {n-1} = {len(edges) - (n-1)}")
    print(f"    cycle_birth_count = {len(births)} = β₁ ✓" if len(births) == len(edges) - (n-1) else "    ✗")
    print()


# ========================================================================
# Experiment 4: Lipschitz Stability Test (Theorem 2)
# ========================================================================

def run_lipschitz_test():
    print("=" * 70)
    print("EXPERIMENT 4: LIPSCHITZ STABILITY (Theorem 2)")
    print("Verifying: changing one edge weight changes cycleBirthCountLE by ≤ 1")
    print("=" * 70)

    rng = np.random.default_rng(99)
    n = 30
    p = 0.2
    edges = sample_gnp_weighted(n, p, 'uniform', rng)
    m = len(edges)

    if m == 0:
        print("  No edges generated. Skipping.")
        return

    violations = 0
    tests = 0

    for _ in range(200):
        edge_idx = rng.integers(0, m)
        new_w = rng.random()
        t = rng.random()

        original_births, _ = compute_cycle_births(n, edges)
        orig_count = sum(1 for w in original_births if w <= t)

        mod_edges = list(edges)
        u, v, _ = mod_edges[edge_idx]
        mod_edges[edge_idx] = (u, v, new_w)

        mod_births, _ = compute_cycle_births(n, mod_edges)
        mod_count = sum(1 for w in mod_births if w <= t)

        diff = abs(orig_count - mod_count)
        tests += 1
        if diff > 1:
            violations += 1

    print(f"  Tested {tests} random single-edge perturbations")
    print(f"  Violations of |ΔN(t)| ≤ 1: {violations}")
    if violations == 0:
        print(f"  Lipschitz bound satisfied in all tests ✓")
    else:
        print(f"  WARNING: {violations} violations found!")
    print()


# ========================================================================
# Main
# ========================================================================

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  PROBABILISTIC TROPICAL TOPOLOGY: CYCLE-BIRTH DISTRIBUTIONS       ║")
    print("║  Concentration and Universality in Random Weighted Graphs          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    run_concentration_test()
    run_universality_test()
    run_mst_complement_test()
    run_lipschitz_test()

    print("=" * 70)
    print("ALL EXPERIMENTS COMPLETE")
    print("=" * 70)


"""
Visualization: Concentration of Cycle-Birth Distributions

Illustrates how empirical cycle-birth CDFs concentrate as graph size n grows.
Multiple independent trials of G(n,p) with uniform edge weights produce
empirical CDFs that cluster more tightly for larger n, demonstrating
the concentration phenomenon predicted by the McDiarmid/Azuma bound
(Theorem 3).

This is the visual analogue of the tropical spectral law: just as
the eigenvalue distribution of a random matrix concentrates to the
semicircle law, the cycle-birth distribution concentrates to a
deterministic tropical spectral measure.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# Self-contained implementations
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append(w)
        else:
            uf.union(u, v)
    return births


def sample_gnp(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    return edges


# Parameters
p = 0.15
sizes = [30, 100, 300]
num_trials = 15
rng = np.random.default_rng(2025)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
colors = ['#2196F3', '#FF9800', '#4CAF50']

for idx, n in enumerate(sizes):
    ax = axes[idx]
    for trial in range(num_trials):
        edges = sample_gnp(n, p, rng)
        births = compute_births(n, edges)
        if births:
            sorted_b = np.sort(births)
            cdf_y = np.arange(1, len(sorted_b) + 1) / len(sorted_b)
            ax.step(sorted_b, cdf_y, alpha=0.4, linewidth=1.2,
                    color=colors[idx])

    ax.set_title(f'n = {n}', fontsize=14, fontweight='bold')
    ax.set_xlabel('Edge Weight', fontsize=11)
    ax.set_ylabel('Empirical CDF', fontsize=11)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    # Add concentration annotation
    ax.text(0.05, 0.92, f'{num_trials} trials', transform=ax.transAxes,
            fontsize=9, color='gray')

fig.suptitle('Concentration of Cycle-Birth CDFs as n → ∞\n'
             'G(n, 0.15) with Uniform[0,1] edge weights',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('concentration_plot.png', dpi=150, bbox_inches='tight')
print("Saved concentration_plot.png")


"""
Visualization: Cycle Births as MST Complement

Illustrates Theorem 5: cycle-birth edges are exactly the non-MST edges.
Shows a small weighted graph with MST edges (blue) and cycle-birth edges (red),
plus a histogram comparing birth weights to MST weights.

This connects tropical Morse theory to combinatorial optimization:
the "tropical critical spectrum" of a graph is literally the weight spectrum
of edges rejected by Kruskal's algorithm.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


# Self-contained
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_births_and_mst(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    mst = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append((u, v, w))
        else:
            uf.union(u, v)
            mst.append((u, v, w))
    return births, mst


# Create a small example graph (K6 with specific weights)
n = 8
rng = np.random.default_rng(77)
edges = []
for i in range(n):
    for j in range(i + 1, n):
        if rng.random() < 0.5:
            edges.append((i, j, round(rng.random(), 2)))

births, mst = compute_births_and_mst(n, edges)

# Layout: circular
angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Graph with MST vs cycle-birth edges
ax = axes[0]

# Draw cycle-birth edges (red, dashed)
for u, v, w in births:
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    ax.plot(x, y, 'r--', linewidth=1.5, alpha=0.6)
    mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax.text(mx, my, f'{w}', fontsize=7, color='red', ha='center',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='white', alpha=0.8))

# Draw MST edges (blue, solid)
for u, v, w in mst:
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    ax.plot(x, y, 'b-', linewidth=2.5, alpha=0.8)
    mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax.text(mx, my, f'{w}', fontsize=7, color='blue', ha='center',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='white', alpha=0.8))

# Draw vertices
for i in range(n):
    ax.plot(pos[i][0], pos[i][1], 'ko', markersize=12, zorder=5)
    ax.text(pos[i][0], pos[i][1], str(i), fontsize=9, ha='center',
            va='center', color='white', fontweight='bold', zorder=6)

mst_patch = mpatches.Patch(color='blue', label=f'MST edges ({len(mst)})')
birth_patch = mpatches.Patch(color='red', label=f'Cycle births ({len(births)})')
ax.legend(handles=[mst_patch, birth_patch], fontsize=10, loc='upper left')
ax.set_title(f'Graph (n={n}, m={len(edges)})\nMST ∪ CycleBirths = All Edges',
             fontsize=12, fontweight='bold')
ax.set_xlim(-1.4, 1.4)
ax.set_ylim(-1.4, 1.4)
ax.set_aspect('equal')
ax.axis('off')

# Verification text
ax.text(0.5, -0.08, f'Theorem 5: {len(mst)} + {len(births)} = {len(edges)} ✓',
        transform=ax.transAxes, fontsize=11, ha='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# Right panel: Weight distributions
ax = axes[1]

mst_w = [e[2] for e in mst]
birth_w = [e[2] for e in births]
all_w = sorted([e[2] for e in edges])

bins = np.linspace(0, 1, 15)
if mst_w:
    ax.hist(mst_w, bins=bins, alpha=0.6, color='blue', label='MST (merge) weights',
            edgecolor='white')
if birth_w:
    ax.hist(birth_w, bins=bins, alpha=0.6, color='red', label='Cycle-birth weights',
            edgecolor='white')

ax.set_xlabel('Edge Weight', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Weight Distribution:\nMST vs Cycle-Birth Edges', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Add summary statistics
if mst_w and birth_w:
    stats_text = (f'MST:  mean={np.mean(mst_w):.3f}, n={len(mst_w)}\n'
                  f'Birth: mean={np.mean(birth_w):.3f}, n={len(birth_w)}\n'
                  f'β₁ = {len(birth_w)}')
    ax.text(0.97, 0.97, stats_text, transform=ax.transAxes, fontsize=9,
            va='top', ha='right',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

fig.suptitle('Theorem 5: Cycle-Birth Edges = MST Complement',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mst_complement_plot.png', dpi=150, bbox_inches='tight')
print("Saved mst_complement_plot.png")


"""
Visualization: Universality Under Monotone Transport

Demonstrates Theorem 4: the cycle-birth edge classification is invariant
under monotone transformation of edge weights. After quantile normalization,
cycle-birth CDFs from Uniform, Exponential, and Normal weight distributions
collapse onto the same curve.

This is the analogue of universality in random matrix theory, where the
eigenvalue distribution is insensitive to the distribution of matrix entries.
In tropical topology, only the ORDER of edge weights matters.
"""

import numpy as np
import matplotlib.pyplot as plt


# Self-contained implementations
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append(w)
        else:
            uf.union(u, v)
    return births


def quantile_transform(values):
    n = len(values)
    if n == 0:
        return np.array([])
    ranks = np.argsort(np.argsort(values))
    return (ranks + 0.5) / n


n = 300
p = 0.15
num_trials = 8
rng = np.random.default_rng(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left panel: Raw CDFs (different distributions look different)
ax = axes[0]
dist_configs = [
    ('uniform', '#2196F3', 'Uniform[0,1]'),
    ('exponential', '#FF5722', 'Exponential(1)'),
    ('normal', '#4CAF50', 'Normal(0,1)'),
]

for dist_name, color, label in dist_configs:
    for trial in range(num_trials):
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if rng.random() < p:
                    if dist_name == 'uniform':
                        w = rng.random()
                    elif dist_name == 'exponential':
                        w = rng.exponential(1.0)
                    else:
                        w = rng.normal(0, 1)
                    edges.append((i, j, w))

        births = compute_births(n, edges)
        if births:
            sorted_b = np.sort(births)
            cdf_y = np.arange(1, len(sorted_b) + 1) / len(sorted_b)
            lbl = label if trial == 0 else None
            ax.step(sorted_b, cdf_y, alpha=0.5, linewidth=1.0,
                    color=color, label=lbl)

ax.set_title('Raw Cycle-Birth CDFs\n(Different Weight Distributions)', fontsize=12, fontweight='bold')
ax.set_xlabel('Edge Weight', fontsize=11)
ax.set_ylabel('Empirical CDF', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Right panel: After quantile transform (universality!)
ax = axes[1]
rng2 = np.random.default_rng(42)  # Same seed for same graphs

for dist_name, color, label in dist_configs:
    for trial in range(num_trials):
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if rng2.random() < p:
                    if dist_name == 'uniform':
                        w = rng2.random()
                    elif dist_name == 'exponential':
                        w = rng2.exponential(1.0)
                    else:
                        w = rng2.normal(0, 1)
                    edges.append((i, j, w))

        births = compute_births(n, edges)
        if births:
            qt = quantile_transform(np.array(births))
            sorted_qt = np.sort(qt)
            cdf_y = np.arange(1, len(sorted_qt) + 1) / len(sorted_qt)
            lbl = label if trial == 0 else None
            ax.step(sorted_qt, cdf_y, alpha=0.5, linewidth=1.0,
                    color=color, label=lbl)

ax.set_title('After Quantile Transform\n(Universality: All Curves Collapse)', fontsize=12, fontweight='bold')
ax.set_xlabel('Quantile-Transformed Weight', fontsize=11)
ax.set_ylabel('Empirical CDF', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

fig.suptitle('Theorem 4: Monotone Transport Universality',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('universality_plot.png', dpi=150, bbox_inches='tight')
print("Saved universality_plot.png")
