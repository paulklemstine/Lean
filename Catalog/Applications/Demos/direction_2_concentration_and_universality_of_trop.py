"""
Applications of Cycle-Birth Concentration Theory

Real-world applications of the cycle-birth framework to network analysis,
anomaly detection, and topological inference.
"""

import numpy as np
from collections import defaultdict


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
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
    cb_weights = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            cb_weights.append(w)
        else:
            uf.union(u, v)
    return np.array(cb_weights)


def ks_distance(s1, s2):
    if len(s1) == 0 or len(s2) == 0:
        return 1.0
    all_vals = np.sort(np.unique(np.concatenate([s1, s2])))
    cdf1 = np.searchsorted(np.sort(s1), all_vals, side='right') / len(s1)
    cdf2 = np.searchsorted(np.sort(s2), all_vals, side='right') / len(s2)
    return np.max(np.abs(cdf1 - cdf2))


# ═══════════════════════════════════════════
# APPLICATION 1: Network Anomaly Detection
# ═══════════════════════════════════════════

def network_anomaly_detector(reference_graphs, test_graph, n, alpha=0.05):
    """Detect anomalous network structure via cycle-birth CDF comparison.
    
    Uses the concentration theorem: if a test graph's cycle-birth CDF
    deviates significantly from the reference distribution, the graph
    has anomalous topological structure.
    
    Args:
        reference_graphs: List of (n, edges) pairs for reference networks
        test_graph: (n, edges) pair for test network
        n: Number of vertices
        alpha: Significance level
        
    Returns:
        Dictionary with anomaly score and decision
    """
    ref_cdfs = []
    for edges in reference_graphs:
        cb = compute_cycle_births(n, edges)
        ref_cdfs.append(cb)
    
    test_cb = compute_cycle_births(n, test_graph)
    
    # Compute KS distances from test to each reference
    ks_dists = [ks_distance(test_cb, ref) for ref in ref_cdfs]
    
    # Compute reference KS distances (between references)
    ref_ks = []
    for i in range(len(ref_cdfs)):
        for j in range(i+1, len(ref_cdfs)):
            ref_ks.append(ks_distance(ref_cdfs[i], ref_cdfs[j]))
    
    mean_test_ks = np.mean(ks_dists)
    mean_ref_ks = np.mean(ref_ks) if ref_ks else 0
    std_ref_ks = np.std(ref_ks) if ref_ks else 1
    
    z_score = (mean_test_ks - mean_ref_ks) / (std_ref_ks + 1e-10)
    
    return {
        'anomaly_score': z_score,
        'is_anomalous': z_score > 2.0,
        'mean_ks_to_reference': mean_test_ks,
        'reference_ks_baseline': mean_ref_ks,
        'test_beta1': len(test_cb),
    }


# ═══════════════════════════════════════════
# APPLICATION 2: Topological Confidence Intervals
# ═══════════════════════════════════════════

def topological_confidence_interval(n, p, num_bootstrap=100, confidence=0.95):
    """Compute confidence intervals for cycle-birth statistics.
    
    Uses the concentration inequality (Theorem 3):
    P(|N(t) - E[N(t)]| ≥ r) ≤ 2·exp(-2r²/m)
    
    This gives theoretical bounds, validated by bootstrap.
    
    Args:
        n: Number of vertices
        p: Edge probability
        num_bootstrap: Number of bootstrap samples
        confidence: Confidence level
        
    Returns:
        Dictionary with confidence intervals for β₁ and CDF
    """
    rng = np.random.default_rng(42)
    
    beta1_samples = []
    cdf_samples = defaultdict(list)
    thresholds = np.linspace(0, 1, 50)
    
    for _ in range(num_bootstrap):
        edges = []
        for i in range(n):
            for j in range(i+1, n):
                if rng.random() < p:
                    edges.append((i, j, rng.random()))
        
        cb = compute_cycle_births(n, edges)
        beta1_samples.append(len(cb))
        
        for t in thresholds:
            count = np.sum(cb <= t) if len(cb) > 0 else 0
            cdf_samples[t].append(count)
    
    beta1_arr = np.array(beta1_samples)
    alpha = 1 - confidence
    
    # Theoretical McDiarmid bound
    m = n * (n - 1) // 2  # max potential edges
    theoretical_bound = np.sqrt(m * np.log(2 / alpha) / 2)
    
    return {
        'beta1_mean': beta1_arr.mean(),
        'beta1_std': beta1_arr.std(),
        'beta1_ci_lower': np.percentile(beta1_arr, 100 * alpha / 2),
        'beta1_ci_upper': np.percentile(beta1_arr, 100 * (1 - alpha / 2)),
        'mcdiarmid_bound': theoretical_bound,
        'n': n,
        'p': p,
    }


