#!/usr/bin/env python3
"""
Applications of Frankl's Union-Closed Conjecture

Demonstrates connections to:
1. Database theory (closed itemsets in data mining)
2. Network reliability (monotone systems)
3. Information theory (entropy of set families)
4. Social choice theory (coalition structures)
"""

import math
from collections import defaultdict
from itertools import combinations


# ============================================================
# Application 1: Data Mining — Closed Itemsets
# ============================================================

def closed_itemset_analysis(transactions: list[set], min_support: float = 0.5):
    """
    In data mining, a set of items is "closed" if no proper superset
    has the same support. The collection of closed itemsets forms a
    union-closed family (actually, intersection-closed, which is dual).
    
    Frankl's conjecture, applied to the dual family, implies:
    there exists an item appearing in at least half the closed itemsets.
    This item is a "universal feature" of the dataset.
    
    Args:
        transactions: List of itemsets (purchase baskets, etc.)
        min_support: Minimum frequency threshold
    """
    print("=" * 60)
    print("APPLICATION 1: Data Mining — Closed Itemsets")
    print("=" * 60)
    
    # Compute support of each itemset
    all_items = set()
    for t in transactions:
        all_items |= t
    
    def support(itemset):
        return sum(1 for t in transactions if itemset <= t) / len(transactions)
    
    # Find frequent closed itemsets
    # (simplified: enumerate and check closure)
    closed = []
    for size in range(len(all_items) + 1):
        for combo in combinations(sorted(all_items), size):
            itemset = frozenset(combo)
            supp = support(itemset)
            if supp >= min_support:
                # Check if closed: no proper superset has same support
                is_closed = True
                for item in all_items - itemset:
                    if support(itemset | {item}) == supp:
                        is_closed = False
                        break
                if is_closed:
                    closed.append((itemset, supp))
    
    print(f"\n  Transactions: {len(transactions)}")
    print(f"  Items: {sorted(all_items)}")
    print(f"  Frequent closed itemsets (support ≥ {min_support}):")
    
    family = set()
    for itemset, supp in closed:
        family.add(itemset)
        print(f"    {set(itemset) if itemset else '∅'}: support = {supp:.2f}")
    
    # Check Frankl's property on the complement family
    if family:
        universe = set()
        for s in family:
            universe |= s
        
        abundances = {}
        for x in universe:
            abundances[x] = sum(1 for s in family if x in s)
        
        if abundances:
            best = max(abundances, key=abundances.get)
            print(f"\n  Most frequent item across closed itemsets: '{best}'")
            print(f"    Appears in {abundances[best]}/{len(family)} closed itemsets "
                  f"({abundances[best]/len(family)*100:.0f}%)")
            print(f"    Frankl's conjecture predicts: ≥ {len(family)/2:.0f} ({50}%)")


# ============================================================
# Application 2: Network Reliability
# ============================================================

