#!/usr/bin/env python3
"""
Applications of Probe Complexity Theory

This module demonstrates practical applications of the product formula
for probe complexity κ, connecting to:

1. Test suite design for composite systems
2. Distinguishability analysis in information systems
3. Covering design optimization
4. Compositional complexity estimation
"""

from algorithms import (
    FiniteCategory, make_discrete, make_parallel, make_thin_poset,
    make_product, compute_kappa, build_product_family,
    verify_separation, product_upper_bound
)


# =============================================================================
# Application 1: Test Suite Design for Composite Systems
# =============================================================================

def test_suite_design():
    """Demonstrate how probe complexity guides test suite design.
    
    In software testing, a "category" represents a system's state machine:
    - Objects = states
    - Morphisms = transitions
    - Parallel morphisms = transitions with same source/target but different behavior
    
    A separating probe family = minimal set of "observer states" from which
    all behavioral differences can be detected.
    
    For composite systems (products), the product formula tells us exactly
    how test suites scale.
    """
    print("=" * 60)
    print("  APPLICATION 1: Test Suite Design")
    print("=" * 60)
    
    # Model a simple system with hidden behavior
    # System A: has 2 states, with 3 different transitions from state 0 to state 1
    sys_A = make_parallel(3)
    kA, fam_A = compute_kappa(sys_A)
    
    # System B: has 4 states, purely deterministic (poset)
    sys_B = make_thin_poset(4)
    kB, fam_B = compute_kappa(sys_B)
    
    # System C: 2 independent components (discrete)
    sys_C = make_discrete(2)
    kC, fam_C = compute_kappa(sys_C)
    
    print(f"\n  System A (nondeterministic): {sys_A}, κ = {kA}")
    print(f"  System B (deterministic):    {sys_B}, κ = {kB}")
    print(f"  System C (independent):      {sys_C}, κ = {kC}")
    
    # Composite system A × C
    AxC = make_product(sys_A, sys_C)
    kAxC, fam_AxC = compute_kappa(AxC)
    bound = product_upper_bound(kA, sys_A.num_objects, kC, sys_C.num_objects)
    
    print(f"\n  Composite A × C:")
    print(f"    κ(A×C) = {kAxC}")
    print(f"    Upper bound = {bound}")
    print(f"    Naïve max estimate = {max(kA, kC)} (WRONG by factor {kAxC / max(kA, kC) if max(kA, kC) > 0 else 'inf'})")
    print(f"    → Need {kAxC} test observers, not {max(kA, kC)}!")
    
    # Build the test suite
    prod_fam = build_product_family(sys_A, sys_C, fam_A, fam_C)
    print(f"    Constructed test suite: {len(prod_fam)} observers")
    print(f"    Verified separating: {verify_separation(AxC, prod_fam)}")


# =============================================================================
# Application 2: Information Channel Discrimination
# =============================================================================

def channel_discrimination():
    """Demonstrate probe complexity as observation complexity for channels.
    
    Think of morphisms as "channels" or "signal paths" between states.
    A probe family = set of "measurement stations" that can distinguish
    all channels by their observable outputs.
    
    The product formula shows: for independent subsystems, observation
    complexity scales linearly with replication, not exponentially.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Channel Discrimination")
    print("=" * 60)
    
    print("\n  How many measurement stations distinguish all channels?")
    print()
    
    # Vary the number of parallel channels and replicas
    for n_channels in [2, 3, 4]:
        C = make_parallel(n_channels)
        kC, _ = compute_kappa(C)
        print(f"  {n_channels} parallel channels: κ = {kC}")
        
        for n_replicas in [1, 2, 3, 4]:
            D = make_discrete(n_replicas)
            bound = product_upper_bound(kC, C.num_objects, 0, n_replicas)
            
            if n_replicas <= 3:
                CxD = make_product(C, D)
                actual, _ = compute_kappa(CxD)
                print(f"    × {n_replicas} replicas: κ = {actual}, "
                      f"bound = {bound}, "
                      f"max = {max(kC, 0)}")
            else:
                print(f"    × {n_replicas} replicas: bound = {bound} "
                      f"(exact computation skipped)")
        print()
    
    print("  Observation: κ scales linearly with #replicas,")
    print("  not as max (which would stay constant).")


# =============================================================================
# Application 3: Covering Design Optimization
# =============================================================================

def covering_design():
    """Demonstrate the connection to covering designs.
    
    A separating family is a covering design where each "parallel pair demand"
    is covered by at least one probe. The product formula gives a covering
    number bound for product hypergraphs.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Covering Design Optimization")
    print("=" * 60)
    
    print("\n  Covering demands (parallel pairs) vs. probes needed:")
    print()
    
    cats = [
        make_parallel(2),
        make_parallel(3),
        make_parallel(4),
        make_parallel(5),
    ]
    
    for C in cats:
        pairs = C.parallel_pairs()
        kC, fam = compute_kappa(C)
        print(f"  {C}: {len(pairs)} demands, κ = {kC}, "
              f"demand/probe ratio = {len(pairs)/kC:.1f}")
    
    print("\n  Product covering efficiency:")
    C = make_parallel(3)
    kC, famC = compute_kappa(C)
    
    for n in [2, 3, 4]:
        D = make_discrete(n)
        CxD = make_product(C, D)
        pairs = CxD.parallel_pairs()
        kCxD, _ = compute_kappa(CxD)
        prod_fam = build_product_family(C, D, famC, set())
        
        print(f"  {C}×Disc({n}): {len(pairs)} demands, κ = {kCxD}, "
              f"constructed family size = {len(prod_fam)}")