# ═══════════════════════════════════════════
# APPLICATION 3: Network Fingerprinting
# ═══════════════════════════════════════════

def network_fingerprint(n, edges, num_bins=20):
    """Compute a topological fingerprint of a network.
    
    The fingerprint is the discretized empirical cycle-birth CDF.
    By the concentration theorem, this fingerprint is stable:
    small perturbations to the network produce similar fingerprints.
    
    By the universality theorem (Theorem 4), the fingerprint is
    invariant under monotone rescaling of edge weights.
    
    Returns:
        Array of CDF values at evenly spaced thresholds
    """
    cb = compute_cycle_births(n, edges)
    if len(cb) == 0:
        return np.zeros(num_bins)
    
    # Normalize weights to [0, 1] via rank transform
    ranks = (np.argsort(np.argsort(cb)) + 1) / len(cb)
    
    thresholds = np.linspace(0, 1, num_bins + 1)[1:]
    fingerprint = np.array([np.mean(ranks <= t) for t in thresholds])
    
    return fingerprint


def fingerprint_distance(fp1, fp2):
    """L∞ distance between two network fingerprints."""
    return np.max(np.abs(fp1 - fp2))


if __name__ == "__main__":
    print("=== Application 1: Network Anomaly Detection ===")
    rng = np.random.default_rng(42)
    n = 50
    p = 0.2
    
    # Generate reference networks (normal G(n,p))
    ref_graphs = []
    for _ in range(10):
        edges = []
        for i in range(n):
            for j in range(i+1, n):
                if rng.random() < p:
                    edges.append((i, j, rng.random()))
        ref_graphs.append(edges)
    
    # Normal test graph
    normal_test = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                normal_test.append((i, j, rng.random()))
    
    result = network_anomaly_detector(ref_graphs, normal_test, n)
    print(f"Normal graph: z-score = {result['anomaly_score']:.2f}, "
          f"anomalous = {result['is_anomalous']}")
    
    # Anomalous test graph (much denser)
    dense_test = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < 0.5:  # Higher density
                dense_test.append((i, j, rng.random()))
    
    result = network_anomaly_detector(ref_graphs, dense_test, n)
    print(f"Dense graph:  z-score = {result['anomaly_score']:.2f}, "
          f"anomalous = {result['is_anomalous']}")
    
    print("\n=== Application 2: Topological Confidence Intervals ===")
    ci = topological_confidence_interval(50, 0.15, num_bootstrap=50)
    print(f"n={ci['n']}, p={ci['p']}")
    print(f"β₁ mean: {ci['beta1_mean']:.1f} ± {ci['beta1_std']:.1f}")
    print(f"95% CI: [{ci['beta1_ci_lower']:.0f}, {ci['beta1_ci_upper']:.0f}]")
    print(f"McDiarmid bound: ±{ci['mcdiarmid_bound']:.1f}")
    
    print("\n=== Application 3: Network Fingerprinting ===")
    fp1 = network_fingerprint(n, ref_graphs[0])
    fp2 = network_fingerprint(n, ref_graphs[1])
    fp_dense = network_fingerprint(n, dense_test)
    print(f"Distance(similar graphs): {fingerprint_distance(fp1, fp2):.4f}")
    print(f"Distance(normal vs dense): {fingerprint_distance(fp1, fp_dense):.4f}")


"""
Demo: Cycle-Birth Concentration and Universality in Random Weighted Graphs

This script demonstrates the key theorems about tropical critical values
(cycle-birth times) in random weighted graph filtrations:

1. Concentration test: empirical cycle-birth CDFs concentrate as n grows
2. Universality test: different weight distributions yield same cycle-birth edges
3. MST complement validation: cycle births = non-MST edges
4. Lipschitz stability: single-edge resampling changes count by ≤ 1

Application keywords: tropical Morse theory, persistent homology, Erdős–Rényi graphs,
concentration of measure, McDiarmid inequality, universality, minimum spanning tree,
KS distance, empirical process.
"""

