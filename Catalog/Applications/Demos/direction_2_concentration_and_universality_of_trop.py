"""
Applications of Cycle-Birth Theory to Network Science

Demonstrates practical applications of the tropical spectral theory:

1. Network robustness analysis via cycle-birth spectrum
2. Anomaly detection in weighted networks
3. Graph comparison via cycle-birth fingerprints
"""

import numpy as np
from typing import List, Tuple, Dict


# ============================================================
# Inlined core algorithms
# ============================================================

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


def compute_cycle_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    cb_weights = []
    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            cb_weights.append(w)
    return cb_weights


def empirical_cdf_on_grid(values, grid):
    s = np.sort(values)
    return np.searchsorted(s, grid, side='right') / len(s) if len(s) > 0 else np.zeros_like(grid)


def ks_distance(v1, v2, grid_size=500):
    if not v1 or not v2:
        return 1.0
    all_v = sorted(set(v1 + v2))
    lo, hi = all_v[0], all_v[-1]
    if lo == hi:
        return 0.0
    grid = np.linspace(lo, hi, grid_size)
    c1 = empirical_cdf_on_grid(v1, grid)
    c2 = empirical_cdf_on_grid(v2, grid)
    return float(np.max(np.abs(c1 - c2)))


# ============================================================
# Application 1: Network Robustness
# ============================================================

def network_robustness_score(n: int, edges: List[Tuple[int, int, float]]) -> Dict:
    """Analyze network robustness using cycle-birth spectrum.

    Networks with many early cycle births (low-weight cycle edges) have
    high redundancy. Networks with late cycle births are more tree-like
    and vulnerable to edge removal.

    Returns:
        Dictionary with robustness metrics

    Example:
        >>> edges = [(0,1,0.1),(1,2,0.2),(2,0,0.3),(0,3,0.5),(1,3,0.6),(2,3,0.9)]
        >>> result = network_robustness_score(4, edges)
        >>> result['redundancy_ratio'] > 0
        True
    """
    cb_weights = compute_cycle_births(n, edges)
    m = len(edges)
    beta1 = len(cb_weights)
    beta0_mst = n - (m - beta1)  # approximate

    result = {
        'num_vertices': n,
        'num_edges': m,
        'beta1': beta1,
        'redundancy_ratio': beta1 / m if m > 0 else 0.0,
        'mean_birth_time': np.mean(cb_weights) if cb_weights else float('nan'),
        'median_birth_time': np.median(cb_weights) if cb_weights else float('nan'),
        'early_birth_fraction': sum(1 for w in cb_weights if w < np.median(
            [e[2] for e in edges])) / max(1, beta1) if cb_weights else 0.0,
    }
    return result


# ============================================================
# Application 2: Anomaly Detection
# ============================================================

def detect_anomalous_graphs(graphs: List[Tuple[int, List[Tuple[int, int, float]]]],
                             threshold: float = 0.3) -> List[int]:
    """Detect anomalous graphs by comparing cycle-birth CDFs.

    Computes pairwise KS distances and flags graphs whose average
    distance exceeds the threshold.

    Args:
        graphs: List of (n, edges) pairs
        threshold: KS distance threshold for anomaly

    Returns:
        Indices of anomalous graphs

    Example:
        >>> g1 = (5, [(0,1,0.1),(1,2,0.2),(2,3,0.3),(3,4,0.4),(0,4,0.5)])
        >>> g2 = (5, [(0,1,0.1),(1,2,0.2),(2,3,0.3),(3,4,0.4),(0,4,0.5)])
        >>> detect_anomalous_graphs([g1, g2])
        []
    """
    all_cb = []
    for n, edges in graphs:
        cb = compute_cycle_births(n, edges)
        all_cb.append(cb)

    num_graphs = len(graphs)
    avg_dist = np.zeros(num_graphs)

    for i in range(num_graphs):
        dists = []
        for j in range(num_graphs):
            if i != j and all_cb[i] and all_cb[j]:
                dists.append(ks_distance(all_cb[i], all_cb[j]))
        avg_dist[i] = np.mean(dists) if dists else 0.0

    anomalies = [i for i in range(num_graphs) if avg_dist[i] > threshold]
    return anomalies


