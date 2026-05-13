#!/usr/bin/env python3
"""
Applications of Ultrametric Observer–Code Duality

Demonstrates real-world applications:
1. Hierarchical clustering certification
2. Cryptographic hash collision structure analysis
3. Phylogenetic tree reconstruction from distance data
4. Proof state compression via canonical codes
"""

from algorithms import (
    FiniteObserverSystem,
    build_canonical_code,
    verify_code_faithfulness,
    reconstruct_sep_from_code,
    compute_level_partition,
    generate_random_ultrametric,
)
from typing import List, Tuple, Dict
import math


# ─────────────────────────────────────────────────────────────
# Application 1: Hierarchical Clustering Certification
# ─────────────────────────────────────────────────────────────
def certify_clustering(distance_matrix: List[List[float]], tolerance: float = 0.01) -> dict:
    """Given a distance matrix, check if it's ultrametric and produce a certificate.

    If ultrametric (within tolerance), returns:
    - The canonical code (certificate of cluster structure)
    - The dendrogram (level partitions)
    - Verification status

    Args:
        distance_matrix: Symmetric non-negative distance matrix
        tolerance: Numerical tolerance for ultrametric check

    Returns:
        Dictionary with certification results
    """
    n = len(distance_matrix)

    # Check ultrametric inequality
    violations = []
    for i in range(n):
        for j in range(n):
            for k in range(n):
                lhs = distance_matrix[i][k]
                rhs = max(distance_matrix[i][j], distance_matrix[j][k])
                if lhs > rhs + tolerance:
                    violations.append((i, j, k, lhs, rhs))

    if violations:
        return {
            "is_ultrametric": False,
            "violations": violations[:5],
            "message": f"Found {len(violations)} ultrametric violations"
        }

    # Discretize to integer separation levels
    all_dists = sorted(set(
        distance_matrix[i][j]
        for i in range(n) for j in range(i + 1, n)
    ))
    dist_to_level = {0.0: 0}
    for idx, d in enumerate(all_dists):
        dist_to_level[d] = idx + 1

    sep = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            sep[i][j] = dist_to_level.get(distance_matrix[i][j], 0)

    labels = [f"item_{i}" for i in range(n)]
    sys = FiniteObserverSystem(labels=labels, sep=sep)

    try:
        sys.verify()
    except ValueError as e:
        return {"is_ultrametric": False, "message": str(e)}

    code = build_canonical_code(sys)
    is_faithful = verify_code_faithfulness(sys, code)

    return {
        "is_ultrametric": True,
        "is_faithful": is_faithful,
        "n_levels": sys.max_sep + 1,
        "codes": {labels[i]: code.codes[i] for i in range(n)},
        "level_classes": {
            level: compute_level_partition(sys, level).classes
            for level in range(sys.max_sep + 1)
        },
        "message": "Certified ultrametric clustering"
    }


# ─────────────────────────────────────────────────────────────
# Application 2: Hash Collision Structure Analysis
# ─────────────────────────────────────────────────────────────
def analyze_hash_collisions(keys: List[str], hash_fn_layers: List) -> dict:
    """Analyze the collision structure of a layered hash family.

    Given keys and a sequence of hash functions (layers), compute the
    separation level (first layer at which hashes differ) and check
    if the resulting structure is ultrametric.

    Args:
        keys: List of input keys
        hash_fn_layers: List of hash functions, each mapping str -> int

    Returns:
        Analysis results including ultrametric check and code structure
    """
    n = len(keys)
    L = len(hash_fn_layers)

    # Compute hash values at each layer
    hashes = {}
    for i, key in enumerate(keys):
        hashes[i] = [fn(key) for fn in hash_fn_layers]

    # Compute separation: first layer of disagreement
    sep = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            level = 0
            for l in range(L):
                if hashes[i][l] != hashes[j][l]:
                    break
                level = l + 1
            # Separation = number of agreeing layers (inverted for distance)
            sep[i][j] = L - level
            sep[j][i] = L - level

    labels = keys[:n]
    sys = FiniteObserverSystem(labels=labels, sep=sep)

    try:
        sys.verify()
        is_ultra = True
    except ValueError:
        is_ultra = False

    return {
        "is_ultrametric": is_ultra,
        "separation_matrix": sep,
        "hash_layers": {keys[i]: hashes[i] for i in range(n)},
        "max_separation": sys.max_sep if is_ultra else max(max(r) for r in sep),
    }


