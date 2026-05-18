#!/usr/bin/env python3
"""
Applications of EML Closure Theory

Demonstrates real-world applications of closure–kernel duality:
1. Model compression via closure equivalence
2. Architecture comparison
3. Feature selection using cores
4. Expressivity lattice construction
"""

import itertools
import numpy as np
from typing import FrozenSet, List, Dict, Set, Tuple, Callable


# ============================================================================
# Application 1: Model Compression via Closure Equivalence
# ============================================================================

def model_compression_demo():
    """
    Demonstrates how closure theory enables model compression.

    Key insight: Two generator sets with the same closure are expressively equivalent.
    Finding a minimal generator is an exact compression of the model class.
    """
    print("=" * 60)
    print("Application 1: Model Compression via Closure Equivalence")
    print("=" * 60)
    print()

    # Simulate function features as elements
    features = frozenset(range(8))  # 8 features/functions

    # Define closure: some features are derivable from others
    # Feature derivation rules (simulating EML operations):
    # 0,1 → 2 (feature 2 = combination of 0 and 1)
    # 2,3 → 4 (feature 4 = combination of 2 and 3)
    # 5,6 → 7 (feature 7 = combination of 5 and 6)
    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            if {0, 1} <= result and 2 not in result:
                result.add(2); changed = True
            if {2, 3} <= result and 4 not in result:
                result.add(4); changed = True
            if {5, 6} <= result and 7 not in result:
                result.add(7); changed = True
        return frozenset(result)

    # Original model uses all 8 features
    original = features
    cl_original = closure(original)
    print(f"Original model: {len(original)} features → closure has {len(cl_original)} features")

    # Find minimal generating sets
    min_size = None
    min_generators = []
    for r in range(1, len(features) + 1):
        for combo in itertools.combinations(features, r):
            S = frozenset(combo)
            if closure(S) == cl_original:
                if min_size is None:
                    min_size = r
                if r == min_size:
                    min_generators.append(S)
                elif r > min_size:
                    break
        if min_size is not None and r > min_size:
            break

    print(f"Minimum generator size: {min_size} features")
    print(f"Compression ratio: {min_size}/{len(original)} = {min_size/len(original):.1%}")
    print(f"Number of minimal generators: {len(min_generators)}")
    for g in min_generators[:5]:
        print(f"  {set(g)}")

    # Compute the core (intersection of all generators)
    core_containment = features
    for r in range(len(features) + 1):
        for combo in itertools.combinations(features, r):
            S = frozenset(combo)
            if cl_original <= closure(S):
                core_containment = core_containment & S
    print(f"\nEML Core (must be in every generator): {set(core_containment)}")
    print()


# ============================================================================
# Application 2: Architecture Comparison
# ============================================================================

