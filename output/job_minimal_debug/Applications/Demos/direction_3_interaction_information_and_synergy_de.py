#!/usr/bin/env python3
"""
Applications of Categorical Interaction Information
=====================================================

Demonstrates real-world applications of the interaction information
framework for presheaves on finite sites:

1. Secret Sharing Detection
2. Distributed Sensor Fusion
3. Information Decomposition Analysis
4. Positivity Barrier Analysis

Each application constructs concrete presheaf triples and computes
information-theoretic quantities to illustrate the theorems.
"""

from __future__ import annotations
from typing import Dict, Set, Tuple, List
from itertools import combinations, product as iterproduct


# ═══════════════════════════════════════════════════════════════════════
#  Lightweight Presheaf Framework (self-contained)
# ═══════════════════════════════════════════════════════════════════════

class Category:
    """Minimal finite category."""
    def __init__(self, name: str, objects: list, morphisms: dict):
        self.name = name
        self.objects = objects
        self.morphisms = morphisms  # {src: {tgt: [morph_names]}}

    def hom(self, src, tgt):
        return self.morphisms.get(src, {}).get(tgt, [])

    def all_morphisms(self):
        for s in self.objects:
            for t in self.objects:
                for f in self.hom(s, t):
                    yield (s, t, f)


class Presheaf:
    """Presheaf on a finite category."""
    def __init__(self, name: str, cat: Category,
                 sections: dict, restriction: dict):
        self.name = name
        self.cat = cat
        self.sections = sections  # {obj: set_of_sections}
        self.restriction = restriction  # {(src,tgt,f): {sec: sec}}

    def restrict(self, src, tgt, f, sec):
        return self.restriction[(src, tgt, f)][sec]


def coprod(F: Presheaf, G: Presheaf) -> Presheaf:
    """Coproduct F ⊕ G."""
    sections = {}
    restriction = {}
    for obj in F.cat.objects:
        sections[obj] = {f"L:{s}" for s in F.sections[obj]} | \
                         {f"R:{s}" for s in G.sections[obj]}
    for src, tgt, f in F.cat.all_morphisms():
        rmap = {}
        for s in F.sections[tgt]:
            rmap[f"L:{s}"] = f"L:{F.restrict(src, tgt, f, s)}"
        for s in G.sections[tgt]:
            rmap[f"R:{s}"] = f"R:{G.restrict(src, tgt, f, s)}"
        restriction[(src, tgt, f)] = rmap
    return Presheaf(f"({F.name}⊕{G.name})", F.cat, sections, restriction)


def kappa(cat: Category, F: Presheaf) -> int:
    """Sheaf compression number with topology compatibility."""
    n = len(cat.objects)
    for size in range(n + 1):
        for combo in combinations(cat.objects, size):
            probes = set(combo)
            # Topology compatibility: probes reach every object
            if not all(any(cat.hom(p, obj) for p in probes)
                       for obj in cat.objects):
                continue
            # Separation check
            ok = True
            for obj in cat.objects:
                secs = sorted(F.sections[obj])
                for i in range(len(secs)):
                    for j in range(i+1, len(secs)):
                        separated = False
                        for p in probes:
                            for f in cat.hom(p, obj):
                                if F.restrict(p, obj, f, secs[i]) != \
                                   F.restrict(p, obj, f, secs[j]):
                                    separated = True
                                    break
                            if separated:
                                break
                        if not separated:
                            ok = False
                            break
                    if not ok:
                        break
                if not ok:
                    break
            if ok:
                return size
    return n


def I_mutual(cat, F, G):
    """Mutual compression I(F;G)."""
    return kappa(cat, F) + kappa(cat, G) - kappa(cat, coprod(F, G))


def I_interaction(cat, F, G, H):
    """Interaction compression I(F;G;H)."""
    return I_mutual(cat, F, G) + I_mutual(cat, F, H) - \
           I_mutual(cat, F, coprod(G, H))


def I_conditional(cat, F, G, H):
    """Conditional mutual compression I(F;H|G)."""
    return I_mutual(cat, F, coprod(G, H)) - I_mutual(cat, F, G)


# ═══════════════════════════════════════════════════════════════════════
#  Standard Categories
# ═══════════════════════════════════════════════════════════════════════