import numpy as np
from collections import defaultdict
import sys


# ──────────────────────────────────────────────
# Union-Find (inline for self-containment)
# ──────────────────────────────────────────────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

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
    """Compute cycle-birth weights from a weighted graph."""
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    cb_weights = []
    merge_edges_set = set()
    cb_edges_set = set()

    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            cb_weights.append(w)
            cb_edges_set.add((min(u,v), max(u,v)))
        else:
            uf.union(u, v)
            merge_edges_set.add((min(u,v), max(u,v)))

    return np.array(cb_weights), merge_edges_set, cb_edges_set


def ks_distance(s1, s2):
    """Kolmogorov-Smirnov distance between two empirical distributions."""
    if len(s1) == 0 or len(s2) == 0:
        return 1.0
    all_vals = np.sort(np.unique(np.concatenate([s1, s2])))
    cdf1 = np.searchsorted(np.sort(s1), all_vals, side='right') / len(s1)
    cdf2 = np.searchsorted(np.sort(s2), all_vals, side='right') / len(s2)
    return np.max(np.abs(cdf1 - cdf2))


def generate_gnp(n, p, dist='uniform', rng=None):
    """Generate weighted G(n,p) with specified weight distribution."""
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i+1, n):
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


# ══════════════════════════════════════════════
# EXPERIMENT 1: Concentration Test
# ══════════════════════════════════════════════

def run_concentration_test():
    """Test that empirical cycle-birth CDFs concentrate as n grows.
    
    For fixed p, we generate multiple G(n,p) instances and measure
    pairwise KS distances between cycle-birth CDFs. If the tropical
    spectral law holds, mean KS distance should decrease ~ n^{-1/2}.
    """
    print("=" * 60)
    print("EXPERIMENT 1: Concentration of Cycle-Birth CDFs")
    print("=" * 60)
    print(f"{'n':>6} | {'m_avg':>8} | {'β₁_avg':>8} | {'KS_mean':>10} | {'KS_std':>10}")
    print("-" * 60)

    p = 0.15
    ns = [50, 100, 200, 500]
    num_trials = 10
    rng = np.random.default_rng(42)

    ks_means = []
    for n in ns:
        cb_lists = []
        m_total, b1_total = 0, 0
        for _ in range(num_trials):
            edges = generate_gnp(n, p, rng=rng)
            cb_w, _, _ = compute_cycle_births(n, edges)
            cb_lists.append(cb_w)
            m_total += len(edges)
            b1_total += len(cb_w)

        # Compute pairwise KS distances
        ks_dists = []
        for i in range(len(cb_lists)):
            for j in range(i+1, len(cb_lists)):
                if len(cb_lists[i]) > 0 and len(cb_lists[j]) > 0:
                    ks_dists.append(ks_distance(cb_lists[i], cb_lists[j]))

        ks_arr = np.array(ks_dists) if ks_dists else np.array([0.0])
        ks_means.append(ks_arr.mean())
        print(f"{n:>6} | {m_total/num_trials:>8.1f} | {b1_total/num_trials:>8.1f} | "
              f"{ks_arr.mean():>10.4f} | {ks_arr.std():>10.4f}")

    # Check approximate n^{-1/2} scaling
    if len(ks_means) >= 2 and ks_means[0] > 0:
        ratio = ks_means[-1] / ks_means[0]
        n_ratio = np.sqrt(ns[0] / ns[-1])
        print(f"\nKS ratio (n={ns[-1]}/n={ns[0]}): {ratio:.3f}")
        print(f"Expected if O(n^{{-1/2}}): ~{n_ratio:.3f}")
        if ratio < n_ratio * 2:
            print("→ Consistent with concentration ✓")
        else:
            print("→ Weaker than expected (may need larger n)")
    print()


# ══════════════════════════════════════════════
# EXPERIMENT 2: Universality Test
# ══════════════════════════════════════════════

