#!/usr/bin/env python3
"""
Anti-Gravity Mathematics: Numerical Demonstrations

Demonstrates the key results about anti-gravity theorems in derivation graphs:
1. Pigeonhole weight theorem
2. Ball growth under expansion
3. Weight-depth tradeoff
4. Anti-gravity ratio distribution
"""

import random
from collections import defaultdict, deque

def build_random_dag(n: int, edge_prob: float = 0.15, seed: int = 42) -> dict:
    """Build a random DAG on n nodes with given edge probability."""
    random.seed(seed)
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < edge_prob:
                adj[i].add(j)
    return dict(adj)

def compute_reachable(adj: dict, n: int, v: int) -> set:
    """Compute all nodes reachable from v via BFS."""
    visited = {v}
    queue = deque([v])
    while queue:
        u = queue.popleft()
        for w in adj.get(u, set()):
            if w not in visited:
                visited.add(w)
                queue.append(w)
    return visited

def compute_weight(adj: dict, n: int, v: int) -> int:
    """Gravitational weight: number of reachable nodes."""
    return len(compute_reachable(adj, n, v))

def compute_proof_depth(adj: dict, n: int, axioms: set, v: int) -> int:
    """Minimum steps to reach v from axiom set via BFS."""
    if v in axioms:
        return 0
    visited = dict()
    queue = deque()
    for a in axioms:
        visited[a] = 0
        queue.append(a)
    while queue:
        u = queue.popleft()
        for w in adj.get(u, set()):
            if w not in visited:
                visited[w] = visited[u] + 1
                if w == v:
                    return visited[w]
                queue.append(w)
    return n + 1  # unreachable

def compute_anti_gravity_ratio(weight: int, depth: int) -> float:
    """Anti-gravity ratio: weight / depth, or weight if depth = 0."""
    if depth == 0:
        return float(weight)
    return weight / depth

def proof_ball(adj: dict, n: int, sources: set, k: int) -> set:
    """Compute proof ball of radius k around sources."""
    current = set(sources)
    for _ in range(k):
        new = set(current)
        for v in current:
            new.update(adj.get(v, set()))
        current = new
    return current

def demo_pigeonhole():
    """Demo 1: Pigeonhole Weight Theorem"""
    print("=" * 60)
    print("DEMO 1: Pigeonhole Weight Theorem")
    print("In any graph, some node has weight ≥ average weight")
    print("=" * 60)
    
    n = 20
    adj = build_random_dag(n, edge_prob=0.2)
    
    weights = {v: compute_weight(adj, n, v) for v in range(n)}
    total_weight = sum(weights.values())
    avg_weight = total_weight / n
    max_node = max(weights, key=weights.get)
    
    print(f"  Nodes: {n}")
    print(f"  Total weight: {total_weight}")
    print(f"  Average weight: {avg_weight:.2f}")
    print(f"  Max weight node: {max_node} (weight = {weights[max_node]})")
    print(f"  Theorem verified: {weights[max_node]} ≥ {avg_weight:.2f} ✓")
    print()

def demo_ball_growth():
    """Demo 2: Ball Growth under Expansion"""
    print("=" * 60)
    print("DEMO 2: Ball Growth Under Expansion")
    print("Proof balls grow multiplicatively in expanding graphs")
    print("=" * 60)
    
    n = 50
    adj = build_random_dag(n, edge_prob=0.15)
    sources = {0, 1, 2}
    
    print(f"  Nodes: {n}, Sources: {sources}")
    print(f"  {'Step k':<10} {'|Ball(k)|':<12} {'Growth':<10}")
    print(f"  {'-'*32}")
    
    prev_size = 0
    for k in range(8):
        ball = proof_ball(adj, n, sources, k)
        growth = len(ball) - prev_size if prev_size > 0 else "-"
        print(f"  {k:<10} {len(ball):<12} {growth}")
        prev_size = len(ball)
        if len(ball) == n:
            print(f"  (saturated at step {k})")
            break
    print()