def arrow_cat():
    return Category("Arrow", ["0", "1"],
                    {"0": {"0": ["id0"], "1": ["f"]},
                     "1": {"1": ["id1"]}})

def triangle_cat():
    return Category("Triangle", ["0", "1", "2"],
                    {"0": {"0": ["id0"], "1": ["f01"], "2": ["f02"]},
                     "1": {"1": ["id1"], "2": ["f12"]},
                     "2": {"2": ["id2"]}})


def make_arrow(name, s0, s1, rmap):
    """Create presheaf on arrow category."""
    cat = arrow_cat()
    sections = {"0": set(s0), "1": set(s1)}
    restriction = {
        ("0", "0", "id0"): {s: s for s in s0},
        ("1", "1", "id1"): {s: s for s in s1},
        ("0", "1", "f"): rmap,
    }
    return Presheaf(name, cat, sections, restriction)


# ═══════════════════════════════════════════════════════════════════════
#  Application 1: Secret Sharing Detection
# ═══════════════════════════════════════════════════════════════════════

def app_secret_sharing():
    """Detect secret-sharing-like patterns in presheaf triples.

    In a 2-of-2 secret sharing scheme:
    - Secret F cannot be recovered from share G alone: I(F;G) = 0
    - Secret F cannot be recovered from share H alone: I(F;H) = 0
    - Both shares together recover the secret: I(F;G⊕H) > 0

    We search for presheaf triples satisfying these conditions.
    """
    print("Application 1: Secret Sharing Detection")
    print("-" * 45)

    cat = arrow_cat()
    base = ["0", "1", "2"]

    # Search for secret-sharing patterns
    found = []
    for s0_F in range(1, 4):
        for s1_F in range(1, 4):
            sec0_F = base[:s0_F]
            sec1_F = base[:s1_F]
            for rmap_F in iterproduct(sec0_F, repeat=s1_F):
                F = make_arrow("F", sec0_F, sec1_F,
                               dict(zip(sec1_F, rmap_F)))
                for s0_G in range(1, 3):
                    for s1_G in range(1, 3):
                        sec0_G = base[:s0_G]
                        sec1_G = base[:s1_G]
                        for rmap_G in iterproduct(sec0_G, repeat=s1_G):
                            G = make_arrow("G", sec0_G, sec1_G,
                                           dict(zip(sec1_G, rmap_G)))
                            iFG = I_mutual(cat, F, G)
                            if iFG != 0:
                                continue
                            for s0_H in range(1, 3):
                                for s1_H in range(1, 3):
                                    sec0_H = base[:s0_H]
                                    sec1_H = base[:s1_H]
                                    for rmap_H in iterproduct(
                                            sec0_H, repeat=s1_H):
                                        H = make_arrow(
                                            "H", sec0_H, sec1_H,
                                            dict(zip(sec1_H, rmap_H)))
                                        iFH = I_mutual(cat, F, H)
                                        if iFH != 0:
                                            continue
                                        iFGH = I_mutual(
                                            cat, F, coprod(G, H))
                                        if iFGH > 0:
                                            found.append(
                                                (s0_F, s1_F, rmap_F,
                                                 s0_G, s1_G, rmap_G,
                                                 s0_H, s1_H, rmap_H,
                                                 iFGH))

    print(f"  Secret-sharing patterns found: {len(found)}")
    if found:
        print("  Examples (first 5):")
        for item in found[:5]:
            print(f"    F({item[0]},{item[1]}), G({item[3]},{item[4]}), "
                  f"H({item[6]},{item[7]}): I(F;G⊕H)={item[9]}")
    else:
        print("  No secret-sharing patterns found at this scale.")
        print("  This is consistent with the positivity barrier on the")
        print("  arrow category: the topology forces enough overlap that")
        print("  perfect privacy (I(F;G)=0) with joint recovery (I(F;G⊕H)>0)")
        print("  cannot coexist.")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  Application 2: Distributed Sensor Fusion
# ═══════════════════════════════════════════════════════════════════════

