#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Certified Term Rewriting

Demonstrates practical applications of the term algebra and completion framework:
1. Algebraic simplification (Boolean algebra)
2. Symbolic equation solving
3. Canonical form computation
4. Pattern-based code optimization
"""

from algorithms import (
    Term, Var, App, FnSym, Rule, Equation, Substitution,
    match_term, apply_subst, normalize, CompletionState,
    orient_step, compute_critical_pairs, deduce_step,
    pretty_term, pretty_rule, pretty_equation
)


def application_1_boolean_simplification():
    """Application 1: Boolean Algebra Simplification
    
    Use rewrite rules to simplify Boolean expressions.
    The rules form a convergent system for Boolean algebra.
    """
    print("=" * 60)
    print("Application 1: Boolean Algebra Simplification")
    print("=" * 60)
    
    # Signature
    AND = FnSym("∧", 2)
    OR = FnSym("∨", 2)
    NOT = FnSym("¬", 1)
    T = FnSym("⊤", 0)
    F = FnSym("⊥", 0)
    
    x, y = Var("x"), Var("y")
    
    # Simplification rules (convergent for propositional logic)
    rules = [
        Rule(App(AND, [App(T, []), x]), x),           # ⊤ ∧ x → x
        Rule(App(AND, [x, App(T, [])]), x),           # x ∧ ⊤ → x
        Rule(App(AND, [App(F, []), x]), App(F, [])),   # ⊥ ∧ x → ⊥
        Rule(App(AND, [x, App(F, [])]), App(F, [])),   # x ∧ ⊥ → ⊥
        Rule(App(OR, [App(T, []), x]), App(T, [])),    # ⊤ ∨ x → ⊤
        Rule(App(OR, [x, App(T, [])]), App(T, [])),    # x ∨ ⊤ → ⊤
        Rule(App(OR, [App(F, []), x]), x),             # ⊥ ∨ x → x
        Rule(App(OR, [x, App(F, [])]), x),             # x ∨ ⊥ → x
        Rule(App(NOT, [App(T, [])]), App(F, [])),      # ¬⊤ → ⊥
        Rule(App(NOT, [App(F, [])]), App(T, [])),      # ¬⊥ → ⊤
        Rule(App(NOT, [App(NOT, [x])]), x),            # ¬¬x → x
        Rule(App(AND, [x, x]), x),                     # x ∧ x → x
        Rule(App(OR, [x, x]), x),                      # x ∨ x → x
    ]
    
    print("\nRules:")
    for r in rules:
        print(f"  {pretty_rule(r)}")
    
    # Test expressions
    p, q = Var("p"), Var("q")
    
    tests = [
        App(AND, [App(T, []), App(OR, [p, App(F, [])])]),     # ⊤ ∧ (p ∨ ⊥)
        App(NOT, [App(NOT, [App(AND, [p, App(T, [])])])]),    # ¬¬(p ∧ ⊤)
        App(OR, [App(AND, [App(F, []), p]), q]),               # (⊥ ∧ p) ∨ q
        App(AND, [App(OR, [p, p]), App(NOT, [App(NOT, [q])])]),# (p ∨ p) ∧ ¬¬q
    ]
    
    print("\nSimplifications:")
    for t in tests:
        nf = normalize(rules, t)
        print(f"  {pretty_term(t)}")
        print(f"    → {pretty_term(nf)}")


def application_2_monoid_normalization():
    """Application 2: Monoid Expression Normalization
    
    Normalize expressions in a monoid (with identity and associativity).
    """
    print("\n" + "=" * 60)
    print("Application 2: Monoid Expression Normalization")
    print("=" * 60)
    
    mul = FnSym("·", 2)
    e = FnSym("e", 0)
    x, y, z = Var("x"), Var("y"), Var("z")
    
    rules = [
        Rule(App(mul, [App(e, []), x]), x),             # e · x → x
        Rule(App(mul, [x, App(e, [])]), x),             # x · e → x
        Rule(App(mul, [App(mul, [x, y]), z]),            # (x·y)·z → x·(y·z)
             App(mul, [x, App(mul, [y, z])])),
    ]
    
    print("\nRules (convergent monoid presentation):")
    for r in rules:
        print(f"  {pretty_rule(r)}")
    
    a, b, c = (FnSym(n, 0) for n in "abc")
    
    tests = [
        App(mul, [App(e, []), App(mul, [App(a, []), App(b, [])])]),
        App(mul, [App(mul, [App(a, []), App(e, [])]), App(b, [])]),
        App(mul, [App(mul, [App(mul, [App(a, []), App(b, [])]), App(c, [])]), App(e, [])]),
    ]
    
    print("\nNormalizations:")
    for t in tests:
        nf = normalize(rules, t)
        print(f"  {pretty_term(t)}")
        print(f"    → {pretty_term(nf)}")


def application_3_pattern_optimization():
    """Application 3: Pattern-Based Expression Optimization
    
    Demonstrates how rewriting can optimize arithmetic expressions,
    analogous to compiler optimization passes.
    """
    print("\n" + "=" * 60)
    print("Application 3: Arithmetic Expression Optimization")
    print("=" * 60)
    
    add = FnSym("+", 2)
    mul = FnSym("*", 2)
    zero = FnSym("0", 0)
    one = FnSym("1", 0)
    x, y = Var("x"), Var("y")
    
    rules = [
        Rule(App(add, [x, App(zero, [])]), x),         # x + 0 → x
        Rule(App(add, [App(zero, []), x]), x),         # 0 + x → x
        Rule(App(mul, [x, App(one, [])]), x),          # x * 1 → x
        Rule(App(mul, [App(one, []), x]), x),          # 1 * x → x
        Rule(App(mul, [x, App(zero, [])]), App(zero, [])),  # x * 0 → 0
        Rule(App(mul, [App(zero, []), x]), App(zero, [])),  # 0 * x → 0
    ]
    
    print("\nOptimization rules:")
    for r in rules:
        print(f"  {pretty_rule(r)}")
    
    a, b = Var("a"), Var("b")
    
    tests = [
        App(add, [App(mul, [a, App(one, [])]), App(zero, [])]),
        App(mul, [App(add, [b, App(zero, [])]), App(mul, [App(one, []), a])]),
        App(mul, [App(add, [a, App(zero, [])]), App(zero, [])]),
    ]
    
    print("\nOptimizations:")
    for t in tests:
        nf = normalize(rules, t)
        print(f"  {pretty_term(t)}")
        print(f"    → {pretty_term(nf)}")
        if nf != t:
            print(f"    (simplified!)")


def application_4_tree_language():
    """Application 4: Tree Language Recognition via Matching
    
    Demonstrates the connection between pattern matching and tree automata:
    the set of all terms matching a pattern forms a regular tree language.
    """
    print("\n" + "=" * 60)
    print("Application 4: Tree Language Recognition")
    print("=" * 60)
    
    f = FnSym("f", 2)
    g = FnSym("g", 1)
    a = FnSym("a", 0)
    b = FnSym("b", 0)
    x, y = Var("x"), Var("y")
    
    pattern = App(f, [x, App(g, [y])])
    print(f"\nPattern: {pretty_term(pattern)}")
    print(f"Language L(pattern) = {{ t | ∃σ. pattern[σ] = t }}")
    
    # Generate all terms up to depth 2 and test membership
    terms_depth_1 = [App(a, []), App(b, [])]
    terms_depth_2 = []
    for t1 in terms_depth_1:
        terms_depth_2.append(App(g, [t1]))
        for t2 in terms_depth_1:
            terms_depth_2.append(App(f, [t1, t2]))
    
    all_terms = terms_depth_1 + terms_depth_2
    
    # Add some depth-3 terms
    for t1 in terms_depth_1:
        for t2 in terms_depth_1:
            all_terms.append(App(f, [t1, App(g, [t2])]))
            all_terms.append(App(f, [App(g, [t1]), App(g, [t2])]))
    
    print(f"\nTesting {len(all_terms)} terms for membership:")
    members = []
    non_members = []
    for t in all_terms:
        sigma = match_term(pattern, t)
        if sigma is not None:
            members.append((t, sigma))
        else:
            non_members.append(t)
    
    print(f"\n  Members ({len(members)}):")
    for t, sigma in members:
        bindings = ", ".join(f"{k}↦{pretty_term(v)}" for k, v in sigma.items())
        print(f"    {pretty_term(t)}  [σ = {{{bindings}}}]")
    
    print(f"\n  Non-members ({len(non_members)}, showing first 5):")
    for t in non_members[:5]:
        print(f"    {pretty_term(t)}")


if __name__ == "__main__":
    application_1_boolean_simplification()
    application_2_monoid_normalization()
    application_3_pattern_optimization()
    application_4_tree_language()
    
    print("\n" + "=" * 60)
    print("All applications demonstrate algorithms that are formally")
    print("verified in the Lean development to preserve equational")
    print("semantics — every simplification is provably correct.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Concrete First-Order Term Algebra: Matching, Rewriting, and Completion

Demonstrates certified matching, rewriting, and Knuth-Bendix completion steps
on first-order terms, including the free group presentation test case.
"""