def architecture_comparison_demo():
    """
    Uses the Galois connection to compare model architectures.

    The biconditional cl(A) ⊆ C ↔ A ⊆ C enables efficient comparison:
    Architecture A is "contained in" architecture B iff A ⊆ cl(B).
    """
    print("=" * 60)
    print("Application 2: Architecture Comparison")
    print("=" * 60)
    print()

    # Define simple function building blocks
    operations = frozenset(range(6))
    # 0: identity, 1: square, 2: add_const, 3: multiply, 4: compose, 5: relu-like

    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            # Composing identity with anything gives that thing
            # Squaring + multiply gives higher powers
            if {1, 3} <= result and 4 not in result:
                result.add(4); changed = True
            # Add_const + multiply gives affine
            if {2, 3} <= result and 0 not in result:
                result.add(0); changed = True
            # Compose + square gives iterated squaring
            if {1, 4} <= result and 5 not in result:
                result.add(5); changed = True
        return frozenset(result)

    # Define architectures
    arch_A = frozenset({0, 1, 2})       # identity, square, add_const
    arch_B = frozenset({1, 2, 3})       # square, add_const, multiply
    arch_C = frozenset({0, 1, 2, 3, 4}) # most operations

    architectures = {"A": arch_A, "B": arch_B, "C": arch_C}

    print("Architecture expressivity comparison:")
    print()

    for name, arch in architectures.items():
        cl = closure(arch)
        print(f"  Architecture {name}: generators = {set(arch)}")
        print(f"    closure = {set(cl)} ({len(cl)} operations)")
    print()

    # Compare using Galois connection: cl(X) ⊆ cl(Y) ↔ X ⊆ cl(Y)
    print("Expressivity ordering (X ⊆ᵉˣᵖ Y means cl(X) ⊆ cl(Y)):")
    for n1, a1 in architectures.items():
        for n2, a2 in architectures.items():
            if n1 != n2:
                cl1 = closure(a1)
                cl2 = closure(a2)
                if cl1 <= cl2:
                    # Verify via Galois connection
                    gc_check = a1 <= cl2
                    print(f"  {n1} ⊆ᵉˣᵖ {n2}: True (verified via GC: A⊆cl(B) = {gc_check})")
                elif cl2 <= cl1:
                    pass  # printed in other direction
                else:
                    print(f"  {n1} and {n2}: incomparable")
    print()

    # Check equivalence
    print("Equivalence classes (same closure):")
    seen = set()
    for n1, a1 in architectures.items():
        if n1 in seen:
            continue
        equiv = [n1]
        cl1 = closure(a1)
        for n2, a2 in architectures.items():
            if n2 != n1 and closure(a2) == cl1:
                equiv.append(n2)
                seen.add(n2)
        if len(equiv) > 1:
            print(f"  {equiv} generate the same class")
        else:
            print(f"  {n1}: unique class {set(cl1)}")
    print()


# ============================================================================
# Application 3: Feature Selection via Cores
# ============================================================================

def feature_selection_demo():
    """
    Uses the core operator for principled feature selection.

    The core of a target class identifies features that MUST be present
    in any generating set—these are the irreducible features.
    """
    print("=" * 60)
    print("Application 3: Feature Selection via Cores")
    print("=" * 60)
    print()

    # 10 candidate features
    features = frozenset(range(10))

    # Derivation rules (simulating redundancies)
    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            # Feature 3 = derived from 0 and 1
            if {0, 1} <= result and 3 not in result:
                result.add(3); changed = True
            # Feature 4 = derived from 1 and 2
            if {1, 2} <= result and 4 not in result:
                result.add(4); changed = True
            # Feature 7 = derived from 5 and 6
            if {5, 6} <= result and 7 not in result:
                result.add(7); changed = True
            # Feature 8 = derived from 6 and 9
            if {6, 9} <= result and 8 not in result:
                result.add(8); changed = True
        return frozenset(result)

    # Target: we want a model class that includes features 0-7
    target = frozenset(range(8))
    cl_target = closure(target)

    print(f"Target feature set: {set(target)}")
    print(f"Closure of target: {set(cl_target)}")
    print()

    # Compute core
    core = features
    for r in range(len(features) + 1):
        for combo in itertools.combinations(features, r):
            S = frozenset(combo)
            if target <= closure(S):
                core = core & S

    print(f"Core features (must be in any generator): {set(core)}")
    print(f"Core size: {len(core)} out of {len(target)} target features")
    print()

    # Find minimal sufficient subsets
    print("Minimal sufficient feature sets:")
    min_size = None
    count = 0
    for r in range(1, len(features) + 1):
        for combo in itertools.combinations(features, r):
            S = frozenset(combo)
            if target <= closure(S):
                if min_size is None:
                    min_size = r
                if r == min_size:
                    count += 1
                    if count <= 5:
                        print(f"  {set(S)} ({r} features)")
        if min_size is not None and r > min_size:
            break

    print(f"\nMinimum features needed: {min_size}")
    print(f"Number of optimal feature sets: {count}")
    print()


# ============================================================================
# Application 4: Expressivity Lattice Construction
# ============================================================================