def network_reliability_demo():
    """
    In network reliability, the collection of "working configurations"
    (sets of edges that maintain connectivity) forms a union-closed family
    — if two configurations each work, their union also works.
    
    Frankl's conjecture implies: there exists an edge that appears in
    at least half of all minimal-or-larger working configurations.
    This edge is the most "critical" for reliability.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Reliability")
    print("=" * 60)
    
    # Simple network: triangle with one extra edge
    # Edges: {a-b, b-c, a-c, c-d}
    # Working = connected subgraphs spanning {a,b,c,d}
    
    edges = ['ab', 'bc', 'ac', 'cd']
    nodes = {'a', 'b', 'c', 'd'}
    
    def is_connected(edge_set):
        """Check if the edge set connects all nodes."""
        if not edge_set:
            return False
        adj = defaultdict(set)
        used_nodes = set()
        for e in edge_set:
            u, v = e[0], e[1]
            adj[u].add(v)
            adj[v].add(u)
            used_nodes.add(u)
            used_nodes.add(v)
        
        if used_nodes != nodes:
            return False
        
        # BFS from first node
        start = next(iter(nodes))
        visited = {start}
        queue = [start]
        while queue:
            u = queue.pop(0)
            for v in adj[u]:
                if v not in visited:
                    visited.add(v)
                    queue.append(v)
        
        return visited == nodes
    
    # Enumerate all working configurations
    working = set()
    for r in range(1, len(edges) + 1):
        for combo in combinations(edges, r):
            if is_connected(combo):
                working.add(frozenset(combo))
    
    print(f"\n  Network: {nodes}")
    print(f"  Edges: {edges}")
    print(f"  Working configurations: {len(working)}")
    
    # Verify union-closure
    is_uc = True
    for A in working:
        for B in working:
            if A | B not in working:
                is_uc = False
                break
        if not is_uc:
            break
    
    print(f"  Union-closed: {is_uc}")
    
    # Find most critical edge
    for e in edges:
        ab = sum(1 for w in working if e in w)
        print(f"  Edge '{e}': appears in {ab}/{len(working)} working configs "
              f"({ab/len(working)*100:.0f}%)")
    
    best_edge = max(edges, key=lambda e: sum(1 for w in working if e in w))
    best_count = sum(1 for w in working if best_edge in w)
    print(f"\n  Most critical edge: '{best_edge}' (abundance = {best_count})")
    print(f"  Frankl prediction: ≥ {len(working)//2} ✓" 
          if 2 * best_count >= len(working) else "  Frankl prediction: FAILED ✗")


# ============================================================
# Application 3: Entropy Analysis
# ============================================================

def entropy_analysis_demo():
    """
    View a union-closed family as a probability space (uniform distribution).
    Each element x defines a binary random variable X_x = 1[x ∈ S].
    
    Frankl's conjecture says: max_x P(X_x = 1) ≥ 1/2.
    
    The entropy approach (Reimer) uses: H(S) ≤ ∑_x H(X_x)
    to derive frequency bounds.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Entropy Analysis of Union-Closed Families")
    print("=" * 60)
    
    def binary_entropy(p):
        """H(p) = -p log₂(p) - (1-p) log₂(1-p)"""
        if p <= 0 or p >= 1:
            return 0.0
        return -p * math.log2(p) - (1 - p) * math.log2(1 - p)
    
    # Generate some interesting union-closed families
    families = {
        "Power set of {0,1,2}": [frozenset(c) for r in range(4) 
                                   for c in combinations(range(3), r)],
        "Chain {∅,{0},{0,1},{0,1,2}}": [frozenset(), frozenset({0}), 
                                          frozenset({0,1}), frozenset({0,1,2})],
        "Generated by {{0,1},{1,2}}": None,  # will compute
    }
    
    # Compute closure for the generated family
    gens = {frozenset({0, 1}), frozenset({1, 2})}
    closure = set(gens)
    changed = True
    while changed:
        changed = False
        for A in list(closure):
            for B in list(closure):
                u = A | B
                if u not in closure:
                    closure.add(u)
                    changed = True
    families["Generated by {{0,1},{1,2}}"] = list(closure)
    
    for name, family in families.items():
        n = len(family)
        universe = frozenset()
        for s in family:
            universe |= s
        
        print(f"\n  Family: {name}")
        print(f"    |F| = {n}, |U| = {len(universe)}")
        print(f"    H(S) = log₂({n}) = {math.log2(n):.3f} bits")
        
        total_coord_entropy = 0
        for x in sorted(universe):
            freq = sum(1 for s in family if x in s) / n
            h = binary_entropy(freq)
            total_coord_entropy += h
            print(f"    P(x={x} ∈ S) = {freq:.3f}, H(X_{x}) = {h:.3f}")
        
        print(f"    ∑ H(X_x) = {total_coord_entropy:.3f}")
        print(f"    Subadditivity gap: {total_coord_entropy - math.log2(n):.3f} ≥ 0: "
              f"{'✓' if total_coord_entropy >= math.log2(n) - 0.001 else '✗'}")


# ============================================================
# Application 4: Social Choice — Coalition Analysis
# ============================================================

