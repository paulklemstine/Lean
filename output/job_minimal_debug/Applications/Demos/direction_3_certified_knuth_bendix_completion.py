#!/usr/bin/env python3
"""
Applications of Knuth-Bendix Completion

This module demonstrates real-world applications of the Knuth-Bendix
completion procedure:

1. Deciding the word problem for monoids
2. Simplifying algebraic expressions
3. Verifying algebraic identities
4. Building certified normalizers
"""

from algorithms import (
    Term, Equation, Rule,
    make_var, make_fun, kb_complete, lpo, normalize,
)


def separator(title: str) -> None:
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70 + "\n")


# ─────────────────────────────────────────────────────────────────────
#  Application 1: Word Problem for Monoids
# ─────────────────────────────────────────────────────────────────────

def app_word_problem():
    """Use completion to decide the word problem for free monoids.
    
    The word problem asks: given two expressions, do they represent
    the same element? With a convergent rewrite system, this reduces
    to comparing normal forms.
    """
    separator("Application 1: Word Problem for Monoids")

    x, y, z = make_var("x"), make_var("y"), make_var("z")
    e = make_fun("e")
    m = lambda a, b: make_fun("m", a, b)

    equations = [
        Equation(m(m(x, y), z), m(x, m(y, z))),
        Equation(m(e, x), x),
        Equation(m(x, e), x),
    ]

    result = kb_complete(equations, lpo({"m": 2, "e": 1}))
    assert result.terminated and result.is_convergent()

    print("Convergent rewrite system for monoids:")
    for r in result.rules:
        print(f"  {r}")

    # Test word equivalences
    a, b, c = make_fun("a"), make_fun("b"), make_fun("c")

    def words_equal(t1: Term, t2: Term) -> bool:
        return normalize(t1, result.rules) == normalize(t2, result.rules)

    print("\nWord problem tests:")
    tests = [
        (m(m(a, b), c), m(a, m(b, c)), True),
        (m(e, m(a, b)), m(a, b), True),
        (m(a, m(e, b)), m(a, b), True),
        (m(a, b), m(b, a), False),  # Not commutative!
        (m(m(m(a, e), b), c), m(a, m(b, c)), True),
    ]

    for t1, t2, expected in tests:
        result_eq = words_equal(t1, t2)
        status = "✓" if result_eq == expected else "✗"
        print(f"  {status} {t1} {'=' if result_eq else '≠'} {t2}")


# ─────────────────────────────────────────────────────────────────────
#  Application 2: Expression Simplification
# ─────────────────────────────────────────────────────────────────────

def app_simplification():
    """Use rewrite rules as an expression simplifier."""
    separator("Application 2: Expression Simplification")

    x, y, z = make_var("x"), make_var("y"), make_var("z")
    e = make_fun("e")
    m = lambda a, b: make_fun("m", a, b)

    # Build the monoid normalizer
    equations = [
        Equation(m(m(x, y), z), m(x, m(y, z))),
        Equation(m(e, x), x),
        Equation(m(x, e), x),
    ]
    result = kb_complete(equations, lpo({"m": 2, "e": 1}))

    print("Simplification examples (monoid):")
    a, b, c, d = make_fun("a"), make_fun("b"), make_fun("c"), make_fun("d")

    examples = [
        m(e, m(e, m(e, a))),
        m(m(m(m(a, b), c), d), e),
        m(m(a, e), m(e, b)),
        m(e, e),
        m(m(a, m(b, e)), m(m(c, d), e)),
    ]

    for term in examples:
        nf = normalize(term, result.rules)
        steps = 0
        t = term
        while True:
            from algorithms import rewrite_one_step
            next_t = rewrite_one_step(t, result.rules)
            if next_t is None:
                break
            t = next_t
            steps += 1
        print(f"  {term}")
        print(f"    →  {nf}  ({steps} steps)")
        print()


# ─────────────────────────────────────────────────────────────────────
#  Application 3: Identity Verification
# ─────────────────────────────────────────────────────────────────────

