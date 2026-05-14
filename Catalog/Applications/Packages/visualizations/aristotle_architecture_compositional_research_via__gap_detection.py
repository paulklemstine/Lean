"""
Theory Morphisms: Algorithms for Bridge Discovery and Composition

This module implements the core algorithms for constructing, composing,
and analyzing theory morphisms, including automated bridge discovery
and gap detection.
"""

from dataclasses import dataclass, field
from typing import Callable, Optional, List, Tuple, Dict, Set
import itertools


# ═══════════════════════════════════════════════════════════════
# Core Data Structures
# ═══════════════════════════════════════════════════════════════

@dataclass
class Theory:
    """A research theory with carrier ℕ and invariant function."""
    name: str
    inv: Callable[[int], int]

    def depth_profile(self, n: int = 20) -> List[int]:
        """Compute invariant values for elements 0..n."""
        return [self.inv(x) for x in range(n + 1)]

    def achieves_bound(self, bound: int, search_range: int = 1000) -> Optional[int]:
        """Find minimal witness achieving the bound, or None."""
        for x in range(search_range):
            if bound <= self.inv(x):
                return x
        return None

    def max_depth(self, search_range: int = 100) -> int:
        """Maximum depth in search range (or ∞ if unbounded)."""
        return max(self.inv(x) for x in range(search_range + 1))


@dataclass
class Morphism:
    """A theory morphism with monotonicity certificate."""
    source: Theory
    target: Theory
    to_fun: Callable[[int], int]
    name: str = ""
    _verified: bool = False

    def verify(self, up_to: int = 100) -> bool:
        """Empirically verify monotonicity up to given range."""
        self._verified = all(
            self.source.inv(x) <= self.target.inv(self.to_fun(x))
            for x in range(up_to + 1)
        )
        return self._verified

    def invariant_amplification(self, x: int) -> Tuple[int, int, int]:
        """Return (source_inv, target_inv, amplification) for element x."""
        s = self.source.inv(x)
        t = self.target.inv(self.to_fun(x))
        return s, t, t - s


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Morphism Composition
# ═══════════════════════════════════════════════════════════════

def compose_morphisms(f: Morphism, g: Morphism) -> Morphism:
    """
    Compose morphisms f: A → B and g: B → C into f;g: A → C.

    Time complexity: O(1) for construction, O(n) for verification.

    Theorem: If f and g are monotone, then f;g is monotone.
    Proof: For all x, A.Inv(x) ≤ B.Inv(f(x)) ≤ C.Inv(g(f(x))).
    """
    return Morphism(
        source=f.source,
        target=g.target,
        to_fun=lambda x, _f=f.to_fun, _g=g.to_fun: _g(_f(x)),
        name=f"{f.name};{g.name}" if f.name and g.name else "composed"
    )


def compose_chain(morphisms: List[Morphism]) -> Morphism:
    """
    Compose a chain of morphisms [f₁, f₂, ..., fₙ] into f₁;f₂;...;fₙ.

    Time complexity: O(n) for construction, O(n·m) for verification
    where m is the verification range.

    Returns the composed morphism from the first source to the last target.
    """
    if not morphisms:
        raise ValueError("Empty morphism chain")
    result = morphisms[0]
    for m in morphisms[1:]:
        result = compose_morphisms(result, m)
    return result


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Lower Bound Transfer
# ═══════════════════════════════════════════════════════════════

def transfer_bound(morphism: Morphism, bound: int,
                   witness: int) -> Tuple[int, int]:
    """
    Transfer a lower bound through a morphism.

    Given: bound ≤ source.inv(witness)
    Returns: (target_witness, target_inv_value)
    Guarantees: bound ≤ target_inv_value

    Time complexity: O(1) (single function evaluation + invariant computation)
    """
    source_val = morphism.source.inv(witness)
    assert bound <= source_val, \
        f"Witness {witness} has inv={source_val} < bound={bound}"

    target_witness = morphism.to_fun(witness)
    target_val = morphism.target.inv(target_witness)

    # This assertion follows from monotonicity
    assert bound <= target_val, \
        f"Monotonicity violation: {bound} > {target_val}"

    return target_witness, target_val


def transfer_through_pipeline(
    morphisms: List[Morphism], bound: int, witness: int
) -> List[Tuple[str, int, int]]:
    """
    Transfer a lower bound through a pipeline of morphisms,
    recording the witness and invariant value at each stage.

    Returns: [(theory_name, witness, inv_value), ...]

    Time complexity: O(n) where n is the pipeline length.
    """
    stages = [(morphisms[0].source.name, witness, morphisms[0].source.inv(witness))]

    current_witness = witness
    for m in morphisms:
        current_witness = m.to_fun(current_witness)
        inv_val = m.target.inv(current_witness)
        stages.append((m.target.name, current_witness, inv_val))

    return stages


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Gap Detection
# ═══════════════════════════════════════════════════════════════