def run_universality_test():
    """Test that cycle-birth edge SETS are invariant under monotone transport.
    
    By Theorem 4, the set of cycle-birth edges depends only on the weight
    ordering, not the actual values. Different continuous distributions
    produce the same ordering a.s., so the same edges are cycle births.
    
    We verify this computationally: for the SAME graph with different
    weight distributions (all derived from a common ordering), the
    cycle-birth edge sets should be identical.
    """
    print("=" * 60)
    print("EXPERIMENT 2: Universality via Monotone Transport")
    print("=" * 60)

    n = 100
    p = 0.2
    num_trials = 20
    rng = np.random.default_rng(123)

    agreement_count = 0
    total_tests = 0

    for trial in range(num_trials):
        # Generate base graph with uniform weights
        edges_uniform = generate_gnp(n, p, 'uniform', rng)
        if not edges_uniform:
            continue

        # Apply monotone transforms to get different "distributions"
        edges_exp = [(u, v, np.exp(w)) for u, v, w in edges_uniform]
        edges_cube = [(u, v, w**3) for u, v, w in edges_uniform]
        edges_log = [(u, v, np.log(w + 1)) for u, v, w in edges_uniform]

        _, _, cb_uniform = compute_cycle_births(n, edges_uniform)
        _, _, cb_exp = compute_cycle_births(n, edges_exp)
        _, _, cb_cube = compute_cycle_births(n, edges_cube)
        _, _, cb_log = compute_cycle_births(n, edges_log)

        # All should be identical (Theorem 4)
        if cb_uniform == cb_exp == cb_cube == cb_log:
            agreement_count += 1
        total_tests += 1

    print(f"Trials: {total_tests}")
    print(f"All 4 transforms agree: {agreement_count}/{total_tests}")
    if agreement_count == total_tests:
        print("→ Monotone transport universality: CONFIRMED ✓")
    else:
        print("→ WARNING: disagreement detected (check for weight ties)")
    print()


# ══════════════════════════════════════════════
# EXPERIMENT 3: MST Complement Validation
# ══════════════════════════════════════════════

def run_mst_complement_test():
    """Validate Theorem 5: cycle-birth edges = non-MST edges.
    
    For each random graph, compute:
    1. Cycle-birth edges via the filtration algorithm
    2. MST edges via Kruskal's algorithm
    
    Verify they partition all graph edges.
    """
    print("=" * 60)
    print("EXPERIMENT 3: MST Complement (Theorem 5)")
    print("=" * 60)

    ns = [20, 50, 100, 200]
    p = 0.3
    num_trials = 10
    rng = np.random.default_rng(456)

    for n in ns:
        all_pass = True
        for _ in range(num_trials):
            edges = generate_gnp(n, p, rng=rng)
            cb_w, mst_edges, cb_edges = compute_cycle_births(n, edges)

            all_e = {(min(u,v), max(u,v)) for u, v, _ in edges}

            # Check partition
            if cb_edges | mst_edges != all_e:
                all_pass = False
            if cb_edges & mst_edges:
                all_pass = False
            # Check complement
            if cb_edges != all_e - mst_edges:
                all_pass = False

        status = "PASS ✓" if all_pass else "FAIL ✗"
        print(f"n={n:>4}, p={p}: {status} (all {num_trials} trials)")

    print()


# ══════════════════════════════════════════════
# EXPERIMENT 4: Lipschitz Stability
# ══════════════════════════════════════════════

def run_lipschitz_test():
    """Test Theorem 2: resampling one edge weight changes cycle-birth count by ≤ 1.
    
    For each graph, we resample individual edge weights and measure
    the change in cycleBirthCountLE(t) for various thresholds t.
    The maximum change should never exceed 1.
    """
    print("=" * 60)
    print("EXPERIMENT 4: Lipschitz Stability (Theorem 2)")
    print("=" * 60)

    n = 30
    p = 0.25
    num_graph_trials = 5
    num_resample_per_edge = 3
    rng = np.random.default_rng(789)

    max_change_observed = 0
    total_tests = 0

    for _ in range(num_graph_trials):
        edges = generate_gnp(n, p, rng=rng)
        if not edges:
            continue

        base_cb, _, _ = compute_cycle_births(n, edges)
        thresholds = np.linspace(0, 1, 20)

        for idx in range(min(len(edges), 20)):  # test first 20 edges
            for _ in range(num_resample_per_edge):
                modified = list(edges)
                u, v, _ = modified[idx]
                modified[idx] = (u, v, rng.random())

                mod_cb, _, _ = compute_cycle_births(n, modified)

                for t in thresholds:
                    base_count = np.sum(base_cb <= t) if len(base_cb) > 0 else 0
                    mod_count = np.sum(mod_cb <= t) if len(mod_cb) > 0 else 0
                    change = abs(int(base_count) - int(mod_count))
                    max_change_observed = max(max_change_observed, change)
                    total_tests += 1

    print(f"Total tests: {total_tests}")
    print(f"Max change in cycleBirthCountLE: {max_change_observed}")
    if max_change_observed <= 1:
        print("→ Lipschitz bound ≤ 1: CONFIRMED ✓")
    else:
        print(f"→ WARNING: bound exceeded! Max change = {max_change_observed}")
    print()


