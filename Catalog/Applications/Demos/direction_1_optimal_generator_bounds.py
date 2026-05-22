#!/usr/bin/env python3
"""
Real-world applications of categorical sparsity theory.

This module demonstrates how optimal generator bounds apply to:
1. Database schema compression (minimal keys)
2. Sensor placement optimization
3. Signal reconstruction from sparse measurements
4. Codebook design for communication

Each application shows how the abstract theory of primitive sections
and representable covers maps to practical problems.
"""

from __future__ import annotations
from algorithms import (
    FiniteCategory, Presheaf, compute_primitive_sections,
    compute_primitive_count, greedy_cover, exact_min_cover,
    total_sections, restriction_dependency_graph, compression_ratio
)


# =============================================================================
# Application 1: Database Schema Compression
# =============================================================================

def database_example():
    """Model a database projection system as a presheaf.

    Consider a database with attributes {Name, Age, City, ZipCode}.
    Projections correspond to morphisms in a category:
      {Name,Age,City,Zip} → {Name,Age} (project away City,Zip)
      {Name,Age,City,Zip} → {City,Zip} (project away Name,Age)
      etc.

    A tuple in the full table restricts to tuples in projected tables.
    Primitive sections are tuples that cannot be recovered from any projection.
    """
    print("=" * 60)
    print("APPLICATION 1: Database Schema Compression")
    print("=" * 60)

    # Model as chain: full → projection1 → projection2
    # Object 0: most projected (1 attribute)
    # Object 1: partial projection (2 attributes)
    # Object 2: full table (3 attributes)

    cat = FiniteCategory(
        objects=[0, 1, 2],
        morphisms={
            (0, 0): ["id_0"], (1, 1): ["id_1"], (2, 2): ["id_2"],
            (0, 1): ["proj_01"], (0, 2): ["proj_02"], (1, 2): ["proj_12"],
            (1, 0): [], (2, 0): [], (2, 1): [],
        },
        identity={0: "id_0", 1: "id_1", 2: "id_2"},
        composition={
            ("id_0", "id_0"): "id_0", ("id_1", "id_1"): "id_1",
            ("id_2", "id_2"): "id_2",
            ("proj_01", "id_0"): "proj_01", ("id_1", "proj_01"): "proj_01",
            ("proj_12", "id_1"): "proj_12", ("id_2", "proj_12"): "proj_12",
            ("proj_02", "id_0"): "proj_02", ("id_2", "proj_02"): "proj_02",
            ("proj_01", "proj_12"): "proj_02",
            # Trivial compositions with identities
            ("proj_12", "proj_01"): "proj_02",  # Not valid, but we keep chain
        }
    )

    # Fibers: projected views of a small database
    # Object 2 (full): {Alice-25-NYC, Bob-30-LA, Charlie-25-NYC}
    # Object 1 (partial): {Alice-25, Bob-30, Charlie-25} → {25, 30} after dedup
    # Object 0 (minimal): {young, old} → {y, o}

    F = Presheaf(
        category=cat,
        fibers={
            0: ["y", "o"],
            1: ["A25", "B30", "C25"],
            2: ["Alice-NYC", "Bob-LA", "Charlie-NYC"],
        },
        restriction={
            "id_0": lambda x: x, "id_1": lambda x: x, "id_2": lambda x: x,
            "proj_01": lambda x: "y" if x in ["A25", "C25"] else "o",
            "proj_12": lambda x: {"Alice-NYC": "A25", "Bob-LA": "B30", "Charlie-NYC": "C25"}[x],
            "proj_02": lambda x: {"Alice-NYC": "y", "Bob-LA": "o", "Charlie-NYC": "y"}[x],
        }
    )

    prims = compute_primitive_sections(F)
    pc = compute_primitive_count(F)
    ts = total_sections(F)
    gc = greedy_cover(F)
    em = exact_min_cover(F)

    print(f"\n  Database model: 3-level projection hierarchy")
    print(f"  Level 0 (most projected): {F.fibers[0]}")
    print(f"  Level 1 (partial):        {F.fibers[1]}")
    print(f"  Level 2 (full table):     {F.fibers[2]}")
    print(f"\n  Total tuples across all views: {ts}")
    print(f"  Primitive tuples (minimal keys): {pc}")
    print(f"  Primitive sections by level:")
    for Y in cat.objects:
        print(f"    Level {Y}: {prims[Y]}")
    print(f"\n  Minimum generators needed: {em}")
    print(f"  Compression: {ts} → {em} ({100*(1-em/ts):.0f}% reduction)")
    print(f"\n  Interpretation: Only {em} independent data items are needed to")
    print(f"  reconstruct all {ts} tuples across all projection levels.")
    print()


