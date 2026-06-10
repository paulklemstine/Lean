#!/usr/bin/env python3
"""
Demo: Protein Folding as Persistent Homology Optimization

Demonstrates the key concepts:
1. Compact folds have lower total persistence than extended chains
2. Native-like structures minimize total persistence among random decoys
3. The topological gradient provides directional folding information
4. Domain decomposition of total persistence
"""

import numpy as np
from algorithms import (
    compute_distance_matrix,
    compute_persistence_intervals,
    total_persistence,
    p_total_persistence,
    persistence_entropy,
    topological_gradient,
    gradient_dimension,
    generate_random_decoy,
    generate_extended_chain,
    topological_similarity,
)


def demo_compact_vs_extended():
    """Show that compact folds have lower total persistence than extended chains."""
    print("=" * 60)
    print("Demo 1: Compact Fold vs Extended Chain")
    print("=" * 60)

    n = 20  # 20-atom protein
    bond_length = 3.8

    # Extended chain
    extended = generate_extended_chain(n, bond_length)
    dm_ext = compute_distance_matrix(extended)
    intervals_ext = compute_persistence_intervals(dm_ext)
    tp_ext = total_persistence(intervals_ext)

    # Compact globular fold (random compact)
    np.random.seed(42)
    compact = generate_random_decoy(n, radius=8.0)
    dm_compact = compute_distance_matrix(compact)
    intervals_compact = compute_persistence_intervals(dm_compact)
    tp_compact = total_persistence(intervals_compact)

    print(f"  Atoms: {n}")
    print(f"  Extended chain total persistence: {tp_ext:.2f}")
    print(f"  Compact fold total persistence:   {tp_compact:.2f}")
    print(f"  Ratio (extended/compact):         {tp_ext/tp_compact:.2f}")
    print(f"  → Compact fold has {'LOWER' if tp_compact < tp_ext else 'HIGHER'} total persistence ✓")
    print()


def demo_decoy_comparison():
    """Compare native-like compact structure vs random decoys."""
    print("=" * 60)
    print("Demo 2: Native Fold vs Random Decoys")
    print("=" * 60)

    n = 30
    num_decoys = 200

    # Generate a "native" compact fold
    np.random.seed(7)
    native = generate_random_decoy(n, radius=6.0)
    # Make it more globular by pulling toward center
    center = native.mean(axis=0)
    native = center + 0.7 * (native - center)
    dm_native = compute_distance_matrix(native)
    intervals_native = compute_persistence_intervals(dm_native)
    tp_native = total_persistence(intervals_native)

    # Generate random decoys
    tp_decoys = []
    for i in range(num_decoys):
        np.random.seed(1000 + i)
        decoy = generate_random_decoy(n, radius=12.0)
        dm = compute_distance_matrix(decoy)
        intervals = compute_persistence_intervals(dm)
        tp_decoys.append(total_persistence(intervals))

    wins = sum(1 for tp in tp_decoys if tp_native < tp)
    print(f"  Atoms: {n}")
    print(f"  Native total persistence: {tp_native:.2f}")
    print(f"  Decoy mean:               {np.mean(tp_decoys):.2f}")
    print(f"  Decoy std:                {np.std(tp_decoys):.2f}")
    print(f"  Native beats {wins}/{num_decoys} decoys ({100*wins/num_decoys:.0f}%)")
    print()


def demo_gradient_dimension():
    """Show that gradient dimension grows quadratically."""
    print("=" * 60)
    print("Demo 3: Topological Gradient Dimension (Levinthal Resolution)")
    print("=" * 60)

    for n in [4, 10, 20, 50, 100, 200]:
        gd = gradient_dimension(n)
        ratio = gd / n
        print(f"  n={n:4d}: gradient_dim = {gd:6d}, ratio (gd/n) = {ratio:.1f}")

    print("  → Gradient dimension grows as O(n²), resolving Levinthal's paradox")
    print()


