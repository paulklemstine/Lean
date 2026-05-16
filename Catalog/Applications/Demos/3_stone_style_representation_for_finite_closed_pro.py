#!/usr/bin/env python3
"""
Applications of the Finite Stone Representation Theorem

Demonstrates applications to:
1. Proof-state compression via atom decomposition
2. Abstract interpretation domain analysis
3. Cryptographic state fingerprinting
4. Knowledge representation / formal concept analysis
"""

from algorithms import (
    stone_analysis, enumerate_fixed_points, extract_atoms,
    compute_equivalence_classes, build_stone_isomorphism
)
from itertools import combinations
import hashlib


# ===========================================================================
#  Application 1: Proof-State Compression
# ===========================================================================

def proof_state_compression():
    """Demonstrate proof-state compression via atom decomposition.

    In automated reasoning, proof states are sets of active hypotheses.
    A closure operator represents logical consequence: O(S) = all hypotheses
    derivable from S. Fixed points are "complete" states.

    The Stone theorem shows that if complement-closure holds,
    every complete state is uniquely identified by its atom-support:
    a compact fingerprint of size log2(|FP|) bits instead of |α| bits.
    """
    print("=" * 70)
    print("APPLICATION 1: Proof-State Compression")
    print("=" * 70)

    # 10 hypotheses, grouped into 4 independent "topics"
    alpha = frozenset(range(10))
    topics = [
        frozenset({0, 1, 2}),     # Topic A
        frozenset({3, 4}),         # Topic B
        frozenset({5, 6, 7}),      # Topic C
        frozenset({8, 9}),         # Topic D
    ]

    def consequence_closure(s):
        result = set()
        for t in topics:
            if t & s:
                result |= t
        return frozenset(result)

    result = stone_analysis(alpha, consequence_closure)
    fps = result["fixed_points"]
    at = result["atoms"]

    print(f"  Hypotheses:     {len(alpha)}")
    print(f"  Topics:         {len(topics)}")
    print(f"  Complete states: {len(fps)}")
    print(f"  Atoms:          {len(at)}")
    print()

    # Compression ratio
    original_bits = len(alpha)  # need |α| bits to represent any subset
    compressed_bits = len(at)    # only |atoms| bits needed
    print(f"  Original representation:   {original_bits} bits per state")
    print(f"  Compressed representation: {compressed_bits} bits per state")
    print(f"  Compression ratio:         {compressed_bits/original_bits:.1%}")
    print()

    # Show some states and their compressed forms
    iso = result.get("isomorphism")
    if iso:
        print("  Sample states and their atom-fingerprints:")
        for s in fps[:6]:
            fp = iso.forward[s]
            tag = set(s) if s else "{}"
            print(f"    {str(tag):35s} → atom support {set(fp)}")
    print()


# ===========================================================================
#  Application 2: Abstract Interpretation Domains
# ===========================================================================

def abstract_interpretation():
    """Demonstrate how the Stone theorem classifies abstract domains.

    In static program analysis, abstract domains are closure systems.
    The theorem says: if your abstraction is complement-stable
    (can represent both "property holds" and "property doesn't hold"),
    then your domain is exactly a powerset of independent properties.
    """
    print("=" * 70)
    print("APPLICATION 2: Abstract Interpretation Domain Analysis")
    print("=" * 70)

    # Variable states: 6 program points
    alpha = frozenset(range(6))

    # Example 1: complement-stable abstraction (sign analysis with full negation)
    blocks_cs = [frozenset({0, 1}), frozenset({2, 3}), frozenset({4, 5})]
    def cl_cs(s):
        result = set()
        for b in blocks_cs:
            if b & s:
                result |= b
        return frozenset(result)

    r1 = stone_analysis(alpha, cl_cs)
    print(f"  Example 1: Complement-stable domain")
    print(f"    |Domain| = {len(r1['fixed_points'])}")
    print(f"    Is Boolean: {'✓' if r1['is_boolean'] else '✗'}")
    print(f"    Independent properties: {len(r1['atoms'])}")
    atom_ids = ', '.join(str(i) for i in range(len(r1['atoms'])))
    print(f'    -> Domain = P({atom_ids}) (powerset)')
    print()

    # Example 2: non-complement-stable abstraction (interval analysis)
    # Closed sets: ∅, {0}, {0,1}, {0,1,2}, ..., {0,...,5}
    intervals = [frozenset(range(k)) for k in range(7)]
    def cl_interval(s):
        for iv in intervals:
            if s <= iv:
                return iv
        return alpha  # shouldn't reach here

    r2 = stone_analysis(alpha, cl_interval)
    print(f"  Example 2: Non-complement-stable domain (interval-like)")
    print(f"    |Domain| = {len(r2['fixed_points'])}")
    print(f"    Is Boolean: {'✓' if r2['is_boolean'] else '✗'}")
    print(f"    Complement-stable: {'✓' if r2['properties']['complement_stable'] else '✗'}")
    print(f"    → NOT a powerset algebra (not decomposable into independent atoms)")
    print()


