"""
Anti-Gravity Theorems: Demonstration

This script demonstrates the anti-gravity phenomenon in randomly generated
derivation graphs. It computes the weight (descendant count) and in-degree
of each vertex, identifies anti-gravity vertices, and verifies the
theoretical predictions.
"""
import random
from collections import defaultdict

def build_dag(n: int, edge_prob: float = 0.1, seed: int = 42) -> dict:
    """Build a random DAG on n vertices with given edge probability."""
    random.seed(seed)
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < edge_prob:
                adj[i].add(j)
    return dict(adj)

def compute_descendants(adj: dict, n: int) -> dict:
    """Compute descendant set for each vertex using BFS."""
    descendants = {}
    for v in range(n):
        visited = set()
        queue = [v]
        while queue:
            u = queue.pop(0)
            if u in visited:
                continue
            visited.add(u)
            for w in adj.get(u, set()):
                if w not in visited:
                    queue.append(w)
        descendants[v] = visited
    return descendants

def compute_in_degree(adj: dict, n: int) -> dict:
    """Compute in-degree for each vertex."""
    in_deg = defaultdict(int)
    for u in range(n):
        for v in adj.get(u, set()):
            in_deg[v] += 1
    return dict(in_deg)

def find_anti_gravity(n: int, edge_prob: float, tau: int, seed: int = 42):
    """Find anti-gravity vertices in a random DAG."""
    adj = build_dag(n, edge_prob, seed)
    descendants = compute_descendants(adj, n)
    in_deg = compute_in_degree(adj, n)

    total_weight = sum(len(descendants[v]) for v in range(n))
    edge_count = sum(in_deg.get(v, 0) for v in range(n))

    anti_gravity = []
    for v in range(n):
        weight = len(descendants[v])
        d = in_deg.get(v, 0)
        if weight > tau * d:
            anti_gravity.append((v, weight, d, weight / max(d, 1)))

    return {
        'n': n,
        'edge_prob': edge_prob,
        'tau': tau,
        'total_weight': total_weight,
        'edge_count': edge_count,
        'ratio': total_weight / max(edge_count, 1),
        'anti_gravity_count': len(anti_gravity),
        'anti_gravity_fraction': len(anti_gravity) / n,
        'top_anti_gravity': sorted(anti_gravity, key=lambda x: -x[3])[:5],
        'theorem_prediction_holds': total_weight > tau * edge_count
    }

def main():
    print("=" * 70)
    print("ANTI-GRAVITY THEOREMS: NUMERICAL DEMONSTRATION")
    print("=" * 70)

    # Experiment 1: Varying sparsity
    print("\n--- Experiment 1: Anti-gravity vs graph density ---")
    print(f"{'Density':>10} {'Edges':>8} {'TotalWt':>10} {'Ratio':>8} {'AG Count':>10} {'AG %':>8}")
    print("-" * 60)
    for p in [0.01, 0.02, 0.05, 0.1, 0.2, 0.3]:
        result = find_anti_gravity(100, p, tau=3, seed=42)
        print(f"{p:>10.2f} {result['edge_count']:>8d} {result['total_weight']:>10d} "
              f"{result['ratio']:>8.1f} {result['anti_gravity_count']:>10d} "
              f"{result['anti_gravity_fraction']:>8.1%}")

    # Experiment 2: The pigeonhole prediction
    print("\n--- Experiment 2: Pigeonhole prediction (τ=2) ---")
    print("When TotalWeight > τ·EdgeCount, anti-gravity MUST exist.")
    print(f"{'n':>6} {'TotalWt':>10} {'τ·Edges':>10} {'Holds?':>8} {'AG exists?':>12}")
    print("-" * 50)
    for n in [20, 50, 100, 200, 500]:
        result = find_anti_gravity(n, 0.05, tau=2, seed=42)
        tw = result['total_weight']
        te = 2 * result['edge_count']
        holds = tw > te
        ag_exists = result['anti_gravity_count'] > 0
        print(f"{n:>6d} {tw:>10d} {te:>10d} {'YES' if holds else 'NO':>8} "
              f"{'YES' if ag_exists else 'NO':>12}")

    # Experiment 3: The top anti-gravity vertices
    print("\n--- Experiment 3: Top anti-gravity vertices (n=200, p=0.05, τ=3) ---")
    result = find_anti_gravity(200, 0.05, tau=3, seed=42)
    print(f"Total vertices: {result['n']}")
    print(f"Total weight: {result['total_weight']}")
    print(f"Edge count: {result['edge_count']}")
    print(f"Weight/Edge ratio: {result['ratio']:.2f}")
    print(f"Anti-gravity count: {result['anti_gravity_count']} ({result['anti_gravity_fraction']:.1%})")
    print("\nTop anti-gravity vertices (vertex, weight, in-degree, leverage):")
    for v, w, d, lev in result['top_anti_gravity']:
        print(f"  v={v:>4d}  weight={w:>6d}  in-degree={d:>3d}  leverage={lev:>8.1f}")

    # Experiment 4: Sparse graph guarantee
    print("\n--- Experiment 4: Sparse graph guarantee ---")
    print("In very sparse graphs, nearly ALL vertices are anti-gravity.")
    result_sparse = find_anti_gravity(200, 0.005, tau=5, seed=42)
    result_dense = find_anti_gravity(200, 0.3, tau=5, seed=42)
    print(f"Sparse (p=0.005): {result_sparse['anti_gravity_fraction']:.1%} anti-gravity")
    print(f"Dense  (p=0.3):   {result_dense['anti_gravity_fraction']:.1%} anti-gravity")
    print(f"\nKey insight: Sparser derivation systems have MORE anti-gravity theorems!")

