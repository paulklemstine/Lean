#!/usr/bin/env python3
"""
Applications of Bounded Beta-Reduction Finite Transition Systems

Demonstrates practical applications:
1. Certified program equivalence checking
2. Bounded model checking for higher-order programs
3. State-space exploration and minimization
4. Complexity analysis of reduct growth

Run: python3 applications.py
"""

from algorithms import (
    Lam, Var, App, Abs,
    beta_step_all, reachable_within,
    build_fts, check_weak_bisimilar,
    pretty_lam, normalize, term_size,
    enumerate_closed_terms
)
from collections import defaultdict
import random


def application_equivalence_checking():
    """Application 1: Automated equivalence checking for lambda terms.

    Given two lambda terms, check if they are β-equivalent by comparing
    their bounded transition systems. This is a semi-decision procedure:
    if the systems are NOT weakly bisimilar, the terms are NOT β-equivalent.
    """
    print("=" * 70)
    print("APPLICATION 1: Program Equivalence Checking")
    print("=" * 70)

    test_cases = [
        # (name, term1, term2, expected_equivalent)
        ("Identity reduction",
         App(Abs(0, Var(0)), Var(1)), Var(1), True),
        ("K combinator",
         App(App(Abs(0, Abs(1, Var(0))), Var(2)), Var(3)), Var(2), True),
        ("Nested identity",
         App(Abs(0, Var(0)), App(Abs(1, Var(1)), Var(2))), Var(2), True),
        ("Different variables",
         Var(0), Var(1), False),
        ("Different structure",
         App(Var(0), Var(1)), Var(0), False),
    ]

    print("\nEquivalence checking results:")
    print(f"{'Test case':<25} {'Expected':<12} {'Result':<12} {'Status'}")
    print("-" * 65)

    for name, t1, t2, expected in test_cases:
        fts1 = build_fts(5, t1)
        fts2 = build_fts(5, t2)
        result = check_weak_bisimilar(fts1, fts2)
        status = "✓" if result == expected else "✗"
        print(f"{name:<25} {str(expected):<12} {str(result):<12} {status}")

    print()


def application_state_space_analysis():
    """Application 2: State-space complexity analysis.

    Analyze how the number of reachable states grows with depth
    for different classes of lambda terms. This has implications
    for the feasibility of bounded model checking.
    """
    print("=" * 70)
    print("APPLICATION 2: State-Space Complexity Analysis")
    print("=" * 70)

    # Church numerals
    def church(n):
        """Church numeral for n: λf.λx. f^n x"""
        body = Var(1)  # x
        for _ in range(n):
            body = App(Var(0), body)  # f(...)
        return Abs(0, Abs(1, body))

    # Successor function: λn.λf.λx. f(n f x)
    succ = Abs(2, Abs(0, Abs(1, App(Var(0), App(App(Var(2), Var(0)), Var(1))))))

    print("\nChurch numeral state-space growth:")
    print(f"{'Term':<25} {'d=0':<8} {'d=1':<8} {'d=2':<8} {'d=3':<8} {'d=4':<8}")
    print("-" * 65)

    for n in range(5):
        cn = church(n)
        name = f"church({n})"
        counts = []
        for d in range(5):
            states = reachable_within(d, cn)
            counts.append(len(states))
        print(f"{name:<25} " + " ".join(f"{c:<8}" for c in counts))

    # Successor applied to Church numerals
    print("\nSuccessor application state-space:")
    for n in range(4):
        term = App(succ, church(n))
        name = f"succ(church({n}))"
        counts = []
        for d in range(5):
            states = reachable_within(d, term)
            counts.append(len(states))
        print(f"{name:<25} " + " ".join(f"{c:<8}" for c in counts))

    print()


