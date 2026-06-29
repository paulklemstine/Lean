#!/usr/bin/env python3
"""
algorithms.py — Algorithms for computing sheaf compression information quantities.

Implements:
1. Sheaf compression number computation via exhaustive probe search
2. Mutual compression (categorical mutual information)
3. Conditional compression defect
4. Conditional mutual compression
5. Chain rule verification
6. Exhaustive counterexample search

Complexity:
- Compression number: O(2^n * n * |Sec|^2 * |Mor|) where n = |Obj|
- Mutual compression: 3× compression number computation
- Chain rule verification: 5× compression number computation
"""

from itertools import combinations, product
from typing import Dict, List, Tuple, Set, Optional, Any
from dataclasses import dataclass, field


@dataclass
class FiniteCategory:
    """A finite category with explicit objects and morphisms."""
    objects: List[str]
    morphisms: Dict[Tuple[str, str], List[str]] = field(default_factory=dict)

    def __post_init__(self):
        for obj in self.objects:
            key = (obj, obj)
            if key not in self.morphisms:
                self.morphisms[key] = [f"id_{obj}"]
            elif f"id_{obj}" not in self.morphisms[key]:
                self.morphisms[key].append(f"id_{obj}")

    def hom(self, src: str, tgt: str) -> List[str]:
        return self.morphisms.get((src, tgt), [])


@dataclass
class Presheaf:
    """A presheaf on a finite category valued in finite sets.

    Attributes:
        name: identifier for display
        sections: maps object name -> list of section values
        restrictions: maps (morphism, src, tgt) -> callable restriction map
    """
    name: str
    sections: Dict[str, List[Any]]
    restrictions: Dict[Tuple[str, str, str], Any] = field(default_factory=dict)

    def obj(self, X: str) -> List[Any]:
        return self.sections.get(X, [])

    def restrict(self, f_name: str, src: str, tgt: str, section: Any) -> Any:
        key = (f_name, src, tgt)
        if key in self.restrictions:
            return self.restrictions[key](section)
        return section  # default: identity


@dataclass
class GrothendieckTopology:
    """Grothendieck topology on a finite category.

    covering_sieves: for each object X, list of covering sieves.
    Each sieve is a set of (source_object, morphism_name) pairs.
    """
    name: str
    covering_sieves: Dict[str, List[Set[Tuple[str, str]]]] = field(default_factory=dict)


# ============================================================
# Algorithm 1: Sheaf Compression Number
# ============================================================

def is_topology_compatible(cat: FiniteCategory, probes: Set[str],
                           topo: GrothendieckTopology) -> bool:
    """Check topology compatibility: every covering sieve intersects probes.

    Time: O(|Obj| * |Sieves| * |Sieve_size|)
    """
    for X in cat.objects:
        for sieve in topo.covering_sieves.get(X, []):
            if not any(Z in probes for (Z, _) in sieve):
                return False
    return True


def is_separated_by(cat: FiniteCategory, presheaf: Presheaf,
                    probes: Set[str]) -> bool:
    """Check if probes separate presheaf sections.

    Time: O(|Obj| * |Sec|^2 * |Probes| * |Mor|)
    """
    for X in cat.objects:
        secs = presheaf.obj(X)
        for i in range(len(secs)):
            for j in range(i + 1, len(secs)):
                s, t = secs[i], secs[j]
                distinguished = False
                for Z in probes:
                    for f_name in cat.hom(Z, X):
                        if presheaf.restrict(f_name, Z, X, s) != presheaf.restrict(f_name, Z, X, t):
                            distinguished = True
                            break
                    if distinguished:
                        break
                if not distinguished:
                    return False
    return True


def compute_compression_number(cat: FiniteCategory, presheaf: Presheaf,
                               topo: GrothendieckTopology) -> Optional[int]:
    """Compute κ_sh(J, F) by exhaustive search over probe families.

    Algorithm:
        For k = 0, 1, ..., |Obj|:
            For each subset P ⊆ Obj of size k:
                If P is topology-compatible AND P separates F:
                    Return k
        Return None (no valid probe family exists)

    Time: O(2^n * n * |Sec|^2 * |Mor|) where n = |Obj|
    Space: O(n) for storing probe subsets
    """
    for k in range(len(cat.objects) + 1):
        for combo in combinations(cat.objects, k):
            probes = set(combo)
            if (is_topology_compatible(cat, probes, topo) and
                    is_separated_by(cat, presheaf, probes)):
                return k
    return None


# ============================================================
# Algorithm 2: Coproduct Construction
# ============================================================