from algorithms import (
    Term, Var, App, FnSym, Rule, Equation, Substitution,
    match_term, apply_subst, rewrite_at_root, rewrite_one_step,
    normalize, CompletionState, orient_step, delete_step,
    simplify_step, compose_step, deduce_step, compute_critical_pairs,
    pretty_term, pretty_rule, pretty_equation
)

def section(title):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


def demo_terms_and_substitutions():
    section("1. Terms and Substitutions")
    
    # Define function symbols
    f = FnSym("f", 2)
    g = FnSym("g", 1)
    a = FnSym("a", 0)
    b = FnSym("b", 0)
    
    # Build terms
    x, y = Var("x"), Var("y")
    t1 = App(f, [x, App(g, [y])])
    t2 = App(f, [App(a, []), App(g, [App(b, [])])])
    
    print(f"Term t1 = {pretty_term(t1)}")
    print(f"Term t2 = {pretty_term(t2)}")
    
    # Substitution
    sigma = {"x": App(a, []), "y": App(b, [])}
    t1_sigma = apply_subst(sigma, t1)
    print(f"\nSubstitution σ = {{x ↦ {pretty_term(sigma['x'])}, y ↦ {pretty_term(sigma['y'])}}}")
    print(f"t1[σ] = {pretty_term(t1_sigma)}")
    print(f"t1[σ] = t2? {t1_sigma == t2}")
    
    # Identity substitution
    id_subst = {}
    print(f"\nt1[id] = {pretty_term(apply_subst(id_subst, t1))}")
    print(f"t1[id] = t1? {apply_subst(id_subst, t1) == t1}")


