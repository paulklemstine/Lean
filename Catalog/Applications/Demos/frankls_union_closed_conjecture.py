#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Frequency-Potential Theory

Demonstrates connections between union-closed families and:
  1. Database schema design (closed attribute sets)
  2. Network consensus (closed fault-tolerant subsets)
  3. Boolean function analysis (monotone clause families)
  4. Formal concept analysis (concept lattices)
"""

from itertools import combinations
from collections import defaultdict
from typing import List, Set, FrozenSet, Dict, Tuple

FSet = FrozenSet[int]
Family = List[FSet]


# ─── Shared Utilities ────────────────────────────────────────────────────

def union_closure(generators: List[FSet]) -> Family:
    """Compute the union-closure including ∅."""
    F: Set[FSet] = {frozenset()}
    F.update(generators)
    changed = True
    while changed:
        changed = False
        new = set()
        for A in F:
            for B in F:
                u = A | B
                if u not in F:
                    new.add(u)
                    changed = True
        F.update(new)
    return sorted(F, key=lambda s: (len(s), sorted(s)))


def elem_freq(F: Family, a: int) -> int:
    return sum(1 for s in F if a in s)


def total_weight(F: Family) -> int:
    return sum(len(s) for s in F)


def support(F: Family) -> FSet:
    result: set = set()
    for s in F:
        result.update(s)
    return frozenset(result)


def is_frankl_witness(F: Family, a: int) -> bool:
    return 2 * elem_freq(F, a) >= len(F)


# ─── Application 1: Database Schema Design ──────────────────────────────

def database_schema_demo():
    """
    In database theory, functional dependencies define closed attribute sets.
    The family of closed sets under a set of FDs is union-closed when the
    FDs satisfy certain natural conditions (e.g., when the closure comes
    from a join-semilattice of attribute combinations).

    Frankl's conjecture applied: some attribute appears in at least half
    the closed attribute sets → that attribute is "structurally central."
    """
    print("=" * 60)
    print("APPLICATION 1: Database Schema — Central Attributes")
    print("=" * 60)

    # Attributes: 0=Name, 1=Email, 2=Dept, 3=Role, 4=Salary
    attr_names = {0: "Name", 1: "Email", 2: "Dept", 3: "Role", 4: "Salary"}
    n = len(attr_names)

    # Closed attribute sets under functional dependencies
    # (simplified: these are the "natural query groups")
    generators = [
        frozenset({0, 1}),      # Name+Email (unique identifier)
        frozenset({2, 3}),      # Dept+Role (organizational unit)
        frozenset({3, 4}),      # Role+Salary (compensation structure)
    ]

    F = union_closure(generators)

    print(f"\n  Attributes: {attr_names}")
    print(f"  Generator groups: {[{attr_names[a] for a in g} for g in generators]}")
    print(f"\n  Closed attribute sets ({len(F)} total):")
    for s in F:
        label = {attr_names[a] for a in s} if s else "∅"
        print(f"    {label}")

    print(f"\n  Attribute centrality (frequency / family size):")
    for a in range(n):
        freq = elem_freq(F, a)
        centrality = freq / len(F)
        witness = " ★ CENTRAL" if is_frankl_witness(F, a) else ""
        bar = "█" * int(centrality * 20) + "░" * (20 - int(centrality * 20))
        print(f"    {attr_names[a]:8s}: {bar} {freq}/{len(F)} ({centrality:.0%}){witness}")

    print(f"\n  Interpretation: Attributes marked ★ appear in ≥ half of all")
    print(f"  closed attribute sets. Frankl's conjecture guarantees at least")
    print(f"  one such attribute exists in any schema with these properties.")


# ─── Application 2: Network Fault Tolerance ──────────────────────────────

def network_consensus_demo():
    """
    In distributed systems, a family of "surviving node sets" that is
    union-closed models the property: if two subsets can each maintain
    service, so can their union. The empty set represents total failure.

    Frankl's conjecture: some node participates in at least half of all
    viable configurations → that node is the most reliable.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Consensus — Reliable Nodes")
    print("=" * 60)

    node_names = {0: "Gateway", 1: "Auth", 2: "Cache", 3: "DB", 4: "Logger"}

    # Minimal viable subsets (generators for union-closure)
    viable_subsets = [
        frozenset({0, 3}),      # Gateway + DB (minimal read path)
        frozenset({0, 1, 3}),   # Gateway + Auth + DB (secure path)
        frozenset({0, 2}),      # Gateway + Cache (cached reads)
    ]

    F = union_closure(viable_subsets)

    print(f"\n  Nodes: {node_names}")
    print(f"  Minimal viable configs: {[{node_names[a] for a in g} for g in viable_subsets]}")
    print(f"  All viable configs ({len(F)} total, including ∅=failure):")

    for s in F:
        label = {node_names[a] for a in s} if s else "∅ (failure)"
        print(f"    {label}")

    print(f"\n  Node reliability scores:")
    for a in sorted(node_names):
        freq = elem_freq(F, a)
        reliability = freq / len(F)
        critical = " ★ CRITICAL" if is_frankl_witness(F, a) else ""
        bar = "█" * int(reliability * 20) + "░" * (20 - int(reliability * 20))
        print(f"    {node_names[a]:8s}: {bar} {freq}/{len(F)} ({reliability:.0%}){critical}")


