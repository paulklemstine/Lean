#!/usr/bin/env python3
"""
Algorithms for Theory Morphism Construction and Theorem Transfer

This module implements the core algorithms for:
1. Automatic morphism discovery between theories
2. Chain composition with depth tracking
3. Optimal transfer path finding (maximizing depth gain)
4. Gap detection (proving non-existence of morphisms)

Complexity analysis is provided for each algorithm.
"""

from dataclasses import dataclass, field
from typing import Callable, List, Optional, Tuple, Dict, Set
import heapq
import itertools


# ═══════════════════════════════════════════════════════════════════
# Data Structures
# ═══════════════════════════════════════════════════════════════════

@dataclass
class Theory:
    """
    A research theory with carrier and invariant.

    Attributes:
        name: Human-readable identifier
        carrier: Finite carrier set (list of elements)
        inv: Invariant function Carrier → ℕ

    The invariant measures "depth" or "complexity" of each element.
    """
    name: str
    carrier: List[int]
    inv: Callable[[int], int]

    def max_depth(self) -> int:
        """Maximum invariant value achieved. O(|carrier|)."""
        return max(self.inv(x) for x in self.carrier) if self.carrier else 0

    def achieves_bound(self, n: int) -> Optional[int]:
        """Find witness for lower bound n. O(|carrier|)."""
        for x in self.carrier:
            if self.inv(x) >= n:
                return x
        return None

    def bounded_depth(self) -> int:
        """Upper bound on all invariant values. O(|carrier|)."""
        return self.max_depth()


@dataclass
class Morphism:
    """
    A theory morphism with monotonicity certificate.

    Attributes:
        source: Source theory
        target: Target theory
        map_fn: The underlying function
        name: Human-readable identifier

    Invariant: for all x in source.carrier,
        source.inv(x) ≤ target.inv(map_fn(x))
    """
    source: Theory
    target: Theory
    map_fn: Callable[[int], int]
    name: str = ""

    def is_valid(self) -> bool:
        """
        Verify monotonicity on the finite carrier.

        Time: O(|source.carrier|)
        Space: O(1)
        """
        return all(
            self.source.inv(x) <= self.target.inv(self.map_fn(x))
            for x in self.source.carrier
        )

    def depth_profile(self) -> List[Tuple[int, int, int]]:
        """
        Compute (element, source_depth, target_depth) for all carrier elements.

        Time: O(|source.carrier|)
        Space: O(|source.carrier|)
        """
        return [
            (x, self.source.inv(x), self.target.inv(self.map_fn(x)))
            for x in self.source.carrier
        ]

    def min_gain(self) -> int:
        """Minimum depth gain across all elements. O(|carrier|)."""
        return min(
            self.target.inv(self.map_fn(x)) - self.source.inv(x)
            for x in self.source.carrier
        )


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Morphism Composition
# ═══════════════════════════════════════════════════════════════════

def compose_morphisms(f: Morphism, g: Morphism) -> Morphism:
    """
    Compose two morphisms f: T → U and g: U → V into g ∘ f: T → V.

    Precondition: f.target == g.source (checked by name)

    Time: O(1) for construction; verification is O(|source.carrier|)
    Space: O(1) (lazy composition via closures)

    The composition inherits monotonicity:
        T.Inv(x) ≤ U.Inv(f(x)) ≤ V.Inv(g(f(x)))
    """
    assert f.target.name == g.source.name, \
        f"Cannot compose: {f.target.name} ≠ {g.source.name}"

    return Morphism(
        source=f.source,
        target=g.target,
        map_fn=lambda x, _f=f, _g=g: _g.map_fn(_f.map_fn(x)),
        name=f"{g.name} ∘ {f.name}"
    )


def compose_chain(morphisms: List[Morphism]) -> Morphism:
    """
    Compose a chain of morphisms [f₁, f₂, ..., fₙ].

    Time: O(n) for construction
    Space: O(n) for nested closures

    Returns f₁; f₂; ...; fₙ (left-to-right composition).
    """
    assert len(morphisms) > 0, "Empty chain"
    result = morphisms[0]
    for m in morphisms[1:]:
        result = compose_morphisms(result, m)
    return result


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Automatic Morphism Discovery
# ═══════════════════════════════════════════════════════════════════

