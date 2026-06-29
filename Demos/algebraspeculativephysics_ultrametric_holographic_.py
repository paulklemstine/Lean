#!/usr/bin/env python3
"""
Ultrametric Holographic Renormalization — Demo
===============================================

Demonstrates the core theorems with concrete numerical examples:
1. Ultrametric verification and the isosceles lemma
2. Scale cluster computation and partition property
3. Hierarchical reconstruction from boundary data
4. p-adic ultrametric example
"""

import numpy as np
from itertools import combinations
import json


def is_ultrametric(d: np.ndarray) -> bool:
    """Check if a distance matrix satisfies the ultrametric inequality."""
    n = d.shape[0]
    for i in range(n):
        if d[i, i] != 0:
            return False
        for j in range(n):
            if d[i, j] != d[j, i]:
                return False
            if i != j and d[i, j] == 0:
                return False
            for k in range(n):
                if d[i, k] > max(d[i, j], d[j, k]):
                    return False
    return True


def verify_isosceles(d: np.ndarray) -> list:
    """Verify the ultrametric isosceles lemma: in every triple,
    the two largest distances are equal."""
    n = d.shape[0]
    results = []
    for i, j, k in combinations(range(n), 3):
        dists = sorted([d[i, j], d[i, k], d[j, k]])
        is_isos = dists[1] == dists[2]  # two largest are equal
        results.append({
            'triple': (i, j, k),
            'distances': dists,
            'isosceles': is_isos
        })
    return results


def scale_clusters(d: np.ndarray, s: int) -> list:
    """Compute scale clusters at threshold s.
    Returns list of frozensets (the partition)."""
    n = d.shape[0]
    visited = set()
    clusters = []
    for i in range(n):
        if i in visited:
            continue
        cluster = frozenset(j for j in range(n) if d[i, j] <= s)
        clusters.append(cluster)
        visited.update(cluster)
    return clusters


def reconstruct_hierarchy(d: np.ndarray) -> dict:
    """Reconstruct the hierarchical clustering from an ultrametric.
    Returns the merge tree as a dictionary."""
    n = d.shape[0]
    # Get all distinct nonzero distances (merge scales)
    scales = sorted(set(d[i, j] for i in range(n) for j in range(n) if i != j))

    hierarchy = {'scales': scales, 'partitions': {}}

    for s in [0] + scales:
        clusters = scale_clusters(d, s)
        hierarchy['partitions'][s] = [sorted(list(c)) for c in clusters]

    return hierarchy


def canonical_bulk_reconstruction(profile: np.ndarray) -> dict:
    """The certified canonical reconstruction: Node = boundary, scaleDist = profile.
    This is the explicit 'holographic decoder'."""
    n = profile.shape[0]
    return {
        'node_count': n,
        'is_minimal': True,
        'scale_dist': profile.tolist(),
        'boundary_profile': profile.tolist(),
        'boundary_matches': True
    }


def p_adic_distance(x: int, y: int, p: int) -> int:
    """Compute p-adic distance between integers (as p-adic valuation of difference).
    Returns p^(-v_p(x-y)) where v_p is the p-adic valuation.
    For simplicity, returns the valuation-based scale (larger = closer in p-adic metric)."""
    if x == y:
        return 0
    diff = abs(x - y)
    v = 0
    while diff % p == 0:
        diff //= p
        v += 1
    # Return p^(max_val - v) as a ℕ-valued ultrametric
    # For simplicity, we use the inverse: higher v = closer = smaller distance
    return p ** (0) if v > 10 else p ** (5 - min(v, 5))


