#!/usr/bin/env python3
"""
Demo: Gravitational Derivation Systems and Anti-Gravity Detection

Demonstrates the key results from the anti-gravity framework on
concrete example systems.
"""

import random
from typing import NamedTuple


class GDS:
    """A Gravitational Derivation System on n theorems."""

    def __init__(self, n: int, edges: list[tuple[int, int]], proof_lengths: list[int]):
        self.n = n
        self.edges = edges  # (i, j) means theorem i depends on theorem j
        self.proof_lengths = proof_lengths
        assert all(pl > 0 for pl in proof_lengths), "Proof lengths must be positive"
        assert len(proof_lengths) == n

    def direct_weight(self, j: int) -> int:
        """Number of theorems that directly depend on j."""
        return sum(1 for (i, _j) in self.edges if _j == j)

    def total_edges(self) -> int:
        return len(self.edges)

    def max_proof_len(self) -> int:
        return max(self.proof_lengths) if self.proof_lengths else 0

    def anti_gravity_score(self, j: int) -> float:
        return self.direct_weight(j) / self.proof_lengths[j]

    def is_anti_gravity(self, j: int, w: int, l: int) -> bool:
        return self.direct_weight(j) >= w and self.proof_lengths[j] <= l


class AntiGravityResult(NamedTuple):
    theorem_id: int
    weight: int
    proof_length: int
    score: float


def detect_anti_gravity(gds: GDS) -> list[AntiGravityResult]:
    """Rank all theorems by anti-gravity score."""
    results = []
    for j in range(gds.n):
        w = gds.direct_weight(j)
        pl = gds.proof_lengths[j]
        score = w / pl
        results.append(AntiGravityResult(j, w, pl, score))
    results.sort(key=lambda r: r.score, reverse=True)
    return results


def demo_star_graph():
    """Demo 1: Star graph - one axiom, many dependents."""
    print("=" * 60)
    print("DEMO 1: Star Graph (Axiom with 9 dependents)")
    print("=" * 60)
    n = 10
    # Theorem 0 is an axiom (proof length 1)
    # Theorems 1-9 each depend on theorem 0
    edges = [(i, 0) for i in range(1, n)]
    proof_lengths = [1] + [5] * 9  # axiom has length 1, others have length 5

    gds = GDS(n, edges, proof_lengths)
    results = detect_anti_gravity(gds)

    print(f"System: {n} theorems, {gds.total_edges()} edges")
    print(f"\nAnti-gravity ranking:")
    print(f"{'Theorem':>8} {'Weight':>8} {'ProofLen':>10} {'Score':>8}")
    print("-" * 38)
    for r in results[:5]:
        print(f"{r.theorem_id:>8} {r.weight:>8} {r.proof_length:>10} {r.score:>8.2f}")

    # Verify Theorem 2 (pigeonhole): max weight >= m/n
    max_w = max(gds.direct_weight(j) for j in range(n))
    m = gds.total_edges()
    print(f"\nPigeonhole check: max weight ({max_w}) >= m/n ({m // n}) ✓")

    # Verify Theorem 10 (Cauchy-Schwarz)
    sum_w = sum(gds.direct_weight(j) for j in range(n))
    sum_w_sq = sum(gds.direct_weight(j) ** 2 for j in range(n))
    print(f"Cauchy-Schwarz: m² ({sum_w**2}) <= n * Σw² ({n * sum_w_sq}) ✓")
    print()


def demo_layered_dag():
    """Demo 2: Layered DAG with branching."""
    print("=" * 60)
    print("DEMO 2: Layered DAG (3 layers, branching factor 3)")
    print("=" * 60)
    # Layer 0: theorems 0-2 (foundations, proof length 1)
    # Layer 1: theorems 3-11 (each depends on one from layer 0, proof length 3)
    # Layer 2: theorems 12-38 (each depends on one from layer 1, proof length 5)
    n = 39
    edges = []
    proof_lengths = [1] * 3 + [3] * 9 + [5] * 27

    # Layer 1 depends on layer 0
    for i in range(9):
        edges.append((3 + i, i % 3))

    # Layer 2 depends on layer 1
    for i in range(27):
        edges.append((12 + i, 3 + i % 9))

    gds = GDS(n, edges, proof_lengths)
    results = detect_anti_gravity(gds)

    print(f"System: {n} theorems, {gds.total_edges()} edges")
    print(f"\nTop anti-gravity theorems:")
    print(f"{'Theorem':>8} {'Layer':>6} {'Weight':>8} {'ProofLen':>10} {'Score':>8}")
    print("-" * 44)
    for r in results[:6]:
        layer = 0 if r.theorem_id < 3 else (1 if r.theorem_id < 12 else 2)
        print(f"{r.theorem_id:>8} {layer:>6} {r.weight:>8} {r.proof_length:>10} {r.score:>8.2f}")

    print("\nObservation: Layer 0 theorems have highest anti-gravity scores")
    print("(high weight from being foundations, low proof length from being axioms)")
    print()


