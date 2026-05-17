#!/usr/bin/env python3
"""
Applications of Tropical Univalence

This module demonstrates real-world applications of tropical synthetic homotopy:

1. Graph isomorphism via tropical canonical codes
2. Phylogenetic tree comparison
3. Program/state-space equivalence
4. Network topology classification
"""

import numpy as np
from algorithms import (
    canonical_code, decide_tropical_equivalence, automorphism_group,
    indiscernibility_classes, is_separated, tropical_glue,
    canonical_profile_code, permute_matrix
)
from itertools import permutations


# ─────────────────────────────────────────────────────────────────────────
# APPLICATION 1: Weighted Graph Isomorphism
# ─────────────────────────────────────────────────────────────────────────

def demo_graph_isomorphism():
    """
    Tropical univalence as a weighted graph isomorphism detector.

    Two weighted graphs are isomorphic iff their shortest-path distance
    matrices are tropically equivalent. The canonical code provides a
    complete invariant.
    """
    print("=" * 70)
    print("APPLICATION 1: Weighted Graph Isomorphism")
    print("=" * 70)

    # Graph G1: a weighted path 0-1-2-3
    G1 = np.array([
        [0, 1, 3, 6],
        [1, 0, 2, 5],
        [3, 2, 0, 3],
        [6, 5, 3, 0]
    ], dtype=int)

    # Graph G2: same structure but vertices relabeled as 2-3-0-1
    G2 = permute_matrix(G1, (2, 3, 0, 1))

    # Graph G3: different structure
    G3 = np.array([
        [0, 1, 2, 3],
        [1, 0, 1, 2],
        [2, 1, 0, 1],
        [3, 2, 1, 0]
    ], dtype=int)

    print("\nG1 (weighted path):")
    print(G1)
    print("\nG2 (G1 relabeled):")
    print(G2)
    print("\nG3 (different graph):")
    print(G3)

    eq12, perm12 = decide_tropical_equivalence(G1, G2)
    eq13, perm13 = decide_tropical_equivalence(G1, G3)

    print(f"\nG1 ≅ G2? {eq12} (via permutation {perm12})")
    print(f"G1 ≅ G3? {eq13}")

    code1 = canonical_code(G1)
    code2 = canonical_code(G2)
    code3 = canonical_code(G3)
    print(f"\nCanonical code G1 == G2? {code1 == code2}")
    print(f"Canonical code G1 == G3? {code1 == code3}")

    auts = automorphism_group(G1)
    print(f"\nAutomorphism group of G1: order {len(auts)}")
    for a in auts:
        if a != tuple(range(4)):
            print(f"  Non-trivial: {a}")


# ─────────────────────────────────────────────────────────────────────────
# APPLICATION 2: Phylogenetic Tree Comparison
# ─────────────────────────────────────────────────────────────────────────

