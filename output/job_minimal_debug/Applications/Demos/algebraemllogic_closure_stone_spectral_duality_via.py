#!/usr/bin/env python3
"""
Applications of Closure–Nucleus Spectral Duality

Real-world applications demonstrating the practical value of the duality:
1. Knowledge base compression via implicational basis extraction
2. Access control policy analysis via closure-nucleus decomposition
3. Feature selection in machine learning via spectral separation
4. Database normalization via functional dependency analysis
"""

from algorithms import (
    ClosureOperator, Nucleus, JoinPrimeDetector, SpectralEvaluator,
    ImplicationalBasis, KripkeFrame, build_closure_from_rules,
    full_duality_pipeline
)
from typing import Set, FrozenSet, List, Tuple, Dict
from itertools import combinations

Element = int
Subset = FrozenSet[Element]
Rule = Tuple[Subset, Element]


def format_set(s: FrozenSet, labels=None) -> str:
    if not s:
        return "∅"
    if labels:
        return "{" + ", ".join(labels.get(x, str(x)) for x in sorted(s)) + "}"
    return "{" + ", ".join(str(x) for x in sorted(s)) + "}"


# ============================================================
# Application 1: Knowledge Base Compression
# ============================================================
def knowledge_base_compression():
    print("\n" + "="*70)
    print("  Application 1: Knowledge Base Compression")
    print("="*70)
    print()
    print("Scenario: A medical knowledge base with symptom-diagnosis rules.")
    print("Goal: Extract a minimal set of implication rules that captures")
    print("all diagnostic knowledge, then verify completeness via Kripke")
    print("semantics on spectral prime points.")
    print()

    # Symptoms and diagnoses encoded as integers
    # 1=fever, 2=cough, 3=fatigue, 4=flu, 5=cold
    labels = {1: "fever", 2: "cough", 3: "fatigue", 4: "flu", 5: "cold"}
    universe = set(labels.keys())

    # Medical rules:
    # {fever, cough} → flu
    # {cough} → cold
    # {flu} → fatigue
    rules: List[Rule] = [
        (frozenset([1, 2]), 4),   # fever + cough → flu
        (frozenset([2]), 5),      # cough → cold
        (frozenset([4]), 3),      # flu → fatigue
    ]

    cl_op = build_closure_from_rules(universe, rules)
    nucleus = Nucleus(cl_op, lambda s: s)

    print("Knowledge rules:")
    for gamma, x in rules:
        print(f"  {format_set(gamma, labels)} → {labels[x]}")

    print("\nDiagnostic closures:")
    test = [frozenset([2]), frozenset([1, 2]), frozenset([1])]
    for s in test:
        cl_s = cl_op.closure(s)
        print(f"  Presenting {format_set(s, labels)}")
        print(f"    → Full diagnosis: {format_set(cl_s, labels)}")

    # Extract canonical basis
    basis_ext = ImplicationalBasis(cl_op)
    canonical = basis_ext.canonical_basis()
    print(f"\nCanonical basis ({len(canonical)} rules):")
    for gamma, x in canonical:
        print(f"  {format_set(gamma, labels)} → {labels[x]}")

    # Compare: original 3 rules vs canonical basis
    print(f"\nCompression: {len(rules)} input rules → "
          f"{len(canonical)} canonical rules")
    print("(Canonical basis captures ALL derivable implications)")

    # Verify via Kripke frame
    result = full_duality_pipeline(universe, cl_op, nucleus)
    primes = result['primes']
    frame = KripkeFrame(primes)
    print(f"\nKripke frame has {len(primes)} prime points")
    all_valid = all(frame.validate_rule(r) for r in canonical)
    print(f"All canonical rules validated by Kripke frame: {all_valid}")