def discover_morphisms(
    source: Theory,
    target: Theory,
    candidate_maps: Optional[List[Callable[[int], int]]] = None
) -> List[Morphism]:
    """
    Discover valid morphisms from source to target.

    If candidate_maps is None, tries all functions from source.carrier
    to target.carrier (brute force).

    Time: O(|candidates| × |source.carrier|)
    Space: O(|valid_morphisms|)

    For brute force: |candidates| = |target.carrier|^|source.carrier|
    which is only feasible for small carriers.
    """
    valid = []

    if candidate_maps is None:
        # Brute force: try constant maps and identity-like maps
        candidate_maps = []
        # Constant maps
        for y in target.carrier:
            candidate_maps.append(lambda x, _y=y: _y)
        # Identity (if carriers overlap)
        candidate_maps.append(lambda x: x)
        # Shifted maps
        for shift in range(-5, 6):
            candidate_maps.append(lambda x, _s=shift: x + _s)
        # Polynomial maps
        candidate_maps.append(lambda x: x * x)
        candidate_maps.append(lambda x: x * (x + 1))
        candidate_maps.append(lambda x: 2 * x)

    for i, fn in enumerate(candidate_maps):
        m = Morphism(source=source, target=target, map_fn=fn, name=f"map_{i}")
        try:
            if m.is_valid():
                valid.append(m)
        except (ValueError, KeyError, TypeError):
            continue

    return valid


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Optimal Transfer Path
# ═══════════════════════════════════════════════════════════════════

@dataclass
class TheoryGraph:
    """
    A directed graph of theories connected by morphisms.

    Supports finding optimal transfer paths that maximize
    depth amplification.
    """
    theories: Dict[str, Theory] = field(default_factory=dict)
    morphisms: Dict[str, List[Morphism]] = field(default_factory=dict)

    def add_theory(self, theory: Theory) -> None:
        """Register a theory. O(1)."""
        self.theories[theory.name] = theory
        if theory.name not in self.morphisms:
            self.morphisms[theory.name] = []

    def add_morphism(self, m: Morphism) -> None:
        """Register a morphism. O(1)."""
        self.morphisms[m.source.name].append(m)

    def find_transfer_path(
        self,
        source_name: str,
        target_name: str,
        bound: int
    ) -> Optional[List[Morphism]]:
        """
        Find a path from source to target that transfers bound n.

        Uses BFS to find the shortest path (fewest morphisms).

        Time: O(|V| + |E|) where V = theories, E = morphisms
        Space: O(|V|)

        Returns list of morphisms forming the path, or None.
        """
        if source_name == target_name:
            return []

        visited: Set[str] = {source_name}
        queue: List[Tuple[str, List[Morphism]]] = [(source_name, [])]

        while queue:
            current, path = queue.pop(0)
            for m in self.morphisms.get(current, []):
                next_name = m.target.name
                if next_name not in visited:
                    new_path = path + [m]
                    if next_name == target_name:
                        return new_path
                    visited.add(next_name)
                    queue.append((next_name, new_path))

        return None

    def max_depth_amplification(
        self,
        source_name: str,
        element: int
    ) -> Dict[str, Tuple[int, List[Morphism]]]:
        """
        Compute maximum achievable depth at each reachable theory
        starting from element x in source theory.

        Uses modified Dijkstra (maximizing rather than minimizing).

        Time: O((|V| + |E|) log |V|)
        Space: O(|V|)

        Returns dict mapping theory name → (max_depth, path).
        """
        source = self.theories[source_name]
        initial_depth = source.inv(element)

        # (negative_depth, theory_name, current_element, path)
        heap = [(-initial_depth, source_name, element, [])]
        best: Dict[str, Tuple[int, List[Morphism]]] = {}

        while heap:
            neg_depth, name, elem, path = heapq.heappop(heap)
            depth = -neg_depth

            if name in best:
                continue
            best[name] = (depth, path)

            for m in self.morphisms.get(name, []):
                next_name = m.target.name
                if next_name not in best:
                    next_elem = m.map_fn(elem)
                    next_depth = m.target.inv(next_elem)
                    heapq.heappush(
                        heap,
                        (-next_depth, next_name, next_elem, path + [m])
                    )

        return best


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: Gap Detection
# ═══════════════════════════════════════════════════════════════════

def detect_gap(source: Theory, target: Theory) -> Optional[int]:
    """
    Detect a gap proving no morphism source → target can exist.

    If source achieves bound n+1 but target has bounded depth n,
    no monotone map can exist.

    Time: O(|source.carrier| + |target.carrier|)
    Space: O(1)

    Returns the gap bound n, or None if no gap detected.
    """
    target_max = target.bounded_depth()
    source_max = source.max_depth()

    if source_max > target_max:
        return target_max

    return None


# ═══════════════════════════════════════════════════════════════════
# Algorithm 5: Product and Coproduct Construction
# ═══════════════════════════════════════════════════════════════════

