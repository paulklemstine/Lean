#!/usr/bin/env python3
"""
Matroid Minors and the Robertson-Seymour Conjecture: Demonstrations

This script demonstrates key concepts from matroid minor theory,
including matroid representations, minor operations, and forbidden
minor checking.
"""
import itertools
from typing import List, Set, FrozenSet, Tuple, Optional, Dict


# ── Matroid representation ──────────────────────────────────────────

class Matroid:
    """A matroid defined by its ground set and independent sets."""

    def __init__(self, ground: Set[int], indep: Set[FrozenSet[int]]):
        self.ground = frozenset(ground)
        self.indep = frozenset(indep)

    def rank(self, S: FrozenSet[int]) -> int:
        """Rank of a subset: size of largest independent subset."""
        best = 0
        for r in range(len(S) + 1):
            for combo in itertools.combinations(S, r):
                if frozenset(combo) in self.indep:
                    best = max(best, r)
        return best

    def total_rank(self) -> int:
        return self.rank(self.ground)

    def delete(self, D: Set[int]) -> 'Matroid':
        """Delete elements D from the matroid."""
        new_ground = self.ground - D
        new_indep = {I for I in self.indep if I <= new_ground}
        return Matroid(new_ground, new_indep)

    def contract(self, C: Set[int]) -> 'Matroid':
        """Contract elements C from the matroid."""
        # Find a maximal independent subset of C
        C_fs = frozenset(C) & self.ground
        max_indep_C = frozenset()
        for r in range(len(C_fs) + 1):
            for combo in itertools.combinations(C_fs, r):
                fc = frozenset(combo)
                if fc in self.indep and len(fc) > len(max_indep_C):
                    max_indep_C = fc
        new_ground = self.ground - C_fs
        new_indep = set()
        for I in self.indep:
            if I <= new_ground | max_indep_C and max_indep_C <= I | (I & new_ground):
                new_indep.add(I & new_ground)
        # More precise: I is independent in contraction iff I ∪ max_indep_C is independent
        new_indep = set()
        for sub_size in range(len(new_ground) + 1):
            for combo in itertools.combinations(new_ground, sub_size):
                fc = frozenset(combo)
                if fc | max_indep_C in self.indep:
                    new_indep.add(fc)
        return Matroid(new_ground, new_indep)

    def dual(self) -> 'Matroid':
        """Dual matroid: bases of dual = complements of bases of original."""
        bases = {I for I in self.indep
                 if not any(I < J for J in self.indep)}
        dual_bases = {self.ground - B for B in bases}
        # Independent sets of dual = subsets of dual bases
        dual_indep = set()
        for B in dual_bases:
            for r in range(len(B) + 1):
                for combo in itertools.combinations(B, r):
                    dual_indep.add(frozenset(combo))
        return Matroid(self.ground, dual_indep)

    def is_minor_of(self, other: 'Matroid') -> bool:
        """Check if self is a minor of other (brute force for small matroids)."""
        # Try all possible C, D subsets
        other_ground = list(other.ground)
        n = len(other_ground)
        for mask_c in range(1 << n):
            for mask_d in range(1 << n):
                if mask_c & mask_d:
                    continue  # C and D must be disjoint for clean minor
                C = {other_ground[i] for i in range(n) if mask_c & (1 << i)}
                D = {other_ground[i] for i in range(n) if mask_d & (1 << i)}
                minor = other.contract(C).delete(D)
                if minor.ground == self.ground and minor.indep == self.indep:
                    return True
        return False

    def __eq__(self, other):
        return self.ground == other.ground and self.indep == other.indep

    def __hash__(self):
        return hash((self.ground, self.indep))

    def __repr__(self):
        return f"Matroid(|E|={len(self.ground)}, rank={self.total_rank()})"


# ── Standard matroid constructions ──────────────────────────────────

def uniform_matroid(n: int, r: int) -> Matroid:
    """U(r,n): uniform matroid of rank r on n elements."""
    ground = set(range(n))
    indep = set()
    for k in range(r + 1):
        for combo in itertools.combinations(range(n), k):
            indep.add(frozenset(combo))
    return Matroid(ground, indep)


def graphic_matroid(n_vertices: int, edges: List[tuple]) -> Matroid:
    """Graphic matroid: independent sets = forests."""
    ground = set(range(len(edges)))
    indep = set()
    for k in range(len(edges) + 1):
        for combo in itertools.combinations(range(len(edges)), k):
            # Check if the selected edges form a forest
            edge_set = [edges[i] for i in combo]
            if is_forest(n_vertices, edge_set):
                indep.add(frozenset(combo))
    return Matroid(ground, indep)


def is_forest(n: int, edges: list) -> bool:
    """Check if edges form a forest (acyclic graph)."""
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(a, b):
        a, b = find(a), find(b)
        if a == b:
            return False
        parent[a] = b
        return True
    for u, v in edges:
        if not union(u, v):
            return False
    return True


