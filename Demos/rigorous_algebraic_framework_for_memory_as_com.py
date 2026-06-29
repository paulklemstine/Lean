#!/usr/bin/env python3
"""
Memory Compression Algebra — Interactive Demo

Demonstrates the key theorems from the tropical-algebraic framework:
1. Bottleneck inequality for composition
2. Iteration stabilization
3. Tropical capacity profile
4. Cascade product rank bound
5. Kernel refinement ordering
"""

import math
from algorithms import (
    compression_rank, tropical_capacity, kernel_partition,
    max_fiber_size, stabilization_index_func, cascade_product_rank,
    tropical_capacity_profile, idempotent_power, kernel_refines
)


def demo_bottleneck():
    """Demonstrate the bottleneck inequality rank(g∘f) ≤ min(rank(f), rank(g))."""
    print("=" * 60)
    print("DEMO 1: BOTTLENECK INEQUALITY")
    print("=" * 60)
    print()
    
    domain = list(range(12))
    
    examples = [
        ("x mod 4", "x mod 3", lambda x: x % 4, lambda x: x % 3),
        ("x mod 6", "x mod 2", lambda x: x % 6, lambda x: x % 2),
        ("min(x,2)", "x mod 3", lambda x: min(x, 2), lambda x: x % 3),
        ("x // 3", "x mod 4", lambda x: x // 3, lambda x: x % 4),
    ]
    
    for f_name, g_name, f, g in examples:
        r_f = compression_rank(f, domain)
        r_g = compression_rank(g, domain)
        r_gf = compression_rank(lambda x, f=f, g=g: g(f(x)), domain)
        bound = min(r_f, r_g)
        check = "✓" if r_gf <= bound else "✗"
        print(f"  f = {f_name:12s}, g = {g_name:12s}")
        print(f"  rank(f)={r_f}, rank(g)={r_g}, rank(g∘f)={r_gf} ≤ min={bound} {check}")
        print()


def demo_stabilization():
    """Demonstrate iteration stabilization."""
    print("=" * 60)
    print("DEMO 2: ITERATION STABILIZATION")
    print("=" * 60)
    print()
    
    n = 10
    
    functions = [
        ("max(0, x-1)", lambda x: max(0, x - 1)),
        ("min(x, 3)", lambda x: min(x, 3)),
        ("x // 2", lambda x: x // 2),
        ("(x+1) mod 10", lambda x: (x + 1) % n),
    ]
    
    for name, f in functions:
        N, profile = stabilization_index_func(f, n)
        print(f"  f(x) = {name} on {{0,...,{n-1}}}")
        print(f"  Rank profile: {profile}")
        print(f"  Stabilization at N = {N}")
        print(f"  Final stable rank = {profile[-1]}")
        print()


def demo_tropical_profile():
    """Demonstrate tropical capacity profile."""
    print("=" * 60)
    print("DEMO 3: TROPICAL CAPACITY PROFILE")
    print("=" * 60)
    print()
    
    n = 16
    f = lambda x: max(0, x - 2)
    
    profile = tropical_capacity_profile(f, n, 10)
    
    print(f"  f(x) = max(0, x-2) on {{0,...,{n-1}}}")
    print()
    print(f"  {'Iter k':>8s} | {'v(f^k)':>10s} | {'rank(f^k)':>10s} | Bar")
    print(f"  {'-'*8:>8s}-+-{'-'*10:>10s}-+-{'-'*10:>10s}-+--------")
    
    for k, v in enumerate(profile):
        r = round(math.exp(v)) if v > float('-inf') else 0
        bar = "█" * r
        print(f"  {k:>8d} | {v:>10.4f} | {r:>10d} | {bar}")
    print()


def demo_cascade_product():
    """Demonstrate cascade product rank bound."""
    print("=" * 60)
    print("DEMO 4: CASCADE PRODUCT RANK BOUND")
    print("=" * 60)
    print()
    
    domain = list(range(20))
    
    pairs = [
        ("x mod 4", "x mod 5", lambda x: x % 4, lambda x: x % 5),
        ("x mod 3", "x mod 3", lambda x: x % 3, lambda x: x % 3),
        ("min(x,3)", "x mod 7", lambda x: min(x, 3), lambda x: x % 7),
    ]
    
    for f1_name, f2_name, f1, f2 in pairs:
        r1, r2, r12 = cascade_product_rank(f1, f2, domain)
        bound = r1 * r2
        check = "✓" if r12 <= bound else "✗"
        print(f"  f₁ = {f1_name:12s}, f₂ = {f2_name:12s}")
        print(f"  rank(f₁)={r1}, rank(f₂)={r2}, rank(f₁×f₂)={r12} ≤ {r1}·{r2}={bound} {check}")
        print()


def demo_kernel_refinement():
    """Demonstrate kernel refinement ordering."""
    print("=" * 60)
    print("DEMO 5: KERNEL REFINEMENT ORDERING")
    print("=" * 60)
    print()
    
    domain = list(range(12))
    
    functions = [
        ("identity", lambda x: x),
        ("x mod 6", lambda x: x % 6),
        ("x mod 3", lambda x: x % 3),
        ("x mod 2", lambda x: x % 2),
        ("constant", lambda x: 0),
    ]
    
    print("  Kernel refinement lattice (→ means 'refines'):")
    print()
    
    for i, (n1, f1) in enumerate(functions):
        for j, (n2, f2) in enumerate(functions):
            if i != j:
                refines = kernel_refines(f1, f2, domain)
                if refines:
                    r1 = compression_rank(f1, domain)
                    r2 = compression_rank(f2, domain)
                    print(f"  ker({n1:10s}) → ker({n2:10s})  "
                          f"[rank {r1} ≥ rank {r2}: {'✓' if r1 >= r2 else '✗'}]")
    print()


def demo_idempotent_power():
    """Demonstrate idempotent power computation."""
    print("=" * 60)
    print("DEMO 6: IDEMPOTENT STABILIZATION")
    print("=" * 60)
    print()
    
    examples = [
        ("shift right", 8, lambda x: min(x + 1, 7)),
        ("collapse to 0", 6, lambda x: max(0, x - 1)),
        ("cycle mod 3", 6, lambda x: (x + 1) % 3 if x < 3 else x),
        ("full cycle", 5, lambda x: (x + 1) % 5),
    ]
    
    for name, n, f in examples:
        k = idempotent_power(f, n)
        print(f"  f = {name:20s} on {{0,...,{n-1}}}: idempotent power k = {k}")
        print(f"  f^{k} = f^{2*k} (verified)")
    print()


if __name__ == "__main__":
    demo_bottleneck()
    demo_stabilization()
    demo_tropical_profile()
    demo_cascade_product()
    demo_kernel_refinement()
    demo_idempotent_power()
    
    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Bottleneck Inequality for Function Composition

Demonstrates rank(g∘f) ≤ min(rank(f), rank(g)) across a range
of function pairs, visualized as a scatter plot.
"""

import math
import random
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def compression_rank(f, domain):
    return len(set(f(a) for a in domain))


def main():
    random.seed(42)
    n = 15
    domain = list(range(n))
    
    # Generate many random function pairs
    data = []
    for _ in range(500):
        # Random f : {0,...,n-1} → {0,...,n-1}
        f_table = [random.randint(0, n-1) for _ in range(n)]
        g_table = [random.randint(0, n-1) for _ in range(n)]
        
        f = lambda x, t=f_table: t[x]
        g = lambda x, t=g_table: t[x]
        gf = lambda x, ft=f_table, gt=g_table: gt[ft[x]]
        
        r_f = compression_rank(f, domain)
        r_g = compression_rank(g, domain)
        r_gf = compression_rank(gf, domain)
        
        data.append((r_f, r_g, r_gf))
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Bottleneck Inequality: rank(g∘f) ≤ min(rank(f), rank(g))',
                 fontsize=14, fontweight='bold')
    
    # Plot 1: rank(g∘f) vs min(rank(f), rank(g))
    mins = [min(rf, rg) for rf, rg, _ in data]
    rgfs = [rgf for _, _, rgf in data]
    
    ax1.scatter(mins, rgfs, alpha=0.3, s=20, c='#3498db', edgecolors='none')
    max_val = max(max(mins), max(rgfs)) + 1
    ax1.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (bound)')
    ax1.set_xlabel('min(rank(f), rank(g))', fontsize=12)
    ax1.set_ylabel('rank(g∘f)', fontsize=12)
    ax1.set_title('Bottleneck: All Points Below Diagonal', fontsize=11)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(0, max_val)
    ax1.set_ylim(0, max_val)
    
    # Plot 2: Histogram of slack = min(rank(f), rank(g)) - rank(g∘f)
    slacks = [m - rgf for m, rgf in zip(mins, rgfs)]
    ax2.hist(slacks, bins=range(max(slacks) + 2), color='#2ecc71', 
             edgecolor='white', alpha=0.8)
    ax2.set_xlabel('Slack: min(rank(f), rank(g)) − rank(g∘f)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Information Loss Beyond Bottleneck', fontsize=11)
    ax2.grid(True, alpha=0.3, axis='y')
    
    # Verify: all slacks ≥ 0
    violations = sum(1 for s in slacks if s < 0)
    ax2.text(0.95, 0.95, f'Violations: {violations}/500\n(should be 0)',
             transform=ax2.transAxes, fontsize=11, verticalalignment='top',
             horizontalalignment='right',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('bottleneck_inequality.png', dpi=150, bbox_inches='tight')
    print("Saved: bottleneck_inequality.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Kernel Congruence Lattice

Visualizes the lattice of kernel congruences for functions on a small
finite set, showing how kernel refinement corresponds to the information
ordering (finer kernel = higher rank).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib
matplotlib.use('Agg')
from itertools import product


def partition_from_function(f, domain):
    """Get the partition (as frozenset of frozensets) induced by f."""
    classes = {}
    for x in domain:
        fx = f(x)
        if fx not in classes:
            classes[fx] = set()
        classes[fx].add(x)
    return frozenset(frozenset(s) for s in classes.values())


def partition_refines(p1, p2):
    """Check if partition p1 refines p2 (p1 is finer)."""
    for block1 in p1:
        for block2 in p2:
            inter = block1 & block2
            if inter and inter != block1:
                return False
    return True


def partition_rank(p):
    return len(p)


def main():
    domain = list(range(4))
    
    # Generate all functions {0,1,2,3} → {0,1,2,3}
    all_functions = list(product(range(4), repeat=4))
    
    # Get unique partitions
    partitions = set()
    for ftable in all_functions:
        f = lambda x, t=ftable: t[x]
        p = partition_from_function(f, domain)
        partitions.add(p)
    
    partitions = sorted(partitions, key=lambda p: -len(p))
    
    # Build refinement edges (Hasse diagram)
    edges = []
    for i, p1 in enumerate(partitions):
        for j, p2 in enumerate(partitions):
            if i != j and partition_refines(p1, p2):
                # Check it's a cover (no intermediate partition)
                is_cover = True
                for k, p3 in enumerate(partitions):
                    if k != i and k != j:
                        if partition_refines(p1, p3) and partition_refines(p3, p2):
                            is_cover = False
                            break
                if is_cover:
                    edges.append((i, j))
    
    # Assign positions: group by rank
    rank_groups = {}
    for i, p in enumerate(partitions):
        r = partition_rank(p)
        if r not in rank_groups:
            rank_groups[r] = []
        rank_groups[r].append(i)
    
    positions = {}
    max_rank = max(rank_groups.keys())
    for rank, indices in rank_groups.items():
        y = (rank - 1) / max(1, max_rank - 1) * 8
        width = len(indices)
        for k, idx in enumerate(indices):
            x = (k - (width - 1) / 2) * 1.5
            positions[idx] = (x, y)
    
    # Plot
    fig, ax = plt.subplots(figsize=(14, 10))
    
    colors_by_rank = {1: '#e74c3c', 2: '#e67e22', 3: '#3498db', 4: '#2ecc71'}
    
    # Draw edges
    for i, j in edges:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.2, linewidth=0.5)
    
    # Draw nodes
    for i, p in enumerate(partitions):
        x, y = positions[i]
        r = partition_rank(p)
        color = colors_by_rank.get(r, '#95a5a6')
        
        ax.scatter(x, y, s=100, c=color, zorder=5, edgecolors='white', linewidth=0.5)
    
    # Add rank labels
    for rank in sorted(rank_groups.keys()):
        indices = rank_groups[rank]
        y = positions[indices[0]][1]
        ax.text(-8, y, f'rank = {rank}', fontsize=12, fontweight='bold',
                verticalalignment='center', color=colors_by_rank.get(rank, '#95a5a6'))
    
    # Legend
    legend_patches = [
        mpatches.Patch(color='#2ecc71', label='rank 4 (identity: {{0},{1},{2},{3}})'),
        mpatches.Patch(color='#3498db', label='rank 3 (one merge)'),
        mpatches.Patch(color='#e67e22', label='rank 2 (two classes)'),
        mpatches.Patch(color='#e74c3c', label='rank 1 (constant: {{0,1,2,3}})'),
    ]
    ax.legend(handles=legend_patches, loc='upper right', fontsize=10)
    
    ax.set_title(f'Kernel Congruence Lattice on {{0,1,2,3}}\n'
                 f'{len(partitions)} partitions, ordered by refinement\n'
                 f'(higher = finer partition = more information retained)',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('', fontsize=1)
    ax.set_ylabel('Information Content (rank) →', fontsize=12)
    ax.set_xlim(-9, 9)
    ax.grid(False)
    ax.set_xticks([])
    
    plt.tight_layout()
    plt.savefig('kernel_lattice.png', dpi=150, bbox_inches='tight')
    print(f"Saved: kernel_lattice.png ({len(partitions)} partitions, {len(edges)} cover relations)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Capacity Profile Under Iteration

Shows how the tropical capacity v(f^n) = log(rank(f^n)) decreases
monotonically and stabilizes, demonstrating the Stabilization Theorem.
"""

import math
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def compression_rank_iterate(f, n, k):
    """Compute rank(f^k) on {0,...,n-1}."""
    domain = list(range(n))
    current = {i: i for i in domain}
    for _ in range(k):
        current = {i: f(current[i]) for i in domain}
    return len(set(current.values()))


def tropical_profile(f, n, max_depth):
    """Compute [v(f^0), ..., v(f^max_depth)]."""
    domain = list(range(n))
    current = {i: i for i in domain}
    profile = [math.log(n)]
    for _ in range(max_depth):
        current = {i: f(current[i]) for i in domain}
        r = len(set(current.values()))
        profile.append(math.log(r) if r > 0 else float('-inf'))
    return profile


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical Capacity Profile Under Iteration\n'
                 'v(f^n) = log(rank(f^n)) — Monotone Decrease & Stabilization',
                 fontsize=14, fontweight='bold')

    n = 20
    max_depth = 15
    
    functions = [
        ("f(x) = max(0, x−1)\n(gradual collapse)", lambda x: max(0, x - 1)),
        ("f(x) = x // 2\n(halving)", lambda x: x // 2),
        ("f(x) = min(x, 5)\n(threshold)", lambda x: min(x, 5)),
        ("f(x) = (x+1) mod 20\n(permutation)", lambda x: (x + 1) % n),
    ]
    
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
    
    for ax, (name, f), color in zip(axes.flat, functions, colors):
        profile = tropical_profile(f, n, max_depth)
        ranks = [round(math.exp(v)) if v > float('-inf') else 0 for v in profile]
        
        ks = list(range(len(profile)))
        
        # Plot tropical capacity
        ax.plot(ks, profile, 'o-', color=color, linewidth=2, markersize=6)
        
        # Find stabilization point
        stab = None
        for i in range(1, len(ranks)):
            if ranks[i] == ranks[i-1]:
                stab = i - 1
                break
        
        if stab is not None:
            ax.axvline(x=stab, color='gray', linestyle='--', alpha=0.7,
                      label=f'Stabilizes at N={stab}')
            ax.axhline(y=profile[stab], color='gray', linestyle=':', alpha=0.5)
        
        # Annotate ranks
        for i, (k, v, r) in enumerate(zip(ks, profile, ranks)):
            if i % max(1, len(ks) // 8) == 0 or i == len(ks) - 1:
                ax.annotate(f'r={r}', (k, v), textcoords="offset points",
                          xytext=(0, 12), ha='center', fontsize=8, color=color)
        
        ax.set_xlabel('Iteration k', fontsize=11)
        ax.set_ylabel('v(f^k) = log(rank(f^k))', fontsize=11)
        ax.set_title(name, fontsize=11)
        ax.grid(True, alpha=0.3)
        if stab is not None:
            ax.legend(fontsize=9)
    
    plt.tight_layout()
    plt.savefig('tropical_profile.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_profile.png")


if __name__ == "__main__":
    main()