def detect_gap(source: Theory, target: Theory,
               search_range: int = 100) -> Optional[Tuple[int, int, int]]:
    """
    Detect if a gap exists that prevents any morphism source → target.

    Returns: (source_bound, target_max, gap_size) if gap exists, else None.

    A gap exists if source achieves a bound n but target has bounded
    depth < n. This proves no monotone morphism can exist.

    Time complexity: O(search_range) for each theory.

    Pseudocode:
        target_max ← max{target.inv(y) : y ∈ [0, search_range]}
        source_bound ← min{source.inv(x) : source.inv(x) > target_max}
        if source_bound exists: return gap
        else: return None
    """
    target_max = target.max_depth(search_range)

    for x in range(search_range + 1):
        source_val = source.inv(x)
        if source_val > target_max:
            return (source_val, target_max, source_val - target_max)

    return None


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Bridge Discovery
# ═══════════════════════════════════════════════════════════════

def discover_identity_bridge(
    source: Theory, target: Theory, search_range: int = 50
) -> Optional[Morphism]:
    """
    Attempt to discover a bridge morphism using the identity map.

    Time complexity: O(search_range)

    This is the simplest bridge: check if source.inv(x) ≤ target.inv(x)
    for all x in range. If so, the identity is a valid morphism.
    """
    for x in range(search_range + 1):
        if source.inv(x) > target.inv(x):
            return None

    return Morphism(source, target, lambda x: x, name=f"{source.name}→{target.name}(id)")


def discover_shift_bridge(
    source: Theory, target: Theory,
    max_shift: int = 10, search_range: int = 50
) -> Optional[Morphism]:
    """
    Attempt to discover a bridge morphism using a shifted map x ↦ x + k.

    Time complexity: O(max_shift × search_range)

    Tries shifts k = 0, 1, ..., max_shift and returns the first valid one.
    """
    for k in range(max_shift + 1):
        valid = True
        for x in range(search_range + 1):
            if source.inv(x) > target.inv(x + k):
                valid = False
                break
        if valid:
            return Morphism(
                source, target, lambda x, _k=k: x + _k,
                name=f"{source.name}→{target.name}(+{k})"
            )
    return None


def discover_all_bridges(
    theories: List[Theory], search_range: int = 50
) -> List[Morphism]:
    """
    Discover all identity and shift bridges between a list of theories.

    Time complexity: O(n² × max_shift × search_range) where n = |theories|

    Returns a list of discovered morphisms.
    """
    bridges = []
    for s, t in itertools.permutations(theories, 2):
        # Try identity bridge
        bridge = discover_identity_bridge(s, t, search_range)
        if bridge:
            bridges.append(bridge)
            continue
        # Try shift bridge
        bridge = discover_shift_bridge(s, t, max_shift=5, search_range=search_range)
        if bridge:
            bridges.append(bridge)
    return bridges


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Reachability Analysis
# ═══════════════════════════════════════════════════════════════

def build_reachability_graph(
    theories: List[Theory], morphisms: List[Morphism]
) -> Dict[str, Set[str]]:
    """
    Build the transitive closure of the morphism graph.

    Time complexity: O(n³) via Floyd-Warshall on theory names.

    Returns: dict mapping theory name to set of reachable theory names.
    """
    names = [t.name for t in theories]
    # Direct edges
    reachable: Dict[str, Set[str]] = {n: {n} for n in names}
    for m in morphisms:
        reachable[m.source.name].add(m.target.name)

    # Floyd-Warshall
    for k in names:
        for i in names:
            for j in names:
                if k in reachable[i] and j in reachable[k]:
                    reachable[i].add(j)

    return reachable


# ═══════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Define theories
    theories = [
        Theory("Height", lambda n: n),
        Theory("Cell", lambda n: n * (n + 1)),
        Theory("Dimension", lambda n: n + 1),
        Theory("Stability", lambda n: n),
        Theory("Capacity", lambda n: n),
    ]

    print("=== Bridge Discovery ===")
    bridges = discover_all_bridges(theories)
    for b in bridges:
        verified = b.verify(50)
        print(f"  {b.name}: verified={verified}")

    print("\n=== Reachability Graph ===")
    reach = build_reachability_graph(theories, bridges)
    for name, targets in sorted(reach.items()):
        print(f"  {name} → {sorted(targets)}")

    print("\n=== Gap Detection ===")
    for s, t in itertools.permutations(theories, 2):
        gap = detect_gap(s, t, 50)
        if gap:
            print(f"  Gap: {s.name} → {t.name}: "
                  f"source achieves {gap[0]}, target max = {gap[1]}, gap = {gap[2]}")

    print("\n=== Pipeline Transfer ===")
    h_to_c = Morphism(theories[0], theories[1], lambda x: x, "H→C")
    h_to_d = Morphism(theories[0], theories[2], lambda x: x, "H→D")
    d_to_s = Morphism(theories[2], theories[3], lambda x: x + 1, "D→S")

    stages = transfer_through_pipeline([h_to_d, d_to_s], bound=5, witness=5)
    print("  Pipeline Height → Dimension → Stability with bound=5, witness=5:")
    for name, wit, val in stages:
        print(f"    {name}: witness={wit}, inv={val}")
