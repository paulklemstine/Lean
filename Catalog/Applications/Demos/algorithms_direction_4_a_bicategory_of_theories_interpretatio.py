#!/usr/bin/env python3
"""
Algorithms for the 2-Category of Theories

Implements computational procedures for enumerating morphisms,
computing 2-cell orderings, and analyzing bicategory structure.
"""

from dataclasses import dataclass, field
from typing import List, Dict, Tuple, Optional, Set
import itertools


@dataclass
class Theory:
    """A research theory: a finite carrier with an ℕ-valued invariant.

    Attributes:
        name: Human-readable name.
        elements: List of carrier elements (strings).
        inv: Invariant function as a dictionary element → ℕ.
    """
    name: str
    elements: List[str]
    inv: Dict[str, int]


@dataclass
class Morphism:
    """An invariant-monotone morphism between theories.

    Attributes:
        source: Source theory.
        target: Target theory.
        mapping: Function as a dictionary source_element → target_element.
    """
    source: Theory
    target: Theory
    mapping: Dict[str, str]

    def is_valid(self) -> bool:
        """Check invariant monotonicity: source.inv[x] ≤ target.inv[f(x)]."""
        return all(
            self.source.inv[x] <= self.target.inv[self.mapping[x]]
            for x in self.source.elements
        )

    def invariant_profile(self) -> List[int]:
        """Return the list of target invariant values at image points."""
        return [self.target.inv[self.mapping[x]] for x in self.source.elements]


def compose_morphisms(f: Morphism, g: Morphism) -> Morphism:
    """Compose f: T→U with g: U→V.

    Time complexity: O(|T.elements|)
    Space complexity: O(|T.elements|)
    """
    assert f.target.name == g.source.name
    return Morphism(
        source=f.source,
        target=g.target,
        mapping={x: g.mapping[f.mapping[x]] for x in f.source.elements}
    )


def two_cell_holds(f: Morphism, g: Morphism) -> bool:
    """Check if g pointwise-dominates f (the 2-cell f ≤₂ g).

    Time complexity: O(|source.elements|)

    Returns True iff target.inv[f(x)] ≤ target.inv[g(x)] for all x.
    """
    assert f.source == g.source and f.target == g.target
    return all(
        f.target.inv[f.mapping[x]] <= f.target.inv[g.mapping[x]]
        for x in f.source.elements
    )


def enumerate_morphisms(source: Theory, target: Theory) -> List[Morphism]:
    """Enumerate all valid morphisms from source to target.

    Time complexity: O(|target.elements|^|source.elements| * |source.elements|)

    Algorithm:
        Brute-force enumeration of all functions, filtered by monotonicity.
        For small theories this is tractable; for large ones, use
        constraint-based enumeration (see below).
    """
    morphisms = []
    for mapping_values in itertools.product(target.elements,
                                             repeat=len(source.elements)):
        mapping = dict(zip(source.elements, mapping_values))
        m = Morphism(source=source, target=target, mapping=mapping)
        if m.is_valid():
            morphisms.append(m)
    return morphisms


def compute_hom_preorder(morphisms: List[Morphism]) -> List[List[bool]]:
    """Compute the full preorder matrix for a list of morphisms.

    Time complexity: O(n² * |source.elements|) where n = len(morphisms)

    Returns: n×n boolean matrix where result[i][j] = True iff morphisms[i] ≤₂ morphisms[j].
    """
    n = len(morphisms)
    matrix = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            matrix[i][j] = two_cell_holds(morphisms[i], morphisms[j])
    return matrix


def hasse_diagram(morphisms: List[Morphism],
                  preorder: List[List[bool]]) -> List[Tuple[int, int]]:
    """Compute the Hasse diagram (covering relation) of the preorder.

    Time complexity: O(n³)

    An edge i→j exists iff i ≤ j, i ≠ j, and there is no k with i < k < j.
    """
    n = len(morphisms)
    # First compute strict ordering: i < j means i ≤ j and not j ≤ i
    strict = [[preorder[i][j] and not preorder[j][i] for j in range(n)]
              for i in range(n)]

    edges = []
    for i in range(n):
        for j in range(n):
            if not strict[i][j]:
                continue
            # Check if there's any k strictly between i and j
            is_cover = True
            for k in range(n):
                if k != i and k != j and strict[i][k] and strict[k][j]:
                    is_cover = False
                    break
            if is_cover:
                edges.append((i, j))
    return edges


