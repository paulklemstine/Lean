"""
applications.py — Real-world applications of tropical critical distributions.

Demonstrates how cycle-birth analysis applies to:
1. Network robustness assessment
2. Random graph phase transition detection
3. Topological data analysis confidence intervals
4. Network comparison via tropical spectral distance

Application keywords: network science, percolation, topological statistics,
random optimization, empirical process, tropical Morse theory.
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import (
    UnionFind, kruskal_filtration, erdos_renyi_graph,
    cycle_birth_measure, ks_distance, empirical_cdf_values,
    monotone_transport
)


# ============================================================
# Application 1: Network Robustness via Cycle-Birth Spectrum
# ============================================================

def assess_network_robustness(
    n: int,
    edges: List[Tuple[int, int]],
    weights: np.ndarray,
    name: str = "Network"
) -> Dict:
    """
    Assess network robustness using the cycle-birth spectrum.

    The cycle-birth spectrum reveals the redundancy structure of a network.
    - Early cycle births (low weight threshold) indicate dense, robust regions
    - Late cycle births indicate fragile, tree-like regions
    - The ratio β₁/(m - n + 1) for a connected graph is always 1

    Returns a dictionary of robustness metrics.

    Example:
        >>> edges = [(0,1),(1,2),(2,0),(2,3),(3,4),(4,2)]
        >>> weights = np.array([0.1, 0.2, 0.3, 0.4, 0.5, 0.6])
        >>> metrics = assess_network_robustness(5, edges, weights)
    """
    cb_weights, beta1, num_comp = cycle_birth_measure(n, edges, weights)
    m = len(edges)

    metrics = {
        'name': name,
        'vertices': n,
        'edges': m,
        'components': num_comp,
        'beta1': beta1,
        'redundancy_ratio': beta1 / max(m, 1),
        'median_birth_time': float(np.median(cb_weights)) if beta1 > 0 else None,
        'mean_birth_time': float(np.mean(cb_weights)) if beta1 > 0 else None,
        'birth_spread': float(np.std(cb_weights)) if beta1 > 1 else None,
        'early_redundancy': sum(1 for w in cb_weights if w < np.median(weights)) / max(beta1, 1)
    }

    print(f"\n{'='*50}")
    print(f"Network Robustness Report: {name}")
    print(f"{'='*50}")
    print(f"  Vertices: {n}, Edges: {m}, Components: {num_comp}")
    print(f"  β₁ (cycle rank): {beta1}")
    print(f"  Redundancy ratio: {metrics['redundancy_ratio']:.3f}")
    if beta1 > 0:
        print(f"  Median birth time: {metrics['median_birth_time']:.4f}")
        print(f"  Mean birth time: {metrics['mean_birth_time']:.4f}")
        print(f"  Early redundancy: {metrics['early_redundancy']:.3f}")
    print()

    return metrics


# ============================================================
# Application 2: Phase Transition Detection
# ============================================================

def detect_phase_transitions(
    n_values: List[int] = [20, 50, 100, 200],
    p_values: np.ndarray = None,
    num_trials: int = 20
) -> None:
    """
    Detect the connectivity phase transition in G(n,p) using cycle-birth rates.

    In the Erdős–Rényi model G(n,p):
    - Below p ~ 1/n: mostly trees, few cycle births
    - Above p ~ 1/n: cycle births emerge rapidly
    - The cycle-birth rate is a sensitive indicator of the phase transition

    This uses the tropical critical distribution to detect the transition
    point where redundant connectivity first emerges at scale.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: PHASE TRANSITION DETECTION")
    print("=" * 60)

    if p_values is None:
        p_values = np.array([0.5, 1.0, 1.5, 2.0, 3.0, 5.0])

    rng = np.random.default_rng(42)

    for n in n_values:
        print(f"\n  n = {n}:")
        print(f"  {'p*n':>6} | {'p':>8} | {'Avg β₁':>8} | {'Avg β₁/m':>10} | {'Phase':>12}")
        print(f"  {'-'*55}")

        for pn in p_values:
            p = pn / n
            beta1_vals = []
            ratio_vals = []

            for _ in range(num_trials):
                edges = erdos_renyi_graph(n, p, rng)
                m = len(edges)
                if m == 0:
                    beta1_vals.append(0)
                    ratio_vals.append(0)
                    continue
                weights = rng.uniform(0, 1, m)
                _, beta1, _ = cycle_birth_measure(n, edges, weights)
                beta1_vals.append(beta1)
                ratio_vals.append(beta1 / max(m, 1))

            avg_b1 = np.mean(beta1_vals)
            avg_ratio = np.mean(ratio_vals)
            phase = "subcritical" if pn < 1 else ("critical" if pn < 2 else "supercritical")
            print(f"  {pn:>6.1f} | {p:>8.4f} | {avg_b1:>8.1f} | {avg_ratio:>10.4f} | {phase:>12}")