def app_sensor_fusion():
    """Model distributed sensor fusion as presheaf information.

    Consider sensors G and H observing a signal F.
    Interaction information I(F;G;H) reveals:
    - Positive: sensors are redundant (overlapping coverage)
    - Zero: sensors are independent (complementary coverage)
    - Negative: sensors are synergistic (jointly more than sum)
    """
    print("Application 2: Distributed Sensor Fusion")
    print("-" * 45)

    cat = arrow_cat()

    # Signal: 3 distinct states at source, mapped to 2 at target
    F = make_arrow("Signal", ["s0", "s1", "s2"], ["t0", "t1"],
                   {"t0": "s0", "t1": "s1"})

    # Sensor G: captures coarse-grained view
    G = make_arrow("Sensor_G", ["g0", "g1"], ["gx"],
                   {"gx": "g0"})

    # Sensor H: captures different coarse-grained view
    H = make_arrow("Sensor_H", ["h0", "h1"], ["hy"],
                   {"hy": "h0"})

    kF = kappa(cat, F)
    kG = kappa(cat, G)
    kH = kappa(cat, H)
    iFG = I_mutual(cat, F, G)
    iFH = I_mutual(cat, F, H)
    iFGH_val = I_interaction(cat, F, G, H)

    print(f"  Signal F: κ = {kF}")
    print(f"  Sensor G: κ = {kG}")
    print(f"  Sensor H: κ = {kH}")
    print(f"  I(Signal; Sensor_G) = {iFG}")
    print(f"  I(Signal; Sensor_H) = {iFH}")
    print(f"  I(Signal; G; H) = {iFGH_val}")

    if iFGH_val > 0:
        print("  → Sensors are REDUNDANT: fusing adds less than sum")
    elif iFGH_val == 0:
        print("  → Sensors are INDEPENDENT: fusing adds exactly sum")
    else:
        print("  → Sensors are SYNERGISTIC: fusing creates new information")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  Application 3: Information Decomposition
# ═══════════════════════════════════════════════════════════════════════

def app_information_decomposition():
    """Decompose joint information into redundancy, unique, and synergy.

    For a triple (F, G, H), the information that G⊕H carries about F
    decomposes as:
      I(F; G⊕H) = I(F;G) + I(F;H|G)    [chain rule]

    The interaction information I(F;G;H) = I(F;H) - I(F;H|G) measures
    how much conditioning on G changes H's contribution.
    """
    print("Application 3: Information Decomposition")
    print("-" * 45)

    cat = arrow_cat()

    # Various presheaf configurations
    configs = [
        ("Identical", ("a", "b"), ("x", "y"), {"x": "a", "y": "b"},
                       ("a", "b"), ("x", "y"), {"x": "a", "y": "b"},
                       ("a", "b"), ("x", "y"), {"x": "a", "y": "b"}),
        ("F=G, H indep", ("a", "b"), ("x", "y"), {"x": "a", "y": "b"},
                         ("a", "b"), ("x", "y"), {"x": "a", "y": "b"},
                         ("p", "q"), ("u",), {"u": "p"}),
        ("All different", ("a", "b", "c"), ("x", "y"), {"x": "a", "y": "b"},
                          ("p", "q"), ("u",), {"u": "p"},
                          ("r", "s"), ("v",), {"v": "r"}),
    ]

    for label, s0F, s1F, rmF, s0G, s1G, rmG, s0H, s1H, rmH in configs:
        F = make_arrow("F", s0F, s1F, rmF)
        G = make_arrow("G", s0G, s1G, rmG)
        H = make_arrow("H", s0H, s1H, rmH)

        iFG = I_mutual(cat, F, G)
        iFH = I_mutual(cat, F, H)
        iFGH_joint = I_mutual(cat, F, coprod(G, H))
        cond = I_conditional(cat, F, G, H)
        interaction = I_interaction(cat, F, G, H)

        print(f"\n  Config: {label}")
        print(f"    I(F;G)     = {iFG}")
        print(f"    I(F;H)     = {iFH}")
        print(f"    I(F;G⊕H)  = {iFGH_joint}")
        print(f"    I(F;H|G)   = {cond}")
        print(f"    I(F;G;H)   = {interaction}")
        print(f"    Chain rule: I(F;G⊕H) = I(F;G) + I(F;H|G) → "
              f"{iFGH_joint} = {iFG} + {cond} = {iFG + cond} "
              f"{'✓' if iFGH_joint == iFG + cond else '✗'}")
        print(f"    Identity:   I(F;G;H) = I(F;H) - I(F;H|G) → "
              f"{interaction} = {iFH} - {cond} = {iFH - cond} "
              f"{'✓' if interaction == iFH - cond else '✗'}")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  Application 4: Positivity Barrier Analysis
