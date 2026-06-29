#!/usr/bin/env python3
"""
Applications of Ultrametric Lawvere Realization Duality

Demonstrates practical applications of the theory:
1. Hierarchical document clustering with ultrametric compression
2. Proof trace compression and minimization
3. Phylogenetic tree reconstruction via tropical potentials
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import UltrametricSpace, ProofPotentialSemimodule, MinimalCompressor


# =============================================================================
# Application 1: Hierarchical Document Clustering
# =============================================================================

def document_clustering_demo():
    """Demonstrate ultrametric compression for hierarchical document similarity.

    Scenario: 6 documents in 3 topic clusters, with intra-cluster similarity
    measured by an ultrametric (reflecting hierarchical topic structure).
    """
    print("=" * 70)
    print("Application 1: Hierarchical Document Clustering")
    print("=" * 70)

    doc_names = [
        "ML_intro",    # Machine Learning cluster
        "ML_deep",     # Machine Learning cluster
        "Crypto_RSA",  # Cryptography cluster
        "Crypto_ECC",  # Cryptography cluster
        "Bio_DNA",     # Biology cluster
        "Bio_protein",  # Biology cluster
    ]

    # Ultrametric: within-cluster distance < between-cluster distance
    # Satisfies d(x,z) ≤ max(d(x,y), d(y,z))
    d = np.array([
        [0,  2,  5,  5,  7,  7],  # ML_intro
        [2,  0,  5,  5,  7,  7],  # ML_deep
        [5,  5,  0,  3,  7,  7],  # Crypto_RSA
        [5,  5,  3,  0,  7,  7],  # Crypto_ECC
        [7,  7,  7,  7,  0,  1],  # Bio_DNA
        [7,  7,  7,  7,  1,  0],  # Bio_protein
    ], dtype=float)

    # Compression: map each document to its cluster representative
    compress = np.array([0, 0, 2, 2, 4, 4])

    space = UltrametricSpace(d, names=doc_names, compress=compress)
    valid, msg = space.verify_ultrametric()
    print(f"\n  Ultrametric: {msg}")

    semimodule = ProofPotentialSemimodule(space)
    mc = MinimalCompressor(semimodule)

    print(f"  Original documents: {space.n}")
    print(f"  After compression: {mc.state_count} cluster representatives")
    print(f"  Compression ratio: {mc.state_count}/{space.n} = {mc.state_count/space.n:.2f}")

    # Show cluster structure via potentials
    print("\n  Representable potentials (rows = observers, cols = documents):")
    for p in range(space.n):
        vals = [f"{semimodule.representables[p, x]:.0f}" for x in range(space.n)]
        print(f"    φ_{doc_names[p]:12s} = [{', '.join(vals)}]")

    # Observer distance recovery
    recovery, err = semimodule.verify_observer_recovery()
    print(f"\n  Observer distance = original distance: {recovery}")

    # Quotient distance
    d_q = mc.quotient_distance()
    reps = [doc_names[r] for r in mc.class_representatives]
    print(f"\n  Quotient (compressed) distance matrix:")
    print(f"    Representatives: {reps}")
    for i in range(mc.state_count):
        vals = [f"{d_q[i,j]:.0f}" for j in range(mc.state_count)]
        print(f"    {reps[i]:12s}: [{', '.join(vals)}]")

    return space, semimodule, mc


# =============================================================================
# Application 2: Proof Trace Compression
# =============================================================================

def proof_trace_demo():
    """Demonstrate compression of proof traces in a theorem prover.

    Scenario: 5 proof states representing intermediate steps in proving
    a theorem. Some states are equivalent (same logical content, different
    presentation). Compression identifies them.
    """
    print("\n" + "=" * 70)
    print("Application 2: Proof Trace Compression")
    print("=" * 70)

    state_names = [
        "raw_goal",       # Initial goal
        "after_intro",    # After intro tactic
        "after_intro'",   # After intro' (same effect)
        "after_simp",     # After simplification
        "qed",            # Proof complete
    ]

    # Distance: after_intro and after_intro' are distance 0 (same state)
    d = np.array([
        [0,  3,  3,  5,  8],
        [3,  0,  0,  2,  5],
        [3,  0,  0,  2,  5],
        [5,  2,  2,  0,  3],
        [8,  5,  5,  3,  0],
    ], dtype=float)

    # Compression: simplify each state
    compress = np.array([1, 3, 3, 4, 4])  # raw→intro, intro→simp, simp→qed, qed→qed

    space = UltrametricSpace(d, names=state_names, compress=compress)

    # Note: this is a pre-metric (not separated since d(intro, intro')=0)
    print(f"\n  Separated: {space.is_separated()}")
    print(f"  (after_intro and after_intro' have distance 0 — equivalent states)")

    semimodule = ProofPotentialSemimodule(space)
    mc = MinimalCompressor(semimodule)

    print(f"\n  Original proof states: {space.n}")
    print(f"  Minimal compressor states: {mc.state_count}")
    print(f"  Equivalence classes:")
    for i in range(mc.state_count):
        members = [state_names[j] for j in range(space.n) if mc.labels[j] == i]
        print(f"    Class {i}: {members}")

    print(f"\n  Compression descends to quotient: {mc.verify_compression_descends()}")

    # Show the proof trace simplification
    print(f"\n  Proof trace compression pipeline:")
    print(f"    Original: {' → '.join(state_names)}")
    compressed_names = [state_names[mc.class_representatives[mc.labels[i]]]
                       for i in range(space.n)]
    print(f"    Compressed: {' → '.join(dict.fromkeys(compressed_names))}")

    return space, semimodule, mc


# =============================================================================
# Application 3: Phylogenetic Tree via Tropical Potentials
# =============================================================================

def phylogenetic_demo():
    """Demonstrate phylogenetic tree reconstruction using tropical potentials.

    Scenario: 5 species with evolutionary distances forming an ultrametric
    (molecular clock hypothesis). Tropical potentials encode the tree structure.
    """
    print("\n" + "=" * 70)
    print("Application 3: Phylogenetic Tree via Tropical Potentials")
    print("=" * 70)

    species = ["Human", "Chimp", "Gorilla", "Mouse", "Rat"]

    # Ultrametric encoding molecular clock distances (in millions of years)
    d = np.array([
        [0,   6,  10,  80,  80],   # Human
        [6,   0,  10,  80,  80],   # Chimp
        [10, 10,   0,  80,  80],   # Gorilla
        [80, 80,  80,   0,  20],   # Mouse
        [80, 80,  80,  20,   0],   # Rat
    ], dtype=float)

    space = UltrametricSpace(d, names=species)
    valid, msg = space.verify_ultrametric()
    print(f"\n  Ultrametric (molecular clock): {msg}")

    semimodule = ProofPotentialSemimodule(space)

    # Show how potentials encode tree structure
    print("\n  Representable potentials encode ancestral distances:")
    for p in range(space.n):
        vals = [f"{semimodule.representables[p,x]:4.0f}" for x in range(space.n)]
        print(f"    From {species[p]:8s}: [{', '.join(vals)}]")

    # Tropical operations reveal common ancestors
    print("\n  Tropical addition reveals closest common ancestors:")
    phi_human = semimodule.representables[0]
    phi_mouse = semimodule.representables[3]
    trop_sum = semimodule.tropical_add(phi_human, phi_mouse)
    print(f"    φ_Human ⊕ φ_Mouse = min(dist_to_Human, dist_to_Mouse)")
    print(f"    = {trop_sum}")
    print(f"    Interpretation: each species' distance to nearest of Human/Mouse")

    # Observer distance recovery
    recovery, err = semimodule.verify_observer_recovery()
    print(f"\n  Observer distance = evolutionary distance: {recovery}")

    # Generator rank = number of species (separated space)
    mc = MinimalCompressor(semimodule)
    print(f"  Generator rank: {mc.generator_rank()} (= number of species)")

    return space, semimodule, mc


# =============================================================================
# Visualization
# =============================================================================

def create_visualizations(doc_result, proof_result, phylo_result):
    """Create publication-quality visualizations for all applications."""

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Plot 1: Document clustering dendrogram
    ax = axes[0, 0]
    ax.set_title("Document Clustering\n(Ultrametric Hierarchy)", fontsize=12, fontweight='bold')
    space = doc_result[0]
    # Simple dendrogram visualization
    leaf_x = [0, 1, 3, 4, 6, 7]
    labels = ["ML₁", "ML₂", "Cry₁", "Cry₂", "Bio₁", "Bio₂"]
    for i, x in enumerate(leaf_x):
        ax.plot(x, 0, 'ko', markersize=8, zorder=5)
        ax.text(x, -0.5, labels[i], ha='center', fontsize=9)

    # Merge at level 2 (ML), 3 (Crypto), 1 (Bio)
    merge_pairs = [(0, 1, 2), (2, 3, 3), (4, 5, 1)]
    for (a, b, h) in merge_pairs:
        xa, xb = leaf_x[a], leaf_x[b]
        ax.plot([xa, xa, xb, xb], [0, h, h, 0], 'b-', lw=2)
        ax.text((xa+xb)/2, h+0.2, f"d={h}", ha='center', fontsize=9, color='blue')

    # Top merge
    ax.plot([0.5, 0.5, 3.5, 3.5], [2, 5, 5, 3], 'b-', lw=2)
    ax.plot([2, 2, 6.5, 6.5], [5, 7, 7, 1], 'b-', lw=2)
    ax.text(2, 5.3, "d=5", ha='center', fontsize=9, color='blue')
    ax.text(4.25, 7.3, "d=7", ha='center', fontsize=9, color='blue')
    ax.set_ylabel("Distance", fontsize=10)
    ax.set_xlim(-1, 8)
    ax.set_ylim(-1.5, 8)

    # Plot 2: Proof trace compression
    ax = axes[0, 1]
    ax.set_title("Proof Trace Compression\n(Observational Quotient)", fontsize=12, fontweight='bold')
    space_p = proof_result[0]
    mc_p = proof_result[2]

    # Draw states as nodes
    y_positions = {0: 4, 1: 3, 2: 3, 3: 2, 4: 1}
    x_positions = {0: 1, 1: 0.5, 2: 1.5, 3: 1, 4: 1}
    colors = ['#e74c3c', '#3498db', '#3498db', '#2ecc71', '#f39c12']

    for i in range(5):
        c = colors[mc_p.labels[i]]
        ax.plot(x_positions[i], y_positions[i], 'o', markersize=20,
                color=c, zorder=5)
        ax.text(x_positions[i], y_positions[i], space_p.names[i][:8],
                ha='center', va='center', fontsize=7, fontweight='bold')

    # Draw compression arrows
    for i in range(5):
        ci = space_p.compress[i]
        if ci != i:
            ax.annotate("", xy=(x_positions[ci], y_positions[ci]),
                       xytext=(x_positions[i], y_positions[i]),
                       arrowprops=dict(arrowstyle="->", color='gray', lw=1.5))

    # Highlight equivalent states
    ax.plot([x_positions[1], x_positions[2]],
           [y_positions[1], y_positions[2]], '--', color='red', lw=2)
    ax.text(1, 3.3, "≡ (d=0)", ha='center', fontsize=9, color='red')

    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(0, 5)
    ax.axis('off')
    ax.text(1, 0.3, f"5 states → {mc_p.state_count} classes",
            ha='center', fontsize=11, fontweight='bold')

    # Plot 3: Phylogenetic potentials
    ax = axes[1, 0]
    ax.set_title("Phylogenetic Tropical Potentials", fontsize=12, fontweight='bold')
    semimodule = phylo_result[1]
    species = ["Hum", "Chm", "Gor", "Mou", "Rat"]
    for p in range(5):
        ax.plot(range(5), semimodule.representables[p], 'o-',
                label=f'φ_{species[p]}', markersize=8, lw=2)
    ax.set_xticks(range(5))
    ax.set_xticklabels(species, fontsize=10)
    ax.set_ylabel("Evolutionary Distance", fontsize=10)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)

    # Plot 4: Observer distance recovery
    ax = axes[1, 1]
    ax.set_title("Observer Distance = Original\n(All Applications)", fontsize=12, fontweight='bold')

    for label, result, marker in [("Documents", doc_result, 'o'),
                                   ("Phylogeny", phylo_result, 's')]:
        space = result[0]
        semimodule = result[1]
        d_obs = semimodule.observer_distance_matrix()
        d_orig = []
        d_obs_list = []
        for i in range(space.n):
            for j in range(i+1, space.n):
                d_orig.append(space.dist[i, j])
                d_obs_list.append(d_obs[i, j])
        ax.scatter(d_orig, d_obs_list, label=label, marker=marker, s=60, alpha=0.7)

    max_val = 85
    ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='d_obs = d')
    ax.set_xlabel("Original Distance d", fontsize=10)
    ax.set_ylabel("Observer Distance d_obs", fontsize=10)
    ax.legend(fontsize=9)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('applications_visualization.png', dpi=150, bbox_inches='tight')
    print("\n  Saved: applications_visualization.png")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    doc_result = document_clustering_demo()
    proof_result = proof_trace_demo()
    phylo_result = phylogenetic_demo()

    print("\n" + "=" * 70)
    print("Generating visualizations...")
    print("=" * 70)
    create_visualizations(doc_result, proof_result, phylo_result)

    print("\n✓ All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Ultrametric Lawvere Realization Duality: Demonstrations

This script demonstrates the core theorems with concrete numerical examples:
1. Construction of ultrametric spaces and proof potentials
2. Verification of the observer distance recovery theorem
3. Minimal compressor construction via observational quotient
4. Generator elimination for tropical semimodule basis computation
"""