def application_bounded_model_checking():
    """Application 3: Bounded model checking for higher-order programs.

    Check safety/liveness properties expressed as modal formulas
    on the bounded transition system of a lambda term.
    """
    print("=" * 70)
    print("APPLICATION 3: Bounded Model Checking")
    print("=" * 70)

    from algorithms import weak_modal_eval

    # Property: "the program can reach a normal form"
    # Encoded as: ◇(¬◇⊤) = eventually no more steps
    reaches_normal = ("diamond", ("neg", ("diamond", ("top",))))

    # Property: "the program can make at least one step"
    can_step = ("diamond", ("top",))

    # Property: "the program is stuck (no steps possible)"
    is_stuck = ("neg", ("diamond", ("top",)))

    terms = [
        ("(λx.x) y", App(Abs(0, Var(0)), Var(1))),
        ("y (normal form)", Var(1)),
        ("(λx.xx)(λx.xx) Ω",
         App(Abs(0, App(Var(0), Var(0))), Abs(0, App(Var(0), Var(0))))),
        ("(λx.x)((λy.y) z)", App(Abs(0, Var(0)), App(Abs(1, Var(1)), Var(2)))),
    ]

    d = 5
    print(f"\nModel checking at depth d = {d}:")
    print(f"{'Term':<25} {'Can step':<12} {'Is stuck':<12} {'Reaches NF'}")
    print("-" * 65)

    for name, term in terms:
        fts = build_fts(d, term)
        step = weak_modal_eval(fts, term, can_step)
        stuck = weak_modal_eval(fts, term, is_stuck)
        reaches = weak_modal_eval(fts, term, reaches_normal)
        print(f"{name:<25} {str(step):<12} {str(stuck):<12} {reaches}")

    print()


def application_minimization():
    """Application 4: FTS minimization via partition refinement.

    Compute the minimal FTS by merging bisimilar states.
    The minimized system preserves all modal properties.
    """
    print("=" * 70)
    print("APPLICATION 4: FTS Minimization")
    print("=" * 70)

    term = App(Abs(0, App(Var(0), Var(0))), Abs(1, Var(1)))
    d = 4

    fts = build_fts(d, term)
    n_states = len(fts['states'])
    n_trans = len(fts['transitions'])

    # Simple partition refinement for minimization
    # Group states by their "behavioral class"
    state_list = list(fts['states'])

    # Build successor map
    succ_map = defaultdict(set)
    for src, tgt in fts['transitions']:
        succ_map[src].add(tgt)

    # Initial partition: normal forms vs non-normal forms
    partition = {}
    for s in state_list:
        has_succ = len(succ_map[s]) > 0
        nf = normalize(s, max_steps=50)
        partition[s] = (has_succ, nf)

    # Count equivalence classes
    classes = defaultdict(list)
    for s, cls in partition.items():
        classes[cls].append(s)

    n_classes = len(classes)

    print(f"\nTerm: {pretty_lam(term)}, depth = {d}")
    print(f"Original FTS: {n_states} states, {n_trans} transitions")
    print(f"Minimized FTS: {n_classes} behavioral classes")
    print(f"Compression ratio: {n_states / max(n_classes, 1):.1f}x")

    print(f"\nBehavioral classes:")
    for cls_id, (cls_key, members) in enumerate(classes.items()):
        print(f"  Class {cls_id}: {len(members)} state(s)")
        for m in members[:3]:
            print(f"    {pretty_lam(m)}")
        if len(members) > 3:
            print(f"    ... and {len(members) - 3} more")

    print()


