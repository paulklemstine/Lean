#!/usr/bin/env python3
"""
Collatz One-Way Function: Demonstration Script

Demonstrates the key properties of the Collatz map as a cryptographic primitive:
1. Forward computation efficiency
2. Exponential preimage witnesses
3. Image compression and collisions
4. Hash distribution analysis
5. Preimage density conjecture test
"""

from algorithms import (
    collatz_step, collatz_iter, collatz_owf, collatz_trajectory,
    collatz_hash, preimage_set, find_collisions, image_compression_ratio,
    preimage_density, exponential_preimage_witness, preimage_tree_bfs,
    security_gap_analysis, collision_resistant_hash_test
)


def demo_basic_collatz():
    """Demonstrate basic Collatz map properties."""
    print("=" * 60)
    print("DEMO 1: Basic Collatz Map")
    print("=" * 60)

    for n in [1, 2, 3, 5, 7, 12, 27]:
        print(f"  T({n}) = {collatz_step(n)}")

    print("\nTrajectories:")
    for n in [7, 27, 97]:
        traj = collatz_trajectory(20, n)
        print(f"  {n} -> {' -> '.join(map(str, traj[:10]))} ...")
    print()


def demo_exponential_witness():
    """Demonstrate exponential preimage witnesses."""
    print("=" * 60)
    print("DEMO 2: Exponential Preimage Witnesses")
    print("=" * 60)
    print("  T^a(2^a * v) = v for all a, v > 0\n")

    v = 7
    for a in range(1, 11):
        witness = exponential_preimage_witness(a, v)
        result = collatz_owf(a, witness)
        print(f"  a={a:2d}: T^{a}({witness:>8d}) = {result}  ✓" if result == v
              else f"  a={a:2d}: FAILED")

    print(f"\n  Search space grows as 2^a:")
    for a in [5, 10, 15, 20, 30]:
        print(f"    a={a:2d}: search space ≥ 2^{a} = {2**a:,}")
    print()


def demo_image_compression():
    """Demonstrate image compression under iteration."""
    print("=" * 60)
    print("DEMO 3: Image Compression Under Iteration")
    print("=" * 60)
    print("  Ratio = |Image(T^a on {0..B-1})| / B\n")

    B = 1000
    for a in [1, 2, 3, 5, 10, 20]:
        ratio = image_compression_ratio(a, B)
        print(f"  a={a:2d}: compression ratio = {ratio:.4f}  "
              f"(|image| = {int(ratio * B)})")
    print()


def demo_collisions():
    """Demonstrate collision finding."""
    print("=" * 60)
    print("DEMO 4: Collision Detection")
    print("=" * 60)

    for a in [1, 2, 3, 5]:
        B = 100
        colls = find_collisions(a, B)
        print(f"  a={a}, B={B}: {len(colls)} collision pairs")
        if colls:
            n1, n2 = colls[0]
            print(f"    Example: T^{a}({n1}) = T^{a}({n2}) = {collatz_owf(a, n1)}")
    print()


def demo_security_gap():
    """Demonstrate the security gap between forward and backward computation."""
    print("=" * 60)
    print("DEMO 5: Security Gap Analysis")
    print("=" * 60)
    print("  Forward cost vs backward search space\n")

    results = security_gap_analysis(20, v=7)
    print(f"  {'a':>3s}  {'Forward':>8s}  {'Search Space':>14s}  {'Ratio':>10s}")
    print(f"  {'':->3s}  {'':->8s}  {'':->14s}  {'':->10s}")
    for r in results:
        a = r["iterations"]
        fwd = r["forward_cost"]
        ss = r["search_space_lower_bound"]
        ratio = r["security_ratio"]
        print(f"  {a:3d}  {fwd:8d}  {ss:14,d}  {ratio:10,d}")
    print()


def demo_hash_distribution():
    """Demonstrate Collatz hash distribution."""
    print("=" * 60)
    print("DEMO 6: Collatz Hash Distribution")
    print("=" * 60)

    for a in [5, 10, 20]:
        m = 64
        B = 5000
        stats = collision_resistant_hash_test(a, m, B)
        print(f"\n  a={a}, m={m}, B={B}:")
        print(f"    Buckets used: {stats['num_buckets_used']}/{stats['total_buckets']}")
        print(f"    Avg/bucket:   {stats['avg_per_bucket']:.1f}")
        print(f"    Min/Max:      {stats['min_per_bucket']}/{stats['max_per_bucket']}")
        print(f"    Uniformity:   {stats['uniformity_ratio']:.4f}")
    print()