# ===========================================================================
#  Application 3: Cryptographic State Fingerprinting
# ===========================================================================

def crypto_fingerprinting():
    """Demonstrate closure-invariant fingerprinting.

    Given a closure operator (modeling a one-way function's algebraic structure),
    the atom-support provides a canonical, compressed fingerprint of each
    closure-stable state. Two states have the same fingerprint iff they
    are equivalent under the closure.
    """
    print("=" * 70)
    print("APPLICATION 3: Cryptographic State Fingerprinting")
    print("=" * 70)

    alpha = frozenset(range(12))
    blocks = [
        frozenset({0, 1, 2}),
        frozenset({3, 4}),
        frozenset({5, 6, 7, 8}),
        frozenset({9, 10}),
        frozenset({11}),
    ]

    def cl(s):
        result = set()
        for b in blocks:
            if b & s:
                result |= b
        return frozenset(result)

    fps = enumerate_fixed_points(alpha, cl)
    at = extract_atoms(fps)
    iso = build_stone_isomorphism(fps, at)

    print(f"  State space: {len(alpha)} elements")
    print(f"  Fixed points: {len(fps)}")
    print(f"  Atoms: {len(at)}")
    print()

    # Fingerprinting
    print("  Fingerprint table:")
    print(f"  {'State':35s}  {'Atom-support':15s}  {'Hash (first 8 chars)':20s}")
    print("  " + "-" * 72)
    for s in fps:
        support = iso.forward[s]
        support_str = str(sorted(support))
        h = hashlib.sha256(support_str.encode()).hexdigest()[:8]
        tag = set(s) if s else "{}"
        print(f"  {str(tag):35s}  {str(set(support)):15s}  {h}")
    print()

    # Verify uniqueness
    fingerprints = [iso.forward[s] for s in fps]
    unique = len(set(fingerprints)) == len(fingerprints)
    print(f"  All fingerprints unique: {'✓' if unique else '✗'}")
    print(f"  Fingerprint size: {len(at)} bits (vs {len(alpha)} original)")
    print()


# ===========================================================================
#  Application 4: Formal Concept Analysis
# ===========================================================================

def formal_concept_analysis():
    """Demonstrate connection to Formal Concept Analysis.

    In FCA, a formal context is a relation between objects and attributes.
    The closure operator maps sets of objects to their common attributes' extent.
    When this closure is complement-stable, the concept lattice is Boolean,
    meaning all attributes are independent — the simplest possible structure.
    """
    print("=" * 70)
    print("APPLICATION 4: Formal Concept Analysis")
    print("=" * 70)

    # Objects = {0,1,2,3,4,5}, Attributes = {A, B, C}
    # Independent attributes (complement-stable case)
    objects = frozenset(range(6))
    attr_A = frozenset({0, 1})   # objects with attribute A
    attr_B = frozenset({2, 3})   # objects with attribute B
    attr_C = frozenset({4, 5})   # objects with attribute C

    attribute_extents = [attr_A, attr_B, attr_C]

    # Closure = close under shared attributes
    def concept_closure(s):
        result = set()
        for ext in attribute_extents:
            if ext & s:
                result |= ext
        return frozenset(result)

    result = stone_analysis(objects, concept_closure)
    fps = result["fixed_points"]
    at = result["atoms"]

    print(f"  Objects:    {set(objects)}")
    print(f"  Attributes: A={set(attr_A)}, B={set(attr_B)}, C={set(attr_C)}")
    print(f"  Concepts (fixed points): {len(fps)}")
    print(f"  Is Boolean lattice: {'✓' if result['is_boolean'] else '✗'}")
    print()

    if result['is_boolean']:
        print(f"  The concept lattice is Boolean with {len(at)} atoms.")
        print(f"  This means all {len(at)} attributes are logically independent.")
        print(f"  Concept lattice ≅ P({{A, B, C}}) — the simplest possible structure.")
    print()