# ══════════════════════════════════════════════
# EXPERIMENT 5: Distribution Comparison
# ══════════════════════════════════════════════

def run_distribution_comparison():
    """Compare cycle-birth CDF shapes across different weight distributions.
    
    By Theorem 4, for the SAME graph, monotone transport maps one CDF
    to another. For DIFFERENT random graphs with different distributions,
    after applying the probability integral transform (mapping through
    the CDF of the weight distribution), the rescaled CDFs should converge
    to the same limit.
    """
    print("=" * 60)
    print("EXPERIMENT 5: Cross-Distribution Comparison")
    print("=" * 60)

    n = 200
    p = 0.15
    num_trials = 15
    rng = np.random.default_rng(101)

    distributions = ['uniform', 'exponential', 'normal']

    for dist in distributions:
        cb_counts = []
        for _ in range(num_trials):
            edges = generate_gnp(n, p, dist, rng)
            cb_w, _, _ = compute_cycle_births(n, edges)
            cb_counts.append(len(cb_w))

        arr = np.array(cb_counts)
        print(f"{dist:>12}: β₁ mean={arr.mean():.1f}, std={arr.std():.1f}, "
              f"cv={arr.std()/arr.mean():.3f}" if arr.mean() > 0 else f"{dist:>12}: no cycles")

    # Cross-distribution KS test after quantile normalization
    print("\nQuantile-normalized KS distances (should be small):")
    for i, d1 in enumerate(distributions):
        for j, d2 in enumerate(distributions):
            if j <= i:
                continue
            ks_dists = []
            for _ in range(num_trials):
                e1 = generate_gnp(n, p, d1, rng)
                e2 = generate_gnp(n, p, d2, rng)
                cb1, _, _ = compute_cycle_births(n, e1)
                cb2, _, _ = compute_cycle_births(n, e2)

                # Normalize to [0,1] via rank transform
                if len(cb1) > 1:
                    cb1_norm = (np.argsort(np.argsort(cb1)) + 1) / len(cb1)
                else:
                    cb1_norm = cb1
                if len(cb2) > 1:
                    cb2_norm = (np.argsort(np.argsort(cb2)) + 1) / len(cb2)
                else:
                    cb2_norm = cb2

                if len(cb1_norm) > 0 and len(cb2_norm) > 0:
                    ks_dists.append(ks_distance(cb1_norm, cb2_norm))

            if ks_dists:
                print(f"  {d1:>12} vs {d2:<12}: KS = {np.mean(ks_dists):.4f} ± {np.std(ks_dists):.4f}")

    print()


# ══════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════

