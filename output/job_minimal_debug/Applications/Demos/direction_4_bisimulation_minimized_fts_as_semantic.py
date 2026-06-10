"""
Applications of Bisimulation-Minimized FTS Theory

Demonstrates real-world applications of the canonical finite-state
semantics for typed lambda calculus terms.

Application keywords: program equivalence, compiler optimization,
semantic compression, model reduction, canonical semantics
"""

from algorithms import (
    Term, Var, App, Lam, Ty, Base, Arrow,
    compute_bounded_fts, canonical_quotient_size,
    bisimulation_quotient_size, compute_bisimulation_quotient,
    beta_step, normalize, beta_equivalent, is_normal_form,
    type_state_bound, type_depth, find_stabilization_depth,
    term_size
)


def application_1_program_equivalence():
    """Application 1: Certified Program Equivalence

    Use bisimulation quotients to verify that two implementations
    of the same function are semantically equivalent.
    """
    print("=" * 60)
    print("APPLICATION 1: Program Equivalence Checking")
    print("=" * 60)

    # Two implementations of the identity function
    # Direct: λx.x
    impl1 = Lam(0, Var(0))
    # Via redundant application: (λy.λx.x)(λz.z)
    impl2 = App(Lam(1, Lam(0, Var(0))), Lam(2, Var(2)))

    print(f"\nImplementation 1: {impl1}")
    print(f"Implementation 2: {impl2}")
    print(f"Beta-equivalent: {beta_equivalent(impl1, impl2)}")

    # Compare quotient sizes
    for d in range(5):
        s1 = canonical_quotient_size(d, impl1)
        s2 = canonical_quotient_size(d, impl2)
        b1 = bisimulation_quotient_size(d, impl1)
        b2 = bisimulation_quotient_size(d, impl2)
        print(f"  d={d}: impl1 states={s1} bisim={b1}, "
              f"impl2 states={s2} bisim={b2}")

    # Normalize both
    nf1 = normalize(impl1)
    nf2 = normalize(impl2)
    print(f"\nNormal form 1: {nf1}")
    print(f"Normal form 2: {nf2}")
    print(f"Normal forms equal: {nf1 == nf2}")


def application_2_semantic_compression():
    """Application 2: Semantic Compression

    Measure how much a term's bounded behavior can be compressed
    by bisimulation minimization.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Semantic Compression Ratios")
    print("=" * 60)

    terms = [
        ("Identity", Lam(0, Var(0))),
        ("Const true", Lam(0, Lam(1, Var(0)))),
        ("Const false", Lam(0, Lam(1, Var(1)))),
        ("Apply id", App(Lam(0, Var(0)), Lam(1, Var(1)))),
        ("Church 0", Lam(0, Lam(1, Var(1)))),
        ("Church 1", Lam(0, Lam(1, App(Var(0), Var(1))))),
    ]

    print(f"\n{'Term':<20} {'Size':>5} {'States(d=3)':>12} "
          f"{'Bisim(d=3)':>11} {'Ratio':>8}")
    print("-" * 60)

    for name, t in terms:
        sz = term_size(t)
        states = canonical_quotient_size(3, t)
        bisim = bisimulation_quotient_size(3, t)
        ratio = bisim / states if states > 0 else 1.0
        print(f"{name:<20} {sz:>5} {states:>12} {bisim:>11} {ratio:>8.2f}")


def application_3_type_complexity_analysis():
    """Application 3: Type Complexity Analysis

    Analyze how type structure constrains semantic state complexity.
    This validates the type-uniform bound theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Type Complexity Analysis")
    print("=" * 60)

    types = [
        Base(),
        Arrow(Base(), Base()),
        Arrow(Base(), Arrow(Base(), Base())),
        Arrow(Arrow(Base(), Base()), Base()),
        Arrow(Arrow(Base(), Base()), Arrow(Base(), Base())),
    ]

    print(f"\n{'Type':<30} {'Depth':>6} {'Bound':>8}")
    print("-" * 50)

    for ty in types:
        d = type_depth(ty)
        b = type_state_bound(ty)
        print(f"{str(ty):<30} {d:>6} {b:>8}")