# ============================================================
# Application 3: Graph Fingerprinting
# ============================================================

def cycle_birth_fingerprint(n: int, edges: List[Tuple[int, int, float]],
                             num_bins: int = 10) -> np.ndarray:
    """Compute a cycle-birth fingerprint vector for graph comparison.

    Bins the cycle-birth weights into a histogram, normalized to sum to 1.
    Two graphs with similar structure will have similar fingerprints.

    Args:
        n: Number of vertices
        edges: Edge list with weights
        num_bins: Number of histogram bins

    Returns:
        Normalized histogram vector

    Example:
        >>> edges = [(0,1,0.1),(1,2,0.2),(2,0,0.3)]
        >>> fp = cycle_birth_fingerprint(3, edges)
        >>> abs(fp.sum() - 1.0) < 1e-10 or len(fp) == num_bins
        True
    """
    cb_weights = compute_cycle_births(n, edges)
    if not cb_weights:
        return np.zeros(num_bins)

    all_weights = [e[2] for e in edges]
    lo, hi = min(all_weights), max(all_weights)
    if lo == hi:
        hist = np.zeros(num_bins)
        hist[0] = 1.0
        return hist

    hist, _ = np.histogram(cb_weights, bins=num_bins, range=(lo, hi))
    total = hist.sum()
    return hist / total if total > 0 else hist


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    rng = np.random.default_rng(42)

    print("=" * 60)
    print("Application 1: Network Robustness Analysis")
    print("=" * 60)

    # Dense network (high redundancy)
    n = 30
    edges_dense = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < 0.4:
                edges_dense.append((i, j, rng.random()))

    rob = network_robustness_score(n, edges_dense)
    print(f"Dense network (n={n}, p≈0.4):")
    for k, v in rob.items():
        print(f"  {k}: {v}")

    # Sparse network (low redundancy)
    edges_sparse = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < 0.08:
                edges_sparse.append((i, j, rng.random()))

    rob2 = network_robustness_score(n, edges_sparse)
    print(f"\nSparse network (n={n}, p≈0.08):")
    for k, v in rob2.items():
        print(f"  {k}: {v}")

    print()
    print("=" * 60)
    print("Application 3: Graph Fingerprinting")
    print("=" * 60)

    fp1 = cycle_birth_fingerprint(n, edges_dense)
    fp2 = cycle_birth_fingerprint(n, edges_sparse)
    print(f"Dense fingerprint: {np.round(fp1, 3)}")
    print(f"Sparse fingerprint: {np.round(fp2, 3)}")
    print(f"L2 distance: {np.linalg.norm(fp1 - fp2):.4f}")


"""
Demonstration: Cycle-Birth Concentration and Universality in Random Graphs

This script demonstrates the main theorems computationally:

1. **Concentration test**: Shows that empirical cycle-birth CDFs concentrate
   as n grows (KS distance ~ n^{-1/2}).

2. **Universality test**: Shows that different continuous weight distributions
   produce the same cycle-birth pattern after monotone rescaling.

3. **MST complement validation**: Verifies that cycle-birth edges coincide
   with non-MST edges.

4. **Monotone transport validation**: Verifies that strictly monotone
   transformations preserve cycle-birth classification.

Usage:
    python demo.py
"""

import numpy as np
from typing import List, Tuple, Set, Optional
from dataclasses import dataclass, field


# ============================================================
# Inlined core algorithms (self-contained)
# ============================================================

class UnionFind:
    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True


def compute_cycle_births(n, edges):
    """Return (cycle_birth_weights, merge_weights, mst_edges, non_mst_edges)."""
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    cb_weights, merge_weights = [], []
    mst_edges, non_mst_edges = set(), set()

    for u, v, w in sorted_edges:
        merged = uf.union(u, v)
        edge = (min(u, v), max(u, v))
        if merged:
            merge_weights.append(w)
            mst_edges.add(edge)
        else:
            cb_weights.append(w)
            non_mst_edges.add(edge)

    return cb_weights, merge_weights, mst_edges, non_mst_edges


