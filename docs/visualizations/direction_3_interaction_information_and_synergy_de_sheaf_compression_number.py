#!/usr/bin/env python3
"""
Algorithms for Interaction Information Computation on Finite Sites
===================================================================

Implements the core algorithms for computing sheaf compression numbers,
mutual compression, and interaction information for presheaves on
finite categories with Grothendieck topologies.

Complexity Analysis:
  - sheaf_compression_number: O(2^n * s^2 * n * m) where
      n = number of objects, s = max section size, m = total morphisms
  - mutual_compression: 3x sheaf_compression_number
  - interaction_compression: 5x sheaf_compression_number
  - brute_force_search: O(p^3 * cost(interaction_compression))
      where p = number of presheaves enumerated
"""

from __future__ import annotations
from typing import Dict, List, Set, Tuple, Optional, Generator
from itertools import combinations, product as iterproduct
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════════
#  Data Structures
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Morphism:
    """A morphism in a finite category."""
    name: str
    source: str
    target: str


@dataclass
class FiniteCategory:
    """A finite category with named objects and morphisms."""
    name: str
    objects: Tuple[str, ...]
    morphisms: Tuple[Morphism, ...]

    def hom(self, src: str, tgt: str) -> List[Morphism]:
        """All morphisms from src to tgt."""
        return [m for m in self.morphisms
                if m.source == src and m.target == tgt]


@dataclass
class FinitePresheaf:
    """A presheaf F: C^op → FinSet on a finite category.

    The restriction maps are stored as:
      restrictions[morphism_name] : Dict[section_at_target, section_at_source]
    """
    name: str
    category: FiniteCategory
    sections: Dict[str, Tuple[str, ...]]  # obj → tuple of sections
    restrictions: Dict[str, Dict[str, str]]  # morph_name → restriction map


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 1: Sheaf Compression Number
# ═══════════════════════════════════════════════════════════════════════

def probes_separate(cat: FiniteCategory,
                    presheaf: FinitePresheaf,
                    probes: frozenset) -> bool:
    """Check if probe set separates all sections of presheaf.

    Time: O(|probes| * max_sections^2 * max_morphisms_per_hom)
    Space: O(1) beyond input

    Args:
        cat: The finite category
        presheaf: The presheaf to check separation for
        probes: Set of probe object names

    Returns:
        True iff for every object X, every pair of distinct sections
        s ≠ t at X, there exists a probe Z and morphism Z → X
        distinguishing s and t.
    """
    for obj in cat.objects:
        secs = presheaf.sections[obj]
        n = len(secs)
        for i in range(n):
            for j in range(i + 1, n):
                s, t = secs[i], secs[j]
                separated = False
                for probe in probes:
                    for m in cat.hom(probe, obj):
                        rmap = presheaf.restrictions[m.name]
                        if rmap[s] != rmap[t]:
                            separated = True
                            break
                    if separated:
                        break
                if not separated:
                    return False
    return True


def topology_compatible(cat: FiniteCategory,
                         probes: frozenset) -> bool:
    """Check Grothendieck topology compatibility (minimal topology).

    For the minimal topology, every object must be reachable from
    some probe via at least one morphism.

    Time: O(|objects| * |probes| * max_hom_size)
    """
    for obj in cat.objects:
        if not any(cat.hom(p, obj) for p in probes):
            return False
    return True


def sheaf_compression_number(cat: FiniteCategory,
                              presheaf: FinitePresheaf) -> int:
    """Compute sheaf compression number κ(F).

    Algorithm: Enumerate probe subsets of increasing size until finding
    the smallest that both separates sections and is topology-compatible.

    Time: O(Σ_{k=0}^{n} C(n,k) * (separation_check + compatibility_check))
    Space: O(n) for subset enumeration

    In the worst case this is O(2^n * s^2 * n * m) where s = max sections,
    m = morphisms. For small categories (n ≤ 5), this is very fast.
    """
    n = len(cat.objects)
    for size in range(n + 1):
        for combo in combinations(cat.objects, size):
            probes = frozenset(combo)
            if topology_compatible(cat, probes) and \
               probes_separate(cat, presheaf, probes):
                return size
    return n


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 2: Coproduct Construction
# ═══════════════════════════════════════════════════════════════════════