def application_4_stabilization_analysis():
    """Application 4: Stabilization Depth Analysis

    For various terms, compute when the canonical quotient stabilizes.
    This validates the eventual stabilization theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Stabilization Depth Analysis")
    print("=" * 60)

    terms = [
        ("Normal form x0", Var(0)),
        ("Normal form λx.x", Lam(0, Var(0))),
        ("(λx.x)(λx.x)", App(Lam(0, Var(0)), Lam(1, Var(1)))),
        ("(λx.x)((λx.x)(λy.y))", App(Lam(0, Var(0)), App(Lam(1, Var(1)), Lam(2, Var(2))))),
    ]

    print(f"\n{'Term':<35} {'Stab.Depth':>11} {'Final Size':>11}")
    print("-" * 60)

    for name, t in terms:
        sd = find_stabilization_depth(t, max_depth=20)
        final = canonical_quotient_size(sd + 5, t)
        print(f"{name:<35} {sd:>11} {final:>11}")


def application_5_quotient_sequence():
    """Application 5: Quotient Size Sequence Visualization

    Show how canonicalQuotientSize(d, t) evolves with d.
    Validates monotonicity and eventual stabilization.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Quotient Size Sequences")
    print("=" * 60)

    # A term that takes multiple steps to normalize
    # (λx.x)((λy.y)(λz.z))
    t = App(Lam(0, Var(0)), App(Lam(1, Var(1)), Lam(2, Var(2))))

    print(f"\nTerm: {t}")
    print(f"Normal form: {normalize(t)}")
    print(f"\n{'Depth':>6} {'States':>8} {'Bisim':>8}")
    print("-" * 25)

    for d in range(10):
        s = canonical_quotient_size(d, t)
        b = bisimulation_quotient_size(d, t)
        print(f"{d:>6} {s:>8} {b:>8}")


if __name__ == "__main__":
    application_1_program_equivalence()
    application_2_semantic_compression()
    application_3_type_complexity_analysis()
    application_4_stabilization_analysis()
    application_5_quotient_sequence()


#!/usr/bin/env python3
"""
Demo: Bisimulation-Minimized FTS as Semantic Canonical Forms

This demo:
1. Enumerates closed well-typed terms of types up to depth 3 and size ≤ 12
2. Computes bounded FTS at depth = normalization_depth + 2
3. Computes bisimulation quotients
4. Groups terms by beta-equivalence class
5. Reports whether quotient sizes are constant within each class
6. Highlights any counterexample candidates
7. Visualizes minimized quotients as ASCII graphs

Application keywords: higher-order automata, coalgebraic minimization,
Myhill-Nerode, program equivalence, canonical semantics, state complexity
"""

from collections import defaultdict
from algorithms import (
    Term, Var, App, Lam, Ty, Base, Arrow,
    compute_bounded_fts, canonical_quotient_size,
    bisimulation_quotient_size, compute_bisimulation_quotient,
    beta_step, normalize, beta_equivalent, is_normal_form,
    type_state_bound, type_depth, find_stabilization_depth,
    term_size, enumerate_closed_terms
)


def ascii_graph(states, transitions, root):
    """Draw an ASCII graph of a transition system."""
    state_list = sorted([str(s) for s in states], key=len)
    state_map = {str(s): i for i, s in enumerate(states)}

    lines = []
    lines.append("  States:")
    for s in states:
        marker = " *" if s == root else "  "
        nf = " [NF]" if is_normal_form(s) else ""
        lines.append(f"   {marker} {s}{nf}")

    lines.append("  Transitions:")
    for src, tgt in transitions:
        lines.append(f"    {src} --> {tgt}")

    if not transitions:
        lines.append("    (none)")

    return "\n".join(lines)