# ============================================================
# Application 2: Access Control Policy Analysis
# ============================================================
def access_control_analysis():
    print("\n" + "="*70)
    print("  Application 2: Access Control Policy Analysis")
    print("="*70)
    print()
    print("Scenario: Role-based access control where permissions propagate.")
    print("The nucleus models 'security clearance' — some permissions")
    print("require elevated clearance to be 'stable'.")
    print()

    # Permissions: 1=read, 2=write, 3=admin, 4=audit, 5=deploy
    labels = {1: "read", 2: "write", 3: "admin", 4: "audit", 5: "deploy"}
    universe = set(labels.keys())

    # Permission propagation rules:
    # write → read
    # admin → write, audit
    # deploy → read
    rules: List[Rule] = [
        (frozenset([2]), 1),    # write → read
        (frozenset([3]), 2),    # admin → write
        (frozenset([3]), 4),    # admin → audit
        (frozenset([5]), 1),    # deploy → read
    ]

    cl_op = build_closure_from_rules(universe, rules)

    # Security clearance nucleus: stabilizes only if admin is NOT present
    # (admin permissions require extra verification)
    def security_nucleus(s: Subset) -> Subset:
        s = cl_op.closure(s)
        # If admin (3) is present, add all permissions (full access)
        if 3 in s:
            return frozenset(universe)
        return s

    nucleus = Nucleus(cl_op, security_nucleus)

    print("Permission rules:")
    for gamma, x in rules:
        print(f"  {format_set(gamma, labels)} → {labels[x]}")

    print("\nPermission closures:")
    for v in sorted(universe):
        cl_v = cl_op.closure(frozenset([v]))
        nuc_v = nucleus.apply(cl_v)
        print(f"  {labels[v]:8} → cl: {format_set(cl_v, labels):30} "
              f"nuc: {format_set(nuc_v, labels)}")

    # Analyze stable permission sets
    print("\nNucleus-stable permission sets (security-verified):")
    for s in nucleus.stable_closed_sets():
        print(f"  {format_set(s, labels)}")

    result = full_duality_pipeline(universe, cl_op, nucleus)
    print(f"\nSpectral prime permission profiles: {result['n_primes']}")
    for p in result['primes']:
        print(f"  {format_set(p, labels)}")


# ============================================================
# Application 3: Feature Selection via Spectral Separation
# ============================================================
def feature_selection():
    print("\n" + "="*70)
    print("  Application 3: Feature Selection via Spectral Separation")
    print("="*70)
    print()
    print("Scenario: In ML, features may be redundant. Closure operators")
    print("model feature dependencies. The spectral primes identify the")
    print("minimal 'viewpoints' that distinguish all feature combinations.")
    print()

    # Features: 1=height, 2=weight, 3=BMI, 4=age, 5=blood_pressure
    labels = {1: "height", 2: "weight", 3: "BMI", 4: "age", 5: "BP"}
    universe = set(labels.keys())

    # Feature dependencies:
    # {height, weight} → BMI (BMI is computed from height and weight)
    # That's it — other features are independent
    rules: List[Rule] = [
        (frozenset([1, 2]), 3),   # height + weight → BMI
    ]

    cl_op = build_closure_from_rules(universe, rules)
    nucleus = Nucleus(cl_op, lambda s: s)

    print("Feature dependencies:")
    for gamma, x in rules:
        print(f"  {format_set(gamma, labels)} → {labels[x]}")

    result = full_duality_pipeline(universe, cl_op, nucleus)

    print(f"\nClosed feature sets: {result['n_closed_sets']}")
    print(f"Spectral prime viewpoints: {result['n_primes']}")
    for p in result['primes']:
        print(f"  {format_set(p, labels)}")

    print(f"\nSeparation: {result['injective']}")
    if result['injective']:
        print("→ These prime viewpoints distinguish ALL closed feature sets")
        print("→ They form a sufficient set of 'observation angles'")

    print(f"\nImplicational basis ({result['n_canonical_rules']} rules):")
    for gamma, x in result['canonical_basis']:
        print(f"  {format_set(gamma, labels)} → {labels[x]}")