def product_theory(t1: Theory, t2: Theory) -> Theory:
    """
    Construct the product theory T₁ × T₂.

    Carrier: T₁.carrier × T₂.carrier (as pairs encoded as 1000*a + b)
    Invariant: min(T₁.Inv(a), T₂.Inv(b))

    Time: O(|T₁| × |T₂|)
    Space: O(|T₁| × |T₂|)
    """
    carrier = [1000 * a + b for a in t1.carrier for b in t2.carrier]

    def inv(pair: int) -> int:
        a, b = divmod(pair, 1000)
        return min(t1.inv(a), t2.inv(b))

    return Theory(
        name=f"{t1.name}×{t2.name}",
        carrier=carrier,
        inv=inv
    )


def coproduct_theory(t1: Theory, t2: Theory) -> Theory:
    """
    Construct the coproduct theory T₁ ⊕ T₂.

    Carrier: tagged union (positive = T₁, negative = T₂)
    Invariant: delegates to the component

    Time: O(|T₁| + |T₂|)
    Space: O(|T₁| + |T₂|)
    """
    carrier = [x for x in t1.carrier] + [-x for x in t2.carrier]

    def inv(x: int) -> int:
        if x >= 0:
            return t1.inv(x)
        else:
            return t2.inv(-x)

    return Theory(
        name=f"{t1.name}⊕{t2.name}",
        carrier=carrier,
        inv=inv
    )


# ═══════════════════════════════════════════════════════════════════
# Demo / Self-Test
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("  ALGORITHM DEMOS")
    print("=" * 60)

    # Set up theories
    T_height = Theory("Height", list(range(1, 8)), lambda x: x)
    T_cell = Theory("Cell", list(range(1, 8)), lambda x: x * (x + 1))
    T_dim = Theory("Dimension", list(range(1, 8)), lambda x: x + 1)
    T_stab = Theory("Stability", list(range(1, 15)), lambda x: x)
    T_cap = Theory("Capacity", list(range(1, 200)), lambda x: x)

    # Build morphisms
    m1 = Morphism(T_height, T_cell, lambda x: x, "h→cell")
    m2 = Morphism(T_height, T_dim, lambda x: x, "h→dim")
    m3 = Morphism(T_dim, T_stab, lambda x: x + 1, "dim→stab")
    m4 = Morphism(T_stab, T_cap, lambda x: x, "stab→cap")
    m5 = Morphism(T_height, T_cap, lambda x: x * (x + 1), "h→cap")

    # Algorithm 1: Composition
    print("\n  Algorithm 1: Chain Composition")
    chain = compose_chain([m2, m3, m4])
    print(f"    Chain: {chain.name}")
    print(f"    Valid: {chain.is_valid()}")
    for x in [1, 3, 5, 7]:
        src_d = chain.source.inv(x)
        tgt_d = chain.target.inv(chain.map_fn(x))
        print(f"    x={x}: depth {src_d} → {tgt_d} (gain={tgt_d - src_d})")

    # Algorithm 2: Morphism Discovery
    print("\n  Algorithm 2: Morphism Discovery")
    found = discover_morphisms(T_height, T_cap)
    print(f"    Found {len(found)} valid morphisms from Height to Capacity")

    # Algorithm 3: Optimal Transfer Path
    print("\n  Algorithm 3: Optimal Transfer Path")
    graph = TheoryGraph()
    for t in [T_height, T_cell, T_dim, T_stab, T_cap]:
        graph.add_theory(t)
    for m in [m1, m2, m3, m4, m5]:
        graph.add_morphism(m)

    path = graph.find_transfer_path("Height", "Capacity", 5)
    if path:
        print(f"    Path found: {' → '.join(m.name for m in path)}")

    amp = graph.max_depth_amplification("Height", 5)
    print(f"    Max depths from Height(5):")
    for name, (depth, path) in sorted(amp.items()):
        path_str = " → ".join(m.name for m in path) if path else "(self)"
        print(f"      {name}: depth={depth} via {path_str}")

    # Algorithm 4: Gap Detection
    print("\n  Algorithm 4: Gap Detection")
    T_bounded = Theory("Bounded(3)", list(range(1, 20)), lambda x: min(x, 3))
    gap = detect_gap(T_height, T_bounded)
    print(f"    Height → Bounded(3): gap at {gap}")
    print(f"    → No morphism exists!")

    # Algorithm 5: Product/Coproduct
    print("\n  Algorithm 5: Product & Coproduct")
    prod = product_theory(T_height, T_dim)
    print(f"    {prod.name}: |carrier| = {len(prod.carrier)}, max_depth = {prod.max_depth()}")
    coprod = coproduct_theory(T_height, T_dim)
    print(f"    {coprod.name}: |carrier| = {len(coprod.carrier)}, max_depth = {coprod.max_depth()}")