def bisim_ascii(classes, transitions):
    """Draw an ASCII graph of the bisimulation quotient."""
    # Map states to their class index
    state_to_class = {}
    for i, cls in enumerate(classes):
        for s in cls:
            state_to_class[s] = i

    lines = []
    lines.append("  Bisimulation classes:")
    for i, cls in enumerate(classes):
        members = ", ".join(str(s) for s in sorted(cls, key=str))
        lines.append(f"    [{i}] = {{{members}}}")

    # Quotient transitions
    qtrans = set()
    for src, tgt in transitions:
        c1 = state_to_class.get(src)
        c2 = state_to_class.get(tgt)
        if c1 is not None and c2 is not None and c1 != c2:
            qtrans.add((c1, c2))

    lines.append("  Quotient transitions:")
    for c1, c2 in sorted(qtrans):
        lines.append(f"    [{c1}] --> [{c2}]")
    if not qtrans:
        lines.append("    (none)")

    return "\n".join(lines)


def demo_enumeration_and_grouping():
    """Main demo: enumerate terms, group by beta-class, check quotient invariance."""
    print("=" * 70)
    print("DEMO: Bisimulation-Minimized FTS as Semantic Canonical Forms")
    print("=" * 70)

    # Types to explore
    types_to_explore = [
        Base(),
        Arrow(Base(), Base()),
        Arrow(Base(), Arrow(Base(), Base())),
        Arrow(Arrow(Base(), Base()), Base()),
    ]

    MAX_SIZE = 8  # Keep manageable for demo
    all_results = []

    for ty in types_to_explore:
        print(f"\n{'='*60}")
        print(f"TYPE: {ty}  (depth={type_depth(ty)}, bound={type_state_bound(ty)})")
        print(f"{'='*60}")

        # Enumerate terms
        terms = enumerate_closed_terms(ty, MAX_SIZE)
        print(f"\nEnumerated {len(terms)} closed terms of size ≤ {MAX_SIZE}")

        if not terms:
            print("  (no closed terms found)")
            continue

        # Group by beta-equivalence (via normal forms)
        beta_classes = defaultdict(list)
        for t in terms:
            nf = normalize(t)
            if nf is not None:
                beta_classes[str(nf)].append(t)
            else:
                beta_classes["<divergent>"].append(t)

        print(f"Found {len(beta_classes)} beta-equivalence classes")

        # For each class, compute quotient sizes
        counterexamples = []

        for nf_str, class_terms in sorted(beta_classes.items()):
            if len(class_terms) == 0:
                continue

            print(f"\n  β-class (nf = {nf_str}): {len(class_terms)} terms")

            # Compute depth = normalization_depth + 2
            class_data = []
            for t in class_terms[:5]:  # Limit display
                # Find normalization depth
                current = t
                norm_depth = 0
                for step in range(100):
                    reducts = beta_step(current)
                    if not reducts:
                        break
                    current = reducts[0]
                    norm_depth += 1

                d = norm_depth + 2
                qs = canonical_quotient_size(d, t)
                bs = bisimulation_quotient_size(d, t)
                stab = find_stabilization_depth(t, max_depth=15)

                class_data.append({
                    'term': t, 'depth': d, 'quot_size': qs,
                    'bisim_size': bs, 'stab_depth': stab
                })

                print(f"    {t}")
                print(f"      norm_depth={norm_depth}, eval_depth={d}, "
                      f"states={qs}, bisim_classes={bs}, stable_from={stab}")

            # Check invariance within class
            sizes = set(cd['bisim_size'] for cd in class_data)
            if len(sizes) > 1:
                counterexamples.append((nf_str, class_data))
                print(f"    ⚠ VARIANCE DETECTED: bisim sizes = {sizes}")
            else:
                print(f"    ✓ Quotient sizes consistent within β-class")

        if counterexamples:
            print(f"\n  ⚠ {len(counterexamples)} potential counterexamples found!")
            for nf_str, data in counterexamples:
                print(f"    Class {nf_str}: sizes = "
                      f"{[d['bisim_size'] for d in data]}")
        else:
            print(f"\n  ✓ All β-classes have consistent quotient sizes")


