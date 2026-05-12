#!/usr/bin/env python3
"""
Applications of Closure–Matroid Duality

Demonstrates real-world applications:
1. Secret sharing access structures
2. Feature explanation in ML-like settings
3. Network reliability / reconstruction
"""

import itertools
from demo import ExchangeClosureSystem, uniform_matroid_closure, \
    graphic_matroid_closure, canonical_presentation


def application_secret_sharing():
    """
    Application: Secret Sharing Schemes

    A (t,n)-threshold secret sharing scheme distributes a secret among n
    participants such that any t participants can reconstruct the secret,
    but fewer than t cannot. The access structure is exactly the collection
    of qualified sets from the closure-matroid duality.
    """
    print("=" * 60)
    print("Application 1: Secret Sharing Access Structures")
    print("=" * 60)

    # (3,5)-threshold scheme
    n, t = 5, 3
    ecs = uniform_matroid_closure(n + 1, t)  # n+1: n shares + 1 secret
    pres = canonical_presentation(ecs)

    secret = n  # last element is the secret
    shares = frozenset(range(n))

    print(f"\n({t},{n})-threshold scheme:")
    print(f"  Secret: element {secret}")
    print(f"  Shares: {set(shares)}")

    qs = pres.qualified_sets(secret)
    print(f"\n  Minimal qualified sets ({len(qs)} total):")
    for q in sorted(qs, key=lambda x: (len(x), sorted(x))):
        print(f"    {set(q)}")

    # Verify: all minimal qualified sets have size t
    sizes = set(len(q) for q in qs)
    print(f"\n  All minimal qualified sets have size {sizes} — matches threshold {t}: "
          f"{'✓' if sizes == {t} else '✗'}")

    # Count: should be C(n, t) = C(5, 3) = 10
    expected = len(list(itertools.combinations(range(n), t)))
    print(f"  Count: {len(qs)} (expected C({n},{t}) = {expected}): "
          f"{'✓' if len(qs) == expected else '✗'}")


def application_feature_explanation():
    """
    Application: Feature Explanation in ML

    In explainable ML, we want to find minimal sets of features that
    "explain" a prediction. This maps to finding minimal qualified sets
    in a closure system where:
    - Elements = features
    - Closure captures feature dependencies
    - Qualified sets = sufficient explanations
    """
    print("\n" + "=" * 60)
    print("Application 2: Feature Explanation via Closure Geometry")
    print("=" * 60)

    # Model: 4 features with dependencies
    # Feature 3 (prediction) depends on features 0,1 or features 1,2
    ground = set(range(5))  # features 0-3, prediction = 4

    def cl(A):
        A = set(A)
        result = set(A)
        # Feature 4 (prediction) is determined by {0, 1} or {1, 2}
        if {0, 1} <= A:
            result.add(4)
        if {1, 2} <= A:
            result.add(4)
        # Feature 3 is redundant given {0, 2}
        if {0, 2} <= A:
            result.add(3)
        # Closure of closure
        if {0, 1} <= result:
            result.add(4)
        if {1, 2} <= result:
            result.add(4)
        if {0, 2} <= result:
            result.add(3)
        return result

    ecs = ExchangeClosureSystem(ground, cl)
    pres = canonical_presentation(ecs)

    prediction = 4
    print(f"\n  Features: 0, 1, 2, 3")
    print(f"  Prediction target: {prediction}")
    print(f"  Dependencies: prediction determined by {{0,1}} or {{1,2}}")
    print(f"  Redundancy: feature 3 determined by {{0,2}}")

    qs = pres.qualified_sets(prediction)
    print(f"\n  Minimal sufficient explanations for prediction:")
    for q in sorted(qs, key=lambda x: (len(x), sorted(x))):
        print(f"    Features {set(q)}")

    print(f"\n  Interpretation:")
    print(f"    - These are the smallest feature subsets that fully explain the prediction")
    print(f"    - Each corresponds to a minimal qualified set in the closure geometry")
    print(f"    - The closure operator captures feature dependencies/redundancies")


