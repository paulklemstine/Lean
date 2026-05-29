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