import numpy as np
from itertools import combinations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def verify_ultrametric(d: np.ndarray, names: list[str] = None) -> bool:
    """Check if distance matrix d satisfies ultrametric axioms."""
    n = d.shape[0]
    if names is None:
        names = [str(i) for i in range(n)]

    # Reflexivity
    for i in range(n):
        if d[i, i] != 0:
            print(f"  FAIL: d({names[i]},{names[i]}) = {d[i,i]} != 0")
            return False

    # Symmetry
    if not np.allclose(d, d.T):
        print("  FAIL: not symmetric")
        return False

    # Strong triangle inequality
    for i, j, k in combinations(range(n), 3):
        for a, b, c in [(i,j,k), (i,k,j), (j,i,k), (j,k,i), (k,i,j), (k,j,i)]:
            if d[a, c] > max(d[a, b], d[b, c]) + 1e-10:
                print(f"  FAIL: d({names[a]},{names[c]})={d[a,c]} > max(d({names[a]},{names[b]})={d[a,b]}, d({names[b]},{names[c]})={d[b,c]})")
                return False

    print("  ✓ Ultrametric axioms verified")
    return True


def representable_potentials(d: np.ndarray) -> np.ndarray:
    """Compute all representable potentials φ_p(x) = d(x, p)."""
    n = d.shape[0]
    potentials = np.zeros((n, n))
    for p in range(n):
        potentials[p] = d[:, p]
    return potentials