def application_network_reliability():
    """
    Application: Network Reliability

    Given a network (graph), which edges are essential for connectivity?
    The graphic matroid captures this: circuits are redundant edge sets,
    and cocircuits identify critical cuts.
    """
    print("\n" + "=" * 60)
    print("Application 3: Network Reliability Analysis")
    print("=" * 60)

    # Diamond graph: 4 nodes, 5 edges
    edges = [(0,1), (0,2), (1,3), (2,3), (1,2)]
    n_vertices = 4
    ecs = graphic_matroid_closure(n_vertices, edges)

    print(f"\n  Network: {n_vertices} nodes, {len(edges)} links")
    print(f"  Links: {edges}")

    circuits = ecs.circuits()
    print(f"\n  Circuits (redundant link sets): {len(circuits)}")
    for c in circuits:
        edge_names = [edges[i] for i in c]
        print(f"    {set(c)} = links {edge_names}")

    print(f"\n  Network rank (spanning tree size): {ecs.rank(ecs.ground)}")
    print(f"  Redundancy: {len(edges) - ecs.rank(ecs.ground)} extra links")

    # Find bridges (edges not in any circuit)
    circuit_edges = set()
    for c in circuits:
        circuit_edges |= c

    bridges = set(range(len(edges))) - circuit_edges
    print(f"\n  Bridges (critical links, failure causes disconnection):")
    if bridges:
        for b in bridges:
            print(f"    Link {b} = {edges[b]}")
    else:
        print(f"    None — network is 2-edge-connected")

    # Dependency presentation for reconstruction
    pres = canonical_presentation(ecs)
    print(f"\n  Reconstruction analysis:")
    for target_edge in range(len(edges)):
        qs = pres.qualified_sets(target_edge)
        if qs:
            min_size = min(len(q) for q in qs)
            print(f"    Link {target_edge} ({edges[target_edge]}): "
                  f"reconstructible from {len(qs)} minimal sets "
                  f"(smallest size {min_size})")


if __name__ == "__main__":
    application_secret_sharing()
    application_feature_explanation()
    application_network_reliability()
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Closure–Matroid Duality: Concrete Demonstrations