def social_choice_demo():
    """
    In social choice theory, a collection of "winning coalitions"
    often forms a union-closed family: if two coalitions can each
    pass a motion, their union can too.
    
    Frankl's conjecture implies: there exists a voter who belongs to
    at least half of all winning coalitions — a "powerful" voter.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Social Choice — Winning Coalitions")
    print("=" * 60)
    
    # UN Security Council-inspired voting
    # 5 permanent members (P1-P5), 10 non-permanent (N1-N10)
    # A resolution passes if: all 5 permanent + at least 4 non-permanent
    
    permanent = {f'P{i}' for i in range(1, 6)}
    non_permanent = {f'N{i}' for i in range(1, 6)}  # simplified to 5
    all_members = permanent | non_permanent
    
    # Simplified: need all permanent + ≥ 2 non-permanent
    winning = set()
    for r in range(2, len(non_permanent) + 1):
        for combo in combinations(sorted(non_permanent), r):
            coalition = frozenset(permanent | set(combo))
            winning.add(coalition)
    
    print(f"\n  Voting body: {len(all_members)} members")
    print(f"    Permanent: {sorted(permanent)}")
    print(f"    Non-permanent: {sorted(non_permanent)}")
    print(f"  Winning coalitions: {len(winning)}")
    
    # Verify union-closure (should hold since adding members preserves winning)
    is_uc = True
    for A in winning:
        for B in winning:
            if A | B not in winning:
                is_uc = False
                break
    
    print(f"  Union-closed: {is_uc}")
    
    # Power analysis
    print(f"\n  Power analysis (abundance in winning coalitions):")
    for member in sorted(all_members):
        ab = sum(1 for w in winning if member in w)
        pct = ab / len(winning) * 100
        marker = "★" if ab == len(winning) else ("✓" if 2 * ab >= len(winning) else "")
        print(f"    {member}: {ab}/{len(winning)} ({pct:.0f}%) {marker}")
    
    print(f"\n  Frankl's prediction: ∃ member in ≥ {len(winning)//2} coalitions")
    print(f"  Permanent members appear in ALL coalitions (100%) — much stronger!")


if __name__ == "__main__":
    # Application 1: Data Mining
    transactions = [
        {'bread', 'milk', 'eggs'},
        {'bread', 'butter'},
        {'milk', 'eggs'},
        {'bread', 'milk', 'butter'},
        {'bread', 'eggs'},
        {'milk', 'butter'},
        {'bread', 'milk'},
        {'bread', 'milk', 'eggs', 'butter'},
    ]
    closed_itemset_analysis(transactions, min_support=0.3)
    
    # Application 2: Network Reliability
    network_reliability_demo()
    
    # Application 3: Entropy
    entropy_analysis_demo()
    
    # Application 4: Social Choice
    social_choice_demo()
    
    print("\n" + "=" * 60)
    print("All application demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Frankl's Union-Closed Conjecture: Interactive Demonstrations

This module demonstrates key properties of union-closed families,
including abundance counting, the double-counting identity, and
verification of Frankl's property for small families.
"""

from itertools import combinations
from typing import FrozenSet, Set


def is_union_closed(family: set[frozenset]) -> bool:
    """Check if a family of sets is union-closed."""
    for A in family:
        for B in family:
            if A | B not in family:
                return False
    return True


def abundance(family: set[frozenset], x) -> int:
    """Count how many sets in the family contain element x."""
    return sum(1 for s in family if x in s)


def family_universe(family: set[frozenset]) -> frozenset:
    """Compute the universe (union of all sets) of a family."""
    result = frozenset()
    for s in family:
        result = result | s
    return result


def frankl_property(family: set[frozenset]) -> tuple[bool, dict]:
    """Check if the family satisfies Frankl's property.
    
    Returns (satisfied, details) where details contains abundances.
    """
    universe = family_universe(family)
    n = len(family)
    abundances = {x: abundance(family, x) for x in universe}
    
    best_element = max(abundances, key=abundances.get) if abundances else None
    best_abundance = abundances[best_element] if best_element is not None else 0
    satisfied = 2 * best_abundance >= n
    
    return satisfied, {
        'family_size': n,
        'universe': universe,
        'abundances': abundances,
        'best_element': best_element,
        'best_abundance': best_abundance,
        'threshold': n / 2,
    }


def generate_union_closure(generators: set[frozenset]) -> set[frozenset]:
    """Generate the union-closure of a set of generators."""
    family = set(generators)
    changed = True
    while changed:
        changed = False
        new_sets = set()
        for A in family:
            for B in family:
                union = A | B
                if union not in family:
                    new_sets.add(union)
                    changed = True
        family |= new_sets
    return family


