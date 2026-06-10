#!/usr/bin/env python3
"""
Applications of Probe Complexity Theory

This module demonstrates real-world applications of probe complexity:
1. State machine distinguishability — how many test inputs separate states?
2. Sensor network design — minimum sensors to identify system behavior
3. Protocol verification — minimum observations to distinguish protocols
"""

from algorithms import (
    FiniteCategory, ExhaustiveProbeSearch, GreedyProbeSearch,
    ProfileCapacityChecker, DistinguishingSetAnalysis,
    make_discrete, make_parallel_arrows, make_cyclic_monoid,
    make_disjoint_union
)
import math


def state_machine_example():
    """
    Application 1: State Machine Distinguishability

    Consider a finite state machine where:
    - Objects = states
    - Morphisms = state transitions (possibly multiple per pair)
    - Probe = a test input applied at a state

    Probe complexity tells us the minimum number of "test states"
    needed to fully distinguish all transitions.
    """
    print("=" * 60)
    print("Application 1: State Machine Distinguishability")
    print("=" * 60)
    print()
    print("A state machine with states {A, B, C} and transitions:")
    print("  A→A: stay_A, loop_A (two distinct self-transitions)")
    print("  A→B: go_AB")
    print("  B→B: stay_B")
    print("  C→C: stay_C, loop_C")
    print()

    objects = ["A", "B", "C"]
    hom_sets = {
        ("A", "A"): ["stay_A", "loop_A"],
        ("A", "B"): ["go_AB"],
        ("B", "B"): ["stay_B"],
        ("C", "C"): ["stay_C", "loop_C"],
    }
    # Compositions
    comp = {}
    # Identities
    comp[("stay_A", "stay_A")] = "stay_A"
    comp[("stay_A", "loop_A")] = "loop_A"
    comp[("loop_A", "stay_A")] = "loop_A"
    comp[("loop_A", "loop_A")] = "stay_A"  # loop² = id
    comp[("go_AB", "stay_A")] = "go_AB"
    comp[("go_AB", "loop_A")] = "go_AB"
    comp[("stay_B", "go_AB")] = "go_AB"
    comp[("stay_B", "stay_B")] = "stay_B"
    comp[("stay_C", "stay_C")] = "stay_C"
    comp[("stay_C", "loop_C")] = "loop_C"
    comp[("loop_C", "stay_C")] = "loop_C"
    comp[("loop_C", "loop_C")] = "stay_C"

    identity = {"A": "stay_A", "B": "stay_B", "C": "stay_C"}
    cat = FiniteCategory(objects, hom_sets, comp, identity)

    searcher = ExhaustiveProbeSearch(cat)
    pc, probes = searcher.search()

    print(f"Probe complexity = {pc}")
    print(f"Optimal test states: {probes}")
    print()
    print("Interpretation: To distinguish all state transitions,")
    print(f"we need to observe behavior from {pc} test state(s).")
    print(f"Testing from states {probes} is sufficient.")

    # Verify information-theoretic bound
    checker = ProfileCapacityChecker(cat)
    ok, details = checker.check_bound(probes)
    print(f"\nInformation-theoretic bound: {'SATISFIED ✓' if ok else 'VIOLATED ✗'}")
    for d in details:
        if d["hom_size"] > 1:
            bits_needed = math.log2(d["hom_size"])
            bits_available = math.log2(d["capacity"]) if d["capacity"] > 0 else 0
            print(f"  Hom({d['src']},{d['tgt']}): {d['hom_size']} morphisms, "
                  f"need {bits_needed:.1f} bits, have {bits_available:.1f} bits")
    print()


def sensor_network_example():
    """
    Application 2: Sensor Network Design

    Consider a network of n components, each with observable behaviors.
    A sensor placed at component Z can observe how signals from Z
    propagate through the network. The probe complexity tells us
    the minimum number of sensors needed.
    """
    print("=" * 60)
    print("Application 2: Sensor Network Design")
    print("=" * 60)
    print()

    # Model: 4 network nodes, each node's behavior is described
    # by a monoid of signal transformations
    print("Network with 4 independent components,")
    print("each having 2 possible signal transformations.")
    print()

    cat = make_disjoint_union([make_cyclic_monoid(2)] * 4)
    searcher = ExhaustiveProbeSearch(cat)
    pc, probes = searcher.search()

    print(f"Number of components: {cat.n_objects}")
    print(f"Total behaviors: {cat.n_morphisms}")
    print(f"Minimum sensors needed: {pc}")
    print(f"Sensor placement: {probes}")
    print()

    greedy = GreedyProbeSearch(cat)
    gpc, gprobes = greedy.search()
    print(f"Greedy approximation: {gpc} sensors at {gprobes}")
    print(f"Approximation ratio: {gpc/pc:.2f}")
    print()

    # Now with a more connected network (shared morphisms)
    print("Connected network (single Z/8Z monoid):")
    cat2 = make_cyclic_monoid(8)
    pc2, probes2 = ExhaustiveProbeSearch(cat2).search()
    print(f"  Behaviors: {cat2.n_morphisms}")
    print(f"  Minimum sensors: {pc2}")
    print(f"  (Only 1 node, so 1 sensor suffices)")
    print()