# ─── Application 3: Boolean Function Analysis ───────────────────────────

def boolean_analysis_demo():
    """
    Monotone Boolean functions can be represented by their "satisfying sets"
    — the sets of variables set to 1 that make the function true. When
    these satisfying sets include ∅ (the constant-1 function restricted
    to a union-closed subfamily), Frankl's conjecture gives a lower bound
    on the influence of the most influential variable.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Boolean Functions — Variable Influence")
    print("=" * 60)

    # Variables in a circuit: x0, x1, x2, x3
    var_names = {0: "x₀", 1: "x₁", 2: "x₂", 3: "x₃"}

    # Satisfying assignments (as sets of "true" variables)
    # For a monotone function: any superset of a satisfying set is also satisfying
    generators = [
        frozenset({0, 1}),     # x0 ∧ x1
        frozenset({2, 3}),     # x2 ∧ x3
    ]

    F = union_closure(generators)

    print(f"\n  Variables: {list(var_names.values())}")
    print(f"  Generator clauses: {[{var_names[a] for a in g} for g in generators]}")
    print(f"  Union-closed satisfying sets ({len(F)}):")
    for s in F:
        assignment = ", ".join(f"{var_names[a]}=1" for a in sorted(s)) if s else "all-0"
        print(f"    {{{assignment}}}")

    print(f"\n  Variable influence (proportion of satisfying sets containing variable):")
    for a in range(4):
        freq = elem_freq(F, a)
        influence = freq / len(F)
        high = " ★ HIGH INFLUENCE" if is_frankl_witness(F, a) else ""
        print(f"    {var_names[a]}: {freq}/{len(F)} = {influence:.2f}{high}")

    tw = total_weight(F)
    avg = tw / len(F)
    print(f"\n  Average satisfying-set size: {avg:.2f}")
    print(f"  Total weight: {tw}")
    print(f"  Double counting: Σ influence = {sum(elem_freq(F, a) for a in range(4))} = totalWeight")


# ─── Application 4: Formal Concept Analysis ─────────────────────────────

def concept_lattice_demo():
    """
    In Formal Concept Analysis, the extents of a formal context form
    a closure system. When the intent operator produces a union-closed
    family of extents, Frankl's conjecture guarantees a "frequent object."
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Formal Concept Analysis — Frequent Objects")
    print("=" * 60)

    # Objects and attributes in a formal context
    objects = {0: "Cat", 1: "Dog", 2: "Fish", 3: "Bird", 4: "Snake"}
    attributes = {0: "Legs", 1: "Fur", 2: "Tail", 3: "Wings", 4: "Aquatic"}

    # Incidence: which objects have which attributes
    incidence = {
        0: {0, 1, 2},           # Cat: Legs, Fur, Tail
        1: {0, 1, 2},           # Dog: Legs, Fur, Tail
        2: {2, 4},              # Fish: Tail, Aquatic
        3: {0, 2, 3},           # Bird: Legs, Tail, Wings
        4: {2},                 # Snake: Tail
    }

    # Extents: for each subset of attributes, the set of objects having ALL those attributes
    def extent(attrs: FSet) -> FSet:
        if not attrs:
            return frozenset(objects.keys())
        return frozenset(obj for obj, obj_attrs in incidence.items()
                        if attrs <= obj_attrs)

    # Compute all distinct extents
    all_attr_subsets = []
    for r in range(len(attributes) + 1):
        for c in combinations(range(len(attributes)), r):
            all_attr_subsets.append(frozenset(c))

    extents = set()
    for attrs in all_attr_subsets:
        ext = extent(attrs)
        extents.add(ext)

    # These extents form a closure system (intersection-closed)
    # Let's look at them as a family
    F = sorted(extents, key=lambda s: (len(s), sorted(s)))

    print(f"\n  Context: {len(objects)} objects × {len(attributes)} attributes")
    print(f"  Distinct extents ({len(F)}):")
    for s in F:
        obj_names = {objects[o] for o in s} if s else "∅"
        print(f"    {obj_names}")

    print(f"\n  Object frequency in extents:")
    for o in sorted(objects):
        freq = elem_freq(F, o)
        is_w = is_frankl_witness(F, o)
        marker = " ★ FREQUENT" if is_w else ""
        print(f"    {objects[o]:6s}: {freq}/{len(F)}{marker}")

    # Verify double counting
    tw = total_weight(F)
    freq_sum = sum(elem_freq(F, o) for o in objects)
    print(f"\n  Double counting: totalWeight={tw}, Σ freq={freq_sum}, "
          f"match={'✓' if tw == freq_sum else '✗'}")