def enumerate_union_closed_families(universe_size: int) -> list[set[frozenset]]:
    """Enumerate all nonempty union-closed families over {0, ..., n-1}
    that contain at least one nonempty set."""
    universe = list(range(universe_size))
    
    # Generate all possible subsets
    all_subsets = []
    for r in range(universe_size + 1):
        for combo in combinations(universe, r):
            all_subsets.append(frozenset(combo))
    
    families = []
    # Try all nonempty subsets of the power set
    for size in range(1, len(all_subsets) + 1):
        for combo in combinations(all_subsets, size):
            family = set(combo)
            if is_union_closed(family) and any(len(s) > 0 for s in family):
                families.append(family)
    
    return families


def verify_double_counting(family: set[frozenset], universe: frozenset) -> dict:
    """Verify the double-counting identity: sum of |s| = sum of abundances."""
    sum_sizes = sum(len(s) for s in family)
    sum_abundances = sum(abundance(family, x) for x in universe)
    
    return {
        'sum_of_sizes': sum_sizes,
        'sum_of_abundances': sum_abundances,
        'identity_holds': sum_sizes == sum_abundances,
    }


def demo_basic():
    """Demonstrate basic definitions and properties."""
    print("=" * 60)
    print("DEMO 1: Basic Union-Closed Family Properties")
    print("=" * 60)
    
    # Example family over {0, 1, 2}
    F = {
        frozenset(),
        frozenset({0}),
        frozenset({1}),
        frozenset({0, 1}),
        frozenset({0, 1, 2}),
    }
    
    print(f"\nFamily F = {{{', '.join(str(set(s)) if s else '∅' for s in sorted(F, key=len))}}}")
    print(f"  |F| = {len(F)}")
    print(f"  Union-closed: {is_union_closed(F)}")
    
    universe = family_universe(F)
    print(f"  Universe: {set(universe)}")
    
    for x in sorted(universe):
        a = abundance(F, x)
        print(f"  abundance({x}) = {a}  {'✓' if 2*a >= len(F) else '✗'} (need ≥ {len(F)/2:.1f})")
    
    satisfied, details = frankl_property(F)
    print(f"\n  Frankl's property: {'SATISFIED ✓' if satisfied else 'NOT SATISFIED ✗'}")
    print(f"  Best element: {details['best_element']} with abundance {details['best_abundance']}")


def demo_double_counting():
    """Demonstrate the double-counting identity."""
    print("\n" + "=" * 60)
    print("DEMO 2: Double-Counting Identity")
    print("=" * 60)
    
    families = [
        ({frozenset({0}), frozenset({0, 1}), frozenset({0, 1, 2})}, "chain family"),
        ({frozenset({0}), frozenset({1}), frozenset({0, 1})}, "two singletons + union"),
        ({frozenset(), frozenset({0, 1}), frozenset({0, 1, 2}), frozenset({2}), frozenset({0, 1, 2})}, "mixed"),
    ]
    
    for family, name in families:
        universe = family_universe(family)
        result = verify_double_counting(family, universe)
        print(f"\n  {name}:")
        print(f"    ∑|s| = {result['sum_of_sizes']}")
        print(f"    ∑ abundance(x) = {result['sum_of_abundances']}")
        print(f"    Identity holds: {'✓' if result['identity_holds'] else '✗'}")


def demo_exhaustive_verification():
    """Exhaustively verify Frankl's property for small universes."""
    print("\n" + "=" * 60)
    print("DEMO 3: Exhaustive Verification for Small Universes")
    print("=" * 60)
    
    for n in range(1, 4):
        families = enumerate_union_closed_families(n)
        all_satisfy = True
        counterexample = None
        
        for F in families:
            satisfied, details = frankl_property(F)
            if not satisfied:
                all_satisfy = False
                counterexample = F
                break
        
        status = "ALL SATISFY ✓" if all_satisfy else f"COUNTEREXAMPLE FOUND ✗"
        print(f"\n  Universe size {n}: {len(families)} union-closed families (with nonempty member)")
        print(f"    Frankl's property: {status}")
        
        if not all_satisfy and counterexample:
            print(f"    Counterexample: {counterexample}")


