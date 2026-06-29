#!/usr/bin/env python3
"""
applications.py — Real-world applications of sheaf compression subadditivity.

Demonstrates how the subadditivity theorem applies to:
1. Sensor network data fusion
2. Database query optimization
3. Network protocol analysis
"""

from algorithms import (
    FiniteSite, FinitePresheaf, analyze_compression,
    build_coproduct, compute_compression_number
)
from typing import Dict, List


# ────────────────────────────────────────────────────────────────────────────
# Application 1: Sensor Network Data Fusion
# ────────────────────────────────────────────────────────────────────────────

def sensor_network_example():
    """Demonstrate compression of sensor data from overlapping coverage areas.

    Model: A network of sensors covering overlapping regions. Each region
    is an "object" in our category, with morphisms representing containment
    (restriction from larger to smaller regions). Temperature readings and
    humidity readings are two presheaves. Subadditivity tells us that
    monitoring both data streams requires at most as many probe sensors
    as monitoring each separately.
    """
    print("=" * 60)
    print("APPLICATION 1: Sensor Network Data Fusion")
    print("=" * 60)
    print()
    print("Scenario: 4 overlapping sensor regions (A ⊃ B, A ⊃ C, B ∩ C = D)")
    print("Temperature readings (F) and humidity readings (G) are two")
    print("presheaves on this coverage topology.")
    print()

    # Category: regions with containment morphisms
    site = FiniteSite(
        objects=["A", "B", "C", "D"],
        morphisms={
            ("B", "A"): ["incl_BA"],  # B ⊂ A
            ("C", "A"): ["incl_CA"],  # C ⊂ A
            ("D", "B"): ["incl_DB"],  # D ⊂ B
            ("D", "C"): ["incl_DC"],  # D ⊂ C
            ("D", "A"): ["incl_DA"],  # D ⊂ A (composite)
        }
    )

    # Temperature presheaf: sections are possible temperature readings
    temp = FinitePresheaf(
        site=site,
        sections={
            "A": ["cold", "warm", "hot"],
            "B": ["cold", "warm"],
            "C": ["warm", "hot"],
            "D": ["warm"],
        },
        restriction_maps={
            ("incl_BA", "B", "A"): {"cold": "cold", "warm": "warm", "hot": "warm"},
            ("incl_CA", "C", "A"): {"cold": "warm", "warm": "warm", "hot": "hot"},
            ("incl_DB", "D", "B"): {"cold": "warm", "warm": "warm"},
            ("incl_DC", "D", "C"): {"warm": "warm", "hot": "warm"},
            ("incl_DA", "D", "A"): {"cold": "warm", "warm": "warm", "hot": "warm"},
        }
    )

    # Humidity presheaf
    humid = FinitePresheaf(
        site=site,
        sections={
            "A": ["dry", "humid", "wet"],
            "B": ["dry", "humid"],
            "C": ["humid", "wet"],
            "D": ["humid"],
        },
        restriction_maps={
            ("incl_BA", "B", "A"): {"dry": "dry", "humid": "humid", "wet": "humid"},
            ("incl_CA", "C", "A"): {"dry": "humid", "humid": "humid", "wet": "wet"},
            ("incl_DB", "D", "B"): {"dry": "humid", "humid": "humid"},
            ("incl_DC", "D", "C"): {"humid": "humid", "wet": "humid"},
            ("incl_DA", "D", "A"): {"dry": "humid", "humid": "humid", "wet": "humid"},
        }
    )

    result = analyze_compression(temp, humid)

    print(f"Temperature compression: κ(T) = {result.kappa_F}")
    print(f"  Optimal probes: {result.witness_F}")
    print(f"Humidity compression: κ(H) = {result.kappa_G}")
    print(f"  Optimal probes: {result.witness_G}")
    print(f"Joint compression: κ(T⊕H) = {result.kappa_FG}")
    print(f"Savings (defect): {result.defect}")
    print()

    if result.is_strict:
        print("✓ STRICT SUBADDITIVITY: Joint monitoring requires FEWER sensors")
        print(f"  than separate monitoring ({result.kappa_FG} < {result.kappa_F}+{result.kappa_G}={result.kappa_F+result.kappa_G})")
        if result.jointly_admissible:
            print(f"  Shared probe set: {result.jointly_admissible}")
    else:
        print("  Equality: No savings from joint monitoring in this configuration")
    print()


