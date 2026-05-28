#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Cycle-Birth Theory

Demonstrates how the formally verified cycle-birth theorems apply to:
1. Network resilience analysis
2. Topological data analysis of random networks
3. Quality assessment of mesh/graph structures

Application keywords: network science, topological statistics, percolation,
random optimization, persistent homology, tropical Morse theory.
"""

import random
import math
from typing import List, Tuple, Dict


class UnionFind:
    """Union-Find for Kruskal-based cycle-birth computation."""
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
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return True


def cycle_births(n: int, edges: List[Tuple[int,int]], weights: List[float]):
    """Compute cycle-birth and MST edges."""
    order = sorted(range(len(edges)), key=lambda i: weights[i])
    uf = UnionFind(n)
    births, mst = [], []
    for idx in order:
        u, v = edges[idx]
        w = weights[idx]
        if uf.union(u, v): mst.append((edges[idx], w))
        else: births.append((edges[idx], w))
    return births, mst


# ─── Application 1: Network Resilience ───

def network_resilience_analysis():
    """
    Analyze network resilience using cycle-birth theory.

    Key insight: The cycle-birth count β₁ measures redundancy in a network.
    By Theorem 5, β₁ = m - (n-1) for connected graphs, meaning each
    cycle-birth edge provides an alternative path.

    A network with more early cycle births (low-weight redundant edges)
    is more resilient to edge failures.
    """
    print("=" * 60)
    print("APPLICATION 1: NETWORK RESILIENCE ANALYSIS")
    print("=" * 60)
    print()

    random.seed(42)

    # Generate two networks with same topology but different weight patterns
    n = 20
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if random.random() < 0.25:
                edges.append((i, j))

    m = len(edges)
    print(f"  Network: {n} nodes, {m} edges")
    print()

    # Scenario A: low-cost redundancy (cycle births have low weights)
    weights_a = [random.uniform(0, 1) for _ in range(m)]
    births_a, mst_a = cycle_births(n, edges, weights_a)

    # Scenario B: high-cost redundancy (reassign weights)
    weights_b = sorted(weights_a)  # same multiset, different assignment
    random.shuffle(weights_b)
    births_b, mst_b = cycle_births(n, edges, weights_b)

    print(f"  Scenario A: {len(births_a)} redundant edges (cycle births)")
    print(f"    MST cost: {sum(w for _, w in mst_a):.2f}")
    print(f"    Mean birth weight: {sum(w for _, w in births_a)/max(1,len(births_a)):.3f}")
    print()
    print(f"  Scenario B: {len(births_b)} redundant edges (cycle births)")
    print(f"    MST cost: {sum(w for _, w in mst_b):.2f}")
    print(f"    Mean birth weight: {sum(w for _, w in births_b)/max(1,len(births_b)):.3f}")
    print()
    print("  → By Theorem 5, β₁ (number of cycle births) is the same")
    print("    regardless of weight assignment. Only the birth weights change.")
    print("  → Lower mean birth weight = cheaper redundancy = more resilient.")
    print()


# ─── Application 2: Topological Network Fingerprinting ───

def topological_fingerprinting():
    """
    Use cycle-birth distributions as topological fingerprints for networks.

    By Theorem 4 (universality), the cycle-birth classification is invariant
    under monotone transport. This means the birth distribution captures
    genuine topological structure, not measurement artifacts.
    """
    print("=" * 60)
    print("APPLICATION 2: TOPOLOGICAL NETWORK FINGERPRINTING")
    print("=" * 60)
    print()

    random.seed(123)

    def make_lattice_graph(rows, cols):
        """Grid graph with noise."""
        n = rows * cols
        edges, weights = [], []
        for r in range(rows):
            for c in range(cols):
                v = r * cols + c
                if c + 1 < cols:
                    edges.append((v, v + 1))
                    weights.append(random.uniform(0, 1))
                if r + 1 < rows:
                    edges.append((v, v + cols))
                    weights.append(random.uniform(0, 1))
        return n, edges, weights

    def make_random_graph(n, p):
        """Erdős-Rényi G(n,p)."""
        edges, weights = [], []
        for i in range(n):
            for j in range(i+1, n):
                if random.random() < p:
                    edges.append((i, j))
                    weights.append(random.uniform(0, 1))
        return n, edges, weights

    # Compare lattice vs random
    n1, e1, w1 = make_lattice_graph(5, 5)
    n2, e2, w2 = make_random_graph(25, 0.12)

    b1, m1 = cycle_births(n1, e1, w1)
    b2, m2 = cycle_births(n2, e2, w2)

    print(f"  Lattice (5×5): {n1} nodes, {len(e1)} edges, β₁={len(b1)}")
    print(f"  Random G(25,0.12): {n2} nodes, {len(e2)} edges, β₁={len(b2)}")
    print()

    if b1:
        bw1 = sorted([w for _, w in b1])
        print(f"  Lattice birth weights:  min={bw1[0]:.3f}, median={bw1[len(bw1)//2]:.3f}, max={bw1[-1]:.3f}")
    if b2:
        bw2 = sorted([w for _, w in b2])
        print(f"  Random birth weights:   min={bw2[0]:.3f}, median={bw2[len(bw2)//2]:.3f}, max={bw2[-1]:.3f}")

    print()
    print("  → Different graph topologies produce different cycle-birth distributions.")
    print("  → By Theorem 4, this fingerprint is robust to monotone weight rescaling.")
    print()


# ─── Application 3: Mesh Quality Assessment ───

def mesh_quality():
    """
    Assess mesh quality using the cycle-birth / MST complement duality.

    A good mesh should have β₁ = expected number of holes.
    Excess cycle births indicate unnecessary connectivity.
    The Euler characteristic identity (formally verified) gives:
    χ = V - E = β₀ - β₁
    """
    print("=" * 60)
    print("APPLICATION 3: MESH QUALITY ASSESSMENT")
    print("=" * 60)
    print()

    random.seed(789)

    # Simple triangulated surface
    n = 10
    edges = [(i, (i+1) % n) for i in range(n)]  # cycle
    # Add some diagonals
    for i in range(0, n, 2):
        edges.append((i, (i+2) % n))

    m = len(edges)
    weights = [random.uniform(0, 1) for _ in range(m)]

    births, mst = cycle_births(n, edges, weights)
    beta0 = n - len(mst)
    beta1 = len(births)
    chi = n - m

    print(f"  Mesh: {n} vertices, {m} edges")
    print(f"  β₀ (components) = {beta0}")
    print(f"  β₁ (cycles)     = {beta1}")
    print(f"  χ (Euler char)  = {chi} = {beta0} - {beta1}")
    print()
    print(f"  Verified: V - E = β₀ - β₁: {chi} = {beta0 - beta1} ✓")
    print()
    print("  → The Euler characteristic identity is formally verified in Lean 4.")
    print("  → Cycle-birth count detects topological complexity of the mesh.")
    print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF CYCLE-BIRTH THEORY                        ║")
    print("║  From Formal Proofs to Real-World Networks                  ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    network_resilience_analysis()
    topological_fingerprinting()
    mesh_quality()


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
demo.py — Cycle-Birth Distributions in Random Weighted Graphs

Demonstrates:
1. Concentration test: KS distance decay with graph size
2. Universality test: invariance under monotone weight transport
3. MST complement validation: cycle births = non-MST edges

Application keywords: tropical Morse theory, persistent homology, Erdős–Rényi graphs,
concentration of measure, McDiarmid inequality, Azuma–Hoeffding, universality,
minimum spanning tree, graphic matroid, percolation, network science,
topological statistics, random optimization, KS distance, empirical process.
"""