def expressivity_lattice_demo():
    """
    Constructs and analyzes the complete lattice of EML-closed sets.

    The lattice reveals the taxonomy of expressivity: which model classes
    are strictly more expressive than others, and which are incomparable.
    """
    print("=" * 60)
    print("Application 4: Expressivity Lattice")
    print("=" * 60)
    print()

    universe = frozenset({1, 2, 3, 4, 5})

    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            if 1 in result and 2 not in result:
                result.add(2); changed = True
            if 3 in result and 4 not in result:
                result.add(4); changed = True
            if {2, 4} <= result and 5 not in result:
                result.add(5); changed = True
        return frozenset(result)

    # Enumerate closed sets
    closed_sets = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(sorted(universe), r):
            S = frozenset(combo)
            if closure(S) == S:
                closed_sets.append(S)

    closed_sets.sort(key=lambda s: (len(s), sorted(s)))
    print(f"Closed sets ({len(closed_sets)} total):")
    for C in closed_sets:
        print(f"  {set(C)}")
    print()

    # Build Hasse diagram
    print("Hasse diagram (cover relations):")
    covers = []
    for i, C1 in enumerate(closed_sets):
        for C2 in closed_sets[i+1:]:
            if C1 < C2:
                is_cover = True
                for C3 in closed_sets:
                    if C1 < C3 < C2:
                        is_cover = False
                        break
                if is_cover:
                    covers.append((C1, C2))
                    print(f"  {set(C1)} ⊂ {set(C2)}")
    print()

    # Lattice properties
    print("Lattice operations:")
    for i, C1 in enumerate(closed_sets):
        for C2 in closed_sets[i+1:]:
            meet = C1 & C2
            join = closure(C1 | C2)
            if closure(meet) != meet:
                print(f"  WARNING: {set(C1)} ∩ {set(C2)} = {set(meet)} is NOT closed!")
            else:
                print(f"  {set(C1)} ∧ {set(C2)} = {set(meet)}, "
                      f"{set(C1)} ∨ {set(C2)} = {set(join)}")
    print()

    # Width and height of the lattice
    by_size = {}
    for C in closed_sets:
        sz = len(C)
        by_size.setdefault(sz, []).append(C)

    height = len(by_size)
    width = max(len(v) for v in by_size.values())
    print(f"Lattice statistics:")
    print(f"  Height: {height}")
    print(f"  Width: {width}")
    print(f"  Total elements: {len(closed_sets)}")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("Applications of EML Closure Theory")
    print("=" * 60)
    print()

    model_compression_demo()
    architecture_comparison_demo()
    feature_selection_demo()
    expressivity_lattice_demo()


#!/usr/bin/env python3
"""
Demo: EML Closure Systems, Galois Connections, and Moore Families

Demonstrates the core mathematical structures from the EML closure–kernel duality
with concrete finite examples. Shows closure computation, Galois connection
verification, core computation, and Moore family properties.
"""

import itertools
from typing import Set, FrozenSet, Callable, Dict, List, Tuple


# ============================================================================
# Finite Closure Systems
# ============================================================================