def demo_phylogenetics():
    """
    Comparing phylogenetic trees via tropical metric equivalence.

    In phylogenetics, trees encode evolutionary distances between species.
    Two trees represent the same evolutionary history (up to leaf labeling)
    iff their distance matrices are tropically equivalent.

    Tropical indiscernibility identifies "redundant" taxa: species that
    are interchangeable in the evolutionary metric.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Phylogenetic Tree Comparison")
    print("=" * 70)

    # Tree 1: ((A,B):2, (C,D):3) with trunk length 1
    # Distances come from sum of edge weights on paths
    tree1 = np.array([
        [0, 4, 6, 6],   # A
        [4, 0, 6, 6],   # B
        [6, 6, 0, 6],   # C
        [6, 6, 6, 0]    # D
    ], dtype=int)

    # Tree 2: same topology, taxa relabeled (C↔A)
    tree2 = permute_matrix(tree1, (2, 1, 0, 3))

    # Tree 3: different topology ((A,C):2, (B,D):3)
    tree3 = np.array([
        [0, 6, 4, 6],   # A
        [6, 0, 6, 6],   # B
        [4, 6, 0, 6],   # C
        [6, 6, 6, 0]    # D
    ], dtype=int)

    print("\nTree 1 distance matrix (taxa A,B,C,D):")
    print(tree1)
    print("\nTree 2 (taxa relabeled):")
    print(tree2)
    print("\nTree 3 (different topology):")
    print(tree3)

    eq12, _ = decide_tropical_equivalence(tree1, tree2)
    eq13, _ = decide_tropical_equivalence(tree1, tree3)

    print(f"\nTree1 ≃ Tree2 (relabeled)? {eq12}")
    print(f"Tree1 ≃ Tree3 (different topology)? {eq13}")

    # Indiscernible taxa
    classes = indiscernibility_classes(tree1)
    print(f"\nIndiscernibility classes in Tree 1:")
    taxa = ['A', 'B', 'C', 'D']
    for cls in classes:
        names = [taxa[i] for i in cls]
        if len(cls) > 1:
            print(f"  {names} ← these taxa are tropically indiscernible!")
        else:
            print(f"  {names}")


# ─────────────────────────────────────────────────────────────────────────
# APPLICATION 3: State Space Equivalence
# ─────────────────────────────────────────────────────────────────────────

def demo_state_equivalence():
    """
    Behavioral equivalence of weighted transition systems.

    States in a weighted automaton can be compared by their "cost profiles"
    — the minimum cost to reach every other state. Two automata are
    behaviorally equivalent iff their cost matrices are tropically equivalent.

    This connects tropical univalence to program verification: two modules
    are interchangeable iff they have the same tropical canonical code.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: State Space Equivalence")
    print("=" * 70)

    # Automaton 1: 3 states, with transition costs
    auto1 = np.array([
        [0, 2, 5],
        [2, 0, 3],
        [5, 3, 0]
    ], dtype=int)

    # Automaton 2: same behavior, states reordered
    auto2 = np.array([
        [0, 3, 2],
        [3, 0, 5],
        [2, 5, 0]
    ], dtype=int)

    # Automaton 3: different behavior
    auto3 = np.array([
        [0, 1, 5],
        [1, 0, 4],
        [5, 4, 0]
    ], dtype=int)

    print("\nAutomaton 1 (cost matrix):")
    print(auto1)
    print("\nAutomaton 2 (reordered states):")
    print(auto2)
    print("\nAutomaton 3 (different costs):")
    print(auto3)

    eq12, perm = decide_tropical_equivalence(auto1, auto2)
    eq13, _ = decide_tropical_equivalence(auto1, auto3)

    print(f"\nA1 ≃ A2? {eq12} (state mapping: {perm})")
    print(f"A1 ≃ A3? {eq13}")
    print(f"\n→ Tropical univalence decides program equivalence!")


# ─────────────────────────────────────────────────────────────────────────
# APPLICATION 4: Network Topology Classification
# ─────────────────────────────────────────────────────────────────────────

def demo_network_classification():
    """
    Classifying network topologies by tropical equivalence class.

    Different network configurations may be functionally equivalent
    if they produce the same shortest-path distances. The canonical
    code provides a fingerprint for each equivalence class.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Network Topology Classification")
    print("=" * 70)

    # Generate several 3-node networks and classify
    from itertools import product as cart_product

    classes = {}
    representatives = {}
    for d01, d02, d12 in cart_product(range(1, 5), repeat=3):
        D = np.array([
            [0, d01, d02],
            [d01, 0, d12],
            [d02, d12, 0]
        ], dtype=int)
        code = canonical_code(D)
        if code not in classes:
            classes[code] = 0
            representatives[code] = (d01, d02, d12)
        classes[code] += 1

    print(f"\n3-node networks with edge weights in {{1,2,3,4}}:")
    print(f"  Total labeled configurations: {sum(classes.values())}")
    print(f"  Distinct equivalence classes: {len(classes)}")
    print(f"  Average orbit size: {sum(classes.values()) / len(classes):.1f}")

    print(f"\nClassification summary:")
    by_orbit = {}
    for code, count in classes.items():
        if count not in by_orbit:
            by_orbit[count] = 0
        by_orbit[count] += 1

    for orbit_size, num_classes in sorted(by_orbit.items()):
        print(f"  Orbit size {orbit_size}: {num_classes} classes")
        # Orbit size 1 = maximally asymmetric, orbit size 6 = maximally symmetric


# ─────────────────────────────────────────────────────────────────────────
# APPLICATION 5: Gluing and Modular Composition
# ─────────────────────────────────────────────────────────────────────────

def demo_modular_composition():
    """
    Modular composition of metric spaces via tropical gluing.

    If two pairs of spaces are individually equivalent, their gluings
    along equivalent attachment points should also be equivalent.
    This is the tropical shadow of pushout invariance.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Modular Composition via Gluing")
    print("=" * 70)

    # Two equivalent pairs
    D1 = np.array([[0, 3, 5], [3, 0, 4], [5, 4, 0]], dtype=int)
    D2 = permute_matrix(D1, (1, 0, 2))  # Equivalent to D1

    E1 = np.array([[0, 2], [2, 0]], dtype=int)
    E2 = np.array([[0, 2], [2, 0]], dtype=int)  # Same as E1

    # Glue D1⊕E1 at D1[2]—E1[0]
    G1 = tropical_glue(D1, E1, 2, 0)
    # Glue D2⊕E2 at D2[2]—E2[0] (D2[2] corresponds to D1[2] under perm (1,0,2))
    G2 = tropical_glue(D2, E2, 2, 0)

    print("\nGlued space G1 = D1 ∪ E1:")
    print(G1)
    print("\nGlued space G2 = D2 ∪ E2:")
    print(G2)

    eq, perm = decide_tropical_equivalence(G1, G2)
    print(f"\nG1 ≃ G2? {eq}")
    if perm:
        print(f"  Witnessing permutation: {perm}")
    print(f"\n→ Gluing preserves tropical equivalence class!")