# ─────────────────────────────────────────────────────────────
# Application 3: Phylogenetic Tree Reconstruction
# ─────────────────────────────────────────────────────────────
def reconstruct_phylogeny(species: List[str], genetic_distances: List[List[float]]) -> dict:
    """Reconstruct a phylogenetic tree from genetic distance data.

    If the distances form an ultrametric (consistent with a molecular clock),
    the canonical code gives the exact tree structure.

    Returns the dendrogram, canonical codes, and tree structure.
    """
    result = certify_clustering(genetic_distances)

    if not result["is_ultrametric"]:
        return {
            "success": False,
            "message": "Distances are not ultrametric. "
                       "Consider UPGMA correction before reconstruction."
        }

    # Extract tree structure from level partitions
    tree_edges = []
    level_classes = result["level_classes"]
    levels = sorted(level_classes.keys())

    for l_idx in range(1, len(levels)):
        prev_level = levels[l_idx - 1]
        curr_level = levels[l_idx]
        prev_parts = level_classes[prev_level]
        curr_parts = level_classes[curr_level]

        for curr_cls in curr_parts:
            children = []
            for prev_cls in prev_parts:
                if set(prev_cls).issubset(set(curr_cls)) and prev_cls != curr_cls:
                    children.append(prev_cls)
            if len(children) > 1:
                parent_name = f"ancestor_L{curr_level}"
                for child in children:
                    child_names = [species[i] for i in child]
                    tree_edges.append({
                        "parent": parent_name,
                        "child": child_names if len(child_names) > 1 else child_names[0],
                        "divergence_level": curr_level
                    })

    return {
        "success": True,
        "species_codes": {species[i]: result["codes"][f"item_{i}"]
                          for i in range(len(species))},
        "tree_edges": tree_edges,
        "dendrogram_levels": {
            level: [[species[i] for i in cls] for cls in parts]
            for level, parts in level_classes.items()
        },
        "message": "Phylogenetic tree successfully reconstructed"
    }


# ─────────────────────────────────────────────────────────────
# Application 4: Proof State Compression
# ─────────────────────────────────────────────────────────────
def compress_proof_states(states: List[str],
                          distinguishers: List) -> dict:
    """Compress a collection of proof states using canonical ultrametric codes.

    Each distinguisher is a function that maps proof states to observable
    outcomes. The separation between two states is the number of distinguishers
    that give different outcomes.

    The canonical code provides the optimal hierarchical compression.
    """
    n = len(states)
    D = len(distinguishers)

    # Compute outcomes
    outcomes = {}
    for i, state in enumerate(states):
        outcomes[i] = [d(state) for d in distinguishers]

    # Compute separation (Hamming-like distance over distinguishers)
    sep = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            diff_count = sum(1 for d in range(D) if outcomes[i][d] != outcomes[j][d])
            sep[i][j] = diff_count
            sep[j][i] = diff_count

    # Check ultrametric property
    labels = states[:n]
    sys = FiniteObserverSystem(labels=labels, sep=sep)

    try:
        sys.verify()
        is_ultra = True
        code = build_canonical_code(sys)
        compression_ratio = (
            sum(math.log2(max(1, len(compute_level_partition(sys, l).classes)))
                for l in range(sys.max_sep + 1))
            / max(1, n * math.log2(max(2, n)))
        )
    except ValueError:
        is_ultra = False
        code = None
        compression_ratio = None

    return {
        "is_ultrametric": is_ultra,
        "separation_matrix": sep,
        "canonical_codes": {states[i]: code.codes[i] for i in range(n)} if code else None,
        "compression_ratio": compression_ratio,
        "n_states": n,
        "n_distinguishers": D,
    }