def demo_density_conjecture():
    """Test the falsifiable conjecture on preimage density."""
    print("=" * 60)
    print("DEMO 7: Preimage Density Conjecture Test")
    print("=" * 60)
    print("  Conjecture: density → 1/m as a → ∞\n")

    m = 100
    v = 0
    B = 5000
    expected = 1.0 / m

    print(f"  m={m}, v={v}, B={B}, expected density = {expected:.4f}\n")
    print(f"  {'a':>4s}  {'Density':>10s}  {'Expected':>10s}  {'Deviation':>10s}")
    print(f"  {'':->4s}  {'':->10s}  {'':->10s}  {'':->10s}")

    for a in [1, 2, 5, 10, 20, 50, 100]:
        d = preimage_density(a, m, v, B)
        dev = abs(d - expected)
        print(f"  {a:4d}  {d:10.6f}  {expected:10.6f}  {dev:10.6f}")
    print()


def demo_preimage_tree():
    """Demonstrate the preimage tree structure."""
    print("=" * 60)
    print("DEMO 8: Preimage Tree Structure")
    print("=" * 60)

    target = 8
    depth = 5
    tree = preimage_tree_bfs(target, depth)

    print(f"\n  Preimage tree for {target}, depth {depth}:")
    for node, preimages in sorted(tree.items())[:20]:
        print(f"    T⁻¹({node}) = {preimages}")

    print(f"\n  Total nodes explored: {len(tree)}")
    print()


if __name__ == "__main__":
    demo_basic_collatz()
    demo_exponential_witness()
    demo_image_compression()
    demo_collisions()
    demo_security_gap()
    demo_hash_distribution()
    demo_density_conjecture()
    demo_preimage_tree()

    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Collatz Preimage Tree

Shows the tree structure of preimages under the Collatz map,
demonstrating the exponential branching that makes inversion hard.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import deque


def collatz_step(n: int) -> int:
    if n <= 0:
        return 0
    if n % 2 == 0:
        return n // 2
    else:
        return 3 * n + 1


def get_preimages(v: int) -> list:
    """Get all Collatz preimages of v."""
    preimages = []
    if v > 0:
        preimages.append(2 * v)  # even preimage
        if v >= 4 and v % 3 == 1:
            candidate = (v - 1) // 3
            if candidate % 2 == 1 and candidate > 0:
                preimages.append(candidate)
    return preimages


def build_preimage_tree(root: int, max_depth: int):
    """Build preimage tree via BFS, returning (edges, positions)."""
    positions = {root: (0, 0)}
    edges = []
    queue = deque([(root, 0)])
    level_counts = {}

    while queue:
        node, depth = queue.popleft()
        if depth >= max_depth:
            continue

        preimages = get_preimages(node)
        if depth + 1 not in level_counts:
            level_counts[depth + 1] = 0

        for p in preimages:
            if p not in positions:
                y = -(depth + 1)
                x = level_counts[depth + 1]
                level_counts[depth + 1] += 1
                positions[p] = (x, y)
                edges.append((node, p))
                queue.append((p, depth + 1))

    return edges, positions


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    fig.suptitle('Collatz Preimage Trees', fontsize=16, fontweight='bold')

    # Tree 1: root = 8
    ax1 = axes[0]
    root1 = 8
    edges1, pos1 = build_preimage_tree(root1, 6)

    for parent, child in edges1:
        px, py = pos1[parent]
        cx, cy = pos1[child]
        ax1.plot([px, cx], [py, cy], 'b-', alpha=0.4, linewidth=1)

    for node, (x, y) in pos1.items():
        color = 'red' if node == root1 else ('green' if node % 2 == 0 else 'orange')
        ax1.scatter(x, y, c=color, s=80, zorder=5, edgecolors='black', linewidth=0.5)
        ax1.annotate(str(node), (x, y), textcoords="offset points",
                    xytext=(0, 8), ha='center', fontsize=7)

    ax1.set_title(f'Preimage Tree: root = {root1}')
    ax1.set_ylabel('Depth')
    ax1.set_xlabel('Node index')
    ax1.grid(True, alpha=0.2)

    # Tree 2: root = 16
    ax2 = axes[1]
    root2 = 16
    edges2, pos2 = build_preimage_tree(root2, 6)

    for parent, child in edges2:
        px, py = pos2[parent]
        cx, cy = pos2[child]
        ax2.plot([px, cx], [py, cy], 'b-', alpha=0.4, linewidth=1)

    for node, (x, y) in pos2.items():
        color = 'red' if node == root2 else ('green' if node % 2 == 0 else 'orange')
        ax2.scatter(x, y, c=color, s=80, zorder=5, edgecolors='black', linewidth=0.5)
        ax2.annotate(str(node), (x, y), textcoords="offset points",
                    xytext=(0, 8), ha='center', fontsize=7)

    ax2.set_title(f'Preimage Tree: root = {root2}')
    ax2.set_ylabel('Depth')
    ax2.set_xlabel('Node index')
    ax2.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('preimage_tree.png', dpi=150, bbox_inches='tight')
    print("Saved: preimage_tree.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Security Gap Between Forward and Backward Computation

Shows the exponential divergence between forward cost (linear in a)
and backward search space (exponential in a) for the Collatz OWF.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n: int) -> int:
    if n <= 0:
        return 0
    if n % 2 == 0:
        return n // 2
    else:
        return 3 * n + 1