def demo_matching():
    section("2. Pattern Matching")
    
    f = FnSym("f", 2)
    g = FnSym("g", 1)
    a = FnSym("a", 0)
    b = FnSym("b", 0)
    x, y, z = Var("x"), Var("y"), Var("z")
    
    # Match f(x, g(y)) against f(a, g(b))
    pattern = App(f, [x, App(g, [y])])
    target = App(f, [App(a, []), App(g, [App(b, [])])])
    
    print(f"Pattern: {pretty_term(pattern)}")
    print(f"Target:  {pretty_term(target)}")
    result = match_term(pattern, target)
    if result is not None:
        print(f"Match:   {{{', '.join(f'{k} ↦ {pretty_term(v)}' for k, v in result.items())}}}")
        print(f"Verify:  pattern[σ] = {pretty_term(apply_subst(result, pattern))}")
    
    # Non-matching case
    pattern2 = App(f, [App(a, []), y])
    target2 = App(f, [App(b, []), App(a, [])])
    print(f"\nPattern: {pretty_term(pattern2)}")
    print(f"Target:  {pretty_term(target2)}")
    result2 = match_term(pattern2, target2)
    print(f"Match:   {'None (correctly fails — a ≠ b)' if result2 is None else result2}")
    
    # Variable consistency check
    pattern3 = App(f, [x, x])
    target3 = App(f, [App(a, []), App(b, [])])
    print(f"\nPattern: {pretty_term(pattern3)}")
    print(f"Target:  {pretty_term(target3)}")
    result3 = match_term(pattern3, target3)
    print(f"Match:   {'None (correctly fails — x bound to a and b)' if result3 is None else result3}")