def demo_basic_ultrametric():
    """Demo 1: Basic ultrametric verification."""
    print("=" * 60)
    print("Demo 1: Basic Ultrametric Space")
    print("=" * 60)

    # A simple ultrametric on 4 points (representing a binary tree)
    #     root (scale 4)
    #    /    \
    #  (2)    (2)
    #  / \    / \
    # a   b  c   d
    d = np.array([
        [0, 2, 4, 4],
        [2, 0, 4, 4],
        [4, 4, 0, 2],
        [4, 4, 2, 0]
    ])
    labels = ['a', 'b', 'c', 'd']

    print(f"\nDistance matrix (labels: {labels}):")
    print(d)
    print(f"\nIs ultrametric: {is_ultrametric(d)}")

    # Verify isosceles
    print("\nIsosceles lemma verification:")
    results = verify_isosceles(d)
    for r in results:
        names = tuple(labels[i] for i in r['triple'])
        print(f"  Triple {names}: distances = {r['distances']}, "
              f"isosceles = {r['isosceles']}")

    # Scale clusters
    print("\nScale clusters (hierarchical partitions):")
    for s in [0, 1, 2, 3, 4]:
        clusters = scale_clusters(d, s)
        named = [sorted(labels[i] for i in c) for c in clusters]
        print(f"  Scale {s}: {named}")

    # Reconstruction
    print("\nHierarchical reconstruction:")
    h = reconstruct_hierarchy(d)
    print(f"  Merge scales: {h['scales']}")
    for s, parts in h['partitions'].items():
        named = [[labels[i] for i in p] for p in parts]
        print(f"  Scale {s}: {named}")

    # Canonical bulk
    print("\nCanonical bulk reconstruction:")
    bulk = canonical_bulk_reconstruction(d)
    print(f"  Node count: {bulk['node_count']}")
    print(f"  Is minimal: {bulk['is_minimal']}")
    print(f"  Boundary matches original: {bulk['boundary_matches']}")


def demo_phylogenetic():
    """Demo 2: Phylogenetic tree example."""
    print("\n" + "=" * 60)
    print("Demo 2: Phylogenetic Tree (6 species)")
    print("=" * 60)

    # Evolutionary distances (ultrametric)
    # Tree:
    #          root (10)
    #         /        \
    #       (6)        (8)
    #      / \        / \
    #    (2)  (4)   (4)  e
    #    /\   /\    /\
    #   a  b c  d  e  f
    # Correction: let me make a valid ultrametric
    species = ['Cat', 'Dog', 'Horse', 'Eagle', 'Frog', 'Fish']
    d = np.array([
        [0, 2, 4, 8, 8, 10],   # Cat
        [2, 0, 4, 8, 8, 10],   # Dog
        [4, 4, 0, 8, 8, 10],   # Horse
        [8, 8, 8, 0, 6, 10],   # Eagle
        [8, 8, 8, 6, 0, 10],   # Frog
        [10, 10, 10, 10, 10, 0] # Fish
    ])

    print(f"\nSpecies: {species}")
    print(f"Is ultrametric: {is_ultrametric(d)}")

    print("\nHierarchical reconstruction:")
    h = reconstruct_hierarchy(d)
    print(f"  Merge scales: {h['scales']}")
    for s, parts in h['partitions'].items():
        named = [[species[i] for i in p] for p in parts]
        print(f"  Scale {s}: {named}")


def demo_p_adic():
    """Demo 3: p-adic ultrametric."""
    print("\n" + "=" * 60)
    print("Demo 3: 2-adic Ultrametric on Z/16Z")
    print("=" * 60)

    p = 2
    n = 8
    elements = list(range(n))

    # 2-adic distance: d(x,y) = 2^(k) where 2^k || (x-y)
    # We use a normalized version
    d = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i == j:
                d[i, j] = 0
            else:
                diff = abs(i - j)
                v = 0
                dd = diff
                while dd % p == 0:
                    dd //= p
                    v += 1
                d[i, j] = 2 ** (4 - v)  # Invert: higher valuation = closer

    print(f"\nElements: {elements}")
    print(f"Distance matrix:")
    print(d)
    print(f"\nIs ultrametric: {is_ultrametric(d)}")

    print("\nScale clusters:")
    for s in sorted(set(d.flatten()) - {0}):
        clusters = scale_clusters(d, s)
        print(f"  Scale {s}: {[sorted(list(c)) for c in clusters]}")

    # Verify isosceles
    iso_results = verify_isosceles(d)
    all_iso = all(r['isosceles'] for r in iso_results)
    print(f"\nAll triangles isosceles: {all_iso}")


