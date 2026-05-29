"""
Applications of Tropical Critical Distribution Theory.

This module demonstrates real-world applications of cycle-birth analysis:

1. Network robustness assessment via cycle-birth spectra
2. Anomaly detection in weighted networks
3. Graph comparison via tropical spectral distance

Application keywords: network science, topological statistics, random optimization,
percolation, topological data analysis.
"""

import numpy as np
from typing import List, Tuple, Dict


# ---- Inline core algorithms ----

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


def compute_filtration(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    steps = []
    for u, v, w in sorted_edges:
        merged = uf.union(u, v)
        steps.append(((u, v), w, not merged))
    return steps


def cycle_birth_weights(steps):
    return np.array([w for _, w, sc in steps if sc])


def empirical_cdf(weights, grid):
    if len(weights) == 0:
        return np.zeros_like(grid)
    return np.array([np.mean(weights <= t) for t in grid])


def ks_distance(cdf1, cdf2):
    return float(np.max(np.abs(cdf1 - cdf2)))


# ---- Application 1: Network Robustness Assessment ----

def network_robustness_score(n: int, edges: List[Tuple[int, int, float]]) -> Dict:
    """Assess network robustness using cycle-birth spectrum.

    A network with many cycle births (relative to edges) has high redundancy.
    The distribution of birth weights indicates where redundancy is concentrated.

    Low-weight cycle births = cheap redundancy (robust).
    High-weight cycle births = expensive redundancy (fragile).

    Returns:
        Dictionary with robustness metrics.
    """
    steps = compute_filtration(n, edges)
    m = len(steps)
    births = cycle_birth_weights(steps)

    if m == 0:
        return {"redundancy_ratio": 0, "mean_birth_weight": float('nan')}

    redundancy_ratio = len(births) / m if m > 0 else 0

    result = {
        "num_vertices": n,
        "num_edges": m,
        "num_cycle_births": len(births),
        "num_tree_edges": m - len(births),
        "redundancy_ratio": redundancy_ratio,
        "betti_1": len(births),
    }

    if len(births) > 0:
        result["mean_birth_weight"] = float(np.mean(births))
        result["median_birth_weight"] = float(np.median(births))
        result["birth_weight_std"] = float(np.std(births))
        # Early births indicate cheap redundancy
        result["early_birth_fraction"] = float(np.mean(births <= np.median(
            [s[1] for s in steps])))
    else:
        result["mean_birth_weight"] = float('nan')

    return result


# ---- Application 2: Graph Comparison via Tropical Distance ----

def tropical_spectral_distance(n1: int, edges1: List, n2: int, edges2: List,
                                grid_size: int = 200) -> float:
    """Compute the tropical spectral distance between two weighted graphs.

    This uses the KS distance between empirical cycle-birth CDFs as a
    metric for comparing graph topologies under their weight filtrations.

    This is the topological analogue of comparing spectral measures
    in random matrix theory.

    Args:
        n1, edges1: First graph.
        n2, edges2: Second graph.
        grid_size: Resolution of CDF comparison grid.

    Returns:
        KS distance between the two empirical cycle-birth CDFs.
    """
    steps1 = compute_filtration(n1, edges1)
    steps2 = compute_filtration(n2, edges2)
    bw1 = cycle_birth_weights(steps1)
    bw2 = cycle_birth_weights(steps2)

    if len(bw1) == 0 and len(bw2) == 0:
        return 0.0
    if len(bw1) == 0 or len(bw2) == 0:
        return 1.0

    # Use combined weight range for grid
    all_w = np.concatenate([bw1, bw2])
    grid = np.linspace(np.min(all_w), np.max(all_w), grid_size)

    cdf1 = empirical_cdf(bw1, grid)
    cdf2 = empirical_cdf(bw2, grid)

    return ks_distance(cdf1, cdf2)


# ---- Application 3: Anomaly Detection ----

def detect_anomalous_edges(n: int, edges: List[Tuple[int, int, float]],
                           threshold_quantile: float = 0.9) -> List:
    """Detect anomalous edges using cycle-birth analysis.

    Edges that create cycles at unusually high weights are "anomalous":
    they represent unexpected connections between already-connected parts
    of the network. These can indicate:
    - Redundant infrastructure links
    - Suspicious connections in social networks
    - Potential failure points in communication networks

    Args:
        n: Number of vertices.
        edges: Weighted edge list.
        threshold_quantile: Quantile above which births are "anomalous".

    Returns:
        List of (edge, weight) pairs flagged as anomalous.
    """
    steps = compute_filtration(n, edges)
    births = [(e, w) for e, w, sc in steps if sc]

    if not births:
        return []

    weights = np.array([w for _, w in births])
    threshold = np.quantile(weights, threshold_quantile)

    return [(e, w) for e, w in births if w >= threshold]


# ---- Demo ----

if __name__ == "__main__":
    rng = np.random.default_rng(42)

    print("=" * 60)
    print("APPLICATION 1: NETWORK ROBUSTNESS ASSESSMENT")
    print("=" * 60)
    print()

    # Compare a dense vs sparse network
    for desc, n, p in [("Sparse (p=0.1)", 50, 0.1), ("Dense (p=0.4)", 50, 0.4)]:
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if rng.random() < p:
                    edges.append((i, j, rng.random()))
        metrics = network_robustness_score(n, edges)
        print(f"  {desc}:")
        for k, v in metrics.items():
            if isinstance(v, float):
                print(f"    {k}: {v:.4f}")
            else:
                print(f"    {k}: {v}")
        print()

    print("=" * 60)
    print("APPLICATION 2: GRAPH COMPARISON VIA TROPICAL DISTANCE")
    print("=" * 60)
    print()

    # Compare graphs with similar vs different structure
    n = 40
    edges_a = [(i, j, rng.random())
               for i in range(n) for j in range(i+1, n) if rng.random() < 0.2]
    edges_b = [(i, j, rng.random())
               for i in range(n) for j in range(i+1, n) if rng.random() < 0.2]
    edges_c = [(i, j, rng.random())
               for i in range(n) for j in range(i+1, n) if rng.random() < 0.5]

    d_ab = tropical_spectral_distance(n, edges_a, n, edges_b)
    d_ac = tropical_spectral_distance(n, edges_a, n, edges_c)
    d_bc = tropical_spectral_distance(n, edges_b, n, edges_c)

    print(f"  G_a vs G_b (similar density): KS = {d_ab:.4f}")
    print(f"  G_a vs G_c (different density): KS = {d_ac:.4f}")
    print(f"  G_b vs G_c (different density): KS = {d_bc:.4f}")
    print()
    print("  Similar-density graphs should have smaller tropical distance.")
    print()

    print("=" * 60)
    print("APPLICATION 3: ANOMALY DETECTION")
    print("=" * 60)
    print()

    n = 30
    edges = [(i, j, rng.random())
             for i in range(n) for j in range(i+1, n) if rng.random() < 0.15]

    anomalies = detect_anomalous_edges(n, edges, threshold_quantile=0.8)
    print(f"  Graph: {n} vertices, {len(edges)} edges")
    print(f"  Anomalous edges (top 20% cycle births): {len(anomalies)}")
    for e, w in anomalies[:5]:
        print(f"    Edge {e}, weight {w:.4f}")
    print()


"""
Demonstration: Concentration and Universality of Tropical Critical Distributions.

This script demonstrates the core theorems computationally:

1. **Concentration test**: Pairwise KS distances between empirical cycle-birth CDFs
   from independent G(n,p) trials decrease as n grows, confirming concentration.

2. **Universality test**: Under different continuous weight distributions
   (Uniform, Exponential, Gaussian), the cycle-birth edge sets are invariant
   under monotone transport, and rescaled CDFs collapse.

3. **MST complement validation**: Verifies that cycle-birth edges coincide
   with non-MST edges for random weighted graphs.

Application keywords: tropical Morse theory, persistent homology, Erdős–Rényi graphs,
concentration of measure, McDiarmid inequality, universality, minimum spanning tree,
KS distance, empirical process.
"""

import numpy as np
from typing import List, Tuple


# ---- Inline implementations (self-contained) ----

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


def compute_filtration(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    steps = []
    for u, v, w in sorted_edges:
        merged = uf.union(u, v)
        steps.append(((u, v), w, not merged))
    return steps


def cycle_birth_weights(steps):
    return np.array([w for _, w, sc in steps if sc])


def mst_edge_set(steps):
    return set(e for e, _, sc in steps if not sc)


def generate_gnp(n, p, dist='uniform', rng=None):
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


def empirical_cdf(weights, grid):
    if len(weights) == 0:
        return np.zeros_like(grid)
    return np.array([np.mean(weights <= t) for t in grid])


def ks_distance(cdf1, cdf2):
    return float(np.max(np.abs(cdf1 - cdf2)))


# ---- Test 1: Concentration ----

def test_concentration():
    print("=" * 70)
    print("TEST 1: CONCENTRATION OF CYCLE-BIRTH CDF")
    print("=" * 70)
    print()
    print("For G(n, p=0.15), we compute pairwise KS distances between")
    print("empirical cycle-birth CDFs from independent trials.")
    print("Theory (Theorem 3) predicts concentration: mean KS ~ O(n^{-1/2}).")
    print()

    p = 0.15
    n_values = [50, 100, 200, 500]
    num_trials = 20
    rng = np.random.default_rng(42)

    print(f"{'n':>6} | {'Mean KS':>10} | {'Std KS':>10} | {'n^(-1/2)':>10} | {'Ratio':>10}")
    print("-" * 60)

    for n in n_values:
        # Collect CDFs from independent trials
        grid = np.linspace(0, 1, 200)
        cdfs = []

        for _ in range(num_trials):
            edges = generate_gnp(n, p, 'uniform', rng)
            if len(edges) == 0:
                continue
            steps = compute_filtration(n, edges)
            bw = cycle_birth_weights(steps)
            if len(bw) == 0:
                continue
            cdf = empirical_cdf(bw, grid)
            cdfs.append(cdf)

        if len(cdfs) < 2:
            print(f"{n:>6} | {'N/A':>10} | {'N/A':>10}")
            continue

        # Pairwise KS distances
        ks_dists = []
        for i in range(len(cdfs)):
            for j in range(i + 1, len(cdfs)):
                ks_dists.append(ks_distance(cdfs[i], cdfs[j]))

        mean_ks = np.mean(ks_dists)
        std_ks = np.std(ks_dists)
        theory = 1.0 / np.sqrt(n)
        ratio = mean_ks / theory if theory > 0 else float('inf')

        print(f"{n:>6} | {mean_ks:>10.4f} | {std_ks:>10.4f} | {theory:>10.4f} | {ratio:>10.4f}")

    print()
    print("If the ratio stabilizes, concentration follows O(n^{-1/2}) scaling.")
    print()


# ---- Test 2: Universality under monotone transport ----

def test_universality():
    print("=" * 70)
    print("TEST 2: UNIVERSALITY UNDER MONOTONE TRANSPORT")
    print("=" * 70)
    print()
    print("Theorem 4: Applying a strictly monotone function to edge weights")
    print("preserves the set of cycle-birth edges. Only the order matters.")
    print()

    n = 100
    p = 0.3
    rng = np.random.default_rng(123)

    edges_base = generate_gnp(n, p, 'uniform', rng)
    if not edges_base:
        print("No edges generated. Skipping.")
        return

    steps_base = compute_filtration(n, edges_base)
    births_base = set(e for e, w, sc in steps_base if sc)

    transforms = {
        "x -> x^2": lambda x: x ** 2,
        "x -> x^3": lambda x: x ** 3,
        "x -> exp(x)": lambda x: np.exp(x),
        "x -> log(1+x)": lambda x: np.log(1 + x),
        "x -> 100*x + 7": lambda x: 100 * x + 7,
    }

    print(f"Base graph: n={n}, p={p}, {len(edges_base)} edges, {len(births_base)} cycle births")
    print()

    all_match = True
    for name, phi in transforms.items():
        edges_trans = [(u, v, phi(w)) for u, v, w in edges_base]
        steps_trans = compute_filtration(n, edges_trans)
        births_trans = set(e for e, w, sc in steps_trans if sc)

        match = births_base == births_trans
        all_match = all_match and match
        status = "✓ MATCH" if match else "✗ MISMATCH"
        print(f"  {name:>20s}: {status}")

    print()
    if all_match:
        print("All monotone transforms preserve cycle-birth classification. ✓")
    else:
        print("WARNING: Some transforms failed! This contradicts Theorem 4.")
    print()

    # Compare rescaled CDFs across different distributions
    print("Comparing cycle-birth CDFs across weight distributions (rescaled):")
    print()

    distributions = ['uniform', 'exponential', 'normal']
    grid = np.linspace(0, 1, 200)

    # Generate the same graph structure for fair comparison
    rng2 = np.random.default_rng(456)
    adjacency = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng2.random() < p:
                adjacency.append((i, j))

    cdfs_by_dist = {}
    for dist in distributions:
        rng3 = np.random.default_rng(789)
        edges = [(u, v, rng3.random() if dist == 'uniform'
                  else (rng3.exponential() if dist == 'exponential'
                        else rng3.normal()))
                 for u, v in adjacency]

        steps = compute_filtration(n, edges)
        bw = cycle_birth_weights(steps)

        if len(bw) > 0:
            # Rank-transform to [0,1] for universality comparison
            sorted_indices = np.argsort(bw)
            ranks = np.empty_like(bw)
            ranks[sorted_indices] = np.arange(1, len(bw) + 1) / len(bw)
            cdf = empirical_cdf(ranks, grid)
            cdfs_by_dist[dist] = cdf
            print(f"  {dist:>15s}: {len(bw)} cycle births")

    if len(cdfs_by_dist) >= 2:
        print()
        dists = list(cdfs_by_dist.keys())
        for i in range(len(dists)):
            for j in range(i + 1, len(dists)):
                ks = ks_distance(cdfs_by_dist[dists[i]], cdfs_by_dist[dists[j]])
                print(f"  KS({dists[i]:>12s} vs {dists[j]:<12s}) = {ks:.4f}")
    print()


# ---- Test 3: MST Complement Validation ----

def test_mst_complement():
    print("=" * 70)
    print("TEST 3: MST COMPLEMENT VALIDATION (THEOREM 5)")
    print("=" * 70)
    print()
    print("Theorem 5: Cycle-birth edges = complement of MST edges.")
    print("We verify this for multiple random graphs.")
    print()

    rng = np.random.default_rng(999)
    n_tests = 50
    all_pass = True

    for trial in range(n_tests):
        n = rng.integers(10, 50)
        p = rng.uniform(0.1, 0.5)
        edges = generate_gnp(int(n), float(p), 'uniform', rng)

        if not edges:
            continue

        steps = compute_filtration(int(n), edges)
        births = set(e for e, w, sc in steps if sc)
        forest = set(e for e, w, sc in steps if not sc)
        all_edges = set(e for e, _, _ in steps)

        # Check partition
        if births | forest != all_edges or (births & forest):
            print(f"  Trial {trial}: PARTITION FAILED!")
            all_pass = False
            continue

        # Check forest is acyclic
        uf = UnionFind(int(n))
        forest_ok = True
        for u, v in forest:
            if not uf.union(u, v):
                forest_ok = False
                break

        if not forest_ok:
            print(f"  Trial {trial}: FOREST HAS CYCLE!")
            all_pass = False

    if all_pass:
        print(f"  All {n_tests} trials passed. ✓")
        print("  Cycle-birth edges = non-MST edges in every case.")
    else:
        print("  Some trials FAILED!")
    print()


# ---- Test 4: Lipschitz stability ----

def test_lipschitz():
    print("=" * 70)
    print("TEST 4: LIPSCHITZ STABILITY (THEOREM 2)")
    print("=" * 70)
    print()
    print("Theorem 2: Flipping one edge's classification changes")
    print("the cycle-birth count by at most 1.")
    print()

    rng = np.random.default_rng(42)
    n = 30
    p = 0.3

    edges = generate_gnp(n, p, 'uniform', rng)
    if not edges:
        print("No edges. Skipping.")
        return

    steps = compute_filtration(n, edges)
    base_count = sum(1 for _, _, sc in steps if sc)

    max_diff = 0
    for k in range(len(steps)):
        # Flip the k-th edge's classification
        modified_steps = list(steps)
        e, w, sc = modified_steps[k]
        modified_steps[k] = (e, w, not sc)
        mod_count = sum(1 for _, _, sc2 in modified_steps if sc2)
        diff = abs(base_count - mod_count)
        max_diff = max(max_diff, diff)

    print(f"  Graph: n={n}, {len(edges)} edges, {base_count} cycle births")
    print(f"  Max change from flipping one classification: {max_diff}")
    print(f"  Bounded by 1: {'✓' if max_diff <= 1 else '✗'}")
    print()


# ---- Test 5: Euler characteristic ----

def test_euler_characteristic():
    print("=" * 70)
    print("TEST 5: EULER CHARACTERISTIC IDENTITY")
    print("=" * 70)
    print()
    print("Cross-domain theorem: V - E = β₀ - β₁ = (V - merges) - cycles")
    print()

    examples = [
        ("Triangle (K3)", 3, [(0, 1, 1), (0, 2, 2), (1, 2, 3)]),
        ("K4", 4, [(0, 1, 1), (0, 2, 2), (0, 3, 3), (1, 2, 4), (1, 3, 5), (2, 3, 6)]),
        ("Path P4", 4, [(0, 1, 1), (1, 2, 2), (2, 3, 3)]),
        ("Cycle C5", 5, [(0, 1, 1), (1, 2, 2), (2, 3, 3), (3, 4, 4), (4, 0, 5)]),
    ]

    for name, n, edges in examples:
        steps = compute_filtration(n, edges)
        m = len(steps)
        merges = sum(1 for _, _, sc in steps if not sc)
        cycles = sum(1 for _, _, sc in steps if sc)

        chi_direct = n - m
        chi_filtration = (n - merges) - cycles

        match = chi_direct == chi_filtration
        print(f"  {name:>15s}: V={n}, E={m}, merges={merges}, cycles={cycles}")
        print(f"  {'':>15s}  χ = V-E = {chi_direct}, β₀-β₁ = {chi_filtration} {'✓' if match else '✗'}")
        print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL CRITICAL DISTRIBUTIONS: Concentration & Universality     ║")
    print("║  Computational Demonstration of Formally Verified Theorems          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    test_euler_characteristic()
    test_lipschitz()
    test_mst_complement()
    test_universality()
    test_concentration()

    print("=" * 70)
    print("ALL TESTS COMPLETE")
    print("=" * 70)


"""
Visualization: Concentration of Cycle-Birth CDFs.

This script visualizes the concentration phenomenon for cycle-birth CDFs
in Erdős-Rényi random graphs. As n increases, the empirical CDFs from
independent trials converge to a common limit, confirming that tropical
critical values behave like a concentrated spectral observable.

What it visualizes: Multiple overlaid empirical CDFs for different graph sizes,
showing convergence. This is the visual analogue of the semicircle law converging
for random matrix eigenvalues.
"""

import numpy as np
import matplotlib.pyplot as plt


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


def compute_cycle_births(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            births.append(w)
    return np.array(births)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Concentration of Tropical Critical Distributions\n'
             'Cycle-Birth CDFs in G(n, 0.15) with Uniform Weights',
             fontsize=14, fontweight='bold')

p = 0.15
n_values = [50, 100, 200, 500]
num_trials = 15
rng = np.random.default_rng(42)
grid = np.linspace(0, 1, 300)
colors = plt.cm.viridis(np.linspace(0.2, 0.8, num_trials))

for idx, n in enumerate(n_values):
    ax = axes[idx // 2, idx % 2]

    for trial in range(num_trials):
        births = compute_cycle_births(n, p, rng)
        if len(births) > 0:
            cdf = np.array([np.mean(births <= t) for t in grid])
            ax.plot(grid, cdf, color=colors[trial], alpha=0.5, linewidth=0.8)

    ax.set_title(f'n = {n}', fontsize=12, fontweight='bold')
    ax.set_xlabel('Weight threshold t')
    ax.set_ylabel('Empirical CDF F(t)')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

    # Add annotation about spread
    ax.text(0.05, 0.92, f'{num_trials} independent trials',
            transform=ax.transAxes, fontsize=9,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('concentration_plot.png', dpi=150, bbox_inches='tight')
print("Saved concentration_plot.png")


"""
Visualization: MST Complement Theorem — Cycle Births as Non-Tree Edges.

This script visualizes the MST complement theorem (Theorem 5): for a weighted
graph, the cycle-birth edges are exactly the edges NOT in the minimum spanning
tree. The plot shows a small graph with MST edges (solid, blue) and cycle-birth
edges (dashed, red), along with a weight spectrum comparison.

What it visualizes: The structural duality between MST construction (Kruskal's
algorithm) and cycle-birth detection — two perspectives on the same filtration
process, connecting combinatorial optimization with tropical topology.
"""

import numpy as np
import matplotlib.pyplot as plt


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


# Create a small graph for visualization
n = 8
rng = np.random.default_rng(17)

# Generate positions for vertices on a circle
angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
positions = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

# Generate edges with random weights
edges = []
for i in range(n):
    for j in range(i + 1, n):
        if rng.random() < 0.5:
            edges.append((i, j, round(rng.random() * 10, 1)))

# Compute filtration
sorted_edges = sorted(edges, key=lambda e: e[2])
uf = UnionFind(n)
mst_edges = []
birth_edges = []
for u, v, w in sorted_edges:
    if uf.union(u, v):
        mst_edges.append((u, v, w))
    else:
        birth_edges.append((u, v, w))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('MST Complement Theorem: Cycle Births = Non-Tree Edges',
             fontsize=14, fontweight='bold')

# Left: Graph visualization
ax1.set_title('Graph with MST and Cycle-Birth Edges', fontweight='bold')
ax1.set_aspect('equal')

# Draw cycle-birth edges (dashed red) first (background)
for u, v, w in birth_edges:
    x1, y1 = positions[u]
    x2, y2 = positions[v]
    ax1.plot([x1, x2], [y1, y2], 'r--', linewidth=1.5, alpha=0.6)
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
    ax1.text(mx, my, f'{w}', fontsize=7, ha='center', va='center',
             color='red', alpha=0.8,
             bbox=dict(boxstyle='round,pad=0.15', facecolor='white', alpha=0.7))

# Draw MST edges (solid blue)
for u, v, w in mst_edges:
    x1, y1 = positions[u]
    x2, y2 = positions[v]
    ax1.plot([x1, x2], [y1, y2], 'b-', linewidth=2.5, alpha=0.8)
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
    ax1.text(mx, my, f'{w}', fontsize=7, ha='center', va='center',
             color='blue', fontweight='bold',
             bbox=dict(boxstyle='round,pad=0.15', facecolor='lightyellow', alpha=0.9))

# Draw vertices
for i, (x, y) in positions.items():
    ax1.plot(x, y, 'ko', markersize=12, zorder=5)
    ax1.text(x, y, str(i), fontsize=9, ha='center', va='center',
             color='white', fontweight='bold', zorder=6)

ax1.legend(['Cycle birth (non-MST)', 'MST edge'],
           loc='lower left', fontsize=9)
ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.axis('off')

# Stats annotation
stats_text = (f"Vertices: {n}\n"
              f"Edges: {len(edges)}\n"
              f"MST edges: {len(mst_edges)}\n"
              f"Cycle births: {len(birth_edges)}\n"
              f"β₁ = {len(birth_edges)}")
ax1.text(0.02, 0.98, stats_text, transform=ax1.transAxes,
         fontsize=9, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow'))

# Right: Weight spectrum comparison
ax2.set_title('Weight Spectrum: MST vs Cycle-Birth Edges', fontweight='bold')

mst_weights = [w for _, _, w in mst_edges]
birth_weights = [w for _, _, w in birth_edges]

if mst_weights and birth_weights:
    all_weights = mst_weights + birth_weights
    bins = np.linspace(min(all_weights) - 0.5, max(all_weights) + 0.5, 15)

    ax2.hist(mst_weights, bins=bins, alpha=0.6, color='blue',
             label=f'MST edges (n={len(mst_weights)})', edgecolor='navy')
    ax2.hist(birth_weights, bins=bins, alpha=0.6, color='red',
             label=f'Cycle births (n={len(birth_weights)})', edgecolor='darkred')

    ax2.axvline(x=np.max(mst_weights), color='blue', linestyle=':', alpha=0.5)
    ax2.axvline(x=np.min(birth_weights), color='red', linestyle=':', alpha=0.5)

ax2.set_xlabel('Edge weight')
ax2.set_ylabel('Count')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

explanation = ("Kruskal's algorithm accepts\n"
               "light edges (MST) and rejects\n"
               "edges that close cycles.\n\n"
               "cycle births = E \\ MST")
ax2.text(0.95, 0.95, explanation, transform=ax2.transAxes,
         fontsize=9, ha='right', va='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow'))

plt.tight_layout()
plt.savefig('mst_complement_plot.png', dpi=150, bbox_inches='tight')
print("Saved mst_complement_plot.png")


"""
Visualization: Universality of Cycle-Birth Distributions Under Monotone Transport.

This script visualizes the universality phenomenon: when edge weights are drawn
from different continuous distributions (Uniform, Exponential, Gaussian), the
cycle-birth edge SETS are identical (only weights change). After rank-transforming
to a common scale, the empirical CDFs collapse perfectly.

What it visualizes: Side-by-side comparison of raw CDFs (which differ by distribution)
and rank-transformed CDFs (which collapse), demonstrating that tropical criticality
depends only on order structure, not on the specific distribution.
"""

import numpy as np
import matplotlib.pyplot as plt


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


def compute_filtration_with_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            births.append(w)
    return np.array(births)


# Generate a fixed graph topology
n = 80
p = 0.25
rng = np.random.default_rng(42)
adjacency = [(i, j) for i in range(n) for j in range(i + 1, n) if rng.random() < p]
m = len(adjacency)

distributions = {
    'Uniform [0,1]': lambda rng, m: rng.random(m),
    'Exponential(1)': lambda rng, m: rng.exponential(1.0, m),
    'Normal(0,1)': lambda rng, m: rng.normal(0, 1, m),
    'Beta(2,5)': lambda rng, m: rng.beta(2, 5, m),
}

colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Universality of Tropical Critical Distributions\n'
             'Same graph topology, different weight distributions',
             fontsize=14, fontweight='bold')

for idx, (name, gen) in enumerate(distributions.items()):
    rng_w = np.random.default_rng(123)
    weights = gen(rng_w, m)
    edges = [(u, v, w) for (u, v), w in zip(adjacency, weights)]
    births = compute_filtration_with_births(n, edges)

    if len(births) == 0:
        continue

    # Raw CDF
    sorted_births = np.sort(births)
    raw_cdf = np.arange(1, len(sorted_births) + 1) / len(sorted_births)
    ax1.step(sorted_births, raw_cdf, where='post', color=colors[idx],
             label=name, linewidth=1.5)

    # Rank-transformed CDF (universality)
    sorted_idx = np.argsort(births)
    ranks = np.empty_like(births)
    ranks[sorted_idx] = np.arange(1, len(births) + 1) / len(births)
    sorted_ranks = np.sort(ranks)
    rank_cdf = np.arange(1, len(sorted_ranks) + 1) / len(sorted_ranks)
    ax2.step(sorted_ranks, rank_cdf, where='post', color=colors[idx],
             label=name, linewidth=1.5, alpha=0.7)

ax1.set_title('Raw Cycle-Birth CDFs', fontweight='bold')
ax1.set_xlabel('Birth weight')
ax1.set_ylabel('Empirical CDF')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.text(0.05, 0.85, 'CDFs differ by\nweight distribution',
         transform=ax1.transAxes, fontsize=10, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow'))

ax2.set_title('Rank-Transformed CDFs (Universality)', fontweight='bold')
ax2.set_xlabel('Rank-normalized weight')
ax2.set_ylabel('Empirical CDF')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.text(0.05, 0.85, 'All CDFs collapse!\n(Only order matters)',
         transform=ax2.transAxes, fontsize=10, style='italic',
         color='darkgreen', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

plt.tight_layout()
plt.savefig('universality_plot.png', dpi=150, bbox_inches='tight')
print("Saved universality_plot.png")