# ─────────────────────────────────────────────────────────────
# Run all applications
# ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 65)
    print("APPLICATION 1: Hierarchical Clustering Certification")
    print("=" * 65)

    # Ultrametric distance matrix (e.g., from single-linkage clustering)
    distances = [
        [0.0, 0.1, 0.3, 0.5, 0.5],
        [0.1, 0.0, 0.3, 0.5, 0.5],
        [0.3, 0.3, 0.0, 0.5, 0.5],
        [0.5, 0.5, 0.5, 0.0, 0.2],
        [0.5, 0.5, 0.5, 0.2, 0.0],
    ]
    cert = certify_clustering(distances)
    print(f"  Is ultrametric: {cert['is_ultrametric']}")
    if cert['is_ultrametric']:
        print(f"  Number of levels: {cert['n_levels']}")
        print(f"  Certificate: {cert['message']}")
        for label, code in cert['codes'].items():
            print(f"    {label}: {code}")

    print(f"\n{'=' * 65}")
    print("APPLICATION 2: Hash Collision Structure")
    print("=" * 65)

    # Simulate layered hash functions
    import hashlib

    def make_hash_layer(salt: str, bits: int = 4):
        def h(key: str) -> int:
            digest = hashlib.sha256((salt + key).encode()).hexdigest()
            return int(digest[:bits], 16)
        return h

    hash_layers = [make_hash_layer(f"layer_{i}", bits=2) for i in range(5)]
    keys = ["proof_A", "proof_B", "proof_C", "proof_D"]
    collision_result = analyze_hash_collisions(keys, hash_layers)
    print(f"  Is ultrametric: {collision_result['is_ultrametric']}")
    print(f"  Max separation: {collision_result['max_separation']}")
    print(f"  Separation matrix:")
    for row in collision_result['separation_matrix']:
        print(f"    {row}")

    print(f"\n{'=' * 65}")
    print("APPLICATION 3: Phylogenetic Reconstruction")
    print("=" * 65)

    species = ["Human", "Chimp", "Gorilla", "Orangutan", "Gibbon"]
    gen_dist = [
        [0.0, 0.1, 0.2, 0.4, 0.5],
        [0.1, 0.0, 0.2, 0.4, 0.5],
        [0.2, 0.2, 0.0, 0.4, 0.5],
        [0.4, 0.4, 0.4, 0.0, 0.5],
        [0.5, 0.5, 0.5, 0.5, 0.0],
    ]
    phylo = reconstruct_phylogeny(species, gen_dist)
    print(f"  Success: {phylo['success']}")
    if phylo['success']:
        print("  Dendrogram:")
        for level, parts in phylo['dendrogram_levels'].items():
            print(f"    Level {level}: {parts}")
        print("  Species codes:")
        for sp, code in phylo['species_codes'].items():
            print(f"    {sp}: {code}")

    print(f"\n{'=' * 65}")
    print("APPLICATION 4: Proof State Compression")
    print("=" * 65)

    # Simulate proof states with hierarchical structure
    proof_states = ["P1: x=0", "P2: x=0,y=1", "P3: x=1", "P4: x=1,y=0"]
    distinguishers = [
        lambda s: "x=0" in s,
        lambda s: "x=1" in s,
        lambda s: "y=0" in s,
        lambda s: "y=1" in s,
    ]
    compression = compress_proof_states(proof_states, distinguishers)
    print(f"  Is ultrametric: {compression['is_ultrametric']}")
    if compression['is_ultrametric']:
        print(f"  Compression ratio: {compression['compression_ratio']:.3f}")
        print("  Canonical codes:")
        for state, code in compression['canonical_codes'].items():
            print(f"    {state}: {code}")

    print(f"\n{'=' * 65}")
    print("All applications completed!")
    print("=" * 65)


#!/usr/bin/env python3
"""
Ultrametric Observer–Code Duality: Demonstrations

Demonstrates the core theorems with concrete numerical examples:
1. Constructing finite ultrametric spaces (observer systems)
2. Computing the nested level-relation partitions (prime-congruence filtration)
3. Verifying the isosceles triangle property
4. Canonical code construction and faithfulness
5. Reconstruction of separation from level data
"""

import numpy as np
from itertools import combinations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import matplotlib.patches as mpatches