def verify_potential(d: np.ndarray, phi: np.ndarray) -> bool:
    """Check 1-Lipschitz condition: φ(x) ≤ d(x,y) + φ(y) for all x,y."""
    n = d.shape[0]
    for x in range(n):
        for y in range(n):
            if phi[x] > d[x, y] + phi[y] + 1e-10:
                return False
    return True


def observer_distance(d: np.ndarray) -> np.ndarray:
    """Compute the observer distance: sup over potentials of |φ(x)-φ(y)|."""
    n = d.shape[0]
    pots = representable_potentials(d)
    obs_d = np.zeros((n, n))
    for x in range(n):
        for y in range(n):
            max_diff = 0
            for phi in pots:
                diff = max(phi[x] - phi[y], phi[y] - phi[x])
                max_diff = max(max_diff, diff)
            obs_d[x, y] = max_diff
    return obs_d


def minimal_compressor(d: np.ndarray, C: np.ndarray) -> tuple:
    """
    Compute the minimal compressor by quotienting observationally equivalent states.

    Returns: (quotient_map, num_classes, class_labels)
    """
    n = d.shape[0]
    pots = representable_potentials(d)

    # Build equivalence classes: x ≡ y iff all potentials agree
    classes = list(range(n))
    for x in range(n):
        for y in range(x + 1, n):
            equiv = True
            for phi in pots:
                if abs(phi[x] - phi[y]) > 1e-10:
                    equiv = False
                    break
            if equiv:
                # Merge classes
                cx, cy = classes[x], classes[y]
                for i in range(n):
                    if classes[i] == cy:
                        classes[i] = cx

    unique_classes = sorted(set(classes))
    class_map = {c: i for i, c in enumerate(unique_classes)}
    labels = [class_map[c] for c in classes]

    return labels, len(unique_classes), labels