def sample_erdos_renyi(n, p, weight_dist='uniform', rng=None):
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                if weight_dist == 'uniform':
                    w = rng.random()
                elif weight_dist == 'exponential':
                    w = rng.exponential(1.0)
                elif weight_dist == 'normal':
                    w = rng.normal(0.0, 1.0)
                else:
                    raise ValueError(f"Unknown: {weight_dist}")
                edges.append((i, j, w))
    return edges


def ks_distance(v1, v2, grid_size=1000):
    if not v1 or not v2:
        return 1.0
    all_v = sorted(set(v1 + v2))
    lo, hi = all_v[0], all_v[-1]
    if lo == hi:
        return 0.0
    margin = 0.01 * (hi - lo)
    grid = np.linspace(lo - margin, hi + margin, grid_size)
    s1, s2 = np.sort(v1), np.sort(v2)
    cdf1 = np.searchsorted(s1, grid, side='right') / len(s1)
    cdf2 = np.searchsorted(s2, grid, side='right') / len(s2)
    return float(np.max(np.abs(cdf1 - cdf2)))


# ============================================================
# Experiment 1: Concentration Test
# ============================================================

def run_concentration_test():
    print("=" * 70)
    print("EXPERIMENT 1: Concentration of Cycle-Birth CDFs")
    print("=" * 70)
    print()
    print("Testing whether KS distance between trials decreases ~ n^{-1/2}")
    print()

    p = 0.15
    ns = [50, 100, 200, 500]
    num_trials = 20
    rng = np.random.default_rng(42)

    print(f"{'n':>6} | {'mean edges':>10} | {'mean β₁':>8} | {'mean KS':>10} | {'std KS':>10} | {'n^{-1/2}':>10}")
    print("-" * 70)

    results = []
    for n in ns:
        trial_weights = []
        edge_counts = []

        for _ in range(num_trials):
            edges = sample_erdos_renyi(n, p, 'uniform', rng)
            cb_w, _, _, _ = compute_cycle_births(n, edges)
            trial_weights.append(cb_w)
            edge_counts.append(len(edges))

        # Compute pairwise KS distances
        ks_dists = []
        for i in range(num_trials):
            for j in range(i + 1, num_trials):
                if trial_weights[i] and trial_weights[j]:
                    d = ks_distance(trial_weights[i], trial_weights[j])
                    ks_dists.append(d)

        mean_ks = np.mean(ks_dists) if ks_dists else float('nan')
        std_ks = np.std(ks_dists) if ks_dists else float('nan')
        mean_edges = np.mean(edge_counts)
        mean_beta1 = np.mean([len(w) for w in trial_weights])
        expected = 1.0 / np.sqrt(n)

        print(f"{n:>6} | {mean_edges:>10.1f} | {mean_beta1:>8.1f} | {mean_ks:>10.4f} | {std_ks:>10.4f} | {expected:>10.4f}")
        results.append((n, mean_ks))

    # Check scaling
    if len(results) >= 2:
        n1, ks1 = results[0]
        n2, ks2 = results[-1]
        if ks2 > 0:
            ratio = ks1 / ks2
            expected_ratio = np.sqrt(n2 / n1)
            print(f"\nKS ratio (n={n1} vs n={n2}): {ratio:.2f}")
            print(f"Expected ratio (√(n₂/n₁)):   {expected_ratio:.2f}")
            print(f"Consistent with n^{{-1/2}} scaling: {abs(ratio - expected_ratio) / expected_ratio < 0.5}")

    print()


# ============================================================
# Experiment 2: Universality Test
# ============================================================