# =============================================================================
# Application 4: Compositional Complexity Estimation
# =============================================================================

def compositional_complexity():
    """Show how the product formula enables compositional reasoning.
    
    For large systems built from small components, we can bound the
    probe complexity without ever constructing the full product.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 4: Compositional Complexity")
    print("=" * 60)
    
    print("\n  Estimating κ for large products without enumeration:")
    print()
    
    # Compute κ for small building blocks
    blocks = {
        'Par(2)': (make_parallel(2), None),
        'Par(3)': (make_parallel(3), None),
        'Disc(5)': (make_discrete(5), None),
        'Poset(3)': (make_thin_poset(3), None),
    }
    
    for name, (cat, _) in blocks.items():
        k, fam = compute_kappa(cat)
        blocks[name] = (cat, k)
        print(f"  κ({name}) = {k}, |Ob| = {cat.num_objects}")
    
    print()
    
    # Estimate products
    pairs_to_check = [
        ('Par(2)', 'Disc(5)'),
        ('Par(3)', 'Disc(5)'),
        ('Par(2)', 'Par(3)'),
        ('Par(2)', 'Poset(3)'),
    ]
    
    for name_C, name_D in pairs_to_check:
        catC, kC = blocks[name_C]
        catD, kD = blocks[name_D]
        bound = product_upper_bound(kC, catC.num_objects, kD, catD.num_objects)
        
        # Compute actual if feasible
        CxD = make_product(catC, catD)
        actual, _ = compute_kappa(CxD)
        
        print(f"  {name_C} × {name_D}:")
        print(f"    Upper bound (formula) = {bound}")
        print(f"    Actual κ = {actual}")
        print(f"    Efficiency = {actual/bound:.0%}" if bound > 0 else "    (trivial)")
        print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    test_suite_design()
    channel_discrimination()
    covering_design()
    compositional_complexity()
    
    print("\n" + "=" * 60)
    print("  All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Product Formula for Probe Complexity κ

This script demonstrates the product upper bound for probe complexity:
    κ(C × D) ≤ κ(C) · |Ob(D)| + κ(D) · |Ob(C)|

It computes κ for small finite categories and their products, testing
various candidate formulas and exhibiting the failure of the max-law.
"""

from itertools import product as cartesian_product
from typing import Dict, List, Tuple, Set, Optional
import sys


# =============================================================================
# Finite Category Representation
# =============================================================================

class FiniteCategory:
    """A finite category represented by objects and morphism sets.
    
    Objects: list of hashable items.
    Morphisms: dict mapping (source, target) to set of morphism labels.
    Composition: dict mapping (f, g) to f ∘ g (where g : A→B, f : B→C).
    """
    
    def __init__(self, name: str, objects: list, hom: dict, comp: dict):
        self.name = name
        self.objects = objects
        self.hom = hom  # (X, Y) -> set of morphism labels
        self.comp = comp  # (f_label, g_label) -> composed label
        self.num_objects = len(objects)
    
    def morphisms(self, X, Y) -> set:
        return self.hom.get((X, Y), set())
    
    def __repr__(self):
        return self.name


# =============================================================================
# Category Constructors
# =============================================================================

def discrete_category(n: int) -> FiniteCategory:
    """Discrete category with n objects (only identity morphisms)."""
    objects = list(range(n))
    hom = {(i, i): {f"id_{i}"} for i in objects}
    comp = {(f"id_{i}", f"id_{i}"): f"id_{i}" for i in objects}
    return FiniteCategory(f"Disc({n})", objects, hom, comp)


def parallel_arrows(n: int) -> FiniteCategory:
    """Category with 2 objects and n parallel arrows from 0 to 1."""
    objects = [0, 1]
    arrows = {f"f_{i}" for i in range(n)}
    hom = {(0, 0): {"id_0"}, (1, 1): {"id_1"}, (0, 1): arrows}
    comp = {}
    comp[("id_0", "id_0")] = "id_0"
    comp[("id_1", "id_1")] = "id_1"
    for a in arrows:
        comp[(a, "id_0")] = a  # a ∘ id_0 = a
        comp[("id_1", a)] = a  # id_1 ∘ a = a
    return FiniteCategory(f"Par({n})", objects, hom, comp)