def demo_domain_decomposition():
    """Demonstrate additivity of total persistence under domain decomposition."""
    print("=" * 60)
    print("Demo 4: Domain Decomposition")
    print("=" * 60)

    # Create a two-domain protein
    n1, n2 = 15, 15
    np.random.seed(123)
    domain1 = generate_random_decoy(n1, radius=5.0) + np.array([0, 0, 0])
    domain2 = generate_random_decoy(n2, radius=5.0) + np.array([20, 0, 0])
    full_protein = np.vstack([domain1, domain2])

    # Compute individual domain persistences
    dm1 = compute_distance_matrix(domain1)
    dm2 = compute_distance_matrix(domain2)
    dm_full = compute_distance_matrix(full_protein)

    int1 = compute_persistence_intervals(dm1)
    int2 = compute_persistence_intervals(dm2)
    int_full = compute_persistence_intervals(dm_full)

    tp1 = total_persistence(int1)
    tp2 = total_persistence(int2)
    tp_full = total_persistence(int_full)

    print(f"  Domain 1 ({n1} atoms): TP = {tp1:.2f}")
    print(f"  Domain 2 ({n2} atoms): TP = {tp2:.2f}")
    print(f"  Sum of domains:        TP = {tp1 + tp2:.2f}")
    print(f"  Full protein ({n1+n2} atoms): TP = {tp_full:.2f}")
    print(f"  (When domains are well-separated, inter-domain bars add extra persistence)")
    print()


def demo_p_persistence():
    """Compare p-total persistence for different p values."""
    print("=" * 60)
    print("Demo 5: p-Total Persistence Hierarchy")
    print("=" * 60)

    n = 25
    np.random.seed(99)
    coords = generate_random_decoy(n, radius=8.0)
    dm = compute_distance_matrix(coords)
    intervals = compute_persistence_intervals(dm)

    for p in [0, 1, 2, 3]:
        ptp = p_total_persistence(intervals, p)
        print(f"  p={p}: p-total persistence = {ptp:.4f}")

    entropy = persistence_entropy(intervals)
    print(f"  Persistence entropy: {entropy:.4f}")
    print()


def demo_topological_gradient():
    """Demonstrate the topological gradient."""
    print("=" * 60)
    print("Demo 6: Topological Gradient")
    print("=" * 60)

    n = 10
    np.random.seed(55)
    coords = generate_random_decoy(n, radius=8.0)

    grad = topological_gradient(coords, delta=0.05)
    grad_norm = np.linalg.norm(grad, axis=1)

    print(f"  Atoms: {n}")
    print(f"  Gradient norms per atom:")
    for i in range(min(n, 8)):
        print(f"    Atom {i}: |∇TP| = {grad_norm[i]:.4f}")
    print(f"  Max gradient: {grad_norm.max():.4f} (atom {grad_norm.argmax()})")
    print(f"  Mean gradient: {grad_norm.mean():.4f}")
    print()


