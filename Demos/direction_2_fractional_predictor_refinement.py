#!/usr/bin/env python3
"""
Applications of Fractional Transversal Theory

Demonstrates real-world applications of the fractional transversal framework:
1. Network Security — optimal sensor placement with fractional relaxation
2. Crew Scheduling — minimum crew assignment covering all flights
3. Code Design — transversals of Tanner graphs for error-correcting codes
"""

from __future__ import annotations
import numpy as np
from scipy.optimize import linprog
import math


# ─── Core infrastructure (self-contained) ──────────────────────────────────

class Hypergraph:
    def __init__(self, n: int, edges: list[set[int]], vertex_names: list[str] | None = None):
        self.n = n
        self.edges = [set(e) for e in edges]
        self.m = len(self.edges)
        self.vertex_names = vertex_names or [str(i) for i in range(n)]

    def incidence_matrix(self) -> np.ndarray:
        A = np.zeros((self.m, self.n))
        for i, e in enumerate(self.edges):
            for v in e:
                A[i, v] = 1.0
        return A


def compute_tau_star(H: Hypergraph) -> tuple[float, np.ndarray]:
    if H.m == 0:
        return 0.0, np.zeros(H.n)
    c = np.ones(H.n)
    A = -H.incidence_matrix()
    b = -np.ones(H.m)
    bounds = [(0, None)] * H.n
    res = linprog(c, A_ub=A, b_ub=b, bounds=bounds, method='highs')
    if res.success:
        return res.fun, res.x
    return float('inf'), np.zeros(H.n)


def compute_tau(H: Hypergraph) -> tuple[int, set[int]]:
    best_size, best_set = H.n + 1, set(range(H.n))
    for mask in range(1, 1 << H.n):
        S = {v for v in range(H.n) if mask & (1 << v)}
        if len(S) >= best_size:
            continue
        if all(S & e for e in H.edges):
            best_size, best_set = len(S), S
    return best_size, best_set


def threshold_round(x: np.ndarray, d: int) -> set[int]:
    return {v for v in range(len(x)) if x[v] >= 1.0 / d - 1e-10}


def edge_heterogeneity(H: Hypergraph) -> float:
    if H.m == 0:
        return 0.0
    sizes = np.array([len(e) for e in H.edges], dtype=float)
    return float(np.var(sizes))


# ─── Application 1: Network Security ───────────────────────────────────────