if __name__ == "__main__":
    proof_state_compression()
    abstract_interpretation()
    crypto_fingerprinting()
    formal_concept_analysis()


#!/usr/bin/env python3
"""
Finite Stone Representation — Interactive Demo

Demonstrates how closure operators on finite sets produce
fixed-point Boolean algebras that are isomorphic to powerset algebras.
"""

from itertools import combinations
from typing import Callable, FrozenSet, Set as TSet


# ===========================================================================
#  Core types
# ===========================================================================
Universe = frozenset          # ground set α
Subset   = frozenset          # element of P(α)
Closure  = Callable[[Subset], Subset]   # O : P(α) → P(α)


def powerset(s: frozenset) -> list[frozenset]:
    """Return every subset of s (as a list of frozensets)."""
    elems = sorted(s)
    out = []
    for r in range(len(elems) + 1):
        for c in combinations(elems, r):
            out.append(frozenset(c))
    return out


# ===========================================================================
#  Closure-operator builders
# ===========================================================================

def make_partition_closure(alpha: frozenset,
                           blocks: list[frozenset]) -> Closure:
    """Build a closure operator from a partition of alpha.

    O(S) = union of every block that intersects S.
    This is monotone, extensive, idempotent, and complement-stable.
    """
    def cl(s: Subset) -> Subset:
        result: TSet[object] = set()
        for b in blocks:
            if b & s:
                result |= b
        return frozenset(result)
    return cl


def make_topological_closure(alpha: frozenset,
                             closed_sets: list[frozenset]) -> Closure:
    """Closure = intersection of all closed sets containing S."""
    def cl(s: Subset) -> Subset:
        result = alpha
        for c in closed_sets:
            if s <= c and c <= result:
                result = c
        return result
    return cl


# ===========================================================================
#  Compute fixed points & check properties
# ===========================================================================

def fixed_points(alpha: frozenset, cl: Closure) -> list[frozenset]:
    """Return all S ⊆ α with cl(S) = S, sorted by size."""
    fps = [s for s in powerset(alpha) if cl(s) == s]
    return sorted(fps, key=lambda s: (len(s), sorted(s)))


def is_monotone(alpha: frozenset, cl: Closure) -> bool:
    ps = powerset(alpha)
    for s in ps:
        for t in ps:
            if s <= t and not cl(s) <= cl(t):
                return False
    return True


def is_extensive(alpha: frozenset, cl: Closure) -> bool:
    return all(s <= cl(s) for s in powerset(alpha))


def is_idempotent(alpha: frozenset, cl: Closure) -> bool:
    return all(cl(cl(s)) == cl(s) for s in powerset(alpha))


def is_complement_stable(alpha: frozenset, cl: Closure) -> bool:
    fps = fixed_points(alpha, cl)
    for s in fps:
        comp = alpha - s
        if cl(comp) != comp:
            return False
    return True


def equiv_classes(alpha: frozenset, fps: list[frozenset]) -> list[frozenset]:
    """Compute the equivalence classes: x ~ y iff they belong to the same fps."""
    classes: list[frozenset] = []
    remaining = set(alpha)
    while remaining:
        x = min(remaining)
        cls: TSet[object] = set()
        for a in alpha:
            same = True
            for s in fps:
                if (x in s) != (a in s):
                    same = False
                    break
            if same:
                cls.add(a)
        classes.append(frozenset(cls))
        remaining -= cls
    return classes


def atoms(fps: list[frozenset]) -> list[frozenset]:
    """Return atoms: minimal nonempty fixed points."""
    nonempty = [s for s in fps if s]
    result = []
    for s in nonempty:
        is_atom = True
        for t in nonempty:
            if t < s:      # strictly smaller nonempty fixed point exists
                is_atom = False
                break
        if is_atom:
            result.append(s)
    return result


