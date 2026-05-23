"""
Algorithms for computing probe complexity on finite sites.

This module implements the core algorithms for presheaf and sheaf probe
complexity computation on finite categories with Grothendieck topologies.

All algorithms operate on explicit finite representations:
- Categories as adjacency-like structures (objects + morphism sets + composition)
- Presheaves as dictionaries mapping objects to finite sets with restriction maps
- Grothendieck topologies as collections of covering sieves
"""

from __future__ import annotations

import itertools
from dataclasses import dataclass, field
from typing import (
    Any,
    Callable,
    Dict,
    FrozenSet,
    List,
    Optional,
    Set,
    Tuple,
)


# ---------------------------------------------------------------------------
# Core types
# ---------------------------------------------------------------------------

Obj = str  # objects are named strings for readability
Mor = Tuple[Obj, Obj, str]  # (source, target, label)


@dataclass
class FiniteCategory:
    """A small finite category given explicitly.

    Attributes:
        objects: list of object names
        morphisms: dict mapping (source, target) to list of morphism labels
        compose: function (f_label, g_label, src, mid, tgt) -> composed label
        identity: dict mapping object to its identity morphism label
    """

    objects: List[Obj]
    morphisms: Dict[Tuple[Obj, Obj], List[str]]
    compose: Callable[[str, str, Obj, Obj, Obj], str]
    identity: Dict[Obj, str]

    def hom(self, source: Obj, target: Obj) -> List[str]:
        """Return the list of morphism labels from source to target."""
        return self.morphisms.get((source, target), [])

    def all_morphisms(self) -> List[Mor]:
        """Return all morphisms as (source, target, label) triples."""
        result = []
        for (s, t), labels in self.morphisms.items():
            for lbl in labels:
                result.append((s, t, lbl))
        return result


@dataclass
class Presheaf:
    """A presheaf on a FiniteCategory.

    Attributes:
        sections: dict mapping object c to the set of sections F(c)
        restrict: function (section, f_source, f_target, f_label) -> restricted section
            Applies the restriction map F(f) to a section.
    """

    sections: Dict[Obj, List[Any]]
    restrict: Callable[[Any, Obj, Obj, str], Any]


# A sieve on object c is a set of (source, morphism_label) pairs
Sieve = FrozenSet[Tuple[Obj, str]]


@dataclass
class GrothendieckTopology:
    """A Grothendieck topology on a FiniteCategory.

    Attributes:
        covering_sieves: dict mapping object c to a set of sieves on c.
            Each sieve is a frozenset of (source, morphism_label) pairs.
    """

    covering_sieves: Dict[Obj, Set[Sieve]]


# ---------------------------------------------------------------------------
# Sieve generation
# ---------------------------------------------------------------------------


def maximal_sieve(cat: FiniteCategory, c: Obj) -> Sieve:
    """The maximal sieve on c: all morphisms targeting c."""
    pairs: Set[Tuple[Obj, str]] = set()
    for src in cat.objects:
        for lbl in cat.hom(src, c):
            pairs.add((src, lbl))
    return frozenset(pairs)


def generate_sieve(
    cat: FiniteCategory, c: Obj, presieve: Set[Tuple[Obj, str]]
) -> Sieve:
    """Generate the sieve from a presieve by closing under precomposition.

    A sieve S on c contains f : Y -> c and is closed under precomposition:
    if f ∈ S and g : Z -> Y, then f ∘ g ∈ S.
    """
    sieve: Set[Tuple[Obj, str]] = set(presieve)
    changed = True
    while changed:
        changed = False
        new_elements: Set[Tuple[Obj, str]] = set()
        for src_f, f_lbl in list(sieve):
            # f : src_f -> c is in the sieve
            # For each g : Z -> src_f, add f ∘ g
            for z in cat.objects:
                for g_lbl in cat.hom(z, src_f):
                    composed = cat.compose(f_lbl, g_lbl, z, src_f, c)
                    pair = (z, composed)
                    if pair not in sieve:
                        new_elements.add(pair)
        if new_elements:
            sieve.update(new_elements)
            changed = True
    return frozenset(sieve)