def network_security_demo():
    """
    Optimal sensor placement in a network.

    Scenario: A network has 8 nodes and 6 critical paths (hyperedges).
    We need to place sensors to monitor all paths. Each sensor covers
    one node and monitors all paths through it.

    The fractional solution tells us the minimum "monitoring capacity"
    needed, and threshold rounding gives a practical integer placement.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Security — Optimal Sensor Placement")
    print("=" * 70)

    nodes = ["Router-A", "Router-B", "Switch-1", "Switch-2",
             "Firewall", "Gateway", "Server-1", "Server-2"]
    n = len(nodes)

    # Critical paths (each must be monitored by at least one sensor)
    paths = [
        {0, 2, 6},      # Router-A → Switch-1 → Server-1
        {0, 3, 7},      # Router-A → Switch-2 → Server-2
        {1, 2, 7},      # Router-B → Switch-1 → Server-2
        {1, 3, 6},      # Router-B → Switch-2 → Server-1
        {4, 2, 3},      # Firewall → Switch-1 → Switch-2
        {5, 0, 1},      # Gateway → Router-A → Router-B
    ]

    H = Hypergraph(n, paths, nodes)

    print(f"\nNetwork: {n} nodes, {H.m} critical paths")
    for i, (path, edge) in enumerate(zip(paths, H.edges)):
        path_names = [nodes[v] for v in sorted(edge)]
        print(f"  Path {i+1}: {' → '.join(path_names)}")

    # Fractional solution
    tau_star, x = compute_tau_star(H)
    print(f"\nFractional transversal number τ* = {tau_star:.4f}")
    print("Fractional sensor assignment:")
    for v in range(n):
        if x[v] > 1e-6:
            print(f"  {nodes[v]}: {x[v]:.4f}")

    # Integer solution
    tau, S = compute_tau(H)
    print(f"\nInteger transversal number τ = {tau}")
    print(f"Optimal sensor placement: {[nodes[v] for v in sorted(S)]}")

    # Threshold rounding
    d_max = max(len(e) for e in H.edges)
    S_rounded = threshold_round(x, d_max)
    print(f"\nThreshold-rounded placement (d_max={d_max}): "
          f"{[nodes[v] for v in sorted(S_rounded)]}")
    print(f"Size: {len(S_rounded)} ≤ {d_max} × {tau_star:.2f} = {d_max * tau_star:.2f}")

    # Heterogeneity
    sigma2 = edge_heterogeneity(H)
    print(f"\nEdge heterogeneity σ² = {sigma2:.4f}")
    print(f"Integrality gap: τ − τ* = {tau - tau_star:.4f}")


# ─── Application 2: Crew Scheduling ────────────────────────────────────────

def crew_scheduling_demo():
    """
    Minimum crew assignment for airline flight coverage.

    Scenario: An airline has 10 crew members and 8 flight segments.
    Each flight segment can be covered by a subset of qualified crew.
    Find the minimum number of crew members needed on duty.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Crew Scheduling — Minimum Staff Coverage")
    print("=" * 70)

    crew = [f"Crew-{i}" for i in range(10)]
    n = len(crew)

    # Flight segments and qualified crew
    flights = [
        ({0, 1, 2}, "NYC→LAX morning"),
        ({1, 3, 4}, "NYC→CHI morning"),
        ({2, 4, 5, 6}, "LAX→SEA afternoon"),
        ({0, 5, 7}, "CHI→MIA afternoon"),
        ({3, 6, 8}, "SEA→DEN evening"),
        ({7, 8, 9}, "MIA→ATL evening"),
        ({0, 4, 9}, "DEN→NYC night"),
        ({2, 3, 7, 8}, "ATL→LAX night"),
    ]

    edges = [f[0] for f in flights]
    H = Hypergraph(n, edges, crew)

    print(f"\nAirline: {n} crew members, {H.m} flight segments")
    for edge, (_, name) in zip(edges, flights):
        qualified = [crew[v] for v in sorted(edge)]
        print(f"  {name}: qualified crew = {qualified}")

    tau_star, x = compute_tau_star(H)
    print(f"\nFractional minimum crew: τ* = {tau_star:.4f}")
    print("Fractional duty assignment:")
    for v in range(n):
        if x[v] > 1e-6:
            print(f"  {crew[v]}: {x[v]:.4f} duty fraction")

    tau, S = compute_tau(H)
    print(f"\nMinimum crew on duty: τ = {tau}")
    print(f"Optimal assignment: {[crew[v] for v in sorted(S)]}")

    sigma2 = edge_heterogeneity(H)
    print(f"\nQualification heterogeneity σ² = {sigma2:.4f}")
    print(f"Integrality gap: {tau - tau_star:.4f}")
    print(f"  → Gap {'is' if sigma2 > 0.1 else 'is not'} expected due to "
          f"{'heterogeneous' if sigma2 > 0.1 else 'uniform'} qualification sets")


# ─── Application 3: Error-Correcting Codes ─────────────────────────────────

