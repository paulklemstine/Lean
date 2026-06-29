#!/usr/bin/env python3
"""
algorithms.py — Algorithms for sheaf compression on finite sites.

Implements computation of compression numbers, coproduct assembly,
jointly admissible family search, and compression defect analysis.

All algorithms operate on finite categories represented as directed
multigraphs with explicit composition tables.
"""

from itertools import combinations
from typing import Dict, List, Tuple, Optional, FrozenSet, Set
from dataclasses import dataclass, field


# ────────────────────────────────────────────────────────────────────────────
# Data Structures
# ────────────────────────────────────────────────────────────────────────────

@dataclass
class FiniteSite:
    """A finite category with a (trivial) Grothendieck topology.

    The topology is the canonical one: only the maximal sieve is covering.
    This means topology compatibility requires that every object is reachable
    from at least one probe (there exists a morphism from the probe to the object).

    Attributes:
        objects: List of object names.
        morphisms: Dict mapping (source, target) to list of morphism names.
                   Identity morphisms are added automatically.
    """
    objects: List[str]
    morphisms: Dict[Tuple[str, str], List[str]] = field(default_factory=dict)

    def __post_init__(self):
        for obj in self.objects:
            key = (obj, obj)
            if key not in self.morphisms:
                self.morphisms[key] = [f"id_{obj}"]
            elif f"id_{obj}" not in self.morphisms[key]:
                self.morphisms[key].append(f"id_{obj}")

    def hom(self, source: str, target: str) -> List[str]:
        """All morphisms from source to target."""
        return self.morphisms.get((source, target), [])

    def has_morphism(self, source: str, target: str) -> bool:
        """Whether any morphism exists from source to target."""
        return len(self.hom(source, target)) > 0


@dataclass
class FinitePresheaf:
    """A presheaf F: C^op -> FinSet on a finite site.

    Attributes:
        site: The underlying finite site.
        sections: Dict mapping object name to list of section values.
        restriction_maps: Dict mapping (morphism, source, target) to a dict
            representing F(f): F(target) -> F(source) for f: source -> target.
    """
    site: FiniteSite
    sections: Dict[str, List] = field(default_factory=dict)
    restriction_maps: Dict[Tuple[str, str, str], Dict] = field(default_factory=dict)

    def obj(self, x: str) -> List:
        return self.sections.get(x, [])

    def restrict(self, morph: str, source: str, target: str, section) -> object:
        if morph == f"id_{target}" and source == target:
            return section
        key = (morph, source, target)
        return self.restriction_maps.get(key, {}).get(section, section)


# ────────────────────────────────────────────────────────────────────────────
# Algorithm 1: Separation Check
# ────────────────────────────────────────────────────────────────────────────

def check_separation(probes: FrozenSet[str], presheaf: FinitePresheaf) -> bool:
    """Check whether a probe family separates a presheaf.

    A probe family P separates F if for every object X and distinct sections
    s ≠ t ∈ F(X), there exists Z ∈ P and f: Z → X such that F(f)(s) ≠ F(f)(t).

    Time complexity: O(|P| · |Mor| · Σ_X |F(X)|²)
    Space complexity: O(1) additional

    Args:
        probes: Frozenset of probe object names.
        presheaf: The presheaf to check.

    Returns:
        True if the probe family separates the presheaf.
    """
    site = presheaf.site
    for x in site.objects:
        secs = presheaf.obj(x)
        for i in range(len(secs)):
            for j in range(i + 1, len(secs)):
                s, t = secs[i], secs[j]
                if s == t:
                    continue
                distinguished = False
                for z in probes:
                    for f in site.hom(z, x):
                        if presheaf.restrict(f, z, x, s) != presheaf.restrict(f, z, x, t):
                            distinguished = True
                            break
                    if distinguished:
                        break
                if not distinguished:
                    return False
    return True


# ────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Topology Compatibility Check
# ────────────────────────────────────────────────────────────────────────────

