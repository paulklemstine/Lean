#!/usr/bin/env python3
"""
Applications of Knuth-Bendix Completion
=========================================

Real-world applications demonstrating how KB completion transforms
algebraic specifications into computational tools:

1. Expression simplification (symbolic computation)
2. Equivalence checking for computational graphs
3. Canonical form computation for group elements
"""

from algorithms import (
    Term, Var, Op, RewriteRule, KnuthBendixCompleter,
    shortlex_gt, normalize, all_critical_pairs
)


# ============================================================
# Application 1: Symbolic Expression Simplification
# ============================================================

def app_expression_simplifier():
    """
    Build an expression simplifier from algebraic axioms.

    Given axioms of a Boolean algebra (idempotency, complementation, etc.),
    KB completion produces a rewrite system that simplifies Boolean expressions
    to canonical form.
    """
    print("=" * 70)
    print("APPLICATION 1: Boolean Expression Simplifier")
    print("=" * 70)
    print()

    x, y = Var("x"), Var("y")
    zero = Op("0", [])
    one = Op("1", [])

    # Boolean algebra axioms (subset)
    equations = [
        # Identity
        (Op("or", [x, zero]), x),
        (Op("and", [x, one]), x),
        # Annihilation
        (Op("or", [x, one]), one),
        (Op("and", [x, zero]), zero),
        # Idempotency
        (Op("or", [x, x]), x),
        (Op("and", [x, x]), x),
    ]

    completer = KnuthBendixCompleter(shortlex_gt)
    result = completer.complete(equations, max_steps=100)

    print(f"Completion: {'SUCCESS' if result else 'INCOMPLETE'}")
    print(f"Rules: {len(completer.rules)}")
    for r in completer.rules:
        print(f"  {r}")

    # Simplify expressions
    print("\nSimplification examples:")
    a, b = Var("a"), Var("b")

    exprs = [
        Op("or", [a, Op("or", [a, b])]),
        Op("and", [a, Op("and", [a, zero])]),
        Op("or", [Op("and", [a, one]), zero]),
        Op("and", [Op("or", [a, a]), Op("or", [b, b])]),
    ]

    for expr in exprs:
        nf = normalize(expr, completer.rules)
        print(f"  {expr}  →  {nf}")
    print()


# ============================================================
# Application 2: Computational Graph Equivalence
# ============================================================

def app_graph_equivalence():
    """
    Check equivalence of computational graphs using normal forms.

    Two computation graphs are equivalent iff they have the same normal
    form under the rewrite system derived from the algebraic laws.
    This is the core of equality saturation in compiler optimization.
    """
    print("=" * 70)
    print("APPLICATION 2: Computational Graph Equivalence")
    print("=" * 70)
    print()

    x, y, z = Var("x"), Var("y"), Var("z")
    zero = Op("0", [])

    # Arithmetic simplification rules (pre-oriented)
    equations = [
        (Op("+", [x, zero]), x),               # x + 0 = x
        (Op("*", [x, zero]), zero),             # x * 0 = 0
        (Op("*", [x, Op("1", [])]), x),         # x * 1 = x
        (Op("+", [x, x]), Op("*", [Op("2", []), x])),  # x + x = 2*x
    ]

    completer = KnuthBendixCompleter(shortlex_gt)
    result = completer.complete(equations, max_steps=100)

    print(f"Completion: {'SUCCESS' if result else 'INCOMPLETE'}")
    print(f"Rules: {len(completer.rules)}")
    for r in completer.rules:
        print(f"  {r}")

    # Check equivalences
    print("\nEquivalence checks:")
    a, b = Var("a"), Var("b")

    pairs = [
        (Op("+", [a, zero]), a, "a+0 ≡ a"),
        (Op("*", [Op("+", [a, zero]), Op("1", [])]),
         a, "(a+0)*1 ≡ a"),
        (Op("+", [a, a]),
         Op("*", [Op("2", []), a]), "a+a ≡ 2*a"),
    ]

    for t1, t2, desc in pairs:
        nf1 = normalize(t1, completer.rules)
        nf2 = normalize(t2, completer.rules)
        equiv = nf1 == nf2
        symbol = "≡" if equiv else "≢"
        print(f"  {desc}: {symbol} (nf₁={nf1}, nf₂={nf2})")
    print()