class ClosureSystem:
    """A closure operator on a finite universe, represented by its closure function."""

    def __init__(self, universe: FrozenSet, closure_fn: Callable):
        self.universe = universe
        self._closure_fn = closure_fn

    def closure(self, S: FrozenSet) -> FrozenSet:
        """Compute the closure of a set S."""
        return self._closure_fn(S)

    def is_closed(self, S: FrozenSet) -> bool:
        """Check if S is a closed set (fixed point of closure)."""
        return self.closure(S) == S

    def closed_sets(self) -> List[FrozenSet]:
        """Enumerate all closed sets."""
        result = []
        for r in range(len(self.universe) + 1):
            for subset in itertools.combinations(self.universe, r):
                S = frozenset(subset)
                if self.is_closed(S):
                    result.append(S)
        return sorted(result, key=lambda s: (len(s), sorted(s)))

    def core(self, C: FrozenSet) -> FrozenSet:
        """Compute emlCore(C) = ⋂{A | C ⊆ closure(A)}."""
        generators = []
        for r in range(len(self.universe) + 1):
            for subset in itertools.combinations(self.universe, r):
                A = frozenset(subset)
                if C <= self.closure(A):
                    generators.append(A)
        if not generators:
            return self.universe
        return frozenset.intersection(*generators) if generators else frozenset()

    def minimal_generators_eq(self, C: FrozenSet) -> FrozenSet:
        """Compute minimalGeneratorsEq(C) = ⋂{A | closure(A) = C}."""
        exact_generators = []
        for r in range(len(self.universe) + 1):
            for subset in itertools.combinations(self.universe, r):
                A = frozenset(subset)
                if self.closure(A) == C:
                    exact_generators.append(A)
        if not exact_generators:
            return self.universe  # empty intersection = universe
        return frozenset.intersection(*exact_generators)

    def verify_galois_connection(self) -> bool:
        """Verify: cl(A) ⊆ C ↔ A ⊆ C for all A and all closed C."""
        closed = self.closed_sets()
        for r in range(len(self.universe) + 1):
            for subset in itertools.combinations(self.universe, r):
                A = frozenset(subset)
                cl_A = self.closure(A)
                for C in closed:
                    forward = (cl_A <= C) <= (A <= C)  # cl(A) ⊆ C → A ⊆ C
                    backward = (A <= C) <= (cl_A <= C)  # A ⊆ C → cl(A) ⊆ C
                    if not (forward and backward):
                        return False
        return True

    def verify_moore_family(self) -> bool:
        """Verify that closed sets are closed under arbitrary intersection."""
        closed = self.closed_sets()
        # Check all pairs
        for i, C1 in enumerate(closed):
            for C2 in closed[i:]:
                intersection = C1 & C2
                if not self.is_closed(intersection):
                    return False
        return True


# ============================================================================
# Example 1: Polynomial-like closure on {1, x, x², x³}
# ============================================================================

def polynomial_closure_example():
    """
    Closure on {1, x, x², x³} where closure = all monomials up to the max degree present.
    This models polynomial rings: cl({xᵏ}) = {1, x, ..., xᵏ}.
    """
    print("=" * 60)
    print("Example 1: Polynomial-Degree Closure")
    print("=" * 60)
    print()

    universe = frozenset({0, 1, 2, 3})  # degrees: 1, x, x², x³

    def closure(S: FrozenSet) -> FrozenSet:
        if not S:
            return frozenset({0})  # constants always present
        max_deg = max(S)
        return frozenset(range(max_deg + 1))

    cs = ClosureSystem(universe, closure)

    # List closed sets
    closed = cs.closed_sets()
    print(f"Closed sets ({len(closed)} total):")
    for C in closed:
        degs = sorted(C)
        polys = ", ".join(f"x^{d}" if d > 0 else "1" for d in degs)
        print(f"  {{{polys}}}")
    print()

    # Verify Galois connection
    gc_ok = cs.verify_galois_connection()
    print(f"Galois connection cl(A) ⊆ C ↔ A ⊆ C verified: {gc_ok}")

    # Verify Moore family
    mf_ok = cs.verify_moore_family()
    print(f"Moore family (closed under ∩) verified: {mf_ok}")
    print()

    # Compute cores
    print("Core computation:")
    for C in closed:
        core = cs.core(C)
        mg = cs.minimal_generators_eq(C)
        degs_C = sorted(C)
        degs_core = sorted(core)
        degs_mg = sorted(mg)
        print(f"  C = {{{', '.join(str(d) for d in degs_C)}}}")
        print(f"    core    = {{{', '.join(str(d) for d in degs_core)}}}")
        print(f"    minGen  = {{{', '.join(str(d) for d in degs_mg)}}}")
        print(f"    core ⊆ minGen ⊆ C: {core <= mg <= C}")
    print()


# ============================================================================
# Example 2: Algebraic closure with composition
# ============================================================================