def demo_rewriting():
    section("3. One-Step Rewriting")
    
    f = FnSym("f", 2)
    a = FnSym("a", 0)
    b = FnSym("b", 0)
    x, y = Var("x"), Var("y")
    
    # Rule: f(a, x) → x
    rule = Rule(App(f, [App(a, []), x]), x)
    print(f"Rule: {pretty_rule(rule)}")
    
    # Term: f(a, f(a, b))
    term = App(f, [App(a, []), App(f, [App(a, []), App(b, [])])])
    print(f"Term: {pretty_term(term)}")
    
    result = rewrite_one_step([rule], term)
    if result:
        print(f"One step: {pretty_term(term)} → {pretty_term(result)}")
    
    # Normalize (apply rules until no more apply)
    nf = normalize([rule], term, max_steps=10)
    print(f"Normal form: {pretty_term(nf)}")


def demo_free_group():
    section("4. Free Group Presentation — Canonical Test Case")
    
    # Signature: mul (binary), inv (unary), e (nullary)
    mul = FnSym("*", 2)
    inv = FnSym("⁻¹", 1)
    e = FnSym("1", 0)
    x, y, z = Var("x"), Var("y"), Var("z")
    
    # Free group axioms as equations
    equations = [
        Equation(App(mul, [App(e, []), x]), x),                          # 1 * x = x
        Equation(App(mul, [App(inv, [x]), x]), App(e, [])),              # x⁻¹ * x = 1
        Equation(App(mul, [App(mul, [x, y]), z]),                        # (x*y)*z = x*(y*z)
                 App(mul, [x, App(mul, [y, z])])),
    ]
    
    print("Free group equations:")
    for i, eq in enumerate(equations):
        print(f"  ({i+1}) {pretty_equation(eq)}")
    
    # Initial completion state
    state = CompletionState(equations=list(equations), rules=[])
    print(f"\nInitial state: {len(state.equations)} equations, {len(state.rules)} rules")
    
    # Step 1: Orient equation 1 → rule (left-to-right)
    print("\n--- Completion Steps ---")
    state = orient_step(state, 0)
    print(f"Orient eq 1: {pretty_rule(state.rules[-1])}")
    
    # Step 2: Orient equation 2
    state = orient_step(state, 0)
    print(f"Orient eq 2: {pretty_rule(state.rules[-1])}")
    
    # Step 3: Orient equation 3
    state = orient_step(state, 0)
    print(f"Orient eq 3: {pretty_rule(state.rules[-1])}")
    
    print(f"\nAfter orienting: {len(state.equations)} equations, {len(state.rules)} rules")
    print("\nCurrent rules:")
    for r in state.rules:
        print(f"  {pretty_rule(r)}")
    
    # Compute critical pairs
    print("\n--- Critical Pairs ---")
    cps = compute_critical_pairs(state.rules)
    for i, (s, t) in enumerate(cps[:8]):
        print(f"  CP {i+1}: {pretty_term(s)} ≈ {pretty_term(t)}")
    if len(cps) > 8:
        print(f"  ... and {len(cps) - 8} more")
    
    # Add critical pairs as equations (deduce)
    for s, t in cps[:5]:
        state = deduce_step(state, s, t)
    
    print(f"\nAfter deducing CPs: {len(state.equations)} equations, {len(state.rules)} rules")
    
    # Try some simplification
    for _ in range(3):
        changed = False
        for i in range(len(state.equations)):
            new_state = simplify_step(state, i)
            if new_state is not None:
                state = new_state
                changed = True
                break
        for i in range(len(state.equations)):
            new_state = delete_step(state, i)
            if new_state is not None:
                state = new_state
                changed = True
                break
        if not changed:
            break
    
    print(f"After simplification: {len(state.equations)} equations, {len(state.rules)} rules")
    
    # Show some normalization
    print("\n--- Normalization Examples ---")
    # 1 * (x⁻¹ * x) should normalize
    test_term = App(mul, [App(e, []), App(mul, [App(inv, [Var("a")]), Var("a")])])
    nf = normalize(state.rules, test_term, max_steps=20)
    print(f"  {pretty_term(test_term)} →* {pretty_term(nf)}")
    
    # (1 * x) should normalize to x
    test_term2 = App(mul, [App(e, []), Var("a")])
    nf2 = normalize(state.rules, test_term2, max_steps=20)
    print(f"  {pretty_term(test_term2)} →* {pretty_term(nf2)}")
    
    print("\n[Note: Full KB completion of the free group requires ~10 additional rules")
    print(" including x*1=x, x*x⁻¹=1, (x⁻¹)⁻¹=x, etc. A complete convergent")
    print(" presentation is well-known but requires careful choice of reduction order.]")