# ── Demonstrations ──────────────────────────────────────────────────

def demo_uniform_matroids():
    """Demonstrate uniform matroids and their minor operations."""
    print("=" * 60)
    print("DEMO 1: Uniform Matroids and Minors")
    print("=" * 60)

    U24 = uniform_matroid(4, 2)
    print(f"\nU(2,4) = {U24}")
    print(f"  Ground set: {set(U24.ground)}")
    print(f"  Rank: {U24.total_rank()}")
    print(f"  # independent sets: {len(U24.indep)}")

    # Delete element 3
    U24_d3 = U24.delete({3})
    print(f"\nU(2,4) \\ {{3}} = {U24_d3}")
    print(f"  Ground set: {set(U24_d3.ground)}")
    print(f"  Rank: {U24_d3.total_rank()}")

    # Contract element 0
    U24_c0 = U24.contract({0})
    print(f"\nU(2,4) / {{0}} = {U24_c0}")
    print(f"  Ground set: {set(U24_c0.ground)}")
    print(f"  Rank: {U24_c0.total_rank()}")

    # Check: U(2,3) is a minor of U(2,4)
    U23 = uniform_matroid(3, 2)
    # U(2,3) on {0,1,2} should be isomorphic to U24 \ {3}
    print(f"\nU(2,3) ground = {set(U23.ground)}")
    print(f"U(2,4)\\{{3}} ground = {set(U24_d3.ground)}")
    print(f"U(2,3) == U(2,4)\\{{3}}: {U23 == U24_d3}")


def demo_graphic_matroids():
    """Demonstrate graphic matroids (connection to Robertson-Seymour)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Graphic Matroids (Graph Minors)")
    print("=" * 60)

    # K4 complete graph
    edges_K4 = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    M_K4 = graphic_matroid(4, edges_K4)
    print(f"\nGraphic matroid of K4: {M_K4}")
    print(f"  # edges (ground set size): {len(M_K4.ground)}")
    print(f"  Rank: {M_K4.total_rank()}")

    # K3 (triangle)
    edges_K3 = [(0,1), (0,2), (1,2)]
    M_K3 = graphic_matroid(3, edges_K3)
    print(f"\nGraphic matroid of K3: {M_K3}")
    print(f"  Rank: {M_K3.total_rank()}")

    # Delete edge 5 (edge (2,3)) from K4
    M_K4_d = M_K4.delete({5})
    print(f"\nM(K4) \\ {{edge(2,3)}}: {M_K4_d}")
    print(f"  Rank: {M_K4_d.total_rank()}")


def demo_duality():
    """Demonstrate matroid duality and the dual-minor theorem."""
    print("\n" + "=" * 60)
    print("DEMO 3: Matroid Duality")
    print("=" * 60)

    U24 = uniform_matroid(4, 2)
    U24_dual = U24.dual()
    print(f"\nU(2,4): rank = {U24.total_rank()}")
    print(f"U(2,4)*: rank = {U24_dual.total_rank()}")
    print(f"U(2,4)* should be U(2,4) (self-dual): {U24 == U24_dual}")

    U13 = uniform_matroid(3, 1)
    U13_dual = U13.dual()
    print(f"\nU(1,3): rank = {U13.total_rank()}")
    print(f"U(1,3)*: rank = {U13_dual.total_rank()}")
    print(f"U(1,3)* should be U(2,3)")

    # Verify dual_dual = identity
    U24_dd = U24_dual.dual()
    print(f"\nU(2,4)** == U(2,4): {U24 == U24_dd}")


def demo_forbidden_minors():
    """Demonstrate the forbidden minor concept."""
    print("\n" + "=" * 60)
    print("DEMO 4: Forbidden Minors for Graphic Matroids")
    print("=" * 60)

    # U(2,4) is the forbidden minor for graphic matroids of rank ≤ 1
    # (i.e., forests). Any graph containing U(2,4) as a minor has a cycle.
    U24 = uniform_matroid(4, 2)

    # Check: is U(2,4) graphic?
    # U(2,4) has 4 elements, all pairs independent, all triples dependent
    # This is the cycle matroid of... actually U(2,4) is NOT graphic
    # (it's the matroid of 4 points in general position in rank 2)
    print(f"\nU(2,4) = {U24}")
    print("U(2,4) is NOT graphic — it's a forbidden minor for graphic matroids")

    # The key theorem: if a minor-closed property has the RS property,
    # then its set of forbidden minors is finite.
    print("\nKey Theorem (formalized in Lean):")
    print("  If C has the Robertson-Seymour property (WQO by minors)")
    print("  and P is minor-closed, then the set of forbidden minors")
    print("  for P within C is finite (no infinite antichain).")


def demo_rs_conjecture():
    """Discuss the Robertson-Seymour conjecture for matroids."""
    print("\n" + "=" * 60)
    print("DEMO 5: Robertson-Seymour Conjecture for Matroids")
    print("=" * 60)

    print("""