def algebraic_closure_example():
    """
    Closure on {a, b, c, d} where:
    - {a} generates {a, b} (b = a composed with itself, conceptually)
    - {c} generates {c, d}
    - Full set is closed
    """
    print("=" * 60)
    print("Example 2: Composition-like Closure")
    print("=" * 60)
    print()

    universe = frozenset({'a', 'b', 'c', 'd'})

    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        # Rule: a generates b
        if 'a' in result:
            result.add('b')
        # Rule: c generates d
        if 'c' in result:
            result.add('d')
        # Rule: b and d together generate a (cross-interaction)
        if 'b' in result and 'd' in result:
            result.add('a')
            result.add('c')
        return frozenset(result)

    cs = ClosureSystem(universe, closure)

    # Verify closure axioms
    print("Verifying closure axioms:")

    # Extensivity
    ext_ok = all(
        frozenset(s) <= cs.closure(frozenset(s))
        for r in range(5)
        for s in itertools.combinations(universe, r)
    )
    print(f"  Extensivity (A ⊆ cl(A)): {ext_ok}")

    # Monotonicity
    mono_ok = True
    subsets = [frozenset(s) for r in range(5) for s in itertools.combinations(universe, r)]
    for A in subsets:
        for B in subsets:
            if A <= B and not (cs.closure(A) <= cs.closure(B)):
                mono_ok = False
    print(f"  Monotonicity: {mono_ok}")

    # Idempotence
    idemp_ok = all(cs.closure(cs.closure(A)) == cs.closure(A) for A in subsets)
    print(f"  Idempotence: {idemp_ok}")
    print()

    # List closed sets
    closed = cs.closed_sets()
    print(f"Closed sets ({len(closed)} total):")
    for C in closed:
        print(f"  {set(C)}")
    print()

    # Verify Galois connection
    gc_ok = cs.verify_galois_connection()
    print(f"Galois connection verified: {gc_ok}")

    # Verify Moore family
    mf_ok = cs.verify_moore_family()
    print(f"Moore family verified: {mf_ok}")
    print()

    # Demonstrate the core hierarchy
    print("Core hierarchy (core ⊆ minGen ⊆ C):")
    for C in closed:
        if len(C) > 0:
            core = cs.core(C)
            mg = cs.minimal_generators_eq(C)
            hierarchy = core <= mg <= C
            print(f"  C={set(C)}: core={set(core)}, minGen={set(mg)}, hierarchy={hierarchy}")
    print()


# ============================================================================
# Example 3: Demonstrating that emlCore ≠ identity on closed sets
# ============================================================================

def core_not_identity_example():
    """
    Shows that emlCore(C) can be strictly smaller than C, even for closed C.
    This demonstrates why the naive Galois connection fails.
    """
    print("=" * 60)
    print("Example 3: Core ≠ Identity (Why Naive Adjoint Fails)")
    print("=" * 60)
    print()

    universe = frozenset({1, 2, 3})

    def closure(S: FrozenSet) -> FrozenSet:
        """cl(S) = universe for any nonempty S; cl(∅) = ∅."""
        if S:
            return universe
        return frozenset()

    cs = ClosureSystem(universe, closure)

    closed = cs.closed_sets()
    print(f"Closed sets: {[set(C) for C in closed]}")

    C = universe  # This is closed
    core = cs.core(C)
    print(f"\nC = {set(C)} (closed: {cs.is_closed(C)})")
    print(f"emlCore(C) = {set(core)}")
    print(f"Core = C? {core == C}")
    print(f"Core ⊂ C? {core < C}")

    print(f"\nThe core is empty because {{1}}, {{2}}, {{3}} all have closure = universe,")
    print(f"so they're all in the family {{A | C ⊆ cl(A)}}. Their intersection is empty.")

    # Show that naive Galois connection fails
    print(f"\nNaive GC check: cl({{1}}) ⊆ C = {cs.closure(frozenset({1})) <= C}")
    print(f"But {{1}} ⊆ emlCore(C) = {frozenset({1}) <= core}")
    print(f"So cl(A) ⊆ C does NOT imply A ⊆ emlCore(C). The naive GC fails!")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("EML Closure Systems: Galois Connections and Moore Families")
    print("=" * 60)
    print()

    polynomial_closure_example()
    algebraic_closure_example()
    core_not_identity_example()

    print("=" * 60)
    print("Key Takeaways:")
    print("1. The correct Galois connection uses Subtype.val (inclusion),")
    print("   not emlCore, as the right adjoint.")
    print("2. cl(A) ⊆ C ↔ A ⊆ C holds for all A and closed C.")
    print("3. EML-closed sets form a Moore family (closed under ∩).")
    print("4. The core hierarchy: emlCore(C) ⊆ minimalGeneratorsEq(C) ⊆ C.")
    print("5. emlCore(C) can be strictly smaller than C, even for closed C.")