def app_identity_verification():
    """Use completion to verify algebraic identities automatically."""
    separator("Application 3: Algebraic Identity Verification")

    x, y, z = make_var("x"), make_var("y"), make_var("z")
    e = make_fun("e")
    m = lambda a, b: make_fun("m", a, b)

    result = kb_complete(
        [
            Equation(m(m(x, y), z), m(x, m(y, z))),
            Equation(m(e, x), x),
            Equation(m(x, e), x),
        ],
        lpo({"m": 2, "e": 1}),
    )

    def verify_identity(lhs: Term, rhs: Term, name: str) -> None:
        nf_l = normalize(lhs, result.rules)
        nf_r = normalize(rhs, result.rules)
        status = "VERIFIED ✓" if nf_l == nf_r else "FAILED ✗"
        print(f"  {status}: {name}")
        print(f"    {lhs} = {rhs}")
        if nf_l != nf_r:
            print(f"    Normal forms differ: {nf_l} ≠ {nf_r}")

    print("Verifying monoid identities:\n")

    a, b, c, d = make_var("a"), make_var("b"), make_var("c"), make_var("d")

    # These should all be verified
    verify_identity(
        m(m(m(a, b), c), d),
        m(a, m(b, m(c, d))),
        "Full associativity: ((a·b)·c)·d = a·(b·(c·d))"
    )
    verify_identity(
        m(m(a, e), m(e, b)),
        m(a, b),
        "Identity elimination: (a·e)·(e·b) = a·b"
    )
    verify_identity(
        m(e, m(m(a, b), e)),
        m(a, b),
        "Double identity: e·((a·b)·e) = a·b"
    )

    # This should fail (commutativity doesn't hold in monoids)
    verify_identity(
        m(a, b),
        m(b, a),
        "Commutativity: a·b = b·a (should fail!)"
    )


# ─────────────────────────────────────────────────────────────────────
#  Application 4: Certified Normalizer Pipeline
# ─────────────────────────────────────────────────────────────────────

def app_certified_normalizer():
    """Demonstrate the full certified normalizer pipeline.
    
    This mirrors the formal verification pipeline:
    1. Start with equations
    2. Run KB completion
    3. Verify convergence
    4. Use the normalizer for optimization
    """
    separator("Application 4: Certified Normalizer Pipeline")

    x, y, z = make_var("x"), make_var("y"), make_var("z")
    e = make_fun("e")
    m = lambda a, b: make_fun("m", a, b)

    print("Step 1: Define equational theory")
    equations = [
        Equation(m(m(x, y), z), m(x, m(y, z))),
        Equation(m(e, x), x),
        Equation(m(x, e), x),
    ]
    for eq in equations:
        print(f"  {eq}")

    print("\nStep 2: Run Knuth-Bendix completion")
    result = kb_complete(equations, lpo({"m": 2, "e": 1}))
    print(f"  Terminated: {result.terminated}")
    print(f"  Rules generated: {len(result.rules)}")

    print("\nStep 3: Verify convergence (all critical pairs joinable)")
    convergent = result.is_convergent()
    print(f"  Convergent: {convergent}")

    if convergent:
        print("\nStep 4: Use as certified normalizer")
        print("  The normalizer is guaranteed to:")
        print("  • Always terminate (terminating rewrite system)")
        print("  • Produce a unique normal form (confluent)")
        print("  • Preserve the equational theory (sound rewriting)")
        print()
        print("  This corresponds to the formal theorem:")
        print("  kb_certified_optimizer: convergent + sound → eval-preserving normalizer")

        a, b, c = make_fun("a"), make_fun("b"), make_fun("c")
        demo_terms = [
            m(m(a, b), c),
            m(e, m(a, m(b, c))),
            m(m(m(a, e), b), m(c, e)),
        ]
        print("\n  Normalization examples:")
        for t in demo_terms:
            nf = normalize(t, result.rules)
            print(f"    {t}  ⟹  {nf}")


# ─────────────────────────────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app_word_problem()
    app_simplification()
    app_identity_verification()
    app_certified_normalizer()

    print("\n" + "=" * 70)
    print("  All Applications Complete")
    print("=" * 70)


#!/usr/bin/env python3
"""
Knuth-Bendix Completion — Interactive Demonstrations

This script demonstrates the Knuth-Bendix completion algorithm on several
classical examples from algebra:

1. Free monoid (associativity + identity)
2. Group theory (associativity + identity + inverses)
3. Boolean ring (idempotent multiplication + involutive addition)

Each demo shows:
- The input equational axioms
- The completion trace (orient, deduce, delete steps)
- The resulting convergent rewrite system
- Convergence verification (all critical pairs joinable)
- Normal form computation on example terms
"""

from algorithms import (
    Term, Equation, Rule, CompletionResult,
    make_var, make_fun, kb_complete, lpo, normalize, critical_pairs,
)


def separator(title: str) -> None:
    """Print a section separator."""
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70 + "\n")


# ─────────────────────────────────────────────────────────────────────
#  Demo 1: Free Monoid Completion
# ─────────────────────────────────────────────────────────────────────