# ────────────────────────────────────────────────────────────────────────────
# Application 2: Database Query Optimization
# ────────────────────────────────────────────────────────────────────────────

def database_query_example():
    """Demonstrate compression for database view covering.

    Model: Database tables as objects, foreign key relationships as morphisms.
    Queries on different tables are presheaves. Subadditivity bounds the
    number of "index probes" needed to resolve combined queries.
    """
    print("=" * 60)
    print("APPLICATION 2: Database Query Optimization")
    print("=" * 60)
    print()
    print("Scenario: Tables Users → Orders → Items with foreign keys.")
    print("Query F resolves user activity patterns.")
    print("Query G resolves item popularity patterns.")
    print()

    site = FiniteSite(
        objects=["Users", "Orders", "Items"],
        morphisms={
            ("Users", "Orders"): ["placed_by"],   # order → user
            ("Orders", "Items"): ["contains"],     # item → order
            ("Users", "Items"): ["purchased"],     # item → user (composite)
        }
    )

    # User activity presheaf
    activity = FinitePresheaf(
        site=site,
        sections={
            "Users": ["active", "inactive", "new"],
            "Orders": ["recent", "old"],
            "Items": ["popular", "niche"],
        },
        restriction_maps={
            ("placed_by", "Users", "Orders"): {"recent": "active", "old": "inactive"},
            ("contains", "Orders", "Items"): {"popular": "recent", "niche": "old"},
            ("purchased", "Users", "Items"): {"popular": "active", "niche": "inactive"},
        }
    )

    # Item popularity presheaf
    popularity = FinitePresheaf(
        site=site,
        sections={
            "Users": ["buyer", "browser"],
            "Orders": ["large", "small"],
            "Items": ["trending", "stable", "declining"],
        },
        restriction_maps={
            ("placed_by", "Users", "Orders"): {"large": "buyer", "small": "browser"},
            ("contains", "Orders", "Items"): {"trending": "large", "stable": "small", "declining": "small"},
            ("purchased", "Users", "Items"): {"trending": "buyer", "stable": "browser", "declining": "browser"},
        }
    )

    result = analyze_compression(activity, popularity)

    print(f"Activity query compression: κ(A) = {result.kappa_F}")
    print(f"  Optimal index probes: {result.witness_F}")
    print(f"Popularity query compression: κ(P) = {result.kappa_G}")
    print(f"  Optimal index probes: {result.witness_G}")
    print(f"Combined query compression: κ(A⊕P) = {result.kappa_FG}")
    print(f"Index savings: {result.defect}")
    print()

    if result.is_strict:
        print("✓ SAVINGS: Combined query needs fewer index probes!")
        print(f"  {result.kappa_FG} probes suffice vs {result.kappa_F+result.kappa_G} separately")
    else:
        print("  No savings: queries probe independent table aspects")
    print()


# ────────────────────────────────────────────────────────────────────────────
# Application 3: Network Protocol Analysis
# ────────────────────────────────────────────────────────────────────────────