def demo_weight_depth_tradeoff():
    """Demo 3: Weight-Depth Product Bound"""
    print("=" * 60)
    print("DEMO 3: Weight-Depth Product Bound")
    print("weight(v) * depth(v) ≤ n² + n for all nodes")
    print("=" * 60)
    
    n = 30
    adj = build_random_dag(n, edge_prob=0.12)
    axioms = {0, 1}
    bound = n**2 + n
    
    print(f"  Nodes: {n}, Bound: n² + n = {bound}")
    print(f"  {'Node':<8} {'Weight':<10} {'Depth':<8} {'Product':<10} {'≤ Bound?'}")
    print(f"  {'-'*44}")
    
    violations = 0
    for v in range(n):
        w = compute_weight(adj, n, v)
        d = compute_proof_depth(adj, n, axioms, v)
        product = w * d
        ok = product <= bound
        if not ok:
            violations += 1
        if v < 10 or not ok:
            print(f"  {v:<8} {w:<10} {d:<8} {product:<10} {'✓' if ok else '✗'}")
    
    print(f"  ... ({n} nodes total)")
    print(f"  Violations: {violations} (theorem says 0) ✓" if violations == 0 
          else f"  Violations: {violations} ✗")
    print()

def demo_antigravity_distribution():
    """Demo 4: Anti-Gravity Ratio Distribution"""
    print("=" * 60)
    print("DEMO 4: Anti-Gravity Ratio Distribution")
    print("Classifying nodes by anti-gravity ratio")
    print("=" * 60)
    
    n = 40
    adj = build_random_dag(n, edge_prob=0.15)
    axioms = {0, 1, 2}
    
    ratios = []
    for v in range(n):
        w = compute_weight(adj, n, v)
        d = compute_proof_depth(adj, n, axioms, v)
        r = compute_anti_gravity_ratio(w, d)
        ratios.append((v, w, d, r))
    
    ratios.sort(key=lambda x: -x[3])
    
    print(f"  Top 10 anti-gravity nodes:")
    print(f"  {'Node':<8} {'Weight':<10} {'Depth':<8} {'AG Ratio':<12} {'Class'}")
    print(f"  {'-'*48}")
    
    for v, w, d, r in ratios[:10]:
        if d == 0:
            cls = "AXIOM (max AG)"
        elif r > 5:
            cls = "HIGH AG"
        elif r > 2:
            cls = "MODERATE AG"
        else:
            cls = "LOW AG"
        print(f"  {v:<8} {w:<10} {d:<8} {r:<12.2f} {cls}")
    
    # Statistics
    high_ag = sum(1 for _, _, _, r in ratios if r > 5)
    mod_ag = sum(1 for _, _, _, r in ratios if 2 < r <= 5)
    low_ag = sum(1 for _, _, _, r in ratios if r <= 2)
    
    print(f"\n  Distribution:")
    print(f"    High AG (ratio > 5):     {high_ag} ({100*high_ag/n:.1f}%)")
    print(f"    Moderate AG (2 < r ≤ 5): {mod_ag} ({100*mod_ag/n:.1f}%)")
    print(f"    Low AG (ratio ≤ 2):      {low_ag} ({100*low_ag/n:.1f}%)")
    print()

def demo_successor_weight_monotonicity():
    """Demo 5: Weight Monotonicity under Successors"""
    print("=" * 60)
    print("DEMO 5: Weight Monotonicity (Successor Inheritance)")
    print("If v → u then weight(v) ≥ weight(u)")
    print("=" * 60)
    
    n = 25
    adj = build_random_dag(n, edge_prob=0.2)
    
    violations = 0
    checked = 0
    examples = []
    
    for v in range(n):
        w_v = compute_weight(adj, n, v)
        for u in adj.get(v, set()):
            w_u = compute_weight(adj, n, u)
            checked += 1
            if w_v < w_u:
                violations += 1
            if len(examples) < 5:
                examples.append((v, u, w_v, w_u))
    
    print(f"  Edges checked: {checked}")
    for v, u, wv, wu in examples:
        print(f"  Edge {v}→{u}: weight({v})={wv} ≥ weight({u})={wu} {'✓' if wv >= wu else '✗'}")
    print(f"  Violations: {violations} (theorem says 0) ✓" if violations == 0
          else f"  Violations: {violations} ✗")
    print()

if __name__ == "__main__":
    print("\n🌌 ANTI-GRAVITY MATHEMATICS: NUMERICAL DEMONSTRATIONS 🌌\n")
    demo_pigeonhole()
    demo_ball_growth()
    demo_weight_depth_tradeoff()
    demo_antigravity_distribution()
    demo_successor_weight_monotonicity()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Anti-Gravity Mathematics: Visualization