# =============================================================================
# Application 2: Sensor Placement
# =============================================================================

def sensor_placement_example():
    """Model optimal sensor placement as minimum cover.

    Consider a monitoring network where sensors at different locations
    observe overlapping regions. A sensor at location Z can observe
    phenomena at location Y if there's a "line of sight" morphism Y → Z.

    The presheaf assigns observable states to each location.
    Primitive sections are states that can only be observed locally.
    The minimum cover gives the minimum number of sensors needed.
    """
    print("=" * 60)
    print("APPLICATION 2: Optimal Sensor Placement")
    print("=" * 60)

    # Diamond topology: 4 locations
    # Location 3 (hilltop) can observe locations 1 and 2
    # Location 1 can observe location 0
    # Location 2 can observe location 0
    cat = FiniteCategory(
        objects=[0, 1, 2, 3],
        morphisms={
            (a, b): [] for a in range(4) for b in range(4)
        },
        identity={i: f"id_{i}" for i in range(4)},
        composition={}
    )
    # Add morphisms
    all_mor = [
        (0, 0, "id_0"), (1, 1, "id_1"), (2, 2, "id_2"), (3, 3, "id_3"),
        (0, 1, "obs_01"), (0, 2, "obs_02"), (0, 3, "obs_03"),
        (1, 3, "obs_13"), (2, 3, "obs_23"),
    ]
    for a, b, name in all_mor:
        cat.morphisms[(a, b)] = cat.morphisms.get((a, b), [])
        if name not in cat.morphisms[(a, b)]:
            cat.morphisms[(a, b)].append(name)

    # Composition
    for a, b, name in all_mor:
        cat.composition[(name, f"id_{a}")] = name
        cat.composition[(f"id_{b}", name)] = name
    cat.composition[("obs_13", "obs_01")] = "obs_03"
    cat.composition[("obs_23", "obs_02")] = "obs_03"

    # Each location has 3 possible states: normal, warning, critical
    states = ["normal", "warning", "critical"]
    F = Presheaf(
        category=cat,
        fibers={i: list(states) for i in range(4)},
        restriction={
            f"id_{i}": lambda x: x for i in range(4)
        }
    )
    # Restriction: observing from higher vantage points
    F.restriction["obs_01"] = lambda x: x
    F.restriction["obs_02"] = lambda x: x
    F.restriction["obs_03"] = lambda x: x
    F.restriction["obs_13"] = lambda x: x
    F.restriction["obs_23"] = lambda x: x

    prims = compute_primitive_sections(F)
    pc = compute_primitive_count(F)
    ts = total_sections(F)
    gc = greedy_cover(F)
    em = exact_min_cover(F)

    print(f"\n  Sensor network: diamond topology (4 locations)")
    print(f"  Each location has 3 possible states: {states}")
    print(f"\n  Total observable states: {ts}")
    print(f"  Primitive (locally-unique) states: {pc}")
    print(f"  Minimum sensors needed: {em}")
    print(f"  Greedy placement: {len(gc)} sensors at {[g[0] for g in gc[:5]]}...")
    print(f"\n  Insight: Sensors at high-vantage locations (3) can observe")
    print(f"  lower locations (1,2), reducing the total sensors needed.")
    print()


# =============================================================================
# Application 3: Compression Ratio Analysis
# =============================================================================