if __name__ == "__main__":
    main()


"""
Visualization: Anti-Gravity Density vs Graph Sparsity

Shows how the fraction of anti-gravity vertices varies with graph density,
confirming the theoretical prediction that sparser graphs have more
anti-gravity theorems.
"""
import random
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def build_dag(n, edge_prob, seed=42):
    random.seed(seed)
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < edge_prob:
                adj[i].add(j)
    return dict(adj)


def compute_descendants(adj, n):
    descendants = {}
    for v in range(n):
        visited = set()
        queue = [v]
        while queue:
            u = queue.pop(0)
            if u in visited:
                continue
            visited.add(u)
            for w in adj.get(u, set()):
                if w not in visited:
                    queue.append(w)
        descendants[v] = visited
    return descendants


def compute_in_degree(adj, n):
    in_deg = defaultdict(int)
    for u in range(n):
        for v in adj.get(u, set()):
            in_deg[v] += 1
    return dict(in_deg)


def anti_gravity_stats(n, edge_prob, tau, seed=42):
    adj = build_dag(n, edge_prob, seed)
    descendants = compute_descendants(adj, n)
    in_deg = compute_in_degree(adj, n)
    total_w = sum(len(descendants[v]) for v in range(n))
    edge_c = sum(in_deg.get(v, 0) for v in range(n))
    ag_count = sum(1 for v in range(n)
                   if len(descendants[v]) > tau * in_deg.get(v, 0))
    weights = [len(descendants[v]) for v in range(n)]
    return {
        'ag_frac': ag_count / n,
        'weight_edge_ratio': total_w / max(edge_c, 1),
        'weights': weights,
        'edge_count': edge_c,
        'total_weight': total_w,
    }


def main():
    n = 150
    tau = 3
    densities = np.linspace(0.005, 0.4, 30)

    ag_fracs = []
    we_ratios = []
    for p in densities:
        stats = anti_gravity_stats(n, p, tau)
        ag_fracs.append(stats['ag_frac'])
        we_ratios.append(stats['weight_edge_ratio'])

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Anti-gravity density vs edge probability
    axes[0].plot(densities, ag_fracs, 'b-o', markersize=4, linewidth=1.5)
    axes[0].set_xlabel('Edge Probability', fontsize=12)
    axes[0].set_ylabel('Anti-Gravity Fraction', fontsize=12)
    axes[0].set_title(f'Anti-Gravity Density (n={n}, τ={tau})', fontsize=13)
    axes[0].axhline(y=0.1, color='r', linestyle='--', alpha=0.7, label='10% prediction')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Weight/Edge ratio vs density
    axes[1].plot(densities, we_ratios, 'g-s', markersize=4, linewidth=1.5)
    axes[1].set_xlabel('Edge Probability', fontsize=12)
    axes[1].set_ylabel('TotalWeight / EdgeCount', fontsize=12)
    axes[1].set_title('Proof Compression Ratio', fontsize=13)
    axes[1].axhline(y=tau, color='r', linestyle='--', alpha=0.7, label=f'τ={tau} threshold')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Weight distribution for sparse vs dense
    stats_sparse = anti_gravity_stats(n, 0.02, tau)
    stats_dense = anti_gravity_stats(n, 0.2, tau)
    axes[2].hist(stats_sparse['weights'], bins=30, alpha=0.6, label='Sparse (p=0.02)', color='blue')
    axes[2].hist(stats_dense['weights'], bins=30, alpha=0.6, label='Dense (p=0.2)', color='red')
    axes[2].set_xlabel('Vertex Weight', fontsize=12)
    axes[2].set_ylabel('Count', fontsize=12)
    axes[2].set_title('Weight Distribution', fontsize=13)
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Novelty/anti_gravity_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved visualization to Novelty/anti_gravity_visualization.png")


if __name__ == "__main__":
    main()