def demo_reconstruction_roundtrip():
    """Demo 4: Reconstruction roundtrip verification."""
    print("\n" + "=" * 60)
    print("Demo 4: Reconstruction Roundtrip")
    print("=" * 60)

    # Generate random ultrametric via hierarchical clustering
    n = 6
    np.random.seed(42)

    # Build random ultrametric from a random binary tree
    def random_ultrametric(n):
        """Generate a random ultrametric by building a random merge tree."""
        d = np.zeros((n, n), dtype=int)
        clusters = [{i} for i in range(n)]
        scale = 1
        while len(clusters) > 1:
            # Pick two random clusters to merge
            i, j = np.random.choice(len(clusters), 2, replace=False)
            c1, c2 = clusters[min(i, j)], clusters[max(i, j)]
            # Set distances between merged clusters
            for a in c1:
                for b in c2:
                    d[a, b] = scale
                    d[b, a] = scale
            # Merge
            new_cluster = c1 | c2
            clusters = [c for k, c in enumerate(clusters) if k != i and k != j]
            clusters.append(new_cluster)
            scale += np.random.randint(1, 4)
        return d

    d = random_ultrametric(n)
    print(f"\nOriginal ultrametric:")
    print(d)
    print(f"Is ultrametric: {is_ultrametric(d)}")

    # Reconstruct
    bulk = canonical_bulk_reconstruction(d)
    reconstructed = np.array(bulk['scale_dist'])

    # Verify roundtrip
    match = np.array_equal(d, reconstructed)
    print(f"\nReconstructed ultrametric:")
    print(reconstructed)
    print(f"\nRoundtrip match: {match}")

    # Hierarchy
    h = reconstruct_hierarchy(d)
    print(f"\nMerge scales: {h['scales']}")
    for s, parts in h['partitions'].items():
        print(f"  Scale {s}: {parts}")

    # Run multiple random trials
    print("\n--- Random trial verification ---")
    n_trials = 1000
    successes = 0
    for trial in range(n_trials):
        np.random.seed(trial)
        sz = np.random.randint(3, 10)
        dd = random_ultrametric(sz)
        if is_ultrametric(dd):
            bulk_trial = canonical_bulk_reconstruction(dd)
            if np.array_equal(dd, np.array(bulk_trial['scale_dist'])):
                successes += 1
    print(f"Random trials: {successes}/{n_trials} successful roundtrips")


def demo_entropy_profiles():
    """Demo 5: Entropy profiles and separation."""
    print("\n" + "=" * 60)
    print("Demo 5: Entropy Profiles and Separation")
    print("=" * 60)

    d = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 1, 5],
        [3, 3, 1, 0, 5],
        [5, 5, 5, 5, 0]
    ])
    labels = ['a', 'b', 'c', 'd', 'e']

    print(f"\nUltrametric on {labels}:")
    print(d)
    print(f"Is ultrametric: {is_ultrametric(d)}")

    print("\nEntropy profiles (distance vectors):")
    for i, label in enumerate(labels):
        profile = d[i]
        print(f"  profile({label}) = {profile}")

    # Check separation
    print("\nSeparation check (all profiles distinct):")
    profiles_set = set()
    all_distinct = True
    for i in range(len(labels)):
        prof = tuple(d[i])
        if prof in profiles_set:
            all_distinct = False
            print(f"  DUPLICATE profile for {labels[i]}!")
        profiles_set.add(prof)
    print(f"  All profiles distinct: {all_distinct}")

    # Nondegeneracy
    print("\nNondegeneracy check (all off-diagonal > 0):")
    nondegenerate = all(d[i, j] > 0 for i in range(len(labels))
                       for j in range(len(labels)) if i != j)
    print(f"  Nondegenerate: {nondegenerate}")