def compression_analysis():
    """Analyze how morphism density affects compression ratio.

    Compare categories with different morphism densities to show that
    more morphisms → more restriction dependencies → better compression.
    """
    print("=" * 60)
    print("APPLICATION 3: Compression vs Morphism Density")
    print("=" * 60)

    results = []

    # Discrete (0 non-identity morphisms)
    cat_disc = FiniteCategory(
        objects=[0, 1, 2, 3],
        morphisms={(a, b): [f"id_{a}"] if a == b else []
                   for a in range(4) for b in range(4)},
        identity={i: f"id_{i}" for i in range(4)},
        composition={(f"id_{i}", f"id_{i}"): f"id_{i}" for i in range(4)}
    )
    F_disc = Presheaf(cat_disc,
        {i: [0, 1, 2] for i in range(4)},
        {f"id_{i}": lambda x: x for i in range(4)})
    results.append(("Discrete(4)", 0, compression_ratio(F_disc),
                     exact_min_cover(F_disc), total_sections(F_disc)))

    # Path: 0→1→2→3 (3 non-identity morphisms)
    cat_path = FiniteCategory(
        objects=[0, 1, 2, 3],
        morphisms={(a, b): [] for a in range(4) for b in range(4)},
        identity={i: f"id_{i}" for i in range(4)},
        composition={}
    )
    for i in range(4):
        cat_path.morphisms[(i, i)] = [f"id_{i}"]
        cat_path.composition[(f"id_{i}", f"id_{i}")] = f"id_{i}"
    for a in range(4):
        for b in range(a+1, 4):
            name = f"f_{a}_{b}"
            cat_path.morphisms[(a, b)] = [name]
            cat_path.composition[(name, f"id_{a}")] = name
            cat_path.composition[(f"id_{b}", name)] = name
    for a in range(4):
        for b in range(a+1, 4):
            for c in range(b+1, 4):
                cat_path.composition[(f"f_{b}_{c}", f"f_{a}_{b}")] = f"f_{a}_{c}"

    F_path = Presheaf(cat_path,
        {i: [0, 1, 2] for i in range(4)},
        {f"id_{i}": lambda x: x for i in range(4)})
    for a in range(4):
        for b in range(a+1, 4):
            F_path.restriction[f"f_{a}_{b}"] = lambda x: x
    results.append(("Chain(4)", 6, compression_ratio(F_path),
                     exact_min_cover(F_path), total_sections(F_path)))

    print(f"\n  {'Category':<20} {'Non-id mor':>10} {'Ratio':>8} {'MinCover':>9} {'Total':>6}")
    print("  " + "-" * 55)
    for name, mor, ratio, mc, ts in results:
        print(f"  {name:<20} {mor:>10} {ratio:>8.3f} {mc:>9} {ts:>6}")

    print(f"\n  Key insight: More morphisms create more dependencies,")
    print(f"  reducing the number of primitive (irreducible) sections.")
    print(f"  This is the categorical analogue of sparse coding: richer")
    print(f"  structure enables better compression.")
    print()


# =============================================================================
# Application 4: Codebook Design
# =============================================================================