# ═══════════════════════════════════════════════════════════════════════

def app_positivity_barrier():
    """Analyze when and why interaction information stays nonneg.

    On the arrow category with minimal topology, we observe that
    interaction information is always ≥ 0 for small section sizes.
    This application explores the structural reasons.
    """
    print("Application 4: Positivity Barrier Analysis")
    print("-" * 45)

    cat = arrow_cat()

    # Compute distribution of interaction values
    base = ["0", "1"]
    values = {}
    total = 0

    for s0F in range(1, 3):
        for s1F in range(1, 3):
            secF0 = base[:s0F]; secF1 = base[:s1F]
            for rmF in iterproduct(secF0, repeat=s1F):
                F = make_arrow("F", secF0, secF1, dict(zip(secF1, rmF)))
                for s0G in range(1, 3):
                    for s1G in range(1, 3):
                        secG0 = base[:s0G]; secG1 = base[:s1G]
                        for rmG in iterproduct(secG0, repeat=s1G):
                            G = make_arrow("G", secG0, secG1,
                                           dict(zip(secG1, rmG)))
                            for s0H in range(1, 3):
                                for s1H in range(1, 3):
                                    secH0 = base[:s0H]; secH1 = base[:s1H]
                                    for rmH in iterproduct(
                                            secH0, repeat=s1H):
                                        H = make_arrow("H", secH0, secH1,
                                                       dict(zip(secH1, rmH)))
                                        val = I_interaction(cat, F, G, H)
                                        values[val] = values.get(val, 0) + 1
                                        total += 1

    print(f"\n  Distribution of I(F;G;H) over {total} triples:")
    for v in sorted(values.keys()):
        pct = 100 * values[v] / total
        bar = "█" * int(pct / 2)
        print(f"    I = {v:3d}: {values[v]:6d} ({pct:5.1f}%) {bar}")

    min_val = min(values.keys())
    max_val = max(values.keys())
    print(f"\n  Range: [{min_val}, {max_val}]")
    if min_val >= 0:
        print("  ✓ POSITIVITY BARRIER CONFIRMED at this scale!")
        print("  All interaction information values are nonneg.")
    else:
        print(f"  ⚡ Negative values found! Min = {min_val}")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  Main
# ═══════════════════════════════════════════════════════════════════════

def main():
    print("=" * 55)
    print("  Applications of Categorical Interaction Information")
    print("=" * 55)
    print()

    app_secret_sharing()
    app_sensor_fusion()
    app_information_decomposition()
    app_positivity_barrier()

    print("=" * 55)
    print("  All applications complete.")
    print("=" * 55)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Interaction Information and Synergy Detection for Presheaves on Finite Sites
=============================================================================

This demo constructs sample presheaf triples on small finite categories,
computes pairwise and ternary interaction compression quantities, and
explores synergy phenomena.

The key definitions mirror the formally verified Lean development:
  - sheafCompressionNumber: minimum probe set size separating sections
    AND compatible with the Grothendieck topology
  - mutualCompression: I(F;G) = κ(F) + κ(G) - κ(F⊕G)
  - interactionCompression: I(F;G;H) = I(F;G) + I(F;H) - I(F;G⊕H)
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Dict, List, Set, Tuple, Optional
from itertools import product as iterproduct, combinations


# ═══════════════════════════════════════════════════════════════════════
#  Category and Presheaf Definitions
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class FiniteCategory:
    """A finite category specified by objects, morphisms, and composition."""
    name: str
    objects: List[str]
    # morphisms[src][tgt] = list of morphism names
    morphisms: Dict[str, Dict[str, List[str]]]

    def all_morphisms(self) -> List[Tuple[str, str, str]]:
        """Return all (src, tgt, morphism_name) triples."""
        result = []
        for src in self.objects:
            for tgt in self.objects:
                for f in self.morphisms.get(src, {}).get(tgt, []):
                    result.append((src, tgt, f))
        return result

    def morphisms_from_to(self, src: str, tgt: str) -> List[str]:
        return self.morphisms.get(src, {}).get(tgt, [])