# ============================================================
# Application 4: Database Normalization
# ============================================================
def database_normalization():
    print("\n" + "="*70)
    print("  Application 4: Database Normalization")
    print("="*70)
    print()
    print("Scenario: Functional dependencies in a database schema.")
    print("The closure operator computes attribute closure.")
    print("Spectral analysis reveals the key structure.")
    print()

    # Attributes: StudentID=1, Name=2, Major=3, Advisor=4, Dept=5
    labels = {1: "SID", 2: "Name", 3: "Major", 4: "Advisor", 5: "Dept"}
    universe = set(labels.keys())

    # Functional dependencies:
    # SID → Name, Major
    # Major → Dept
    # {Major, Advisor} → (nothing extra)
    rules: List[Rule] = [
        (frozenset([1]), 2),    # SID → Name
        (frozenset([1]), 3),    # SID → Major
        (frozenset([3]), 5),    # Major → Dept
    ]

    cl_op = build_closure_from_rules(universe, rules)
    nucleus = Nucleus(cl_op, lambda s: s)

    print("Schema: StudentID, Name, Major, Advisor, Dept")
    print("Functional dependencies:")
    for gamma, x in rules:
        print(f"  {format_set(gamma, labels)} → {labels[x]}")

    # Candidate keys = minimal sets whose closure is the full universe
    print("\nAttribute closures:")
    for v in sorted(universe):
        cl_v = cl_op.closure(frozenset([v]))
        is_key = cl_v == frozenset(universe)
        key_mark = " [SUPERKEY]" if is_key else ""
        print(f"  cl({labels[v]}) = {format_set(cl_v, labels)}{key_mark}")

    # Check pairs
    print("\nTwo-attribute closures:")
    for a, b in combinations(sorted(universe), 2):
        cl_ab = cl_op.closure(frozenset([a, b]))
        is_key = cl_ab == frozenset(universe)
        if is_key:
            print(f"  cl({labels[a]},{labels[b]}) = "
                  f"{format_set(cl_ab, labels)} [SUPERKEY]")

    result = full_duality_pipeline(universe, cl_op, nucleus)
    print(f"\nSpectral analysis:")
    print(f"  Closed attribute sets: {result['n_closed_sets']}")
    print(f"  Prime viewpoints: {result['n_primes']}")
    print(f"  Canonical FD basis: {result['n_canonical_rules']} rules")


if __name__ == "__main__":
    knowledge_base_compression()
    access_control_analysis()
    feature_selection()
    database_normalization()

    print("\n" + "="*70)
    print("  Applications Summary")
    print("="*70)
    print()
    print("The Closure–Nucleus Spectral Duality provides a unified framework")
    print("for analyzing rule-based systems across domains:")
    print()
    print("  1. Knowledge bases: Extract minimal rule sets with completeness")
    print("     guarantees via Kripke semantics")
    print("  2. Access control: Decompose permissions into base (closure)")
    print("     and elevated (nucleus) tiers with spectral verification")
    print("  3. Feature selection: Identify minimal distinguishing viewpoints")
    print("     using spectral prime analysis")
    print("  4. Database design: Analyze functional dependencies through")
    print("     the lens of closure lattice spectral structure")


#!/usr/bin/env python3
"""
Demonstration of Closure–Nucleus Spectral Duality

Concrete numerical examples showing the duality between closure systems,
nucleus operators, spectral prime points, and Kripke semantics.

The main theorems hold under a separation hypothesis: join-prime stable
closed sets must separate all closed sets. This demo shows examples where
separation holds (and the duality works perfectly) and examples where it
fails (illustrating why the hypothesis is necessary).
"""

from algorithms import (
    ClosureOperator, Nucleus, JoinPrimeDetector, SpectralEvaluator,
    ImplicationalBasis, KripkeFrame, build_closure_from_rules,
    full_duality_pipeline
)
from typing import Set, FrozenSet, List, Tuple

Element = int
Subset = FrozenSet[Element]
Rule = Tuple[Subset, Element]


def print_separator(title: str):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


def format_set(s: FrozenSet) -> str:
    if not s:
        return "∅"
    return "{" + ", ".join(str(x) for x in sorted(s)) + "}"


def check_separation(cl_op, primes):
    """Check if join-primes separate all closed sets."""
    closed = cl_op.all_closed_sets()
    for i, s in enumerate(closed):
        for j, t in enumerate(closed):
            if i >= j:
                continue
            if s == t:
                continue
            # Check if some prime distinguishes s and t
            separated = False
            for p in primes:
                if (s.issubset(p)) != (t.issubset(p)):
                    separated = True
                    break
            if not separated:
                return False, s, t
    return True, None, None


# ============================================================
# Example 1: Identity Closure (Power Set Lattice)
# ============================================================
def example_1():
    print_separator("Example 1: Identity Closure (Power Set) — Separation Holds")

    universe = {1, 2, 3}
    # Identity closure: every set is closed
    cl_op = ClosureOperator(universe, lambda s: s)
    nucleus = Nucleus(cl_op, lambda s: s)

    print("Universe:", format_set(frozenset(universe)))
    print("Closure: identity (every set is closed)")
    print("Nucleus: identity")

    result = full_duality_pipeline(universe, cl_op, nucleus)

    print(f"\nClosed sets: {result['n_closed_sets']} (= 2^3 = 8, all subsets)")
    print(f"Join-primes ({result['n_primes']}):")
    for p in result['primes']:
        print(f"  {format_set(p)}")

    sep_ok, _, _ = check_separation(cl_op, result['primes'])
    print(f"\nSeparation hypothesis: {'✓ SATISFIED' if sep_ok else '✗ FAILS'}")
    print(f"Spectral injective: {result['injective']}")
    print(f"Reconstruction verified: {result['reconstruction_correct']}")
    print(f"Kripke complete: {result['kripke_complete']}")

    # Show the Kripke frame
    primes = result['primes']
    frame = KripkeFrame(primes)
    print(f"\nKripke semantics examples:")
    examples = [(frozenset([1]), 2), (frozenset([1]), 1),
                (frozenset([1, 2]), 3), (frozenset(), 1)]
    for a, x in examples:
        in_cl = x in cl_op.closure(a)
        entails = frame.entails(a, x)
        status = "✓" if in_cl == entails else "✗"
        print(f"  {status} {x} ∈ cl({format_set(a)})? {str(in_cl):5}  "
              f"Kripke: {str(entails):5}")