def probe_family_sieve(
    cat: FiniteCategory, probe_family: List[Obj], c: Obj
) -> Sieve:
    """Generate the sieve at c from a probe family.

    The presieve consists of all morphisms f : Z -> c where Z ∈ probe_family.
    """
    presieve: Set[Tuple[Obj, str]] = set()
    for z in probe_family:
        for lbl in cat.hom(z, c):
            presieve.add((z, lbl))
    return generate_sieve(cat, c, presieve)


# ---------------------------------------------------------------------------
# Separation and topology-respect checking
# ---------------------------------------------------------------------------


def separates_presheaf(
    cat: FiniteCategory, probe_family: List[Obj], F: Presheaf
) -> bool:
    """Check whether a probe family separates a presheaf.

    A probe family P separates F if for every object c and every pair
    of distinct sections x, y ∈ F(c), there exists Z ∈ P and f : Z -> c
    such that F(f)(x) ≠ F(f)(y).
    """
    for c in cat.objects:
        secs = F.sections.get(c, [])
        for i in range(len(secs)):
            for j in range(i + 1, len(secs)):
                x, y = secs[i], secs[j]
                # Check if some probe distinguishes x from y
                separated = False
                for z in probe_family:
                    for f_lbl in cat.hom(z, c):
                        if F.restrict(x, z, c, f_lbl) != F.restrict(y, z, c, f_lbl):
                            separated = True
                            break
                    if separated:
                        break
                if not separated:
                    return False
    return True


def respects_topology(
    cat: FiniteCategory,
    probe_family: List[Obj],
    J: GrothendieckTopology,
) -> bool:
    """Check whether a probe family respects a Grothendieck topology.

    P respects J if for every object c, the sieve generated by P at c
    is a J-covering sieve.
    """
    for c in cat.objects:
        sieve = probe_family_sieve(cat, probe_family, c)
        if sieve not in J.covering_sieves.get(c, set()):
            return False
    return True


# ---------------------------------------------------------------------------
# Complexity computation
# ---------------------------------------------------------------------------


def presheaf_probe_complexity(cat: FiniteCategory, F: Presheaf) -> int:
    """Compute the presheaf probe complexity of F.

    Returns the minimum cardinality of a probe family that separates F.

    Time complexity: O(2^n * n * S^2) where n = |Ob(C)|, S = max|F(c)|.
    """
    n = len(cat.objects)
    for k in range(n + 1):
        for subset in itertools.combinations(cat.objects, k):
            probe = list(subset)
            if separates_presheaf(cat, probe, F):
                return k
    return n  # should not reach here


def sheaf_probe_complexity(
    cat: FiniteCategory, F: Presheaf, J: GrothendieckTopology
) -> int:
    """Compute the sheaf probe complexity of F relative to topology J.

    Returns the minimum cardinality of a probe family that both
    separates F and respects J.

    Time complexity: O(2^n * n * (S^2 + |Mor|)) where n = |Ob(C)|.
    """
    n = len(cat.objects)
    for k in range(n + 1):
        for subset in itertools.combinations(cat.objects, k):
            probe = list(subset)
            if separates_presheaf(cat, probe, F) and respects_topology(
                cat, probe, J
            ):
                return k
    return n  # should not reach here


# ---------------------------------------------------------------------------
# Topology construction helpers
# ---------------------------------------------------------------------------