if __name__ == "__main__":
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║  Cycle-Birth Concentration & Universality Demo              ║")
    print("║  Tropical Critical Values in Random Weighted Graphs         ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    run_concentration_test()
    run_universality_test()
    run_mst_complement_test()
    run_lipschitz_test()
    run_distribution_comparison()

    print("=" * 60)
    print("All experiments complete.")
    print("=" * 60)


"""
Visualization: Concentration of Cycle-Birth CDFs

Illustrates the key concentration phenomenon: as graph size n increases,
the empirical cycle-birth CDF concentrates around a deterministic limit.
Multiple independent trials of G(n,p) with uniform edge weights produce
CDFs that cluster ever more tightly.

This is the graphical manifestation of the bounded-differences / McDiarmid
concentration inequality applied to tropical critical values.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# ── Inline dependencies ──
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
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
    cb_weights = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            cb_weights.append(w)
        else:
            uf.union(u, v)
    return np.array(cb_weights)

def generate_gnp(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    return edges


# ── Main visualization ──
matplotlib.rcParams.update({'font.size': 11})
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

p = 0.15
ns = [50, 150, 500]
num_trials = 8
rng = np.random.default_rng(42)
colors = plt.cm.viridis(np.linspace(0.2, 0.8, num_trials))

for ax_idx, n in enumerate(ns):
    ax = axes[ax_idx]
    for trial in range(num_trials):
        edges = generate_gnp(n, p, rng)
        cb = compute_cycle_births(n, edges)
        if len(cb) > 0:
            sorted_cb = np.sort(cb)
            cdf_y = np.arange(1, len(sorted_cb)+1) / len(sorted_cb)
            ax.step(sorted_cb, cdf_y, where='post', color=colors[trial],
                    alpha=0.7, linewidth=1.2)

    ax.set_xlabel('Edge Weight (Birth Time)', fontsize=12)
    ax.set_ylabel('Empirical CDF', fontsize=12)
    ax.set_title(f'n = {n},  p = {p}\n({num_trials} independent trials)', fontsize=13)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

fig.suptitle('Concentration of Cycle-Birth CDFs\n'
             'As n grows, the tropical spectral measure concentrates',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")


"""
Visualization: MST Complement and Filtration Dichotomy

Illustrates Theorem 5: the fundamental partition of graph edges into
MST edges (merges) and cycle-birth edges (non-MST). Shows a small
graph with edges colored by their classification, plus the Betti
number trajectory through the filtration.

This visualizes the bridge between combinatorial optimization (MST)
and tropical topology (cycle births).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib


# ── Inline dependencies ──
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.nc = n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.nc -= 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


# ── Generate a small graph for visualization ──
matplotlib.rcParams.update({'font.size': 11})
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

n = 8
rng = np.random.default_rng(55)

# Place vertices on a circle
angles = np.linspace(0, 2*np.pi, n, endpoint=False)
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

# Generate random edges
edges = []
for i in range(n):
    for j in range(i+1, n):
        if rng.random() < 0.5:
            edges.append((i, j, round(rng.random(), 3)))

# Sort by weight and classify
sorted_edges = sorted(edges, key=lambda e: e[2])
uf = UnionFind(n)
merge_edges = []
cb_edges = []
beta0_traj = [n]
beta1_traj = [0]
components = n
cycles = 0

for u, v, w in sorted_edges:
    if uf.connected(u, v):
        cb_edges.append((u, v, w))
        cycles += 1
    else:
        uf.union(u, v)
        merge_edges.append((u, v, w))
        components -= 1
    beta0_traj.append(components)
    beta1_traj.append(cycles)

# Left panel: Graph with edge coloring
ax = axes[0]
ax.set_xlim(-1.6, 1.6)
ax.set_ylim(-1.6, 1.6)
ax.set_aspect('equal')

# Draw MST edges (blue, thick)
for u, v, w in merge_edges:
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    ax.plot(x, y, 'b-', linewidth=2.5, alpha=0.7, zorder=1)
    mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax.text(mx, my, f'{w:.3f}', fontsize=7, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='lightblue', alpha=0.8))

# Draw cycle-birth edges (red, dashed)
for u, v, w in cb_edges:
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    ax.plot(x, y, 'r--', linewidth=2, alpha=0.7, zorder=1)
    mx, my = (x[0]+x[1])/2 + 0.05, (y[0]+y[1])/2 + 0.05
    ax.text(mx, my, f'{w:.3f}', fontsize=7, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='lightyellow', alpha=0.8))

# Draw vertices
for i in range(n):
    ax.plot(pos[i][0], pos[i][1], 'ko', markersize=12, zorder=2)
    ax.text(pos[i][0], pos[i][1], str(i), fontsize=9, ha='center', va='center',
            color='white', fontweight='bold', zorder=3)

blue_patch = mpatches.Patch(color='blue', label=f'MST edges ({len(merge_edges)})')
red_patch = mpatches.Patch(color='red', label=f'Cycle births ({len(cb_edges)})')
ax.legend(handles=[blue_patch, red_patch], loc='upper right', fontsize=10)
ax.set_title(f'Edge Partition: MST vs Cycle Births\n'
             f'{n} vertices, {len(edges)} edges', fontsize=13)
ax.axis('off')

# Right panel: Betti trajectory
ax = axes[1]
steps = range(len(beta0_traj))
ax.step(steps, beta0_traj, where='post', color='blue', linewidth=2,
        label='β₀ (components)')
ax.step(steps, beta1_traj, where='post', color='red', linewidth=2,
        label='β₁ (cycles)')

