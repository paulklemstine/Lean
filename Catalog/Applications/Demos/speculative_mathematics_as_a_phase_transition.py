#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of Coherence Percolation Phase Transitions

Demonstrates the core phenomenon: monotone coherence functions on knowledge graphs
exhibit sharp phase transitions at critical edge densities.
"""

import random
import math
from collections import defaultdict


class UnionFind:
    """Union-Find data structure for tracking connected components."""
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.size = [1] * n

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
        self.size[rx] += self.size[ry]
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def max_component(self):
        comp_sizes = defaultdict(int)
        for i in range(len(self.parent)):
            comp_sizes[self.find(i)] += 1
        return max(comp_sizes.values()) if comp_sizes else 0


def simulate_percolation(n, edge_order=None):
    """
    Simulate edge percolation on K_n.

    Returns: list of (edge_count, coherence) pairs
    """
    # Generate all possible edges
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]

    if edge_order is None:
        random.shuffle(edges)
    else:
        edges = [edges[i] for i in edge_order]

    uf = UnionFind(n)
    results = [(0, 1.0 / n)]  # Initial state

    for idx, (u, v) in enumerate(edges):
        uf.union(u, v)
        coherence = uf.max_component() / n
        results.append((idx + 1, coherence))

    return results


def find_critical_point(trajectory):
    """Find the critical point: first step where coherence >= 0.5."""
    for edge_count, coherence in trajectory:
        if coherence >= 0.5:
            return edge_count
    return len(trajectory)


def compute_susceptibility(trajectory):
    """Compute susceptibility (discrete derivative) at each step."""
    susc = []
    for i in range(len(trajectory) - 1):
        delta = trajectory[i+1][1] - trajectory[i][1]
        susc.append((trajectory[i][0], delta))
    return susc


def demo_sequential_merge(n=10):
    """Demo 1: Sequential merge (path-like growth)."""
    print(f"\n{'='*60}")
    print(f"Demo 1: Sequential Merge on {n} vertices")
    print(f"{'='*60}")

    uf = UnionFind(n)
    print(f"Step 0: coherence = {1/n:.4f} (each vertex isolated)")

    for k in range(n - 1):
        uf.union(k, k + 1)
        coherence = uf.max_component() / n
        print(f"Step {k+1}: coherence = {coherence:.4f} "
              f"(max component = {uf.max_component()})")

    cp = math.ceil(n / 2) - 1
    print(f"\nCritical point (coherence >= 0.5): step {cp}")
    print(f"Saturation point: step {n-1}")


def demo_sharp_transition(n=10):
    """Demo 2: The sharpest possible transition."""
    print(f"\n{'='*60}")
    print(f"Demo 2: Sharp Transition on {n} vertices")
    print(f"{'='*60}")

    print(f"Step 0: Φ = 1/{n} = {1/n:.4f}")
    print(f"Step 1: Φ = 1.0000")
    print(f"Susceptibility at step 0: {1 - 1/n:.4f}")
    print(f"Critical point: {'0' if n == 2 else '1'}")


def demo_random_percolation(n=50, num_trials=5):
    """Demo 3: Random percolation on K_n."""
    print(f"\n{'='*60}")
    print(f"Demo 3: Random Percolation on K_{n} ({num_trials} trials)")
    print(f"{'='*60}")

    critical_points = []
    for trial in range(num_trials):
        trajectory = simulate_percolation(n)
        cp = find_critical_point(trajectory)
        critical_points.append(cp)
        print(f"Trial {trial+1}: critical point at edge {cp} "
              f"(density = {cp / (n*(n-1)/2):.4f})")

    avg_cp = sum(critical_points) / len(critical_points)
    print(f"\nAverage critical point: {avg_cp:.1f} edges")
    print(f"Average critical density: {avg_cp / (n*(n-1)/2):.4f}")
    print(f"Erdős-Rényi prediction (1/n): {1/n:.4f}")
    print(f"Predicted critical edge count: {n*(n-1)/2 * (1/n):.1f}")


def demo_susceptibility_peak(n=30):
    """Demo 4: Susceptibility peak at criticality."""
    print(f"\n{'='*60}")
    print(f"Demo 4: Susceptibility Peak on K_{n}")
    print(f"{'='*60}")

    trajectory = simulate_percolation(n)
    susc = compute_susceptibility(trajectory)

    # Find peak susceptibility
    max_susc = max(susc, key=lambda x: x[1])
    cp = find_critical_point(trajectory)

    print(f"Critical point: edge {cp}")
    print(f"Peak susceptibility: {max_susc[1]:.4f} at edge {max_susc[0]}")
    print(f"Susceptibility bound (1 - 1/n): {1 - 1/n:.4f}")

    # Verify telescoping sum
    total_susc = sum(s for _, s in susc)
    expected = trajectory[-1][1] - trajectory[0][1]
    print(f"\nTelescoping sum verification:")
    print(f"  Sum of susceptibilities: {total_susc:.6f}")
    print(f"  Φ(end) - Φ(0): {expected:.6f}")
    print(f"  Match: {abs(total_susc - expected) < 1e-10}")


def demo_merge_dominance():
    """Demo 5: Merge of two systems lowers critical point."""
    print(f"\n{'='*60}")
    print(f"Demo 5: Merge Dominance")
    print(f"{'='*60}")

    n = 20
    t1 = simulate_percolation(n)
    t2 = simulate_percolation(n)

    # Merge: take max coherence at each step
    merged = [(k, max(t1[k][1], t2[k][1]))
              for k in range(min(len(t1), len(t2)))]

    cp1 = find_critical_point(t1)
    cp2 = find_critical_point(t2)
    cp_merged = find_critical_point(merged)

    print(f"System 1 critical point: {cp1}")
    print(f"System 2 critical point: {cp2}")
    print(f"Merged system critical point: {cp_merged}")
    print(f"min(cp1, cp2) = {min(cp1, cp2)}")
    print(f"Theorem: cp_merged ≤ min(cp1, cp2) → "
          f"{'✓ Verified' if cp_merged <= min(cp1, cp2) else '✗ Failed'}")


def demo_phase_regime_classification(n=20):
    """Demo 6: Phase regime classification."""
    print(f"\n{'='*60}")
    print(f"Demo 6: Phase Regime Classification (n={n})")
    print(f"{'='*60}")

    trajectory = simulate_percolation(n)

    subcritical = sum(1 for _, c in trajectory if c < 0.5)
    critical = sum(1 for _, c in trajectory if c == 0.5)
    supercritical = sum(1 for _, c in trajectory if c > 0.5)

    print(f"Subcritical steps (Φ < 1/2): {subcritical}")
    print(f"Critical steps (Φ = 1/2): {critical}")
    print(f"Supercritical steps (Φ > 1/2): {supercritical}")

    # Verify monotonicity
    coherences = [c for _, c in trajectory]
    is_monotone = all(coherences[i] <= coherences[i+1]
                      for i in range(len(coherences)-1))
    print(f"Monotonicity verified: {'✓' if is_monotone else '✗'}")

    # Verify supercritical persistence
    cp = find_critical_point(trajectory)
    persistence = all(c >= 0.5 for _, c in trajectory[cp:])
    print(f"Supercritical persistence verified: {'✓' if persistence else '✗'}")


if __name__ == "__main__":
    random.seed(42)

    demo_sequential_merge(10)
    demo_sharp_transition(10)
    demo_random_percolation(50, 5)
    demo_susceptibility_peak(30)
    demo_merge_dominance()
    demo_phase_regime_classification(20)

    print(f"\n{'='*60}")
    print("All demonstrations complete.")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
Visualization: Coherence Percolation Phase Transition

Generates a plot showing the order parameter Φ vs edge count
for random percolation on K_n, with the critical point highlighted.
"""