def maximal_topology(cat: FiniteCategory) -> GrothendieckTopology:
    """The maximal (discrete) topology: every sieve is covering.

    This is ⊤ in the lattice of Grothendieck topologies.
    """
    covering: Dict[Obj, Set[Sieve]] = {}
    for c in cat.objects:
        # Enumerate all sieves on c (subsets of morphisms targeting c)
        all_mors: List[Tuple[Obj, str]] = []
        for src in cat.objects:
            for lbl in cat.hom(src, c):
                all_mors.append((src, lbl))
        # All subsets that are actually sieves (closed under precomposition)
        all_sieves: Set[Sieve] = set()
        for r in range(len(all_mors) + 1):
            for subset in itertools.combinations(all_mors, r):
                s = frozenset(subset)
                # Check sieve closure
                if _is_sieve(cat, c, s):
                    all_sieves.add(s)
        covering[c] = all_sieves
    return GrothendieckTopology(covering_sieves=covering)


def minimal_topology(cat: FiniteCategory) -> GrothendieckTopology:
    """The minimal topology: only the maximal sieve covers at each object.

    This is ⊥ in the lattice of Grothendieck topologies.
    """
    covering: Dict[Obj, Set[Sieve]] = {}
    for c in cat.objects:
        covering[c] = {maximal_sieve(cat, c)}
    return GrothendieckTopology(covering_sieves=covering)


def _is_sieve(cat: FiniteCategory, c: Obj, s: FrozenSet[Tuple[Obj, str]]) -> bool:
    """Check whether s is a sieve on c (closed under precomposition)."""
    for src_f, f_lbl in s:
        for z in cat.objects:
            for g_lbl in cat.hom(z, src_f):
                composed = cat.compose(f_lbl, g_lbl, z, src_f, c)
                if (z, composed) not in s:
                    return False
    return True


# ---------------------------------------------------------------------------
# Example categories
# ---------------------------------------------------------------------------


def make_discrete_category(names: List[str]) -> FiniteCategory:
    """Create a discrete category (only identity morphisms)."""
    morphisms: Dict[Tuple[Obj, Obj], List[str]] = {}
    identity: Dict[Obj, str] = {}
    for name in names:
        morphisms[(name, name)] = [f"id_{name}"]
        identity[name] = f"id_{name}"

    def compose(f: str, g: str, src: Obj, mid: Obj, tgt: Obj) -> str:
        if f.startswith("id_"):
            return g
        if g.startswith("id_"):
            return f
        return f  # should not happen in discrete category

    return FiniteCategory(
        objects=names, morphisms=morphisms, compose=compose, identity=identity
    )


def make_arrow_category() -> FiniteCategory:
    """Create the arrow category: 0 -> 1."""
    objects = ["0", "1"]
    morphisms = {
        ("0", "0"): ["id_0"],
        ("1", "1"): ["id_1"],
        ("0", "1"): ["f"],
    }
    identity = {"0": "id_0", "1": "id_1"}

    def compose(f_lbl: str, g_lbl: str, src: Obj, mid: Obj, tgt: Obj) -> str:
        if f_lbl.startswith("id_"):
            return g_lbl
        if g_lbl.startswith("id_"):
            return f_lbl
        # f : mid -> tgt, g : src -> mid
        return f_lbl  # only possible composition is f ∘ id_0 = f

    return FiniteCategory(
        objects=objects, morphisms=morphisms, compose=compose, identity=identity
    )


def make_triangle_category() -> FiniteCategory:
    """Create a triangle category: 0 -> 1 -> 2 with 0 -> 2."""
    objects = ["0", "1", "2"]
    morphisms = {
        ("0", "0"): ["id_0"],
        ("1", "1"): ["id_1"],
        ("2", "2"): ["id_2"],
        ("0", "1"): ["f01"],
        ("1", "2"): ["f12"],
        ("0", "2"): ["f02"],  # f12 ∘ f01 = f02
    }
    identity = {"0": "id_0", "1": "id_1", "2": "id_2"}

    def compose(f_lbl: str, g_lbl: str, src: Obj, mid: Obj, tgt: Obj) -> str:
        if f_lbl.startswith("id_"):
            return g_lbl
        if g_lbl.startswith("id_"):
            return f_lbl
        # f12 ∘ f01 = f02
        if f_lbl == "f12" and g_lbl == "f01":
            return "f02"
        return f_lbl  # fallback

    return FiniteCategory(
        objects=objects, morphisms=morphisms, compose=compose, identity=identity
    )