def verify_ultrametric(sep, labels=None):
    """Verify that a separation matrix satisfies ultrametric axioms."""
    n = len(sep)
    if labels is None:
        labels = [str(i) for i in range(n)]

    # Axiom 1: sep(x,x) = 0
    for i in range(n):
        assert sep[i][i] == 0, f"sep({labels[i]},{labels[i]}) = {sep[i][i]} != 0"

    # Axiom 2: symmetry
    for i in range(n):
        for j in range(n):
            assert sep[i][j] == sep[j][i], \
                f"sep({labels[i]},{labels[j]}) = {sep[i][j]} != {sep[j][i]} = sep({labels[j]},{labels[i]})"

    # Axiom 3: ultrametric inequality
    for i in range(n):
        for j in range(n):
            for k in range(n):
                assert sep[i][k] <= max(sep[i][j], sep[j][k]), \
                    f"Ultrametric violated: sep({labels[i]},{labels[k]})={sep[i][k]} > " \
                    f"max(sep({labels[i]},{labels[j]})={sep[i][j]}, sep({labels[j]},{labels[k]})={sep[j][k]})"

    # Axiom 4: positive for distinct
    for i in range(n):
        for j in range(n):
            if i != j:
                assert sep[i][j] > 0, f"sep({labels[i]},{labels[j]}) = 0 but {labels[i]} != {labels[j]}"

    print("✓ All ultrametric axioms verified")
    return True


def compute_level_partition(sep, level):
    """Compute the partition of elements at a given level.
    levelRel(n, x, y) iff sep(x,y) <= n."""
    n = len(sep)
    visited = [False] * n
    classes = []
    for i in range(n):
        if visited[i]:
            continue
        cls = [i]
        visited[i] = True
        for j in range(i + 1, n):
            if sep[i][j] <= level:
                cls.append(j)
                visited[j] = True
        classes.append(cls)
    return classes


def verify_isosceles(sep, labels=None):
    """Verify the ultrametric isosceles property: among any three pairwise
    separations, the two largest are equal."""
    n = len(sep)
    if labels is None:
        labels = [str(i) for i in range(n)]

    violations = 0
    for i, j, k in combinations(range(n), 3):
        vals = sorted([sep[i][j], sep[j][k], sep[i][k]])
        if vals[1] != vals[2]:
            print(f"  ✗ Isosceles violated for ({labels[i]},{labels[j]},{labels[k]}): "
                  f"sorted separations = {vals}")
            violations += 1

    if violations == 0:
        print("✓ Isosceles property verified for all triples")
    return violations == 0


def reconstruct_sep_from_levels(level_partitions, n_elements):
    """Reconstruct the separation matrix from level partition data.
    sep(x,y) = min{n : levelRel(n, x, y)} = min level at which x,y are in same class."""
    sep = [[0] * n_elements for _ in range(n_elements)]
    max_level = max(level_partitions.keys()) + 1

    for i in range(n_elements):
        for j in range(i + 1, n_elements):
            # Find minimum level at which i and j are in the same class
            for lev in sorted(level_partitions.keys()):
                partition = level_partitions[lev]
                in_same = any(i in cls and j in cls for cls in partition)
                if in_same:
                    sep[i][j] = lev
                    sep[j][i] = lev
                    break
            else:
                sep[i][j] = max_level
                sep[j][i] = max_level

    return sep


# ─────────────────────────────────────────────────────────────
# Demo 1: A DNA/phylogenetic ultrametric
# ─────────────────────────────────────────────────────────────
print("=" * 65)
print("DEMO 1: Phylogenetic Ultrametric (Species Divergence)")
print("=" * 65)

species = ["Human", "Chimp", "Gorilla", "Dog", "Cat"]
# Separation = evolutionary divergence level (higher = more divergent)
# This is a classic ultrametric from molecular clock hypothesis
sep1 = [
    [0, 1, 2, 4, 4],  # Human
    [1, 0, 2, 4, 4],  # Chimp
    [2, 2, 0, 4, 4],  # Gorilla
    [4, 4, 4, 0, 3],  # Dog
    [4, 4, 4, 3, 0],  # Cat
]

print("\nSeparation matrix:")
header = "         " + "  ".join(f"{s:>7}" for s in species)
print(header)
for i, row in enumerate(sep1):
    print(f"{species[i]:>8} " + "  ".join(f"{v:>7}" for v in row))