# ============================================================
# Application 3: Monoid Element Canonicalization
# ============================================================

def app_monoid_canonicalization():
    """
    Compute canonical forms for elements with idempotency and identity.

    Shows how KB completion normalizes expressions in a monoid with
    idempotency (x*x = x) and identity (e*x = x, x*e = x).
    """
    print("=" * 70)
    print("APPLICATION 3: Idempotent Monoid Canonicalization")
    print("=" * 70)
    print()

    x = Var("x")
    e = Op("e", [])

    # Idempotent monoid with identity
    equations = [
        (Op("*", [e, x]), x),      # e*x = x
        (Op("*", [x, e]), x),      # x*e = x
        (Op("*", [x, x]), x),      # x*x = x (idempotency)
    ]

    completer = KnuthBendixCompleter(shortlex_gt)
    result = completer.complete(equations, max_steps=200)

    print(f"Completion: {'SUCCESS' if result else 'INCOMPLETE'}")
    print(f"Rules: {len(completer.rules)}")
    for r in completer.rules:
        print(f"  {r}")

    # Canonicalize expressions
    print("\nCanonical forms:")
    a, b = Var("a"), Var("b")

    terms = [
        (Op("*", [e, a]), "e*a"),
        (Op("*", [a, e]), "a*e"),
        (Op("*", [a, a]), "a*a"),
        (Op("*", [Op("*", [a, a]), a]), "(a*a)*a"),
        (Op("*", [e, Op("*", [a, Op("*", [e, b])])]), "e*(a*(e*b))"),
        (Op("*", [Op("*", [a, b]), Op("*", [a, b])]), "(a*b)*(a*b)"),
    ]

    for t, desc in terms:
        nf = normalize(t, completer.rules)
        print(f"  {desc}  →  {nf}")

    # Show the word problem
    print("\nWord problem examples:")
    pairs = [
        (Op("*", [Op("*", [a, a]), a]), a, "(a*a)*a =? a"),
        (Op("*", [e, Op("*", [a, a])]), a, "e*(a*a) =? a"),
        (Op("*", [a, b]), Op("*", [b, a]), "a*b =? b*a"),
    ]
    for t1, t2, desc in pairs:
        nf1 = normalize(t1, completer.rules)
        nf2 = normalize(t2, completer.rules)
        print(f"  {desc}: {'YES' if nf1 == nf2 else 'NO'}")
    print()


# ============================================================
# Application 4: Convergence Analysis
# ============================================================

def app_convergence_analysis():
    """
    Analyze the convergence properties of completed systems.

    Demonstrates the connection between completion step count and
    algebraic complexity of the presentation.
    """
    print("=" * 70)
    print("APPLICATION 4: Convergence Analysis")
    print("=" * 70)
    print()

    x, y, z = Var("x"), Var("y"), Var("z")
    e = Op("e", [])

    presentations = {
        "Trivial monoid": [
            (Op("*", [e, x]), x),
            (Op("*", [x, e]), x),
        ],
        "Idempotent magma": [
            (Op("*", [x, x]), x),
        ],
        "Commutative magma": [
            (Op("*", [x, y]), Op("*", [y, x])),
        ],
        "Left-zero semigroup": [
            (Op("*", [x, y]), x),
        ],
        "Right-zero semigroup": [
            (Op("*", [x, y]), y),
        ],
    }

    print(f"{'Presentation':<25} {'Rules':<8} {'Steps':<8} {'CPs':<8} {'Conv?'}")
    print("-" * 60)

    for name, eqs in presentations.items():
        completer = KnuthBendixCompleter(shortlex_gt)
        # Count steps manually
        steps = 0
        result = False
        completer.rules = []
        for lhs, rhs in eqs:
            rule = completer.orient(lhs, rhs)
            if rule:
                completer.rules.append(rule)

        for step in range(50):
            cps = all_critical_pairs(completer.rules)
            new_rules = []
            for s, t in cps:
                ns = normalize(s, completer.rules)
                nt = normalize(t, completer.rules)
                if ns != nt:
                    rule = completer.orient(ns, nt)
                    if rule and rule not in completer.rules and rule not in new_rules:
                        new_rules.append(rule)
            steps = step + 1
            if not new_rules:
                result = True
                break
            completer.rules.extend(new_rules)
            completer._interreduce()

        num_cps = len(all_critical_pairs(completer.rules))
        print(f"{name:<25} {len(completer.rules):<8} {steps:<8} {num_cps:<8} {'✓' if result else '✗'}")

    print()