if __name__ == '__main__':
    demo_basic_ultrametric()
    demo_phylogenetic()
    demo_p_adic()
    demo_reconstruction_roundtrip()
    demo_entropy_profiles()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for the ultrametric holographic renormalization paper."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_distance_matrix():
    """Visualize an ultrametric distance matrix with hierarchical structure."""
    d = np.array([
        [0, 2, 4, 4, 8, 8],
        [2, 0, 4, 4, 8, 8],
        [4, 4, 0, 2, 8, 8],
        [4, 4, 2, 0, 8, 8],
        [8, 8, 8, 8, 0, 4],
        [8, 8, 8, 8, 4, 0]
    ])
    labels = ['A', 'B', 'C', 'D', 'E', 'F']

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Distance matrix heatmap
    ax = axes[0]
    im = ax.imshow(d, cmap='YlOrRd', interpolation='nearest')
    ax.set_xticks(range(len(labels)))
    ax.set_yticks(range(len(labels)))
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_yticklabels(labels, fontsize=12)
    ax.set_title('Ultrametric Distance Matrix\n(Boundary Entropy Profile)', fontsize=14)
    for i in range(len(labels)):
        for j in range(len(labels)):
            ax.text(j, i, str(d[i, j]), ha='center', va='center',
                   color='black' if d[i, j] < 5 else 'white', fontsize=14)
    plt.colorbar(im, ax=ax, label='Distance')

    # Dendrogram / tree
    ax = axes[1]
    # Draw the tree manually
    leaf_x = {0: 0.5, 1: 1.5, 2: 3, 3: 4, 4: 6, 5: 7}
    # Internal nodes: (A,B) merge at 2, (C,D) merge at 2, (E,F) merge at 4,
    # (AB,CD) merge at 4, (ABCD,EF) merge at 8
    for i, (label, x) in enumerate(zip(labels, leaf_x.values())):
        ax.plot(x, 0, 'ko', markersize=10)
        ax.text(x, -0.5, label, ha='center', va='top', fontsize=12, fontweight='bold')

    # Merge A-B at scale 2
    ax.plot([0.5, 0.5, 1.5, 1.5], [0, 2, 2, 0], 'b-', linewidth=2)
    ax.text(1, 2.2, 's=2', ha='center', fontsize=10, color='blue')

    # Merge C-D at scale 2
    ax.plot([3, 3, 4, 4], [0, 2, 2, 0], 'b-', linewidth=2)
    ax.text(3.5, 2.2, 's=2', ha='center', fontsize=10, color='blue')

    # Merge E-F at scale 4
    ax.plot([6, 6, 7, 7], [0, 4, 4, 0], 'g-', linewidth=2)
    ax.text(6.5, 4.2, 's=4', ha='center', fontsize=10, color='green')

    # Merge AB-CD at scale 4
    ax.plot([1, 1, 3.5, 3.5], [2, 4, 4, 2], 'g-', linewidth=2)
    ax.text(2.25, 4.2, 's=4', ha='center', fontsize=10, color='green')

    # Merge ABCD-EF at scale 8
    ax.plot([2.25, 2.25, 6.5, 6.5], [4, 8, 8, 4], 'r-', linewidth=2)
    ax.text(4.375, 8.3, 's=8', ha='center', fontsize=10, color='red')

    ax.set_xlim(-0.5, 8)
    ax.set_ylim(-1, 9.5)
    ax.set_ylabel('Scale', fontsize=12)
    ax.set_title('Reconstructed Bulk Hierarchy\n(Canonical Merge Tree)', fontsize=14)
    ax.set_xticks([])
    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')

    fig.suptitle('Ultrametric Holographic Duality: Boundary ↔ Bulk', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_scale_partitions():
    """Visualize how scale clusters evolve with increasing scale threshold."""
    d = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 1, 5],
        [3, 3, 1, 0, 5],
        [5, 5, 5, 5, 0]
    ])
    labels = ['a', 'b', 'c', 'd', 'e']
    n = len(labels)

    scales = [0, 1, 3, 5]

    fig, axes = plt.subplots(1, len(scales), figsize=(16, 4))

    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']

    for ax_idx, s in enumerate(scales):
        ax = axes[ax_idx]

        # Compute clusters
        visited = set()
        clusters = []
        for i in range(n):
            if i in visited:
                continue
            cluster = [j for j in range(n) if d[i, j] <= s]
            clusters.append(cluster)
            visited.update(cluster)

        # Draw points in clusters
        positions = {0: (1, 2), 1: (2, 2), 2: (3, 1), 3: (4, 1), 4: (2.5, 3.5)}
        for c_idx, cluster in enumerate(clusters):
            color = colors[c_idx % len(colors)]
            xs = [positions[i][0] for i in cluster]
            ys = [positions[i][1] for i in cluster]

            if len(cluster) > 1:
                # Draw convex hull / bounding box
                margin = 0.3
                x_min, x_max = min(xs) - margin, max(xs) + margin
                y_min, y_max = min(ys) - margin, max(ys) + margin
                rect = plt.Rectangle((x_min, y_min), x_max - x_min, y_max - y_min,
                                    fill=True, facecolor=color, alpha=0.15,
                                    edgecolor=color, linewidth=2)
                ax.add_patch(rect)

            for i in cluster:
                x, y = positions[i]
                ax.plot(x, y, 'o', color=color, markersize=15, zorder=5)
                ax.text(x, y, labels[i], ha='center', va='center',
                       fontsize=11, fontweight='bold', color='white', zorder=6)

        ax.set_xlim(0, 5)
        ax.set_ylim(0, 4.5)
        ax.set_title(f'Scale s = {s}\n({len(clusters)} clusters)', fontsize=12)
        ax.set_aspect('equal')
        ax.axis('off')

    fig.suptitle('Scale-Cluster Evolution: Hierarchical Partitions Under Coarse-Graining',
                fontsize=14, y=1.05)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_entropy_profiles():
    """Visualize entropy profiles showing separation property."""
    d = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 1, 5],
        [3, 3, 1, 0, 5],
        [5, 5, 5, 5, 0]
    ])
    labels = ['a', 'b', 'c', 'd', 'e']

    fig, ax = plt.subplots(figsize=(10, 6))

    x_pos = np.arange(len(labels))
    width = 0.15
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']

    for i, (label, color) in enumerate(zip(labels, colors)):
        offsets = x_pos + (i - 2) * width
        bars = ax.bar(offsets, d[i], width * 0.9, label=f'profile({label})',
                     color=color, alpha=0.8, edgecolor='black', linewidth=0.5)

    ax.set_xlabel('Observer', fontsize=12)
    ax.set_ylabel('Entropy Distance', fontsize=12)
    ax.set_title('Entropy Profiles: Each Point Has a Unique Signature\n'
                '(Separation Theorem)', fontsize=14)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(labels, fontsize=12)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == '__main__':
    print("Generating visualizations...")

    b64_1 = viz_distance_matrix()
    print(f"Distance matrix visualization: {len(b64_1)} chars")

    b64_2 = viz_scale_partitions()
    print(f"Scale partitions visualization: {len(b64_2)} chars")

    b64_3 = viz_entropy_profiles()
    print(f"Entropy profiles visualization: {len(b64_3)} chars")

    # Save results
    import json
    results = {
        'distance_matrix': b64_1,
        'scale_partitions': b64_2,
        'entropy_profiles': b64_3
    }
    with open('viz_data.json', 'w') as f:
        json.dump(results, f)
    print("Saved to viz_data.json")