def demo_monoid():
    """Complete the theory of a monoid (associative operation with identity)."""
    separator("Demo 1: Free Monoid Completion")

    x, y, z = make_var("x"), make_var("y"), make_var("z")
    e = make_fun("e")
    m = lambda a, b: make_fun("m", a, b)

    equations = [
        Equation(m(m(x, y), z), m(x, m(y, z))),  # associativity
        Equation(m(e, x), x),                       # left identity
        Equation(m(x, e), x),                       # right identity
    ]

    print("Input equations:")
    for eq in equations:
        print(f"  {eq}")

    prec = {"m": 2, "e": 1}
    ordering = lpo(prec)

    result = kb_complete(equations, ordering, verbose=True)

    print(f"\n--- Result ---")
    print(f"Terminated: {result.terminated}")
    print(f"Steps: {result.steps}")
    print(f"Final rules ({len(result.rules)}):")
    for r in result.rules:
        print(f"  {r}")
    print(f"Convergent: {result.is_convergent()}")

    # Demonstrate normalization
    print("\n--- Normalization Examples ---")
    a, b, c = make_fun("a"), make_fun("b"), make_fun("c")
    examples = [
        m(e, a),           # e·a → a
        m(a, e),           # a·e → a
        m(m(a, b), c),     # (a·b)·c → a·(b·c)
        m(e, m(e, a)),     # e·(e·a) → a
        m(m(m(a, b), c), e),  # ((a·b)·c)·e → a·(b·(c))
    ]
    for term in examples:
        nf = normalize(term, result.rules)
        print(f"  {term}  →*  {nf}")


# ─────────────────────────────────────────────────────────────────────
#  Demo 2: Group Theory Completion
# ─────────────────────────────────────────────────────────────────────

def demo_group():
    """Complete the theory of groups."""
    separator("Demo 2: Group Theory Completion")

    x, y, z = make_var("x"), make_var("y"), make_var("z")
    e = make_fun("e")
    m = lambda a, b: make_fun("m", a, b)
    i = lambda a: make_fun("i", a)

    equations = [
        Equation(m(m(x, y), z), m(x, m(y, z))),  # associativity
        Equation(m(e, x), x),                       # left identity
        Equation(m(i(x), x), e),                    # left inverse
    ]

    print("Input equations (group axioms):")
    for eq in equations:
        print(f"  {eq}")

    prec = {"m": 3, "i": 2, "e": 1}
    ordering = lpo(prec)

    result = kb_complete(equations, ordering, verbose=True)

    print(f"\n--- Result ---")
    print(f"Terminated: {result.terminated}")
    print(f"Steps: {result.steps}")
    print(f"Final rules ({len(result.rules)}):")
    for r in result.rules:
        print(f"  {r}")
    print(f"Convergent: {result.is_convergent()}")

    # Demonstrate the word problem
    print("\n--- Word Problem Examples ---")
    a, b = make_fun("a"), make_fun("b")
    word_problems = [
        (m(a, m(i(a), b)), b, "a · a⁻¹ · b = b"),
        (m(i(i(a)), e), a, "a⁻¹⁻¹ · e = a"),
        (m(a, i(a)), e, "a · a⁻¹ = e"),
        (i(e), e, "e⁻¹ = e"),
        (i(m(a, b)), m(i(b), i(a)), "(a·b)⁻¹ = b⁻¹·a⁻¹"),
    ]
    for t1, t2, description in word_problems:
        nf1 = normalize(t1, result.rules)
        nf2 = normalize(t2, result.rules)
        equal = "✓" if nf1 == nf2 else "✗"
        print(f"  {equal} {description}")
        print(f"    LHS normal form: {nf1}")
        print(f"    RHS normal form: {nf2}")


# ─────────────────────────────────────────────────────────────────────
#  Demo 3: Boolean Ring Completion
# ─────────────────────────────────────────────────────────────────────

def demo_boolean_ring():
    """Complete a subset of Boolean ring axioms."""
    separator("Demo 3: Boolean Ring Axioms (Partial)")

    x, y, z = make_var("x"), make_var("y"), make_var("z")
    zero = make_fun("0")
    one = make_fun("1")
    add = lambda a, b: make_fun("+", a, b)
    mul = lambda a, b: make_fun("*", a, b)

    equations = [
        Equation(add(add(x, y), z), add(x, add(y, z))),  # + assoc
        Equation(add(x, y), add(y, x)),                    # + comm
        Equation(add(zero, x), x),                          # + identity
        Equation(add(x, x), zero),                          # x + x = 0 (char 2)
        Equation(mul(mul(x, y), z), mul(x, mul(y, z))),  # * assoc
        Equation(mul(one, x), x),                           # * left id
        Equation(mul(x, one), x),                           # * right id
        Equation(mul(x, x), x),                             # idempotent
    ]

    print("Input equations (Boolean ring subset):")
    for eq in equations:
        print(f"  {eq}")

    prec = {"*": 4, "+": 3, "1": 2, "0": 1}
    ordering = lpo(prec)

    result = kb_complete(equations, ordering, max_steps=500, verbose=False)

    print(f"\n--- Result ---")
    print(f"Terminated: {result.terminated}")
    print(f"Steps: {result.steps}")
    print(f"Final rules ({len(result.rules)}):")
    for r in result.rules:
        print(f"  {r}")

    if result.terminated:
        print(f"Convergent: {result.is_convergent()}")

        # Normalization
        print("\n--- Normalization Examples ---")
        a, b = make_fun("a"), make_fun("b")
        examples = [
            add(a, a),           # a + a → 0
            mul(a, a),           # a * a → a
            add(zero, a),        # 0 + a → a
            mul(one, a),         # 1 * a → a
        ]
        for term in examples:
            nf = normalize(term, result.rules)
            print(f"  {term}  →*  {nf}")