def protocol_verification_example():
    """
    Application 3: Protocol Verification

    Different communication protocols may appear identical unless
    observed from specific vantage points. Probe complexity gives
    the minimum number of observation points needed.
    """
    print("=" * 60)
    print("Application 3: Protocol Distinguishability")
    print("=" * 60)
    print()

    # 3 endpoints with multiple protocol variants between some pairs
    objects = ["client", "server", "cache"]
    hom_sets = {
        ("client", "client"): ["id_c"],
        ("server", "server"): ["id_s"],
        ("cache", "cache"): ["id_k"],
        ("client", "server"): ["http", "https", "grpc"],
        ("server", "cache"): ["redis_get", "redis_set"],
        ("client", "cache"): ["direct_read"],
    }
    comp = {
        ("id_c", "id_c"): "id_c",
        ("id_s", "id_s"): "id_s",
        ("id_k", "id_k"): "id_k",
    }
    for p in ["http", "https", "grpc"]:
        comp[(p, "id_c")] = p
        comp[("id_s", p)] = p
    for p in ["redis_get", "redis_set"]:
        comp[(p, "id_s")] = p
        comp[("id_k", p)] = p
    comp[("direct_read", "id_c")] = "direct_read"
    comp[("id_k", "direct_read")] = "direct_read"
    # Compositions through server
    for p in ["http", "https", "grpc"]:
        for q in ["redis_get", "redis_set"]:
            comp[(q, p)] = f"{q}_via_{p}"
            hom_sets.setdefault(("client", "cache"), [])
            if f"{q}_via_{p}" not in hom_sets[("client", "cache")]:
                hom_sets[("client", "cache")].append(f"{q}_via_{p}")
            comp[(f"{q}_via_{p}", "id_c")] = f"{q}_via_{p}"
            comp[("id_k", f"{q}_via_{p}")] = f"{q}_via_{p}"

    identity = {"client": "id_c", "server": "id_s", "cache": "id_k"}
    cat = FiniteCategory(objects, hom_sets, comp, identity)

    searcher = ExhaustiveProbeSearch(cat)
    pc, probes = searcher.search()

    print(f"Endpoints: {objects}")
    print(f"Protocol variants: {cat.n_morphisms} total")
    print(f"Minimum observation points: {pc}")
    print(f"Observe from: {probes}")
    print()

    analyzer = DistinguishingSetAnalysis(cat)
    summary = analyzer.summary()
    print(f"Distinguishing analysis:")
    print(f"  Morphism pairs to separate: {summary['n_pairs']}")
    print(f"  Min distinguishing multiplicity: {summary['min_multiplicity']}")
    print(f"  Forced observation points: {summary['hitting_set_lb']}")
    print()

    # Information content analysis
    checker = ProfileCapacityChecker(cat)
    print("Information budget per hom-set:")
    for (src, tgt), morphs in cat.hom_sets.items():
        if len(morphs) > 1:
            bits_needed = math.log2(len(morphs))
            bits_available = checker.information_content(probes, src, tgt)
            print(f"  Hom({src},{tgt}): {len(morphs)} variants, "
                  f"need {bits_needed:.2f} bits, have {bits_available:.2f} bits")
    print()