def tropical_add(phi: np.ndarray, psi: np.ndarray) -> np.ndarray:
    """Tropical addition: pointwise minimum."""
    return np.minimum(phi, psi)


def tropical_scalar(c: float, phi: np.ndarray) -> np.ndarray:
    """Tropical scalar action: φ(x) + c."""
    return phi + c


def generation_check(d: np.ndarray, phi: np.ndarray) -> np.ndarray:
    """Verify φ(x) = inf_p (d(x,p) + φ(p)) for representable generation."""
    n = d.shape[0]
    reconstructed = np.full(n, np.inf)
    for p in range(n):
        reconstructed = np.minimum(reconstructed, d[:, p] + phi[p])
    return reconstructed


# =============================================================================
# DEMO 1: Three-point ultrametric space
# =============================================================================

print("=" * 70)
print("DEMO 1: Three-Point Ultrametric Proof Compression")
print("=" * 70)

# States: A=0, B=1, C=2
names_3 = ["A", "B", "C"]
d3 = np.array([
    [0, 3, 3],
    [3, 0, 1],
    [3, 1, 0]
], dtype=float)

print("\nDistance matrix d:")
for i in range(3):
    print(f"  {' '.join(f'd({names_3[i]},{names_3[j]})={d3[i,j]:.0f}' for j in range(3))}")