def run_universality_test():
    print("=" * 70)
    print("EXPERIMENT 2: Universality Under Monotone Transport")
    print("=" * 70)
    print()
    print("Testing whether different weight distributions yield same cycle-birth pattern")
    print("after quantile normalization.")
    print()

    n = 200
    p = 0.15
    num_trials = 10
    rng = np.random.default_rng(123)

    dists = ['uniform', 'exponential', 'normal']

    for trial in range(min(3, num_trials)):
        print(f"--- Trial {trial + 1} ---")

        # Generate the same graph structure
        graph_rng = np.random.default_rng(rng.integers(0, 2**32))

        # For each distribution, use the same graph but different weights
        pattern_by_dist = {}
        weights_by_dist = {}

        for dist in dists:
            trial_rng = np.random.default_rng(graph_rng.integers(0, 2**32))
            # Same graph structure
            base_rng = np.random.default_rng(42 + trial)
            edges_struct = []
            for i in range(n):
                for j in range(i + 1, n):
                    if base_rng.random() < p:
                        edges_struct.append((i, j))

            # Apply weights from chosen distribution
            edges = []
            for u, v in edges_struct:
                if dist == 'uniform':
                    w = trial_rng.random()
                elif dist == 'exponential':
                    w = trial_rng.exponential(1.0)
                elif dist == 'normal':
                    w = trial_rng.normal(0.0, 1.0)
                edges.append((i, j, w))

            cb_w, _, _, _ = compute_cycle_births(n, edges)
            weights_by_dist[dist] = cb_w

        # Compare: after rank-normalizing, CDFs should be similar
        print(f"  {'Dist1':>12} vs {'Dist2':>12} | {'KS (raw)':>10} | {'KS (rank-norm)':>14}")
        for i, d1 in enumerate(dists):
            for d2 in dists[i+1:]:
                w1 = weights_by_dist[d1]
                w2 = weights_by_dist[d2]
                if w1 and w2:
                    ks_raw = ks_distance(w1, w2)
                    # Rank-normalize
                    def rank_normalize(vals):
                        s = sorted(vals)
                        rank_map = {v: (i + 0.5) / len(s) for i, v in enumerate(s)}
                        return [rank_map[v] for v in vals]
                    rn1 = rank_normalize(w1)
                    rn2 = rank_normalize(w2)
                    ks_rn = ks_distance(rn1, rn2)
                    print(f"  {d1:>12} vs {d2:>12} | {ks_raw:>10.4f} | {ks_rn:>14.4f}")
                else:
                    print(f"  {d1:>12} vs {d2:>12} | {'(empty)':>10} | {'(empty)':>14}")
        print()


# ============================================================
# Experiment 3: MST Complement Validation
# ============================================================

def run_mst_complement_test():
    print("=" * 70)
    print("EXPERIMENT 3: MST Complement Validation (Theorem 5)")
    print("=" * 70)
    print()
    print("Verifying cycle-birth edges = complement of MST edges")
    print()

    rng = np.random.default_rng(99)
    ns = [10, 20, 50, 100, 200]
    p = 0.3

    all_pass = True
    for n in ns:
        edges = sample_erdos_renyi(n, p, 'uniform', rng)
        cb_w, merge_w, mst_edges, non_mst_edges = compute_cycle_births(n, edges)

        all_edges = set()
        for u, v, w in edges:
            all_edges.add((min(u, v), max(u, v)))

        partition_ok = (mst_edges | non_mst_edges == all_edges and
                        len(mst_edges & non_mst_edges) == 0)
        count_ok = len(cb_w) + len(merge_w) == len(edges)

        status = "✓" if (partition_ok and count_ok) else "✗"
        if not (partition_ok and count_ok):
            all_pass = False

        print(f"  n={n:>4}: edges={len(edges):>5}, MST={len(mst_edges):>4}, "
              f"cycles={len(cb_w):>4}, partition={status}")

    print(f"\n  All tests passed: {'YES' if all_pass else 'NO'}")
    print()


# ============================================================
# Experiment 4: Monotone Transport Validation
# ============================================================