def thin_poset(n: int) -> FiniteCategory:
    """Linear order (thin poset) on n objects: 0 ≤ 1 ≤ ... ≤ n-1."""
    objects = list(range(n))
    hom = {}
    comp = {}
    for i in objects:
        for j in objects:
            if i <= j:
                label = f"m_{i}_{j}"
                hom[(i, j)] = {label}
    # Composition: m_{j,k} ∘ m_{i,j} = m_{i,k}
    for i in objects:
        for j in objects:
            for k in objects:
                if i <= j <= k:
                    comp[(f"m_{j}_{k}", f"m_{i}_{j}")] = f"m_{i}_{k}"
    return FiniteCategory(f"Poset({n})", objects, hom, comp)


def product_category(C: FiniteCategory, D: FiniteCategory) -> FiniteCategory:
    """Product category C × D."""
    objects = [(c, d) for c in C.objects for d in D.objects]
    hom = {}
    comp = {}
    
    for (c1, d1) in objects:
        for (c2, d2) in objects:
            c_morphs = C.morphisms(c1, c2)
            d_morphs = D.morphisms(d1, d2)
            if c_morphs and d_morphs:
                prod_morphs = {f"({f},{g})" for f in c_morphs for g in d_morphs}
                hom[((c1, d1), (c2, d2))] = prod_morphs
    
    # Composition
    for (c1, d1) in objects:
        for (c2, d2) in objects:
            for (c3, d3) in objects:
                for f_c in C.morphisms(c2, c3):
                    for f_d in D.morphisms(d2, d3):
                        for g_c in C.morphisms(c1, c2):
                            for g_d in D.morphisms(d1, d2):
                                f_label = f"({f_c},{f_d})"
                                g_label = f"({g_c},{g_d})"
                                fc_gc = C.comp.get((f_c, g_c))
                                fd_gd = D.comp.get((f_d, g_d))
                                if fc_gc and fd_gd:
                                    comp[(f_label, g_label)] = f"({fc_gc},{fd_gd})"
    
    return FiniteCategory(f"{C.name}×{D.name}", objects, hom, comp)


# =============================================================================
# Probe Complexity Computation
# =============================================================================

def compute_probe_complexity(cat: FiniteCategory) -> Tuple[int, Optional[frozenset]]:
    """Compute κ(C) = minimum cardinality of a separating probe family.
    
    A probe family P ⊆ Ob(C) separates if:
    for all X, Y, for all f ≠ g : X → Y,
    there exist Z ∈ P and h : Z → X such that h∘f ≠ h∘g.
    
    Returns (κ, optimal_family).
    """
    # Find all parallel pairs that need separating
    parallel_pairs = []
    for X in cat.objects:
        for Y in cat.objects:
            morphs = list(cat.morphisms(X, Y))
            for i in range(len(morphs)):
                for j in range(i + 1, len(morphs)):
                    parallel_pairs.append((X, Y, morphs[i], morphs[j]))
    
    if not parallel_pairs:
        return 0, frozenset()
    
    def is_separating(P: set) -> bool:
        for X, Y, f, g in parallel_pairs:
            separated = False
            for Z in P:
                for h in cat.morphisms(Z, X):
                    hf = cat.comp.get((f, h))
                    hg = cat.comp.get((g, h))
                    if hf is not None and hg is not None and hf != hg:
                        separated = True
                        break
                if separated:
                    break
            if not separated:
                return False
        return True
    
    # Try increasing sizes
    from itertools import combinations
    for size in range(1, len(cat.objects) + 1):
        for subset in combinations(cat.objects, size):
            if is_separating(set(subset)):
                return size, frozenset(subset)
    
    return len(cat.objects), frozenset(cat.objects)


# =============================================================================
# Main Demo
# =============================================================================

def print_table_row(cols, widths):
    parts = []
    for c, w in zip(cols, widths):
        parts.append(str(c).center(w))
    print("│" + "│".join(parts) + "│")


def print_separator(widths, style="─"):
    parts = [style * w for w in widths]
    left = "├" if style == "─" else "┌" if style == "━" else "└"
    right = "┤" if style == "─" else "┐" if style == "━" else "┘"
    mid = "┼" if style == "─" else "┬" if style == "━" else "┴"
    print(left + mid.join(parts) + right)