def check_topology_compatible(probes: FrozenSet[str], site: FiniteSite) -> bool:
    """Check topology compatibility (canonical topology).

    For the canonical topology, compatibility requires that every object X
    is reachable from at least one probe Z ∈ P (there exists f: Z → X).

    Time complexity: O(|P| · |Ob(C)|)
    Space complexity: O(1) additional

    Args:
        probes: Frozenset of probe object names.
        site: The finite site.

    Returns:
        True if the probe family is topology-compatible.
    """
    for x in site.objects:
        reachable = any(site.has_morphism(z, x) for z in probes)
        if not reachable:
            return False
    return True


# ────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Sheaf Compression Number
# ────────────────────────────────────────────────────────────────────────────

def compute_compression_number(presheaf: FinitePresheaf) -> Tuple[int, FrozenSet[str]]:
    """Compute the sheaf compression number κ_sh and an optimal witness.

    Enumerates probe families in order of increasing size and returns the
    first one that both separates the presheaf and is topology-compatible.

    Time complexity: O(2^n · n · |F|²) where n = |Ob(C)|
    Space complexity: O(n)

    Args:
        presheaf: The presheaf.

    Returns:
        Tuple of (compression_number, optimal_probe_family).
    """
    site = presheaf.site
    n = len(site.objects)
    for k in range(n + 1):
        for subset in combinations(site.objects, k):
            pf = frozenset(subset)
            if check_separation(pf, presheaf) and check_topology_compatible(pf, site):
                return k, pf
    return n, frozenset(site.objects)


# ────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Coproduct Presheaf Construction
# ────────────────────────────────────────────────────────────────────────────

def build_coproduct(F: FinitePresheaf, G: FinitePresheaf) -> FinitePresheaf:
    """Build the pointwise coproduct presheaf F ⊕ G.

    (F ⊕ G)(X) = F(X) ⊔ G(X) (tagged union).
    (F ⊕ G)(f) = F(f) ⊔ G(f) (applied component-wise).

    Time complexity: O(|Ob| · (|F| + |G|) · |Mor|)
    Space complexity: O(|Ob| · (|F| + |G|))

    Args:
        F: First presheaf.
        G: Second presheaf (must share the same site).

    Returns:
        The coproduct presheaf.
    """
    assert F.site is G.site or F.site.objects == G.site.objects
    site = F.site

    sections = {}
    for x in site.objects:
        sections[x] = [("L", s) for s in F.obj(x)] + [("R", s) for s in G.obj(x)]

    restriction_maps = {}
    for (src, tgt), morphs in site.morphisms.items():
        if src == tgt:
            continue
        for m in morphs:
            restr = {}
            for s in F.obj(tgt):
                restr[("L", s)] = ("L", F.restrict(m, src, tgt, s))
            for s in G.obj(tgt):
                restr[("R", s)] = ("R", G.restrict(m, src, tgt, s))
            restriction_maps[(m, src, tgt)] = restr

    return FinitePresheaf(site=site, sections=sections, restriction_maps=restriction_maps)


# ────────────────────────────────────────────────────────────────────────────
# Algorithm 5: Jointly Admissible Family Search
# ────────────────────────────────────────────────────────────────────────────

def find_jointly_admissible(
    F: FinitePresheaf,
    G: FinitePresheaf,
    max_size: Optional[int] = None
) -> Optional[Tuple[int, FrozenSet[str]]]:
    """Find the smallest jointly admissible probe family for F and G.

    A family R is jointly admissible if it separates both F and G
    and is topology-compatible.

    Time complexity: O(2^n · n · (|F|² + |G|²))
    Space complexity: O(n)

    Args:
        F: First presheaf.
        G: Second presheaf (same site).
        max_size: Optional upper bound on family size to search.

    Returns:
        Tuple (size, family) or None if not found within max_size.
    """
    site = F.site
    n = len(site.objects)
    limit = max_size if max_size is not None else n
    for k in range(limit + 1):
        for subset in combinations(site.objects, k):
            pf = frozenset(subset)
            if (check_separation(pf, F) and
                check_separation(pf, G) and
                check_topology_compatible(pf, site)):
                return k, pf
    return None