# ============================================================
# Example 2: Simple Implicational Closure
# ============================================================
def example_2():
    print_separator("Example 2: Simple Implication {1}→2")

    universe = {1, 2, 3}
    rules: List[Rule] = [(frozenset([1]), 2)]
    cl_op = build_closure_from_rules(universe, rules)
    nucleus = Nucleus(cl_op, lambda s: s)

    print("Universe:", format_set(frozenset(universe)))
    print("Rule: {1} → 2")

    print("\nClosure computations:")
    test_sets = [frozenset(), frozenset([1]), frozenset([2]),
                 frozenset([3]), frozenset([1, 3])]
    for s in test_sets:
        print(f"  cl({format_set(s)}) = {format_set(cl_op.closure(s))}")

    result = full_duality_pipeline(universe, cl_op, nucleus)

    print(f"\nClosed sets ({result['n_closed_sets']}):")
    for s in result['closed_sets']:
        print(f"  {format_set(s)}")

    print(f"\nJoin-primes ({result['n_primes']}):")
    for p in result['primes']:
        print(f"  {format_set(p)}")

    sep_ok, s1, s2 = check_separation(cl_op, result['primes'])
    print(f"\nSeparation: {'✓ SATISFIED' if sep_ok else '✗ FAILS'}")
    if not sep_ok:
        print(f"  Unseparated pair: {format_set(s1)}, {format_set(s2)}")

    print(f"Spectral injective: {result['injective']}")
    print(f"Reconstruction: {result['reconstruction_correct']}")
    print(f"Kripke complete: {result['kripke_complete']}")

    # Show Kripke semantics
    primes = result['primes']
    frame = KripkeFrame(primes)
    print(f"\nKripke entailment (= logical consequence):")
    examples = [(frozenset([1]), 2), (frozenset([2]), 1),
                (frozenset([1]), 3), (frozenset([1, 3]), 2)]
    for a, x in examples:
        in_cl = x in cl_op.closure(a)
        entails = frame.entails(a, x)
        status = "✓" if in_cl == entails else "✗"
        print(f"  {status} {format_set(a)} ⊢ {x}? "
              f"Closure: {str(in_cl):5}  Kripke: {str(entails):5}")


# ============================================================
# Example 3: Modal Nucleus Example
# ============================================================
def example_3():
    print_separator("Example 3: Closure with Non-Trivial Nucleus (Modal Logic)")

    universe = {1, 2, 3}
    # Closure: {1} → 2
    rules: List[Rule] = [(frozenset([1]), 2)]
    cl_op = build_closure_from_rules(universe, rules)

    # Nucleus: maps each closed set to its "necessitation"
    # Specifically: if 2 ∈ s, add 3 (and close)
    def nuc(s: Subset) -> Subset:
        s = cl_op.closure(s)  # ensure closed
        if 2 in s:
            return cl_op.closure(s | frozenset([3]))
        return s

    nucleus = Nucleus(cl_op, nuc)

    print("Universe:", format_set(frozenset(universe)))
    print("Closure rule: {1} → 2")
    print("Nucleus: if 2 ∈ s, add 3 (modal necessitation)")

    print("\nClosed sets and nucleus images:")
    for s in cl_op.all_closed_sets():
        ns = nucleus.apply(s)
        stable = " [nuc-stable]" if nucleus.is_stable(s) else ""
        print(f"  {format_set(s):15} →  nuc: {format_set(ns):15}{stable}")

    result = full_duality_pipeline(universe, cl_op, nucleus)

    print(f"\nStable closed sets: {len(nucleus.stable_closed_sets())}")
    for s in nucleus.stable_closed_sets():
        print(f"  {format_set(s)}")

    print(f"\nJoin-primes ({result['n_primes']}):")
    for p in result['primes']:
        print(f"  {format_set(p)}")

    sep_ok, s1, s2 = check_separation(cl_op, result['primes'])
    print(f"\nSeparation: {'✓ SATISFIED' if sep_ok else '✗ FAILS'}")
    if not sep_ok:
        print(f"  Unseparated: {format_set(s1)}, {format_set(s2)}")

    # Nucleus-fixed basis
    basis_ext = ImplicationalBasis(cl_op)
    nuc_basis = basis_ext.nucleus_fixed_basis(nucleus)
    print(f"\nNucleus-fixed basis ({len(nuc_basis)} rules):")
    for gamma, x in nuc_basis:
        print(f"  {format_set(gamma)} ⊢ {x}")