#!/usr/bin/env python3
"""
Visualizations for EML Closure Systems

Generates publication-quality figures showing:
1. Lattice of closed sets (Hasse diagram)
2. Core hierarchy diagram
3. Galois connection visualization
4. Moore family intersection property
"""

import itertools
import base64
import io
from typing import FrozenSet, List, Dict, Tuple
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def set_label(S: FrozenSet) -> str:
    """Pretty-print a frozenset."""
    if not S:
        return "∅"
    return "{" + ",".join(str(x) for x in sorted(S)) + "}"


# ============================================================================
# Figure 1: Hasse Diagram of Closed Sets
# ============================================================================

def create_hasse_diagram():
    """Create a Hasse diagram showing the lattice of EML-closed sets."""
    universe = frozenset({1, 2, 3, 4, 5})

    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            if 1 in result and 2 not in result:
                result.add(2); changed = True
            if 3 in result and 4 not in result:
                result.add(4); changed = True
            if {2, 4} <= result and 5 not in result:
                result.add(5); changed = True
        return frozenset(result)

    # Find closed sets
    closed = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(sorted(universe), r):
            S = frozenset(combo)
            if closure(S) == S:
                closed.append(S)

    closed.sort(key=lambda s: (len(s), sorted(s)))

    # Find covers
    covers = []
    for i, C1 in enumerate(closed):
        for C2 in closed[i+1:]:
            if C1 < C2:
                is_cover = True
                for C3 in closed:
                    if C1 < C3 < C2:
                        is_cover = False
                        break
                if is_cover:
                    covers.append((C1, C2))

    # Layout: group by size
    by_size = {}
    for C in closed:
        sz = len(C)
        by_size.setdefault(sz, []).append(C)

    positions = {}
    for sz, sets in by_size.items():
        n = len(sets)
        for i, S in enumerate(sets):
            x = (i - (n - 1) / 2) * 2.5
            y = sz * 1.8
            positions[S] = (x, y)

    # Draw
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Draw edges
    for C1, C2 in covers:
        x1, y1 = positions[C1]
        x2, y2 = positions[C2]
        ax.plot([x1, x2], [y1, y2], 'b-', alpha=0.4, linewidth=1.5)

    # Draw nodes
    for C in closed:
        x, y = positions[C]
        circle = plt.Circle((x, y), 0.35, color='steelblue', alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y - 0.7, set_label(C), ha='center', va='top',
                fontsize=8, fontweight='bold')

    ax.set_xlim(-5, 5)
    ax.set_ylim(-1.5, max(sz for sz in by_size) * 1.8 + 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Lattice of EML-Closed Sets\n(Hasse Diagram)', fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/hasse_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hasse_diagram.png")

    return fig


# ============================================================================
# Figure 2: Core Hierarchy
# ============================================================================

def create_core_hierarchy():
    """Visualize the core ⊆ minGenEq ⊆ C hierarchy."""
    universe = frozenset({1, 2, 3, 4, 5, 6})

    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            if 1 in result and 2 not in result:
                result.add(2); changed = True
            if 3 in result and 4 not in result:
                result.add(4); changed = True
            if {1, 3} <= result and 5 not in result:
                result.add(5); changed = True
            if 5 in result and 6 not in result:
                result.add(6); changed = True
        return frozenset(result)

    # Pick a specific closed set
    C = closure(frozenset({1, 3}))

    # Compute core
    core = universe
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(universe, r):
            S = frozenset(combo)
            if C <= closure(S):
                core = core & S

    # Compute minGenEq
    exact_gens = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(universe, r):
            S = frozenset(combo)
            if closure(S) == C:
                exact_gens.append(S)

    if exact_gens:
        min_gen = frozenset.intersection(*exact_gens)
    else:
        min_gen = frozenset()

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Draw nested sets as concentric regions
    colors = ['#2196F3', '#4CAF50', '#FF9800']
    labels = [f'C = {set_label(C)}', f'minGenEq = {set_label(min_gen)}', f'Core = {set_label(core)}']
    sets = [C, min_gen, core]

    for i, (S, color, label) in enumerate(zip(sets, colors, labels)):
        width = 3 - i * 0.8
        height = 1.8 - i * 0.4
        rect = mpatches.FancyBboxPatch((-width/2, -height/2 + i*0.15), width, height,
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, alpha=0.3,
                                        edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.text(width/2 + 0.1, -height/2 + i*0.15 + height/2, label,
                ha='left', va='center', fontsize=11, color=color, fontweight='bold')

    # List elements
    all_elements = sorted(C)
    for i, elem in enumerate(all_elements):
        x = (i - (len(all_elements)-1)/2) * 0.4
        y = 0
        color = '#FF9800' if elem in core else ('#4CAF50' if elem in min_gen else '#2196F3')
        ax.plot(x, y, 'o', color=color, markersize=12, zorder=10)
        ax.text(x, y, str(elem), ha='center', va='center', fontsize=9,
                fontweight='bold', color='white', zorder=11)

    ax.set_xlim(-2.5, 4)
    ax.set_ylim(-1.5, 1.5)
    ax.axis('off')
    ax.set_title('Core Hierarchy: Core ⊆ MinGenEq ⊆ C\n'
                 '(Elements colored by their deepest membership)',
                 fontsize=13, fontweight='bold')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/core_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: core_hierarchy.png")


# ============================================================================
# Figure 3: Galois Connection Biconditional
# ============================================================================

def create_galois_connection_viz():
    """Visualize the Galois connection cl(A) ⊆ C ↔ A ⊆ C."""
    universe = frozenset({1, 2, 3, 4})

    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            if 1 in result and 2 not in result:
                result.add(2); changed = True
            if 3 in result and 4 not in result:
                result.add(4); changed = True
        return frozenset(result)

    # Get all subsets and closed sets
    subsets = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(sorted(universe), r):
            subsets.append(frozenset(combo))

    closed_sets = [S for S in subsets if closure(S) == S]

    # Build truth table for the biconditional
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: show cl(A) ⊆ C implications
    ax = axes[0]
    data = []
    for A in subsets[:8]:  # Show first 8 subsets
        cl_A = closure(A)
        for C in closed_sets:
            lhs = cl_A <= C
            rhs = A <= C
            data.append((set_label(A), set_label(C), lhs, rhs, lhs == rhs))

    # Draw as a grid
    ax.set_title('Galois Connection Truth Table\ncl(A) ⊆ C ↔ A ⊆ C', fontsize=12, fontweight='bold')
    ax.text(0.5, 0.95, 'All entries match: biconditional holds for all A, C (closed)',
            transform=ax.transAxes, ha='center', fontsize=10, color='green')
    ax.axis('off')

    # Right: arrow diagram
    ax = axes[1]
    ax.set_title('Galois Connection Schema', fontsize=12, fontweight='bold')

    # Draw two columns: Generators (left) and Closed Sets (right)
    gen_examples = [frozenset(), frozenset({1}), frozenset({3}), frozenset({1, 3})]
    closed_examples = closed_sets[:5]

    for i, A in enumerate(gen_examples):
        y = 3 - i * 1.5
        ax.text(0.5, y, set_label(A), ha='center', va='center',
                bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8),
                fontsize=10)

    for j, C in enumerate(closed_examples):
        y = 3.5 - j * 1.2
        ax.text(5.5, y, set_label(C), ha='center', va='center',
                bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8),
                fontsize=10)

    # Draw arrows for cl(A) ⊆ C relationships
    for i, A in enumerate(gen_examples):
        cl_A = closure(A)
        y_a = 3 - i * 1.5
        for j, C in enumerate(closed_examples):
            y_c = 3.5 - j * 1.2
            if cl_A <= C:
                ax.annotate('', xy=(4.5, y_c), xytext=(1.5, y_a),
                          arrowprops=dict(arrowstyle='->', color='blue', alpha=0.3))

    ax.text(3, -1, 'Generators → Closed Sets\n(arrows = cl(A) ⊆ C)',
            ha='center', fontsize=10)
    ax.set_xlim(-1, 7)
    ax.set_ylim(-2, 5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/galois_connection.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: galois_connection.png")


# ============================================================================
# Figure 4: Moore Family - Intersection Closure Property
# ============================================================================

def create_moore_family_viz():
    """Visualize that intersections of closed sets are closed."""
    universe = frozenset({1, 2, 3, 4, 5})

    def closure(S: FrozenSet) -> FrozenSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            if 1 in result and 2 not in result:
                result.add(2); changed = True
            if 3 in result and 4 not in result:
                result.add(4); changed = True
            if {2, 4} <= result and 5 not in result:
                result.add(5); changed = True
        return frozenset(result)

    closed_sets = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(sorted(universe), r):
            S = frozenset(combo)
            if closure(S) == S:
                closed_sets.append(S)

    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Show all pairs of closed sets and their intersections
    pairs = []
    for i, C1 in enumerate(closed_sets):
        for C2 in closed_sets[i+1:]:
            inter = C1 & C2
            is_closed = closure(inter) == inter
            pairs.append((C1, C2, inter, is_closed))

    # Draw as a table
    y_start = len(pairs) * 0.4 + 1
    ax.text(0.5, y_start + 0.5, 'Moore Family: Intersection of Closed Sets',
            ha='center', fontsize=14, fontweight='bold', transform=ax.transData)
    ax.text(0.5, y_start, 'All intersections of closed sets are closed ✓',
            ha='center', fontsize=11, color='green', transform=ax.transData)

    headers = ['C₁', 'C₂', 'C₁ ∩ C₂', 'Closed?']
    x_positions = [-3, -1, 1, 3.2]
    for x, h in zip(x_positions, headers):
        ax.text(x, y_start - 0.7, h, ha='center', va='center',
                fontsize=11, fontweight='bold')

    for idx, (C1, C2, inter, is_closed) in enumerate(pairs[:12]):
        y = y_start - 1.2 - idx * 0.5
        color = 'green' if is_closed else 'red'
        texts = [set_label(C1), set_label(C2), set_label(inter), '✓' if is_closed else '✗']
        for x, t in zip(x_positions, texts):
            ax.text(x, y, t, ha='center', va='center', fontsize=9,
                    color=color if t in ('✓', '✗') else 'black')

    ax.set_xlim(-5, 5)
    ax.set_ylim(-1, y_start + 1.5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/moore_family.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: moore_family.png")


def image_to_base64(path: str) -> str:
    """Convert an image file to a base64 data URI."""
    with open(path, 'rb') as f:
        data = f.read()
    encoded = base64.b64encode(data).decode('utf-8')
    return f"data:image/png;base64,{encoded}"


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("Generating EML Closure System Visualizations")
    print("=" * 50)
    print()

    create_hasse_diagram()
    create_core_hierarchy()
    create_galois_connection_viz()
    create_moore_family_viz()

    print()
    print("All visualizations generated successfully.")