# ===========================================================================
#  Demo 1: Partition closure on {0,1,2,3,4,5}
# ===========================================================================
def demo_partition():
    print("=" * 70)
    print("DEMO 1: Partition Closure on {0,1,2,3,4,5}")
    print("=" * 70)
    alpha = frozenset(range(6))
    blocks = [frozenset({0, 1}), frozenset({2, 3}), frozenset({4, 5})]
    cl = make_partition_closure(alpha, blocks)

    print(f"  Ground set:  {set(alpha)}")
    print(f"  Partition:   {[set(b) for b in blocks]}")
    print()

    fps = fixed_points(alpha, cl)
    print(f"  Fixed points ({len(fps)} total):")
    for s in fps:
        print(f"    {set(s) if s else '{}'}")
    print()

    at = atoms(fps)
    print(f"  Atoms ({len(at)}):")
    for a in at:
        print(f"    {set(a)}")

    classes = equiv_classes(alpha, fps)
    print(f"  Equivalence classes ({len(classes)}):")
    for c in classes:
        print(f"    {set(c)}")

    print()
    print(f"  Expected: |fixed points| = 2^|atoms| = 2^{len(at)} = {2**len(at)}")
    print(f"  Actual:   |fixed points| = {len(fps)}")
    assert len(fps) == 2 ** len(at), "Mismatch!"
    print("  ✓ Stone representation confirmed: fixed points ≅ P(atoms)")
    print()

    # Verify properties
    props = {
        "Monotone": is_monotone(alpha, cl),
        "Extensive": is_extensive(alpha, cl),
        "Idempotent": is_idempotent(alpha, cl),
        "Complement-stable": is_complement_stable(alpha, cl),
    }
    for name, ok in props.items():
        print(f"  {name}: {'✓' if ok else '✗'}")
    print()


# ===========================================================================
#  Demo 2: Arbitrary closure (not complement-stable) → NOT a powerset
# ===========================================================================
def demo_non_boolean():
    print("=" * 70)
    print("DEMO 2: Non-complement-stable closure on {0,1,2}")
    print("=" * 70)
    alpha = frozenset(range(3))
    # Closed sets: ∅, {0}, {0,1,2}  (not complement-stable!)
    closed_sets = [frozenset(), frozenset({0}), alpha]
    cl = make_topological_closure(alpha, closed_sets)

    print(f"  Ground set:  {set(alpha)}")
    print(f"  Closed sets: {[set(c) for c in closed_sets]}")
    print()

    fps = fixed_points(alpha, cl)
    print(f"  Fixed points ({len(fps)} total):")
    for s in fps:
        print(f"    {set(s) if s else '{}'}")
    print()

    comp_stable = is_complement_stable(alpha, cl)
    print(f"  Complement-stable: {'✓' if comp_stable else '✗'}")
    print(f"  |Fixed points| = {len(fps)}")

    import math
    is_power_of_2 = len(fps) > 0 and (len(fps) & (len(fps) - 1)) == 0
    print(f"  Is a power of 2? {'Yes' if is_power_of_2 else 'No'}")
    if not is_power_of_2:
        print("  → NOT a Boolean algebra (not isomorphic to any powerset)")
    print()


# ===========================================================================
#  Demo 3: The identity operator (finest partition)
# ===========================================================================
def demo_identity():
    print("=" * 70)
    print("DEMO 3: Identity Closure (finest partition) on {0,1,2,3}")
    print("=" * 70)
    alpha = frozenset(range(4))
    blocks = [frozenset({x}) for x in alpha]
    cl = make_partition_closure(alpha, blocks)

    fps = fixed_points(alpha, cl)
    at = atoms(fps)
    classes = equiv_classes(alpha, fps)

    print(f"  Ground set:  {set(alpha)}")
    print(f"  Partition:   {[set(b) for b in blocks]}  (singletons)")
    print(f"  Fixed points: {len(fps)} = 2^{len(at)} = {2**len(at)}")
    print(f"  Atoms: {len(at)}  (one per element)")
    print(f"  Equivalence classes: {len(classes)}  (one per element)")
    print(f"  → Isomorphic to P({set(alpha)}) itself")
    print()