def collatz_iter(a: int, n: int) -> int:
    result = n
    for _ in range(a):
        result = collatz_step(result)
    return result


def image_compression_ratio(a: int, bound: int) -> float:
    image = {collatz_iter(a, n) for n in range(bound)}
    return len(image) / bound


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Collatz One-Way Function: Security Analysis', fontsize=16, fontweight='bold')

    # Plot 1: Forward vs Backward cost (log scale)
    ax1 = axes[0, 0]
    a_vals = list(range(1, 31))
    forward_costs = a_vals
    backward_costs = [2**a for a in a_vals]
    ax1.semilogy(a_vals, forward_costs, 'b-o', markersize=4, label='Forward cost (a)')
    ax1.semilogy(a_vals, backward_costs, 'r-s', markersize=4, label='Search space (2^a)')
    ax1.fill_between(a_vals, forward_costs, backward_costs, alpha=0.15, color='red')
    ax1.set_xlabel('Iterations (a)')
    ax1.set_ylabel('Cost')
    ax1.set_title('Security Gap: Forward vs Backward')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Image compression ratio
    ax2 = axes[0, 1]
    B = 1000
    a_range = list(range(1, 26))
    ratios = [image_compression_ratio(a, B) for a in a_range]
    ax2.plot(a_range, ratios, 'g-o', markersize=4)
    ax2.axhline(y=0, color='k', linestyle='--', alpha=0.3)
    ax2.set_xlabel('Iterations (a)')
    ax2.set_ylabel('|Image| / B')
    ax2.set_title(f'Image Compression (B={B})')
    ax2.grid(True, alpha=0.3)

    # Plot 3: Preimage tree branching
    ax3 = axes[1, 0]
    targets = [4, 8, 16, 32]
    depths = list(range(1, 13))
    for target in targets:
        counts = []
        for d in depths:
            preimages = {n for n in range(target * 2**d + 100)
                        if collatz_iter(d, n) == target}
            counts.append(len(preimages))
        ax3.semilogy(depths, counts, '-o', markersize=4, label=f'target={target}')
    # Reference: 2^d growth
    ref = [2**d for d in depths]
    ax3.semilogy(depths, ref, 'k--', alpha=0.5, label='2^d reference')
    ax3.set_xlabel('Depth (d)')
    ax3.set_ylabel('Number of Preimages')
    ax3.set_title('Preimage Tree Growth')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Hash distribution
    ax4 = axes[1, 1]
    m = 32
    B = 3000
    for a in [1, 5, 10, 20]:
        hash_counts = [0] * m
        for n in range(B):
            h = collatz_iter(a, n) % m
            hash_counts[h] += 1
        ax4.bar(np.arange(m) + a * 0.15, hash_counts, width=0.15,
                label=f'a={a}', alpha=0.7)
    ax4.axhline(y=B/m, color='k', linestyle='--', alpha=0.5, label=f'B/m={B//m}')
    ax4.set_xlabel('Hash bucket')
    ax4.set_ylabel('Count')
    ax4.set_title(f'Hash Distribution (m={m}, B={B})')
    ax4.legend(fontsize=7)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('security_gap_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: security_gap_analysis.png")


if __name__ == "__main__":
    main()