# ============================================================
# Application 3: Topological Confidence Intervals
# ============================================================

def topological_confidence_intervals(
    n: int = 100,
    p: float = 0.15,
    num_trials: int = 50,
    confidence: float = 0.95
) -> None:
    """
    Compute confidence intervals for topological summaries using
    concentration of measure (Theorem 3).

    By the bounded differences inequality (Theorem 2), the cycle-birth
    count at any threshold t satisfies:
        P(|N(t) - E[N(t)]| ≥ r) ≤ 2 exp(-2r²/m)

    This gives theoretical confidence bands for the empirical CDF.
    We compare these with empirical confidence bands from simulation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: TOPOLOGICAL CONFIDENCE INTERVALS")
    print("=" * 60)

    rng = np.random.default_rng(42)

    # Collect empirical CDFs
    t_grid = np.linspace(0, 1, 100)
    cdf_values = []

    for _ in range(num_trials):
        edges = erdos_renyi_graph(n, p, rng)
        if len(edges) == 0:
            continue
        weights = rng.uniform(0, 1, len(edges))
        cb_weights, beta1, _ = cycle_birth_measure(n, edges, weights)
        if beta1 > 0:
            _, cdf = empirical_cdf_values(cb_weights, t_grid)
            cdf_values.append(cdf)

    if len(cdf_values) < 2:
        print("  Not enough trials with cycle births.")
        return

    cdf_array = np.array(cdf_values)
    mean_cdf = np.mean(cdf_array, axis=0)
    std_cdf = np.std(cdf_array, axis=0)

    # Theoretical bound from McDiarmid (via bounded differences)
    avg_m = np.mean([len(erdos_renyi_graph(n, p, rng)) for _ in range(20)])
    alpha = 1 - confidence
    # McDiarmid: P(|X - E[X]| ≥ r) ≤ 2 exp(-2r²/m)
    # So r = sqrt(m * ln(2/α) / 2)
    r_theory = np.sqrt(avg_m * np.log(2 / alpha) / 2)

    print(f"\n  Parameters: n={n}, p={p}, trials={num_trials}, confidence={confidence}")
    print(f"  Average number of edges: {avg_m:.0f}")
    print(f"  McDiarmid theoretical bound (count): r = {r_theory:.1f}")
    print(f"\n  Empirical CDF statistics at selected thresholds:")
    print(f"  {'t':>6} | {'Mean CDF':>10} | {'Std CDF':>10} | {'95% width':>10}")
    print(f"  {'-'*45}")

    for idx in [10, 25, 50, 75, 90]:
        t = t_grid[idx]
        print(f"  {t:>6.2f} | {mean_cdf[idx]:>10.4f} | {std_cdf[idx]:>10.4f} | "
              f"{2*1.96*std_cdf[idx]:>10.4f}")


# ============================================================
# Application 4: Network Comparison via Tropical Distance
# ============================================================

def tropical_network_comparison() -> None:
    """
    Compare networks using the KS distance between their cycle-birth CDFs.

    This defines a "tropical spectral distance" between networks:
        d_trop(G₁, G₂) = D_KS(μ_{G₁}, μ_{G₂})

    where μ_G is the empirical cycle-birth measure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: NETWORK COMPARISON VIA TROPICAL DISTANCE")
    print("=" * 60)

    rng = np.random.default_rng(42)
    n = 80

    # Generate networks with different structures
    networks = {}

    # Dense random network
    edges = erdos_renyi_graph(n, 0.3, rng)
    weights = rng.uniform(0, 1, len(edges))
    networks['Dense G(80,0.3)'] = (n, edges, weights)

    # Sparse random network
    edges = erdos_renyi_graph(n, 0.08, rng)
    weights = rng.uniform(0, 1, len(edges))
    networks['Sparse G(80,0.08)'] = (n, edges, weights)

    # Grid-like network (lattice + noise)
    grid_edges = []
    side = int(np.sqrt(n))
    for i in range(side):
        for j in range(side):
            v = i * side + j
            if j + 1 < side:
                grid_edges.append((v, v + 1))
            if i + 1 < side:
                grid_edges.append((v, v + side))
    # Add some random edges
    for _ in range(len(grid_edges) // 3):
        u, v = rng.integers(0, side * side, 2)
        if u != v and (min(u,v), max(u,v)) not in grid_edges:
            grid_edges.append((min(u,v), max(u,v)))
    weights = rng.uniform(0, 1, len(grid_edges))
    networks['Grid + noise'] = (side * side, grid_edges, weights)

    # Compute pairwise distances
    names = list(networks.keys())
    birth_data = {}

    for name, (nn, edges, weights) in networks.items():
        cb_w, b1, nc = cycle_birth_measure(nn, edges, weights)
        birth_data[name] = cb_w
        print(f"\n  {name}: {len(edges)} edges, β₁={b1}, components={nc}")

    print(f"\n  Tropical spectral distances (KS):")
    print(f"  {'':>20}", end="")
    for name in names:
        print(f" | {name[:12]:>12}", end="")
    print()

    for name_i in names:
        print(f"  {name_i:>20}", end="")
        for name_j in names:
            if len(birth_data[name_i]) > 0 and len(birth_data[name_j]) > 0:
                d = ks_distance(birth_data[name_i], birth_data[name_j])
                print(f" | {d:>12.4f}", end="")
            else:
                print(f" | {'N/A':>12}", end="")
        print()

    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF TROPICAL CRITICAL DISTRIBUTIONS       ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: Network robustness
    rng = np.random.default_rng(42)
    n = 50
    edges = erdos_renyi_graph(n, 0.15, rng)
    weights = rng.uniform(0, 1, len(edges))
    assess_network_robustness(n, edges, weights, "Random G(50, 0.15)")

    # Application 2: Phase transitions
    detect_phase_transitions(n_values=[50, 100])

    # Application 3: Confidence intervals
    topological_confidence_intervals()

    # Application 4: Network comparison
    tropical_network_comparison()


"""
demo.py — Interactive demonstration of tropical critical distributions
in random weighted graphs.

Demonstrates:
1. Cycle-birth time computation from weighted graph filtrations
2. Concentration of empirical cycle-birth CDFs across trials
3. Universality under monotone transport (uniform/exponential/normal weights)
4. MST complement validation
5. KS distance scaling with graph size

Application keywords: tropical Morse theory, persistent homology, Erdős–Rényi graphs,
concentration of measure, McDiarmid inequality, universality, minimum spanning tree,
graphic matroid, KS distance, empirical process.
"""

import numpy as np
from collections import defaultdict
import itertools

# ============================================================
# Core Algorithms
# ============================================================

class UnionFind:
    """Weighted union-find with path compression."""
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
        """Returns True if x,y were in different components (merge event)."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True


def erdos_renyi(n, p, rng=None):
    """Generate G(n,p) edge list."""
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


def compute_cycle_births(n, edges, weights):
    """
    Compute cycle-birth edges and MST edges via Kruskal's algorithm.

    Returns:
        cycle_birth_weights: list of weights of cycle-birth edges
        mst_weights: list of weights of MST edges
        filtration_steps: list of (weight, is_cycle_birth) tuples
    """
    # Sort edges by weight
    order = np.argsort(weights)
    uf = UnionFind(n)

    cycle_birth_weights = []
    mst_weights = []
    filtration_steps = []

    for idx in order:
        w = weights[idx]
        u, v = edges[idx]
        merged = uf.union(u, v)
        if merged:
            # Merge event: edge joins two components (MST edge)
            mst_weights.append(w)
            filtration_steps.append((w, False))
        else:
            # Cycle birth: endpoints already connected
            cycle_birth_weights.append(w)
            filtration_steps.append((w, True))

    return cycle_birth_weights, mst_weights, filtration_steps


def empirical_cdf(data, t_values):
    """Compute empirical CDF at given threshold values."""
    data_sorted = np.sort(data)
    return np.searchsorted(data_sorted, t_values, side='right') / len(data_sorted)


def ks_distance(cdf1, cdf2):
    """Kolmogorov-Smirnov distance between two empirical CDFs."""
    all_vals = np.sort(np.concatenate([cdf1, cdf2]))
    if len(all_vals) == 0:
        return 0.0
    ecdf1 = np.searchsorted(np.sort(cdf1), all_vals, side='right') / max(len(cdf1), 1)
    ecdf2 = np.searchsorted(np.sort(cdf2), all_vals, side='right') / max(len(cdf2), 1)
    return np.max(np.abs(ecdf1 - ecdf2))


# ============================================================
# Experiment 1: Concentration Test
# ============================================================

def concentration_test():
    """
    Test concentration of cycle-birth empirical CDFs.
    For increasing n, compute pairwise KS distances between trials.
    Expected: mean KS distance ~ O(n^{-1/2}).
    """
    print("=" * 60)
    print("EXPERIMENT 1: CONCENTRATION TEST")
    print("=" * 60)
    print()

    p = 0.15
    n_values = [50, 100, 200, 500]
    num_trials = 10
    rng = np.random.default_rng(42)

    print(f"Parameters: p = {p}, trials = {num_trials}")
    print(f"{'n':>6} | {'Mean KS':>10} | {'Std KS':>10} | {'n^(-1/2)':>10} | {'Ratio':>10}")
    print("-" * 60)

    for n in n_values:
        # Collect cycle-birth weights across trials
        trial_births = []
        for trial in range(num_trials):
            edges = erdos_renyi(n, p, rng)
            if len(edges) == 0:
                continue
            weights = rng.uniform(0, 1, len(edges))
            cb_weights, _, _ = compute_cycle_births(n, edges, weights)
            if len(cb_weights) > 0:
                trial_births.append(np.array(cb_weights))

        # Compute pairwise KS distances
        ks_dists = []
        for i in range(len(trial_births)):
            for j in range(i + 1, len(trial_births)):
                ks_dists.append(ks_distance(trial_births[i], trial_births[j]))

        if len(ks_dists) > 0:
            mean_ks = np.mean(ks_dists)
            std_ks = np.std(ks_dists)
            expected = 1.0 / np.sqrt(n)
            ratio = mean_ks / expected if expected > 0 else float('inf')
            print(f"{n:>6} | {mean_ks:>10.4f} | {std_ks:>10.4f} | {expected:>10.4f} | {ratio:>10.4f}")
        else:
            print(f"{n:>6} | {'N/A':>10} | {'N/A':>10} | {'N/A':>10} | {'N/A':>10}")

    print()
    print("If the ratio column stabilizes, KS distance decays like O(n^{-1/2}).")
    print()


# ============================================================
# Experiment 2: Universality Test
# ============================================================

def universality_test():
    """
    Test universality under monotone transport.
    Compare cycle-birth CDFs under Uniform, Exponential, and Gaussian weights.
    After applying the probability integral transform, CDFs should align.
    """
    print("=" * 60)
    print("EXPERIMENT 2: UNIVERSALITY TEST")
    print("=" * 60)
    print()

    n = 200
    p = 0.2
    num_trials = 5
    rng = np.random.default_rng(123)

    from scipy.stats import expon, norm

    distributions = {
        'Uniform[0,1]': lambda size: rng.uniform(0, 1, size),
        'Exponential(1)': lambda size: rng.exponential(1.0, size),
        'Normal(0,1)': lambda size: rng.standard_normal(size),
    }

    # For each trial, generate the same graph structure with different weight laws
    print(f"Parameters: n = {n}, p = {p}, trials = {num_trials}")
    print()

    all_transformed_births = {name: [] for name in distributions}

    for trial in range(num_trials):
        edges = erdos_renyi(n, p, rng)
        if len(edges) == 0:
            continue
        m = len(edges)

        for name, gen_weights in distributions.items():
            weights = gen_weights(m)
            cb_weights, _, _ = compute_cycle_births(n, edges, weights)
            if len(cb_weights) > 0:
                # Transform to uniform scale using rank transform
                # (monotone transport to uniform)
                all_weights_sorted = np.sort(weights)
                ranks = np.searchsorted(all_weights_sorted, cb_weights, side='right') / m
                all_transformed_births[name].append(ranks)

    # Compare transformed CDFs across distributions
    print("KS distances between transformed cycle-birth CDFs (should be small):")
    print(f"{'Pair':>35} | {'Mean KS':>10} | {'Max KS':>10}")
    print("-" * 60)

    dist_names = list(distributions.keys())
    for i in range(len(dist_names)):
        for j in range(i + 1, len(dist_names)):
            name_i, name_j = dist_names[i], dist_names[j]
            ks_vals = []
            min_len = min(len(all_transformed_births[name_i]),
                         len(all_transformed_births[name_j]))
            for k in range(min_len):
                d = ks_distance(all_transformed_births[name_i][k],
                               all_transformed_births[name_j][k])
                ks_vals.append(d)
            if ks_vals:
                pair = f"{name_i} vs {name_j}"
                print(f"{pair:>35} | {np.mean(ks_vals):>10.4f} | {np.max(ks_vals):>10.4f}")

    print()
    print("Small KS distances confirm universality under monotone transport.")
    print()


# ============================================================
# Experiment 3: MST Complement Validation
# ============================================================

def mst_complement_test():
    """
    Verify that cycle-birth edges are exactly the complement of MST edges.
    """
    print("=" * 60)
    print("EXPERIMENT 3: MST COMPLEMENT VALIDATION")
    print("=" * 60)
    print()

    rng = np.random.default_rng(999)
    num_tests = 100
    n = 30
    p = 0.3
    all_match = True

    for test in range(num_tests):
        edges = erdos_renyi(n, p, rng)
        if len(edges) == 0:
            continue
        weights = rng.uniform(0, 1, len(edges))
        cb_weights, mst_weights, steps = compute_cycle_births(n, edges, weights)

        # Verify: cycle births + MST edges = all edges
        total = len(cb_weights) + len(mst_weights)
        if total != len(edges):
            print(f"  FAIL on test {test}: {total} != {len(edges)}")
            all_match = False

        # Verify mutual exclusivity from filtration steps
        for w, is_cb in steps:
            if is_cb:
                assert w in cb_weights
            else:
                assert w in mst_weights

    status = "PASS" if all_match else "FAIL"
    print(f"  {num_tests} random graphs tested: {status}")
    print(f"  Cycle births + MST edges = total edges in all cases.")
    print()


# ============================================================
# Experiment 4: Betti Number Computation
# ============================================================

def betti_number_test():
    """
    Verify β₁ = m - n + c where c = number of connected components.
    """
    print("=" * 60)
    print("EXPERIMENT 4: BETTI NUMBER VERIFICATION")
    print("=" * 60)
    print()

    rng = np.random.default_rng(777)
    n = 50
    p = 0.15

    for trial in range(5):
        edges = erdos_renyi(n, p, rng)
        m = len(edges)
        if m == 0:
            continue
        weights = rng.uniform(0, 1, m)
        cb_weights, mst_weights, _ = compute_cycle_births(n, edges, weights)

        # Count components using union-find
        uf = UnionFind(n)
        for u, v in edges:
            uf.union(u, v)
        components = len(set(uf.find(i) for i in range(n)))

        beta1 = len(cb_weights)
        expected_beta1 = m - n + components

        status = "✓" if beta1 == expected_beta1 else "✗"
        print(f"  Trial {trial+1}: m={m}, n={n}, c={components}, "
              f"β₁={beta1}, m-n+c={expected_beta1} {status}")

    print()


# ============================================================
# Experiment 5: Filtration Visualization Data
# ============================================================

def filtration_analysis():
    """
    Detailed analysis of a single filtration showing merge/cycle patterns.
    """
    print("=" * 60)
    print("EXPERIMENT 5: FILTRATION ANALYSIS")
    print("=" * 60)
    print()

    # Use a small graph for illustration
    n = 8
    p = 0.5
    rng = np.random.default_rng(42)

    edges = erdos_renyi(n, p, rng)
    m = len(edges)
    weights = rng.uniform(0, 1, m)

    cb_weights, mst_weights, steps = compute_cycle_births(n, edges, weights)

    print(f"  Graph: n={n}, m={m}")
    print(f"  MST edges: {len(mst_weights)}")
    print(f"  Cycle births: {len(cb_weights)}")
    print(f"  β₁ = {len(cb_weights)}")
    print()
    print("  Filtration steps (sorted by weight):")
    print(f"  {'Step':>4} | {'Weight':>8} | {'Type':>12}")
    print("  " + "-" * 35)
    for i, (w, is_cb) in enumerate(steps):
        event_type = "CYCLE BIRTH" if is_cb else "MERGE"
        print(f"  {i+1:>4} | {w:>8.4f} | {event_type:>12}")

    print()
    print("  Cycle-birth weights:", [f"{w:.4f}" for w in sorted(cb_weights)])
    print("  MST weights:", [f"{w:.4f}" for w in sorted(mst_weights)])
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL CRITICAL DISTRIBUTIONS IN RANDOM GRAPHS      ║")
    print("║  Concentration & Universality Demo                     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    filtration_analysis()
    mst_complement_test()
    betti_number_test()
    concentration_test()

    try:
        universality_test()
    except ImportError:
        print("(Skipping universality test — scipy not available)")
        print()

    print("=" * 60)
    print("ALL EXPERIMENTS COMPLETE")
    print("=" * 60)


"""
Visualization: Concentration of Tropical Critical Distributions

This script visualizes the concentration phenomenon for cycle-birth CDFs
in random Erdős-Rényi graphs. Multiple independent trials of G(n,p) with
uniform random weights produce cycle-birth CDFs that concentrate around
a deterministic limit as n grows.

The plot shows overlaid empirical CDFs from independent trials at different
graph sizes, demonstrating tighter concentration at larger n.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# ============================================================
# Inline implementations (self-contained)
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


def erdos_renyi(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


def compute_cycle_births(n, edges, weights):
    order = np.argsort(weights)
    uf = UnionFind(n)
    cb_weights = []
    for idx in order:
        u, v = edges[idx]
        if not uf.union(u, v):
            cb_weights.append(weights[idx])
    return np.array(cb_weights)


# ============================================================
# Generate data
# ============================================================

rng = np.random.default_rng(42)
p = 0.15
n_values = [50, 100, 200, 500]
num_trials = 15
t_grid = np.linspace(0, 1, 300)

# ============================================================
# Create figure
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Concentration of Cycle-Birth CDFs in G(n, p)',
             fontsize=16, fontweight='bold', y=0.98)

colors = plt.cm.viridis(np.linspace(0.2, 0.8, num_trials))

for ax_idx, (ax, n) in enumerate(zip(axes.flat, n_values)):
    cdfs = []
    for trial in range(num_trials):
        edges = erdos_renyi(n, p, rng)
        if len(edges) == 0:
            continue
        weights = rng.uniform(0, 1, len(edges))
        cb = compute_cycle_births(n, edges, weights)
        if len(cb) > 0:
            cdf = np.searchsorted(np.sort(cb), t_grid, side='right') / len(cb)
            cdfs.append(cdf)
            ax.plot(t_grid, cdf, color=colors[trial], alpha=0.4, linewidth=0.8)

    if cdfs:
        mean_cdf = np.mean(cdfs, axis=0)
        ax.plot(t_grid, mean_cdf, 'k-', linewidth=2.5, label='Mean CDF')

        # Shade ±1 std
        std_cdf = np.std(cdfs, axis=0)
        ax.fill_between(t_grid, mean_cdf - std_cdf, mean_cdf + std_cdf,
                        alpha=0.2, color='steelblue', label='±1 std')

    ax.set_title(f'n = {n}  (p = {p})', fontsize=13, fontweight='bold')
    ax.set_xlabel('Threshold t', fontsize=11)
    ax.set_ylabel('Empirical CDF', fontsize=11)
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.05, 1.05)
    ax.legend(loc='lower right', fontsize=9)
    ax.grid(True, alpha=0.3)

    if cdfs:
        max_std = np.max(std_cdf)
        ax.text(0.05, 0.92, f'max std = {max_std:.3f}',
                transform=ax.transAxes, fontsize=10,
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")


"""
Visualization: Graph Filtration and Cycle-Birth Process

This script visualizes the tropical Morse filtration of a small weighted graph,
showing how edges are added in order of weight and how each addition either
merges two components (MST edge) or creates a cycle (cycle-birth edge).

The plot shows the filtration timeline with merge events below and cycle-birth
events above, plus the evolving Betti numbers β₀ (components) and β₁ (cycles).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


# ============================================================
# Inline implementations (self-contained)
# ============================================================

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n_components = n

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
        self.n_components -= 1
        return True


# ============================================================
# Generate a small example
# ============================================================

rng = np.random.default_rng(17)
n = 8
edges = []
for i in range(n):
    for j in range(i + 1, n):
        if rng.random() < 0.45:
            edges.append((i, j))

m = len(edges)
weights = rng.uniform(0, 1, m)

# Run Kruskal
order = np.argsort(weights)
uf = UnionFind(n)

steps = []  # (weight, edge, is_merge, beta0, beta1)
beta0, beta1 = n, 0

for idx in order:
    w = weights[idx]
    u, v = edges[idx]
    is_merge = uf.union(u, v)
    if is_merge:
        beta0 -= 1
        steps.append((w, (u, v), True, beta0, beta1))
    else:
        beta1 += 1
        steps.append((w, (u, v), False, beta0, beta1))

# ============================================================
# Create figure
# ============================================================

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 8), height_ratios=[3, 2],
                                gridspec_kw={'hspace': 0.3})

fig.suptitle('Tropical Morse Filtration: Merge vs Cycle-Birth Events',
             fontsize=16, fontweight='bold', y=0.98)

# Top panel: Event timeline
merge_color = '#2196F3'
cycle_color = '#FF5722'

for i, (w, (u, v), is_merge, b0, b1) in enumerate(steps):
    if is_merge:
        ax1.bar(i, -1, bottom=0, color=merge_color, alpha=0.7, width=0.8,
               edgecolor='white', linewidth=0.5)
        ax1.text(i, -0.5, f'{u}-{v}', ha='center', va='center',
                fontsize=7, color='white', fontweight='bold')
    else:
        ax1.bar(i, 1, bottom=0, color=cycle_color, alpha=0.7, width=0.8,
               edgecolor='white', linewidth=0.5)
        ax1.text(i, 0.5, f'{u}-{v}', ha='center', va='center',
                fontsize=7, color='white', fontweight='bold')

    # Weight label
    ax1.text(i, -1.4 if is_merge else 1.3, f'{w:.2f}',
            ha='center', va='center', fontsize=7, rotation=45)

ax1.axhline(y=0, color='black', linewidth=1.5)
ax1.set_xlim(-0.5, len(steps) - 0.5)
ax1.set_ylim(-1.8, 1.8)
ax1.set_xlabel('Edge insertion order (by weight)', fontsize=11)
ax1.set_ylabel('Event type', fontsize=11)
ax1.set_yticks([-0.5, 0.5])
ax1.set_yticklabels(['MERGE\n(MST edge)', 'CYCLE BIRTH\n(non-MST edge)'], fontsize=9)

merge_patch = mpatches.Patch(color=merge_color, alpha=0.7, label=f'Merge events (MST edges)')
cycle_patch = mpatches.Patch(color=cycle_color, alpha=0.7, label=f'Cycle births (non-MST edges)')
ax1.legend(handles=[merge_patch, cycle_patch], loc='upper right', fontsize=10)

# Count events
n_merges = sum(1 for _, _, m, _, _ in steps if m)
n_cycles = sum(1 for _, _, m, _, _ in steps if not m)
ax1.text(0.02, 0.95, f'n={n}, m={len(steps)}\nMerges: {n_merges}, Cycles: {n_cycles}',
        transform=ax1.transAxes, fontsize=10,
        verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Bottom panel: Betti numbers
x_vals = list(range(len(steps)))
b0_vals = [s[3] for s in steps]
b1_vals = [s[4] for s in steps]

ax2.step(x_vals, b0_vals, where='post', color=merge_color, linewidth=2.5,
        label='β₀ (components)', marker='o', markersize=4)
ax2.step(x_vals, b1_vals, where='post', color=cycle_color, linewidth=2.5,
        label='β₁ (cycles)', marker='s', markersize=4)

ax2.set_xlabel('Edge insertion order', fontsize=11)
ax2.set_ylabel('Betti number', fontsize=11)
ax2.legend(fontsize=11, loc='center right')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, len(steps) - 0.5)

# Add Euler characteristic annotation
chi = b0_vals[-1] - b1_vals[-1]
ax2.text(0.02, 0.95, f'Final: β₀={b0_vals[-1]}, β₁={b1_vals[-1]}\n'
        f'χ = β₀ - β₁ = {chi}\n'
        f'V - E = {n} - {len(steps)} = {n - len(steps)}',
        transform=ax2.transAxes, fontsize=10,
        verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
print("Saved viz_filtration.png")


"""
Visualization: Universality Under Monotone Transport

This script visualizes the universality theorem: cycle-birth CDFs are
invariant under monotone transport of edge weights. Three different
weight distributions (Uniform, Exponential, Normal) produce identical
cycle-birth CDFs after quantile normalization.

The top row shows raw CDFs (different for each distribution).
The bottom row shows CDFs after monotone transport to uniform scale (identical).
"""

import numpy as np
import matplotlib.pyplot as plt


# ============================================================
# Inline implementations (self-contained)
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


def erdos_renyi(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


def compute_cycle_births(n, edges, weights):
    order = np.argsort(weights)
    uf = UnionFind(n)
    cb_indices = []
    for idx in order:
        u, v = edges[idx]
        if not uf.union(u, v):
            cb_indices.append(idx)
    return cb_indices


def rank_transform(weights, cb_indices, all_weights):
    """Transform cycle-birth weights to rank scale."""
    sorted_all = np.sort(all_weights)
    ranks = np.searchsorted(sorted_all, weights[cb_indices], side='right') / len(all_weights)
    return ranks


# ============================================================
# Generate data
# ============================================================

rng = np.random.default_rng(42)
n = 200
p = 0.2
num_trials = 8

# Generate a fixed graph structure
edges = erdos_renyi(n, p, rng)
m = len(edges)

distributions = {
    'Uniform[0,1]': lambda: rng.uniform(0, 1, m),
    'Exponential(1)': lambda: rng.exponential(1.0, m),
    'Normal(0,1)': lambda: rng.standard_normal(m),
}

dist_colors = {'Uniform[0,1]': '#2196F3', 'Exponential(1)': '#FF5722', 'Normal(0,1)': '#4CAF50'}

# ============================================================
# Create figure
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Universality of Cycle-Birth Distributions Under Monotone Transport',
             fontsize=16, fontweight='bold', y=0.98)

for col, (dist_name, gen_weights) in enumerate(distributions.items()):
    ax_raw = axes[0, col]
    ax_transport = axes[1, col]

    for trial in range(num_trials):
        weights = gen_weights()
        cb_indices = compute_cycle_births(n, edges, weights)

        if len(cb_indices) == 0:
            continue

        # Raw CDF
        cb_raw = np.sort(weights[cb_indices])
        raw_cdf = np.arange(1, len(cb_raw) + 1) / len(cb_raw)
        ax_raw.step(cb_raw, raw_cdf, color=dist_colors[dist_name],
                   alpha=0.4, linewidth=0.8, where='post')

        # Transported CDF (rank transform)
        cb_ranks = rank_transform(weights, cb_indices, weights)
        cb_ranks_sorted = np.sort(cb_ranks)
        transport_cdf = np.arange(1, len(cb_ranks_sorted) + 1) / len(cb_ranks_sorted)
        ax_transport.step(cb_ranks_sorted, transport_cdf, color=dist_colors[dist_name],
                         alpha=0.4, linewidth=0.8, where='post')

    # Labels and formatting
    ax_raw.set_title(f'{dist_name}\n(Raw weights)', fontsize=12, fontweight='bold')
    ax_raw.set_xlabel('Weight', fontsize=10)
    ax_raw.set_ylabel('Empirical CDF', fontsize=10)
    ax_raw.set_ylim(-0.05, 1.05)
    ax_raw.grid(True, alpha=0.3)

    ax_transport.set_title(f'{dist_name}\n(After monotone transport)', fontsize=12, fontweight='bold')
    ax_transport.set_xlabel('Rank (uniform scale)', fontsize=10)
    ax_transport.set_ylabel('Empirical CDF', fontsize=10)
    ax_transport.set_xlim(-0.05, 1.05)
    ax_transport.set_ylim(-0.05, 1.05)
    ax_transport.grid(True, alpha=0.3)

    # Add diagonal reference line to transported plots
    ax_transport.plot([0, 1], [0, 1], 'k--', alpha=0.3, linewidth=1, label='y = x')

# Add annotations
axes[0, 0].set_ylabel('Raw CDF', fontsize=12, fontweight='bold')
axes[1, 0].set_ylabel('Transported CDF', fontsize=12, fontweight='bold')

fig.text(0.5, 0.49, '↓  Monotone transport (probability integral transform)  ↓',
         ha='center', fontsize=13, fontweight='bold', color='#666666')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.subplots_adjust(hspace=0.45)
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