def network_protocol_example():
    """Demonstrate compression for network protocol state analysis.

    Model: Protocol layers as objects (Physical, Link, Network, Transport),
    encapsulation as morphisms. Different packet types (control, data) are
    presheaves. Subadditivity bounds the number of inspection points needed.
    """
    print("=" * 60)
    print("APPLICATION 3: Network Protocol Inspection")
    print("=" * 60)
    print()
    print("Scenario: Protocol stack Physical → Link → Network → Transport")
    print("Control packets (F) and data packets (G) need inspection.")
    print()

    site = FiniteSite(
        objects=["Phys", "Link", "Net", "Trans"],
        morphisms={
            ("Phys", "Link"): ["encap_PL"],
            ("Link", "Net"): ["encap_LN"],
            ("Net", "Trans"): ["encap_NT"],
            ("Phys", "Net"): ["encap_PN"],
            ("Link", "Trans"): ["encap_LT"],
            ("Phys", "Trans"): ["encap_PT"],
        }
    )

    # Control packets presheaf
    control = FinitePresheaf(
        site=site,
        sections={
            "Phys": ["signal_a", "signal_b"],
            "Link": ["frame_x", "frame_y", "frame_z"],
            "Net": ["route_1", "route_2"],
            "Trans": ["syn", "ack", "fin"],
        },
        restriction_maps={
            ("encap_PL", "Phys", "Link"): {"frame_x": "signal_a", "frame_y": "signal_a", "frame_z": "signal_b"},
            ("encap_LN", "Link", "Net"): {"route_1": "frame_x", "route_2": "frame_y"},
            ("encap_NT", "Net", "Trans"): {"syn": "route_1", "ack": "route_1", "fin": "route_2"},
            ("encap_PN", "Phys", "Net"): {"route_1": "signal_a", "route_2": "signal_a"},
            ("encap_LT", "Link", "Trans"): {"syn": "frame_x", "ack": "frame_x", "fin": "frame_y"},
            ("encap_PT", "Phys", "Trans"): {"syn": "signal_a", "ack": "signal_a", "fin": "signal_a"},
        }
    )

    # Data packets presheaf
    data = FinitePresheaf(
        site=site,
        sections={
            "Phys": ["raw_0", "raw_1"],
            "Link": ["eth_a", "eth_b"],
            "Net": ["ip_x", "ip_y", "ip_z"],
            "Trans": ["tcp_p", "tcp_q"],
        },
        restriction_maps={
            ("encap_PL", "Phys", "Link"): {"eth_a": "raw_0", "eth_b": "raw_1"},
            ("encap_LN", "Link", "Net"): {"ip_x": "eth_a", "ip_y": "eth_b", "ip_z": "eth_a"},
            ("encap_NT", "Net", "Trans"): {"tcp_p": "ip_x", "tcp_q": "ip_y"},
            ("encap_PN", "Phys", "Net"): {"ip_x": "raw_0", "ip_y": "raw_1", "ip_z": "raw_0"},
            ("encap_LT", "Link", "Trans"): {"tcp_p": "eth_a", "tcp_q": "eth_b"},
            ("encap_PT", "Phys", "Trans"): {"tcp_p": "raw_0", "tcp_q": "raw_1"},
        }
    )

    result = analyze_compression(control, data)

    print(f"Control packet inspection: κ(C) = {result.kappa_F}")
    print(f"  Inspection points: {result.witness_F}")
    print(f"Data packet inspection: κ(D) = {result.kappa_G}")
    print(f"  Inspection points: {result.witness_G}")
    print(f"Combined inspection: κ(C⊕D) = {result.kappa_FG}")
    print(f"Savings: {result.defect} fewer inspection points")
    print()

    if result.is_strict:
        print("✓ SAVINGS: Shared inspection points serve both packet types!")
    else:
        print("  No savings: packet types require independent inspection")
    print()


# ────────────────────────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    sensor_network_example()
    database_query_example()
    network_protocol_example()

    print("=" * 60)
    print("CONCLUSION")
    print("=" * 60)
    print()
    print("In all applications, the subadditivity theorem guarantees:")
    print("  κ_sh(combined) ≤ κ_sh(source_1) + κ_sh(source_2)")
    print()
    print("This means combining data sources NEVER increases the per-source")
    print("cost of observation. When shared structure exists, the cost")
    print("DECREASES — the compression defect measures these savings.")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of sheaf compression subadditivity.