def arrow_category() -> FiniteCategory:
    """The arrow category: two objects 0 → 1 with identity morphisms."""
    return FiniteCategory(
        name="Arrow (0 → 1)",
        objects=["0", "1"],
        morphisms={
            "0": {"0": ["id_0"], "1": ["f"]},
            "1": {"1": ["id_1"]},
        },
    )


def triangle_category() -> FiniteCategory:
    """The triangle category: 0 → 1 → 2, 0 → 2."""
    return FiniteCategory(
        name="Triangle (0 → 1 → 2)",
        objects=["0", "1", "2"],
        morphisms={
            "0": {"0": ["id_0"], "1": ["f01"], "2": ["f02"]},
            "1": {"1": ["id_1"], "2": ["f12"]},
            "2": {"2": ["id_2"]},
        },
    )


# ═══════════════════════════════════════════════════════════════════════
#  Presheaf on a Finite Category
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class FinitePresheaf:
    """A presheaf F: C^op → Set on a finite category.

    sections[obj] = set of section values at that object
    restriction[(src, tgt, f)] maps sections at tgt to sections at src
    (contravariant: a morphism src → tgt gives a map F(tgt) → F(src))
    """
    name: str
    category: FiniteCategory
    sections: Dict[str, Set[str]]
    restriction: Dict[Tuple[str, str, str], Dict[str, str]]

    def restrict(self, src: str, tgt: str, f: str, section: str) -> str:
        """Apply restriction map F(f): F(tgt) → F(src)."""
        return self.restriction[(src, tgt, f)][section]


def coproduct_presheaf(F: FinitePresheaf, G: FinitePresheaf) -> FinitePresheaf:
    """Pointwise coproduct (disjoint union) F ⊕ G."""
    cat = F.category
    sections = {}
    restriction = {}
    for obj in cat.objects:
        sections[obj] = {f"L:{s}" for s in F.sections[obj]} | \
                         {f"R:{s}" for s in G.sections[obj]}
    for src, tgt, f in cat.all_morphisms():
        rmap = {}
        for s in F.sections[tgt]:
            rmap[f"L:{s}"] = f"L:{F.restrict(src, tgt, f, s)}"
        for s in G.sections[tgt]:
            rmap[f"R:{s}"] = f"R:{G.restrict(src, tgt, f, s)}"
        restriction[(src, tgt, f)] = rmap
    return FinitePresheaf(
        name=f"({F.name} ⊕ {G.name})",
        category=cat,
        sections=sections,
        restriction=restriction,
    )


# ═══════════════════════════════════════════════════════════════════════
#  Sheaf Compression Number (with topology compatibility)
# ═══════════════════════════════════════════════════════════════════════

def probes_separate(cat: FiniteCategory, F: FinitePresheaf,
                    probe_set: Set[str]) -> bool:
    """Check if a probe set separates all sections of F.

    Probes separate F if for every object X and every pair of distinct
    sections s ≠ t at X, there exists a probe Z in the set and a morphism
    Z → X such that F(f)(s) ≠ F(f)(t).
    """
    for obj in cat.objects:
        secs = sorted(F.sections[obj])
        for i in range(len(secs)):
            for j in range(i + 1, len(secs)):
                s, t = secs[i], secs[j]
                separated = False
                for probe in probe_set:
                    for f_name in cat.morphisms_from_to(probe, obj):
                        if F.restrict(probe, obj, f_name, s) != \
                           F.restrict(probe, obj, f_name, t):
                            separated = True
                            break
                    if separated:
                        break
                if not separated:
                    return False
    return True


def topology_compatible(cat: FiniteCategory, probe_set: Set[str]) -> bool:
    """Check if a probe set is compatible with the minimal Grothendieck topology.

    In the minimal topology, the only covering sieve of any object X is the
    maximal sieve (all morphisms into X). Topology compatibility requires
    that for every object X, there exists a probe Z in the set and a morphism
    Z → X. This ensures the probes "reach" every object.
    """
    for obj in cat.objects:
        reachable = False
        for probe in probe_set:
            if cat.morphisms_from_to(probe, obj):
                reachable = True
                break
        if not reachable:
            return False
    return True


def sheaf_compression_number(cat: FiniteCategory,
                              F: FinitePresheaf) -> int:
    """Compute the sheaf compression number κ(F).

    The minimum number of probe objects needed to BOTH:
    1. Separate all sections of F
    2. Be compatible with the Grothendieck topology (reach all objects)
    """
    objects = cat.objects
    n = len(objects)
    for size in range(0, n + 1):
        for probe_combo in combinations(range(n), size):
            probe_set = {objects[i] for i in probe_combo}
            if topology_compatible(cat, probe_set) and \
               probes_separate(cat, F, probe_set):
                return size
    return n