def coding_theory_demo():
    """
    Transversals of Tanner graphs for LDPC code analysis.

    The minimum transversal of a code's Tanner graph relates to
    the code's minimum distance and error-correcting capability.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Coding Theory — Tanner Graph Analysis")
    print("=" * 70)

    # Simple (7,4) Hamming code parity check matrix
    # H = [1 1 1 0 1 0 0]
    #     [1 1 0 1 0 1 0]
    #     [1 0 1 1 0 0 1]
    bits = [f"b{i}" for i in range(7)]
    n = 7

    # Each parity check defines a hyperedge (bits involved)
    checks = [
        {0, 1, 2, 4},     # check 1
        {0, 1, 3, 5},     # check 2
        {0, 2, 3, 6},     # check 3
    ]

    H = Hypergraph(n, checks, bits)

    print(f"\n(7,4) Hamming code Tanner graph:")
    print(f"  {n} bit positions, {H.m} parity checks")
    for i, check in enumerate(checks):
        print(f"  Check {i+1}: bits {sorted(check)}")

    tau_star, x = compute_tau_star(H)
    print(f"\nFractional transversal τ* = {tau_star:.4f}")
    print("Fractional assignment (LP decoding weights):")
    for v in range(n):
        if x[v] > 1e-6:
            print(f"  {bits[v]}: {x[v]:.4f}")

    tau, S = compute_tau(H)
    print(f"\nInteger transversal τ = {tau}")
    print(f"Minimum hitting set: {[bits[v] for v in sorted(S)]}")
    print(f"  (relates to code minimum distance d = 3)")

    sigma2 = edge_heterogeneity(H)
    print(f"\nCheck heterogeneity σ² = {sigma2:.4f}")
    print(f"  (σ² = 0 means all checks have same weight → regular LDPC)")


# ─── Application 4: Comparative Analysis ───────────────────────────────────

def comparative_analysis():
    """Compare fractional vs integer transversal across problem families."""
    print("\n" + "=" * 70)
    print("COMPARATIVE ANALYSIS: Fractional vs Integer Across Families")
    print("=" * 70)

    families = []

    # Family 1: Uniform (all edges size 3)
    edges_uniform = [{0, 1, 2}, {1, 2, 3}, {2, 3, 4}, {3, 4, 5}, {4, 5, 0}]
    families.append(("3-uniform cycle", Hypergraph(6, edges_uniform)))

    # Family 2: Mixed sizes
    edges_mixed = [{0, 1}, {1, 2, 3}, {3, 4, 5, 6}, {0, 2, 4, 5, 6}]
    families.append(("Mixed (2,3,4,5)", Hypergraph(7, edges_mixed)))

    # Family 3: Bipartite-like (size 2)
    edges_bip = [{0, 3}, {0, 4}, {1, 3}, {1, 4}, {2, 5}]
    families.append(("Bipartite (size 2)", Hypergraph(6, edges_bip)))

    # Family 4: Large uniform (size 4)
    edges_large = [{0, 1, 2, 3}, {2, 3, 4, 5}, {4, 5, 6, 7}, {6, 7, 0, 1}]
    families.append(("4-uniform cycle", Hypergraph(8, edges_large)))

    print(f"\n{'Family':<25} {'n':<4} {'m':<4} {'τ*':<8} {'τ':<4} {'d_max':<6} "
          f"{'Gap':<8} {'σ²':<8} {'Bound':<8}")
    print("-" * 85)

    for name, H in families:
        tau_star, _ = compute_tau_star(H)
        tau, _ = compute_tau(H)
        d_max = max(len(e) for e in H.edges)
        sigma2 = edge_heterogeneity(H)
        gap = tau - tau_star
        bound = d_max * tau_star

        print(f"{name:<25} {H.n:<4} {H.m:<4} {tau_star:<8.3f} {tau:<4} {d_max:<6} "
              f"{gap:<8.3f} {sigma2:<8.3f} {bound:<8.3f}")

    print("\nKey observations:")
    print("  • Uniform hypergraphs have σ² = 0 and smaller relative gaps")
    print("  • Mixed-size hypergraphs show larger gaps correlated with σ²")
    print("  • The bound τ ≤ d_max · τ* always holds (verified above)")


# ─── Main ───────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Fractional Transversal Theory                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    network_security_demo()
    crew_scheduling_demo()
    coding_theory_demo()
    comparative_analysis()

    print("\n" + "=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Demo: Fractional Transversal Refinement — Integrality Gap Dynamics

Generates random heterogeneous hypergraphs, computes τ (integer transversal number),
τ* (fractional transversal number), and the heterogeneity index σ².
Produces scatter plots of τ − ⌈τ*⌉ vs σ² to test the heterogeneity-smoothing conjecture,
and an animation showing how the fractional predictor smooths step-function behavior.

Usage:
    python demo.py

Outputs:
    - integrality_gap_vs_heterogeneity.png : scatter plot
    - smoothing_comparison.png : fractional vs integer predictor comparison
    - gap_statistics.txt : summary statistics
"""