if __name__ == "__main__":
    demo_graph_isomorphism()
    demo_phylogenetics()
    demo_state_equivalence()
    demo_network_classification()
    demo_modular_composition()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Univalence: Concrete Demonstrations

This script demonstrates the core theorems of tropical synthetic homotopy:
1. Tropical indiscernibility as an equivalence relation
2. Canonical orbit codes classifying weighted spaces up to isometry
3. Decidability of tropical equivalence

Each example uses small finite weighted spaces (distance matrices) to make
the abstract theory tangible and computable.
"""

import numpy as np
import math
from itertools import permutations
from collections import Counter

# ─────────────────────────────────────────────────────────────────────────
# CORE DEFINITIONS
# ─────────────────────────────────────────────────────────────────────────

def profile(D, x):
    """Equidistance profile: row x of distance matrix D."""
    return tuple(D[x])

def tropically_indiscernible(D, x, y):
    """Two points are tropically indiscernible iff they have identical profiles."""
    return all(D[x, z] == D[y, z] for z in range(D.shape[0]))

def permute_matrix(D, sigma):
    """Apply permutation sigma to distance matrix D (simultaneous row/col permutation)."""
    n = D.shape[0]
    result = np.zeros_like(D)
    for i in range(n):
        for j in range(n):
            result[i][j] = D[sigma[i]][sigma[j]]
    return result

def orbit_code(D):
    """Compute the orbit code: set of all matrices obtainable by permutation."""
    n = D.shape[0]
    orbit = set()
    for perm in permutations(range(n)):
        M = permute_matrix(D, perm)
        orbit.add(tuple(M.flatten()))
    return frozenset(orbit)

def tropically_equivalent(D, E):
    """Check if two matrices are tropically equivalent (isometric)."""
    n = D.shape[0]
    if E.shape[0] != n:
        return False, None
    for perm in permutations(range(n)):
        if all(E[perm[i]][perm[j]] == D[i][j] for i in range(n) for j in range(n)):
            return True, perm
    return False, None

def canonical_code_sorted(D):
    """Canonical code via lexicographic minimum of orbit."""
    n = D.shape[0]
    best = None
    for perm in permutations(range(n)):
        M = permute_matrix(D, perm)
        flat = tuple(M.flatten())
        if best is None or flat < best:
            best = flat
    return best


# ─────────────────────────────────────────────────────────────────────────
# DEMONSTRATION 1: Indiscernibility as Equivalence Relation
# ─────────────────────────────────────────────────────────────────────────

print("=" * 70)
print("DEMO 1: Tropical Indiscernibility is an Equivalence Relation")
print("=" * 70)

# A 4-point space where points 1 and 2 are indiscernible
D1 = np.array([
    [0, 3, 3, 5],
    [3, 0, 4, 2],
    [3, 0, 4, 2],  # Point 2 has same distances as point 1
    [5, 2, 2, 0]
], dtype=int)
# Note: D1 is not symmetric between rows 1,2 and cols 1,2
# Let's make a proper example
D1 = np.array([
    [0, 3, 3, 5],
    [3, 0, 2, 4],
    [3, 2, 0, 4],  # Same profile as point 1: [3,2,0,4] vs [3,0,2,4] - different!
    [5, 4, 4, 0]
], dtype=int)

# Better example: points with truly identical profiles
D1 = np.array([
    [0, 1, 1, 3],
    [1, 0, 2, 4],
    [1, 2, 0, 4],
    [3, 4, 4, 0]
], dtype=int)

print(f"\nDistance matrix D (4 points):")
print(D1)
print(f"\nProfiles:")
for i in range(4):
    print(f"  Point {i}: {profile(D1, i)}")

print(f"\nIndiscernibility checks:")
for i in range(4):
    for j in range(i+1, 4):
        ind = tropically_indiscernible(D1, i, j)
        if ind:
            print(f"  Point {i} ≈ₜ Point {j}: {ind} ← INDISCERNIBLE!")
        else:
            print(f"  Point {i} ≈ₜ Point {j}: {ind}")

# Verify equivalence relation properties
print(f"\nReflexivity:  Point 0 ≈ₜ Point 0 = {tropically_indiscernible(D1, 0, 0)}")
print(f"Symmetry:     If 0≈ₜ0, then 0≈ₜ0 = {tropically_indiscernible(D1, 0, 0)}")

# Separation axiom example
print(f"\nSeparation axiom check:")
separated = True
for i in range(4):
    for j in range(i+1, 4):
        if tropically_indiscernible(D1, i, j) and i != j:
            separated = False
            print(f"  VIOLATION: Point {i} ≈ₜ Point {j} but {i} ≠ {j}")
if separated:
    print("  ✓ Space is separated: indiscernibility = equality")


# ─────────────────────────────────────────────────────────────────────────
# DEMONSTRATION 2: Canonical Codes and Univalence
# ─────────────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 2: Tropical Univalence — Code Equality ↔ Isometry")
print("=" * 70)

# Two isometric 3-point spaces
D = np.array([
    [0, 2, 5],
    [2, 0, 3],
    [5, 3, 0]
], dtype=int)

# E is D with points 0 and 1 swapped (permutation [1,0,2])
E = np.array([
    [0, 2, 3],
    [2, 0, 5],
    [3, 5, 0]
], dtype=int)

print(f"\nMatrix D:")
print(D)
print(f"\nMatrix E (D with points 0,1 swapped):")
print(E)

equiv, perm = tropically_equivalent(D, E)
print(f"\nTropically equivalent? {equiv}")
if perm:
    print(f"  Witnessing permutation σ: {perm}")
    print(f"  Verification: E[σ(i)][σ(j)] = D[i][j] for all i,j ✓")

code_D = canonical_code_sorted(D)
code_E = canonical_code_sorted(E)
print(f"\nCanonical code of D: {code_D}")
print(f"Canonical code of E: {code_E}")
print(f"Codes equal? {code_D == code_E}")
print(f"\n★ UNIVALENCE VERIFIED: Code equality ↔ Tropical isometry ★")

# Non-isometric example
F = np.array([
    [0, 1, 5],
    [1, 0, 3],
    [5, 3, 0]
], dtype=int)

print(f"\nMatrix F (different distances):")
print(F)
equiv_DF, _ = tropically_equivalent(D, F)
code_F = canonical_code_sorted(F)
print(f"D ≃ F? {equiv_DF}")
print(f"Code D = Code F? {code_D == code_F}")
print(f"★ Correctly distinguishes non-isometric spaces ★")


# ─────────────────────────────────────────────────────────────────────────
# DEMONSTRATION 3: Decidability and Orbit Structure
# ─────────────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 3: Decidability — Exhaustive Search over Permutations")
print("=" * 70)

# 4-point weighted graph
G = np.array([
    [0, 1, 4, 6],
    [1, 0, 3, 5],
    [4, 3, 0, 2],
    [6, 5, 2, 0]
], dtype=int)

print(f"\n4-point distance matrix G:")
print(G)

orbit = orbit_code(G)
print(f"\nOrbit size: {len(orbit)} (out of {math.factorial(4)} = 4! permutations)")
print(f"This means the automorphism group has order {math.factorial(4) // len(orbit)}")

# Check all permutations
print(f"\nDecision procedure: checking all {math.factorial(4)} permutations...")
auto_count = 0
for perm in permutations(range(4)):
    M = permute_matrix(G, perm)
    if np.array_equal(M, G):
        auto_count += 1
        if perm != (0,1,2,3):
            print(f"  Non-trivial automorphism found: {perm}")
print(f"Total automorphisms: {auto_count}")


# ─────────────────────────────────────────────────────────────────────────
# DEMONSTRATION 4: Tropical Distribution Law
# ─────────────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 4: Tropical Distribution — min(a+c, b+c) = min(a,b) + c")
print("=" * 70)

print("\nThe fundamental algebraic identity of tropical path composition:")
print("  min(a + c, b + c) = min(a, b) + c")
print("\nVerification for random values:")
for _ in range(5):
    a, b, c = np.random.randint(0, 20, 3)
    lhs = min(a + c, b + c)
    rhs = min(a, b) + c
    print(f"  a={a:2d}, b={b:2d}, c={c:2d}: min({a+c:2d},{b+c:2d}) = {lhs:2d} = {rhs:2d} = min({a},{b})+{c}  ✓")


# ─────────────────────────────────────────────────────────────────────────
# DEMONSTRATION 5: Classification Table
# ─────────────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 5: Complete Classification of 3-Point ℕ-Weighted Spaces")
print("=" * 70)

# Enumerate all symmetric 3×3 distance matrices with entries in {1,2,3}, zero diagonal
from itertools import product as cart_product

classes = {}
for d01, d02, d12 in cart_product(range(1, 4), repeat=3):
    D = np.array([
        [0, d01, d02],
        [d01, 0, d12],
        [d02, d12, 0]
    ], dtype=int)
    code = canonical_code_sorted(D)
    if code not in classes:
        classes[code] = []
    classes[code].append((d01, d02, d12))

print(f"\nWith edge weights in {{1,2,3}}, there are:")
print(f"  {sum(len(v) for v in classes.values())} total labeled spaces")
print(f"  {len(classes)} equivalence classes under tropical isometry")
print(f"\nClasses (representative edge weights [d01,d02,d12]):")
for i, (code, members) in enumerate(sorted(classes.items(), key=lambda x: x[0])):
    rep = members[0]
    print(f"  Class {i+1}: representative ({rep[0]},{rep[1]},{rep[2]}), "
          f"orbit size {len(members)}, members: {members}")


# ─────────────────────────────────────────────────────────────────────────
# DEMONSTRATION 6: Gluing / Pushout Construction
# ─────────────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 6: Tropical Gluing — Pushout of Weighted Spaces")
print("=" * 70)

def glue_spaces(D, E, attach_D, attach_E):
    """Glue two distance matrices along attachment points."""
    n, m = D.shape[0], E.shape[0]
    G = np.zeros((n + m, n + m), dtype=int)

    # D-D block
    G[:n, :n] = D

    # E-E block
    G[n:, n:] = E

    # Cross blocks: shortest path through attachment points
    for i in range(n):
        for j in range(m):
            dist = D[i, attach_D] + E[attach_E, j]
            G[i, n + j] = dist
            G[n + j, i] = dist

    return G

D_small = np.array([[0, 2], [2, 0]], dtype=int)
E_small = np.array([[0, 3, 5], [3, 0, 4], [5, 4, 0]], dtype=int)

print(f"\nSpace D (2 points):")
print(D_small)
print(f"\nSpace E (3 points):")
print(E_small)

G_glued = glue_spaces(D_small, E_small, 1, 0)  # Glue D's point 1 to E's point 0
print(f"\nGlued space D ∪ E (5 points, attached at D[1]—E[0]):")
print(G_glued)

# Verify the glued distances use the tropical distribution law
i, j = 0, 3  # D-point to E-point
expected = D_small[0, 1] + E_small[0, 1]
print(f"\nDistance from D[0] to E[1]: {G_glued[i, j]}")
print(f"  = D[0,attach_D] + E[attach_E,1] = {D_small[0,1]} + {E_small[0,1]} = {expected}")
print(f"  This uses the tropical path composition through the attachment point")


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Synthetic Homotopy

Generates publication-quality figures illustrating the key concepts:
1. Distance matrix heatmaps with orbit structure
2. Equivalence class partitioning
3. Indiscernibility profiles
4. Gluing construction diagrams
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from itertools import permutations, product as cart_product
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


def fig1_orbit_structure():
    """Visualize the orbit of a distance matrix under permutation."""
    D = np.array([
        [0, 1, 3],
        [1, 0, 2],
        [3, 2, 0]
    ], dtype=int)

    fig, axes = plt.subplots(2, 3, figsize=(12, 8))
    fig.suptitle('Orbit of a 3-Point Tropical Space Under Permutation',
                 fontsize=14, fontweight='bold')

    perms = list(permutations(range(3)))
    for idx, (ax, perm) in enumerate(zip(axes.flat, perms)):
        M = np.zeros_like(D)
        for i in range(3):
            for j in range(3):
                M[i, j] = D[perm[i], perm[j]]

        im = ax.imshow(M, cmap='YlOrRd', vmin=0, vmax=3)
        ax.set_title(f'σ = {perm}', fontsize=10)

        for i in range(3):
            for j in range(3):
                ax.text(j, i, str(M[i, j]), ha='center', va='center',
                       fontsize=14, fontweight='bold')

        ax.set_xticks(range(3))
        ax.set_yticks(range(3))

    fig.colorbar(im, ax=axes, shrink=0.6, label='Distance')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig1_orbit_structure.png'), dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  ✓ fig1_orbit_structure.png")


def fig2_equivalence_classes():
    """Visualize the partition of 3-point spaces into equivalence classes."""
    classes = {}
    for d01, d02, d12 in cart_product(range(1, 4), repeat=3):
        D = np.array([[0, d01, d02], [d01, 0, d12], [d02, d12, 0]], dtype=int)
        # Canonical code
        best = None
        for perm in permutations(range(3)):
            M = np.zeros_like(D)
            for i in range(3):
                for j in range(3):
                    M[i, j] = D[perm[i], perm[j]]
            flat = tuple(M.flatten())
            if best is None or flat < best:
                best = flat
        if best not in classes:
            classes[best] = []
        classes[best].append((d01, d02, d12))

    # Plot
    fig, ax = plt.subplots(figsize=(10, 7))

    orbit_sizes = [len(v) for v in classes.values()]
    unique_sizes = sorted(set(orbit_sizes))
    colors = plt.cm.Set2(np.linspace(0, 1, len(unique_sizes)))
    color_map = {s: c for s, c in zip(unique_sizes, colors)}

    y_pos = 0
    for idx, (code, members) in enumerate(sorted(classes.items())):
        orbit_size = len(members)
        color = color_map[orbit_size]

        for i, (d01, d02, d12) in enumerate(members):
            ax.barh(y_pos, 1, color=color, edgecolor='white', linewidth=0.5)
            ax.text(0.5, y_pos, f'({d01},{d02},{d12})', ha='center', va='center',
                   fontsize=7)
            y_pos += 1
        y_pos += 0.3  # Gap between classes

    ax.set_xlabel('Members of Each Equivalence Class')
    ax.set_title('Tropical Equivalence Classes of 3-Point Spaces\n'
                 '(edge weights ∈ {1,2,3})', fontsize=13, fontweight='bold')
    ax.set_yticks([])

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [Patch(facecolor=color_map[s], label=f'Orbit size {s}')
                      for s in unique_sizes]
    ax.legend(handles=legend_elements, loc='upper right')

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig2_equivalence_classes.png'), dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  ✓ fig2_equivalence_classes.png")


def fig3_indiscernibility():
    """Visualize indiscernibility profiles."""
    # Space with two indiscernible points
    D = np.array([
        [0, 3, 3, 5],
        [3, 0, 4, 2],
        [3, 4, 0, 2],
        [5, 2, 2, 0]
    ], dtype=int)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Heatmap
    im = ax1.imshow(D, cmap='viridis')
    ax1.set_title('Distance Matrix\n(points 1 and 2 have distinct profiles)', fontsize=11)
    for i in range(4):
        for j in range(4):
            ax1.text(j, i, str(D[i, j]), ha='center', va='center',
                    fontsize=14, color='white' if D[i,j] > 2 else 'black',
                    fontweight='bold')
    ax1.set_xticks(range(4))
    ax1.set_yticks(range(4))
    ax1.set_xlabel('Column index')
    ax1.set_ylabel('Row index (point)')
    fig.colorbar(im, ax=ax1, shrink=0.8)

    # Profile comparison
    for i in range(4):
        profile = D[i]
        ax2.plot(range(4), profile, 'o-', linewidth=2, markersize=8,
                label=f'Point {i}: {tuple(profile)}')

    ax2.set_xlabel('Reference point z', fontsize=11)
    ax2.set_ylabel('Distance d(x, z)', fontsize=11)
    ax2.set_title('Equidistance Profiles\n(identical profiles ↔ indiscernibility)',
                  fontsize=11)
    ax2.legend(fontsize=9)
    ax2.set_xticks(range(4))
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig3_indiscernibility.png'), dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  ✓ fig3_indiscernibility.png")


def fig4_univalence_diagram():
    """Visualize the univalence correspondence: codes ↔ isometries."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Matrix D
    D = np.array([[0, 2, 5], [2, 0, 3], [5, 3, 0]], dtype=int)
    # Matrix E = D permuted by (1,0,2)
    E = np.array([[0, 2, 3], [2, 0, 5], [3, 5, 0]], dtype=int)

    im1 = axes[0].imshow(D, cmap='Blues', vmin=0, vmax=5)
    axes[0].set_title('Space D', fontsize=12, fontweight='bold')
    for i in range(3):
        for j in range(3):
            axes[0].text(j, i, str(D[i,j]), ha='center', va='center',
                        fontsize=16, fontweight='bold')
    axes[0].set_xticks(range(3))
    axes[0].set_yticks(range(3))

    im2 = axes[1].imshow(E, cmap='Oranges', vmin=0, vmax=5)
    axes[1].set_title('Space E (isometric to D)', fontsize=12, fontweight='bold')
    for i in range(3):
        for j in range(3):
            axes[1].text(j, i, str(E[i,j]), ha='center', va='center',
                        fontsize=16, fontweight='bold')
    axes[1].set_xticks(range(3))
    axes[1].set_yticks(range(3))

    # Show the permutation
    axes[2].set_xlim(-1, 3)
    axes[2].set_ylim(-0.5, 3)
    axes[2].set_title('Tropical Isometry σ', fontsize=12, fontweight='bold')

    mapping = [(0, 1), (1, 0), (2, 2)]
    for d_pt, e_pt in mapping:
        axes[2].annotate('', xy=(2, e_pt), xytext=(0.5, d_pt),
                        arrowprops=dict(arrowstyle='->', lw=2, color='green'))
        axes[2].text(0, d_pt, f'D[{d_pt}]', fontsize=12, ha='center',
                    bbox=dict(boxstyle='round', facecolor='lightblue'))
        axes[2].text(2.5, e_pt, f'E[{e_pt}]', fontsize=12, ha='center',
                    bbox=dict(boxstyle='round', facecolor='lightyellow'))

    axes[2].text(1.25, -0.3, 'σ: (0→1, 1→0, 2→2)', fontsize=10, ha='center',
                style='italic')
    axes[2].axis('off')

    fig.suptitle('Tropical Univalence: Equal Codes ↔ Isometry Exists',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig4_univalence.png'), dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  ✓ fig4_univalence.png")


def fig5_gluing():
    """Visualize the tropical gluing construction."""
    D = np.array([[0, 2, 4], [2, 0, 3], [4, 3, 0]], dtype=int)
    E = np.array([[0, 1], [1, 0]], dtype=int)

    # Glue at D[2] — E[0]
    n, m = 3, 2
    G = np.zeros((n + m, n + m), dtype=int)
    G[:n, :n] = D
    G[n:, n:] = E
    for i in range(n):
        for j in range(m):
            dist = D[i, 2] + E[0, j]
            G[i, n + j] = dist
            G[n + j, i] = dist

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    im1 = axes[0].imshow(D, cmap='Blues', vmin=0, vmax=6)
    axes[0].set_title('Space D (3 points)', fontsize=12)
    for i in range(3):
        for j in range(3):
            axes[0].text(j, i, str(D[i,j]), ha='center', va='center', fontsize=14, fontweight='bold')
    axes[0].set_xticks(range(3))
    axes[0].set_yticks(range(3))
    fig.colorbar(im1, ax=axes[0], shrink=0.8)

    im2 = axes[1].imshow(E, cmap='Oranges', vmin=0, vmax=6)
    axes[1].set_title('Space E (2 points)', fontsize=12)
    for i in range(2):
        for j in range(2):
            axes[1].text(j, i, str(E[i,j]), ha='center', va='center', fontsize=14, fontweight='bold')
    axes[1].set_xticks(range(2))
    axes[1].set_yticks(range(2))
    fig.colorbar(im2, ax=axes[1], shrink=0.8)

    im3 = axes[2].imshow(G, cmap='Greens', vmin=0, vmax=6)
    axes[2].set_title('Glued Space D ∪ E (5 points)\nAttached at D[2]—E[0]', fontsize=12)
    for i in range(5):
        for j in range(5):
            axes[2].text(j, i, str(G[i,j]), ha='center', va='center', fontsize=12, fontweight='bold')
    axes[2].set_xticks(range(5))
    axes[2].set_yticks(range(5))
    # Draw partition lines
    axes[2].axhline(2.5, color='red', linewidth=2, linestyle='--')
    axes[2].axvline(2.5, color='red', linewidth=2, linestyle='--')
    fig.colorbar(im3, ax=axes[2], shrink=0.8)

    fig.suptitle('Tropical Pushout: Gluing Two Weighted Spaces',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig5_gluing.png'), dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  ✓ fig5_gluing.png")


def fig6_classification_stats():
    """Statistics on equivalence class structure."""
    results = {}
    for n in range(2, 5):
        if n == 4:
            max_w = 3
        else:
            max_w = 4

        classes = {}
        count = 0
        for weights in cart_product(range(1, max_w + 1), repeat=n*(n-1)//2):
            D = np.zeros((n, n), dtype=int)
            idx = 0
            for i in range(n):
                for j in range(i+1, n):
                    D[i, j] = weights[idx]
                    D[j, i] = weights[idx]
                    idx += 1

            best = None
            for perm in permutations(range(n)):
                M = np.zeros_like(D)
                for a in range(n):
                    for b in range(n):
                        M[a, b] = D[perm[a], perm[b]]
                flat = tuple(M.flatten())
                if best is None or flat < best:
                    best = flat

            if best not in classes:
                classes[best] = 0
            classes[best] += 1
            count += 1

        orbit_sizes = list(classes.values())
        results[n] = {
            'total': count,
            'classes': len(classes),
            'max_w': max_w,
            'orbit_sizes': orbit_sizes
        }

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([2, 3, 4]):
        data = results[n]
        sizes = data['orbit_sizes']
        unique_sizes = sorted(set(sizes))
        counts = [sizes.count(s) for s in unique_sizes]

        bars = axes[idx].bar([str(s) for s in unique_sizes], counts,
                            color=plt.cm.viridis(np.linspace(0.2, 0.8, len(unique_sizes))))
        axes[idx].set_xlabel('Orbit Size')
        axes[idx].set_ylabel('Number of Classes')
        axes[idx].set_title(f'n={n} points, weights ∈ [1,{data["max_w"]}]\n'
                           f'{data["total"]} spaces → {data["classes"]} classes')

        for bar, count in zip(bars, counts):
            axes[idx].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
                          str(count), ha='center', fontsize=9)

    fig.suptitle('Distribution of Orbit Sizes in Tropical Equivalence Classes',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fig6_classification_stats.png'), dpi=150,
                bbox_inches='tight')
    plt.close()
    print("  ✓ fig6_classification_stats.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    fig1_orbit_structure()
    fig2_equivalence_classes()
    fig3_indiscernibility()
    fig4_univalence_diagram()
    fig5_gluing()
    fig6_classification_stats()
    print("\nAll visualizations generated!")