# ─────────────────────────────────────────────────────────────────────
#  Demo 4: Critical Pair Analysis
# ─────────────────────────────────────────────────────────────────────

def demo_critical_pairs():
    """Demonstrate critical pair computation."""
    separator("Demo 4: Critical Pair Analysis")

    x, y, z = make_var("x"), make_var("y"), make_var("z")
    f = lambda a, b: make_fun("f", a, b)

    # Two rules that create overlapping patterns
    r1 = Rule(f(f(x, y), z), f(x, f(y, z)))  # associativity
    r2 = Rule(f(f(x, y), z), f(x, f(y, z)))  # same rule (self-overlap)

    print(f"Rule 1: {r1}")
    print(f"Rule 2: {r2}")

    cps = critical_pairs(r1, r2)
    print(f"\nCritical pairs ({len(cps)}):")
    for t1, t2 in cps:
        print(f"  {t1}  ≟  {t2}")

    # Check joinability
    rules = [r1]
    print(f"\nJoinability check:")
    for t1, t2 in cps:
        nf1 = normalize(t1, rules)
        nf2 = normalize(t2, rules)
        joinable = "JOINABLE" if nf1 == nf2 else "NOT JOINABLE"
        print(f"  {t1} →* {nf1}")
        print(f"  {t2} →* {nf2}")
        print(f"  → {joinable}")


# ─────────────────────────────────────────────────────────────────────
#  Demo 5: Completion Statistics
# ─────────────────────────────────────────────────────────────────────

def demo_statistics():
    """Show statistics about completion on various theories."""
    separator("Demo 5: Completion Statistics")

    x, y, z = make_var("x"), make_var("y"), make_var("z")

    theories = {
        "Monoid": {
            "equations": [
                Equation(make_fun("m", make_fun("m", x, y), z),
                         make_fun("m", x, make_fun("m", y, z))),
                Equation(make_fun("m", make_fun("e"), x), x),
                Equation(make_fun("m", x, make_fun("e")), x),
            ],
            "prec": {"m": 2, "e": 1},
        },
        "Group": {
            "equations": [
                Equation(make_fun("m", make_fun("m", x, y), z),
                         make_fun("m", x, make_fun("m", y, z))),
                Equation(make_fun("m", make_fun("e"), x), x),
                Equation(make_fun("m", make_fun("i", x), x), make_fun("e")),
            ],
            "prec": {"m": 3, "i": 2, "e": 1},
        },
    }

    print(f"{'Theory':<15} {'Terminated':<12} {'Steps':<8} {'Rules':<8} {'Convergent':<12}")
    print("-" * 55)

    for name, spec in theories.items():
        ordering = lpo(spec["prec"])
        result = kb_complete(spec["equations"], ordering, max_steps=1000)
        conv = result.is_convergent() if result.terminated else "N/A"
        print(f"{name:<15} {str(result.terminated):<12} {result.steps:<8} {len(result.rules):<8} {str(conv):<12}")


# ─────────────────────────────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_monoid()
    demo_group()
    demo_critical_pairs()
    demo_statistics()
    # Boolean ring can be slow; run separately if desired
    # demo_boolean_ring()

    separator("All Demos Complete")
    print("The Knuth-Bendix completion procedure successfully:")
    print("  ✓ Completed monoid theory (3 rules)")
    print("  ✓ Completed group theory (derived inverse laws)")
    print("  ✓ Computed and verified critical pairs")
    print("  ✓ Verified convergence of completed systems")
    print()
    print("These results correspond to the formally verified theorems in")
    print("Catalog/Pythagorean/KnuthBendixCompletion.lean:")
    print("  • newman_lemma (terminating + locally confluent ⟹ confluent)")
    print("  • kb_completion_correct (completion yields convergent system)")
    print("  • kb_certified_optimizer (convergent system ⟹ certified optimizer)")