def scaling_analysis():
    """
    Scaling Analysis: How does probe complexity grow with category size?
    """
    print("=" * 60)
    print("Scaling Analysis: Probe Complexity vs Category Size")
    print("=" * 60)
    print()

    print(f"{'Category':<30} {'|Ob|':>5} {'|Mor|':>6} {'PC':>4} "
          f"{'PC/n':>6} {'log₂n':>6}")
    print("─" * 65)

    categories = []

    # Discrete categories
    for n in [2, 4, 8, 16]:
        cat = make_discrete(n)
        categories.append((f"Discrete({n})", cat))

    # Parallel arrows
    for k in [2, 4, 8]:
        cat = make_parallel_arrows(k)
        categories.append((f"Arrows({k})", cat))

    # Monoids
    for n in [2, 3, 4, 6]:
        cat = make_cyclic_monoid(n)
        categories.append((f"Z/{n}Z", cat))

    # Disjoint unions
    for k in [2, 3, 4]:
        cat = make_disjoint_union([make_cyclic_monoid(2)] * k)
        categories.append((f"{k}×Z/2Z", cat))

    for name, cat in categories:
        pc, _ = ExhaustiveProbeSearch(cat).search()
        n = cat.n_objects
        ratio = f"{pc/n:.2f}" if n > 0 else "N/A"
        logn = f"{math.log2(n):.2f}" if n > 1 else "0.00"
        print(f"  {name:<28} {n:>5} {cat.n_morphisms:>6} {pc:>4} "
              f"{ratio:>6} {logn:>6}")

    print()
    print("Key finding: Probe complexity is determined by the 'separability")
    print("structure' — categories with isolated nontrivial components")
    print("require one probe per component (linear), while connected")
    print("categories with rich morphism structure often need few probes.")


if __name__ == "__main__":
    state_machine_example()
    print()
    sensor_network_example()
    print()
    protocol_verification_example()
    print()
    scaling_analysis()


#!/usr/bin/env python3
"""
Probe Complexity of Finite Categories — Demo

This script demonstrates the probe complexity theory by computing
probe complexity for various small finite categories and visualizing
the results.

A finite category C has objects and morphisms. A probe family P ⊆ Ob(C)
separates morphisms if: for any f ≠ g : X → Y, there exists Z ∈ P and
h : Z → X such that h∘f ≠ h∘g. The probe complexity is the minimum
size of such a family.
"""

import itertools
from typing import Dict, List, Tuple, Set, Optional
import math


class FiniteCategory:
    """
    A finite category represented by:
    - objects: list of object names
    - morphisms: dict mapping (source, target) to list of morphism names
    - composition: dict mapping (f, g) to f∘g (where g : A→B, f : B→C)
    - identity: dict mapping object to its identity morphism name
    """

    def __init__(self, objects, morphisms, composition, identity):
        self.objects = list(objects)
        self.morphisms = morphisms  # (src, tgt) -> [morph_names]
        self.composition = composition  # (f, g) -> result
        self.identity = identity  # obj -> id_morph

    def hom(self, src, tgt) -> list:
        """Return list of morphisms from src to tgt."""
        return self.morphisms.get((src, tgt), [])

    def compose(self, f, g):
        """Compose f after g (g then f)."""
        return self.composition[(f, g)]

    def __repr__(self):
        n_obj = len(self.objects)
        n_morph = sum(len(v) for v in self.morphisms.values())
        return f"FiniteCategory({n_obj} objects, {n_morph} morphisms)"


def discrete_category(n: int) -> FiniteCategory:
    """The discrete category on n objects (only identity morphisms)."""
    objects = list(range(n))
    morphisms = {(i, i): [f"id_{i}"] for i in objects}
    composition = {(f"id_{i}", f"id_{i}"): f"id_{i}" for i in objects}
    identity = {i: f"id_{i}" for i in objects}
    return FiniteCategory(objects, morphisms, composition, identity)


def parallel_arrows_category(n_arrows: int) -> FiniteCategory:
    """Category with 2 objects and n parallel arrows from 0 to 1."""
    objects = [0, 1]
    arrows = [f"f_{i}" for i in range(n_arrows)]
    morphisms = {
        (0, 0): ["id_0"],
        (1, 1): ["id_1"],
        (0, 1): arrows,
    }
    composition = {}
    # id ∘ id = id
    composition[("id_0", "id_0")] = "id_0"
    composition[("id_1", "id_1")] = "id_1"
    # f_i ∘ id_0 = f_i
    for f in arrows:
        composition[(f, "id_0")] = f
        composition[("id_1", f)] = f
    identity = {0: "id_0", 1: "id_1"}
    return FiniteCategory(objects, morphisms, composition, identity)


def monoid_category(elements: list, mult_table: dict) -> FiniteCategory:
    """
    A single-object category (monoid).
    elements: list of element names (first should be identity)
    mult_table: dict mapping (a, b) to a*b
    """
    objects = [0]
    morphisms = {(0, 0): elements}
    composition = {(a, b): mult_table[(a, b)] for a in elements for b in elements}
    identity = {0: elements[0]}
    return FiniteCategory(objects, morphisms, composition, identity)


def cyclic_monoid_category(n: int) -> FiniteCategory:
    """The cyclic group Z/nZ as a single-object category."""
    elements = [f"g{i}" for i in range(n)]
    mult_table = {
        (f"g{i}", f"g{j}"): f"g{(i + j) % n}" for i in range(n) for j in range(n)
    }
    return monoid_category(elements, mult_table)