def demo_union_closure():
    """Demonstrate union-closure generation from generators."""
    print("\n" + "=" * 60)
    print("DEMO 4: Union-Closure from Generators")
    print("=" * 60)
    
    generators_list = [
        ({frozenset({0}), frozenset({1})}, "{{0}, {1}}"),
        ({frozenset({0, 1}), frozenset({1, 2})}, "{{0,1}, {1,2}}"),
        ({frozenset({0}), frozenset({1}), frozenset({2})}, "{{0}, {1}, {2}}"),
    ]
    
    for generators, name in generators_list:
        closure = generate_union_closure(generators)
        print(f"\n  Generators: {name}")
        print(f"  Closure: {{{', '.join(str(set(s)) if s else '∅' for s in sorted(closure, key=lambda s: (len(s), sorted(s))))}}} ({len(closure)} sets)")
        
        satisfied, details = frankl_property(closure)
        print(f"  Frankl's property: {'✓' if satisfied else '✗'}")
        if details['best_element'] is not None:
            print(f"  Most abundant element: {details['best_element']} (abundance = {details['best_abundance']}/{details['family_size']})")


def demo_structural_insight():
    """Demonstrate the key structural insight: the universe is always in the family."""
    print("\n" + "=" * 60)
    print("DEMO 5: Structural Insight — Universe Membership")
    print("=" * 60)
    
    generators_list = [
        {frozenset({0, 2}), frozenset({1, 3}), frozenset({2, 3})},
        {frozenset({0}), frozenset({1, 2}), frozenset({3, 4})},
    ]
    
    for generators in generators_list:
        closure = generate_union_closure(generators)
        universe = family_universe(closure)
        
        print(f"\n  Generators: {{{', '.join(str(set(s)) for s in generators)}}}")
        print(f"  Family size: {len(closure)}")
        print(f"  Universe: {set(universe)}")
        print(f"  Universe ∈ F: {universe in closure} ✓")
        
        # Show elements in non-maximal members get abundance ≥ 2
        for s in sorted(closure, key=lambda s: (len(s), sorted(s))):
            if s != universe and len(s) > 0:
                for x in sorted(s):
                    a = abundance(closure, x)
                    print(f"    {x} ∈ {set(s)} (non-maximal): abundance = {a} ≥ 2 {'✓' if a >= 2 else '✗'}")
                break  # Just show one example


if __name__ == "__main__":
    demo_basic()
    demo_double_counting()
    demo_exhaustive_verification()
    demo_union_closure()
    demo_structural_insight()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Frankl's Union-Closed Conjecture

Generates charts showing:
1. Abundance distribution across families
2. Family lattice structure (Hasse diagram)
3. Exhaustive verification heatmap
4. Double-counting identity visualization
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def is_union_closed(family):
    for A in family:
        for B in family:
            if A | B not in family:
                return False
    return True


def abundance(family, x):
    return sum(1 for s in family if x in s)


def generate_union_closure(generators):
    family = set(generators)
    changed = True
    while changed:
        changed = False
        new_sets = set()
        for A in family:
            for B in family:
                u = A | B
                if u not in family:
                    new_sets.add(u)
                    changed = True
        family |= new_sets
    return family