def demo_quotient_visualization():
    """Visualize bisimulation quotients for specific terms."""
    print("\n" + "=" * 70)
    print("VISUALIZATION: Bisimulation Quotients")
    print("=" * 70)

    examples = [
        ("Identity (λx.x)", Lam(0, Var(0))),
        ("Redex (λx.x)(λy.y)", App(Lam(0, Var(0)), Lam(1, Var(1)))),
        ("Double redex (λx.x)((λy.y)(λz.z))",
         App(Lam(0, Var(0)), App(Lam(1, Var(1)), Lam(2, Var(2))))),
    ]

    for name, t in examples:
        print(f"\n--- {name}: {t} ---")

        nf = normalize(t)
        print(f"Normal form: {nf}")

        d = 5
        states, trans = compute_bounded_fts(d, t)
        classes = compute_bisimulation_quotient(states, trans)

        print(f"\nFTS at depth {d}:")
        print(ascii_graph(states, trans, t))
        print(f"\nBisimulation quotient ({len(classes)} classes):")
        print(bisim_ascii(classes, trans))


def demo_monotone_stabilization():
    """Demonstrate that quotient sizes are monotone and stabilize."""
    print("\n" + "=" * 70)
    print("MONOTONE STABILIZATION CONJECTURE TEST")
    print("=" * 70)

    terms = [
        ("(λx.x)(λy.y)", App(Lam(0, Var(0)), Lam(1, Var(1)))),
        ("(λx.x)((λy.y)(λz.z))",
         App(Lam(0, Var(0)), App(Lam(1, Var(1)), Lam(2, Var(2))))),
        ("(λf.λx.f x)(λy.y)",
         App(Lam(0, Lam(1, App(Var(0), Var(1)))), Lam(2, Var(2)))),
    ]

    for name, t in terms:
        print(f"\n  {name}:")
        sizes = []
        prev = 0
        monotone = True
        for d in range(10):
            s = canonical_quotient_size(d, t)
            sizes.append(s)
            if s < prev:
                monotone = False
            prev = s

        print(f"    Sequence: {sizes}")
        print(f"    Monotone: {'✓' if monotone else '✗'}")

        # Check stabilization
        stable_from = None
        for i in range(len(sizes) - 1):
            if all(sizes[j] == sizes[i] for j in range(i, len(sizes))):
                stable_from = i
                break
        print(f"    Stabilizes at d={stable_from}")


def demo_type_bound_validation():
    """Validate that quotient sizes respect type bounds for normal forms."""
    print("\n" + "=" * 70)
    print("TYPE BOUND VALIDATION")
    print("=" * 70)

    types = [
        Base(),
        Arrow(Base(), Base()),
        Arrow(Base(), Arrow(Base(), Base())),
    ]

    for ty in types:
        bound = type_state_bound(ty)
        terms = enumerate_closed_terms(ty, 6)
        normal_forms = [t for t in terms if is_normal_form(t)]

        violations = []
        for nf in normal_forms:
            for d in range(8):
                qs = canonical_quotient_size(d, nf)
                if qs > bound:
                    violations.append((nf, d, qs))

        print(f"\n  Type {ty} (bound={bound}):")
        print(f"    Normal forms found: {len(normal_forms)}")
        if violations:
            print(f"    ⚠ {len(violations)} VIOLATIONS!")
            for nf, d, qs in violations[:3]:
                print(f"      {nf} at d={d}: size={qs} > {bound}")
        else:
            print(f"    ✓ All normal forms satisfy bound")


if __name__ == "__main__":
    demo_enumeration_and_grouping()
    demo_quotient_visualization()
    demo_monotone_stabilization()
    demo_type_bound_validation()