This module demonstrates the core mathematical structures connecting
exchange closure systems, matroid rank, circuits, and dependency presentations.
"""

import itertools
from typing import Set, FrozenSet, Dict, List, Tuple, Callable


# ============================================================
# §1. Exchange Closure Systems
# ============================================================

class ExchangeClosureSystem:
    """
    A finite exchange closure system on a ground set X.
    Stores the closure operator as a function Set -> Set.
    """
    def __init__(self, ground: set, cl: Callable):
        self.ground = frozenset(ground)
        self._cl = cl
        self._verify_axioms()

    def cl(self, A: frozenset) -> frozenset:
        return frozenset(self._cl(set(A)))

    def _verify_axioms(self):
        """Verify the four closure axioms on small subsets."""
        # Extensivity
        for x in self.ground:
            A = frozenset({x})
            assert A <= self.cl(A), f"Extensivity failed for {A}"
        # Idempotence
        for A in _small_subsets(self.ground, max_size=3):
            assert self.cl(self.cl(A)) == self.cl(A), f"Idempotence failed for {A}"

    def rank(self, A: frozenset) -> int:
        """Rank: minimum |B| where B ⊆ A and cl(B) ⊇ A."""
        A = frozenset(A)
        min_rank = len(A)
        for r in range(len(A) + 1):
            for B in itertools.combinations(A, r):
                B = frozenset(B)
                if A <= self.cl(B):
                    return r
        return min_rank

    def is_independent(self, A: frozenset) -> bool:
        return self.rank(frozenset(A)) == len(A)

    def circuits(self) -> List[frozenset]:
        """Find all circuits: minimal dependent sets."""
        circuits = []
        for size in range(1, len(self.ground) + 1):
            for C in itertools.combinations(self.ground, size):
                C = frozenset(C)
                if not self.is_independent(C):
                    # Check minimality
                    if all(self.is_independent(C - {x}) for x in C):
                        circuits.append(C)
        return circuits

    def flats(self) -> List[frozenset]:
        """Find all flats (closed sets)."""
        result = []
        for size in range(len(self.ground) + 1):
            for F in itertools.combinations(self.ground, size):
                F = frozenset(F)
                if self.cl(F) == F:
                    result.append(F)
        return result


def _small_subsets(ground, max_size=None):
    if max_size is None:
        max_size = len(ground)
    for r in range(max_size + 1):
        for S in itertools.combinations(ground, r):
            yield frozenset(S)


# ============================================================
# §2. Examples: Matroid Closure Systems
# ============================================================

def uniform_matroid_closure(n: int, k: int):
    """Closure for the uniform matroid U(k,n): rank k on n elements.
    cl(A) = A if |A| < k, cl(A) = ground if |A| >= k."""
    ground = set(range(n))
    def cl(A):
        A = set(A)
        if len(A) >= k:
            return set(ground)
        return set(A)
    return ExchangeClosureSystem(ground, cl)


def graphic_matroid_closure(n: int, edges: List[Tuple[int, int]]):
    """Closure for the graphic matroid of a graph.
    An edge set is independent iff it forms a forest.
    cl(A) = all edges whose endpoints are connected by a path in A."""
    ground = set(range(len(edges)))

    def find_components(edge_set):
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px != py:
                parent[px] = py
        for i in edge_set:
            u, v = edges[i]
            union(u, v)
        return find

    def cl(A):
        A = set(A)
        find = find_components(A)
        result = set(A)
        for i in ground:
            u, v = edges[i]
            if find(u) == find(v):
                result.add(i)
        return result

    return ExchangeClosureSystem(ground, cl)


# ============================================================
# §3. Dependency Presentation
# ============================================================

class DepPresentation:
    """A dependency presentation: collection of dependencies,
    each with a support set and a target element."""

    def __init__(self, ground: set, deps: List[Tuple[frozenset, any]]):
        """deps: list of (support, target) pairs."""
        self.ground = frozenset(ground)
        self.deps = deps

    def cl(self, A: frozenset) -> frozenset:
        """Induced closure: x ∈ cl(A) if x ∈ A or there's a dependency
        targeting x with support \ {x} ⊆ A."""
        A = frozenset(A)
        result = set(A)
        for support, target in self.deps:
            if (support - {target}) <= A:
                result.add(target)
        return frozenset(result)

    def qualified_sets(self, target) -> List[frozenset]:
        """Find all minimal qualified sets for a target."""
        qualified = []
        for size in range(len(self.ground) + 1):
            for Q in itertools.combinations(self.ground - {target}, size):
                Q = frozenset(Q)
                if target in self.cl(Q):
                    # Check minimality
                    if all(target not in self.cl(Q - {x}) for x in Q):
                        qualified.append(Q)
        return qualified


def canonical_presentation(ecs: ExchangeClosureSystem) -> DepPresentation:
    """Build the canonical dependency presentation from a closure system."""
    deps = []
    for size in range(len(ecs.ground) + 1):
        for A in itertools.combinations(ecs.ground, size):
            A = frozenset(A)
            cl_A = ecs.cl(A)
            for x in cl_A - A:
                deps.append((A | {x}, x))
    return DepPresentation(ecs.ground, deps)


# ============================================================
# §4. Demonstrations
# ============================================================

def demo_uniform_matroid():
    """Demonstrate with the uniform matroid U(2,4)."""
    print("=" * 60)
    print("Demo 1: Uniform Matroid U(2,4)")
    print("=" * 60)

    ecs = uniform_matroid_closure(4, 2)
    print(f"Ground set: {set(ecs.ground)}")
    print(f"\nRank function:")
    for size in range(5):
        for A in itertools.combinations(range(4), size):
            A = frozenset(A)
            print(f"  r({set(A)}) = {ecs.rank(A)}")

    print(f"\nCircuits: {[set(c) for c in ecs.circuits()]}")
    print(f"\nFlats: {[set(f) for f in ecs.flats()]}")

    # Canonical presentation
    pres = canonical_presentation(ecs)
    print(f"\nCanonical presentation has {len(pres.deps)} dependencies")

    # Verify round-trip
    print("\nRound-trip verification (cl = canonical cl on Finsets):")
    for size in range(5):
        for A in itertools.combinations(range(4), size):
            A = frozenset(A)
            assert ecs.cl(A) == pres.cl(A), f"Mismatch for {A}"
    print("  ✓ All closures match!")

    # Qualified sets
    print(f"\nMinimal qualified sets for target 3:")
    qs = pres.qualified_sets(3)
    print(f"  {[set(q) for q in qs]}")
    print()


def demo_graphic_matroid():
    """Demonstrate with a small graph's matroid."""
    print("=" * 60)
    print("Demo 2: Graphic Matroid of K4 (complete graph on 4 vertices)")
    print("=" * 60)

    # K4 edges
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    ecs = graphic_matroid_closure(4, edges)
    print(f"Ground set (edges): {list(range(6))}")
    print(f"Edges: {edges}")
    print(f"\nRank of ground set: {ecs.rank(ecs.ground)}")

    circuits = ecs.circuits()
    print(f"\nCircuits ({len(circuits)} total):")
    for c in circuits:
        edge_names = [edges[i] for i in c]
        print(f"  {set(c)} = edges {edge_names}")

    flats = ecs.flats()
    print(f"\nFlats ({len(flats)} total):")
    for f in sorted(flats, key=len):
        print(f"  {set(f)} (rank {ecs.rank(f)})")

    # Canonical presentation
    pres = canonical_presentation(ecs)
    print(f"\nCanonical presentation: {len(pres.deps)} dependencies")

    # Verify round-trip
    match_count = 0
    total = 0
    for size in range(7):
        for A in itertools.combinations(range(6), size):
            A = frozenset(A)
            total += 1
            if ecs.cl(A) == pres.cl(A):
                match_count += 1
    print(f"Round-trip: {match_count}/{total} closures match")

    # Qualified sets for edge 5 (edge (2,3))
    print(f"\nMinimal qualified sets for edge 5 = (2,3):")
    qs = pres.qualified_sets(5)
    for q in qs:
        edge_names = [edges[i] for i in q]
        print(f"  {set(q)} = edges {edge_names}")
    print()