# ===========================================================================
#  Demo 4: Coarsest partition (trivial closure)
# ===========================================================================
def demo_trivial():
    print("=" * 70)
    print("DEMO 4: Trivial Closure (coarsest partition) on {0,1,2,3}")
    print("=" * 70)
    alpha = frozenset(range(4))
    blocks = [alpha]  # single block
    cl = make_partition_closure(alpha, blocks)

    fps = fixed_points(alpha, cl)
    at = atoms(fps)

    print(f"  Ground set: {set(alpha)}")
    print(f"  Partition:  [{set(alpha)}]  (single block)")
    print(f"  Fixed points: {len(fps)}  (only ∅ and {set(alpha)})")
    print(f"  Atoms: {len(at)}  ({set(alpha)})")
    print(f"  → Isomorphic to P({{*}}) = {{∅, {{*}}}}")
    print()


# ===========================================================================
#  Demo 5: Show the bijection explicitly
# ===========================================================================
def demo_bijection():
    print("=" * 70)
    print("DEMO 5: Explicit Bijection — Fixed Points ↔ P(atoms)")
    print("=" * 70)
    alpha = frozenset(range(8))
    blocks = [frozenset({0, 1}), frozenset({2}),
              frozenset({3, 4, 5}), frozenset({6, 7})]
    cl = make_partition_closure(alpha, blocks)

    fps = fixed_points(alpha, cl)
    at = atoms(fps)

    print(f"  Ground set: {set(alpha)}")
    print(f"  Partition:  {[set(b) for b in blocks]}")
    print(f"  Atoms:      {[set(a) for a in at]}")
    print(f"  |FP| = {len(fps)},  2^|atoms| = {2**len(at)}")
    print()

    # Build the bijection: φ(S) = {atoms ⊆ S}
    print("  Bijection  φ : FixedPoints → P(Atoms)")
    print("  " + "-" * 50)
    for s in fps:
        atom_support = frozenset(i for i, a in enumerate(at) if a <= s)
        tag = set(s) if s else "{}"
        print(f"    {str(tag):30s}  ↦  {set(atom_support)}")
    print()


if __name__ == "__main__":
    demo_partition()
    demo_non_boolean()
    demo_identity()
    demo_trivial()
    demo_bijection()


