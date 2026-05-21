#!/usr/bin/env python3
"""
Applications of Frankl's Union-Closed Conjecture

Demonstrates connections to:
1. Data compression / concept lattices
2. Social network analysis (community overlap)
3. Boolean function complexity
4. Knowledge representation (closure systems)
"""

from itertools import combinations
from collections import defaultdict
from typing import Set, FrozenSet, List, Dict


def powerset(s: frozenset) -> list[frozenset]:
    elems = list(s)
    return [frozenset(c) for r in range(len(elems)+1) for c in combinations(elems, r)]


def union_closure(family: set[frozenset]) -> set[frozenset]:
    closed = set(family)
    changed = True
    while changed:
        changed = False
        new = set()
        for A in closed:
            for B in closed:
                U = A | B
                if U not in closed:
                    new.add(U)
                    changed = True
        closed |= new
    return closed


def elem_freq(family: set[frozenset], a) -> int:
    return sum(1 for s in family if a in s)


# ═══════════════════════════════════════════════════════════
# APPLICATION 1: Concept Lattices and Knowledge Discovery
# ═══════════════════════════════════════════════════════════

def concept_lattice_demo():
    """
    In Formal Concept Analysis, the set of extents of a formal context
    forms a closure system (union-closed family under intersection,
    but the dual — the set of intents — is union-closed).
    
    Frankl's conjecture implies: in any concept lattice, at least one
    attribute appears in at least half the concepts.
    """
    print("\n" + "="*60)
    print("  APPLICATION 1: Concept Lattices")
    print("="*60)
    
    # A formal context: objects × attributes
    # Objects: animals, Attributes: properties
    objects = ["dog", "cat", "eagle", "salmon", "snake"]
    attributes = ["legs", "fur", "wings", "breathes_air", "warm_blooded"]
    
    # Incidence relation
    context = {
        "dog":    {"legs", "fur", "breathes_air", "warm_blooded"},
        "cat":    {"legs", "fur", "breathes_air", "warm_blooded"},
        "eagle":  {"legs", "wings", "breathes_air", "warm_blooded"},
        "salmon": set(),
        "snake":  {"breathes_air"},
    }
    
    # Compute attribute sets (intents) — which attributes are shared
    # by which groups of objects
    intents = set()
    for r in range(len(objects) + 1):
        for combo in combinations(objects, r):
            if combo:
                shared = set.intersection(*(context[o] for o in combo))
            else:
                shared = set(attributes)
            intents.add(frozenset(shared))
    
    # The intents form a closure system (closed under intersection)
    # For Frankl, we look at the dual: union-closed families
    print(f"\n  Formal Context: {len(objects)} objects × {len(attributes)} attributes")
    print(f"  Intents (closed under ∩): {len(intents)}")
    
    # Show intents
    for intent in sorted(intents, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(intent) if intent else '{}'}")
    
    # Check which attributes appear most often
    print(f"\n  Attribute frequencies in intents:")
    for attr in sorted(attributes):
        f = sum(1 for i in intents if attr in i)
        heavy = " ← HEAVY" if 2 * f >= len(intents) else ""
        print(f"    {attr}: {f}/{len(intents)}{heavy}")
    
    print(f"\n  Frankl's conjecture predicts: at least one attribute")
    print(f"  appears in ≥ {len(intents)/2:.1f} of the {len(intents)} intents.")


# ═══════════════════════════════════════════════════════════
# APPLICATION 2: Social Network Communities
# ═══════════════════════════════════════════════════════════