def application_random_testing():
    """Application 5: Random testing of the bisimulation conjecture.

    Generate random closed lambda terms, check if β-equivalent pairs
    are weakly bisimilar at various depths.
    """
    print("=" * 70)
    print("APPLICATION 5: Random Testing of Bisimulation Conjecture")
    print("=" * 70)

    random.seed(42)

    # Generate random terms and test
    n_tests = 20
    n_pass = 0
    n_fail = 0

    print(f"\nTesting {n_tests} random term pairs...")

    for i in range(n_tests):
        # Generate a random term with a beta-redex
        var_idx = random.randint(0, 3)
        body_var = random.randint(0, 3)
        arg_var = random.randint(0, 3)

        t1 = App(Abs(var_idx, Var(body_var)), Var(arg_var))
        t2 = normalize(t1, max_steps=10)

        if t2 is not None and t2 != t1:
            fts1 = build_fts(3, t1)
            fts2 = build_fts(3, t2)
            bisim = check_weak_bisimilar(fts1, fts2)

            if bisim:
                n_pass += 1
            else:
                n_fail += 1
                print(f"  FAIL: {pretty_lam(t1)} vs {pretty_lam(t2)}")

    print(f"\nResults: {n_pass} passed, {n_fail} failed out of {n_tests} tests")
    if n_fail == 0:
        print("All tests passed ✓ -- consistent with Theorem 2b")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  APPLICATIONS OF BOUNDED BETA-REDUCTION FTS")
    print("=" * 70 + "\n")

    application_equivalence_checking()
    application_state_space_analysis()
    application_bounded_model_checking()
    application_minimization()
    application_random_testing()

    print("=" * 70)
    print("All applications complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demo: Bounded Beta-Reduction and Finite Transition Systems

Demonstrates the core theorems:
1. Bounded beta-reduct systems are finite
2. Beta-equivalent terms yield weakly bisimilar FTS
3. Modal properties are preserved under bisimulation

Run: python3 demo.py
"""

from algorithms import (
    Lam, Var, App, Abs,
    beta_step_all, reachable_within,
    build_fts, check_weak_bisimilar,
    weak_modal_eval, pretty_lam
)


def demo_finiteness():
    """Theorem 1: Bounded beta-reduct systems are finite."""
    print("=" * 70)
    print("THEOREM 1: Finiteness of Bounded Beta-Reduct Systems")
    print("=" * 70)

    # Example: ((λx. x x) (λy. y)) -- interesting because of self-application
    term = App(Abs(0, App(Var(0), Var(0))), Abs(1, Var(1)))
    print(f"\nTerm: {pretty_lam(term)}")

    for d in range(6):
        states = reachable_within(d, term)
        print(f"  Depth {d}: {len(states)} reachable state(s)")
        if len(states) <= 8:
            for s in states:
                print(f"    - {pretty_lam(s)}")

    # Omega combinator: (λx. x x)(λx. x x)
    omega = App(Abs(0, App(Var(0), Var(0))), Abs(0, App(Var(0), Var(0))))
    print(f"\nDivergent term Ω = {pretty_lam(omega)}")
    for d in range(6):
        states = reachable_within(d, omega)
        print(f"  Depth {d}: {len(states)} reachable state(s)")

    print()


def demo_beta_equivalence():
    """Theorem 2: Beta-equivalent terms yield weakly bisimilar FTS."""
    print("=" * 70)
    print("THEOREM 2: β-Equivalence → Weak Bisimilarity")
    print("=" * 70)

    # Example 1: (λx.x) y  ≡β  y
    t1 = App(Abs(0, Var(0)), Var(1))  # (λx.x) y
    t2 = Var(1)  # y
    print(f"\nPair 1: {pretty_lam(t1)}  ~β  {pretty_lam(t2)}")

    for d in range(4):
        fts1 = build_fts(d, t1)
        fts2 = build_fts(d, t2)
        bisim = check_weak_bisimilar(fts1, fts2)
        print(f"  Depth {d}: weakly bisimilar = {bisim}")

    # Example 2: (λx.λy.x) a b  ≡β  a
    t3 = App(App(Abs(0, Abs(1, Var(0))), Var(2)), Var(3))  # (λx.λy.x) a b
    t4 = Var(2)  # a
    print(f"\nPair 2: {pretty_lam(t3)}  ~β  {pretty_lam(t4)}")

    for d in range(4):
        fts1 = build_fts(d, t3)
        fts2 = build_fts(d, t4)
        bisim = check_weak_bisimilar(fts1, fts2)
        print(f"  Depth {d}: weakly bisimilar = {bisim}")

    # Example 3: NON-equivalent terms
    t5 = Var(0)
    t6 = Var(1)
    print(f"\nPair 3 (NOT equivalent): {pretty_lam(t5)}  vs  {pretty_lam(t6)}")

    for d in range(3):
        fts1 = build_fts(d, t5)
        fts2 = build_fts(d, t6)
        bisim = check_weak_bisimilar(fts1, fts2)
        print(f"  Depth {d}: weakly bisimilar = {bisim}")

    print()


def demo_modal_invariance():
    """Theorem 3: Modal properties are preserved."""
    print("=" * 70)
    print("THEOREM 3: Modal Invariance under Bisimulation")
    print("=" * 70)

    # β-equivalent pair
    t1 = App(Abs(0, Var(0)), Var(1))  # (λx.x) y
    t2 = Var(1)  # y

    # Modal formulas
    formulas = [
        ("⊤", ("top",)),
        ("¬⊤", ("neg", ("top",))),
        ("◇⊤ (has successor)", ("diamond", ("top",))),
        ("◇◇⊤ (has 2-step path)", ("diamond", ("diamond", ("top",)))),
    ]

    d = 3
    print(f"\nDepth d = {d}")
    print(f"Term A: {pretty_lam(t1)}")
    print(f"Term B: {pretty_lam(t2)}")

    fts1 = build_fts(d, t1)
    fts2 = build_fts(d, t2)

    print(f"\n{'Formula':<30} {'A satisfies':<15} {'B satisfies':<15} {'Match?'}")
    print("-" * 70)
    for name, formula in formulas:
        sat_a = weak_modal_eval(fts1, t1, formula)
        sat_b = weak_modal_eval(fts2, t2, formula)
        match = "✓" if sat_a == sat_b else "✗"
        print(f"{name:<30} {str(sat_a):<15} {str(sat_b):<15} {match}")

    print()


def demo_fts_visualization():
    """Visualize the finite transition systems."""
    print("=" * 70)
    print("VISUALIZATION: Finite Transition Systems")
    print("=" * 70)

    # Simple example
    term = App(Abs(0, App(Var(0), Var(0))), Abs(1, Var(1)))
    d = 3

    print(f"\nTerm: {pretty_lam(term)}, depth bound d = {d}")
    fts = build_fts(d, term)

    print(f"\nStates ({len(fts['states'])} total):")
    state_idx = {}
    for i, s in enumerate(fts['states']):
        state_idx[s] = i
        marker = " ← initial" if s == term else ""
        print(f"  [{i}] {pretty_lam(s)}{marker}")

    print(f"\nTransitions ({len(fts['transitions'])} total):")
    for src, tgt in fts['transitions']:
        if src in state_idx and tgt in state_idx:
            print(f"  [{state_idx[src]}] → [{state_idx[tgt]}]  "
                  f"({pretty_lam(src)} → {pretty_lam(tgt)})")

    print()


def demo_conjectures():
    """Test falsifiable conjectures on small terms."""
    print("=" * 70)
    print("CONJECTURE TESTING")
    print("=" * 70)

    # Conjecture 1: Growth of reachable states
    print("\nConjecture: State count grows with depth")
    terms = [
        ("(λx.xx)(λy.y)", App(Abs(0, App(Var(0), Var(0))), Abs(1, Var(1)))),
        ("(λx.x(xx))(λy.y)", App(Abs(0, App(Var(0), App(Var(0), Var(0)))),
                               Abs(1, Var(1)))),
        ("Ω", App(Abs(0, App(Var(0), Var(0))), Abs(0, App(Var(0), Var(0))))),
    ]

    for name, term in terms:
        print(f"\n  {name}:")
        for d in range(8):
            n = len(reachable_within(d, term))
            print(f"    d={d}: {n} states", end="")
            if d > 0:
                prev = len(reachable_within(d - 1, term))
                if prev > 0:
                    print(f"  (ratio: {n / prev:.2f})", end="")
            print()

    # Conjecture 2: Weak bisimilarity for known β-equivalent pairs
    print("\nConjecture: All tested β-equivalent pairs are weakly bisimilar")
    pairs = [
        ("(λx.x)y vs y", App(Abs(0, Var(0)), Var(1)), Var(1)),
        ("(λx.λy.x)a b vs a",
         App(App(Abs(0, Abs(1, Var(0))), Var(2)), Var(3)), Var(2)),
        ("(λx.x)((λy.y)z) vs z",
         App(Abs(0, Var(0)), App(Abs(1, Var(1)), Var(2))), Var(2)),
    ]

    all_pass = True
    for name, t1, t2 in pairs:
        results = []
        for d in range(6):
            fts1 = build_fts(d, t1)
            fts2 = build_fts(d, t2)
            bisim = check_weak_bisimilar(fts1, fts2)
            results.append(bisim)
        passed = all(results)
        all_pass = all_pass and passed
        print(f"  {name}: {'PASS' if passed else 'FAIL'}")

    print(f"\n  Overall: {'ALL PASS ✓' if all_pass else 'SOME FAILURES ✗'}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  BOUNDED BETA-REDUCTION: FINITE BEHAVIORAL SEMANTICS")
    print("  FOR HIGHER-ORDER COMPUTATION")
    print("=" * 70 + "\n")

    demo_finiteness()
    demo_beta_equivalence()
    demo_modal_invariance()
    demo_fts_visualization()
    demo_conjectures()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