print()
verify_ultrametric(sep1, species)
verify_isosceles(sep1, species)

print("\nLevel partitions (dendrogram):")
max_sep = max(max(row) for row in sep1)
for level in range(max_sep + 1):
    partition = compute_level_partition(sep1, level)
    named_partition = [[species[i] for i in cls] for cls in partition]
    print(f"  Level {level}: {named_partition}")

# ─────────────────────────────────────────────────────────────
# Demo 2: Canonical code construction
# ─────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 2: Canonical Code Construction")
print("=" * 65)

# The canonical code for each element is the sequence of its
# equivalence class labels across levels.
print("\nCanonical codes (class labels at each level):")
for level in range(max_sep + 1):
    partition = compute_level_partition(sep1, level)
    class_map = {}
    for cls_idx, cls in enumerate(partition):
        for elem in cls:
            class_map[elem] = cls_idx
    labels = [class_map[i] for i in range(len(species))]
    print(f"  Level {level}: {dict(zip(species, labels))}")

print("\nFull code tuples:")
for i, s in enumerate(species):
    code = []
    for level in range(max_sep + 1):
        partition = compute_level_partition(sep1, level)
        for cls_idx, cls in enumerate(partition):
            if i in cls:
                code.append(cls_idx)
                break
    print(f"  {s}: {tuple(code)}")

# ─────────────────────────────────────────────────────────────
# Demo 3: Reconstruction from level data
# ─────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 3: Reconstruction of Separation from Level Partitions")
print("=" * 65)

level_data = {}
for level in range(max_sep + 1):
    level_data[level] = compute_level_partition(sep1, level)

reconstructed = reconstruct_sep_from_levels(level_data, len(species))
print("\nOriginal separation matrix:")
for row in sep1:
    print(f"  {row}")
print("\nReconstructed separation matrix:")
for row in reconstructed:
    print(f"  {row}")
print(f"\n✓ Reconstruction matches: {sep1 == reconstructed}")

# ─────────────────────────────────────────────────────────────
# Demo 4: Isosceles triangle verification with random ultrametric
# ─────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 4: Random Ultrametric Generation & Isosceles Check")
print("=" * 65)

def random_ultrametric(n, max_val=8):
    """Generate a random ultrametric space by building a random dendrogram."""
    # Start with all elements as singletons
    clusters = [[i] for i in range(n)]
    sep = [[0] * n for _ in range(n)]
    level = 0

    while len(clusters) > 1:
        level += 1
        if level > max_val:
            # Merge all remaining
            merged = []
            for c in clusters:
                merged.extend(c)
            for i in merged:
                for j in merged:
                    if sep[i][j] == 0 and i != j:
                        sep[i][j] = level
                        sep[j][i] = level
            clusters = [merged]
        else:
            # Randomly merge some clusters
            np.random.shuffle(clusters)
            new_clusters = []
            i = 0
            while i < len(clusters):
                if i + 1 < len(clusters) and np.random.random() < 0.5:
                    # Merge clusters[i] and clusters[i+1]
                    merged = clusters[i] + clusters[i + 1]
                    for a in clusters[i]:
                        for b in clusters[i + 1]:
                            sep[a][b] = level
                            sep[b][a] = level
                    new_clusters.append(merged)
                    i += 2
                else:
                    new_clusters.append(clusters[i])
                    i += 1
            clusters = new_clusters

    return sep

np.random.seed(42)
n_points = 8
sep_rand = random_ultrametric(n_points)
labels_rand = [f"P{i}" for i in range(n_points)]

print(f"\nRandom {n_points}-point ultrametric:")
verify_ultrametric(sep_rand, labels_rand)
verify_isosceles(sep_rand, labels_rand)

max_sep_rand = max(max(row) for row in sep_rand)
print(f"\nLevel partitions:")
for level in range(max_sep_rand + 1):
    partition = compute_level_partition(sep_rand, level)
    print(f"  Level {level}: {partition}")

# ─────────────────────────────────────────────────────────────
# Demo 5: Valuation distance and exponential distance
# ─────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 5: Valuation & Exponential Distances")
print("=" * 65)

from fractions import Fraction