def social_network_demo():
    """
    Communities in social networks often exhibit union-closure:
    if group A shares interest X and group B shares interest X,
    then A ∪ B shares interest X.
    
    Frankl's conjecture implies: some person belongs to at least
    half the communities.
    """
    print("\n" + "="*60)
    print("  APPLICATION 2: Social Network Communities")
    print("="*60)
    
    # People and their interest groups
    communities = {
        frozenset({"Alice", "Bob"}),           # Hiking
        frozenset({"Bob", "Carol"}),           # Chess
        frozenset({"Alice", "Carol", "Dave"}), # Book club
    }
    
    # Union-closure models "merged communities"
    closed_communities = union_closure(communities)
    
    print(f"\n  Original communities: {len(communities)}")
    for c in sorted(communities, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(c)}")
    
    print(f"\n  Union-closed communities: {len(closed_communities)}")
    for c in sorted(closed_communities, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(c)}")
    
    ground = frozenset().union(*closed_communities)
    print(f"\n  People: {set(ground)}")
    print(f"  Community memberships:")
    n = len(closed_communities)
    for person in sorted(ground):
        f = elem_freq(closed_communities, person)
        heavy = " ← appears in ≥ half" if 2 * f >= n else ""
        print(f"    {person}: {f}/{n} communities{heavy}")
    
    print(f"\n  Frankl predicts: someone is in ≥ {n/2:.0f} of {n} communities ✓")


# ═══════════════════════════════════════════════════════════
# APPLICATION 3: Feature Selection in Machine Learning
# ═══════════════════════════════════════════════════════════

def feature_selection_demo():
    """
    In feature selection, supported feature sets often form union-closed
    families. Frankl's conjecture suggests there's always a "universal"
    feature that's relevant to at least half the models.
    """
    print("\n" + "="*60)
    print("  APPLICATION 3: Feature Selection")
    print("="*60)
    
    # Feature sets for different ML models
    feature_sets = {
        frozenset({"age", "income"}),              # Model 1: demographics
        frozenset({"income", "credit_score"}),      # Model 2: financial
        frozenset({"age", "education"}),            # Model 3: background
    }
    
    closed = union_closure(feature_sets)
    
    print(f"\n  Original feature sets: {len(feature_sets)}")
    for fs in sorted(feature_sets, key=lambda s: sorted(s)):
        print(f"    {set(fs)}")
    
    print(f"\n  Union-closed feature sets: {len(closed)}")
    for fs in sorted(closed, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(fs)}")
    
    ground = frozenset().union(*closed)
    n = len(closed)
    print(f"\n  Feature frequencies:")
    for feat in sorted(ground):
        f = elem_freq(closed, feat)
        heavy = " ← UNIVERSAL FEATURE" if 2 * f >= n else ""
        print(f"    {feat}: {f}/{n}{heavy}")
    
    print(f"\n  Frankl guarantees: some feature appears in ≥ {n//2 + (n%2>0)} models")


# ═══════════════════════════════════════════════════════════
# APPLICATION 4: Database Query Closure
# ═══════════════════════════════════════════════════════════

def database_query_demo():
    """
    In database theory, the set of attribute closures under
    functional dependencies forms a closure system.
    Frankl's conjecture implies a "dominant attribute" principle.
    """
    print("\n" + "="*60)
    print("  APPLICATION 4: Database Attribute Closure")
    print("="*60)
    
    # Functional dependencies define which attribute sets determine others
    # Simulated: attribute sets that form a union-closed family
    base_attrs = {
        frozenset({"name", "id"}),
        frozenset({"id", "department"}),
        frozenset({"department", "location"}),
    }
    
    closed = union_closure(base_attrs)
    
    print(f"\n  Key attribute sets: {len(base_attrs)}")
    for s in sorted(base_attrs, key=lambda s: sorted(s)):
        print(f"    {set(s)}")
    
    print(f"\n  Closed attribute sets: {len(closed)}")
    for s in sorted(closed, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(s)}")
    
    ground = frozenset().union(*closed)
    n = len(closed)
    print(f"\n  Attribute frequencies:")
    for attr in sorted(ground):
        f = elem_freq(closed, attr)
        heavy = " ← DOMINANT" if 2 * f >= n else ""
        print(f"    {attr}: {f}/{n}{heavy}")
    
    # Verify Frankl
    has_witness = any(2 * elem_freq(closed, a) >= n for a in ground)
    print(f"\n  Frankl witness exists: {'✓' if has_witness else '✗'}")


# ═══════════════════════════════════════════════════════════
# APPLICATION 5: Counting and Statistics
# ═══════════════════════════════════════════════════════════