#!/usr/bin/env python3
"""
Visualizations for Finite Stone Representation Theorem
Generates publication-quality figures as PNG files.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
import base64
from io import BytesIO


def powerset(s):
    elems = sorted(s)
    out = []
    for r in range(len(elems) + 1):
        for c in combinations(elems, r):
            out.append(frozenset(c))
    return out


def make_partition_closure(alpha, blocks):
    def cl(s):
        result = set()
        for b in blocks:
            if b & s:
                result |= b
        return frozenset(result)
    return cl


# ===========================================================================
#  Figure 1: Fixed-Point Lattice Hasse Diagram
# ===========================================================================

def figure_hasse_diagram():
    """Draw the Hasse diagram of fixed points for a partition closure."""
    alpha = frozenset(range(6))
    blocks = [frozenset({0, 1}), frozenset({2, 3}), frozenset({4, 5})]
    cl = make_partition_closure(alpha, blocks)

    fps = sorted([s for s in powerset(alpha) if cl(s) == s],
                 key=lambda s: (len(s), sorted(s)))

    # Assign levels by size
    levels = {}
    for s in fps:
        k = len(s)
        if k not in levels:
            levels[k] = []
        levels[k].append(s)

    # Assign positions
    pos = {}
    for level, sets in sorted(levels.items()):
        n = len(sets)
        for i, s in enumerate(sets):
            x = (i - (n - 1) / 2) * 2.0
            pos[s] = (x, level)

    # Hasse edges: s → t if s ⊂ t and no u with s ⊂ u ⊂ t
    edges = []
    for s in fps:
        for t in fps:
            if s < t:
                # Check no intermediate
                if not any(s < u < t for u in fps):
                    edges.append((s, t))

    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Draw edges
    for s, t in edges:
        x0, y0 = pos[s]
        x1, y1 = pos[t]
        ax.plot([x0, x1], [y0, y1], 'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    colors = {0: '#E74C3C', 2: '#3498DB', 4: '#2ECC71', 6: '#9B59B6'}
    for s in fps:
        x, y = pos[s]
        c = colors.get(len(s), '#95A5A6')
        label = set(s) if s else "∅"
        ax.plot(x, y, 'o', color=c, markersize=20, zorder=5)
        ax.text(x, y, str(label), ha='center', va='center',
                fontsize=7, fontweight='bold', zorder=6)

    ax.set_title("Hasse Diagram of Fixed Points\n(Partition Closure on {0,1,2,3,4,5})",
                 fontsize=14, fontweight='bold')
    ax.set_ylabel("Set size", fontsize=12)
    ax.set_xticks([])
    ax.set_yticks(sorted(levels.keys()))

    # Legend
    patches = [
        mpatches.Patch(color='#E74C3C', label='∅ (bottom)'),
        mpatches.Patch(color='#3498DB', label='Atoms (size 2)'),
        mpatches.Patch(color='#2ECC71', label='Unions of 2 atoms'),
        mpatches.Patch(color='#9B59B6', label='{0,...,5} (top)'),
    ]
    ax.legend(handles=patches, loc='upper left', fontsize=9)

    plt.tight_layout()
    plt.savefig('fig_hasse_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved fig_hasse_diagram.png")


# ===========================================================================
#  Figure 2: Stone Isomorphism Visualization
# ===========================================================================

def figure_stone_isomorphism():
    """Visualize the bijection between fixed points and P(atoms)."""
    alpha = frozenset(range(6))
    blocks = [frozenset({0, 1}), frozenset({2, 3}), frozenset({4, 5})]
    cl = make_partition_closure(alpha, blocks)

    fps = sorted([s for s in powerset(alpha) if cl(s) == s],
                 key=lambda s: (len(s), sorted(s)))
    atoms = blocks

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Fixed points
    ax1.set_title("Fixed Points of O", fontsize=13, fontweight='bold')
    y_positions = list(range(len(fps)))
    for i, s in enumerate(fps):
        label = set(s) if s else "∅"
        color = '#3498DB' if s else '#E74C3C'
        if s == alpha:
            color = '#9B59B6'
        ax1.barh(i, 1, color=color, alpha=0.7, edgecolor='white')
        ax1.text(0.5, i, str(label), ha='center', va='center',
                fontsize=9, fontweight='bold')
    ax1.set_yticks([])
    ax1.set_xticks([])
    ax1.set_xlim(-0.1, 1.1)

    # Right: P(atoms)
    atom_names = ['A', 'B', 'C']
    subsets_of_atoms = []
    for r in range(len(atom_names) + 1):
        for c in combinations(range(len(atom_names)), r):
            subsets_of_atoms.append(frozenset(c))

    ax2.set_title("P({A, B, C})  =  Powerset of Atoms", fontsize=13, fontweight='bold')
    for i, t in enumerate(subsets_of_atoms):
        label = "{" + ", ".join(atom_names[j] for j in sorted(t)) + "}" if t else "∅"
        color = '#2ECC71'
        ax2.barh(i, 1, color=color, alpha=0.7, edgecolor='white')
        ax2.text(0.5, i, label, ha='center', va='center',
                fontsize=9, fontweight='bold')
    ax2.set_yticks([])
    ax2.set_xticks([])
    ax2.set_xlim(-0.1, 1.1)

    # Draw arrows between corresponding elements
    for i, s in enumerate(fps):
        support = frozenset(j for j, a in enumerate(atoms) if a <= s)
        j = subsets_of_atoms.index(support)
        con = mpatches.FancyArrowPatch(
            (1.05, i), (-0.05, j),
            arrowstyle='->', mutation_scale=15,
            connectionstyle='arc3,rad=0.1',
            color='#E67E22', linewidth=1.5,
            transform=fig.transFigure,
            clip_on=False
        )
        # Use annotation instead for cross-axes arrows
        ax1.annotate('', xy=(1.15, i), xytext=(1.0, i),
                    arrowprops=dict(arrowstyle='->', color='#E67E22', lw=1.5))

    fig.suptitle("Stone Isomorphism: Fixed Points ≅ P(Atoms)",
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig_stone_isomorphism.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved fig_stone_isomorphism.png")


# ===========================================================================
#  Figure 3: Partition / Equivalence Classes
# ===========================================================================

def figure_partition():
    """Visualize how the closure operator partitions the ground set into atoms."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    configs = [
        ("Finest (identity)", [frozenset({i}) for i in range(6)]),
        ("3 blocks", [frozenset({0, 1}), frozenset({2, 3}), frozenset({4, 5})]),
        ("Coarsest (trivial)", [frozenset(range(6))]),
    ]

    colors_pool = ['#E74C3C', '#3498DB', '#2ECC71', '#F39C12', '#9B59B6', '#1ABC9C']

    for ax, (title, blocks) in zip(axes, configs):
        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.set_xlim(-0.5, 5.5)
        ax.set_ylim(-1, 1)
        ax.set_aspect('equal')

        for i, b in enumerate(blocks):
            color = colors_pool[i % len(colors_pool)]
            elems = sorted(b)
            # Draw a rounded rectangle around the block
            x_min = min(elems) - 0.3
            x_max = max(elems) + 0.3
            rect = mpatches.FancyBboxPatch(
                (x_min, -0.4), x_max - x_min, 0.8,
                boxstyle=mpatches.BoxStyle.Round(pad=0.15),
                facecolor=color, alpha=0.3, edgecolor=color, linewidth=2
            )
            ax.add_patch(rect)

            for e in elems:
                ax.plot(e, 0, 'o', color=color, markersize=18, zorder=5)
                ax.text(e, 0, str(e), ha='center', va='center',
                       fontsize=10, fontweight='bold', zorder=6)

        n_fp = 2 ** len(blocks)
        ax.text(2.5, -0.8, f"|FP| = 2^{len(blocks)} = {n_fp}",
               ha='center', fontsize=11, style='italic')
        ax.set_xticks([])
        ax.set_yticks([])
        for spine in ax.spines.values():
            spine.set_visible(False)

    fig.suptitle("Partitions Define Atoms → Fixed Points ≅ Powerset",
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_partition_atoms.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved fig_partition_atoms.png")


# ===========================================================================
#  Figure 4: Compression Ratio
# ===========================================================================

def figure_compression():
    """Show how atom-based compression scales with ground set size."""
    sizes = list(range(4, 21))
    # For k atoms out of n elements, compression = k/n
    # We'll show various partition structures

    fig, ax = plt.subplots(figsize=(10, 6))

    # Fixed number of atoms
    for k in [2, 3, 4, 5]:
        ratios = [k / n for n in sizes]
        ax.plot(sizes, ratios, 'o-', label=f'{k} atoms', linewidth=2, markersize=6)

    ax.set_xlabel('Ground set size |α|', fontsize=12)
    ax.set_ylabel('Compression ratio (bits per state)', fontsize=12)
    ax.set_title('Proof-State Compression via Atom Decomposition',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.1)

    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax.text(max(sizes) + 0.5, 1.0, 'No compression', fontsize=9, color='gray')

    plt.tight_layout()
    plt.savefig('fig_compression_ratio.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved fig_compression_ratio.png")


# ===========================================================================
#  Generate base64 versions for JSON embedding
# ===========================================================================

def fig_to_base64(fig_func) -> str:
    """Run a figure function and return base64-encoded PNG."""
    buf = BytesIO()
    fig_func_inner = fig_func.__name__

    # Re-run but save to buffer
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    # Capture the figure
    fig_func()

    # Read the last saved file
    fname = {
        'figure_hasse_diagram': 'fig_hasse_diagram.png',
        'figure_stone_isomorphism': 'fig_stone_isomorphism.png',
        'figure_partition': 'fig_partition_atoms.png',
        'figure_compression': 'fig_compression_ratio.png',
    }.get(fig_func_inner)

    if fname:
        with open(fname, 'rb') as f:
            data = f.read()
        return "data:image/png;base64," + base64.b64encode(data).decode()
    return ""


if __name__ == "__main__":
    print("Generating visualizations...")
    figure_hasse_diagram()
    figure_stone_isomorphism()
    figure_partition()
    figure_compression()
    print("Done! All figures saved as PNG files.")