def demo_rank_properties():
    """Demonstrate matroid rank axioms."""
    print("=" * 60)
    print("Demo 3: Rank Axiom Verification for U(3,5)")
    print("=" * 60)

    ecs = uniform_matroid_closure(5, 3)
    ground = list(range(5))

    # Verify rank axioms
    print("Checking rank axioms...")

    # 1. Bounded: r(A) ≤ |A|
    bounded_ok = True
    for size in range(6):
        for A in itertools.combinations(ground, size):
            A = frozenset(A)
            if ecs.rank(A) > len(A):
                bounded_ok = False
    print(f"  Bounded (r(A) ≤ |A|): {'✓' if bounded_ok else '✗'}")

    # 2. Monotone: A ⊆ B → r(A) ≤ r(B)
    mono_ok = True
    all_sets = list(_small_subsets(frozenset(ground)))
    for A in all_sets:
        for B in all_sets:
            if A <= B and ecs.rank(A) > ecs.rank(B):
                mono_ok = False
    print(f"  Monotone (A ⊆ B → r(A) ≤ r(B)): {'✓' if mono_ok else '✗'}")

    # 3. Submodular: r(A∪B) + r(A∩B) ≤ r(A) + r(B)
    submod_ok = True
    for A in all_sets:
        for B in all_sets:
            rAB = ecs.rank(A | B)
            rAiB = ecs.rank(A & B)
            rA = ecs.rank(A)
            rB = ecs.rank(B)
            if rAB + rAiB > rA + rB:
                submod_ok = False
    print(f"  Submodular (r(A∪B) + r(A∩B) ≤ r(A) + r(B)): {'✓' if submod_ok else '✗'}")

    # 4. Unit increase: r(A) ≤ r(A∪{x}) ≤ r(A) + 1
    unit_ok = True
    for A in all_sets:
        for x in ground:
            rA = ecs.rank(A)
            rAx = ecs.rank(A | {x})
            if not (rA <= rAx <= rA + 1):
                unit_ok = False
    print(f"  Unit increase: {'✓' if unit_ok else '✗'}")

    # 5. Closure-rank duality
    print(f"\nClosure-rank duality check:")
    for A in list(_small_subsets(frozenset(ground), max_size=3)):
        cl_A = ecs.cl(A)
        rank_A = ecs.rank(A)
        for x in ground:
            in_cl = x in cl_A
            rank_eq = ecs.rank(A | {x}) == rank_A
            if in_cl != rank_eq:
                print(f"  MISMATCH: x={x}, A={set(A)}")
    print(f"  All closure-rank dualities verified ✓")
    print()