def equivalence_classes(morphisms: List[Morphism],
                        preorder: List[List[bool]]) -> List[List[int]]:
    """Compute equivalence classes under mutual domination.

    Two morphisms f, g are equivalent if f ≤₂ g and g ≤₂ f.
    This is the quotient that turns the preorder into a partial order.

    Time complexity: O(n²)
    """
    n = len(morphisms)
    visited = [False] * n
    classes = []
    for i in range(n):
        if visited[i]:
            continue
        cls = [i]
        visited[i] = True
        for j in range(i + 1, n):
            if preorder[i][j] and preorder[j][i]:
                cls.append(j)
                visited[j] = True
        classes.append(cls)
    return classes


def verify_interchange(source: Theory, mid: Theory, target: Theory,
                       f1: Morphism, f2: Morphism,
                       g1: Morphism, g2: Morphism) -> bool:
    """Verify the interchange law for a specific configuration.

    Given f₁ ≤ f₂ : S→M and g₁ ≤ g₂ : M→T,
    check that g₁∘f₁ ≤ g₂∘f₂.

    Time complexity: O(|source.elements|)
    """
    if not two_cell_holds(f1, f2) or not two_cell_holds(g1, g2):
        return True  # Vacuously true if premises don't hold

    c1 = compose_morphisms(f1, g1)
    c2 = compose_morphisms(f2, g2)
    return two_cell_holds(c1, c2)


def morphism_count_formula(source_size: int, target_inv_values: List[int],
                           source_inv_values: List[int]) -> int:
    """Count valid morphisms by the product formula.

    For each source element x, count target elements y with
    target.inv[y] ≥ source.inv[x]. The total count is the product
    over all source elements.

    Time complexity: O(|source| * |target|)
    """
    count = 1
    for s_val in source_inv_values:
        valid_targets = sum(1 for t_val in target_inv_values if t_val >= s_val)
        count *= valid_targets
    return count


# ─── Main demonstration ───

if __name__ == "__main__":
    T = Theory("Source", ["a", "b", "c"], {"a": 1, "b": 3, "c": 5})
    U = Theory("Target", ["x", "y", "z"], {"x": 2, "y": 4, "z": 6})

    print("=== Morphism Enumeration ===")
    morphisms = enumerate_morphisms(T, U)
    print(f"Theory T: {T.elements}, inv = {T.inv}")
    print(f"Theory U: {U.elements}, inv = {U.inv}")
    print(f"Number of valid morphisms T → U: {len(morphisms)}")

    # Verify with counting formula
    predicted = morphism_count_formula(
        len(T.elements),
        list(U.inv.values()),
        list(T.inv.values())
    )
    print(f"Predicted by counting formula: {predicted}")

    print("\n=== Preorder Structure ===")
    preorder = compute_hom_preorder(morphisms)
    classes = equivalence_classes(morphisms, preorder)
    print(f"Number of equivalence classes: {len(classes)}")
    for i, cls in enumerate(classes):
        profiles = [tuple(morphisms[j].invariant_profile()) for j in cls]
        print(f"  Class {i}: {len(cls)} morphism(s), profiles: {profiles}")

    print("\n=== Hasse Diagram ===")
    hasse = hasse_diagram(morphisms, preorder)
    print(f"Number of covering relations: {len(hasse)}")
    for i, j in hasse[:10]:
        pi = tuple(morphisms[i].invariant_profile())
        pj = tuple(morphisms[j].invariant_profile())
        print(f"  {pi} ≤ {pj}")

    print("\n=== Interchange Law Verification ===")
    V = Theory("Target2", ["p", "q"], {"p": 5, "q": 10})
    morph_UV = enumerate_morphisms(U, V)
    violations = 0
    tests = 0
    for f1, f2 in itertools.combinations(morphisms, 2):
        if not two_cell_holds(f1, f2):
            continue
        for g1, g2 in itertools.combinations(morph_UV, 2):
            if not two_cell_holds(g1, g2):
                continue
            tests += 1
            if not verify_interchange(T, U, V, f1, f2, g1, g2):
                violations += 1
    print(f"Tested {tests} configurations, violations: {violations}")
    print("Interchange law: " + ("VERIFIED ✓" if violations == 0 else "FAILED ✗"))