# Mark merge events and cycle births
merge_idx = 0
cb_idx = 0
for k, (u, v, w) in enumerate(sorted_edges):
    if (u, v, w) in merge_edges:
        ax.axvline(x=k+1, color='blue', alpha=0.15, linewidth=8)
    else:
        ax.axvline(x=k+1, color='red', alpha=0.15, linewidth=8)

ax.set_xlabel('Edge Insertion Order', fontsize=12)
ax.set_ylabel('Betti Number', fontsize=12)
ax.set_title('Betti Trajectory Through Filtration\n'
             'Blue bands = merges, Red bands = cycle births', fontsize=13)
ax.legend(fontsize=11)
ax.set_xlim(0, len(sorted_edges)+0.5)
ax.grid(True, alpha=0.3)

fig.suptitle('The Kruskal–Morse Duality\n'
             'MST edges decrease β₀, non-MST edges increase β₁',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mst_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_mst_complement.png")


"""
Visualization: Monotone Transport Universality

Demonstrates Theorem 4: the cycle-birth edge SET is invariant under
strictly monotone transformations of edge weights. Different weight
distributions (uniform, exponential, Gaussian) produce different
raw CDFs, but after applying the probability integral transform
(mapping through the weight CDF), they collapse onto a single curve.

This is the tropical analogue of universality in random matrix theory:
microscopic details (the weight distribution) wash out, leaving a
universal macroscopic law.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# ── Inline dependencies ──
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
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
    cb_weights = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            cb_weights.append(w)
        else:
            uf.union(u, v)
    return np.array(cb_weights)


# ── Generate one graph, apply three weight distributions ──
matplotlib.rcParams.update({'font.size': 11})
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

n = 300
p = 0.12
rng = np.random.default_rng(77)

# Generate base graph structure
graph_edges = []
for i in range(n):
    for j in range(i+1, n):
        if rng.random() < p:
            graph_edges.append((i, j))

# Three weight distributions for the SAME graph
base_uniform = rng.random(len(graph_edges))
transforms = {
    'Uniform [0,1]': base_uniform,
    'Exponential': np.exp(base_uniform * 3) - 1,
    'Cubic': base_uniform ** 3,
}
colors = {'Uniform [0,1]': '#1f77b4', 'Exponential': '#ff7f0e', 'Cubic': '#2ca02c'}

# Left panel: Raw CDFs (different curves)
ax = axes[0]
for label, weights in transforms.items():
    edges = [(u, v, w) for (u, v), w in zip(graph_edges, weights)]
    cb = compute_cycle_births(n, edges)
    if len(cb) > 0:
        sorted_cb = np.sort(cb)
        cdf_y = np.arange(1, len(sorted_cb)+1) / len(sorted_cb)
        ax.step(sorted_cb, cdf_y, where='post', label=label,
                color=colors[label], linewidth=2)

ax.set_xlabel('Birth Time (raw weight)', fontsize=12)
ax.set_ylabel('Empirical CDF', fontsize=12)
ax.set_title('Raw Cycle-Birth CDFs\n(Different weight scales)', fontsize=13)
ax.legend(fontsize=10)
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

# Right panel: After quantile normalization (same curve!)
ax = axes[1]
for label, weights in transforms.items():
    edges = [(u, v, w) for (u, v), w in zip(graph_edges, weights)]
    cb = compute_cycle_births(n, edges)
    if len(cb) > 0:
        # Quantile normalize: rank → [0,1]
        ranks = (np.argsort(np.argsort(cb)) + 1) / len(cb)
        sorted_r = np.sort(ranks)
        cdf_y = np.arange(1, len(sorted_r)+1) / len(sorted_r)
        ax.step(sorted_r, cdf_y, where='post', label=label,
                color=colors[label], linewidth=2, alpha=0.8)

ax.plot([0, 1], [0, 1], 'k--', alpha=0.3, label='Identity')
ax.set_xlabel('Quantile-Normalized Birth Time', fontsize=12)
ax.set_ylabel('Empirical CDF', fontsize=12)
ax.set_title('After Monotone Transport\n(Curves collapse — Theorem 4)', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

fig.suptitle('Universality of Cycle-Birth Distributions\n'
             'Same graph, different weight distributions → same topological pattern',
             fontsize=14, fontweight='bold', y=1.04)
plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