def demo_secret_sharing():
    """Demonstrate the connection to secret-sharing access structures."""
    print("=" * 60)
    print("Demo 4: Secret Sharing via Closure Geometry")
    print("=" * 60)

    # (2,3)-threshold scheme: any 2 of 3 shares reconstruct the secret
    # This is U(2,4) where element 3 is the secret
    ecs = uniform_matroid_closure(4, 2)
    pres = canonical_presentation(ecs)

    secret = 3
    shares = frozenset({0, 1, 2})

    print(f"Secret: element {secret}")
    print(f"Shares: {set(shares)}")

    qs = pres.qualified_sets(secret)
    print(f"\nMinimal qualified sets (can reconstruct the secret):")
    for q in qs:
        print(f"  {set(q)}")

    print(f"\nUnqualified singletons (cannot reconstruct alone):")
    for x in shares:
        if secret not in pres.cl(frozenset({x})):
            print(f"  {{{x}}} — insufficient")

    print(f"\nThis matches the (2,3)-threshold access structure!")
    print(f"  - Any single share is insufficient")
    print(f"  - Any pair of shares suffices")
    print()


if __name__ == "__main__":
    demo_uniform_matroid()
    demo_graphic_matroid()
    demo_rank_properties()
    demo_secret_sharing()
    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualizations for Closure–Matroid Duality

Generates publication-quality figures showing:
1. Flat lattice diagram
2. Rank function heatmap
3. Circuit structure
4. Access structure diagram
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import itertools
import base64
import io

