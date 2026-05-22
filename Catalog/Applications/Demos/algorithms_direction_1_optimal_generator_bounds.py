#!/usr/bin/env python3
"""
Algorithms for computing categorical sparsity invariants.

This module implements the core algorithms for:
- Primitive section detection
- Greedy generator compression
- Exact minimum representable cover computation
- Compression ratio analysis

These algorithms correspond to the formally verified Lean theorems in
Pythagorean/ProbeComplexity/OptimalGeneratorBounds.lean.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Any
import itertools


@dataclass
class FiniteCategory:
    """A finite category represented explicitly.

    Attributes:
        objects: List of objects.
        morphisms: Dict mapping (source, target) to list of morphism names.
        identity: Dict mapping object to its identity morphism name.
        composition: Dict mapping (g, f) to g ∘ f (f then g).
    """
    objects: list[Any]
    morphisms: dict[tuple[Any, Any], list[str]]
    identity: dict[Any, str]
    composition: dict[tuple[str, str], str]

    def all_morphisms(self) -> list[tuple[Any, Any, str]]:
        """Return all (source, target, name) triples."""
        result = []
        for (s, t), names in self.morphisms.items():
            for name in names:
                result.append((s, t, name))
        return result

    def non_identity_morphisms_to(self, target: Any) -> list[tuple[Any, str]]:
        """Return all (source, morphism_name) where source ≠ target."""
        result = []
        for src in self.objects:
            if src == target:
                continue
            for name in self.morphisms.get((src, target), []):
                result.append((src, name))
        return result


@dataclass
class Presheaf:
    """A finite-valued presheaf F : C^op → FinSet.

    For a morphism f : A → B in C, the restriction map goes
    F(B) → F(A) (contravariant).

    Attributes:
        category: The underlying finite category.
        fibers: Dict mapping each object Y to list of elements of F(Y).
        restriction: Dict mapping morphism name to the restriction function.
            For f : A → B, restriction[f] : F(B) → F(A).
    """
    category: FiniteCategory
    fibers: dict[Any, list[Any]]
    restriction: dict[str, Callable]

    def restrict(self, morphism_name: str, element: Any) -> Any:
        """Apply restriction along a morphism."""
        return self.restriction[morphism_name](element)


def is_primitive(F: Presheaf, Y: Any, x: Any) -> bool:
    """Check if section x at object Y is primitive.

    A section is primitive if it is NOT in the image of any restriction
    map from a different object. That is, there is no Z ≠ Y, f : Y → Z,
    z ∈ F(Z) such that F(f)(z) = x.

    In presheaf convention: for f : Y → Z in C, the restriction
    F.map(f^op) : F(Z) → F(Y). We check that x is not in the image
    of any such map from Z ≠ Y.

    Time complexity: O(|Mor| * max|F(Z)|)
    """
    for Z in F.category.objects:
        if Z == Y:
            continue
        # Look for morphisms from Y to Z in C
        for f_name in F.category.morphisms.get((Y, Z), []):
            # f : Y → Z, so F.map(f.op) : F(Z) → F(Y)
            for z in F.fibers[Z]:
                if F.restrict(f_name, z) == x:
                    return False
    return True


def compute_primitive_sections(F: Presheaf) -> dict[Any, list[Any]]:
    """Compute all primitive sections at each object.

    Returns:
        Dict mapping each object Y to the list of primitive sections at Y.

    Time complexity: O(|Ob| * |F_max| * |Mor| * |F_max|)
    """
    result = {}
    for Y in F.category.objects:
        prims = [x for x in F.fibers[Y] if is_primitive(F, Y, x)]
        result[Y] = prims
    return result


def compute_primitive_count(F: Presheaf) -> int:
    """Compute the total number of primitive sections.

    This is the categorical sparsity invariant: the number of
    restriction-irreducible information units.

    Time complexity: O(|Ob|^2 * |F_max|^2 * |Mor|)
    """
    prims = compute_primitive_sections(F)
    return sum(len(v) for v in prims.values())


def total_sections(F: Presheaf) -> int:
    """Compute the total number of sections across all objects."""
    return sum(len(v) for v in F.fibers.values())


def compression_ratio(F: Presheaf) -> float:
    """Compute the compression ratio: primitiveCount / totalSections.

    A ratio of 1.0 means no compression (e.g., discrete categories).
    A ratio < 1.0 means the category structure enables compression.
    """
    ts = total_sections(F)
    if ts == 0:
        return 1.0
    return compute_primitive_count(F) / ts


def _sections_covered_by(F: Presheaf, generators: list[tuple[Any, Any]]) -> set[tuple[Any, Any]]:
    """Compute all (object, section) pairs covered by a set of generators.

    A generator (Y, x) covers (W, w) if there exists f : W → Y with F(f)(x) = w.
    """
    covered = set()
    for gen_obj, gen_sec in generators:
        for W in F.category.objects:
            for f_name in F.category.morphisms.get((W, gen_obj), []):
                w = F.restrict(f_name, gen_sec)
                covered.add((W, w))
    return covered


def _all_sections(F: Presheaf) -> set[tuple[Any, Any]]:
    """Return the set of all (object, section) pairs."""
    return {(Y, x) for Y in F.category.objects for x in F.fibers[Y]}


def greedy_cover(F: Presheaf) -> list[tuple[Any, Any]]:
    """Compute a representable cover using a greedy algorithm.

    Strategy: prioritize primitive sections first, then add remaining
    sections as needed. At each step, pick the generator that covers
    the most uncovered sections.

    This implements the "greedy compression" strategy from the research paper.

    Time complexity: O(|total|^2 * |Mor| * |F_max|)

    Returns:
        List of (object, section) pairs forming the cover.
    """
    all_secs = _all_sections(F)
    if not all_secs:
        return []

    cover: list[tuple[Any, Any]] = []
    covered: set[tuple[Any, Any]] = set()

    # Candidate generators: all (Y, x) pairs
    candidates = [(Y, x) for Y in F.category.objects for x in F.fibers[Y]]

    while covered != all_secs:
        # Find the candidate that covers the most new sections
        best_gen = None
        best_new = set()
        for gen in candidates:
            new_covered = _sections_covered_by(F, [gen]) - covered
            if len(new_covered) > len(best_new):
                best_gen = gen
                best_new = new_covered
        if best_gen is None:
            break
        cover.append(best_gen)
        covered |= best_new
        candidates.remove(best_gen)

    return cover


def exact_min_cover(F: Presheaf) -> int:
    """Compute the exact minimum representable cover size by exhaustive search.

    Warning: exponential in the number of sections. Only use for small instances.

    Time complexity: O(2^|total| * |total| * |Mor| * |F_max|)

    Returns:
        The minimum number of generators needed to cover all sections.
    """
    all_secs = _all_sections(F)
    if not all_secs:
        return 0

    candidates = [(Y, x) for Y in F.category.objects for x in F.fibers[Y]]
    n = len(candidates)

    # Try increasing sizes
    for k in range(1, n + 1):
        for subset in itertools.combinations(candidates, k):
            if _sections_covered_by(F, list(subset)) >= all_secs:
                return k
    return n


def restriction_dependency_graph(F: Presheaf) -> dict[tuple[Any, Any], list[tuple[Any, Any]]]:
    """Compute the restriction dependency graph.

    Nodes are (object, section) pairs. There is an edge from (Z, z) to (Y, x)
    if there exists f : Y → Z with F(f)(z) = x and Z ≠ Y.

    This graph captures how sections depend on sections at other objects
    through restriction maps.

    Returns:
        Adjacency list: maps each node to its list of dependents.
    """
    graph: dict[tuple[Any, Any], list[tuple[Any, Any]]] = {}

    for Y in F.category.objects:
        for x in F.fibers[Y]:
            graph[(Y, x)] = []

    for Y in F.category.objects:
        for Z in F.category.objects:
            if Z == Y:
                continue
            for f_name in F.category.morphisms.get((Y, Z), []):
                for z in F.fibers[Z]:
                    x = F.restrict(f_name, z)
                    if (Y, x) not in graph[(Z, z)]:
                        graph[(Z, z)].append((Y, x))

    return graph


def print_dependency_graph(F: Presheaf):
    """Print the restriction dependency graph in a readable format."""
    graph = restriction_dependency_graph(F)
    print("Restriction Dependency Graph:")
    print("  (arrows show restriction: (Z,z) → (Y,x) means x = F(f)(z) for some f : Y → Z)")
    for node, deps in sorted(graph.items()):
        if deps:
            dep_str = ", ".join(f"({d[0]},{d[1]})" for d in deps)
            print(f"  ({node[0]},{node[1]}) → {dep_str}")
        else:
            print(f"  ({node[0]},{node[1]}) [primitive — no outgoing restrictions]")


if __name__ == "__main__":
    # Quick self-test
    from demo import make_discrete, make_chain, make_diamond, constant_presheaf

    print("=== Self-test ===")

    # Discrete(3), fiber size 2
    cat = make_discrete(3)
    F = constant_presheaf(cat, 2)
    pc = compute_primitive_count(F)
    ts = total_sections(F)
    em = exact_min_cover(F)
    assert pc == ts == em == 6, f"Discrete(3,2): pc={pc}, ts={ts}, em={em}"
    print(f"  Discrete(3,2): OK (primitiveCount={pc}, totalSections={ts}, exactMin={em})")

    # Chain(3), constant fiber 2
    cat = make_chain(3)
    F = constant_presheaf(cat, 2)
    pc = compute_primitive_count(F)
    ts = total_sections(F)
    em = exact_min_cover(F)
    print(f"  Chain(3,2): primitiveCount={pc}, totalSections={ts}, exactMin={em}")
    assert pc <= ts
    assert em <= ts

    print("\n  All tests passed!")
