#!/usr/bin/env python3
"""
Sheaf Compression on Finite Sites — Core Algorithms

Implements the compression invariant computation algorithms described
in the research paper. These algorithms enumerate probe families over
finite sites and compute both presheaf and sheaf compression numbers.

Algorithm Complexity:
- Brute-force enumeration: O(2^n * n * |F| * |Mor|) where n = |Ob(C)|
- With pruning: significantly faster in practice for n ≤ 6

Type hints and docstrings throughout.
"""

from itertools import combinations
from typing import Dict, List, Set, Tuple, Optional, FrozenSet
from dataclasses import dataclass, field


# ─────────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Morphism:
    """A morphism in a finite category."""
    name: str
    source: str
    target: str


@dataclass
class FiniteSite:
    """A finite site: a finite category equipped with a Grothendieck topology.

    Attributes:
        objects: List of object names.
        morphisms: List of all morphisms (including identities).
        identity: Map from object name to its identity morphism name.
        compose: Composition table: compose[(f, g)] = f ∘ g.
        covering_sieves: For each object X, list of covering sieves.
            Each sieve is a frozenset of morphism names with target X.
    """
    objects: List[str]
    morphisms: List[Morphism]
    identity: Dict[str, str]
    compose: Dict[Tuple[str, str], str] = field(default_factory=dict)
    covering_sieves: Dict[str, List[FrozenSet[str]]] = field(default_factory=dict)

    def morphisms_to(self, X: str) -> List[Morphism]:
        """All morphisms with target X."""
        return [m for m in self.morphisms if m.target == X]

    def morphisms_from(self, Z: str) -> List[Morphism]:
        """All morphisms with source Z."""
        return [m for m in self.morphisms if m.source == Z]

    def morphisms_from_to(self, Z: str, X: str) -> List[Morphism]:
        """All morphisms from Z to X."""
        return [m for m in self.morphisms if m.source == Z and m.target == X]


@dataclass
class FinitePresheaf:
    """A presheaf on a finite category.

    Attributes:
        sections: F(X) = list of section names for each object X.
        restriction: For each morphism f: Y → X, restriction[f.name] maps
            sections of F(X) to sections of F(Y).
    """
    sections: Dict[str, List[str]]
    restriction: Dict[str, Dict[str, str]]


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Probe Separation Test
# ─────────────────────────────────────────────────────────────────────

def test_probe_separation(
    site: FiniteSite,
    presheaf: FinitePresheaf,
    probes: Set[str]
) -> bool:
    """Test whether a probe family separates a presheaf.

    A probe family P separates F if for every object X and every pair
    of distinct sections s, t ∈ F(X), there exists Z ∈ P and f: Z → X
    such that F(f)(s) ≠ F(f)(t).

    Time complexity: O(|Ob| * |F|² * |P| * max_hom_size)
    Space complexity: O(1) beyond input

    Args:
        site: The finite site.
        presheaf: The presheaf to test.
        probes: Set of probe object names.

    Returns:
        True if probes separate the presheaf.
    """
    for X in site.objects:
        secs = presheaf.sections[X]
        for i in range(len(secs)):
            for j in range(i + 1, len(secs)):
                s, t = secs[i], secs[j]
                distinguished = False
                for Z in probes:
                    for m in site.morphisms_from_to(Z, X):
                        if presheaf.restriction[m.name][s] != presheaf.restriction[m.name][t]:
                            distinguished = True
                            break
                    if distinguished:
                        break
                if not distinguished:
                    return False
    return True


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Topology Compatibility Test
# ─────────────────────────────────────────────────────────────────────

def test_topology_compatible(
    site: FiniteSite,
    probes: Set[str]
) -> bool:
    """Test whether a probe family is topology-compatible.

    P is compatible with J if every covering sieve on every object X
    contains at least one morphism whose source is in P.

    Time complexity: O(|Ob| * |covers| * |sieve_size|)

    Args:
        site: The finite site (includes topology data).
        probes: Set of probe object names.

    Returns:
        True if probes are topology-compatible.
    """
    for X in site.objects:
        if X not in site.covering_sieves:
            continue
        for sieve in site.covering_sieves[X]:
            has_probe_arrow = False
            for morph_name in sieve:
                # Find the morphism to check its source
                for m in site.morphisms:
                    if m.name == morph_name and m.source in probes:
                        has_probe_arrow = True
                        break
                if has_probe_arrow:
                    break
            if not has_probe_arrow:
                return False
    return True


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Compression Number Computation
# ─────────────────────────────────────────────────────────────────────