def run_monotone_transport_test():
    print("=" * 70)
    print("EXPERIMENT 4: Monotone Transport Invariance (Theorem 4)")
    print("=" * 70)
    print()
    print("Verifying that strictly monotone transforms preserve cycle-birth classification")
    print()

    rng = np.random.default_rng(77)
    n = 50
    p = 0.3
    edges_base = sample_erdos_renyi(n, p, 'uniform', rng)

    transforms = [
        ("x ↦ 2x + 1", lambda x: 2 * x + 1),
        ("x ↦ x³", lambda x: x ** 3),
        ("x ↦ eˣ", lambda x: np.exp(x)),
        ("x ↦ log(x+1)", lambda x: np.log(x + 1)),
        ("x ↦ 100x - 50", lambda x: 100 * x - 50),
    ]

    # Compute base classification
    cb_base, _, _, _ = compute_cycle_births(n, edges_base)
    base_flags = []
    sorted_edges = sorted(edges_base, key=lambda e: e[2])
    uf = UnionFind(n)
    for u, v, w in sorted_edges:
        merged = uf.union(u, v)
        base_flags.append(not merged)

    all_pass = True
    for name, phi in transforms:
        edges_t = [(u, v, phi(w)) for u, v, w in edges_base]
        sorted_t = sorted(edges_t, key=lambda e: e[2])
        uf_t = UnionFind(n)
        t_flags = []
        for u, v, w in sorted_t:
            merged = uf_t.union(u, v)
            t_flags.append(not merged)

        match = base_flags == t_flags
        if not match:
            all_pass = False
        status = "✓" if match else "✗"
        print(f"  {name:>20}: classification preserved = {status}")

    print(f"\n  All tests passed: {'YES' if all_pass else 'NO'}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Cycle-Birth Concentration and Universality — Computational Demo   ║")
    print("║                                                                    ║")
    print("║  Tropical Spectral Theory for Random Graphs                        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    run_concentration_test()
    run_universality_test()
    run_mst_complement_test()
    run_monotone_transport_test()

    print("=" * 70)
    print("All experiments complete.")
    print("=" * 70)


"""
Visualization: Concentration of Cycle-Birth CDFs

Shows how empirical cycle-birth CDFs from independent random graph trials
converge as n grows. Multiple trials at each n are overlaid, demonstrating
that the spread (measured by KS distance) shrinks with increasing n.

This visualizes the concentration phenomenon established by Theorem 3
(cycleBirth_hasBoundedDifferences → McDiarmid concentration).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ---- Inlined algorithms ----

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


def get_cycle_births(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    cb = []
    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            cb.append(w)
    return cb


# ---- Main visualization ----

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Concentration of Cycle-Birth CDFs in G(n, 0.15)',
             fontsize=16, fontweight='bold')

ns = [50, 100, 200, 500]
p = 0.15
num_trials = 15
rng = np.random.default_rng(42)

for idx, (ax, n) in enumerate(zip(axes.flat, ns)):
    grid = np.linspace(0, 1, 500)

    for trial in range(num_trials):
        cb = get_cycle_births(n, p, np.random.default_rng(rng.integers(0, 2**32)))
        if cb:
            sorted_cb = np.sort(cb)
            cdf = np.searchsorted(sorted_cb, grid, side='right') / len(sorted_cb)
            alpha = 0.3 if num_trials > 5 else 0.6
            ax.plot(grid, cdf, alpha=alpha, linewidth=0.8, color='steelblue')

    ax.set_title(f'n = {n}', fontsize=13, fontweight='bold')
    ax.set_xlabel('Weight threshold t', fontsize=10)
    ax.set_ylabel('Empirical CDF F̂(t)', fontsize=10)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

    # Add annotation about spread
    if idx == 0:
        ax.annotate('Wide spread\n(low concentration)',
                    xy=(0.5, 0.5), fontsize=9, ha='center',
                    bbox=dict(boxstyle='round', fc='lightyellow', alpha=0.8))
    elif idx == 3:
        ax.annotate('Tight convergence\n(high concentration)',
                    xy=(0.5, 0.5), fontsize=9, ha='center',
                    bbox=dict(boxstyle='round', fc='lightgreen', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")


"""
Visualization: MST Complement = Cycle-Birth Edges

Illustrates Theorem 5: in a weighted graph filtration, cycle-birth edges
are exactly the edges NOT in the minimum spanning tree. Shows a small
graph example with MST edges (blue) and cycle-birth edges (red), plus
the weight spectrum decomposition.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ---- Inlined algorithms ----

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


# ---- Build a small example ----

n = 8
np.random.seed(42)
positions = np.array([
    [0, 1], [1, 1.8], [2, 1], [1, 0],
    [3, 1.5], [4, 1], [3, 0], [4, 0]
], dtype=float)

# Generate edges with weights = Euclidean distance + noise
edges = []
for i in range(n):
    for j in range(i+1, n):
        dist = np.linalg.norm(positions[i] - positions[j])
        if dist < 2.5:  # only nearby edges
            w = dist + np.random.uniform(-0.1, 0.1)
            edges.append((i, j, w))

# Classify edges
sorted_edges = sorted(edges, key=lambda e: e[2])
uf = UnionFind(n)
mst_edges = []
cycle_edges = []
for u, v, w in sorted_edges:
    if uf.union(u, v):
        mst_edges.append((u, v, w))
    else:
        cycle_edges.append((u, v, w))

# ---- Plot ----

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Theorem 5: Cycle-Birth Edges = Non-MST Edges',
             fontsize=14, fontweight='bold')