if __name__ == "__main__":
    app_expression_simplifier()
    app_graph_equivalence()
    app_monoid_canonicalization()
    app_convergence_analysis()
    print("All applications completed successfully!")


#!/usr/bin/env python3
"""
Knuth-Bendix Completion Demo
=============================

Demonstrates KB completion for finitely presented algebraic structures:
1. Idempotent magma: {x*x = x}
2. Left-unital monoid: {e*x = x, x*e = x}
3. Left-zero semigroup: {x*y = x}
4. Word problem decision procedure

Shows the resulting rewrite systems and verifies normal forms.
"""

from algorithms import (
    Term, Var, Op, RewriteRule, KnuthBendixCompleter,
    shortlex_gt, normalize, all_critical_pairs
)


def demo_idempotent():
    """Complete an idempotent magma presentation."""
    print("=" * 70)
    print("DEMO 1: Idempotent Magma Completion")
    print("=" * 70)
    print()
    print("Equations: {x*x = x}")
    print("This is the simplest non-trivial completion problem.")
    print()

    x = Var("x")
    equations = [(Op("*", [x, x]), x)]

    completer = KnuthBendixCompleter(shortlex_gt)
    result = completer.complete(equations, max_steps=50)

    print(f"Completion: {'SUCCESS' if result else 'FAILED'}")
    print(f"Rules: {len(completer.rules)}")
    for i, rule in enumerate(completer.rules, 1):
        print(f"  Rule {i}: {rule}")

    # Test normal forms
    print()
    print("Normal form tests:")
    a, b = Var("a"), Var("b")

    tests = [
        (Op("*", [a, a]), "a*a"),
        (Op("*", [Op("*", [a, a]), Op("*", [a, a])]), "(a*a)*(a*a)"),
        (Op("*", [Op("*", [a, b]), Op("*", [a, b])]), "(a*b)*(a*b)"),
    ]

    for t, desc in tests:
        nf = normalize(t, completer.rules)
        print(f"  {desc} → {nf}")
    print()


def demo_unital_monoid():
    """Complete a monoid with identity."""
    print("=" * 70)
    print("DEMO 2: Monoid with Identity")
    print("=" * 70)
    print()
    print("Equations: {e*x = x, x*e = x}")
    print("Completion should produce two rules eliminating the identity.")
    print()

    x = Var("x")
    e = Op("e", [])

    equations = [
        (Op("*", [e, x]), x),
        (Op("*", [x, e]), x),
    ]

    completer = KnuthBendixCompleter(shortlex_gt)
    result = completer.complete(equations, max_steps=50)

    print(f"Completion: {'SUCCESS' if result else 'FAILED'}")
    print(f"Rules: {len(completer.rules)}")
    for i, rule in enumerate(completer.rules, 1):
        print(f"  Rule {i}: {rule}")

    # Test
    print()
    print("Normal form tests:")
    a, b = Var("a"), Var("b")

    tests = [
        (Op("*", [e, a]), "e*a"),
        (Op("*", [a, e]), "a*e"),
        (Op("*", [e, Op("*", [a, e])]), "e*(a*e)"),
        (Op("*", [Op("*", [e, a]), Op("*", [b, e])]), "(e*a)*(b*e)"),
    ]

    for t, desc in tests:
        nf = normalize(t, completer.rules)
        print(f"  {desc} → {nf}")
    print()