Produces a scatter plot of weight vs proof depth for nodes in a random DAG,
with anti-gravity ratio encoded as color. Demonstrates the weight-depth
tradeoff theorem and anti-gravity node clustering.
"""

import random
from collections import defaultdict, deque
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np


def build_random_dag(n, edge_prob=0.12, seed=42):
    random.seed(seed)
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < edge_prob:
                adj[i].add(j)
    return dict(adj)


def compute_reachable(adj, v):
    visited = {v}
    queue = deque([v])
    while queue:
        u = queue.popleft()
        for w in adj.get(u, set()):
            if w not in visited:
                visited.add(w)
                queue.append(w)
    return visited


def compute_depth(adj, n, axioms, v):
    if v in axioms:
        return 0
    dist = {a: 0 for a in axioms}
    queue = deque(axioms)
    while queue:
        u = queue.popleft()
        for w in adj.get(u, set()):
            if w not in dist:
                dist[w] = dist[u] + 1
                if w == v:
                    return dist[w]
                queue.append(w)
    return n + 1


def main():
    n = 60
    adj = build_random_dag(n, edge_prob=0.12)
    axioms = {0, 1, 2, 3}
    
    weights = []
    depths = []
    ratios = []
    labels = []
    
    for v in range(n):
        w = len(compute_reachable(adj, v))
        d = compute_depth(adj, n, axioms, v)
        r = w / d if d > 0 else w
        weights.append(w)
        depths.append(d)
        ratios.append(r)
        labels.append(v)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Plot 1: Weight vs Depth scatter
    ax1 = axes[0]
    scatter = ax1.scatter(depths, weights, c=ratios, cmap='plasma', 
                          s=80, edgecolors='black', linewidth=0.5, alpha=0.8)
    plt.colorbar(scatter, ax=ax1, label='Anti-Gravity Ratio')
    
    # Draw the n²+n bound curve
    d_range = np.linspace(0.5, max(depths) + 1, 100)
    w_bound = (n**2 + n) / d_range
    w_bound = np.minimum(w_bound, n)
    ax1.plot(d_range, w_bound, 'r--', alpha=0.5, label='weight·depth ≤ n²+n')
    
    ax1.set_xlabel('Proof Depth', fontsize=12)
    ax1.set_ylabel('Gravitational Weight', fontsize=12)
    ax1.set_title('Anti-Gravity Map\n(High AG = bright, top-left)', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.set_xlim(-0.5, max(depths) + 1)
    
    # Plot 2: Ball growth curves
    ax2 = axes[1]
    for src in [0, 5, 15, 30]:
        sizes = []
        current = {src}
        for k in range(15):
            sizes.append(len(current))
            expansion = set(current)
            for v in current:
                expansion.update(adj.get(v, set()))
            if expansion == current:
                sizes.extend([len(current)] * (14 - k))
                break
            current = expansion
        ax2.plot(range(len(sizes)), sizes, 'o-', label=f'Source {src}', markersize=4)
    
    ax2.set_xlabel('Steps k', fontsize=12)
    ax2.set_ylabel('|ProofBall(k)|', fontsize=12)
    ax2.set_title('Proof Ball Growth\n(Steeper = more anti-gravity)', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.axhline(y=n, color='gray', linestyle=':', alpha=0.5, label='n')
    
    # Plot 3: Anti-gravity ratio histogram
    ax3 = axes[2]
    finite_ratios = [r for r in ratios if r < 100]
    ax3.hist(finite_ratios, bins=20, color='mediumpurple', edgecolor='black', alpha=0.8)
    ax3.axvline(x=np.mean(finite_ratios), color='red', linestyle='--', 
                label=f'Mean = {np.mean(finite_ratios):.1f}')
    ax3.axvline(x=np.median(finite_ratios), color='orange', linestyle='--',
                label=f'Median = {np.median(finite_ratios):.1f}')
    ax3.set_xlabel('Anti-Gravity Ratio', fontsize=12)
    ax3.set_ylabel('Count', fontsize=12)
    ax3.set_title('Distribution of AG Ratios\n(Right-skewed = anti-gravity concentration)', fontsize=13)
    ax3.legend(fontsize=9)
    
    plt.suptitle('Anti-Gravity Mathematics: Theorem Dependency Structure', 
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('antigravity_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: antigravity_analysis.png")


if __name__ == "__main__":
    main()