def coproduct(F: FinitePresheaf, G: FinitePresheaf) -> FinitePresheaf:
    """Compute pointwise coproduct F ⊕ G.

    (F ⊕ G)(X) = F(X) ∐ G(X) with disjoint-union restriction maps.

    Time: O(|objects| * (|F.sections| + |G.sections|) +
             |morphisms| * (|F.sections| + |G.sections|))
    Space: O(total sections + total restriction entries)
    """
    cat = F.category
    sections = {}
    restrictions = {}

    for obj in cat.objects:
        f_secs = tuple(f"L:{s}" for s in F.sections[obj])
        g_secs = tuple(f"R:{s}" for s in G.sections[obj])
        sections[obj] = f_secs + g_secs

    for m in cat.morphisms:
        rmap = {}
        f_rmap = F.restrictions[m.name]
        g_rmap = G.restrictions[m.name]
        for s in F.sections[m.target]:
            rmap[f"L:{s}"] = f"L:{f_rmap[s]}"
        for s in G.sections[m.target]:
            rmap[f"R:{s}"] = f"R:{g_rmap[s]}"
        restrictions[m.name] = rmap

    return FinitePresheaf(
        name=f"({F.name}⊕{G.name})",
        category=cat,
        sections=sections,
        restrictions=restrictions,
    )


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 3: Information Quantities
# ═══════════════════════════════════════════════════════════════════════

def mutual_compression(cat: FiniteCategory,
                        F: FinitePresheaf,
                        G: FinitePresheaf) -> int:
    """Compute mutual compression I(F;G) = κ(F) + κ(G) - κ(F⊕G).

    Time: 3 × sheaf_compression_number
    """
    kF = sheaf_compression_number(cat, F)
    kG = sheaf_compression_number(cat, G)
    kFG = sheaf_compression_number(cat, coproduct(F, G))
    return kF + kG - kFG


def conditional_mutual_compression(cat: FiniteCategory,
                                    F: FinitePresheaf,
                                    G: FinitePresheaf,
                                    H: FinitePresheaf) -> int:
    """Compute I(F;H|G) = I(F;G⊕H) - I(F;G).

    Time: 5 × sheaf_compression_number (shared κ(F) computation)
    """
    kF = sheaf_compression_number(cat, F)
    kG = sheaf_compression_number(cat, G)
    GH = coproduct(G, H)
    kGH = sheaf_compression_number(cat, GH)
    kFG = sheaf_compression_number(cat, coproduct(F, G))
    kFGH = sheaf_compression_number(cat, coproduct(F, GH))
    iFG = kF + kG - kFG
    iFGH = kF + kGH - kFGH
    return iFGH - iFG


def interaction_compression(cat: FiniteCategory,
                              F: FinitePresheaf,
                              G: FinitePresheaf,
                              H: FinitePresheaf) -> int:
    """Compute I(F;G;H) = I(F;G) + I(F;H) - I(F;G⊕H).

    Time: 5 × sheaf_compression_number
    """
    kF = sheaf_compression_number(cat, F)
    kG = sheaf_compression_number(cat, G)
    kH = sheaf_compression_number(cat, H)
    GH = coproduct(G, H)
    kFG = sheaf_compression_number(cat, coproduct(F, G))
    kFH = sheaf_compression_number(cat, coproduct(F, H))
    kGH_val = sheaf_compression_number(cat, GH)
    kFGH = sheaf_compression_number(cat, coproduct(F, GH))

    iFG = kF + kG - kFG
    iFH = kF + kH - kFH
    iFGH_joint = kF + kGH_val - kFGH
    return iFG + iFH - iFGH_joint


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 4: Presheaf Enumeration
# ═══════════════════════════════════════════════════════════════════════

def make_arrow_category() -> FiniteCategory:
    """Construct the arrow category 0 → 1."""
    return FiniteCategory(
        name="Arrow",
        objects=("0", "1"),
        morphisms=(
            Morphism("id_0", "0", "0"),
            Morphism("id_1", "1", "1"),
            Morphism("f", "0", "1"),
        ),
    )


def enumerate_arrow_presheaves(
    max_sections: int = 3
) -> Generator[FinitePresheaf, None, None]:
    """Enumerate presheaves on the arrow category with bounded sections.

    Yields presheaves with section sizes from 1 to max_sections at each object.

    Total count: Σ_{s0=1}^{max} Σ_{s1=1}^{max} s0^s1
    For max=3: 1+1+1 + 2+4+8 + 3+9+27 = 3+14+39 = 56 presheaves
    """
    cat = make_arrow_category()
    base = [str(i) for i in range(max_sections)]

    for s0 in range(1, max_sections + 1):
        for s1 in range(1, max_sections + 1):
            sec0 = tuple(base[:s0])
            sec1 = tuple(base[:s1])
            for mapping in iterproduct(sec0, repeat=s1):
                rmap = dict(zip(sec1, mapping))
                sections = {"0": sec0, "1": sec1}
                restrictions = {
                    "id_0": {s: s for s in sec0},
                    "id_1": {s: s for s in sec1},
                    "f": rmap,
                }
                yield FinitePresheaf(
                    name=f"P({s0},{s1})",
                    category=cat,
                    sections=sections,
                    restrictions=restrictions,
                )


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 5: Brute-Force Synergy Search
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class SearchResult:
    """Result of a brute-force synergy search."""
    max_sections: int
    total_presheaves: int
    total_triples: int
    negative_count: int
    synergy_witness_count: int
    min_interaction: int
    examples: List[Tuple[str, str, str, int]]