def compute_presheaf_compression(
    site: FiniteSite,
    presheaf: FinitePresheaf
) -> Tuple[int, Optional[Set[str]]]:
    """Compute the presheaf compression number.

    Enumerates probe families in order of increasing size and returns
    the first one that separates the presheaf.

    Time complexity: O(2^n * n * |F|² * max_hom_size) worst case
    where n = |Ob(C)|.

    Args:
        site: The finite site.
        presheaf: The presheaf.

    Returns:
        (compression_number, optimal_probe_set) or (n+1, None) if
        no separating family exists.
    """
    n = len(site.objects)
    for k in range(n + 1):
        for subset in combinations(site.objects, k):
            probes = set(subset)
            if test_probe_separation(site, presheaf, probes):
                return k, probes
    return n + 1, None


def compute_sheaf_compression(
    site: FiniteSite,
    presheaf: FinitePresheaf
) -> Tuple[int, Optional[Set[str]]]:
    """Compute the sheaf compression number.

    Enumerates probe families in order of increasing size and returns
    the first one that both separates the presheaf and is
    topology-compatible.

    Time complexity: O(2^n * (n * |F|² * max_hom + |covers|)) worst case

    Args:
        site: The finite site.
        presheaf: The presheaf.

    Returns:
        (compression_number, optimal_probe_set) or (n+1, None).
    """
    n = len(site.objects)
    for k in range(n + 1):
        for subset in combinations(site.objects, k):
            probes = set(subset)
            if (test_probe_separation(site, presheaf, probes) and
                    test_topology_compatible(site, probes)):
                return k, probes
    return n + 1, None


def compute_compression_gap(
    site: FiniteSite,
    presheaf: FinitePresheaf
) -> Tuple[int, int, int]:
    """Compute the gap between sheaf and presheaf compression.

    Returns:
        (presheaf_compression, sheaf_compression, gap)
    """
    pc, _ = compute_presheaf_compression(site, presheaf)
    sc, _ = compute_sheaf_compression(site, presheaf)
    return pc, sc, sc - pc


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Exhaustive Search for Compression Gaps
# ─────────────────────────────────────────────────────────────────────

def search_for_gaps(
    site: FiniteSite,
    presheaves: List[FinitePresheaf]
) -> List[Tuple[int, int, int, int]]:
    """Search for compression gaps across multiple presheaves.

    Args:
        site: The finite site.
        presheaves: List of presheaves to test.

    Returns:
        List of (index, presheaf_compression, sheaf_compression, gap)
        for presheaves with nonzero gap.
    """
    gaps = []
    for i, F in enumerate(presheaves):
        pc, sc, gap = compute_compression_gap(site, F)
        if gap > 0:
            gaps.append((i, pc, sc, gap))
    return gaps


# ─────────────────────────────────────────────────────────────────────
# Utility: Build standard sites
# ─────────────────────────────────────────────────────────────────────