def demo_completion_trace():
    section("5. Completion Trace — Semigroup Laws")
    
    # Simpler example: semigroup (just associativity)
    f = FnSym("·", 2)
    x, y, z = Var("x"), Var("y"), Var("z")
    
    # (x·y)·z = x·(y·z)
    assoc = Equation(
        App(f, [App(f, [x, y]), z]),
        App(f, [x, App(f, [y, z])])
    )
    
    state = CompletionState(equations=[assoc], rules=[])
    print(f"Initial: {pretty_equation(assoc)}")
    
    # Orient
    state = orient_step(state, 0)
    print(f"Orient: {pretty_rule(state.rules[0])}")
    
    # Compute critical pairs
    cps = compute_critical_pairs(state.rules)
    print(f"\nCritical pairs: {len(cps)}")
    for s, t in cps:
        print(f"  {pretty_term(s)} ≈ {pretty_term(t)}")
    
    # For semigroup with just associativity, KB completion terminates immediately
    # (the single rule is already convergent — it's just flattening to right-associated form)
    print("\nThe associativity rule alone forms a convergent system!")
    print("Any term normalizes to right-associated form.")
    
    # Demo normalization
    a, b, c, d = (FnSym(n, 0) for n in "abcd")
    term = App(f, [App(f, [App(f, [App(a,[]), App(b,[])]), App(c,[])]), App(d,[])])
    nf = normalize(state.rules, term, max_steps=20)
    print(f"\n  {pretty_term(term)}")
    print(f"  →* {pretty_term(nf)}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Concrete First-Order Term Algebra: Matching, Rewriting, Completion ║")
    print("║  Certified Symbolic Computation Demo                                ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_terms_and_substitutions()
    demo_matching()
    demo_rewriting()
    demo_free_group()
    demo_completion_trace()
    
    section("Summary")
    print("This demo illustrates the executable components that correspond to")
    print("formally verified theorems in the Lean development:")
    print()
    print("  • Substitution composition (subst_comp) — functorial property")
    print("  • Pattern matching (match_sound) — tree language recognition")
    print("  • Rewriting closure (rewrites_closed_under_subst_and_context)")
    print("  • Completion steps preserve equational theory")
    print("  • Global simulation: concrete completion → abstract correctness")
    print()
    print("Each operation demonstrated here has a corresponding formal proof")
    print("in Lean showing it preserves the equational theory.")