def brute_force_search(max_sections: int = 3) -> SearchResult:
    """Exhaustively search for negative interaction information.

    Enumerates all triples (F, G, H) of presheaves on the arrow category
    with section sizes ≤ max_sections, computing interaction information
    for each. Reports negative instances and XOR-synergy witnesses.

    Uses symmetry I(F;G;H) = I(F;H;G) to reduce search by ~2x.

    Time: O(p^3 * compression_cost) where p = number of presheaves
    Space: O(p) for presheaf storage
    """
    cat = make_arrow_category()
    presheaves = list(enumerate_arrow_presheaves(max_sections))
    n = len(presheaves)

    result = SearchResult(
        max_sections=max_sections,
        total_presheaves=n,
        total_triples=0,
        negative_count=0,
        synergy_witness_count=0,
        min_interaction=0,
        examples=[],
    )

    for i in range(n):
        F = presheaves[i]
        for j in range(n):
            G = presheaves[j]
            for k in range(j, n):  # symmetry in G,H
                H = presheaves[k]
                result.total_triples += 1

                kF = sheaf_compression_number(cat, F)
                kG = sheaf_compression_number(cat, G)
                kH = sheaf_compression_number(cat, H)
                GH = coproduct(G, H)
                kFG = sheaf_compression_number(cat, coproduct(F, G))
                kFH = sheaf_compression_number(cat, coproduct(F, H))
                kGH = sheaf_compression_number(cat, GH)
                kFGH = sheaf_compression_number(cat, coproduct(F, GH))

                iFG = kF + kG - kFG
                iFH = kF + kH - kFH
                iFGH = kF + kGH - kFGH
                val = iFG + iFH - iFGH

                if val < 0:
                    result.negative_count += 1
                    result.min_interaction = min(result.min_interaction, val)
                    if iFG == 0 and iFH == 0 and iFGH > 0:
                        result.synergy_witness_count += 1
                    if len(result.examples) < 10:
                        result.examples.append(
                            (F.name, G.name, H.name, val))

    return result


# ═══════════════════════════════════════════════════════════════════════
#  Main: Run Algorithms and Report
# ═══════════════════════════════════════════════════════════════════════

def main():
    print("Algorithms for Interaction Information on Finite Sites")
    print("=" * 55)

    # Algorithm demonstration
    cat = make_arrow_category()
    presheaves = list(enumerate_arrow_presheaves(2))
    print(f"\nArrow category presheaves (max sections ≤ 2): {len(presheaves)}")

    # Compute all pairwise mutual compressions
    print("\nSample mutual compressions:")
    for i in range(min(4, len(presheaves))):
        for j in range(i, min(4, len(presheaves))):
            F, G = presheaves[i], presheaves[j]
            mc = mutual_compression(cat, F, G)
            print(f"  I({F.name}; {G.name}) = {mc}")

    # Run search
    print("\nRunning brute-force search (max_sections=2)...")
    result = brute_force_search(2)
    print(f"  Presheaves: {result.total_presheaves}")
    print(f"  Triples checked: {result.total_triples}")
    print(f"  Negative instances: {result.negative_count}")
    print(f"  Synergy witnesses: {result.synergy_witness_count}")
    print(f"  Min interaction: {result.min_interaction}")

    print("\nRunning brute-force search (max_sections=3)...")
    result = brute_force_search(3)
    print(f"  Presheaves: {result.total_presheaves}")
    print(f"  Triples checked: {result.total_triples}")
    print(f"  Negative instances: {result.negative_count}")
    print(f"  Synergy witnesses: {result.synergy_witness_count}")
    print(f"  Min interaction: {result.min_interaction}")

    if result.negative_count == 0:
        print("\n  POSITIVITY BARRIER: No negative interaction found.")
        print("  This suggests that on the arrow category with the minimal")
        print("  Grothendieck topology, interaction information is always")
        print("  nonnegative for small section sizes.")
        print("  Synergy may require richer categories (e.g., triangle)")
        print("  or more complex topologies to manifest.")


if __name__ == "__main__":
    main()