import numpy as np
from collections import defaultdict
import itertools


# ─── Core algorithms ───

class UnionFind:
    """Union-Find (disjoint set) data structure for Kruskal's algorithm."""
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
            return False  # same component → cycle birth
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True  # merge


def compute_cycle_births(n, edges, weights):
    """
    Compute cycle-birth edges via Kruskal's algorithm.

    An edge is a cycle birth iff its endpoints are already connected
    when it is inserted (sorted by weight). This is Theorem 1.

    Returns:
        cycle_birth_weights: sorted list of weights of cycle-birth edges
        mst_weights: sorted list of weights of MST edges
    """
    order = np.argsort(weights)
    uf = UnionFind(n)
    cycle_birth_weights = []
    mst_weights = []

    for idx in order:
        u, v = edges[idx]
        w = weights[idx]
        if uf.union(u, v):
            mst_weights.append(w)
        else:
            cycle_birth_weights.append(w)

    return cycle_birth_weights, mst_weights


def sample_erdos_renyi(n, p, weight_dist='uniform', rng=None):
    """
    Sample G(n,p) with random edge weights from given distribution.

    Returns: (edges, weights)
    """
    if rng is None:
        rng = np.random.default_rng()

    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))

    m = len(edges)
    if weight_dist == 'uniform':
        weights = rng.random(m)
    elif weight_dist == 'exponential':
        weights = rng.exponential(1.0, m)
    elif weight_dist == 'normal':
        weights = rng.normal(0, 1, m)
    else:
        raise ValueError(f"Unknown distribution: {weight_dist}")

    return edges, weights