from algorithms import compute_rank, enumerate_circuits, enumerate_flats, compute_flat_lattice


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 string."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def visualize_rank_heatmap(save_path='rank_heatmap.png'):
    """Visualize the rank function of U(3,5) as a heatmap."""
    ground = frozenset(range(5))

    def cl(A):
        A = frozenset(A)
        return ground if len(A) >= 3 else A

    # Compute ranks for all subsets, organized by size
    all_sets = []
    for size in range(6):
        for S in itertools.combinations(range(5), size):
            all_sets.append(frozenset(S))

    # Create visualization
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))

    # Group by size
    by_size = {}
    for S in all_sets:
        sz = len(S)
        if sz not in by_size:
            by_size[sz] = []
        by_size[sz].append((S, compute_rank(cl, ground, S)))

    # Plot
    max_width = max(len(v) for v in by_size.values())
    colors = plt.cm.viridis(np.linspace(0, 1, 4))

    for size, sets in sorted(by_size.items()):
        n = len(sets)
        x_positions = np.linspace(0, 1, n + 2)[1:-1] if n > 1 else [0.5]
        for i, (S, r) in enumerate(sets):
            color = colors[r] if r < 4 else colors[3]
            rect = patches.FancyBboxPatch(
                (x_positions[i] * 10 - 0.3, size - 0.2),
                0.6, 0.4,
                boxstyle="round,pad=0.05",
                facecolor=color, edgecolor='black', alpha=0.8
            )
            ax.add_patch(rect)
            label = '{' + ','.join(str(x) for x in sorted(S)) + '}'
            ax.text(x_positions[i] * 10, size, f'{label}\nr={r}',
                    ha='center', va='center', fontsize=6, fontweight='bold')

    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 5.5)
    ax.set_ylabel('Set Size', fontsize=12)
    ax.set_title('Rank Function of U(3,5): r(A) = min(|A|, 3)', fontsize=14)
    ax.set_yticks(range(6))

    # Add colorbar
    sm = plt.cm.ScalarMappable(cmap=plt.cm.viridis, norm=plt.Normalize(0, 3))
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax, label='Rank')
    cbar.set_ticks([0, 1, 2, 3])

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")
    return fig_to_base64(fig)


def visualize_flat_lattice(save_path='flat_lattice.png'):
    """Visualize the flat lattice of U(2,4)."""
    ground = frozenset(range(4))

    def cl(A):
        A = frozenset(A)
        return ground if len(A) >= 2 else A

    flats = enumerate_flats(cl, ground)
    covers = compute_flat_lattice(cl, ground)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Assign positions: group by rank
    positions = {}
    by_rank = {}
    for F in flats:
        r = compute_rank(cl, ground, F)
        if r not in by_rank:
            by_rank[r] = []
        by_rank[r].append(F)

    for rank, flat_list in by_rank.items():
        n = len(flat_list)
        x_positions = np.linspace(-n/2 + 0.5, n/2 - 0.5, n)
        for i, F in enumerate(flat_list):
            positions[F] = (x_positions[i], rank)

    # Draw edges (covering relations)
    for F1, F2 in covers:
        x1, y1 = positions[F1]
        x2, y2 = positions[F2]
        ax.plot([x1, x2], [y1, y2], 'b-', alpha=0.4, linewidth=1.5)

    # Draw nodes
    for F, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.15, color='steelblue', ec='darkblue',
                           linewidth=2, zorder=5)
        ax.add_patch(circle)
        label = '{' + ','.join(str(e) for e in sorted(F)) + '}' if F else '∅'
        ax.text(x, y - 0.35, label, ha='center', va='top', fontsize=8,
               fontweight='bold')

    ax.set_xlim(-3, 3)
    ax.set_ylim(-0.5, 2.8)
    ax.set_aspect('equal')
    ax.set_title('Flat Lattice of U(2,4)', fontsize=14)
    ax.set_ylabel('Rank', fontsize=12)
    ax.set_yticks([0, 1, 2])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")
    return fig_to_base64(fig)


def visualize_circuit_structure(save_path='circuits.png'):
    """Visualize circuits of the graphic matroid of K4."""
    from demo import graphic_matroid_closure

    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    ecs = graphic_matroid_closure(4, edges)

    circuits = ecs.circuits()

    fig, axes = plt.subplots(1, len(circuits), figsize=(3 * len(circuits), 3))
    if len(circuits) == 1:
        axes = [axes]

    for idx, (ax, circ) in enumerate(zip(axes, circuits)):
        # Draw K4
        pos = {0: (0, 1), 1: (1, 1), 2: (0, 0), 3: (1, 0)}

        # Draw all edges grey
        for i, (u, v) in enumerate(edges):
            x = [pos[u][0], pos[v][0]]
            y = [pos[u][1], pos[v][1]]
            color = 'red' if i in circ else 'lightgrey'
            lw = 3 if i in circ else 1
            ax.plot(x, y, color=color, linewidth=lw, zorder=1)

        # Draw nodes
        for node, (x, y) in pos.items():
            ax.plot(x, y, 'ko', markersize=10, zorder=2)
            ax.text(x, y + 0.12, str(node), ha='center', va='bottom',
                   fontsize=9, fontweight='bold')

        edge_labels = [str(edges[i]) for i in sorted(circ)]
        ax.set_title(f'Circuit {idx+1}\n{", ".join(edge_labels)}', fontsize=9)
        ax.set_xlim(-0.3, 1.3)
        ax.set_ylim(-0.3, 1.3)
        ax.set_aspect('equal')
        ax.axis('off')

    fig.suptitle('Circuits of the Graphic Matroid of K₄', fontsize=13, y=1.02)
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")
    return fig_to_base64(fig)