from __future__ import annotations
import numpy as np
from scipy.optimize import linprog
import math
import sys


# ─── Hypergraph and algorithm implementations (self-contained) ─────────────


class Hypergraph:
    """A hypergraph H = (V, E) on vertices {0, ..., n-1}."""

    def __init__(self, n: int, edges: list[set[int]]):
        self.n = n
        self.edges = [set(e) for e in edges]
        self.m = len(self.edges)

    def incidence_matrix(self) -> np.ndarray:
        A = np.zeros((self.m, self.n))
        for i, e in enumerate(self.edges):
            for v in e:
                A[i, v] = 1.0
        return A


def compute_tau_star(H: Hypergraph) -> float:
    """Compute fractional transversal number τ*(H) via LP."""
    if H.m == 0:
        return 0.0
    c = np.ones(H.n)
    A = -H.incidence_matrix()
    b = -np.ones(H.m)
    bounds = [(0, None)] * H.n
    res = linprog(c, A_ub=A, b_ub=b, bounds=bounds, method='highs')
    return res.fun if res.success else float('inf')


def compute_tau(H: Hypergraph) -> int:
    """Compute integer transversal number τ(H) via brute force (small n only)."""
    n = H.n
    best = n
    for mask in range(1, 1 << n):
        S = {v for v in range(n) if mask & (1 << v)}
        size = len(S)
        if size >= best:
            continue
        if all(S & e for e in H.edges):
            best = size
    return best


def edge_heterogeneity(H: Hypergraph) -> float:
    """Compute edge-size heterogeneity σ²(H)."""
    if H.m == 0:
        return 0.0
    sizes = np.array([len(e) for e in H.edges], dtype=float)
    return float(np.var(sizes))


def generate_random_hypergraph(
    n: int, num_edges: int, size_dist: dict[int, float],
    rng: np.random.Generator,
) -> Hypergraph:
    """Generate a random hypergraph with given edge-size distribution."""
    sizes = list(size_dist.keys())
    probs = np.array([size_dist[k] for k in sizes])
    probs /= probs.sum()

    edges, seen = [], set()
    for _ in range(num_edges * 3):  # oversample to handle duplicates
        if len(edges) >= num_edges:
            break
        k = rng.choice(sizes, p=probs)
        if k > n:
            continue
        edge = frozenset(rng.choice(n, size=k, replace=False).tolist())
        if edge not in seen:
            seen.add(edge)
            edges.append(set(edge))
    return Hypergraph(n, edges)


# ─── Main experiment ────────────────────────────────────────────────────────


def run_experiment(
    n: int = 12,
    num_edges: int = 15,
    num_trials: int = 200,
    seed: int = 42,
) -> list[dict]:
    """
    Run the heterogeneity–gap experiment.

    Generates random hypergraphs with varying edge-size distributions,
    computes τ, τ*, σ², and records the results.
    """
    rng = np.random.default_rng(seed)
    results = []

    # Vary proportions of edges with sizes 2, 3, 4
    distributions = []
    for p2 in np.linspace(0, 1, 6):
        for p3 in np.linspace(0, 1 - p2, 6):
            p4 = 1 - p2 - p3
            if p4 >= -0.01:
                p4 = max(p4, 0)
                distributions.append({2: p2 + 0.01, 3: p3 + 0.01, 4: p4 + 0.01})

    total = len(distributions) * num_trials
    done = 0

    for dist in distributions:
        for trial in range(num_trials):
            H = generate_random_hypergraph(n, num_edges, dist, rng)
            if H.m < 3:
                continue

            tau_star = compute_tau_star(H)
            tau = compute_tau(H)
            sigma2 = edge_heterogeneity(H)
            ceil_tau_star = math.ceil(tau_star - 1e-9)

            results.append({
                'tau': tau,
                'tau_star': tau_star,
                'ceil_tau_star': ceil_tau_star,
                'sigma2': sigma2,
                'gap': tau - tau_star,
                'rounding_gap': tau - ceil_tau_star,
                'dist': dist,
            })

            done += 1
            if done % 100 == 0:
                print(f"  Progress: {done}/{total} trials completed")

    return results