def codebook_example():
    """Model codebook design as representable cover optimization.

    In communication, a codebook maps messages to codewords.
    The presheaf models how codewords restrict/project across channels.
    Primitive sections correspond to independently distinguishable codewords.
    """
    print("=" * 60)
    print("APPLICATION 4: Codebook Design")
    print("=" * 60)

    # Two channels with different resolutions
    # Channel 0: low resolution (2 symbols)
    # Channel 1: high resolution (4 symbols)
    # Morphism 0 → 1: refinement

    cat = FiniteCategory(
        objects=[0, 1],
        morphisms={(0, 0): ["id_0"], (1, 1): ["id_1"],
                   (0, 1): ["refine"], (1, 0): []},
        identity={0: "id_0", 1: "id_1"},
        composition={
            ("id_0", "id_0"): "id_0", ("id_1", "id_1"): "id_1",
            ("refine", "id_0"): "refine", ("id_1", "refine"): "refine",
        }
    )

    # Low-res channel: {A, B}
    # High-res channel: {A1, A2, B1, B2}
    # Refinement restriction: A1,A2 → A; B1,B2 → B
    F = Presheaf(cat,
        {0: ["A", "B"], 1: ["A1", "A2", "B1", "B2"]},
        {
            "id_0": lambda x: x, "id_1": lambda x: x,
            "refine": lambda x: {"A1": "A", "A2": "A", "B1": "B", "B2": "B"}[x],
        }
    )

    prims = compute_primitive_sections(F)
    pc = compute_primitive_count(F)
    ts = total_sections(F)
    em = exact_min_cover(F)

    print(f"\n  Two-channel codebook:")
    print(f"  Low-res channel:  {F.fibers[0]}")
    print(f"  High-res channel: {F.fibers[1]}")
    print(f"\n  Total codewords: {ts}")
    print(f"  Primitive codewords: {pc}")
    for Y in cat.objects:
        print(f"    Channel {Y}: {prims[Y]}")
    print(f"  Minimum codebook size: {em}")
    print(f"\n  Insight: Low-res symbols A,B are generated by restricting")
    print(f"  high-res symbols, so they are NOT primitive. Only the")
    print(f"  high-res symbols are primitive generators of the codebook.")
    print()


