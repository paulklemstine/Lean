#!/usr/bin/env python3
"""
Algorithms for Persistent Homology Detection of Renormalizability

This module implements the core computational algorithms from the research paper:
1. Divergence complex construction from theory profiles
2. Persistent 1-bar count via Euler defect
3. Union-find for connected component counting
4. Barcode summary computation

All algorithms are verified against the formally proved theorems.
"""

from typing import List, Dict, Set, Tuple, Optional
from dataclasses import dataclass, field


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Divergence Profile Construction
# ═══════════════════════════════════════════════════════════════════

@dataclass
class GraphType:
    """A graph type in the divergence profile.

    Attributes:
        residue_arity: Number of external legs
        loop_order: Loop order at which this type appears
        is_superficially_divergent: Whether ω ≥ 0 by power counting
        is_primitive: Whether the graph is 1PI without subdivergences
    """
    residue_arity: int
    loop_order: int
    is_superficially_divergent: bool = True
    is_primitive: bool = True

    def __hash__(self):
        return hash((self.residue_arity, self.loop_order))


@dataclass
class DivergenceProfile:
    """Divergence profile for a QFT at bounded loop order.

    Corresponds to the Lean definition:
      structure DivProfile (α : Type*) [Fintype α] [DecidableEq α] where
        loopOrder : α → ℕ
        supDiv : α → Bool
        prim : α → Bool

    Time complexity: O(|graph_types|) to construct.
    Space complexity: O(|graph_types|).
    """
    graph_types: List[GraphType]

    def primitive_divergent_types(self) -> List[GraphType]:
        """Return primitive superficially divergent types.

        Corresponds to: primDivFinset D = univ.filter (supDiv ∧ prim)
        """
        return [g for g in self.graph_types
                if g.is_superficially_divergent and g.is_primitive]

    def primitive_divergence_count(self) -> int:
        """Count of primitive divergent types.

        Corresponds to: primDivCount D = (primDivFinset D).card
        """
        return len(self.primitive_divergent_types())


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Loop-Filtered Divergence Complex
# ═══════════════════════════════════════════════════════════════════

@dataclass
class LoopFilteredComplex:
    """A loop-filtered divergence complex.

    The 1-skeleton of the bar complex restricted to primitive generators.

    Corresponds to the Lean definition:
      structure LoopComplex (α : Type*) [DecidableEq α] where
        vertices : Finset α
        edges : Finset (α × α)
        filtration : α → ℕ

    Time complexity: O(V² + E) to construct.
    Space complexity: O(V + E).
    """
    vertices: List[GraphType]
    edges: List[Tuple[GraphType, GraphType]]
    filtration: Dict[GraphType, int] = field(default_factory=dict)

    @classmethod
    def from_profile(cls, profile: DivergenceProfile,
                     max_loop: int) -> 'LoopFilteredComplex':
        """Construct the complex from a divergence profile.

        Algorithm:
        1. Collect all primitive divergent types up to max_loop
        2. Create edges for:
           a. Same residue type, adjacent loop orders (vertical)
           b. Different residue type, same loop order (horizontal)
        3. Record filtration values

        Time: O(n²) where n = number of graph types
        Space: O(n²)
        """
        prim_types = [g for g in profile.graph_types
                      if g.is_superficially_divergent and g.is_primitive
                      and g.loop_order <= max_loop]

        edges = []
        for i, g1 in enumerate(prim_types):
            for j, g2 in enumerate(prim_types):
                if i < j:
                    # Vertical edges: same residue, adjacent loops
                    if (g1.residue_arity == g2.residue_arity and
                            abs(g1.loop_order - g2.loop_order) == 1):
                        edges.append((g1, g2))
                    # Horizontal edges: same loop, different residue
                    if (g1.loop_order == g2.loop_order and
                            g1.residue_arity != g2.residue_arity):
                        edges.append((g1, g2))

        filt = {g: g.loop_order for g in prim_types}
        return cls(vertices=prim_types, edges=edges, filtration=filt)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Union-Find for Connected Components
# ═══════════════════════════════════════════════════════════════════