def coproduct_presheaf(F: Presheaf, G: Presheaf, cat: FiniteCategory) -> Presheaf:
    """Construct pointwise coproduct F ⊕ G.

    Sections: F(X) ⊔ G(X) via tagged union ("L", s) | ("R", s)
    Restrictions: Sum.map F(f) G(f)

    Time: O(|Obj| + |Mor|) for construction
    """
    sections = {}
    restrictions = {}

    for X in cat.objects:
        sections[X] = [("L", s) for s in F.obj(X)] + [("R", s) for s in G.obj(X)]

    for (src, tgt), morph_list in cat.morphisms.items():
        for f_name in morph_list:
            def make_r(fn, s, t, F_ref, G_ref):
                def r(section):
                    tag, val = section
                    if tag == "L":
                        return ("L", F_ref.restrict(fn, s, t, val))
                    else:
                        return ("R", G_ref.restrict(fn, s, t, val))
                return r
            restrictions[(f_name, src, tgt)] = make_r(f_name, src, tgt, F, G)

    return Presheaf(f"{F.name}⊕{G.name}", sections, restrictions)


# ============================================================
# Algorithm 3: Information Quantities
# ============================================================

def mutual_compression(cat: FiniteCategory, topo: GrothendieckTopology,
                       F: Presheaf, G: Presheaf) -> Optional[int]:
    """Compute I_sh(F; G) = κ(F) + κ(G) - κ(F⊕G).

    Time: 3 × compression_number_time
    """
    kF = compute_compression_number(cat, F, topo)
    kG = compute_compression_number(cat, G, topo)
    FG = coproduct_presheaf(F, G, cat)
    kFG = compute_compression_number(cat, FG, topo)

    if any(v is None for v in [kF, kG, kFG]):
        return None
    return kF + kG - kFG


def conditional_compression_defect(cat: FiniteCategory, topo: GrothendieckTopology,
                                   G: Presheaf, H: Presheaf) -> Optional[int]:
    """Compute κ_cond(G, H) = κ(G⊕H) - κ(G).

    Time: 2 × compression_number_time
    """
    kG = compute_compression_number(cat, G, topo)
    GH = coproduct_presheaf(G, H, cat)
    kGH = compute_compression_number(cat, GH, topo)

    if kG is None or kGH is None:
        return None
    return kGH - kG


def conditional_mutual_compression(cat: FiniteCategory, topo: GrothendieckTopology,
                                   F: Presheaf, G: Presheaf, H: Presheaf) -> Optional[int]:
    """Compute I_sh(F; H|G) = I_sh(F; G⊕H) - I_sh(F; G).

    Time: 5 × compression_number_time
    """
    GH = coproduct_presheaf(G, H, cat)
    I_total = mutual_compression(cat, topo, F, GH)
    I_FG = mutual_compression(cat, topo, F, G)

    if I_total is None or I_FG is None:
        return None
    return I_total - I_FG


# ============================================================
# Algorithm 4: Chain Rule Verification
# ============================================================

def verify_chain_rule(cat: FiniteCategory, topo: GrothendieckTopology,
                      F: Presheaf, G: Presheaf, H: Presheaf) -> dict:
    """Verify the chain rule I(F; G⊕H) = I(F; G) + I(F; H|G).

    Returns dict with:
        - lhs: I(F; G⊕H)
        - rhs_parts: (I(F;G), I(F;H|G))
        - rhs: I(F;G) + I(F;H|G)
        - verified: bool
        - defect_decomposition: I(F;H|G) == κ_cond(G,H) - κ_cond(F⊕G, H)
    """
    GH = coproduct_presheaf(G, H, cat)
    lhs = mutual_compression(cat, topo, F, GH)
    I_FG = mutual_compression(cat, topo, F, G)
    cmc = conditional_mutual_compression(cat, topo, F, G, H)

    rhs = I_FG + cmc if I_FG is not None and cmc is not None else None

    # Defect decomposition
    ccd_GH = conditional_compression_defect(cat, topo, G, H)
    FG = coproduct_presheaf(F, G, cat)
    ccd_FGH = conditional_compression_defect(cat, topo, FG, H)
    defect_rhs = ccd_GH - ccd_FGH if ccd_GH is not None and ccd_FGH is not None else None

    return {
        "lhs": lhs,
        "I_FG": I_FG,
        "I_cond": cmc,
        "rhs": rhs,
        "chain_rule_verified": lhs == rhs if lhs is not None and rhs is not None else None,
        "defect_lhs": cmc,
        "defect_rhs": defect_rhs,
        "defect_verified": cmc == defect_rhs if cmc is not None and defect_rhs is not None else None,
    }


# ============================================================
# Algorithm 5: Counterexample Search
# ============================================================