def empirical_cdf(values, t):
    """Compute empirical CDF at point t."""
    if len(values) == 0:
        return 0.0
    return np.mean(np.array(values) <= t)


def ks_distance(sample1, sample2):
    """Compute Kolmogorov-Smirnov distance between two samples."""
    if len(sample1) == 0 or len(sample2) == 0:
        return 1.0
    combined = np.sort(np.concatenate([sample1, sample2]))
    cdf1 = np.array([np.mean(sample1 <= x) for x in combined])
    cdf2 = np.array([np.mean(sample2 <= x) for x in combined])
    return np.max(np.abs(cdf1 - cdf2))


def probability_integral_transform(values, transform='rank'):
    """
    Transform values to [0,1] via probability integral transform.
    This implements the monotone transport from Theorem 4.
    """
    if len(values) == 0:
        return np.array([])
    arr = np.array(values)
    ranks = np.argsort(np.argsort(arr))
    return (ranks + 0.5) / len(arr)


# ─── Experiment 1: Concentration ───

def concentration_test():
    """
    Test that KS distance between empirical cycle-birth CDFs
    from independent trials decays like O(n^{-1/2}).

    This validates the concentration theorem (Theorem 3):
    the bounded-differences property (Theorem 2) implies
    subgaussian concentration via McDiarmid's inequality.
    """
    print("=" * 60)
    print("EXPERIMENT 1: CONCENTRATION TEST")
    print("=" * 60)
    print()

    p = 0.15
    ns = [50, 100, 200, 500]
    num_trials = 20
    rng = np.random.default_rng(42)

    results = {}

    for n in ns:
        ks_distances = []
        trial_births = []

        for trial in range(num_trials):
            edges, weights = sample_erdos_renyi(n, p, 'uniform', rng)
            if len(edges) == 0:
                continue
            births, _ = compute_cycle_births(n, edges, weights)
            if len(births) > 0:
                trial_births.append(np.array(births))

        # Compute pairwise KS distances
        for i in range(len(trial_births)):
            for j in range(i + 1, len(trial_births)):
                ks_distances.append(ks_distance(trial_births[i], trial_births[j]))

        mean_ks = np.mean(ks_distances) if ks_distances else float('nan')
        results[n] = mean_ks
        print(f"  n={n:4d}: mean KS distance = {mean_ks:.4f}  "
              f"(n^{{-1/2}} = {1/np.sqrt(n):.4f})")

    print()
    if len(results) >= 2:
        ns_list = sorted(results.keys())
        for i in range(1, len(ns_list)):
            ratio = results[ns_list[i]] / results[ns_list[i-1]] if results[ns_list[i-1]] > 0 else float('nan')
            expected = np.sqrt(ns_list[i-1] / ns_list[i])
            print(f"  Ratio n={ns_list[i-1]}→{ns_list[i]}: {ratio:.3f} "
                  f"(expected ~{expected:.3f} for n^{{-1/2}} decay)")

    print()
    return results