print("\nUltrametric verification:")
verify_ultrametric(d3, names_3)

# Compression: C collapses C→B
C3 = np.array([0, 1, 1])  # A→A, B→B, C→B
print(f"\nCompression map: {', '.join(f'{names_3[i]}→{names_3[C3[i]]}' for i in range(3))}")

# Nonexpansive check
print("\nNonexpansive verification:")
for x in range(3):
    for y in range(x+1, 3):
        d_orig = d3[x, y]
        d_comp = d3[C3[x], C3[y]]
        print(f"  d(C({names_3[x]}),C({names_3[y]})) = d({names_3[C3[x]]},{names_3[C3[y]]}) = {d_comp:.0f} ≤ {d_orig:.0f} = d({names_3[x]},{names_3[y]})  {'✓' if d_comp <= d_orig else '✗'}")

# Representable potentials
pots3 = representable_potentials(d3)
print("\nRepresentable potentials:")
for p in range(3):
    vals = [f"φ_{names_3[p]}({names_3[x]})={pots3[p,x]:.0f}" for x in range(3)]
    valid = verify_potential(d3, pots3[p])
    print(f"  {', '.join(vals)}  [1-Lipschitz: {'✓' if valid else '✗'}]")

# Observer distance
obs3 = observer_distance(d3)
print("\nObserver distance recovery (d_obs = d?):")
for x in range(3):
    for y in range(x+1, 3):
        print(f"  d_obs({names_3[x]},{names_3[y]}) = {obs3[x,y]:.0f}, d({names_3[x]},{names_3[y]}) = {d3[x,y]:.0f}  {'✓' if abs(obs3[x,y]-d3[x,y])<1e-10 else '✗'}")