def mutual_compression(cat: FiniteCategory,
                        F: FinitePresheaf, G: FinitePresheaf) -> int:
    """Compute mutual compression I(F;G) = κ(F) + κ(G) - κ(F⊕G)."""
    kF = sheaf_compression_number(cat, F)
    kG = sheaf_compression_number(cat, G)
    kFG = sheaf_compression_number(cat, coproduct_presheaf(F, G))
    return kF + kG - kFG


def conditional_mutual_compression(cat: FiniteCategory,
                                    F: FinitePresheaf,
                                    G: FinitePresheaf,
                                    H: FinitePresheaf) -> int:
    """Compute conditional mutual compression I(F;H|G) = I(F;G⊕H) - I(F;G)."""
    return mutual_compression(cat, F, coproduct_presheaf(G, H)) - \
           mutual_compression(cat, F, G)


def interaction_compression(cat: FiniteCategory,
                             F: FinitePresheaf,
                             G: FinitePresheaf,
                             H: FinitePresheaf) -> int:
    """Compute interaction compression I(F;G;H) = I(F;G) + I(F;H) - I(F;G⊕H)."""
    iFG = mutual_compression(cat, F, G)
    iFH = mutual_compression(cat, F, H)
    iFGH = mutual_compression(cat, F, coproduct_presheaf(G, H))
    return iFG + iFH - iFGH


# ═══════════════════════════════════════════════════════════════════════
#  Presheaf Constructors
# ═══════════════════════════════════════════════════════════════════════

def make_constant_presheaf(cat: FiniteCategory, name: str,
                            values: Set[str]) -> FinitePresheaf:
    """Constant presheaf with the same set at every object."""
    sections = {obj: set(values) for obj in cat.objects}
    restriction = {}
    for src, tgt, f in cat.all_morphisms():
        restriction[(src, tgt, f)] = {v: v for v in values}
    return FinitePresheaf(name=name, category=cat,
                          sections=sections, restriction=restriction)


def make_arrow_presheaf(name: str, sec0: Set[str], sec1: Set[str],
                         rmap: Dict[str, str]) -> FinitePresheaf:
    """Presheaf on the arrow category with given sections and restriction."""
    cat = arrow_category()
    sections = {"0": set(sec0), "1": set(sec1)}
    restriction = {
        ("0", "0", "id_0"): {s: s for s in sec0},
        ("1", "1", "id_1"): {s: s for s in sec1},
        ("0", "1", "f"): rmap,
    }
    return FinitePresheaf(name=name, category=cat,
                          sections=sections, restriction=restriction)


# ═══════════════════════════════════════════════════════════════════════
#  Brute-Force Search
# ═══════════════════════════════════════════════════════════════════════

def enumerate_arrow_presheaves(max_sections: int = 3) -> List[FinitePresheaf]:
    """Enumerate presheaves on the arrow category with bounded section sizes."""
    presheaves = []
    base = [str(i) for i in range(max_sections)]
    for size0 in range(1, max_sections + 1):
        for size1 in range(1, max_sections + 1):
            sec0 = set(base[:size0])
            sec1 = set(base[:size1])
            sec1_list = sorted(sec1)
            sec0_list = sorted(sec0)
            for mapping in iterproduct(sec0_list, repeat=len(sec1_list)):
                rmap = dict(zip(sec1_list, mapping))
                name = f"P({size0},{size1})"
                P = make_arrow_presheaf(name, sec0, sec1, rmap)
                presheaves.append(P)
    return presheaves