import random
from collections import defaultdict

try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.size = [1] * n

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
        self.size[rx] += self.size[ry]
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def max_component(self):
        sizes = defaultdict(int)
        for i in range(len(self.parent)):
            sizes[self.find(i)] += 1
        return max(sizes.values())


def simulate(n, seed=None):
    if seed is not None:
        random.seed(seed)
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    random.shuffle(edges)
    uf = UnionFind(n)
    coherence = [1.0 / n]
    for u, v in edges:
        uf.union(u, v)
        coherence.append(uf.max_component() / n)
    return coherence


def main():
    if not HAS_MPL:
        print("matplotlib not available. Skipping visualization.")
        return

    n = 100
    num_trials = 20

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Multiple trajectories
    ax1 = axes[0]
    all_cp = []
    for trial in range(num_trials):
        coh = simulate(n, seed=trial)
        edges = range(len(coh))
        density = [e / (n*(n-1)/2) for e in edges]
        ax1.plot(density, coh, alpha=0.3, color='steelblue', linewidth=0.8)
        cp = next((k for k, c in enumerate(coh) if c >= 0.5), len(coh))
        all_cp.append(cp / (n*(n-1)/2))

    ax1.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='Φ = 1/2')
    avg_cp_density = sum(all_cp) / len(all_cp)
    ax1.axvline(x=avg_cp_density, color='darkred', linestyle=':', alpha=0.7,
                label=f'Avg critical density ≈ {avg_cp_density:.3f}')
    ax1.axvline(x=1/n, color='green', linestyle=':', alpha=0.7,
                label=f'Erdős-Rényi 1/n = {1/n:.3f}')
    ax1.set_xlabel('Edge Density (edges / max edges)')
    ax1.set_ylabel('Coherence Φ')
    ax1.set_title(f'Phase Transition: {num_trials} Percolation Trials (n={n})')
    ax1.legend(fontsize=8)
    ax1.set_xlim(0, 0.15)

    # Panel 2: Susceptibility
    ax2 = axes[1]
    coh = simulate(n, seed=0)
    susc = [coh[k+1] - coh[k] for k in range(len(coh)-1)]
    density = [k / (n*(n-1)/2) for k in range(len(susc))]
    ax2.bar(density, susc, width=1/(n*(n-1)/2), alpha=0.7, color='orange')
    ax2.set_xlabel('Edge Density')
    ax2.set_ylabel('Susceptibility χ(k)')
    ax2.set_title('Susceptibility Peak at Criticality')
    ax2.set_xlim(0, 0.15)

    # Panel 3: Critical point distribution
    ax3 = axes[2]
    cp_list = []
    for trial in range(200):
        coh = simulate(n, seed=trial + 1000)
        cp = next((k for k, c in enumerate(coh) if c >= 0.5), len(coh))
        cp_list.append(cp / (n*(n-1)/2))
    ax3.hist(cp_list, bins=30, alpha=0.7, color='purple', edgecolor='black')
    ax3.axvline(x=sum(cp_list)/len(cp_list), color='red', linestyle='--',
                label=f'Mean = {sum(cp_list)/len(cp_list):.4f}')
    ax3.set_xlabel('Critical Edge Density')
    ax3.set_ylabel('Count')
    ax3.set_title(f'Distribution of Critical Points (n={n}, 200 trials)')
    ax3.legend()

    plt.tight_layout()
    plt.savefig('phase_transition_visualization.png', dpi=150)
    print("Saved: phase_transition_visualization.png")


if __name__ == "__main__":
    main()