def search_counterexamples(cat: FiniteCategory, topo: GrothendieckTopology,
                           max_sections: int = 3) -> dict:
    """Exhaustive search for violations of conjectured properties.

    Tests:
    1. Chain rule: I(F;G⊕H) = I(F;G) + I(F;H|G)
    2. Nonnegativity: I(F;G) ≥ 0
    3. Upper bound: I(F;G) ≤ κ(F)
    4. Conditional nonneg: κ_cond(G,H) ≥ 0
    5. Conditional MI nonneg: I(F;H|G) ≥ 0

    Time: O(max_sections^3 × compression_time)
    """
    violations = {
        "chain_rule": [],
        "nonneg_mutual": [],
        "upper_bound": [],
        "nonneg_cond_defect": [],
        "nonneg_cond_mutual": [],
    }
    total_tested = 0

    value_lists = [list(range(k)) for k in range(1, max_sections + 1)]

    for vF in value_lists:
        for vG in value_lists:
            for vH in value_lists:
                F = Presheaf("F", {X: list(vF) for X in cat.objects})
                G = Presheaf("G", {X: list(vG) for X in cat.objects})
                H = Presheaf("H", {X: list(vH) for X in cat.objects})
                total_tested += 1

                result = verify_chain_rule(cat, topo, F, G, H)

                if result["chain_rule_verified"] is False:
                    violations["chain_rule"].append((len(vF), len(vG), len(vH)))

                I_FG = mutual_compression(cat, topo, F, G)
                if I_FG is not None and I_FG < 0:
                    violations["nonneg_mutual"].append((len(vF), len(vG)))

                kF = compute_compression_number(cat, F, topo)
                if I_FG is not None and kF is not None and I_FG > kF:
                    violations["upper_bound"].append((len(vF), len(vG)))

                ccd = conditional_compression_defect(cat, topo, G, H)
                if ccd is not None and ccd < 0:
                    violations["nonneg_cond_defect"].append((len(vG), len(vH)))

                cmc = conditional_mutual_compression(cat, topo, F, G, H)
                if cmc is not None and cmc < 0:
                    violations["nonneg_cond_mutual"].append((len(vF), len(vG), len(vH)))

    return {
        "total_tested": total_tested,
        "violations": violations,
        "all_clean": all(len(v) == 0 for v in violations.values()),
    }


# ============================================================
# Pre-built categories and topologies
# ============================================================

def arrow_category() -> FiniteCategory:
    """The arrow category: a → b."""
    return FiniteCategory(
        objects=["a", "b"],
        morphisms={("a", "b"): ["f"]}
    )


def triangle_category() -> FiniteCategory:
    """The triangle category: a → b → c, a → c."""
    return FiniteCategory(
        objects=["a", "b", "c"],
        morphisms={("a", "b"): ["f"], ("b", "c"): ["g"], ("a", "c"): ["h"]}
    )


def trivial_topology(cat: FiniteCategory) -> GrothendieckTopology:
    """The trivial topology: only identity sieves cover."""
    covering = {}
    for X in cat.objects:
        covering[X] = [{(X, f"id_{X}")}]
    return GrothendieckTopology("trivial", covering)


def discrete_topology(cat: FiniteCategory) -> GrothendieckTopology:
    """The discrete topology: all sieves generated by all morphisms."""
    covering = {}
    for X in cat.objects:
        all_incoming = set()
        for src in cat.objects:
            for f_name in cat.hom(src, X):
                all_incoming.add((src, f_name))
        covering[X] = [all_incoming] if all_incoming else []
    return GrothendieckTopology("discrete", covering)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    cat = arrow_category()
    topo = trivial_topology(cat)

    F = Presheaf("F", {X: [0, 1] for X in cat.objects})
    G = Presheaf("G", {X: [0, 1, 2] for X in cat.objects})
    H = Presheaf("H", {X: [0, 1] for X in cat.objects})

    print("=== Compression Numbers ===")
    print(f"κ(F) = {compute_compression_number(cat, F, topo)}")
    print(f"κ(G) = {compute_compression_number(cat, G, topo)}")
    print(f"κ(H) = {compute_compression_number(cat, H, topo)}")

    print("\n=== Mutual Compression ===")
    print(f"I(F;G) = {mutual_compression(cat, topo, F, G)}")

    print("\n=== Chain Rule ===")
    result = verify_chain_rule(cat, topo, F, G, H)
    print(f"Chain rule verified: {result['chain_rule_verified']}")
    print(f"Defect decomposition verified: {result['defect_verified']}")

    print("\n=== Counterexample Search ===")
    search = search_counterexamples(cat, topo, max_sections=3)
    print(f"Tested {search['total_tested']} configurations")
    print(f"All properties hold: {search['all_clean']}")
    for prop, viols in search['violations'].items():
        if viols:
            print(f"  VIOLATION in {prop}: {viols}")