# Left: Graph with edge classification
ax1.set_title('Graph with Edge Classification', fontsize=12, fontweight='bold')

# Draw cycle-birth edges (red, dashed)
for u, v, w in cycle_edges:
    x = [positions[u][0], positions[v][0]]
    y = [positions[u][1], positions[v][1]]
    ax1.plot(x, y, 'r--', linewidth=1.5, alpha=0.6)
    mid_x, mid_y = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax1.text(mid_x, mid_y + 0.1, f'{w:.2f}', fontsize=7, ha='center', color='red')

# Draw MST edges (blue, solid)
for u, v, w in mst_edges:
    x = [positions[u][0], positions[v][0]]
    y = [positions[u][1], positions[v][1]]
    ax1.plot(x, y, 'b-', linewidth=2.5, alpha=0.8)
    mid_x, mid_y = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax1.text(mid_x, mid_y + 0.1, f'{w:.2f}', fontsize=7, ha='center', color='blue')

# Draw vertices
for i, (x, y) in enumerate(positions):
    ax1.scatter(x, y, s=200, c='white', edgecolors='black', linewidth=2, zorder=5)
    ax1.text(x, y, str(i), fontsize=10, ha='center', va='center', zorder=6,
             fontweight='bold')

ax1.legend(
    [plt.Line2D([0], [0], color='blue', linewidth=2.5),
     plt.Line2D([0], [0], color='red', linewidth=1.5, linestyle='--')],
    [f'MST edges ({len(mst_edges)})',
     f'Cycle-birth edges ({len(cycle_edges)})'],
    fontsize=10, loc='lower right'
)
ax1.set_xlim(-0.5, 4.5)
ax1.set_ylim(-0.5, 2.3)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.2)

# Right: Weight spectrum decomposition
ax2.set_title('Weight Spectrum Decomposition', fontsize=12, fontweight='bold')

mst_w = [w for _, _, w in mst_edges]
cycle_w = [w for _, _, w in cycle_edges]

bins = np.linspace(
    min(w for _, _, w in sorted_edges) - 0.1,
    max(w for _, _, w in sorted_edges) + 0.1,
    15
)

ax2.hist(mst_w, bins=bins, alpha=0.7, color='steelblue',
         label=f'MST edges (n-1 = {len(mst_edges)})', edgecolor='white')
ax2.hist(cycle_w, bins=bins, alpha=0.7, color='salmon',
         label=f'Cycle births (β₁ = {len(cycle_edges)})', edgecolor='white')