# ============================================================
# Example 4: Database Dependency Closure (FCA-style)
# ============================================================
def example_4():
    print_separator("Example 4: Database Functional Dependencies")

    # Attributes of a database table
    universe = {1, 2, 3, 4, 5}  # A, B, C, D, E
    labels = {1: 'A', 2: 'B', 3: 'C', 4: 'D', 5: 'E'}

    def fmt(s):
        if not s:
            return "∅"
        return "{" + ",".join(labels[x] for x in sorted(s)) + "}"

    # Functional dependencies:
    # A → B, B → C, {A,D} → E
    rules: List[Rule] = [
        (frozenset([1]), 2),      # A → B
        (frozenset([2]), 3),      # B → C
        (frozenset([1, 4]), 5),   # {A,D} → E
    ]

    cl_op = build_closure_from_rules(universe, rules)
    nucleus = Nucleus(cl_op, lambda s: s)

    print("Attributes: A=1, B=2, C=3, D=4, E=5")
    print("Functional dependencies:")
    for gamma, x in rules:
        print(f"  {fmt(gamma)} → {labels[x]}")

    print("\nAttribute closures (= determined attributes):")
    for v in sorted(universe):
        print(f"  cl({labels[v]}) = {fmt(cl_op.closure(frozenset([v])))}")
    print(f"  cl({{A,D}}) = {fmt(cl_op.closure(frozenset([1, 4])))}")

    result = full_duality_pipeline(universe, cl_op, nucleus)

    print(f"\nClosed sets (= closed attribute sets): {result['n_closed_sets']}")
    for s in sorted(result['closed_sets'], key=lambda x: (len(x), sorted(x))):
        print(f"  {fmt(s)}")

    print(f"\nJoin-primes ({result['n_primes']}):")
    for p in result['primes']:
        print(f"  {fmt(p)}")

    sep_ok, s1, s2 = check_separation(cl_op, result['primes'])
    print(f"\nSeparation: {'✓ SATISFIED' if sep_ok else '✗ FAILS'}")
    if sep_ok:
        print("  → Full duality theorem applies!")
        print(f"  → Spectral injective: {result['injective']}")
        print(f"  → Reconstruction: {result['reconstruction_correct']}")
        print(f"  → Kripke complete: {result['kripke_complete']}")


# ============================================================
# Example 5: Verification of All Duality Properties
# ============================================================
def example_5():
    print_separator("Example 5: Complete Duality Verification")

    universe = {1, 2, 3}
    # Identity closure (every set closed) — guaranteed separation
    cl_op = ClosureOperator(universe, lambda s: s)
    nucleus = Nucleus(cl_op, lambda s: s)

    print("Universe: {1, 2}")
    print("Rule: {1} → 2")
    print()

    # Enumerate everything
    closed = cl_op.all_closed_sets()
    print(f"Closed sets: {[format_set(s) for s in closed]}")

    result = full_duality_pipeline(universe, cl_op, nucleus)
    primes = result['primes']
    print(f"Join-primes: {[format_set(p) for p in primes]}")

    # Spectral evaluation table
    evaluator = SpectralEvaluator(cl_op, nucleus, primes)
    print(f"\nSpectral evaluation table:")
    print(f"  {'Closed set':15} | " +
          " | ".join(f"p={format_set(p)}" for p in primes))
    print(f"  {'-'*15}-+-" + "-+-".join("-" * max(8, len(format_set(p))+2) for p in primes))
    for s in closed:
        evals = [str(s.issubset(p)) for p in primes]
        print(f"  {format_set(s):15} | " +
              " | ".join(f"{e:>{max(8, len(format_set(p))+2)}}" for e, p in zip(evals, primes)))

    # Reconstruction verification
    print(f"\nReconstruction: cl(A) = ⋂ {{p prime | A ⊆ p}}")
    for r in range(len(universe) + 1):
        from itertools import combinations
        for s in combinations(universe, r):
            fs = frozenset(s)
            actual = cl_op.closure(fs)
            reconstructed = evaluator.reconstruct_closure(fs)
            match = "✓" if actual == reconstructed else "✗"
            print(f"  {match} cl({format_set(fs)}) = {format_set(actual)}  "
                  f"reconstructed = {format_set(reconstructed)}")

    # Kripke completeness
    frame = KripkeFrame(primes)
    print(f"\nKripke completeness: x ∈ cl(A) ↔ ∀p.(A⊆p → x∈p)")
    for r in range(len(universe) + 1):
        from itertools import combinations
        for s in combinations(universe, r):
            fs = frozenset(s)
            for x in sorted(universe):
                in_cl = x in cl_op.closure(fs)
                entails = frame.entails(fs, x)
                match = "✓" if in_cl == entails else "✗"
                print(f"  {match} {x} ∈ cl({format_set(fs)})? "
                      f"closure={str(in_cl):5}  kripke={str(entails):5}")

    print(f"\n{'='*50}")
    print(f"  ALL DUALITY PROPERTIES VERIFIED: "
          f"{'YES' if result['injective'] and result['reconstruction_correct'] and result['kripke_complete'] else 'PARTIAL'}")
    print(f"{'='*50}")