The Robertson-Seymour Theorem (for graphs):
  For any infinite sequence G₁, G₂, G₃, ... of finite graphs,
  there exist i < j such that Gᵢ is a minor of Gⱼ.

The Matroid RS Conjecture (for F_q-representable matroids):
  For any finite field F_q and any infinite sequence M₁, M₂, M₃, ...
  of F_q-representable matroids, there exist i < j such that
  Mᵢ is a minor of Mⱼ.

Status:
  q = 2 (binary matroids ≈ graphs): PROVED (Robertson-Seymour, 2004)
  q = 3 (ternary matroids): OPEN (Geelen-Gerards-Whittle program)
  q = 4 (GF(4)-representable): OPEN
  General q: OPEN

Our formalized results (in Lean 4):
  1. Duality preserves the minor relation: N ≤m M ↔ N✶ ≤m M✶
  2. RS property implies no infinite antichains
  3. RS + minor-closed ⟹ finite forbidden minors
  4. Forbidden minor characterization theorem (under well-foundedness)
  5. Duality of forbidden minors: FM(P✶) = (FM(P))✶
  6. MatroidWQO structure: bundles RS + dual-closure + minor-closure
""")


if __name__ == "__main__":
    demo_uniform_matroids()
    demo_graphic_matroids()
    demo_duality()
    demo_forbidden_minors()
    demo_rs_conjecture()


#!/usr/bin/env python3
"""
Visualization: Minor Lattice of Small Matroids

Generates a Hasse diagram of the minor ordering on uniform matroids U(r,n)
for small r and n, showing which matroids are minors of which.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import itertools


def uniform_matroid_indep(n, r):
    """Return independent sets of U(r,n)."""
    indep = set()
    for k in range(r + 1):
        for combo in itertools.combinations(range(n), k):
            indep.add(frozenset(combo))
    return frozenset(range(n)), indep


def is_minor_uniform(r1, n1, r2, n2):
    """Check if U(r1,n1) is a minor of U(r2,n2).
    U(r1,n1) ≤m U(r2,n2) iff r1 ≤ r2 and n1 - r1 ≤ n2 - r2."""
    return r1 <= r2 and (n1 - r1) <= (n2 - r2) and n1 <= n2


def main():
    # Generate uniform matroids U(r,n) for 0 ≤ r ≤ n ≤ 5
    matroids = []
    for n in range(1, 7):
        for r in range(n + 1):
            matroids.append((r, n))

    # Compute Hasse diagram edges (cover relations)
    edges = []
    for i, (r1, n1) in enumerate(matroids):
        for j, (r2, n2) in enumerate(matroids):
            if i == j:
                continue
            if is_minor_uniform(r1, n1, r2, n2):
                # Check it's a cover: no intermediate matroid
                is_cover = True
                for k, (r3, n3) in enumerate(matroids):
                    if k == i or k == j:
                        continue
                    if (is_minor_uniform(r1, n1, r3, n3) and
                        is_minor_uniform(r3, n3, r2, n2)):
                        is_cover = False
                        break
                if is_cover:
                    edges.append((i, j))

    # Layout: x = r, y = n
    fig, ax = plt.subplots(1, 1, figsize=(12, 10))

    # Position nodes
    positions = {}
    for idx, (r, n) in enumerate(matroids):
        x = r - n / 2  # center each row
        y = n
        positions[idx] = (x, y)

    # Draw edges
    for i, j in edges:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        ax.plot([x1, x2], [y1, y2], 'b-', alpha=0.3, linewidth=0.8)

    # Draw nodes
    for idx, (r, n) in enumerate(matroids):
        x, y = positions[idx]
        color = plt.cm.viridis(r / max(n, 1))
        ax.plot(x, y, 'o', color=color, markersize=12, zorder=5,
                markeredgecolor='black', markeredgewidth=0.5)
        ax.annotate(f'U({r},{n})', (x, y), textcoords="offset points",
                    xytext=(0, 10), ha='center', fontsize=7, fontweight='bold')

    ax.set_title('Hasse Diagram: Minor Order on Uniform Matroids U(r,n)',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('Shifted rank (r - n/2)', fontsize=11)
    ax.set_ylabel('Ground set size n', fontsize=11)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    # Legend
    legend_text = ("U(r₁,n₁) ≤m U(r₂,n₂)  ⟺  r₁≤r₂ and n₁-r₁≤n₂-r₂\n"
                   "Lines show cover relations (immediate minors)")
    ax.text(0.02, 0.02, legend_text, transform=ax.transAxes,
            fontsize=9, verticalalignment='bottom',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    plt.tight_layout()
    plt.savefig('minor_lattice.png', dpi=150, bbox_inches='tight')
    print("Saved minor_lattice.png")


if __name__ == "__main__":
    main()