Builds small finite sites, defines presheaves, computes compression numbers,
forms coproducts, and displays whether equality or strict inequality holds.
"""

from itertools import combinations, product as cartesian_product
from typing import Dict, List, Tuple, Set, Optional, FrozenSet
import random


# ────────────────────────────────────────────────────────────────────────────
# Core Data Structures
# ────────────────────────────────────────────────────────────────────────────

class FiniteCategory:
    """A finite category represented by objects and morphisms with composition."""

    def __init__(self, objects: List[str], morphisms: Dict[Tuple[str, str], List[str]]):
        """
        objects: list of object names
        morphisms: dict mapping (source, target) -> list of morphism names
                   Identity morphisms are always implicitly included.
        """
        self.objects = objects
        self.morphisms = morphisms
        # Add identity morphisms
        for obj in objects:
            key = (obj, obj)
            if key not in self.morphisms:
                self.morphisms[key] = [f"id_{obj}"]
            elif f"id_{obj}" not in self.morphisms[key]:
                self.morphisms[key].append(f"id_{obj}")

    def hom(self, source: str, target: str) -> List[str]:
        """Get all morphisms from source to target."""
        return self.morphisms.get((source, target), [])

    def __repr__(self):
        non_id = {k: v for k, v in self.morphisms.items()
                  if k[0] != k[1] or len(v) > 1}
        return f"Category(objects={self.objects}, morphisms={non_id})"


class Presheaf:
    """A presheaf F: C^op -> Set on a finite category."""

    def __init__(self, category: FiniteCategory,
                 sections: Dict[str, List],
                 restrictions: Dict[Tuple[str, str, str], Dict]):
        """
        sections: dict mapping object name -> list of section values
        restrictions: dict mapping (morph_name, source, target) -> {section: section}
                      representing F(f): F(target) -> F(source) for f: source -> target
                      Identity restrictions are implicit.
        """
        self.category = category
        self.sections = sections
        self.restrictions = restrictions

    def obj(self, x: str) -> List:
        """Sections at object x."""
        return self.sections[x]

    def restrict(self, morph: str, source: str, target: str, section) -> object:
        """Apply restriction map F(f)(s) for f: source -> target, s ∈ F(target)."""
        if morph == f"id_{target}" and source == target:
            return section
        key = (morph, source, target)
        if key in self.restrictions:
            return self.restrictions[key].get(section, section)
        return section  # default: identity restriction


class CoprodPresheaf:
    """Pointwise coproduct F ⊕ G of two presheaves."""

    def __init__(self, F: Presheaf, G: Presheaf):
        self.F = F
        self.G = G
        self.category = F.category

    def obj(self, x: str) -> List:
        """Sections: tagged union of F(x) and G(x)."""
        return [("L", s) for s in self.F.obj(x)] + [("R", s) for s in self.G.obj(x)]

    def restrict(self, morph: str, source: str, target: str, section) -> object:
        """Restriction preserves the tag."""
        tag, s = section
        if tag == "L":
            return ("L", self.F.restrict(morph, source, target, s))
        else:
            return ("R", self.G.restrict(morph, source, target, s))


# ────────────────────────────────────────────────────────────────────────────
# Compression Number Computation
# ────────────────────────────────────────────────────────────────────────────

def separates(probe_family: FrozenSet[str], presheaf, category: FiniteCategory) -> bool:
    """Check if a probe family separates the presheaf."""
    for x in category.objects:
        secs = presheaf.obj(x)
        for i, s in enumerate(secs):
            for j in range(i + 1, len(secs)):
                t = secs[j]
                if s == t:
                    continue
                # Check if some probe distinguishes s from t
                distinguished = False
                for z in probe_family:
                    for f in category.hom(z, x):
                        rs = presheaf.restrict(f, z, x, s)
                        rt = presheaf.restrict(f, z, x, t)
                        if rs != rt:
                            distinguished = True
                            break
                    if distinguished:
                        break
                if not distinguished:
                    return False
    return True


def topology_compatible(probe_family: FrozenSet[str],
                        category: FiniteCategory) -> bool:
    """Check topology compatibility with the canonical topology.
    For simplicity, we use the trivial (bottom) topology where only
    the maximal sieve is covering — every probe family with morphisms
    to all objects is compatible."""
    for x in category.objects:
        reachable = False
        for z in probe_family:
            if category.hom(z, x):
                reachable = True
                break
        if not reachable:
            return False
    return True


def compute_kappa_sh(presheaf, category: FiniteCategory) -> int:
    """Compute the sheaf compression number (minimum topology-compatible
    separating probe family size)."""
    n = len(category.objects)
    for k in range(n + 1):
        for subset in combinations(category.objects, k):
            pf = frozenset(subset)
            if separates(pf, presheaf, category) and topology_compatible(pf, category):
                return k
    return n


def find_jointly_admissible(F: Presheaf, G: Presheaf,
                            category: FiniteCategory) -> Optional[FrozenSet[str]]:
    """Find the smallest jointly admissible probe family."""
    n = len(category.objects)
    for k in range(n + 1):
        for subset in combinations(category.objects, k):
            pf = frozenset(subset)
            if (separates(pf, F, category) and
                separates(pf, G, category) and
                topology_compatible(pf, category)):
                return pf
    return None


# ────────────────────────────────────────────────────────────────────────────
# Example Categories and Presheaves
# ────────────────────────────────────────────────────────────────────────────

def arrow_category() -> FiniteCategory:
    """The arrow category: 0 → 1."""
    return FiniteCategory(
        objects=["0", "1"],
        morphisms={("0", "1"): ["f01"]}
    )


def path_category() -> FiniteCategory:
    """Path category: 0 → 1 → 2."""
    return FiniteCategory(
        objects=["0", "1", "2"],
        morphisms={
            ("0", "1"): ["f01"],
            ("1", "2"): ["f12"],
            ("0", "2"): ["f02"],  # composite
        }
    )


def triangle_category() -> FiniteCategory:
    """Triangle category: 0 → 1, 0 → 2, 1 → 2."""
    return FiniteCategory(
        objects=["0", "1", "2"],
        morphisms={
            ("0", "1"): ["f01"],
            ("1", "2"): ["f12"],
            ("0", "2"): ["f02"],
        }
    )


def make_presheaf(category: FiniteCategory,
                  section_sizes: Dict[str, int],
                  seed: Optional[int] = None) -> Presheaf:
    """Create a presheaf with given section sizes and random restrictions."""
    if seed is not None:
        random.seed(seed)
    sections = {}
    for obj in category.objects:
        k = section_sizes.get(obj, 1)
        sections[obj] = list(range(k))

    restrictions = {}
    for (src, tgt), morphs in category.morphisms.items():
        if src == tgt:
            continue
        for m in morphs:
            tgt_secs = sections[tgt]
            src_secs = sections[src]
            if not src_secs:
                continue
            restr = {}
            for s in tgt_secs:
                restr[s] = random.choice(src_secs)
            restrictions[(m, src, tgt)] = restr

    return Presheaf(category, sections, restrictions)


# ────────────────────────────────────────────────────────────────────────────
# Demo
# ────────────────────────────────────────────────────────────────────────────

def demo_subadditivity():
    """Main demonstration of subadditivity."""
    print("=" * 70)
    print("SHEAF COMPRESSION SUBADDITIVITY — DEMONSTRATION")
    print("=" * 70)
    print()
    print("We verify that κ_sh(J, F⊕G) ≤ κ_sh(J,F) + κ_sh(J,G)")
    print("for various finite sites and presheaf pairs.")
    print()

    # ── Example 1: Arrow Category ──
    print("─" * 70)
    print("Example 1: Arrow Category (0 → 1)")
    print("─" * 70)
    cat = arrow_category()
    print(f"Category: {cat.objects}, morphisms: 0 → 1")
    print()

    configs = [
        ({"0": 2, "1": 2}, {"0": 2, "1": 2}),
        ({"0": 3, "1": 2}, {"0": 2, "1": 1}),
        ({"0": 1, "1": 1}, {"0": 2, "1": 3}),
        ({"0": 2, "1": 3}, {"0": 3, "1": 2}),
    ]

    for i, (sF, sG) in enumerate(configs):
        F = make_presheaf(cat, sF, seed=42 + i)
        G = make_presheaf(cat, sG, seed=100 + i)
        coprod = CoprodPresheaf(F, G)

        kF = compute_kappa_sh(F, cat)
        kG = compute_kappa_sh(G, cat)
        kFG = compute_kappa_sh(coprod, cat)
        defect = kF + kG - kFG

        ja = find_jointly_admissible(F, G, cat)
        ja_size = len(ja) if ja else "none"

        print(f"  F sections: {sF}, G sections: {sG}")
        print(f"  κ(F)={kF}, κ(G)={kG}, κ(F⊕G)={kFG}, defect={defect}")
        print(f"  Subadditivity: {kFG} ≤ {kF + kG} {'✓' if kFG <= kF + kG else '✗'}")
        print(f"  {'STRICT' if defect > 0 else 'EQUALITY'}")
        print(f"  Jointly admissible family size: {ja_size}")
        print()

    # ── Example 2: Path Category ──
    print("─" * 70)
    print("Example 2: Path Category (0 → 1 → 2)")
    print("─" * 70)
    cat = path_category()
    print(f"Category: {cat.objects}, morphisms: 0→1, 1→2, 0→2")
    print()

    configs = [
        ({"0": 2, "1": 2, "2": 2}, {"0": 2, "1": 2, "2": 2}),
        ({"0": 3, "1": 2, "2": 1}, {"0": 1, "1": 2, "2": 3}),
        ({"0": 1, "1": 1, "2": 1}, {"0": 2, "1": 2, "2": 2}),
    ]

    for i, (sF, sG) in enumerate(configs):
        F = make_presheaf(cat, sF, seed=200 + i)
        G = make_presheaf(cat, sG, seed=300 + i)
        coprod = CoprodPresheaf(F, G)

        kF = compute_kappa_sh(F, cat)
        kG = compute_kappa_sh(G, cat)
        kFG = compute_kappa_sh(coprod, cat)
        defect = kF + kG - kFG

        print(f"  F sections: {sF}, G sections: {sG}")
        print(f"  κ(F)={kF}, κ(G)={kG}, κ(F⊕G)={kFG}, defect={defect}")
        print(f"  Subadditivity: {kFG} ≤ {kF + kG} {'✓' if kFG <= kF + kG else '✗'}")
        print(f"  {'STRICT' if defect > 0 else 'EQUALITY'}")
        print()

    # ── Example 3: Statistical Test ──
    print("─" * 70)
    print("Example 3: Random Sampling (1000 trials, arrow category)")
    print("─" * 70)
    cat = arrow_category()

    violations = 0
    strict_count = 0
    total = 1000

    for trial in range(total):
        sF = {obj: random.randint(1, 4) for obj in cat.objects}
        sG = {obj: random.randint(1, 4) for obj in cat.objects}
        F = make_presheaf(cat, sF, seed=1000 + trial)
        G = make_presheaf(cat, sG, seed=5000 + trial)
        coprod = CoprodPresheaf(F, G)

        kF = compute_kappa_sh(F, cat)
        kG = compute_kappa_sh(G, cat)
        kFG = compute_kappa_sh(coprod, cat)

        if kFG > kF + kG:
            violations += 1
        if kFG < kF + kG:
            strict_count += 1

    print(f"  Trials: {total}")
    print(f"  Subadditivity violations: {violations}")
    print(f"  Strict inequality: {strict_count}/{total} ({100*strict_count/total:.1f}%)")
    print(f"  Equality: {total - strict_count - violations}/{total} ({100*(total-strict_count-violations)/total:.1f}%)")
    print()

    # ── Summary ──
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("The sheaf compression number κ_sh satisfies subadditivity:")
    print("  κ_sh(J, F⊕G) ≤ κ_sh(J, F) + κ_sh(J, G)")
    print()
    print("This is the geometric analogue of entropy subadditivity.")
    print("The compression defect I_sh(F;G) = κ(F)+κ(G)-κ(F⊕G) ≥ 0")
    print("measures shared probe structure (geometric mutual information).")
    print()
    print("Strict inequality is GENERIC — most presheaf pairs share probe")
    print("structure, enabling joint compression savings.")


if __name__ == "__main__":
    demo_subadditivity()