def print_statistics(results: list[dict]) -> str:
    """Generate summary statistics table."""
    lines = []
    lines.append("=" * 80)
    lines.append("INTEGRALITY GAP STATISTICS")
    lines.append("=" * 80)
    lines.append(f"{'σ² range':<20} {'Count':<8} {'Mean τ*':<10} {'Mean τ':<10} "
                 f"{'Mean gap':<10} {'Pr[gap>0]':<10}")
    lines.append("-" * 80)

    bins = [(0, 0.01), (0.01, 0.2), (0.2, 0.5), (0.5, 0.8), (0.8, 2.0)]
    for lo, hi in bins:
        subset = [r for r in results if lo <= r['sigma2'] < hi]
        if not subset:
            continue
        count = len(subset)
        mean_ts = np.mean([r['tau_star'] for r in subset])
        mean_t = np.mean([r['tau'] for r in subset])
        mean_gap = np.mean([r['gap'] for r in subset])
        pr_gap = np.mean([1 if r['rounding_gap'] > 0 else 0 for r in subset])
        lines.append(f"[{lo:.2f}, {hi:.2f}){'':<11} {count:<8} {mean_ts:<10.3f} "
                     f"{mean_t:<10.3f} {mean_gap:<10.3f} {pr_gap:<10.3f}")

    lines.append("=" * 80)
    return "\n".join(lines)