# ────────────────────────────────────────────────────────────────────────────
# Algorithm 6: Compression Defect Analysis
# ────────────────────────────────────────────────────────────────────────────

@dataclass
class CompressionAnalysis:
    """Results of compression defect analysis."""
    kappa_F: int
    kappa_G: int
    kappa_FG: int
    defect: int  # kappa_F + kappa_G - kappa_FG
    is_strict: bool  # defect > 0
    witness_F: FrozenSet[str]
    witness_G: FrozenSet[str]
    jointly_admissible: Optional[FrozenSet[str]]
    jointly_admissible_size: Optional[int]


def analyze_compression(F: FinitePresheaf, G: FinitePresheaf) -> CompressionAnalysis:
    """Full compression defect analysis for a presheaf pair.

    Computes κ(F), κ(G), κ(F⊕G), the defect, and searches for
    jointly admissible families.

    Args:
        F: First presheaf.
        G: Second presheaf (same site).

    Returns:
        CompressionAnalysis with all computed values.
    """
    kF, wF = compute_compression_number(F)
    kG, wG = compute_compression_number(G)

    coprod = build_coproduct(F, G)
    kFG, _ = compute_compression_number(coprod)

    defect = kF + kG - kFG

    ja_result = find_jointly_admissible(F, G, max_size=kF + kG - 1)
    ja_family = ja_result[1] if ja_result else None
    ja_size = ja_result[0] if ja_result else None

    return CompressionAnalysis(
        kappa_F=kF, kappa_G=kG, kappa_FG=kFG,
        defect=defect, is_strict=defect > 0,
        witness_F=wF, witness_G=wG,
        jointly_admissible=ja_family,
        jointly_admissible_size=ja_size
    )


# ────────────────────────────────────────────────────────────────────────────
# Example Usage
# ────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import random

    # Build a path category 0 → 1 → 2
    site = FiniteSite(
        objects=["A", "B", "C"],
        morphisms={
            ("A", "B"): ["f"],
            ("B", "C"): ["g"],
            ("A", "C"): ["gf"],  # composite g∘f
        }
    )

    # Build two presheaves
    random.seed(42)
    F = FinitePresheaf(
        site=site,
        sections={"A": [0, 1], "B": [0, 1, 2], "C": [0, 1]},
        restriction_maps={
            ("f", "A", "B"): {0: 0, 1: 0, 2: 1},
            ("g", "B", "C"): {0: 0, 1: 1},
            ("gf", "A", "C"): {0: 0, 1: 0},
        }
    )

    G = FinitePresheaf(
        site=site,
        sections={"A": [0, 1, 2], "B": [0, 1], "C": [0, 1, 2]},
        restriction_maps={
            ("f", "A", "B"): {0: 0, 1: 1},
            ("g", "B", "C"): {0: 0, 1: 1, 2: 0},
            ("gf", "A", "C"): {0: 0, 1: 1, 2: 0},
        }
    )

    print("Compression Analysis for Path Category A → B → C")
    print("=" * 50)
    result = analyze_compression(F, G)
    print(f"κ_sh(F) = {result.kappa_F} (witness: {result.witness_F})")
    print(f"κ_sh(G) = {result.kappa_G} (witness: {result.witness_G})")
    print(f"κ_sh(F⊕G) = {result.kappa_FG}")
    print(f"Defect I_sh(F;G) = {result.defect}")
    print(f"Strict subadditivity: {result.is_strict}")
    if result.jointly_admissible:
        print(f"Jointly admissible family: {result.jointly_admissible} (size {result.jointly_admissible_size})")
    else:
        print("No jointly admissible family smaller than κ(F)+κ(G) found.")