def main():
    print("\n" + "=" * 60)
    print("  CATEGORICAL SPARSITY: Real-World Applications")
    print("=" * 60 + "\n")

    database_example()
    sensor_placement_example()
    compression_analysis()
    codebook_example()

    print("=" * 60)
    print("  SUMMARY")
    print("=" * 60)
    print("""
  Categorical sparsity theory provides a unified framework for:

  1. DATABASE COMPRESSION: Primitive sections = minimal keys.
     Only irreducible tuples need storage; the rest are projections.

  2. SENSOR PLACEMENT: Minimum covers = optimal sensor locations.
     High-vantage sensors observe multiple locations via restriction.

  3. SIGNAL COMPRESSION: Compression ratio decreases with morphism
     density — richer categorical structure enables better compression.

  4. CODEBOOK DESIGN: Primitive codewords = independent symbols.
     Coarse symbols are generated by restricting fine ones.

  The universal bound n*m is tight for discrete categories (no structure).
  Real categories with morphisms achieve strictly better compression.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Interactive exploration of categorical sparsity and optimal generator bounds.

This demo computes primitive sections, greedy cover sizes, and exact minimal
representable cover sizes for small finite categories and presheaves.
It also visualizes the restriction dependency graph.

Usage:
    python demo.py
"""

from __future__ import annotations
import itertools
from dataclasses import dataclass, field
from typing import Callable
from algorithms import (
    FiniteCategory, Presheaf, compute_primitive_sections,
    compute_primitive_count, greedy_cover, exact_min_cover,
    total_sections, compression_ratio
)


def make_discrete(n: int) -> FiniteCategory:
    """Discrete category with n objects (only identity morphisms)."""
    objects = list(range(n))
    morphisms: dict[tuple[int,int], list[str]] = {}
    for a in objects:
        morphisms[(a, a)] = [f"id_{a}"]
    identity = {a: f"id_{a}" for a in objects}
    comp: dict[tuple[str,str], str] = {}
    for a in objects:
        comp[(f"id_{a}", f"id_{a}")] = f"id_{a}"
    return FiniteCategory(objects, morphisms, identity, comp)


def make_chain(n: int) -> FiniteCategory:
    """Linear order 0 < 1 < ... < n-1 as a category."""
    objects = list(range(n))
    morphisms: dict[tuple[int,int], list[str]] = {}
    identity = {}
    comp: dict[tuple[str,str], str] = {}

    # Generate morphism names for a ≤ b
    def mor_name(a: int, b: int) -> str:
        if a == b:
            return f"id_{a}"
        return f"f_{a}_{b}"

    for a in objects:
        identity[a] = f"id_{a}"
        for b in objects:
            if a <= b:
                morphisms[(a, b)] = [mor_name(a, b)]
            else:
                morphisms[(a, b)] = []

    # Composition
    for a in objects:
        for b in objects:
            for c in objects:
                if a <= b <= c:
                    comp[(mor_name(b, c), mor_name(a, b))] = mor_name(a, c)

    return FiniteCategory(objects, morphisms, identity, comp)


def make_diamond() -> FiniteCategory:
    """Diamond poset: 0 < 1, 0 < 2, 1 < 3, 2 < 3."""
    objects = [0, 1, 2, 3]
    # Morphisms from Hasse + transitivity + identities
    # 0→0, 0→1, 0→2, 0→3, 1→1, 1→3, 2→2, 2→3, 3→3
    morphisms: dict[tuple[int,int], list[str]] = {
        (a, b): [] for a in objects for b in objects
    }
    all_mor = [
        (0, 0, "id_0"), (1, 1, "id_1"), (2, 2, "id_2"), (3, 3, "id_3"),
        (0, 1, "f_01"), (0, 2, "f_02"), (0, 3, "f_03"),
        (1, 3, "f_13"), (2, 3, "f_23"),
    ]
    for a, b, name in all_mor:
        morphisms[(a, b)].append(name)

    identity = {i: f"id_{i}" for i in objects}

    # Build composition table
    comp: dict[tuple[str,str], str] = {}
    # id compositions
    for a, b, name in all_mor:
        comp[(name, f"id_{a}")] = name
        comp[(f"id_{b}", name)] = name
    # Non-trivial compositions
    comp[("f_13", "f_01")] = "f_03"
    comp[("f_23", "f_02")] = "f_03"

    return FiniteCategory(objects, morphisms, identity, comp)


def constant_presheaf(cat: FiniteCategory, m: int) -> Presheaf:
    """Constant presheaf assigning Fin(m) = {0,...,m-1} to every object."""
    fibers = {Y: list(range(m)) for Y in cat.objects}
    restriction: dict[str, Callable] = {}
    for (a, b), mors in cat.morphisms.items():
        for mor in mors:
            restriction[mor] = lambda x, _a=a, _b=b: x  # identity on values
    return Presheaf(cat, fibers, restriction)


def injective_chain_presheaf(n: int, m: int) -> Presheaf:
    """Presheaf on chain 0<1<...<n-1 where restriction is identity (injective).
    All fibers have size m."""
    cat = make_chain(n)
    fibers = {Y: list(range(m)) for Y in cat.objects}
    restriction: dict[str, Callable] = {}
    for (a, b), mors in cat.morphisms.items():
        for mor in mors:
            restriction[mor] = lambda x: x
    return Presheaf(cat, fibers, restriction)


def collapsing_chain_presheaf() -> Presheaf:
    """Chain 0<1<2 where F(2)={0,1,2}, F(1)={0,1}, F(0)={0},
    restriction 2→1 sends {0,1}↦{0,1}, 2↦0,
    restriction 1→0 sends {0,1}↦0."""
    cat = make_chain(3)
    fibers = {0: [0], 1: [0, 1], 2: [0, 1, 2]}
    restriction = {
        "id_0": lambda x: x,
        "id_1": lambda x: x,
        "id_2": lambda x: x,
        "f_0_1": lambda x: 0,
        "f_1_2": lambda x: min(x, 1),
        "f_0_2": lambda x: 0,
    }
    return Presheaf(cat, fibers, restriction)


def print_separator():
    print("=" * 70)


def analyze_presheaf(name: str, F: Presheaf):
    """Full analysis of a presheaf."""
    print(f"\n{'─' * 60}")
    print(f"  {name}")
    print(f"{'─' * 60}")

    n_obj = len(F.category.objects)
    ts = total_sections(F)
    prims = compute_primitive_sections(F)
    pc = compute_primitive_count(F)
    greedy = greedy_cover(F)
    exact = exact_min_cover(F)

    print(f"  Objects: {n_obj}")
    print(f"  Fibers: {F.fibers}")
    print(f"  Total sections:     {ts}")
    print(f"  Primitive count:    {pc}")
    print(f"  Greedy cover size:  {len(greedy)}")
    print(f"  Exact min cover:    {exact}")
    print(f"  Compression ratio:  {compression_ratio(F):.3f}")
    print(f"  Universal bound:    {n_obj * max((len(v) for v in F.fibers.values()), default=0)}")
    print()

    # Print primitive sections
    for Y in F.category.objects:
        prim_at_Y = prims.get(Y, [])
        all_at_Y = F.fibers[Y]
        print(f"  Object {Y}: sections={all_at_Y}, primitive={prim_at_Y}")

    # Print greedy cover
    print(f"\n  Greedy cover generators:")
    for obj, sec in greedy:
        print(f"    ({obj}, {sec})")
    print()


def main():
    print_separator()
    print("  CATEGORICAL SPARSITY: Optimal Generator Bounds")
    print("  Interactive Demo")
    print_separator()

    # === Discrete categories ===
    print("\n\n▶ DISCRETE CATEGORIES")
    print("  (No non-identity morphisms — every section is primitive)")

    for n in [1, 2, 3, 5]:
        for m in [1, 2, 3]:
            cat = make_discrete(n)
            F = constant_presheaf(cat, m)
            analyze_presheaf(f"Discrete({n}), constant fiber size {m}", F)

    # === Chain categories ===
    print("\n\n▶ CHAIN CATEGORIES (linear orders)")
    print("  (Restriction along order creates dependencies)")

    # Constant presheaf on chain
    for n in [2, 3, 4]:
        cat = make_chain(n)
        F = constant_presheaf(cat, 2)
        analyze_presheaf(f"Chain({n}), constant fiber size 2", F)

    # Collapsing chain
    F_collapse = collapsing_chain_presheaf()
    analyze_presheaf("Chain(3), collapsing presheaf", F_collapse)

    # Injective chain presheaf
    for n in [2, 3]:
        F_inj = injective_chain_presheaf(n, 3)
        analyze_presheaf(f"Chain({n}), injective presheaf, fiber size 3", F_inj)

    # === Diamond ===
    print("\n\n▶ DIAMOND POSET")
    cat = make_diamond()
    F_diamond = constant_presheaf(cat, 2)
    analyze_presheaf("Diamond, constant fiber size 2", F_diamond)

    # === Summary table ===
    print_separator()
    print("  SUMMARY TABLE")
    print_separator()
    print(f"  {'Category':<25} {'n':>3} {'m':>3} {'Total':>6} {'Prim':>6} {'Greedy':>6} {'Exact':>6} {'n*m':>6} {'Ratio':>7}")
    print("  " + "-" * 70)

    test_cases = [
        ("Discrete(3)", make_discrete(3), 2),
        ("Discrete(5)", make_discrete(5), 3),
        ("Chain(3)", make_chain(3), 2),
        ("Chain(4)", make_chain(4), 2),
        ("Diamond", make_diamond(), 2),
    ]

    for name, cat, m in test_cases:
        F = constant_presheaf(cat, m)
        n_obj = len(cat.objects)
        ts = total_sections(F)
        pc = compute_primitive_count(F)
        g = len(greedy_cover(F))
        ex = exact_min_cover(F)
        cr = compression_ratio(F)
        print(f"  {name:<25} {n_obj:>3} {m:>3} {ts:>6} {pc:>6} {g:>6} {ex:>6} {n_obj*m:>6} {cr:>7.3f}")

    print()
    print_separator()
    print("  KEY FINDINGS:")
    print("  • Discrete categories: minCover = totalSections (no compression)")
    print("  • Chain categories: constant presheaves have significant compression")
    print("  • Diamond poset: additional compression from branching structure")
    print("  • Universal bound n*m is tight only for discrete categories")
    print_separator()


if __name__ == "__main__":
    main()