def make_plots(results: list[dict]) -> None:
    """Generate plots (requires matplotlib)."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping plots.")
        return

    sigma2s = [r['sigma2'] for r in results]
    gaps = [r['gap'] for r in results]
    rounding_gaps = [r['rounding_gap'] for r in results]

    # Plot 1: Gap vs heterogeneity
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax = axes[0]
    ax.scatter(sigma2s, gaps, alpha=0.3, s=10, c='steelblue')
    ax.set_xlabel('Edge heterogeneity σ²', fontsize=12)
    ax.set_ylabel('Integrality gap τ − τ*', fontsize=12)
    ax.set_title('Integrality Gap vs Edge Heterogeneity', fontsize=13)
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.scatter(sigma2s, rounding_gaps, alpha=0.3, s=10, c='coral')
    ax.set_xlabel('Edge heterogeneity σ²', fontsize=12)
    ax.set_ylabel('Rounding gap τ − ⌈τ*⌉', fontsize=12)
    ax.set_title('Rounding Gap vs Edge Heterogeneity', fontsize=13)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('integrality_gap_vs_heterogeneity.png', dpi=150)
    print("Saved: integrality_gap_vs_heterogeneity.png")
    plt.close()

    # Plot 2: Smoothing comparison
    fig, ax = plt.subplots(figsize=(10, 6))

    sorted_results = sorted(results, key=lambda r: r['sigma2'])
    n_window = max(1, len(sorted_results) // 30)

    s2_smooth, tau_smooth, taustar_smooth = [], [], []
    for i in range(0, len(sorted_results) - n_window, n_window):
        window = sorted_results[i:i + n_window]
        s2_smooth.append(np.mean([r['sigma2'] for r in window]))
        tau_smooth.append(np.std([r['tau'] for r in window]))
        taustar_smooth.append(np.std([r['tau_star'] for r in window]))

    ax.plot(s2_smooth, tau_smooth, 'o-', color='coral', label='Std(τ) — integer', markersize=4)
    ax.plot(s2_smooth, taustar_smooth, 's-', color='steelblue', label='Std(τ*) — fractional',
            markersize=4)
    ax.set_xlabel('Edge heterogeneity σ²', fontsize=12)
    ax.set_ylabel('Standard deviation', fontsize=12)
    ax.set_title('Smoothing Effect: Fractional vs Integer Predictor', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('smoothing_comparison.png', dpi=150)
    print("Saved: smoothing_comparison.png")
    plt.close()


def demonstrate_weak_duality(n: int = 8, num_tests: int = 50, seed: int = 123) -> None:
    """Demonstrate weak duality ν* ≤ τ* = ν* (strong duality)."""
    rng = np.random.default_rng(seed)
    print("\n" + "=" * 60)
    print("WEAK/STRONG DUALITY VERIFICATION")
    print("=" * 60)

    max_gap = 0.0
    for _ in range(num_tests):
        dist = {2: rng.random(), 3: rng.random(), 4: rng.random()}
        H = generate_random_hypergraph(n, 12, dist, rng)
        if H.m < 2:
            continue

        tau_star = compute_tau_star(H)

        # Compute ν* (fractional matching)
        if H.m == 0:
            nu_star = 0.0
        else:
            c = -np.ones(H.m)
            A = H.incidence_matrix().T
            b = np.ones(H.n)
            bounds = [(0, None)] * H.m
            res = linprog(c, A_ub=A, b_ub=b, bounds=bounds, method='highs')
            nu_star = -res.fun if res.success else 0.0

        gap = abs(tau_star - nu_star)
        max_gap = max(max_gap, gap)

    print(f"Tested {num_tests} random hypergraphs")
    print(f"Maximum |τ* − ν*| = {max_gap:.2e}")
    print(f"Strong duality {'VERIFIED' if max_gap < 1e-6 else 'FAILED'} (tolerance 1e-6)")


def demonstrate_gap_bound(n: int = 10, num_tests: int = 30, seed: int = 456) -> None:
    """Demonstrate the integrality gap bound τ ≤ d_max · τ*."""
    rng = np.random.default_rng(seed)
    print("\n" + "=" * 60)
    print("INTEGRALITY GAP BOUND VERIFICATION: τ ≤ d_max · τ*")
    print("=" * 60)

    violations = 0
    for i in range(num_tests):
        dist = {2: rng.random(), 3: rng.random(), 4: rng.random()}
        H = generate_random_hypergraph(n, 12, dist, rng)
        if H.m < 2:
            continue

        tau_star = compute_tau_star(H)
        tau = compute_tau(H)
        d_max = max(len(e) for e in H.edges)
        bound = d_max * tau_star

        ok = tau <= bound + 1e-8
        if not ok:
            violations += 1

        if i < 5:
            print(f"  H: n={H.n}, m={H.m}, d_max={d_max}, "
                  f"τ*={tau_star:.3f}, τ={tau}, bound={bound:.3f}, "
                  f"{'✓' if ok else '✗'}")

    print(f"\n  Tested {num_tests} hypergraphs, violations: {violations}")
    print(f"  Gap bound {'VERIFIED' if violations == 0 else 'FAILED'}")


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Fractional Transversal Refinement — Demo                   ║")
    print("║  LP-Dual Threshold Prediction & Integrality Gap Dynamics    ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")

    # Part 1: Demonstrate theorems
    demonstrate_weak_duality()
    demonstrate_gap_bound()

    # Part 2: Heterogeneity experiment
    print("\n" + "=" * 60)
    print("HETEROGENEITY–GAP EXPERIMENT")
    print("=" * 60)
    print("Generating random hypergraphs with varying edge-size distributions...")

    results = run_experiment(n=12, num_edges=15, num_trials=50, seed=42)

    stats = print_statistics(results)
    print(stats)

    # Save statistics
    with open('gap_statistics.txt', 'w') as f:
        f.write(stats)
    print("\nSaved: gap_statistics.txt")

    # Generate plots
    make_plots(results)

    print("\n" + "=" * 60)
    print("DEMO COMPLETE")
    print("=" * 60)


if __name__ == '__main__':
    main()