def viz_abundance_distribution():
    """Visualize abundance distributions for various union-closed families."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("Abundance Distributions in Union-Closed Families", fontsize=16, fontweight='bold')
    
    families = [
        ("Power set of {0,1,2}", 
         {frozenset(c) for r in range(4) for c in combinations(range(3), r)}),
        ("Chain: ∅ ⊂ {0} ⊂ {0,1} ⊂ {0,1,2}", 
         {frozenset(), frozenset({0}), frozenset({0,1}), frozenset({0,1,2})}),
        ("Generated by {{0,1}, {1,2}, {0,2}}", 
         generate_union_closure({frozenset({0,1}), frozenset({1,2}), frozenset({0,2})})),
        ("Generated by {{0}, {1,2}, {2,3}}", 
         generate_union_closure({frozenset({0}), frozenset({1,2}), frozenset({2,3})})),
    ]
    
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
    
    for ax, (name, family), color in zip(axes.flat, families, colors):
        universe = frozenset()
        for s in family:
            universe |= s
        
        elements = sorted(universe)
        abundances = [abundance(family, x) for x in elements]
        threshold = len(family) / 2
        
        bars = ax.bar([str(x) for x in elements], abundances, color=color, alpha=0.8, edgecolor='white')
        ax.axhline(y=threshold, color='red', linestyle='--', linewidth=2, label=f'|F|/2 = {threshold}')
        
        # Highlight elements meeting Frankl threshold
        for bar, ab in zip(bars, abundances):
            if ab >= threshold:
                bar.set_edgecolor('gold')
                bar.set_linewidth(3)
        
        ax.set_title(name, fontsize=11)
        ax.set_xlabel('Element')
        ax.set_ylabel('Abundance')
        ax.set_ylim(0, max(abundances) * 1.2 if abundances else 1)
        ax.legend(fontsize=9)
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_abundance.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_exhaustive_verification():
    """Heatmap of family sizes and Frankl verification status."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # For universe sizes 1-3, count families by size and verify Frankl
    data = {}
    for n in range(1, 4):
        all_subsets = []
        for r in range(n + 1):
            for combo in combinations(range(n), r):
                all_subsets.append(frozenset(combo))
        
        size_counts = defaultdict(lambda: [0, 0])  # [satisfy, total]
        
        for fam_size in range(1, len(all_subsets) + 1):
            for combo in combinations(all_subsets, fam_size):
                family = set(combo)
                if not is_union_closed(family):
                    continue
                if not any(len(s) > 0 for s in family):
                    continue
                
                universe = frozenset()
                for s in family:
                    universe |= s
                
                abundances = {x: abundance(family, x) for x in universe}
                if abundances:
                    best_ab = max(abundances.values())
                    satisfies = 2 * best_ab >= len(family)
                else:
                    satisfies = False
                
                size_counts[(n, fam_size)][1] += 1
                if satisfies:
                    size_counts[(n, fam_size)][0] += 1
        
        data[n] = size_counts
    
    # Create bar chart
    bar_data = []
    labels = []
    for n in range(1, 4):
        total = sum(v[1] for v in data[n].values())
        satisfying = sum(v[0] for v in data[n].values())
        bar_data.append((total, satisfying))
        labels.append(f"|U| = {n}")
    
    x = np.arange(len(labels))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, [d[0] for d in bar_data], width, 
                    label='Total UC families', color='#90CAF9', edgecolor='white')
    bars2 = ax.bar(x + width/2, [d[1] for d in bar_data], width,
                    label='Satisfy Frankl', color='#4CAF50', edgecolor='white')
    
    ax.set_xlabel('Universe Size', fontsize=12)
    ax.set_ylabel('Number of Families', fontsize=12)
    ax.set_title('Exhaustive Verification: All Union-Closed Families Satisfy Frankl\'s Property', 
                  fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend(fontsize=11)
    
    # Add count labels
    for bar in bars1:
        height = bar.get_height()
        ax.annotate(f'{int(height)}', xy=(bar.get_x() + bar.get_width()/2, height),
                    xytext=(0, 3), textcoords="offset points", ha='center', fontsize=10)
    for bar in bars2:
        height = bar.get_height()
        ax.annotate(f'{int(height)}', xy=(bar.get_x() + bar.get_width()/2, height),
                    xytext=(0, 3), textcoords="offset points", ha='center', fontsize=10)
    
    ax.text(0.5, 0.95, '100% verification rate for |U| ≤ 3 ✓', 
            transform=ax.transAxes, ha='center', fontsize=12, color='green',
            fontweight='bold', bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.3))
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_verification.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_double_counting():
    """Visualize the double-counting identity."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    family = generate_union_closure({frozenset({0,1}), frozenset({1,2}), frozenset({0,3})})
    family_list = sorted(family, key=lambda s: (len(s), sorted(s)))
    
    universe = frozenset()
    for s in family:
        universe |= s
    elements = sorted(universe)
    
    # Left: sum of set sizes
    ax = axes[0]
    sizes = [len(s) for s in family_list]
    set_labels = [str(set(s)) if s else '∅' for s in family_list]
    bars = ax.bar(range(len(sizes)), sizes, color='#2196F3', alpha=0.8, edgecolor='white')
    ax.set_xticks(range(len(sizes)))
    ax.set_xticklabels(set_labels, rotation=45, ha='right', fontsize=8)
    ax.set_ylabel('Set Size |s|', fontsize=12)
    ax.set_title(f'Sum of Set Sizes = {sum(sizes)}', fontsize=13, fontweight='bold')
    
    # Right: sum of abundances
    ax = axes[1]
    abundances_list = [abundance(family, x) for x in elements]
    bars = ax.bar([str(x) for x in elements], abundances_list, color='#4CAF50', alpha=0.8, edgecolor='white')
    threshold = len(family) / 2
    ax.axhline(y=threshold, color='red', linestyle='--', linewidth=2, label=f'|F|/2 = {threshold:.1f}')
    ax.set_ylabel('Abundance', fontsize=12)
    ax.set_xlabel('Element', fontsize=12)
    ax.set_title(f'Sum of Abundances = {sum(abundances_list)}', fontsize=13, fontweight='bold')
    ax.legend()
    
    fig.suptitle('Double-Counting Identity: ∑|s| = ∑ abundance(x)', fontsize=15, fontweight='bold', y=1.02)
    
    # Verify
    assert sum(sizes) == sum(abundances_list), "Double-counting identity failed!"
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_double_counting.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_lattice_structure():
    """Visualize the lattice structure of a union-closed family."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    
    family = generate_union_closure({frozenset({0}), frozenset({1}), frozenset({2})})
    family_list = sorted(family, key=lambda s: (len(s), sorted(s)))
    
    # Assign positions by level (set size)
    levels = defaultdict(list)
    for s in family_list:
        levels[len(s)].append(s)
    
    positions = {}
    for level, sets_at_level in levels.items():
        n = len(sets_at_level)
        for i, s in enumerate(sets_at_level):
            x = (i - (n - 1) / 2) * 2
            y = level * 2
            positions[s] = (x, y)
    
    # Draw edges (covering relations)
    for s in family_list:
        for t in family_list:
            if s < t and len(t) == len(s) + 1:
                x1, y1 = positions[s]
                x2, y2 = positions[t]
                ax.plot([x1, x2], [y1, y2], 'gray', linewidth=1, alpha=0.5)
    
    # Draw nodes
    universe = frozenset()
    for s in family:
        universe |= s
    
    for s in family_list:
        x, y = positions[s]
        
        # Color by maximum abundance of elements in s
        if s:
            max_ab = max(abundance(family, elem) for elem in s)
            intensity = max_ab / len(family)
        else:
            intensity = 0
        
        color = plt.cm.YlOrRd(intensity * 0.8 + 0.1)
        
        label = str(set(s)) if s else '∅'
        circle = plt.Circle((x, y), 0.4, color=color, ec='black', linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=8, fontweight='bold', zorder=4)
    
    ax.set_xlim(-5, 5)
    ax.set_ylim(-1, max(levels.keys()) * 2 + 1)
    ax.set_aspect('equal')
    ax.set_title('Lattice Structure of Union-Closed Family\nGenerated by {{0}, {1}, {2}} = Full Power Set', 
                  fontsize=14, fontweight='bold')
    ax.axis('off')
    
    # Add legend
    legend_elements = [
        mpatches.Patch(color=plt.cm.YlOrRd(0.1), label='Low abundance'),
        mpatches.Patch(color=plt.cm.YlOrRd(0.9), label='High abundance'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10)
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_lattice.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = viz_abundance_distribution()
    print(f"  viz_abundance.png generated ({len(b64_1)} chars)")
    
    b64_2 = viz_exhaustive_verification()
    print(f"  viz_verification.png generated ({len(b64_2)} chars)")
    
    b64_3 = viz_double_counting()
    print(f"  viz_double_counting.png generated ({len(b64_3)} chars)")
    
    b64_4 = viz_lattice_structure()
    print(f"  viz_lattice.png generated ({len(b64_4)} chars)")
    
    print("\nAll visualizations generated successfully.")