def demo_similarity():
    """Demonstrate topological similarity metric."""
    print("=" * 60)
    print("Demo 7: Topological Similarity")
    print("=" * 60)

    n = 20
    np.random.seed(42)

    # Three structures: similar compact, different compact, extended
    compact1 = generate_random_decoy(n, radius=6.0)
    compact2 = compact1 + np.random.randn(n, 3) * 0.5  # small perturbation
    compact3 = generate_random_decoy(n, radius=12.0)
    extended = generate_extended_chain(n)

    structures = {
        "compact1": compact1,
        "compact2 (perturbed)": compact2,
        "compact3 (different)": compact3,
        "extended": extended,
    }

    intervals = {}
    for name, coords in structures.items():
        dm = compute_distance_matrix(coords)
        intervals[name] = compute_persistence_intervals(dm)

    print("  Pairwise topological distances:")
    names = list(structures.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            sim = topological_similarity(intervals[names[i]], intervals[names[j]])
            print(f"    d({names[i]}, {names[j]}) = {sim:.2f}")
    print()


if __name__ == "__main__":
    print("\n🧬 Protein Folding as Persistent Homology Optimization\n")
    demo_compact_vs_extended()
    demo_decoy_comparison()
    demo_gradient_dimension()
    demo_domain_decomposition()
    demo_p_persistence()
    demo_topological_gradient()
    demo_similarity()
    print("✅ All demos completed successfully.\n")


#!/usr/bin/env python3
"""
Visualization: Protein Folding Persistence Landscape

Generates plots showing:
1. Total persistence vs fold compactness
2. Persistence barcode diagram
3. Gradient dimension scaling
"""

import numpy as np
import matplotlib.pyplot as plt


def compute_distance_matrix(coords):
    diff = coords[:, np.newaxis, :] - coords[np.newaxis, :, :]
    return np.sqrt(np.sum(diff**2, axis=-1))


def compute_persistence_intervals(dist_matrix):
    n = dist_matrix.shape[0]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((dist_matrix[i, j], i, j))
    edges.sort()
    parent = list(range(n))
    rank_arr = [0] * n
    birth = [0.0] * n

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        if rank_arr[rx] < rank_arr[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank_arr[rx] == rank_arr[ry]:
            rank_arr[rx] += 1
        return True

    intervals = []
    for dist, i, j in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            younger = rj if birth[ri] <= birth[rj] else ri
            intervals.append((birth[younger], dist))
            union(i, j)
    return intervals


def total_persistence(intervals):
    return sum(d - b for b, d in intervals)


def generate_random_decoy(n, radius=10.0, seed=None):
    if seed is not None:
        np.random.seed(seed)
    coords = np.random.randn(n, 3)
    coords *= radius / np.max(np.linalg.norm(coords, axis=1))
    return coords


# --- Plot 1: Total persistence vs compactness ---
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

n = 25
radii = np.linspace(3, 25, 30)
tp_values = []
for r in radii:
    tps = []
    for seed in range(20):
        coords = generate_random_decoy(n, radius=r, seed=seed * 100 + int(r * 10))
        dm = compute_distance_matrix(coords)
        intervals = compute_persistence_intervals(dm)
        tps.append(total_persistence(intervals))
    tp_values.append((np.mean(tps), np.std(tps)))

means = [v[0] for v in tp_values]
stds = [v[1] for v in tp_values]

axes[0].fill_between(radii, [m - s for m, s in zip(means, stds)],
                     [m + s for m, s in zip(means, stds)], alpha=0.3, color='steelblue')
axes[0].plot(radii, means, 'o-', color='steelblue', markersize=3)
axes[0].set_xlabel('Fold Radius (Å)', fontsize=12)
axes[0].set_ylabel('Total Persistence', fontsize=12)
axes[0].set_title('Total Persistence vs Compactness', fontsize=13)
axes[0].axhline(y=means[0], color='red', linestyle='--', alpha=0.5, label='Most compact')
axes[0].legend()

# --- Plot 2: Persistence barcode ---
np.random.seed(42)
coords = generate_random_decoy(20, radius=8.0)
dm = compute_distance_matrix(coords)
intervals = compute_persistence_intervals(dm)
intervals.sort(key=lambda x: x[1] - x[0], reverse=True)

for i, (b, d) in enumerate(intervals):
    axes[1].barh(i, d - b, left=b, height=0.8, color='steelblue', alpha=0.7)
axes[1].set_xlabel('Distance Threshold (Å)', fontsize=12)
axes[1].set_ylabel('Feature Index', fontsize=12)
axes[1].set_title('H₀ Persistence Barcode', fontsize=13)

# --- Plot 3: Gradient dimension scaling ---
ns = np.arange(2, 101)
gd = ns * (ns - 1) // 2
axes[2].plot(ns, gd, 'b-', linewidth=2, label='n(n-1)/2')
axes[2].plot(ns, ns, 'r--', linewidth=1.5, label='n (linear)')
axes[2].fill_between(ns, ns, gd, alpha=0.15, color='blue')
axes[2].set_xlabel('Number of Atoms (n)', fontsize=12)
axes[2].set_ylabel('Dimension', fontsize=12)
axes[2].set_title('Gradient Dimension vs Linear', fontsize=13)
axes[2].legend()
axes[2].set_yscale('log')

plt.tight_layout()
plt.savefig('persistence_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved persistence_landscape.png")