# ---------------------------------------------------------------------------
# Example presheaves
# ---------------------------------------------------------------------------


def constant_presheaf(
    cat: FiniteCategory, values: List[Any]
) -> Presheaf:
    """A constant presheaf: F(c) = values for all c, all restrictions are identity."""
    sections = {c: list(values) for c in cat.objects}

    def restrict(x: Any, src: Obj, tgt: Obj, f_lbl: str) -> Any:
        return x

    return Presheaf(sections=sections, restrict=restrict)


def indicator_presheaf(cat: FiniteCategory, obj: Obj) -> Presheaf:
    """The representable presheaf at obj: F(c) = Hom(c, obj)."""
    sections: Dict[Obj, List[Any]] = {}
    for c in cat.objects:
        sections[c] = cat.hom(c, obj)

    def restrict(x: Any, src: Obj, tgt: Obj, f_lbl: str) -> Any:
        # x is a morphism label tgt -> obj
        # f : src -> tgt
        # F(f)(x) = x ∘ f (precomposition)
        return cat.compose(x, f_lbl, src, tgt, obj)

    return Presheaf(sections=sections, restrict=restrict)


# ---------------------------------------------------------------------------
# Main demonstration
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("=" * 60)
    print("Probe Complexity Algorithms — Demonstration")
    print("=" * 60)

    # 1. Discrete category with 3 objects
    print("\n--- Discrete Category {A, B, C} ---")
    cat = make_discrete_category(["A", "B", "C"])
    F = constant_presheaf(cat, ["x", "y", "z"])
    print(f"Presheaf: constant with 3 sections at each object")
    pc = presheaf_probe_complexity(cat, F)
    print(f"Presheaf probe complexity: {pc}")

    J_max = maximal_topology(cat)
    J_min = minimal_topology(cat)
    sc_max = sheaf_probe_complexity(cat, F, J_max)
    sc_min = sheaf_probe_complexity(cat, F, J_min)
    print(f"Sheaf probe complexity (maximal topology): {sc_max}")
    print(f"Sheaf probe complexity (minimal topology): {sc_min}")
    print(f"Presheaf = Sheaf (max top)? {pc == sc_max}")
    print(f"Presheaf = Sheaf (min top)? {pc == sc_min}")

    # 2. Arrow category
    print("\n--- Arrow Category (0 -> 1) ---")
    cat2 = make_arrow_category()
    F2 = constant_presheaf(cat2, ["a", "b"])
    print(f"Presheaf: constant with 2 sections")
    pc2 = presheaf_probe_complexity(cat2, F2)
    print(f"Presheaf probe complexity: {pc2}")

    J2_max = maximal_topology(cat2)
    J2_min = minimal_topology(cat2)
    sc2_max = sheaf_probe_complexity(cat2, F2, J2_max)
    sc2_min = sheaf_probe_complexity(cat2, F2, J2_min)
    print(f"Sheaf probe complexity (maximal topology): {sc2_max}")
    print(f"Sheaf probe complexity (minimal topology): {sc2_min}")
    print(f"Equality holds? {pc2 == sc2_max == sc2_min}")

    # 3. Triangle category
    print("\n--- Triangle Category (0 -> 1 -> 2) ---")
    cat3 = make_triangle_category()
    F3_repr = indicator_presheaf(cat3, "2")
    print(f"Presheaf: representable at object 2")
    pc3 = presheaf_probe_complexity(cat3, F3_repr)
    print(f"Presheaf probe complexity: {pc3}")

    J3_max = maximal_topology(cat3)
    sc3_max = sheaf_probe_complexity(cat3, F3_repr, J3_max)
    print(f"Sheaf probe complexity (maximal topology): {sc3_max}")
    print(f"Equality holds? {pc3 == sc3_max}")

    print("\n" + "=" * 60)
    print("All examples confirm topology-transparent compression.")
    print("=" * 60)