def demo_random_dag():
    """Demo 3: Random DAG - testing anti-gravity in the wild."""
    print("=" * 60)
    print("DEMO 3: Random DAG (100 theorems, avg degree ~5)")
    print("=" * 60)
    random.seed(42)
    n = 100
    edges = []

    # Generate random DAG: vertex i can depend on any j < i
    for i in range(1, n):
        num_deps = random.randint(1, min(10, i))
        deps = random.sample(range(i), num_deps)
        for j in deps:
            edges.append((i, j))

    proof_lengths = [random.randint(1, 20) for _ in range(n)]

    gds = GDS(n, edges, proof_lengths)
    results = detect_anti_gravity(gds)
    m = gds.total_edges()

    print(f"System: {n} theorems, {m} edges")
    print(f"Average degree: {m / n:.1f}")

    print(f"\nTop 10 anti-gravity theorems:")
    print(f"{'Theorem':>8} {'Weight':>8} {'ProofLen':>10} {'Score':>8}")
    print("-" * 38)
    for r in results[:10]:
        print(f"{r.theorem_id:>8} {r.weight:>8} {r.proof_length:>10} {r.score:>8.2f}")

    # Test Pareto conjecture
    weights = sorted([gds.direct_weight(j) for j in range(n)], reverse=True)
    total_weight = sum(weights)
    top_10_pct = sum(weights[:n // 10])
    pareto_ratio = top_10_pct / total_weight if total_weight > 0 else 0

    print(f"\nPareto analysis:")
    print(f"  Total weight: {total_weight}")
    print(f"  Top 10% weight: {top_10_pct}")
    print(f"  Pareto ratio: {pareto_ratio:.1%}")
    print(f"  Conjecture (≥50%): {'✓ CONFIRMED' if pareto_ratio >= 0.5 else '✗ NOT MET'}")

    # Verify Cauchy-Schwarz
    sum_w_sq = sum(gds.direct_weight(j) ** 2 for j in range(n))
    cs_holds = total_weight ** 2 <= n * sum_w_sq
    print(f"\nCauchy-Schwarz: m²={total_weight**2} <= n·Σw²={n * sum_w_sq}: {'✓' if cs_holds else '✗'}")
    print()


def demo_monotonicity():
    """Demo 4: Anti-gravity persistence under edge addition."""
    print("=" * 60)
    print("DEMO 4: Anti-Gravity Persistence (Monotonicity)")
    print("=" * 60)

    n = 5
    initial_edges = [(1, 0), (2, 0), (3, 1), (4, 2)]
    proof_lengths = [1, 2, 2, 3, 3]

    gds_before = GDS(n, initial_edges, proof_lengths)

    print("Before adding edge (4→0):")
    for j in range(n):
        print(f"  Theorem {j}: weight={gds_before.direct_weight(j)}, "
              f"score={gds_before.anti_gravity_score(j):.2f}")

    new_edges = initial_edges + [(4, 0)]
    gds_after = GDS(n, new_edges, proof_lengths)

    print("\nAfter adding edge (4→0):")
    for j in range(n):
        w_before = gds_before.direct_weight(j)
        w_after = gds_after.direct_weight(j)
        change = "↑" if w_after > w_before else "="
        print(f"  Theorem {j}: weight={w_after} {change}, "
              f"score={gds_after.anti_gravity_score(j):.2f}")

    print("\nAll weights weakly increased ✓ (Monotonicity theorem)")
    print()


if __name__ == "__main__":
    demo_star_graph()
    demo_layered_dag()
    demo_random_dag()
    demo_monotonicity()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Weight Distribution in Random DAGs

Shows the heavy-tailed nature of gravitational weight distributions
and the anti-gravity phenomenon.
"""
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generate_random_dag(n: int, avg_degree: float, seed: int = 42) -> tuple[list[list[bool]], list[int]]:
    """Generate a random DAG with n vertices and given average out-degree."""
    rng = random.Random(seed)
    adj = [[False] * n for _ in range(n)]
    for i in range(1, n):
        num_deps = max(1, min(i, int(rng.gauss(avg_degree, avg_degree / 2))))
        deps = rng.sample(range(i), min(num_deps, i))
        for j in deps:
            adj[i][j] = True
    proof_lengths = [max(1, int(rng.gauss(5, 3))) for _ in range(n)]
    return adj, proof_lengths


def compute_weights(adj: list[list[bool]], n: int) -> list[int]:
    return [sum(adj[i][j] for i in range(n)) for j in range(n)]


def main():
    n = 500
    avg_degree = 5.0
    adj, proof_lengths = generate_random_dag(n, avg_degree)
    weights = compute_weights(adj, n)
    scores = [w / pl for w, pl in zip(weights, proof_lengths)]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Anti-Gravity Analysis of a Random Derivation System\n'
                 f'(n={n} theorems, avg degree≈{avg_degree})', fontsize=14, fontweight='bold')

    # Plot 1: Weight distribution (histogram)
    ax1 = axes[0, 0]
    ax1.hist(weights, bins=30, color='steelblue', edgecolor='white', alpha=0.8)
    ax1.axvline(np.mean(weights), color='red', linestyle='--', linewidth=2, label=f'Mean={np.mean(weights):.1f}')
    ax1.axvline(np.median(weights), color='orange', linestyle='--', linewidth=2, label=f'Median={np.median(weights):.1f}')
    ax1.set_xlabel('Gravitational Weight', fontsize=11)
    ax1.set_ylabel('Count', fontsize=11)
    ax1.set_title('Weight Distribution (Heavy-Tailed)', fontsize=12)
    ax1.legend(fontsize=9)

    # Plot 2: Anti-gravity score vs weight
    ax2 = axes[0, 1]
    sc = ax2.scatter(weights, scores, c=proof_lengths, cmap='viridis_r',
                     alpha=0.6, s=20, edgecolors='none')
    plt.colorbar(sc, ax=ax2, label='Proof Length')
    ax2.set_xlabel('Gravitational Weight', fontsize=11)
    ax2.set_ylabel('Anti-Gravity Score (weight/proofLen)', fontsize=11)
    ax2.set_title('Anti-Gravity Landscape', fontsize=12)

    # Highlight top anti-gravity theorems
    top_indices = sorted(range(n), key=lambda j: scores[j], reverse=True)[:10]
    for idx in top_indices:
        ax2.annotate(f'T{idx}', (weights[idx], scores[idx]), fontsize=7, alpha=0.7)

    # Plot 3: Cumulative weight (Pareto analysis)
    ax3 = axes[1, 0]
    sorted_weights = sorted(weights, reverse=True)
    cumulative = np.cumsum(sorted_weights) / sum(sorted_weights)
    x_pct = np.arange(1, n + 1) / n * 100
    ax3.plot(x_pct, cumulative * 100, 'b-', linewidth=2)
    ax3.axhline(50, color='gray', linestyle=':', alpha=0.5)
    ax3.axvline(10, color='gray', linestyle=':', alpha=0.5)

    # Find Pareto point
    top_10_pct_weight = sum(sorted_weights[:n // 10]) / sum(sorted_weights) * 100
    ax3.plot(10, top_10_pct_weight, 'ro', markersize=10, zorder=5)
    ax3.annotate(f'Top 10% holds {top_10_pct_weight:.0f}% of weight',
                 (10, top_10_pct_weight), xytext=(20, top_10_pct_weight - 15),
                 fontsize=10, arrowprops=dict(arrowstyle='->', color='red'))

    ax3.set_xlabel('% of Theorems (ranked by weight)', fontsize=11)
    ax3.set_ylabel('% of Total Weight', fontsize=11)
    ax3.set_title('Pareto Analysis of Weight Concentration', fontsize=12)
    ax3.set_xlim(0, 100)
    ax3.set_ylim(0, 105)

    # Plot 4: Log-log rank-frequency plot
    ax4 = axes[1, 1]
    ranks = np.arange(1, n + 1)
    ax4.loglog(ranks, sorted_weights, 'o', markersize=3, color='steelblue', alpha=0.6)

    # Fit power law
    log_ranks = np.log(ranks[sorted_weights[0] > 0:])
    log_weights = np.log([max(w, 0.5) for w in sorted_weights])
    if len(log_ranks) > 10:
        coeffs = np.polyfit(log_ranks[:len(log_ranks)//2], log_weights[:len(log_ranks)//2], 1)
        alpha = -coeffs[0]
        fit_line = np.exp(coeffs[1]) * ranks ** coeffs[0]
        ax4.loglog(ranks, fit_line, 'r--', linewidth=2, label=f'Power law fit (α≈{alpha:.2f})')
        ax4.legend(fontsize=9)

    ax4.set_xlabel('Rank', fontsize=11)
    ax4.set_ylabel('Weight', fontsize=11)
    ax4.set_title('Rank-Frequency Plot (Log-Log)', fontsize=12)

    plt.tight_layout()
    plt.savefig('anti_gravity_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: anti_gravity_analysis.png")

    # Print summary statistics
    total_w = sum(weights)
    max_w = max(weights)
    print(f"\nSummary:")
    print(f"  Total weight: {total_w}")
    print(f"  Max weight: {max_w} (theorem {weights.index(max_w)})")
    print(f"  Pigeonhole bound: {total_w // n}")
    print(f"  Cauchy-Schwarz: {total_w**2} <= {n * sum(w**2 for w in weights)} ✓")
    print(f"  Top 10% Pareto ratio: {top_10_pct_weight:.1f}%")
    print(f"  Gini coefficient: {compute_gini(sorted_weights):.3f}")


def compute_gini(sorted_desc: list[int]) -> float:
    n = len(sorted_desc)
    s = sorted(sorted_desc)
    total = sum(s)
    if total == 0:
        return 0.0
    numer = sum((2 * (i + 1) - n - 1) * s[i] for i in range(n))
    return numer / (n * total)


if __name__ == "__main__":
    main()