def disjoint_union_category(cats: list) -> FiniteCategory:
    """Disjoint union (coproduct) of categories."""
    objects = []
    morphisms = {}
    composition = {}
    identity = {}

    for idx, cat in enumerate(cats):
        obj_map = {}
        morph_map = {}
        for obj in cat.objects:
            new_obj = (idx, obj)
            objects.append(new_obj)
            identity[new_obj] = (idx, cat.identity[obj])
            obj_map[obj] = new_obj

        for (src, tgt), morphs in cat.morphisms.items():
            new_src = obj_map[src]
            new_tgt = obj_map[tgt]
            new_morphs = [(idx, m) for m in morphs]
            morphisms[(new_src, new_tgt)] = new_morphs
            for m in morphs:
                morph_map[m] = (idx, m)

        for (f, g), result in cat.composition.items():
            composition[((idx, f), (idx, g))] = (idx, result)

    return FiniteCategory(objects, morphisms, composition, identity)


def is_separating(cat: FiniteCategory, probe_set: set) -> bool:
    """Check if a set of probe objects separates all morphisms."""
    for (src, tgt), morphs in cat.morphisms.items():
        for i, f in enumerate(morphs):
            for g in morphs[i + 1 :]:
                # Check if f and g are separated by some probe
                separated = False
                for z in probe_set:
                    for h in cat.hom(z, src):
                        hf = cat.compose(f, h)
                        hg = cat.compose(g, h)
                        if hf != hg:
                            separated = True
                            break
                    if separated:
                        break
                if not separated:
                    return False
    return True


def probe_complexity(cat: FiniteCategory) -> int:
    """Compute the probe complexity by exhaustive search."""
    n = len(cat.objects)

    # Check if all hom-sets are singletons (probe complexity = 0)
    all_singleton = all(
        len(morphs) <= 1 for morphs in cat.morphisms.values()
    )
    if all_singleton:
        return 0

    for k in range(1, n + 1):
        for subset in itertools.combinations(cat.objects, k):
            if is_separating(cat, set(subset)):
                return k
    return n  # total family always works


def profile_capacity(cat: FiniteCategory, probe_set: set, src, tgt) -> int:
    """Compute the profile capacity ∏_{Z∈P} |Hom(Z,tgt)|^|Hom(Z,src)|."""
    capacity = 1
    for z in probe_set:
        hom_z_src = len(cat.hom(z, src))
        hom_z_tgt = len(cat.hom(z, tgt))
        if hom_z_src == 0:
            capacity *= 1  # empty function space has 1 element
        else:
            capacity *= hom_z_tgt ** hom_z_src
    return capacity