def search_negative_interaction(max_sections: int = 3,
                                 verbose: bool = True) -> Tuple:
    """Search for presheaf triples with negative interaction information."""
    cat = arrow_category()
    presheaves = enumerate_arrow_presheaves(max_sections)
    n = len(presheaves)
    if verbose:
        print(f"  Searching {n} presheaves (max sections = {max_sections})...")

    negative_examples = []
    synergy_witnesses = []
    total_checked = 0
    for i in range(n):
        for j in range(n):
            for k in range(j, n):
                total_checked += 1
                F, G, H = presheaves[i], presheaves[j], presheaves[k]
                iFG = mutual_compression(cat, F, G)
                iFH = mutual_compression(cat, F, H)
                iFGH = mutual_compression(cat, F, coproduct_presheaf(G, H))
                val = iFG + iFH - iFGH
                if val < 0:
                    negative_examples.append((F, G, H, val, iFG, iFH, iFGH))
                    if iFG == 0 and iFH == 0 and iFGH > 0:
                        synergy_witnesses.append((F, G, H, val))

    return negative_examples, synergy_witnesses, total_checked


# ═══════════════════════════════════════════════════════════════════════
#  Main Demo
# ═══════════════════════════════════════════════════════════════════════

def main():
    print("=" * 72)
    print("  Interaction Information & Synergy Detection for Presheaves")
    print("  on Finite Sites — Computational Demo")
    print("=" * 72)

    cat = arrow_category()

    # ── Part 1: Basic Computation ──
    print("\n── Part 1: Basic Information Quantities ──\n")
    print(f"Category: {cat.name}")
    print(f"Objects: {cat.objects}")

    F = make_constant_presheaf(cat, "F_const", {"a", "b"})
    G = make_constant_presheaf(cat, "G_const", {"x", "y"})
    H = make_constant_presheaf(cat, "H_const", {"p", "q"})

    kF = sheaf_compression_number(cat, F)
    kG = sheaf_compression_number(cat, G)
    kH = sheaf_compression_number(cat, H)
    print(f"\nCompression numbers:")
    print(f"  κ(F) = {kF}, κ(G) = {kG}, κ(H) = {kH}")

    iFG = mutual_compression(cat, F, G)
    iFH = mutual_compression(cat, F, H)
    GH = coproduct_presheaf(G, H)
    iFGH = mutual_compression(cat, F, GH)
    interaction = iFG + iFH - iFGH

    print(f"\nMutual compressions:")
    print(f"  I(F;G)   = {iFG}")
    print(f"  I(F;H)   = {iFH}")
    print(f"  I(F;G⊕H) = {iFGH}")
    print(f"\nInteraction information:")
    print(f"  I(F;G;H) = {iFG} + {iFH} - {iFGH} = {interaction}")

    if interaction < 0:
        print("  ⚡ SYNERGY DETECTED!")
    elif interaction > 0:
        print("  📊 REDUNDANCY: Components share overlapping information.")
    else:
        print("  ⚖️  INDEPENDENCE: Components contribute independently.")

    # ── Part 2: Chain Rule Verification ──
    print("\n\n── Part 2: Chain Rule Identity Verification ──\n")

    F = make_arrow_presheaf("F", {"a", "b"}, {"x", "y"},
                             {"x": "a", "y": "b"})
    G = make_arrow_presheaf("G", {"p", "q"}, {"u", "v"},
                             {"u": "p", "v": "q"})
    H = make_arrow_presheaf("H", {"r", "s"}, {"w"},
                             {"w": "r"})

    iFG = mutual_compression(cat, F, G)
    iFH = mutual_compression(cat, F, H)
    iFGH_joint = mutual_compression(cat, F, coproduct_presheaf(G, H))
    cond_HG = iFGH_joint - iFG  # I(F;H|G)
    interaction = iFG + iFH - iFGH_joint

    print(f"F sections: 0→{sorted(F.sections['0'])}, 1→{sorted(F.sections['1'])}")
    print(f"G sections: 0→{sorted(G.sections['0'])}, 1→{sorted(G.sections['1'])}")
    print(f"H sections: 0→{sorted(H.sections['0'])}, 1→{sorted(H.sections['1'])}")

    print(f"\nChain rule: I(F;G⊕H) = I(F;G) + I(F;H|G)")
    print(f"  LHS: {iFGH_joint}")
    print(f"  RHS: {iFG} + {cond_HG} = {iFG + cond_HG}")
    ok1 = iFGH_joint == iFG + cond_HG
    print(f"  {'✓ Verified!' if ok1 else '✗ FAILED'}")

    print(f"\nInteraction identity: I(F;G;H) = I(F;H) - I(F;H|G)")
    print(f"  LHS: {interaction}")
    print(f"  RHS: {iFH} - {cond_HG} = {iFH - cond_HG}")
    ok2 = interaction == iFH - cond_HG
    print(f"  {'✓ Verified!' if ok2 else '✗ FAILED'}")

    print(f"\nSymmetric identity: I(F;G;H) = I(F;G) - I(F;G|H)")
    iFHG_joint = mutual_compression(cat, F, coproduct_presheaf(H, G))
    cond_GH = iFHG_joint - iFH  # I(F;G|H)
    print(f"  LHS: {interaction}")
    print(f"  RHS: {iFG} - {cond_GH} = {iFG - cond_GH}")
    ok3 = interaction == iFG - cond_GH
    print(f"  {'✓ Verified!' if ok3 else '✗ FAILED'}")

    # ── Part 3: Brute-Force Search ──
    print("\n\n── Part 3: Brute-Force Search for Synergy ──\n")

    for max_sec in [2, 3]:
        neg_ex, syn_wit, total = search_negative_interaction(max_sec)
        print(f"\n  Results for max_sections = {max_sec}:")
        print(f"    Total triples checked: {total}")
        print(f"    Negative interaction instances: {len(neg_ex)}")
        print(f"    XOR-synergy witnesses (I(F;G)=0, I(F;H)=0, I(F;G⊕H)>0): {len(syn_wit)}")

        if neg_ex:
            print(f"\n    Sample negative instances:")
            seen = set()
            count = 0
            for F, G, H, val, iFG, iFH, iFGH in neg_ex[:10]:
                key = (val, iFG, iFH, iFGH)
                if key not in seen:
                    seen.add(key)
                    print(f"      I(F;G)={iFG}, I(F;H)={iFH}, "
                          f"I(F;G⊕H)={iFGH} → I(F;G;H)={val}")
                    count += 1
                    if count >= 5:
                        break

        if syn_wit:
            print(f"\n    ⚡ XOR-SYNERGY WITNESSES FOUND!")
            for F, G, H, val in syn_wit[:3]:
                print(f"      I(F;G)=0, I(F;H)=0, I(F;G⊕H)>0 → I(F;G;H)={val}")
        else:
            print(f"\n    No XOR-synergy witnesses at this scale.")

        if not neg_ex:
            print(f"\n    ⚖️  Positivity barrier: all interaction ≥ 0 at this scale.")

    # ── Part 4: Secret Sharing Interpretation ──
    print("\n\n── Part 4: Secret Sharing Interpretation ──\n")
    print("The SynergyWitness / SecretSharingWitness structure captures:")
    print()
    print("  In a 2-of-2 secret sharing scheme:")
    print("  • The secret F cannot be recovered from share G alone: I(F;G) = 0")
    print("  • The secret F cannot be recovered from share H alone: I(F;H) = 0")
    print("  • Joint shares reconstruct the secret: I(F;G⊕H) > 0")
    print()
    print("  Our formally verified theorem proves:")
    print("  SecretSharingWitness F G H → interactionCompression F G H < 0")
    print()
    print("  Equivalently: I(F;H|G) > I(F;H)")
    print("  Observing G 'unlocks' information about H that was previously")
    print("  invisible — the hallmark of synergy / emergence.")
    print()
    print("  This connects presheaf information theory to:")
    print("  • Cryptography: threshold schemes (Shamir, Blakley)")
    print("  • Neuroscience: population codes / integrated information")
    print("  • Distributed computing: coordination complexity")
    print("  • Physics: entanglement and contextuality")

    # ── Part 5: Information Decomposition Summary ──
    print("\n\n── Part 5: Information Decomposition Summary ──\n")
    print("For any presheaf triple (F, G, H):")
    print()
    print("  I(F;G;H) > 0  →  REDUNDANCY")
    print("    G and H provide overlapping information about F.")
    print("    Conditioning on one reduces the other's contribution.")
    print()
    print("  I(F;G;H) = 0  →  INDEPENDENCE")
    print("    G and H contribute non-overlapping information.")
    print("    Joint observation = sum of individual observations.")
    print()
    print("  I(F;G;H) < 0  →  SYNERGY")
    print("    G and H create emergent information about F.")
    print("    Joint observation exceeds sum of parts.")
    print("    Conditioning on one INCREASES the other's contribution.")

    print("\n" + "=" * 72)
    print("  Demo complete.")
    print("=" * 72)


if __name__ == "__main__":
    main()