if __name__ == "__main__":
    example_1()
    example_2()
    example_3()
    example_4()
    example_5()

    print_separator("Summary")
    print("The Closure–Nucleus Spectral Duality Theorem states:")
    print()
    print("  Given: finite closure operator cl, nucleus j, and")
    print("         separation by join-prime stable closed sets,")
    print()
    print("  Then:  1. Spectral evaluation is injective on closed sets")
    print("         2. cl(A) = intersection of primes containing A")
    print("         3. Kripke semantics is sound and complete")
    print("         4. A finite implicational basis exists and")
    print("            is validated by the Kripke frame")
    print()
    print("  This bridges: closure systems ↔ spectral observables")
    print("                ↔ Kripke frames ↔ implicational logic")


#!/usr/bin/env python3
"""
Visualizations for Closure–Nucleus Spectral Duality

Generates publication-quality figures showing:
1. Closed set lattice with spectral prime highlights
2. Spectral evaluation heatmap
3. Kripke frame directed graph
4. Duality correspondence diagram
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (
    ClosureOperator, Nucleus, JoinPrimeDetector, SpectralEvaluator,
    KripkeFrame, build_closure_from_rules, full_duality_pipeline
)
from typing import FrozenSet, List
import base64
from io import BytesIO


def format_set(s: FrozenSet) -> str:
    if not s:
        return "∅"
    return "{" + ",".join(str(x) for x in sorted(s)) + "}"


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def generate_lattice_diagram():
    """Generate a Hasse diagram of the closed set lattice."""
    universe = {1, 2, 3}
    rules = [(frozenset([1]), 2)]
    cl_op = build_closure_from_rules(universe, rules)
    nucleus = Nucleus(cl_op, lambda s: s)

    closed = cl_op.all_closed_sets()
    closed_sorted = sorted(closed, key=lambda s: (len(s), sorted(s)))

    detector = JoinPrimeDetector(cl_op, nucleus)
    primes = set(frozenset(p) for p in detector.all_join_primes())

    # Layout by cardinality
    levels = {}
    for s in closed_sorted:
        k = len(s)
        if k not in levels:
            levels[k] = []
        levels[k].append(s)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    positions = {}
    for level, sets in levels.items():
        n = len(sets)
        for i, s in enumerate(sets):
            x = (i - (n-1)/2) * 2.0
            y = level * 2.0
            positions[s] = (x, y)

    # Draw edges (Hasse diagram)
    for s in closed_sorted:
        for t in closed_sorted:
            if s < t and len(t) == len(s) + 1:
                # Check no intermediate
                intermediate = False
                for u in closed_sorted:
                    if s < u < t:
                        intermediate = True
                        break
                if not intermediate:
                    xs, ys = positions[s]
                    xt, yt = positions[t]
                    ax.plot([xs, xt], [ys, yt], 'k-', linewidth=0.8, alpha=0.5)

    # Draw nodes
    for s in closed_sorted:
        x, y = positions[s]
        is_prime = s in primes
        color = '#e74c3c' if is_prime else '#3498db'
        size = 800 if is_prime else 500
        marker = '*' if is_prime else 'o'
        ax.scatter([x], [y], c=color, s=size, zorder=5, marker=marker,
                  edgecolors='black', linewidth=1.5)
        ax.annotate(format_set(s), (x, y), textcoords="offset points",
                   xytext=(0, 15), ha='center', fontsize=10, fontweight='bold')

    # Legend
    prime_patch = mpatches.Patch(color='#e74c3c', label='Spectral Prime Points')
    closed_patch = mpatches.Patch(color='#3498db', label='Other Closed Sets')
    ax.legend(handles=[prime_patch, closed_patch], loc='upper left', fontsize=12)

    ax.set_title('Closed Set Lattice with Spectral Prime Points\n'
                 'Closure rule: {1} → 2', fontsize=14, fontweight='bold')
    ax.set_xlim(-4, 4)
    ax.set_ylim(-0.5, 7.5)
    ax.axis('off')

    fig.tight_layout()
    fig.savefig('lattice_diagram.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def generate_spectral_heatmap():
    """Generate a heatmap showing the spectral evaluation map."""
    universe = {1, 2, 3}
    cl_op = ClosureOperator(universe, lambda s: s)
    nucleus = Nucleus(cl_op, lambda s: s)

    result = full_duality_pipeline(universe, cl_op, nucleus)
    closed = result['closed_sets']
    primes = result['primes']

    # Build evaluation matrix
    n_closed = len(closed)
    n_primes = len(primes)
    matrix = np.zeros((n_closed, n_primes))

    for i, s in enumerate(closed):
        for j, p in enumerate(primes):
            matrix[i, j] = 1.0 if s.issubset(p) else 0.0

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    cmap = plt.cm.RdYlGn
    im = ax.imshow(matrix, cmap=cmap, aspect='auto', vmin=0, vmax=1)

    ax.set_xticks(range(n_primes))
    ax.set_xticklabels([format_set(p) for p in primes], rotation=45, ha='right')
    ax.set_yticks(range(n_closed))
    ax.set_yticklabels([format_set(s) for s in closed])

    ax.set_xlabel('Spectral Prime Points', fontsize=12)
    ax.set_ylabel('Closed Sets', fontsize=12)
    ax.set_title('Spectral Evaluation Map: s ⊆ p\n'
                 '(Green = True, Red = False)', fontsize=14, fontweight='bold')

    # Add text annotations
    for i in range(n_closed):
        for j in range(n_primes):
            text = '✓' if matrix[i, j] else '✗'
            color = 'white' if matrix[i, j] else 'black'
            ax.text(j, i, text, ha='center', va='center', fontsize=11,
                   color=color, fontweight='bold')

    plt.colorbar(im, ax=ax, label='Evaluation (s ⊆ p)')
    fig.tight_layout()
    fig.savefig('spectral_heatmap.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def generate_kripke_frame():
    """Generate a diagram of the Kripke frame."""
    universe = {1, 2, 3}
    rules = [(frozenset([1]), 2)]
    cl_op = build_closure_from_rules(universe, rules)
    nucleus = Nucleus(cl_op, lambda s: s)

    result = full_duality_pipeline(universe, cl_op, nucleus)
    primes = result['primes']
    frame = KripkeFrame(primes)
    preorder = frame.preorder_matrix()

    n = len(primes)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Preorder matrix
    matrix = np.array(preorder, dtype=float)
    im = ax1.imshow(matrix, cmap='Blues', vmin=0, vmax=1)
    ax1.set_xticks(range(n))
    ax1.set_xticklabels([format_set(p) for p in primes], rotation=45, ha='right')
    ax1.set_yticks(range(n))
    ax1.set_yticklabels([format_set(p) for p in primes])
    ax1.set_title('Specialization Preorder\n(p ≤ q ⟺ q ⊆ p)', fontsize=12,
                  fontweight='bold')
    for i in range(n):
        for j in range(n):
            text = '≤' if matrix[i, j] else ''
            ax1.text(j, i, text, ha='center', va='center', fontsize=10)

    # Right: Force relation diagram
    # Arrange points in a circle
    angles = np.linspace(0, 2*np.pi, n, endpoint=False)
    radius = 2.0
    xs = radius * np.cos(angles)
    ys = radius * np.sin(angles)

    for i in range(n):
        for j in range(n):
            if i != j and preorder[i][j]:
                dx = xs[j] - xs[i]
                dy = ys[j] - ys[i]
                ax2.annotate('', xy=(xs[j]-0.15*dx/np.sqrt(dx**2+dy**2),
                                     ys[j]-0.15*dy/np.sqrt(dx**2+dy**2)),
                            xytext=(xs[i]+0.15*dx/np.sqrt(dx**2+dy**2),
                                    ys[i]+0.15*dy/np.sqrt(dx**2+dy**2)),
                            arrowprops=dict(arrowstyle='->', color='#2c3e50',
                                          lw=1.2, alpha=0.6))

    ax2.scatter(xs, ys, c='#e74c3c', s=600, zorder=5, edgecolors='black',
               linewidth=1.5)
    for i in range(n):
        ax2.annotate(format_set(primes[i]), (xs[i], ys[i]),
                    textcoords="offset points", xytext=(0, 20),
                    ha='center', fontsize=9, fontweight='bold')

    ax2.set_title('Kripke Frame\n(Arrows = specialization order)',
                  fontsize=12, fontweight='bold')
    ax2.set_xlim(-3.5, 3.5)
    ax2.set_ylim(-3.5, 3.5)
    ax2.axis('off')

    fig.tight_layout()
    fig.savefig('kripke_frame.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def generate_duality_diagram():
    """Generate a conceptual diagram of the duality correspondence."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))

    # Draw four boxes
    boxes = {
        'closure': (1, 5, 'Closure System\n(cl, nuc)'),
        'spectral': (7, 5, 'Spectral\nObservables'),
        'kripke': (7, 1, 'Kripke Frame\n(prime points)'),
        'basis': (1, 1, 'Implicational\nBasis'),
    }

    for key, (x, y, label) in boxes.items():
        color = {'closure': '#3498db', 'spectral': '#e74c3c',
                 'kripke': '#2ecc71', 'basis': '#f39c12'}[key]
        rect = mpatches.FancyBboxPatch((x-1.3, y-0.7), 2.6, 1.4,
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, alpha=0.3,
                                        edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y, label, ha='center', va='center', fontsize=12,
               fontweight='bold')

    # Draw arrows with labels
    arrows = [
        (2.7, 5, 5.7, 5, 'Spectral\nEvaluation'),
        (5.7, 5, 2.7, 5, 'Reconstruction'),
        (7, 4.3, 7, 1.7, 'Prime\nPoints'),
        (7, 1.7, 7, 4.3, 'Forcing'),
        (1, 4.3, 1, 1.7, 'Generate'),
        (1, 1.7, 1, 4.3, 'Extract'),
        (2.7, 1, 5.7, 1, 'Validation'),
        (5.7, 1, 2.7, 1, 'Completeness'),
    ]

    for x1, y1, x2, y2, label in arrows:
        dx, dy = x2 - x1, y2 - y1
        is_horizontal = abs(dx) > abs(dy)
        offset = 0.3
        if is_horizontal:
            mx, my = (x1+x2)/2, y1 + (0.35 if y1 > 3 else -0.35)
        else:
            mx, my = x1 + (0.7 if x1 < 4 else -0.7), (y1+y2)/2

        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                   arrowprops=dict(arrowstyle='->', lw=1.5,
                                  color='#2c3e50', alpha=0.7))
        ax.text(mx, my, label, ha='center', va='center', fontsize=8,
               style='italic', color='#2c3e50')

    ax.set_title('Closure–Nucleus Spectral Duality\nFour-Way Correspondence',
                fontsize=16, fontweight='bold')
    ax.set_xlim(-1, 9)
    ax.set_ylim(-0.5, 6.5)
    ax.axis('off')

    fig.tight_layout()
    fig.savefig('duality_diagram.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    print("  1/4: Lattice diagram...")
    b64_lattice = generate_lattice_diagram()
    print(f"       → lattice_diagram.png ({len(b64_lattice)} chars base64)")

    print("  2/4: Spectral heatmap...")
    b64_heatmap = generate_spectral_heatmap()
    print(f"       → spectral_heatmap.png ({len(b64_heatmap)} chars base64)")

    print("  3/4: Kripke frame...")
    b64_kripke = generate_kripke_frame()
    print(f"       → kripke_frame.png ({len(b64_kripke)} chars base64)")

    print("  4/4: Duality diagram...")
    b64_duality = generate_duality_diagram()
    print(f"       → duality_diagram.png ({len(b64_duality)} chars base64)")

    print("\nAll visualizations generated successfully!")
    print("Files: lattice_diagram.png, spectral_heatmap.png, "
          "kripke_frame.png, duality_diagram.png")