print("\nℚ-valued distance (= sep cast to ℚ):")
for i, j in [(0, 1), (0, 2), (0, 3), (3, 4)]:
    d = Fraction(sep1[i][j])
    print(f"  d({species[i]}, {species[j]}) = {d}")

print("\nExponential distance 2^sep(x,y):")
for i, j in [(0, 1), (0, 2), (0, 3), (3, 4)]:
    d = 2 ** sep1[i][j]
    print(f"  expDist({species[i]}, {species[j]}) = {d}")

print("\nVerifying ultrametric inequality for expDist on all triples:")
all_ok = True
for i, j, k in combinations(range(len(species)), 3):
    d_ij = 2 ** sep1[i][j]
    d_jk = 2 ** sep1[j][k]
    d_ik = 2 ** sep1[i][k]
    if d_ik > max(d_ij, d_jk):
        print(f"  ✗ Failed for ({species[i]},{species[j]},{species[k]})")
        all_ok = False
if all_ok:
    print("  ✓ Ultrametric inequality holds for 2^sep on all triples")

# ─────────────────────────────────────────────────────────────
# Visualization: Dendrogram
# ─────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("Generating dendrogram visualization...")
print("=" * 65)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Separation matrix heatmap
ax = axes[0]
im = ax.imshow(sep1, cmap='YlOrRd', aspect='equal')
ax.set_xticks(range(len(species)))
ax.set_yticks(range(len(species)))
ax.set_xticklabels(species, rotation=45, ha='right')
ax.set_yticklabels(species)
ax.set_title('Ultrametric Separation Matrix', fontsize=13, fontweight='bold')
for i in range(len(species)):
    for j in range(len(species)):
        ax.text(j, i, str(sep1[i][j]), ha='center', va='center',
                color='white' if sep1[i][j] > 2 else 'black', fontsize=12)
plt.colorbar(im, ax=ax, shrink=0.8)

# Right: Level partition diagram
ax = axes[1]
ax.set_xlim(-0.5, len(species) - 0.5)
ax.set_ylim(-0.5, max_sep + 0.5)
ax.set_xlabel('Observers', fontsize=11)
ax.set_ylabel('Level (separation threshold)', fontsize=11)
ax.set_title('Prime-Congruence Filtration\n(Dendrogram)', fontsize=13, fontweight='bold')
ax.set_xticks(range(len(species)))
ax.set_xticklabels(species, rotation=45, ha='right')
ax.set_yticks(range(max_sep + 1))

colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
for level in range(max_sep + 1):
    partition = compute_level_partition(sep1, level)
    for cls_idx, cls in enumerate(partition):
        if len(cls) > 1:
            x_min = min(cls) - 0.35
            x_max = max(cls) + 0.35
            rect = FancyBboxPatch((x_min, level - 0.15), x_max - x_min, 0.3,
                                   boxstyle="round,pad=0.05",
                                   facecolor=colors[cls_idx % len(colors)],
                                   alpha=0.3, edgecolor=colors[cls_idx % len(colors)],
                                   linewidth=2)
            ax.add_patch(rect)
    # Draw points
    for i in range(len(species)):
        ax.plot(i, level, 'ko', markersize=4)

plt.tight_layout()
plt.savefig('/workspace/request-project/dendrogram_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: dendrogram_visualization.png")

# ─────────────────────────────────────────────────────────────
# Demo 6: Number of classes at each level (antitone property)
# ─────────────────────────────────────────────────────────────
print("\n" + "=" * 65)
print("DEMO 6: Number of Classes (Antitone Property)")
print("=" * 65)

print(f"\n{'Level':<8} {'#Classes':<10} {'Partition'}")
print("-" * 60)
for level in range(max_sep + 1):
    partition = compute_level_partition(sep1, level)
    named = [[species[i] for i in cls] for cls in partition]
    print(f"{level:<8} {len(partition):<10} {named}")

counts = [len(compute_level_partition(sep1, l)) for l in range(max_sep + 1)]
print(f"\nClass counts: {counts}")
print(f"✓ Antitone (non-increasing): {all(counts[i] >= counts[i+1] for i in range(len(counts)-1))}")

print("\n" + "=" * 65)
print("All demonstrations completed successfully!")
print("=" * 65)