def demo_left_zero():
    """Complete a left-zero semigroup."""
    print("=" * 70)
    print("DEMO 3: Left-Zero Semigroup")
    print("=" * 70)
    print()
    print("Equations: {x*y = x}")
    print("Every product equals its left factor.")
    print()

    x, y = Var("x"), Var("y")
    equations = [(Op("*", [x, y]), x)]

    completer = KnuthBendixCompleter(shortlex_gt)
    result = completer.complete(equations, max_steps=50)

    print(f"Completion: {'SUCCESS' if result else 'FAILED'}")
    print(f"Rules: {len(completer.rules)}")
    for i, rule in enumerate(completer.rules, 1):
        print(f"  Rule {i}: {rule}")

    # Test
    print()
    print("Normal form tests:")
    a, b, c = Var("a"), Var("b"), Var("c")

    tests = [
        (Op("*", [a, b]), "a*b"),
        (Op("*", [Op("*", [a, b]), c]), "(a*b)*c"),
        (Op("*", [a, Op("*", [b, c])]), "a*(b*c)"),
    ]

    for t, desc in tests:
        nf = normalize(t, completer.rules)
        print(f"  {desc} → {nf}")
    print()


def demo_word_problem():
    """Demonstrate the word problem decision procedure."""
    print("=" * 70)
    print("DEMO 4: Word Problem Decision Procedure")
    print("=" * 70)
    print()
    print("A convergent rewrite system DECIDES the word problem:")
    print("Two terms are equivalent iff they have the same normal form.")
    print()

    # Use idempotent magma with identity
    x = Var("x")
    e = Op("e", [])

    equations = [
        (Op("*", [x, x]), x),
        (Op("*", [e, x]), x),
        (Op("*", [x, e]), x),
    ]

    completer = KnuthBendixCompleter(shortlex_gt)
    result = completer.complete(equations, max_steps=50)

    print(f"System: {len(completer.rules)} rules")
    for r in completer.rules:
        print(f"  {r}")
    print()

    a, b = Var("a"), Var("b")

    # Test pairs: (term1, term2, description)
    pairs = [
        (Op("*", [a, a]), a,
         "a*a =? a"),
        (Op("*", [e, Op("*", [a, a])]), a,
         "e*(a*a) =? a"),
        (Op("*", [Op("*", [a, a]), Op("*", [a, a])]), a,
         "(a*a)*(a*a) =? a"),
        (Op("*", [a, b]), Op("*", [b, a]),
         "a*b =? b*a"),
        (Op("*", [a, a]), Op("*", [b, b]),
         "a*a =? b*b"),
    ]

    print("Word problem decisions:")
    for t1, t2, desc in pairs:
        nf1 = normalize(t1, completer.rules)
        nf2 = normalize(t2, completer.rules)
        equal = nf1 == nf2
        print(f"  {desc}: {'YES (equivalent)' if equal else 'NO (distinct)'}")
        print(f"    nf₁ = {nf1}, nf₂ = {nf2}")
    print()


def demo_critical_pairs():
    """Show critical pair computation."""
    print("=" * 70)
    print("DEMO 5: Critical Pair Analysis")
    print("=" * 70)
    print()

    x = Var("x")

    # Start with idempotency rule
    rules = [RewriteRule(Op("*", [x, x]), x)]
    print("Initial system: {x*x → x}")
    print()

    cps = all_critical_pairs(rules)
    print(f"Critical pairs ({len(cps)}):")
    for s, t in cps:
        ns = normalize(s, rules)
        nt = normalize(t, rules)
        joinable = ns == nt
        print(f"  ⟨{s}, {t}⟩ → ⟨{ns}, {nt}⟩ {'(joinable ✓)' if joinable else '(NOT joinable ✗)'}")

    print()
    if all(normalize(s, rules) == normalize(t, rules) for s, t in cps):
        print("All critical pairs are joinable → system is locally confluent!")
        print("Combined with termination → system is CONVERGENT (by Newman's Lemma)")
    print()


if __name__ == "__main__":
    demo_idempotent()
    demo_unital_monoid()
    demo_left_zero()
    demo_word_problem()
    demo_critical_pairs()
    print("All demos completed successfully!")