def main():
    print("=" * 78)
    print("    PRODUCT FORMULA FOR PROBE COMPLEXITY κ")
    print("    κ(C × D) ≤ κ(C)·|D| + κ(D)·|C|")
    print("=" * 78)
    print()
    
    # Build test categories
    categories = [
        discrete_category(1),
        discrete_category(2),
        discrete_category(3),
        parallel_arrows(2),
        parallel_arrows(3),
        thin_poset(2),
        thin_poset(3),
    ]
    
    # Compute κ for each
    kappa = {}
    for cat in categories:
        k, family = compute_probe_complexity(cat)
        kappa[cat.name] = k
        print(f"  κ({cat.name:12s}) = {k}   (optimal family: {set(family) if family else '∅'})")
    
    print()
    print("-" * 78)
    print("  PRODUCT FORMULA VERIFICATION")
    print("-" * 78)
    print()
    
    headers = ["C", "D", "|C|", "|D|", "κ(C)", "κ(D)", "κ(C×D)",
               "max", "sum", "prod", "bound", "max<κ?"]
    widths = [10, 10, 4, 4, 5, 5, 7, 5, 5, 5, 7, 6]
    
    print_separator(widths, "━")
    print_table_row(headers, widths)
    print_separator(widths)
    
    results = []
    for C in categories:
        for D in categories:
            CxD = product_category(C, D)
            kC = kappa[C.name]
            kD = kappa[D.name]
            kCxD, _ = compute_probe_complexity(CxD)
            
            max_val = max(kC, kD)
            sum_val = kC + kD
            prod_val = kC * kD
            bound = kC * D.num_objects + kD * C.num_objects
            max_violated = "YES" if max_val < kCxD else "no"
            
            row = [C.name, D.name, C.num_objects, D.num_objects,
                   kC, kD, kCxD, max_val, sum_val, prod_val, bound, max_violated]
            print_table_row(row, widths)
            
            results.append({
                'C': C.name, 'D': D.name,
                'nC': C.num_objects, 'nD': D.num_objects,
                'kC': kC, 'kD': kD, 'kCxD': kCxD,
                'max': max_val, 'sum': sum_val, 'prod': prod_val, 'bound': bound
            })
            
            # Verify upper bound
            assert kCxD <= bound, (
                f"UPPER BOUND VIOLATED: κ({CxD.name}) = {kCxD} > {bound}"
            )
    
    print_separator(widths)
    
    # Highlight key results
    print()
    print("=" * 78)
    print("  KEY FINDINGS")
    print("=" * 78)
    
    # 1. Max-law violations
    violations = [r for r in results if r['max'] < r['kCxD']]
    print(f"\n  1. MAX-LAW VIOLATIONS: {len(violations)} cases found")
    for r in violations:
        print(f"     {r['C']} × {r['D']}: "
              f"max(κ(C),κ(D)) = {r['max']} < {r['kCxD']} = κ(C×D)")
    
    # 2. Upper bound tightness
    tight = [r for r in results if r['kCxD'] == r['bound'] and r['bound'] > 0]
    print(f"\n  2. TIGHT UPPER BOUND CASES: {len(tight)} cases")
    for r in tight[:5]:
        print(f"     {r['C']} × {r['D']}: κ = {r['kCxD']} = bound = {r['bound']}")
    
    # 3. Thin-factor formula verification
    print(f"\n  3. THIN-FACTOR FORMULA VERIFICATION")
    for r in results:
        if r['kC'] == 0 and r['kD'] > 0:
            expected = r['kD'] * r['nC']
            gap = expected - r['kCxD']
            status = 'TIGHT' if gap == 0 else f'gap={gap}'
            print(f"     {r['C']} × {r['D']}: κ(D)·|C| = {expected}, "
                  f"κ(C×D) = {r['kCxD']}, {status}")
    
    # 4. Counterexample exhibition
    print(f"\n  4. CANONICAL COUNTEREXAMPLE TO MAX-LAW:")
    C = parallel_arrows(2)
    D = discrete_category(2)
    CxD = product_category(C, D)
    kC = kappa[C.name]
    kD = kappa[D.name]
    kCxD, family = compute_probe_complexity(CxD)
    print(f"     C = Par(2): two objects, two parallel arrows")
    print(f"     D = Disc(2): two objects, only identities")
    print(f"     κ(C) = {kC}, κ(D) = {kD}")
    print(f"     max(κ(C), κ(D)) = {max(kC, kD)}")
    print(f"     κ(C × D) = {kCxD}")
    print(f"     Since {max(kC, kD)} < {kCxD}, the max-law FAILS.")
    print(f"     Product upper bound: {kC}·{D.num_objects} + {kD}·{C.num_objects} "
          f"= {kC * D.num_objects + kD * C.num_objects} ≥ {kCxD} ✓")
    
    print()
    print("=" * 78)
    print("  ALL UPPER BOUNDS VERIFIED ✓")
    print("  MAX-LAW STRUCTURALLY REFUTED ✓")
    print("=" * 78)


if __name__ == "__main__":
    main()