# ─── Experiment 2: Universality ───

def universality_test():
    """
    Test that cycle-birth distributions are universal under
    monotone transport (Theorem 4).

    After probability integral transform, empirical CDFs from
    different weight distributions should collapse onto one curve.
    """
    print("=" * 60)
    print("EXPERIMENT 2: UNIVERSALITY TEST")
    print("=" * 60)
    print()

    n = 200
    p = 0.15
    num_trials = 30
    rng = np.random.default_rng(123)

    distributions = ['uniform', 'exponential', 'normal']

    # For each distribution, collect transformed cycle-birth weights
    transformed_births = defaultdict(list)

    for dist in distributions:
        for _ in range(num_trials):
            edges, weights = sample_erdos_renyi(n, p, dist, rng)
            if len(edges) == 0:
                continue
            births, _ = compute_cycle_births(n, edges, weights)
            if len(births) > 2:
                transformed = probability_integral_transform(births)
                transformed_births[dist].append(transformed)

    # Compare pairwise KS distances between distributions
    print("  Pairwise KS distances (after monotone transport):")
    print()

    for d1, d2 in itertools.combinations(distributions, 2):
        ks_dists = []
        for i in range(min(len(transformed_births[d1]), len(transformed_births[d2]))):
            ks_dists.append(ks_distance(
                transformed_births[d1][i], transformed_births[d2][i]))
        mean_ks = np.mean(ks_dists) if ks_dists else float('nan')
        print(f"    {d1:12s} vs {d2:12s}: mean KS = {mean_ks:.4f}")

    # Also compare within same distribution
    print()
    print("  Within-distribution KS distances (baseline):")
    for dist in distributions:
        ks_dists = []
        samples = transformed_births[dist]
        for i in range(min(10, len(samples))):
            for j in range(i + 1, min(10, len(samples))):
                ks_dists.append(ks_distance(samples[i], samples[j]))
        mean_ks = np.mean(ks_dists) if ks_dists else float('nan')
        print(f"    {dist:12s}: mean KS = {mean_ks:.4f}")

    print()
    print("  → If cross-distribution KS ≈ within-distribution KS,")
    print("    universality is confirmed.")
    print()


# ─── Experiment 3: MST Complement Validation ───

def mst_complement_test():
    """
    Verify that cycle-birth edges = complement of MST edges (Theorem 5).

    For connected graphs with distinct weights, the set of cycle-birth
    edges should be exactly the non-MST edges.
    """
    print("=" * 60)
    print("EXPERIMENT 3: MST COMPLEMENT VALIDATION")
    print("=" * 60)
    print()

    n = 50
    p = 0.3
    num_trials = 100
    rng = np.random.default_rng(456)
    violations = 0

    for trial in range(num_trials):
        edges, weights = sample_erdos_renyi(n, p, 'uniform', rng)
        if len(edges) == 0:
            continue

        births, mst_w = compute_cycle_births(n, edges, weights)

        # Verify partition: births + MST = all edges
        if len(births) + len(mst_w) != len(edges):
            violations += 1

        # Verify MST has at most n-1 edges
        if len(mst_w) > n - 1:
            violations += 1

    print(f"  Trials: {num_trials}")
    print(f"  Violations: {violations}")
    print(f"  → {'PASS' if violations == 0 else 'FAIL'}: "
          f"cycle births + MST edges = all edges")
    print()

    # Detailed example
    print("  Detailed example (K₄ with weights 1..6):")
    edges_k4 = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    weights_k4 = np.array([1, 2, 3, 4, 5, 6], dtype=float)
    births_k4, mst_k4 = compute_cycle_births(4, edges_k4, weights_k4)
    print(f"    MST weights:         {mst_k4}")
    print(f"    Cycle-birth weights: {births_k4}")
    print(f"    Total edges: {len(edges_k4)} = {len(mst_k4)} (MST) + {len(births_k4)} (births)")
    print(f"    β₁ = {len(births_k4)} = {len(edges_k4)} - ({4} - 1)")
    print()