# Generation check
print("\nRepresentable generation (φ(x) = inf_p d(x,p)+φ(p)):")
test_phi = np.array([1.0, 2.0, 2.5])
if verify_potential(d3, test_phi):
    recon = generation_check(d3, test_phi)
    print(f"  φ = {test_phi}")
    print(f"  inf_p(d(x,p)+φ(p)) = {recon}")
    print(f"  Equal: {'✓' if np.allclose(test_phi, recon) else '✗'}")

# Minimal compressor
labels, num_classes, _ = minimal_compressor(d3, C3)
print(f"\nMinimal compressor: {num_classes} states (from {len(names_3)})")
print(f"  Class labels: {[f'{names_3[i]}→{labels[i]}' for i in range(3)]}")


# =============================================================================
# DEMO 2: Four-point dendrogram ultrametric
# =============================================================================

print("\n" + "=" * 70)
print("DEMO 2: Four-Point Dendrogram Ultrametric")
print("=" * 70)

names_4 = ["1", "2", "3", "4"]
d4 = np.array([
    [0, 2, 4, 4],
    [2, 0, 4, 4],
    [4, 4, 0, 1],
    [4, 4, 1, 0]
], dtype=float)

print("\nDistance matrix (dendrogram tree structure):")
print("        root (d=4)")
print("       /          \\")
print("    node (d=2)   node (d=1)")
print("    / \\           / \\")
print("   1   2         3   4")

print("\nUltrametric verification:")
verify_ultrametric(d4, names_4)

# All representable potentials
pots4 = representable_potentials(d4)
print("\nRepresentable potentials (generating set):")
for p in range(4):
    vals = [f"{pots4[p,x]:.0f}" for x in range(4)]
    print(f"  φ_{names_4[p]} = [{', '.join(vals)}]")

# Observer distance
obs4 = observer_distance(d4)
print("\nObserver distance = original distance:")
all_match = True
for x in range(4):
    for y in range(x+1, 4):
        match = abs(obs4[x,y] - d4[x,y]) < 1e-10
        all_match = all_match and match
print(f"  All pairs match: {'✓' if all_match else '✗'}")

# Tropical addition demo
print("\nTropical semimodule operations:")
phi = pots4[0]  # φ_1
psi = pots4[1]  # φ_2
trop_sum = tropical_add(phi, psi)
print(f"  φ_1 = {phi}")
print(f"  φ_2 = {psi}")
print(f"  φ_1 ⊕ φ_2 = min(φ_1, φ_2) = {trop_sum}")
print(f"  Idempotent: φ_1 ⊕ φ_1 = {tropical_add(phi, phi)} = φ_1? {'✓' if np.allclose(tropical_add(phi,phi), phi) else '✗'}")
print(f"  Scalar: 3 ⊙ φ_1 = {tropical_scalar(3, phi)}")

# Extremal generator rank
labels4, num_classes4, _ = minimal_compressor(d4, np.arange(4))
print(f"\nExtremal generator rank (= MinComp states): {num_classes4}")
print(f"  (Equals |P| = {len(names_4)} since d is separated)")


# =============================================================================
# DEMO 3: Non-separated example showing quotient
# =============================================================================

print("\n" + "=" * 70)
print("DEMO 3: Non-Separated Pre-Metric (Nontrivial Quotient)")
print("=" * 70)

names_5 = ["A", "B", "B'", "C", "D"]
d5 = np.array([
    [0, 3, 3, 5, 5],
    [3, 0, 0, 2, 2],
    [3, 0, 0, 2, 2],
    [5, 2, 2, 0, 1],
    [5, 2, 2, 1, 0]
], dtype=float)