# ─── Main ────────────────────────────────────────────────────────────────

def main():
    database_schema_demo()
    network_consensus_demo()
    boolean_analysis_demo()
    concept_lattice_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Frankl's Union-Closed Conjecture: Interactive Explorer

Demonstrates the frequency-potential formalism for union-closed families:
  - Enumerates union-closed families on small ground sets
  - Computes elemFreq, totalWeight, support
  - Finds argmaxElemFreq (the most frequent element)
  - Tests the average-threshold conjecture
  - Displays families as join-semilattices (Hasse diagrams)
  - Highlights Frankl witnesses

Usage:
  python demo.py            # Run all demos
  python demo.py --interact # Interactive mode
"""

from itertools import combinations, chain
from collections import defaultdict
import sys


# ─── Core Definitions ───────────────────────────────────────────────────

def elem_freq(F, a):
    """Number of sets in F that contain element a."""
    return sum(1 for s in F if a in s)


def total_weight(F):
    """Sum of all set sizes in the family F."""
    return sum(len(s) for s in F)


def support(F):
    """Union of all members of F (the ground set)."""
    return frozenset().union(*F) if F else frozenset()


def is_frankl_witness(F, a):
    """True if a belongs to at least half the members of F."""
    return 2 * elem_freq(F, a) >= len(F)


def argmax_elem_freq(F):
    """Element with maximum frequency in F. Returns (element, freq)."""
    supp = support(F)
    if not supp:
        return None, 0
    best = max(supp, key=lambda a: elem_freq(F, a))
    return best, elem_freq(F, best)


def is_union_closed(F):
    """Check if F is union-closed (every pairwise union is in F)."""
    fset = set(F)
    for A in F:
        for B in F:
            if A | B not in fset:
                return False
    return True


def is_union_closed_family(F):
    """Check if F is union-closed AND contains the empty set."""
    return frozenset() in set(F) and is_union_closed(F)


# ─── Union-Closure Construction ─────────────────────────────────────────

def union_closure(generators):
    """Compute the union-closure of a set of generators (including ∅)."""
    F = {frozenset()}  # Always include ∅
    F.update(generators)
    changed = True
    while changed:
        changed = False
        new = set()
        for A in F:
            for B in F:
                u = A | B
                if u not in F:
                    new.add(u)
                    changed = True
        F.update(new)
    return F


# ─── Enumeration of Union-Closed Families ────────────────────────────────

def all_subsets(ground):
    """All subsets of a ground set, as frozensets."""
    ground = list(ground)
    result = []
    for r in range(len(ground) + 1):
        for c in combinations(ground, r):
            result.append(frozenset(c))
    return result


def enumerate_union_closed_families(n, max_families=500):
    """
    Enumerate union-closed families on ground set {0, ..., n-1}.
    Returns families as lists of frozensets.
    Limited to max_families for performance.
    """
    ground = set(range(n))
    subsets = all_subsets(ground)
    families = []

    # Strategy: try all subsets of subsets that include ∅
    # For small n, this is feasible
    if n <= 3:
        # Brute force: try all subfamilies containing ∅
        non_empty_subsets = [s for s in subsets if s]
        for r in range(len(non_empty_subsets) + 1):
            for combo in combinations(non_empty_subsets, r):
                F = list(combo) + [frozenset()]
                F_set = set(F)
                if all(A | B in F_set for A in F for B in F):
                    families.append(F)
                    if len(families) >= max_families:
                        return families
    else:
        # For larger n, generate from random generators
        import random
        random.seed(42)
        for _ in range(max_families * 5):
            k = random.randint(1, min(n, 4))
            gens = set()
            for _ in range(k):
                size = random.randint(1, n)
                s = frozenset(random.sample(range(n), size))
                gens.add(s)
            F = union_closure(gens)
            F_list = sorted(F, key=lambda s: (len(s), sorted(s)))
            if F_list not in families:
                families.append(F_list)
            if len(families) >= max_families:
                break

    return families


# ─── Hasse Diagram (text-based) ─────────────────────────────────────────

def hasse_diagram(F):
    """Display the Hasse diagram of F under inclusion (text-based)."""
    F_sorted = sorted(F, key=lambda s: (len(s), sorted(s)))
    covers = defaultdict(list)
    covered_by = defaultdict(list)

    for i, A in enumerate(F_sorted):
        for j, B in enumerate(F_sorted):
            if A < B:  # strict subset
                # Check if it's a cover relation (no C with A ⊂ C ⊂ B in F)
                is_cover = True
                for C in F_sorted:
                    if A < C and C < B:
                        is_cover = False
                        break
                if is_cover:
                    covers[i].append(j)
                    covered_by[j].append(i)

    # Group by levels (set size)
    levels = defaultdict(list)
    for i, s in enumerate(F_sorted):
        levels[len(s)].append(i)

    lines = []
    lines.append("  Hasse Diagram (bottom = ∅, top = ⋃F):")
    lines.append("  " + "─" * 40)

    for level in sorted(levels.keys(), reverse=True):
        items = []
        for idx in levels[level]:
            s = F_sorted[idx]
            label = "{" + ",".join(str(x) for x in sorted(s)) + "}" if s else "∅"
            # Mark Frankl witnesses
            items.append(label)
        lines.append(f"  Level {level}: " + "  ".join(items))

    return "\n".join(lines)


# ─── Demo Functions ──────────────────────────────────────────────────────

def demo_basic_definitions():
    """Demonstrate core definitions on a concrete example."""
    print("=" * 60)
    print("DEMO 1: Core Definitions")
    print("=" * 60)

    # Example: F = {∅, {0}, {1}, {0,1}, {0,1,2}}
    F = [
        frozenset(),
        frozenset({0}),
        frozenset({1}),
        frozenset({0, 1}),
        frozenset({0, 1, 2}),
    ]

    print(f"\nFamily F with {len(F)} members:")
    for s in F:
        print(f"  {set(s) if s else '∅'}")

    print(f"\nIs union-closed family: {is_union_closed_family(F)}")
    print(f"Support: {set(support(F))}")
    print(f"Total weight: {total_weight(F)}")

    supp = support(F)
    print(f"\nElement frequencies:")
    for a in sorted(supp):
        freq = elem_freq(F, a)
        witness = is_frankl_witness(F, a)
        marker = " ★ WITNESS" if witness else ""
        print(f"  elemFreq(F, {a}) = {freq} / {len(F)}{marker}")

    best, best_freq = argmax_elem_freq(F)
    print(f"\nargmaxElemFreq = {best} (frequency = {best_freq})")

    print(f"\n{hasse_diagram(F)}")


def demo_double_counting():
    """Verify the double-counting identity totalWeight = ∑ elemFreq."""
    print("\n" + "=" * 60)
    print("DEMO 2: Double-Counting Identity")
    print("=" * 60)

    examples = [
        ("Singleton", [frozenset(), frozenset({0})]),
        ("Pair", [frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})]),
        ("Power set of {0,1}", [frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})]),
        ("Chain", [frozenset(), frozenset({0}), frozenset({0, 1}), frozenset({0, 1, 2})]),
    ]

    for name, F in examples:
        tw = total_weight(F)
        supp = sorted(support(F))
        freq_sum = sum(elem_freq(F, a) for a in supp)
        # Over full ground type (use support as ground)
        check = "✓" if tw == freq_sum else "✗"
        print(f"\n  {name}: totalWeight = {tw}, ∑ elemFreq = {freq_sum} {check}")


def demo_average_criterion():
    """Test the average-size criterion on various families."""
    print("\n" + "=" * 60)
    print("DEMO 3: Average-Size Criterion")
    print("=" * 60)
    print("  Theorem: If |F| · |α| ≤ 2 · totalWeight(F), then ∃ Frankl witness.")

    examples = [
        ("Large sets", [frozenset(), frozenset({0, 1, 2}), frozenset({1, 2, 3}),
                        frozenset({0, 1, 2, 3})], 4),
        ("Small sets", [frozenset(), frozenset({0}), frozenset({1}),
                        frozenset({0, 1})], 3),
        ("Balanced", [frozenset(), frozenset({0, 1}), frozenset({2, 3}),
                      frozenset({0, 1, 2, 3})], 4),
    ]

    for name, F, ground_size in examples:
        tw = total_weight(F)
        lhs = len(F) * ground_size
        rhs = 2 * tw
        satisfied = lhs <= rhs
        best, best_freq = argmax_elem_freq(F)
        has_witness = any(is_frankl_witness(F, a) for a in support(F))

        print(f"\n  {name}:")
        print(f"    |F| = {len(F)}, |α| = {ground_size}, totalWeight = {tw}")
        print(f"    |F|·|α| = {lhs} {'≤' if satisfied else '>'} 2·totalWeight = {rhs}")
        print(f"    Average criterion {'SATISFIED' if satisfied else 'not satisfied'}")
        print(f"    Has Frankl witness: {has_witness} (best: {best}, freq={best_freq})")


def demo_structural_cases():
    """Demonstrate structural special cases."""
    print("\n" + "=" * 60)
    print("DEMO 4: Structural Special Cases")
    print("=" * 60)

    # Case 1: All nonempty sets contain element 0
    print("\n  Case: All nonempty sets contain a fixed element")
    F1 = [frozenset(), frozenset({0}), frozenset({0, 1}), frozenset({0, 2}),
           frozenset({0, 1, 2})]
    print(f"    F = {[set(s) if s else '∅' for s in F1]}")
    print(f"    Element 0 appears in {elem_freq(F1, 0)}/{len(F1)} sets")
    print(f"    Is Frankl witness: {is_frankl_witness(F1, 0)}")

    # Case 2: Singleton in family
    print("\n  Case: Singleton {a} ∈ F (union-closed)")
    F2 = union_closure([frozenset({0}), frozenset({1, 2})])
    F2_list = sorted(F2, key=lambda s: (len(s), sorted(s)))
    print(f"    F = {[set(s) if s else '∅' for s in F2_list]}")
    print(f"    {{0}} ∈ F: {frozenset({0}) in F2}")
    print(f"    Element 0 freq: {elem_freq(F2_list, 0)}/{len(F2_list)}")
    print(f"    Is Frankl witness: {is_frankl_witness(F2_list, 0)}")

    # Case 3: |F| ≤ 2
    print("\n  Case: |F| ≤ 2")
    F3 = [frozenset(), frozenset({0, 1})]
    print(f"    F = {[set(s) if s else '∅' for s in F3]}")
    for a in sorted(support(F3)):
        print(f"    Element {a} freq: {elem_freq(F3, a)}/{len(F3)}, witness: {is_frankl_witness(F3, a)}")


def demo_disjoint_generators():
    """Demonstrate the disjoint-generators case."""
    print("\n" + "=" * 60)
    print("DEMO 5: Disjoint Generators — Powerset Symmetry")
    print("=" * 60)

    # Generators: {0}, {1}, {2} (pairwise disjoint)
    generators = [frozenset({0}), frozenset({1}), frozenset({2})]
    F = union_closure(generators)
    F_list = sorted(F, key=lambda s: (len(s), sorted(s)))
    k = len(generators)

    print(f"\n  Generators (k={k}): {[set(g) for g in generators]}")
    print(f"  Union-closure has {len(F_list)} = 2^{k} members:")
    for s in F_list:
        print(f"    {set(s) if s else '∅'}")

    print(f"\n  Element frequencies (should be 2^(k-1) = {2**(k-1)}):")
    for a in sorted(support(F)):
        freq = elem_freq(F_list, a)
        print(f"    elemFreq(F, {a}) = {freq} = 2^(k-1)? {freq == 2**(k-1)}")

    # Larger example
    print(f"\n  Larger example: k=4 disjoint generators")
    gens4 = [frozenset({0}), frozenset({1}), frozenset({2}), frozenset({3})]
    F4 = union_closure(gens4)
    F4_list = sorted(F4, key=lambda s: (len(s), sorted(s)))
    print(f"    |F| = {len(F4_list)} = 2^4 = 16")
    for a in range(4):
        freq = elem_freq(F4_list, a)
        print(f"    elemFreq(F, {a}) = {freq} = 2^3 = 8? {freq == 8}")


def demo_average_threshold_conjecture():
    """Test the average-threshold conjecture on small families."""
    print("\n" + "=" * 60)
    print("DEMO 6: Average-Threshold Conjecture Test")
    print("=" * 60)
    print("  Conjecture: For non-chain UCF, 2·totalWeight(F) ≥ |F|·|supp(F)|")

    def is_chain(F):
        """Check if F is a chain under inclusion."""
        for A in F:
            for B in F:
                if not (A <= B or B <= A):
                    return False
        return True

    counterexamples = []
    tested = 0

    for n in range(1, 5):
        families = enumerate_union_closed_families(n, max_families=200)
        n_tested = 0
        n_non_chain = 0
        n_satisfied = 0

        for F in families:
            F_set = set(F)
            if not is_union_closed_family(F):
                continue
            if not any(s for s in F if s):  # need nonempty member
                continue
            tested += 1
            n_tested += 1

            if is_chain(F):
                continue
            n_non_chain += 1

            supp = support(F)
            tw = total_weight(F)
            threshold = len(F) * len(supp)

            if 2 * tw >= threshold:
                n_satisfied += 1
            else:
                counterexamples.append((n, F, 2 * tw, threshold))

        print(f"\n  n={n}: tested {n_tested} UCFs, {n_non_chain} non-chains, "
              f"{n_satisfied} satisfy conjecture")

    if counterexamples:
        print(f"\n  ⚠ COUNTEREXAMPLES FOUND: {len(counterexamples)}")
        for n, F, lhs, rhs in counterexamples[:3]:
            print(f"    n={n}: 2·tw={lhs} < |F|·|supp|={rhs}")
            print(f"    F = {[set(s) if s else '∅' for s in F]}")
    else:
        print(f"\n  ✓ Conjecture holds for all {tested} tested families!")


def demo_interactive():
    """Interactive mode: user specifies generators."""
    print("\n" + "=" * 60)
    print("INTERACTIVE: Build Your Own Union-Closed Family")
    print("=" * 60)

    try:
        n = int(input("\n  Ground set size n (1-6): "))
        if n < 1 or n > 6:
            print("  Using n=3")
            n = 3
    except (ValueError, EOFError):
        print("  Using n=3")
        n = 3

    print(f"  Ground set: {{0, ..., {n-1}}}")
    print(f"  Enter generators as space-separated elements, one per line.")
    print(f"  Empty line to finish.")

    generators = []
    while True:
        try:
            line = input("  Generator: ").strip()
        except EOFError:
            break
        if not line:
            break
        try:
            elems = [int(x) for x in line.split()]
            if all(0 <= x < n for x in elems) and elems:
                generators.append(frozenset(elems))
                print(f"    Added {set(elems)}")
            else:
                print(f"    Invalid (elements must be in 0..{n-1})")
        except ValueError:
            print("    Invalid input")

    if not generators:
        generators = [frozenset({0}), frozenset({1, 2})]
        print(f"  Using default generators: {[set(g) for g in generators]}")

    F = union_closure(generators)
    F_list = sorted(F, key=lambda s: (len(s), sorted(s)))

    print(f"\n  Union-closure ({len(F_list)} members):")
    for s in F_list:
        label = set(s) if s else "∅"
        markers = []
        for a in sorted(support(F)):
            if a in s:
                markers.append(str(a))
        print(f"    {label}")

    print(f"\n  Total weight: {total_weight(F_list)}")
    print(f"  Support: {set(support(F))}")
    print(f"\n  Element frequencies:")
    for a in sorted(support(F)):
        freq = elem_freq(F_list, a)
        witness = is_frankl_witness(F_list, a)
        bar = "█" * freq + "░" * (len(F_list) - freq)
        marker = " ★ WITNESS" if witness else ""
        print(f"    {a}: {bar} {freq}/{len(F_list)}{marker}")

    best, best_freq = argmax_elem_freq(F_list)
    print(f"\n  Maximum frequency element: {best} ({best_freq}/{len(F_list)})")
    print(f"  Is Frankl witness: {is_frankl_witness(F_list, best)}")

    # Double counting verification
    tw = total_weight(F_list)
    freq_sum = sum(elem_freq(F_list, a) for a in sorted(support(F)))
    print(f"\n  Double counting: totalWeight = {tw}, ∑ elemFreq = {freq_sum} "
          f"{'✓' if tw == freq_sum else '✗'}")

    print(f"\n{hasse_diagram(F_list)}")


# ─── Main ────────────────────────────────────────────────────────────────

def main():
    if "--interact" in sys.argv:
        demo_interactive()
    else:
        demo_basic_definitions()
        demo_double_counting()
        demo_average_criterion()
        demo_structural_cases()
        demo_disjoint_generators()
        demo_average_threshold_conjecture()


if __name__ == "__main__":
    main()