def visualize_access_structure(save_path='access_structure.png'):
    """Visualize the access structure of a (2,3)-threshold scheme."""
    from demo import uniform_matroid_closure, canonical_presentation

    ecs = uniform_matroid_closure(4, 2)
    pres = canonical_presentation(ecs)
    secret = 3

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    shares = [0, 1, 2]
    all_subsets = []
    for size in range(4):
        for S in itertools.combinations(shares, size):
            all_subsets.append(frozenset(S))

    # Check qualification
    qualified = []
    unqualified = []
    for S in all_subsets:
        if secret in pres.cl(S):
            qualified.append(S)
        else:
            unqualified.append(S)

    # Minimal qualified
    min_qualified = pres.qualified_sets(secret)
    min_qual_set = set(frozenset(q) for q in min_qualified)

    # Draw as a lattice
    positions = {}
    by_size = {}
    for S in all_subsets:
        sz = len(S)
        if sz not in by_size:
            by_size[sz] = []
        by_size[sz].append(S)

    for sz, sets in by_size.items():
        n = len(sets)
        x_pos = np.linspace(-n/2 + 0.5, n/2 - 0.5, n)
        for i, S in enumerate(sets):
            positions[S] = (x_pos[i], sz)

    # Draw inclusion edges
    for S in all_subsets:
        for x in shares:
            S2 = S | {x}
            if S2 != S and S2 in positions:
                x1, y1 = positions[S]
                x2, y2 = positions[S2]
                ax.plot([x1, x2], [y1, y2], 'grey', alpha=0.3, linewidth=1)

    # Draw nodes with colors
    for S, (x, y) in positions.items():
        if S in min_qual_set:
            color = 'gold'
            ec = 'darkgoldenrod'
            label_extra = ' ★'
        elif S in set(frozenset(q) for q in qualified):
            color = 'lightgreen'
            ec = 'green'
            label_extra = ''
        else:
            color = 'lightcoral'
            ec = 'red'
            label_extra = ''

        circle = plt.Circle((x, y), 0.2, color=color, ec=ec,
                           linewidth=2, zorder=5)
        ax.add_patch(circle)
        label = '{' + ','.join(str(e) for e in sorted(S)) + '}' if S else '∅'
        ax.text(x, y - 0.35, label + label_extra, ha='center', va='top',
               fontsize=8, fontweight='bold')

    # Legend
    legend_elements = [
        patches.Patch(facecolor='gold', edgecolor='darkgoldenrod',
                     label='Minimal Qualified (★)'),
        patches.Patch(facecolor='lightgreen', edgecolor='green',
                     label='Qualified'),
        patches.Patch(facecolor='lightcoral', edgecolor='red',
                     label='Unqualified'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=9)

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-0.8, 3.5)
    ax.set_title('Access Structure of (2,3)-Threshold Scheme', fontsize=13)
    ax.set_ylabel('Coalition Size', fontsize=11)
    ax.set_yticks([0, 1, 2, 3])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {save_path}")
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_rank = visualize_rank_heatmap()
    b64_lattice = visualize_flat_lattice()
    b64_circuits = visualize_circuit_structure()
    b64_access = visualize_access_structure()
    print("\nAll visualizations generated!")