print("\nDistance matrix (B and B' have d=0, i.e., are identified):")
for i in range(5):
    row = [f"{d5[i,j]:.0f}" for j in range(5)]
    print(f"  {names_5[i]}: [{', '.join(row)}]")

print("\nUltrametric verification:")
is_ultra = True
for i in range(5):
    for j in range(5):
        for k in range(5):
            if d5[i,k] > max(d5[i,j], d5[j,k]) + 1e-10:
                is_ultra = False
print(f"  Strong triangle inequality: {'✓' if is_ultra else '✗'}")

labels5, num_classes5, _ = minimal_compressor(d5, np.arange(5))
print(f"\nMinimal compressor: {num_classes5} states (from {len(names_5)})")
print(f"  Equivalence classes: {dict(zip(names_5, labels5))}")
print(f"  B and B' identified: {'✓' if labels5[1] == labels5[2] else '✗'}")


# =============================================================================
# DEMO 4: Iteration monotonicity
# =============================================================================

print("\n" + "=" * 70)
print("DEMO 4: Compression Iteration Distance Monotonicity")
print("=" * 70)

# Use the 4-point space with a compression that brings 3→4→4
C4 = np.array([0, 0, 3, 3])  # 1→1, 2→1, 3→4, 4→4
print(f"\nCompression: {', '.join(f'{names_4[i]}→{names_4[C4[i]]}' for i in range(4))}")

print("\nIterated compression distances d(C^n(1), C^n(3)):")
x, y = 0, 2  # states 1 and 3
prev_dist = d4[x, y]
cx, cy = x, y
for n in range(5):
    dist = d4[cx, cy]
    print(f"  n={n}: d(C^{n}({names_4[x]}), C^{n}({names_4[y]})) = d({names_4[cx]},{names_4[cy]}) = {dist:.0f}  {'≤ ' + str(prev_dist) + ' ✓' if dist <= prev_dist else '✗'}")
    prev_dist = dist
    cx, cy = C4[cx], C4[cy]


# =============================================================================
# Visualization
# =============================================================================

print("\n" + "=" * 70)
print("Generating visualizations...")
print("=" * 70)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: 3-point ultrametric as weighted graph
ax = axes[0]
ax.set_title("3-Point Ultrametric Space", fontsize=13, fontweight='bold')
positions = {0: (0, 0), 1: (2, 0), 2: (1, 1.7)}
for i in range(3):
    ax.plot(*positions[i], 'ko', markersize=12, zorder=5)
    ax.annotate(names_3[i], positions[i], textcoords="offset points",
                xytext=(10, 5), fontsize=14, fontweight='bold')