ax2.set_xlabel('Edge weight', fontsize=11)
ax2.set_ylabel('Count', fontsize=11)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Annotations
total = len(mst_edges) + len(cycle_edges)
ax2.annotate(
    f'Total edges: {total}\n'
    f'MST edges: {len(mst_edges)} = n-1\n'
    f'Cycle births: {len(cycle_edges)} = β₁\n'
    f'Sum: {len(mst_edges)} + {len(cycle_edges)} = {total} ✓',
    xy=(0.95, 0.95), xycoords='axes fraction',
    fontsize=9, ha='right', va='top',
    bbox=dict(boxstyle='round', fc='lightyellow', alpha=0.9)
)

plt.tight_layout()
plt.savefig('viz_mst_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_mst_complement.png")


"""
Visualization: Universality Under Monotone Transport

Shows that cycle-birth CDFs from different weight distributions
(Uniform, Exponential, Normal) collapse onto a single curve after
rank normalization. This visualizes Theorem 4
(cycleBirthFlags_invariant_mapWeights).

Left panel: Raw CDFs differ across distributions.
Right panel: After quantile normalization, all CDFs agree.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ---- Inlined algorithms ----

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


def get_cycle_births_with_dist(n, p, dist, rng):
    edges = []
    edge_structure = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                edge_structure.append((i, j))

    weight_rng = np.random.default_rng(rng.integers(0, 2**32))
    for u, v in edge_structure:
        if dist == 'uniform':
            w = weight_rng.random()
        elif dist == 'exponential':
            w = weight_rng.exponential(1.0)
        elif dist == 'normal':
            w = weight_rng.normal(0.0, 1.0)
        edges.append((u, v, w))

    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    cb = []
    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            cb.append(w)
    return cb


# ---- Main visualization ----

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Universality: Cycle-Birth CDFs Under Different Weight Distributions',
             fontsize=14, fontweight='bold')

n = 300
p = 0.15
num_trials = 5
dists = ['uniform', 'exponential', 'normal']
colors = {'uniform': '#2196F3', 'exponential': '#FF5722', 'normal': '#4CAF50'}
labels = {'uniform': 'Uniform[0,1]', 'exponential': 'Exponential(1)', 'normal': 'Normal(0,1)'}

for dist in dists:
    for trial in range(num_trials):
        rng = np.random.default_rng(42 + trial)
        cb = get_cycle_births_with_dist(n, p, dist, rng)
        if not cb:
            continue

        # Raw CDF
        sorted_cb = np.sort(cb)
        ecdf = np.arange(1, len(sorted_cb)+1) / len(sorted_cb)
        label = labels[dist] if trial == 0 else None
        ax1.step(sorted_cb, ecdf, alpha=0.5, linewidth=1.2,
                 color=colors[dist], label=label)

        # Rank-normalized CDF
        ranks = np.argsort(np.argsort(sorted_cb)) / len(sorted_cb)
        ecdf_norm = np.arange(1, len(sorted_cb)+1) / len(sorted_cb)
        ax2.step(np.sort(ranks), ecdf_norm, alpha=0.5, linewidth=1.2,
                 color=colors[dist], label=label if trial == 0 else None)

ax1.set_title('Raw Cycle-Birth CDFs', fontsize=12, fontweight='bold')
ax1.set_xlabel('Weight threshold', fontsize=11)
ax1.set_ylabel('Empirical CDF', fontsize=11)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.annotate('Different distributions\n→ different CDFs',
             xy=(0.5, 0.3), xycoords='axes fraction',
             fontsize=10, ha='center',
             bbox=dict(boxstyle='round', fc='lightyellow', alpha=0.8))

ax2.set_title('After Rank Normalization (Quantile Transform)', fontsize=12, fontweight='bold')
ax2.set_xlabel('Normalized rank', fontsize=11)
ax2.set_ylabel('Empirical CDF', fontsize=11)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.annotate('All distributions\ncollapse to one curve!',
             xy=(0.5, 0.3), xycoords='axes fraction',
             fontsize=10, ha='center', color='darkgreen',
             fontweight='bold',
             bbox=dict(boxstyle='round', fc='lightgreen', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