def main():
    print("=" * 70)
    print("PROBE COMPLEXITY OF FINITE CATEGORIES — DEMONSTRATIONS")
    print("=" * 70)
    print()

    # --- Example 1: Discrete categories ---
    print("─" * 60)
    print("Example 1: Discrete Categories")
    print("─" * 60)
    print("In a discrete category, every hom-set has at most 1 element.")
    print("The empty probe family is vacuously separating.")
    print()

    for n in [1, 2, 3, 5, 10]:
        cat = discrete_category(n)
        pc = probe_complexity(cat)
        print(f"  Discrete({n}): probe complexity = {pc}")
    print()

    # --- Example 2: Parallel arrows ---
    print("─" * 60)
    print("Example 2: Parallel Arrows (2 objects, k arrows 0→1)")
    print("─" * 60)
    print("To separate k parallel arrows f_1,...,f_k : 0 → 1,")
    print("we need a probe Z with a morphism h : Z → 0.")
    print("Only object 0 itself works (via the identity).")
    print()

    for k in [1, 2, 3, 5, 10]:
        cat = parallel_arrows_category(k)
        pc = probe_complexity(cat)
        hom_size = len(cat.hom(0, 1))
        capacity = profile_capacity(cat, {0}, 0, 1) if pc > 0 else "N/A"
        print(f"  ParallelArrows({k}): probe complexity = {pc}, "
              f"|Hom(0,1)| = {hom_size}, capacity({{{0}}}) = {capacity}")
    print()

    # --- Example 3: Cyclic group monoids ---
    print("─" * 60)
    print("Example 3: Cyclic Group Z/nZ (single-object category)")
    print("─" * 60)
    print("A single-object category is a monoid. The only probe is the")
    print("single object itself. Probe complexity = 1 if |G| > 1, else 0.")
    print()

    for n in [1, 2, 3, 4, 6, 12]:
        cat = cyclic_monoid_category(n)
        pc = probe_complexity(cat)
        cap = n**n  # |Hom(0,0)|^|Hom(0,0)| = n^n
        print(f"  Z/{n}Z: probe complexity = {pc}, |End| = {n}, "
              f"profile capacity = {cap}")
    print()

    # --- Example 4: Disjoint unions ---
    print("─" * 60)
    print("Example 4: Disjoint Unions of Monoids")
    print("─" * 60)
    print("The disjoint union of k copies of a nontrivial monoid")
    print("has probe complexity k (each component needs its own probe).")
    print()

    for k in range(1, 6):
        components = [cyclic_monoid_category(2) for _ in range(k)]
        cat = disjoint_union_category(components)
        pc = probe_complexity(cat)
        n_obj = len(cat.objects)
        print(f"  {k} × Z/2Z: {n_obj} objects, probe complexity = {pc}")
    print()

    # --- Example 5: Information-theoretic bound verification ---
    print("─" * 60)
    print("Example 5: Information-Theoretic Bound Verification")
    print("─" * 60)
    print("For every separating P and every X,Y:")
    print("  |Hom(X,Y)| ≤ ∏_{Z∈P} |Hom(Z,Y)|^|Hom(Z,X)|")
    print()

    test_cats = [
        ("Discrete(3)", discrete_category(3)),
        ("3×Arrows", parallel_arrows_category(3)),
        ("Z/4Z", cyclic_monoid_category(4)),
        ("2×Z/3Z", disjoint_union_category([cyclic_monoid_category(3)] * 2)),
    ]

    for name, cat in test_cats:
        pc = probe_complexity(cat)
        # Find an optimal probe set
        optimal_probes = None
        for k in range(pc, pc + 1):
            for subset in itertools.combinations(cat.objects, k):
                if is_separating(cat, set(subset)):
                    optimal_probes = set(subset)
                    break
            if optimal_probes:
                break

        if optimal_probes is None:
            optimal_probes = set(cat.objects)

        print(f"  {name}: probe complexity = {pc}")
        bound_satisfied = True
        for (src, tgt), morphs in cat.morphisms.items():
            hom_size = len(morphs)
            if hom_size > 0:
                cap = profile_capacity(cat, optimal_probes, src, tgt)
                ok = hom_size <= cap
                bound_satisfied = bound_satisfied and ok
                if hom_size > 1:
                    print(f"    |Hom({src},{tgt})| = {hom_size} ≤ capacity = {cap} ✓" if ok
                          else f"    |Hom({src},{tgt})| = {hom_size} > capacity = {cap} ✗")
        print(f"    Information-theoretic bound: {'SATISFIED ✓' if bound_satisfied else 'VIOLATED ✗'}")
        print()

    # --- Summary table ---
    print("─" * 60)
    print("Summary: Probe Complexity vs Category Size")
    print("─" * 60)
    print(f"{'Category':<25} {'|Ob|':>5} {'|Mor|':>6} {'PC':>4} {'PC/|Ob|':>8}")
    print("─" * 60)

    examples = [
        ("Discrete(5)", discrete_category(5)),
        ("5×Arrows", parallel_arrows_category(5)),
        ("Z/6Z", cyclic_monoid_category(6)),
        ("3×Z/2Z", disjoint_union_category([cyclic_monoid_category(2)] * 3)),
        ("2×Z/3Z", disjoint_union_category([cyclic_monoid_category(3)] * 2)),
        ("Z/2Z + Z/3Z", disjoint_union_category(
            [cyclic_monoid_category(2), cyclic_monoid_category(3)]
        )),
    ]

    for name, cat in examples:
        n_obj = len(cat.objects)
        n_morph = sum(len(v) for v in cat.morphisms.values())
        pc = probe_complexity(cat)
        ratio = f"{pc/n_obj:.2f}" if n_obj > 0 else "N/A"
        print(f"  {name:<23} {n_obj:>5} {n_morph:>6} {pc:>4} {ratio:>8}")

    print()
    print("Key observations:")
    print("  • Discrete categories: PC = 0 (nothing to separate)")
    print("  • Parallel arrows: PC = 1 (one probe suffices)")
    print("  • Disjoint monoids: PC = number of components")
    print("  • Single monoid: PC = 1 (the only object probes itself)")
    print()
    print("The information-theoretic bound |Hom(X,Y)| ≤ ∏ capacity")
    print("is always satisfied, confirming Theorem 2.")


if __name__ == "__main__":
    main()