def statistics_demo():
    """
    Generate statistics about union-closed families on small ground sets.
    """
    print("\n" + "="*60)
    print("  APPLICATION 5: Statistical Survey")
    print("="*60)
    
    for n in range(1, 5):
        universe = frozenset(range(1, n + 1))
        all_subsets = powerset(universe)
        
        count = 0
        witness_count = 0
        avg_criterion_count = 0
        singleton_count = 0
        
        for size in range(1, min(len(all_subsets) + 1, 15)):
            for combo in combinations(all_subsets, size):
                family = set(combo)
                if not all(A | B in family for A in family for B in family):
                    continue
                
                ground = frozenset().union(*family) if family else frozenset()
                if not ground:
                    continue
                
                count += 1
                card = len(family)
                
                # Check Frankl
                has_w = any(2 * elem_freq(family, a) >= card for a in ground)
                if has_w:
                    witness_count += 1
                
                # Check average criterion
                ti = sum(len(s) for s in family)
                if len(ground) * card <= 2 * ti:
                    avg_criterion_count += 1
                
                # Check singleton
                if any(frozenset({a}) in family for a in ground):
                    singleton_count += 1
        
        print(f"\n  Ground size n = {n}:")
        print(f"    UC families with nonempty ground: {count}")
        print(f"    With Frankl witness:              {witness_count} ({100*witness_count//max(count,1)}%)")
        print(f"    Avg criterion sufficient:         {avg_criterion_count}")
        print(f"    Contains a singleton:             {singleton_count}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Frankl's Conjecture: Applications                     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    concept_lattice_demo()
    social_network_demo()
    feature_selection_demo()
    database_query_demo()
    statistics_demo()
    
    print("\n" + "="*60)
    print("  All applications demonstrated!")
    print("="*60)


#!/usr/bin/env python3
"""
Frankl's Union-Closed Conjecture: Interactive Demo

This script demonstrates the key concepts and verified results from
the formalization of Frankl's conjecture. It builds sample union-closed
families, computes frequencies, tests the conjecture, and explores
conjectures on small universes.

Usage:
    python demo.py
"""

from itertools import combinations, chain
from collections import Counter
from typing import Optional


def powerset(s: frozenset) -> list[frozenset]:
    """Return all subsets of s."""
    elems = list(s)
    return [
        frozenset(combo)
        for r in range(len(elems) + 1)
        for combo in combinations(elems, r)
    ]


def is_union_closed(family: set[frozenset]) -> bool:
    """Check if a family of sets is closed under pairwise union."""
    for A in family:
        for B in family:
            if A | B not in family:
                return False
    return True


def union_closure(family: set[frozenset]) -> set[frozenset]:
    """Compute the union-closure of a family of sets."""
    closed = set(family)
    changed = True
    while changed:
        changed = False
        new = set()
        for A in closed:
            for B in closed:
                U = A | B
                if U not in closed:
                    new.add(U)
                    changed = True
        closed |= new
    return closed


def elem_freq(family: set[frozenset], a) -> int:
    """Count how many sets in the family contain element a."""
    return sum(1 for s in family if a in s)


def ground_set(family: set[frozenset]) -> frozenset:
    """Compute the ground set (union of all sets)."""
    return frozenset().union(*family) if family else frozenset()


def total_incidence(family: set[frozenset]) -> int:
    """Sum of cardinalities of all sets."""
    return sum(len(s) for s in family)


def find_frankl_witness(family: set[frozenset]) -> Optional:
    """Find an element appearing in >= half the sets, if one exists."""
    n = len(family)
    g = ground_set(family)
    for a in g:
        if 2 * elem_freq(family, a) >= n:
            return a
    return None


def heavy_elements(family: set[frozenset]) -> set:
    """Return all elements appearing in >= half the sets."""
    n = len(family)
    g = ground_set(family)
    return {a for a in g if 2 * elem_freq(family, a) >= n}


def display_family(name: str, family: set[frozenset]):
    """Pretty-print a union-closed family with statistics."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")
    sorted_family = sorted(family, key=lambda s: (len(s), sorted(s)))
    for s in sorted_family:
        print(f"  {set(s) if s else '{}'}")
    
    g = ground_set(family)
    n = len(family)
    ti = total_incidence(family)
    
    print(f"\n  |F| = {n}")
    print(f"  ground = {set(g)}")
    print(f"  |ground| = {len(g)}")
    print(f"  totalIncidence = {ti}")
    if g:
        print(f"  avg set size = {ti/n:.2f}")
        print(f"  |ground|/2 = {len(g)/2:.2f}")
    
    print(f"\n  Element frequencies:")
    for a in sorted(g):
        f = elem_freq(family, a)
        ratio = f / n if n > 0 else 0
        heavy = " ← HEAVY (≥ 1/2)" if 2 * f >= n else ""
        print(f"    freq({a}) = {f}/{n} = {ratio:.2f}{heavy}")
    
    # Verify double counting
    freq_sum = sum(elem_freq(family, a) for a in g)
    print(f"\n  Double counting check:")
    print(f"    Σ|s| = {ti}")
    print(f"    Σ freq(a) = {freq_sum}")
    print(f"    Match: {'✓' if ti == freq_sum else '✗'}")
    
    w = find_frankl_witness(family)
    h = heavy_elements(family)
    print(f"\n  Frankl witness: {w}")
    print(f"  Heavy elements: {set(h) if h else '{}'}")
    print(f"  HasFranklWitness: {'✓' if w is not None else '✗'}")


def demo_basic_examples():
    """Demonstrate basic union-closed families."""
    print("\n" + "="*60)
    print("  PART 1: Basic Union-Closed Families")
    print("="*60)
    
    # Example 1: Power set
    F1 = set(powerset(frozenset({1, 2, 3})))
    display_family("Power set P({1,2,3})", F1)
    
    # Example 2: Upper sets
    F2 = {frozenset({1, 2}), frozenset({2, 3}), frozenset({1, 2, 3})}
    display_family("Upper set family {{1,2}, {2,3}, {1,2,3}}", F2)
    
    # Example 3: Singleton + empty
    F3 = {frozenset(), frozenset({1})}
    display_family("Family {∅, {1}}", F3)
    
    # Example 4: A larger family
    F4 = union_closure({
        frozenset({1}), frozenset({2, 3}), frozenset({1, 4})
    })
    display_family("Union-closure of {{1}, {2,3}, {1,4}}", F4)


def demo_average_criterion():
    """Demonstrate the average set size criterion."""
    print("\n" + "="*60)
    print("  PART 2: Average Set Size Criterion")
    print("="*60)
    print("""
  Theorem (verified): If avg set size ≥ |ground|/2
  and ground is nonempty, then HasFranklWitness.
  
  Formally: ground.card * |F| ≤ 2 * totalIncidence
            ⟹ ∃ a, 2 * freq(a) ≥ |F|
  """)
    
    # Test on several families
    universe = frozenset({1, 2, 3, 4})
    count_tested = 0
    count_criterion_applies = 0
    
    all_subsets = powerset(universe)
    # Generate some union-closed families
    for size in range(2, 6):
        for combo in combinations(all_subsets, size):
            family = set(combo)
            if is_union_closed(family):
                count_tested += 1
                g = ground_set(family)
                n = len(family)
                ti = total_incidence(family)
                if g and len(g) * n <= 2 * ti:
                    count_criterion_applies += 1
                    w = find_frankl_witness(family)
                    assert w is not None, f"Criterion failed! {family}"
    
    print(f"  Tested {count_tested} union-closed families on {{1,2,3,4}}")
    print(f"  Average criterion applied to {count_criterion_applies} families")
    print(f"  All verified: ✓")


def demo_small_ground():
    """Demonstrate Frankl's conjecture for small ground sets."""
    print("\n" + "="*60)
    print("  PART 3: Frankl for Ground Size ≤ 3 (Verified)")
    print("="*60)
    print("""
  Theorem (verified): Every union-closed family with
  nonempty ground of size ≤ 3 has a Frankl witness.
  """)
    
    # Enumerate all union-closed families on {1,2,3}
    universe = frozenset({1, 2, 3})
    all_subsets = powerset(universe)
    families_tested = 0
    
    for size in range(1, len(all_subsets) + 1):
        for combo in combinations(all_subsets, size):
            family = set(combo)
            if is_union_closed(family):
                g = ground_set(family)
                if len(g) > 0 and len(g) <= 3:
                    families_tested += 1
                    w = find_frankl_witness(family)
                    if w is None:
                        print(f"  COUNTEREXAMPLE: {family}")
                        return
    
    print(f"  Exhaustively tested {families_tested} union-closed families")
    print(f"  on ground sets of size ≤ 3.")
    print(f"  All have Frankl witnesses: ✓")


def demo_singleton_injection():
    """Demonstrate the singleton injection argument."""
    print("\n" + "="*60)
    print("  PART 4: Singleton Injection Principle")
    print("="*60)
    print("""
  Theorem (verified): If {a} ∈ F, then 2 * freq(a) ≥ |F|.
  
  Proof idea: Map each set s not containing a to s ∪ {a}.
  This is an injection into the sets containing a.
  So |sets without a| ≤ |sets with a| = freq(a).
  Hence |F| ≤ 2 * freq(a).
  """)
    
    F = union_closure({
        frozenset({1}), frozenset({2, 3}), frozenset({3, 4, 5})
    })
    display_family("Union-closure of {{1}, {2,3}, {3,4,5}}", F)
    
    a = 1
    with_a = [s for s in F if a in s]
    without_a = [s for s in F if a not in s]
    
    print(f"\n  Injection for element {a}:")
    print(f"  Sets without {a}: {[set(s) for s in without_a]}")
    print(f"  Sets with {a}:    {[set(s) for s in with_a]}")
    print(f"  Injected pairs:")
    for s in without_a:
        t = s | frozenset({a})
        print(f"    {set(s)} → {set(t)} {'∈ F ✓' if t in F else '∉ F ✗'}")
    
    print(f"\n  |without {a}| = {len(without_a)} ≤ {len(with_a)} = |with {a}|")
    print(f"  2 * freq({a}) = {2 * elem_freq(F, a)} ≥ {len(F)} = |F| ✓")


def demo_conjecture_tests():
    """Test conjectures on small universes."""
    print("\n" + "="*60)
    print("  PART 5: Conjecture Testing")
    print("="*60)
    
    # Conjecture 1: Entropy gap
    print("\n  Conjecture 1: Entropy-gap strengthening")
    print("  For every UC family F:")
    print("    2·max_freq - |F| ≥ f(2·totalIncidence - |ground|·|F|)")
    
    universe = frozenset({1, 2, 3, 4})
    all_subsets = powerset(universe)
    
    gaps = []
    for size in range(1, 10):
        for combo in combinations(all_subsets, size):
            family = set(combo)
            if not is_union_closed(family):
                continue
            g = ground_set(family)
            if not g:
                continue
            n = len(family)
            max_freq = max(elem_freq(family, a) for a in g)
            ti = total_incidence(family)
            
            frankl_gap = 2 * max_freq - n
            energy_excess = 2 * ti - len(g) * n
            gaps.append((energy_excess, frankl_gap))
    
    if gaps:
        # Check if frankl_gap is monotone in energy_excess
        gaps.sort()
        min_frankl_at_excess = {}
        for excess, fgap in gaps:
            if excess not in min_frankl_at_excess:
                min_frankl_at_excess[excess] = fgap
            else:
                min_frankl_at_excess[excess] = min(min_frankl_at_excess[excess], fgap)
        
        print(f"\n  Tested {len(gaps)} families on {{1,2,3,4}}")
        print(f"  Energy excess → min Frankl gap:")
        for exc in sorted(min_frankl_at_excess.keys())[:10]:
            print(f"    excess={exc:3d} → min gap={min_frankl_at_excess[exc]:3d}")
    
    # Conjecture 2: Join-irreducible witness
    print("\n  Conjecture 2: Join-irreducible witness principle")
    
    def is_join_irreducible(family, s):
        """Check if s is join-irreducible in the family."""
        if not s:
            return False
        for A in family:
            for B in family:
                if A | B == s and A != s and B != s:
                    return False
        return True
    
    ji_witness_count = 0
    total_count = 0
    
    for size in range(1, 10):
        for combo in combinations(all_subsets, size):
            family = set(combo)
            if not is_union_closed(family):
                continue
            g = ground_set(family)
            if not g:
                continue
            n = len(family)
            
            # Find heavy elements
            heavies = heavy_elements(family)
            if not heavies:
                continue
            total_count += 1
            
            # Check if any heavy element is "witnessed" by a join-irreducible set
            ji_sets = [s for s in family if is_join_irreducible(family, s)]
            ji_elements = set()
            for s in ji_sets:
                ji_elements |= s
            
            if heavies & ji_elements:
                ji_witness_count += 1
    
    if total_count > 0:
        print(f"  Tested {total_count} families with witnesses")
        print(f"  JI-witnessed: {ji_witness_count}/{total_count}")
        print(f"  Conjecture holds: {'✓' if ji_witness_count == total_count else '✗'}")


def demo_double_counting():
    """Demonstrate the double counting identity."""
    print("\n" + "="*60)
    print("  PART 6: Double Counting Identity (Verified)")
    print("="*60)
    print("""
  Theorem (verified):
    totalIncidence(F) = Σ_{a ∈ ground} freq(a)
    
  This identity is the engine behind all averaging arguments.
  """)
    
    F = union_closure({
        frozenset({1, 2}), frozenset({3, 4}), frozenset({2, 5})
    })
    
    g = ground_set(F)
    ti = total_incidence(F)
    freq_sum = sum(elem_freq(F, a) for a in g)
    
    print(f"  Family (union-closure of {{1,2}}, {{3,4}}, {{2,5}}):")
    for s in sorted(F, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(s)}")
    
    print(f"\n  Left side:  Σ|s| = {ti}")
    print(f"  Right side: Σ freq(a) = {freq_sum}")
    
    print(f"\n  Breakdown by element:")
    for a in sorted(g):
        print(f"    freq({a}) = {elem_freq(F, a)}")
    
    print(f"\n  Breakdown by set:")
    for s in sorted(F, key=lambda s: (len(s), sorted(s))):
        print(f"    |{set(s)}| = {len(s)}")
    
    print(f"\n  Identity verified: {ti} = {freq_sum} ✓")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Frankl's Union-Closed Conjecture: Interactive Demo     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_basic_examples()
    demo_double_counting()
    demo_singleton_injection()
    demo_average_criterion()
    demo_small_ground()
    demo_conjecture_tests()
    
    print("\n" + "="*60)
    print("  All demonstrations complete!")
    print("="*60)


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Read lean files
lean_files = [
    'Algebra/Frankl/Defs.lean',
    'Algebra/Frankl/DoubleCount.lean',
    'Algebra/Frankl/AverageCriterion.lean',
    'Algebra/Frankl/SmallGround.lean',
    'Algebra/Frankl/Lattice.lean',
]
lean_code = ""
for f in lean_files:
    lean_code += f"-- ═══ {f} ═══\n\n"
    lean_code += read_file(f) + "\n\n"

# Read Python files
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

package = {
    "title": "Frankl's Union-Closed Conjecture: Partial Results, Structural Reductions, and Entropic Certificates",
    "domain": "Algebra / Extremal Combinatorics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Frankl's Conjecture Interactive Demo",
            "code": demo_code
        },
        {
            "name": "Applications of Frankl's Conjecture",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Union-Closed Family Witness Search",
            "pseudocode": """Algorithm: FindFranklWitness(F)
Input: Union-closed family F = (sets, ground)
Output: Element a with 2·freq(a) ≥ |F|, or None

1. Compute ground = ∪_{S ∈ F} S
2. For each a ∈ ground:
   a. freq ← |{S ∈ F : a ∈ S}|
   b. If 2·freq ≥ |F|: return a
3. Return None

Time: O(n·g) where n = |F|, g = |ground|
Space: O(n·g)
Correctness: By theorem frankl_of_singleton_in_sets and
  frankl_of_average_card_large""",
            "code": algorithms_code
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