for i in range(3):
    for j in range(i+1, 3):
        xi, yi = positions[i]
        xj, yj = positions[j]
        ax.plot([xi, xj], [yi, yj], 'b-', linewidth=1.5, alpha=0.5)
        mx, my = (xi+xj)/2, (yi+yj)/2
        ax.annotate(f"d={d3[i,j]:.0f}", (mx, my), fontsize=11,
                   ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

# Show compression arrow
ax.annotate("", xy=positions[1], xytext=positions[2],
           arrowprops=dict(arrowstyle="->", color='red', lw=2))
ax.text(1.8, 1.0, "C", color='red', fontsize=12, fontweight='bold')
ax.set_xlim(-0.5, 2.8)
ax.set_ylim(-0.5, 2.2)
ax.set_aspect('equal')
ax.axis('off')

# Plot 2: 4-point dendrogram
ax = axes[1]
ax.set_title("4-Point Dendrogram", fontsize=13, fontweight='bold')

# Draw dendrogram
leaf_x = [0, 1, 3, 4]
for i, x in enumerate(leaf_x):
    ax.plot(x, 0, 'ko', markersize=10, zorder=5)
    ax.text(x, -0.3, names_4[i], ha='center', fontsize=12, fontweight='bold')

# Internal nodes
ax.plot([0, 0], [0, 2], 'b-', lw=2)
ax.plot([1, 1], [0, 2], 'b-', lw=2)
ax.plot([0, 1], [2, 2], 'b-', lw=2)
ax.plot([0.5, 0.5], [2, 4], 'b-', lw=2)
ax.text(-0.3, 2, "d=2", fontsize=10, color='blue')

ax.plot([3, 3], [0, 1], 'b-', lw=2)
ax.plot([4, 4], [0, 1], 'b-', lw=2)
ax.plot([3, 4], [1, 1], 'b-', lw=2)
ax.plot([3.5, 3.5], [1, 4], 'b-', lw=2)
ax.text(4.2, 1, "d=1", fontsize=10, color='blue')

ax.plot([0.5, 3.5], [4, 4], 'b-', lw=2)
ax.text(1.5, 4.2, "d=4", fontsize=10, color='blue')

ax.set_xlim(-1, 5.5)
ax.set_ylim(-1, 5)
ax.set_ylabel("Height (distance threshold)", fontsize=11)
ax.set_aspect('equal')

# Plot 3: Observer distance = Original distance
ax = axes[2]
ax.set_title("Observer Distance Recovery", fontsize=13, fontweight='bold')

pairs = []
d_orig = []
d_obs_vals = []
for i in range(4):
    for j in range(i+1, 4):
        pairs.append(f"({names_4[i]},{names_4[j]})")
        d_orig.append(d4[i, j])
        d_obs_vals.append(obs4[i, j])

x_pos = np.arange(len(pairs))
width = 0.35
bars1 = ax.bar(x_pos - width/2, d_orig, width, label='Original d',
               color='steelblue', alpha=0.8)
bars2 = ax.bar(x_pos + width/2, d_obs_vals, width, label='Observer d_obs',
               color='coral', alpha=0.8)

ax.set_xlabel('State Pair', fontsize=11)
ax.set_ylabel('Distance', fontsize=11)
ax.set_xticks(x_pos)
ax.set_xticklabels(pairs, rotation=45, ha='right', fontsize=9)
ax.legend(fontsize=10)
ax.set_ylim(0, 5)

plt.tight_layout()
plt.savefig('ultrametric_duality_demo.png', dpi=150, bbox_inches='tight')
print("  Saved: ultrametric_duality_demo.png")

# Second figure: Potential landscape
fig2, axes2 = plt.subplots(1, 2, figsize=(12, 5))

ax = axes2[0]
ax.set_title("Representable Potentials (4-Point Space)", fontsize=13, fontweight='bold')
for p in range(4):
    ax.plot(range(4), pots4[p], 'o-', label=f'φ_{names_4[p]}', markersize=8, lw=2)
ax.set_xlabel('State index', fontsize=11)
ax.set_ylabel('Potential value', fontsize=11)
ax.set_xticks(range(4))
ax.set_xticklabels(names_4, fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

ax = axes2[1]
ax.set_title("Tropical Addition (Pointwise Min)", fontsize=13, fontweight='bold')
phi1 = pots4[0]
phi2 = pots4[2]
trop = tropical_add(phi1, phi2)
ax.plot(range(4), phi1, 's-', label=f'φ_{names_4[0]}', markersize=8, lw=2)
ax.plot(range(4), phi2, 'D-', label=f'φ_{names_4[2]}', markersize=8, lw=2)
ax.plot(range(4), trop, 'o-', label=f'φ_{names_4[0]} ⊕ φ_{names_4[2]}',
        markersize=10, lw=2.5, color='green')
ax.fill_between(range(4), trop, alpha=0.1, color='green')
ax.set_xlabel('State index', fontsize=11)
ax.set_ylabel('Potential value', fontsize=11)
ax.set_xticks(range(4))
ax.set_xticklabels(names_4, fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('potentials_tropical.png', dpi=150, bbox_inches='tight')
print("  Saved: potentials_tropical.png")

print("\n✓ All demonstrations complete.")