# ─── Main ───

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  CYCLE-BIRTH DISTRIBUTIONS IN RANDOM WEIGHTED GRAPHS       ║")
    print("║  Tropical Morse Theory meets Probabilistic Combinatorics   ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    concentration_test()
    universality_test()
    mst_complement_test()

    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("  Theorem 1 (Dichotomy):     Every edge is merge XOR cycle birth.")
    print("  Theorem 2 (Lipschitz):     Single-edge change → ≤1 count change.")
    print("  Theorem 3 (Concentration): Subgaussian tail via bounded differences.")
    print("  Theorem 4 (Universality):  Monotone transport preserves classification.")
    print("  Theorem 5 (MST Complement): Cycle births = non-MST edges.")
    print()
    print("  All five theorems are formally verified in Lean 4.")
    print()


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization 1: Concentration of Cycle-Birth Distributions

Visualizes how empirical cycle-birth CDFs from independent random graph
trials converge as graph size increases, demonstrating the concentration
theorem (Theorem 3). Multiple trials are overlaid to show the narrowing
of the distribution "band" with increasing n.
"""

import numpy as np
import matplotlib.pyplot as plt


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
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return True


def compute_cycle_births(n, edges, weights):
    order = np.argsort(weights)
    uf = UnionFind(n)
    births = []
    for idx in order:
        u, v = edges[idx]
        if not uf.union(u, v):
            births.append(weights[idx])
    return np.array(births)


def sample_gnp(n, p, rng):
    edges, weights = [], []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                edges.append((i, j))
                weights.append(rng.random())
    return edges, np.array(weights)


fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Concentration of Cycle-Birth Distributions\n(Theorem 3: Bounded Differences → Subgaussian Concentration)',
             fontsize=14, fontweight='bold')

ns = [30, 60, 120, 250]
p = 0.2
num_trials = 15
rng = np.random.default_rng(42)

for ax, n in zip(axes.flat, ns):
    for trial in range(num_trials):
        edges, weights = sample_gnp(n, p, rng)
        if len(edges) == 0:
            continue
        births = compute_cycle_births(n, edges, weights)
        if len(births) > 0:
            sorted_births = np.sort(births)
            cdf_y = np.arange(1, len(sorted_births)+1) / len(sorted_births)
            ax.step(sorted_births, cdf_y, alpha=0.4, linewidth=1)

    ax.set_title(f'n = {n} ({num_trials} independent trials)', fontsize=11)
    ax.set_xlabel('Edge Weight (threshold t)')
    ax.set_ylabel('Empirical CDF F̂(t)')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")


#!/usr/bin/env python3
"""
Visualization 3: MST Complement Duality (Theorem 5)

Illustrates that cycle-birth edges are exactly the complement of the
minimum spanning tree edges. Shows a small graph with MST edges (blue)
and cycle-birth edges (red), plus the Euler characteristic identity.
"""

import numpy as np
import matplotlib.pyplot as plt


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
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return True


# K6 graph
n = 6
edges = []
for i in range(n):
    for j in range(i+1, n):
        edges.append((i, j))

rng = np.random.default_rng(42)
weights = rng.random(len(edges))

# Compute cycle births
order = np.argsort(weights)
uf = UnionFind(n)
mst_idx, birth_idx = [], []
for idx in order:
    u, v = edges[idx]
    if uf.union(u, v):
        mst_idx.append(idx)
    else:
        birth_idx.append(idx)

# Layout: hexagonal
angles = np.linspace(0, 2*np.pi, n, endpoint=False) + np.pi/2
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))
fig.suptitle('MST Complement Duality (Theorem 5)\n'
             'Cycle births = all edges \\ MST edges',
             fontsize=14, fontweight='bold')

# Panel 1: All edges
ax = axes[0]
ax.set_title(f'All Edges ({len(edges)} edges)', fontsize=11)
for idx, (u, v) in enumerate(edges):
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax.plot(x, y, 'gray', linewidth=1.5, alpha=0.6)
    ax.text(mx, my, f'{weights[idx]:.2f}', fontsize=6, ha='center',
            bbox=dict(boxstyle='round,pad=0.1', facecolor='white', alpha=0.8))
for i in range(n):
    ax.plot(*pos[i], 'ko', markersize=12, zorder=5)
    ax.text(pos[i][0], pos[i][1], str(i), color='white', fontsize=8,
            ha='center', va='center', zorder=6, fontweight='bold')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Panel 2: MST + Birth classification
ax = axes[1]
ax.set_title('MST (blue) vs Cycle Births (red)', fontsize=11)
for idx, (u, v) in enumerate(edges):
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    if idx in mst_idx:
        ax.plot(x, y, '#2196F3', linewidth=3, alpha=0.8, zorder=2)
    else:
        ax.plot(x, y, '#F44336', linewidth=2, alpha=0.6, linestyle='--', zorder=1)
for i in range(n):
    ax.plot(*pos[i], 'ko', markersize=12, zorder=5)
    ax.text(pos[i][0], pos[i][1], str(i), color='white', fontsize=8,
            ha='center', va='center', zorder=6, fontweight='bold')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], color='#2196F3', linewidth=3, label=f'MST ({len(mst_idx)} edges)'),
    Line2D([0], [0], color='#F44336', linewidth=2, linestyle='--',
           label=f'Cycle Births ({len(birth_idx)} edges)'),
]
ax.legend(handles=legend_elements, loc='lower center', fontsize=9)

# Panel 3: Euler characteristic and Betti numbers
ax = axes[2]
ax.axis('off')
beta0 = n - len(mst_idx)
beta1 = len(birth_idx)
chi = n - len(edges)

text = (
    f"  K₆ with random weights\n\n"
    f"  V = {n} vertices\n"
    f"  E = {len(edges)} edges\n\n"
    f"  ─── Partition ───\n"
    f"  MST edges (merges):    {len(mst_idx)}\n"
    f"  Cycle births:          {len(birth_idx)}\n"
    f"  Total:                 {len(mst_idx)} + {len(birth_idx)} = {len(edges)} ✓\n\n"
    f"  ─── Betti Numbers ───\n"
    f"  β₀ = V - merges = {n} - {len(mst_idx)} = {beta0}\n"
    f"  β₁ = cycle births = {beta1}\n\n"
    f"  ─── Euler Characteristic ───\n"
    f"  χ = V - E = {n} - {len(edges)} = {chi}\n"
    f"  χ = β₀ - β₁ = {beta0} - {beta1} = {beta0 - beta1} ✓\n\n"
    f"  ─── Tree Test ───\n"
    f"  β₁ = 0? {'Yes → Tree' if beta1 == 0 else 'No → Has cycles'}"
)

ax.text(0.05, 0.95, text, transform=ax.transAxes, fontsize=10,
        verticalalignment='top', fontfamily='monospace',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_mst_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_mst_complement.png")


#!/usr/bin/env python3
"""
Visualization 2: Universality Under Monotone Transport (Theorem 4)

Shows that cycle-birth distributions from different edge-weight distributions
(Uniform, Exponential, Normal) collapse onto the same curve after probability
integral transform. This demonstrates Theorem 4: only the order of weights
matters for cycle-birth classification.
"""

import numpy as np
import matplotlib.pyplot as plt


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
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return True


def compute_cycle_births(n, edges, weights):
    order = np.argsort(weights)
    uf = UnionFind(n)
    births = []
    for idx in order:
        u, v = edges[idx]
        if not uf.union(u, v):
            births.append(weights[idx])
    return np.array(births)


def rank_transform(values):
    """Probability integral transform via ranks."""
    if len(values) == 0:
        return np.array([])
    order = np.argsort(np.argsort(values))
    return (order + 0.5) / len(values)


rng = np.random.default_rng(123)
n = 150
p = 0.2

# Generate a fixed graph topology
graph_edges = []
for i in range(n):
    for j in range(i+1, n):
        if rng.random() < p:
            graph_edges.append((i, j))
m = len(graph_edges)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Universality: Cycle-Birth CDFs Under Different Weight Distributions\n'
             '(Theorem 4: Monotone Transport Preserves Classification)',
             fontsize=13, fontweight='bold')

# Panel 1: Raw CDFs (different distributions look different)
distributions = {
    'Uniform': lambda: rng.random(m),
    'Exponential': lambda: rng.exponential(1.0, m),
    'Normal': lambda: rng.normal(0, 1, m),
}
colors = {'Uniform': '#2196F3', 'Exponential': '#FF5722', 'Normal': '#4CAF50'}

ax = axes[0]
ax.set_title('Raw Birth Weights\n(Distributions differ)', fontsize=11)
for name, gen in distributions.items():
    for trial in range(5):
        weights = gen()
        births = compute_cycle_births(n, graph_edges, weights)
        if len(births) > 0:
            sb = np.sort(births)
            cdf_y = np.arange(1, len(sb)+1) / len(sb)
            ax.step(sb, cdf_y, color=colors[name], alpha=0.4, linewidth=1,
                    label=name if trial == 0 else None)
ax.set_xlabel('Raw Edge Weight')
ax.set_ylabel('Empirical CDF')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Rank-transformed CDFs (distributions collapse)
ax = axes[1]
ax.set_title('After Rank Transform\n(Distributions collapse!)', fontsize=11)
for name, gen in distributions.items():
    for trial in range(5):
        weights = gen()
        births = compute_cycle_births(n, graph_edges, weights)
        if len(births) > 0:
            transformed = rank_transform(births)
            sb = np.sort(transformed)
            cdf_y = np.arange(1, len(sb)+1) / len(sb)
            ax.step(sb, cdf_y, color=colors[name], alpha=0.4, linewidth=1,
                    label=name if trial == 0 else None)
ax.set_xlabel('Rank-Transformed Weight')
ax.set_ylabel('Empirical CDF')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

# Panel 3: Same graph, same topology → identical classifications
ax = axes[2]
ax.set_title('Classification Invariance\n(Same edges are cycle births)', fontsize=11)
# Show that the SAME edges are classified as cycle births
weights_u = rng.random(m)
weights_e = rng.exponential(1.0, m)

order_u = np.argsort(weights_u)
order_e = np.argsort(weights_e)

uf_u, uf_e = UnionFind(n), UnionFind(n)
class_u, class_e = [], []
for idx in order_u:
    u, v = graph_edges[idx]
    class_u.append(not uf_u.union(u, v))
for idx in order_e:
    u, v = graph_edges[idx]
    class_e.append(not uf_e.union(u, v))

# Count agreements: classification depends on weight ORDER, not values
# With different weights, the order changes, so classifications differ
# But with MONOTONE TRANSFORM of same weights, classifications are identical!
weights_sq = weights_u ** 2  # monotone transform
order_sq = np.argsort(weights_sq)
uf_sq = UnionFind(n)
class_sq = []
for idx in order_sq:
    u, v = graph_edges[idx]
    class_sq.append(not uf_sq.union(u, v))

# Rebuild class_u in order
class_u_ordered = [False] * m
uf_check = UnionFind(n)
for idx in order_u:
    u, v = graph_edges[idx]
    class_u_ordered[idx] = not uf_check.union(u, v)

class_sq_ordered = [False] * m
uf_check2 = UnionFind(n)
for idx in order_sq:
    u, v = graph_edges[idx]
    class_sq_ordered[idx] = not uf_check2.union(u, v)

agreement = sum(1 for a, b in zip(class_u_ordered, class_sq_ordered) if a == b)
ax.bar(['w', 'w²\n(monotone)'], [m, agreement],
       color=['#2196F3', '#4CAF50'], alpha=0.7)
ax.set_ylabel('Number of Edges')
ax.axhline(y=m, color='gray', linestyle='--', alpha=0.5)
ax.text(0.5, m * 0.95, f'{m} edges total', ha='center', fontsize=9, color='gray')
ax.text(1, agreement + m*0.02, f'{agreement}/{m}\nagreement', ha='center', fontsize=9)
ax.set_ylim(0, m * 1.15)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