def build_poset_site(
    elements: List[str],
    order: List[Tuple[str, str]],
    topology: str = "trivial"
) -> FiniteSite:
    """Build a finite site from a finite poset.

    Args:
        elements: List of poset elements.
        order: List of (a, b) pairs meaning a ≤ b.
        topology: "trivial" (only maximal sieve covers) or
                  "alexandrov" (principal upper sets generate covers).

    Returns:
        FiniteSite with appropriate topology.
    """
    # Build transitive closure
    le_pairs = set()
    for a in elements:
        le_pairs.add((a, a))  # reflexive
    for a, b in order:
        le_pairs.add((a, b))

    # Transitive closure
    changed = True
    while changed:
        changed = False
        for a, b in list(le_pairs):
            for c, d in list(le_pairs):
                if b == c and (a, d) not in le_pairs:
                    le_pairs.add((a, d))
                    changed = True

    # Build morphisms (one per ≤ relation)
    morphisms = []
    identity = {}
    for a in elements:
        id_name = f"id_{a}"
        morphisms.append(Morphism(id_name, a, a))
        identity[a] = id_name
    for a, b in le_pairs:
        if a != b:
            morphisms.append(Morphism(f"le_{a}_{b}", a, b))

    # Covering sieves
    covering_sieves = {}
    for X in elements:
        arrows_to_X = [m.name for m in morphisms if m.target == X]
        if topology == "trivial":
            covering_sieves[X] = [frozenset(arrows_to_X)]
        elif topology == "alexandrov":
            # In Alexandrov topology, principal upper-set sieves cover
            covering_sieves[X] = [frozenset(arrows_to_X)]
            # Also add each principal upper set as a covering sieve
            for a in elements:
                if (a, X) in le_pairs:
                    sieve = frozenset(m.name for m in morphisms
                                     if m.target == X and (m.source, a) in le_pairs)
                    if sieve not in covering_sieves[X]:
                        covering_sieves[X].append(sieve)

    return FiniteSite(
        objects=elements,
        morphisms=morphisms,
        identity=identity,
        covering_sieves=covering_sieves
    )


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demo ===\n")

    # Build a 3-element chain poset: a ≤ b ≤ c
    site = build_poset_site(
        elements=["a", "b", "c"],
        order=[("a", "b"), ("b", "c")],
        topology="trivial"
    )

    # Constant presheaf with 2 sections
    presheaf = FinitePresheaf(
        sections={"a": ["s0", "s1"], "b": ["s0", "s1"], "c": ["s0", "s1"]},
        restriction={
            "id_a": {"s0": "s0", "s1": "s1"},
            "id_b": {"s0": "s0", "s1": "s1"},
            "id_c": {"s0": "s0", "s1": "s1"},
            "le_a_b": {"s0": "s0", "s1": "s1"},
            "le_b_c": {"s0": "s0", "s1": "s1"},
            "le_a_c": {"s0": "s0", "s1": "s1"},
        }
    )

    pc, pc_probes = compute_presheaf_compression(site, presheaf)
    sc, sc_probes = compute_sheaf_compression(site, presheaf)

    print(f"Chain poset a ≤ b ≤ c, constant presheaf:")
    print(f"  Presheaf compression: {pc}, probes: {pc_probes}")
    print(f"  Sheaf compression:    {sc}, probes: {sc_probes}")
    print(f"  Gap: {sc - pc}")
    print()

    # Build a diamond poset
    site2 = build_poset_site(
        elements=["bot", "l", "r", "top"],
        order=[("bot", "l"), ("bot", "r"), ("l", "top"), ("r", "top")],
        topology="alexandrov"
    )

    presheaf2 = FinitePresheaf(
        sections={
            "bot": ["s0", "s1"],
            "l": ["s0", "s1"],
            "r": ["s0", "s1"],
            "top": ["s0", "s1"]
        },
        restriction={
            "id_bot": {"s0": "s0", "s1": "s1"},
            "id_l": {"s0": "s0", "s1": "s1"},
            "id_r": {"s0": "s0", "s1": "s1"},
            "id_top": {"s0": "s0", "s1": "s1"},
            "le_bot_l": {"s0": "s0", "s1": "s1"},
            "le_bot_r": {"s0": "s0", "s1": "s1"},
            "le_l_top": {"s0": "s0", "s1": "s1"},
            "le_r_top": {"s0": "s0", "s1": "s1"},
            "le_bot_top": {"s0": "s0", "s1": "s1"},
        }
    )

    pc2, pc2_probes = compute_presheaf_compression(site2, presheaf2)
    sc2, sc2_probes = compute_sheaf_compression(site2, presheaf2)
    print(f"Diamond poset, constant presheaf (Alexandrov topology):")
    print(f"  Presheaf compression: {pc2}, probes: {pc2_probes}")
    print(f"  Sheaf compression:    {sc2}, probes: {sc2_probes}")
    print(f"  Gap: {sc2 - pc2}")