class UnionFind:
    """Disjoint-set data structure with path compression and union by rank.

    Time complexity:
      - find: O(α(n)) amortized (inverse Ackermann)
      - union: O(α(n)) amortized
      - count_components: O(n)

    Space: O(n)
    """

    def __init__(self, elements):
        self.parent = {e: e for e in elements}
        self.rank = {e: 0 for e in elements}

    def find(self, x):
        """Find with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        """Union by rank."""
        px, py = self.find(x), self.find(y)
        if px == py:
            return
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1

    def count_components(self) -> int:
        """Count connected components."""
        return len(set(self.find(x) for x in self.parent))


def connected_components(vertices: list, edges: list) -> int:
    """Count connected components of a graph.

    Args:
        vertices: List of vertex identifiers
        edges: List of (v1, v2) pairs

    Returns:
        Number of connected components

    Time: O(V + E · α(V))
    Space: O(V)
    """
    if not vertices:
        return 0
    uf = UnionFind(vertices)
    for v1, v2 in edges:
        uf.union(v1, v2)
    return uf.count_components()


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: Persistent Bar Count via Euler Defect
# ═══════════════════════════════════════════════════════════════════

def persistent_bar_count_euler(complex: LoopFilteredComplex) -> int:
    """Compute persistent 1-bar count via the Euler defect formula.

    The formally verified theorem states:
      barCount = E_essential + β₀ - V

    where β₀ is the number of connected components.
    This is the cycle rank (first Betti number) of the graph.

    Corresponds to the Lean theorem:
      persistent_bar_count_eq_euler_defect

    Args:
        complex: A LoopFilteredComplex

    Returns:
        The persistent 1-bar count

    Time: O(V + E · α(V))
    Space: O(V)

    >>> profile = DivergenceProfile([
    ...     GraphType(2, 1), GraphType(4, 1),
    ...     GraphType(2, 2), GraphType(4, 2)])
    >>> C = LoopFilteredComplex.from_profile(profile, 2)
    >>> persistent_bar_count_euler(C)  # Should be > 0
    1
    """
    V = len(complex.vertices)
    E = len(complex.edges)
    if V == 0:
        return 0
    comp = connected_components(complex.vertices, complex.edges)
    assert V <= E + comp, f"Euler defect invalid: V={V}, E={E}, comp={comp}"
    return E + comp - V


# ═══════════════════════════════════════════════════════════════════
# Algorithm 5: Barcode Summary
# ═══════════════════════════════════════════════════════════════════

@dataclass
class BarcodeBar:
    """A bar in the persistence barcode.

    Attributes:
        birth: Loop order at which the bar is born
        death: Loop order at which the bar dies (None = infinite)
        generator: The generating primitive divergent type
    """
    birth: int
    death: Optional[int]
    generator: Optional[GraphType]

    @property
    def persistence(self) -> float:
        """Length of the bar. Infinite bars have persistence = inf."""
        if self.death is None:
            return float('inf')
        return self.death - self.birth


def compute_barcode(profile: DivergenceProfile, max_loop: int) -> List[BarcodeBar]:
    """Compute a simplified persistence barcode for the theory.

    Each primitive divergent residue type that appears by max_loop
    gives rise to an infinite bar born at its first appearance.

    Time: O(n log n) where n = number of graph types
    Space: O(n)
    """
    # Group by residue arity, find first appearance
    first_appearance: Dict[int, int] = {}
    for g in profile.graph_types:
        if g.is_superficially_divergent and g.is_primitive:
            if g.loop_order <= max_loop:
                arity = g.residue_arity
                if arity not in first_appearance:
                    first_appearance[arity] = g.loop_order
                else:
                    first_appearance[arity] = min(first_appearance[arity],
                                                   g.loop_order)

    bars = []
    for arity, birth in sorted(first_appearance.items()):
        bars.append(BarcodeBar(
            birth=birth,
            death=None,  # Essential bars persist forever
            generator=GraphType(arity, birth),
        ))

    return bars


def barcode_summary(bars: List[BarcodeBar]) -> str:
    """Format a barcode as a human-readable string."""
    lines = []
    for bar in bars:
        death_str = "∞" if bar.death is None else str(bar.death)
        gen_str = f"{bar.generator.residue_arity}-pt" if bar.generator else "?"
        lines.append(f"  [{bar.birth}, {death_str})  ← {gen_str} function")
    return "\n".join(lines)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 6: Renormalizability Test
# ═══════════════════════════════════════════════════════════════════

def test_renormalizability(profiles: List[DivergenceProfile],
                           threshold: int = 10) -> Tuple[bool, int]:
    """Test if a sequence of profiles indicates renormalizability.

    By the formally verified theorem:
      IsRenormalizable T ↔ ∃ B, ∀ n, primDivCount(T.profile n) ≤ B

    We check if the primitive divergence counts stabilize.

    Args:
        profiles: Divergence profiles at increasing truncation levels
        threshold: Number of stable levels required to declare renormalizable

    Returns:
        (is_renormalizable, stable_count)

    Time: O(n · m) where n = len(profiles), m = max types per profile
    Space: O(m)
    """
    counts = [p.primitive_divergence_count() for p in profiles]

    if not counts:
        return True, 0

    # Check if counts stabilize
    stable_count = counts[-1]
    stable_from = len(counts)
    for i in range(len(counts) - 1, -1, -1):
        if counts[i] != stable_count:
            stable_from = i + 1
            break
    else:
        stable_from = 0

    is_stable = (len(counts) - stable_from) >= min(threshold, len(counts))
    return is_stable, stable_count


# ═══════════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Algorithms for Persistent Renormalizability Detection")
    print("=" * 55)

    # Build φ⁴₄D profile
    phi4_types = []
    for L in range(1, 6):
        phi4_types.append(GraphType(residue_arity=2, loop_order=L))
        phi4_types.append(GraphType(residue_arity=4, loop_order=L))

    phi4_profile = DivergenceProfile(phi4_types)

    print(f"\nφ⁴₄D: {phi4_profile.primitive_divergence_count()} "
          f"primitive divergent types (total)")

    # Compute barcode
    bars = compute_barcode(phi4_profile, max_loop=5)
    print(f"\nBarcode (φ⁴₄D, L≤5):")
    print(barcode_summary(bars))
    print(f"Essential bars: {len([b for b in bars if b.death is None])}")

    # Compute Euler defect
    C = LoopFilteredComplex.from_profile(phi4_profile, max_loop=3)
    bar_count = persistent_bar_count_euler(C)
    print(f"\nEuler defect at L=3: {bar_count}")

    # Test renormalizability
    profiles = []
    for max_L in range(1, 6):
        types = [GraphType(2, L) for L in range(1, max_L+1)]
        types += [GraphType(4, L) for L in range(1, max_L+1)]
        profiles.append(DivergenceProfile(types))

    is_renorm, count = test_renormalizability(profiles)
    print(f"\nRenormalizability test: {'YES' if is_renorm else 'NO'} "
          f"(stable at {count})")
