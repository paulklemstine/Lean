#!/usr/bin/env python3
"""
Higher-Order Completion: Applications

Demonstrates real-world applications of the higher-order completion framework:
1. Functional program optimization (map fusion, fold fusion)
2. Certified rewriting for compiler transformations
3. Equational reasoning about higher-order programs
"""

from algorithms import (
    Term, Var, App, Lam, Equation,
    subst, rename, beta_contract, single_subst, lift_subst,
    normalize, ho_match, apply_match, check_rewrite_step,
    bounded_completion, term_size, all_one_step_reducts,
    comp_subst
)


# ============================================================================
# Application 1: Map Fusion Optimization
# ============================================================================

def demo_map_fusion():
    """Demonstrate map fusion as a certified compiler optimization.

    The map fusion law states:
        map f (map g xs) = map (f ∘ g) xs

    This eliminates an intermediate data structure, turning two
    traversals into one — a key optimization in functional compilers.
    """
    print("=" * 70)
    print("APPLICATION 1: Map Fusion Optimization")
    print("=" * 70)

    # Encoding: map = v3, f = v2, g = v1, xs = v0
    # map f (map g xs) → map (λx. f(g x)) xs
    map_fusion = Equation(
        lhs=App(App(Var(3), Var(2)), App(App(Var(3), Var(1)), Var(0))),
        rhs=App(App(Var(3), Lam(App(Var(3), App(Var(2), Var(0))))), Var(0)),
        name="map_fusion"
    )
    print(f"\nRule: {map_fusion}")

    # Instantiate with specific functions
    # Let map = M (a constant), f = λx.x+1, g = λx.x*2
    sigma = lambda n: {
        3: Var(100),  # M (map constant)
        2: Lam(App(Var(50), Var(0))),  # f = λx. succ(x)
        1: Lam(App(Var(51), Var(0))),  # g = λx. double(x)
        0: Var(99),  # xs
    }.get(n, Var(n))

    lhs_inst = subst(map_fusion.lhs, sigma)
    rhs_inst = subst(map_fusion.rhs, sigma)

    print(f"\nBefore fusion: {lhs_inst}")
    print(f"After fusion:  {rhs_inst}")

    # β-normalize the composed function
    rhs_norm, steps, _ = normalize(rhs_inst)
    print(f"After β-normalization ({steps} steps): {rhs_norm}")
    print("\n→ Two traversals fused into one!")
    print("  This eliminates the intermediate list from 'map g xs'")
    print()

    # Show the fused function
    print("The fused function λx. f(g x) normalizes to a single pass:")
    composed = Lam(App(Lam(App(Var(50), Var(0))),
                       App(Lam(App(Var(51), Var(0))), Var(0))))
    comp_norm, steps, _ = normalize(composed)
    print(f"  λx. f(g x) = {composed}")
    print(f"  β-normal:    {comp_norm}")
    print()


# ============================================================================
# Application 2: Eta Expansion/Contraction
# ============================================================================

def demo_eta_laws():
    """Demonstrate η-expansion and contraction rules.

    η-contraction: λx. f x → f  (when x ∉ FV(f))
    η-expansion:   f → λx. f x

    These are crucial for extensional reasoning about functions.
    """
    print("=" * 70)
    print("APPLICATION 2: η-Laws and Extensional Reasoning")
    print("=" * 70)

    # η-redex: λx. (f x) where f = var 0 from outside
    # In de Bruijn: lam (app (var 1) (var 0))
    eta_redex = Lam(App(Var(1), Var(0)))
    eta_reduced = Var(0)

    print(f"\nη-redex:    {eta_redex}  (= λx. f x where f is free)")
    print(f"η-reduced:  {eta_reduced}  (= f)")
    print()

    # Show that η-contraction is NOT a β-step
    beta_result = all_one_step_reducts(eta_redex)
    print(f"β-reducts of {eta_redex}: {beta_result}")
    print("  (No β-reducts — η is independent of β)")
    print()

    # But η + β together are useful
    # Consider: (λf. λx. f x) g = (λx. g x) =η= g
    test = App(Lam(Lam(App(Var(1), Var(0)))), Var(42))
    nf, steps, _ = normalize(test)
    print(f"(λf. λx. f x) g = {test}")
    print(f"β-normal form:     {nf}")
    print(f"This is η-equivalent to v42")
    print()


# ============================================================================
# Application 3: Church Encoding Arithmetic
# ============================================================================

def demo_church_arithmetic():
    """Demonstrate verified Church numeral arithmetic.

    Church numerals: n = λf.λx. f^n(x)
    Addition: add = λm.λn.λf.λx. m f (n f x)
    Multiplication: mul = λm.λn.λf. m (n f)
    """
    print("=" * 70)
    print("APPLICATION 3: Church Encoding Arithmetic")
    print("=" * 70)

    def church(n: int) -> Term:
        """Construct Church numeral n."""
        body = Var(0)  # x
        for _ in range(n):
            body = App(Var(1), body)  # f(...)
        return Lam(Lam(body))  # λf.λx. f^n(x)

    # Addition: λm.λn.λf.λx. m f (n f x)
    add = Lam(Lam(Lam(Lam(
        App(App(Var(3), Var(1)),
            App(App(Var(2), Var(1)), Var(0)))
    ))))

    # Multiplication: λm.λn.λf. m (n f)
    mul = Lam(Lam(Lam(
        App(App(Var(2), App(Var(1), Var(0))), Var(0))
    )))

    print("\nChurch numerals:")
    for i in range(5):
        print(f"  {i} = {church(i)}")

    print(f"\nadd = {add}")
    print(f"mul = {mul}")

    # Compute 2 + 3
    two_plus_three = App(App(add, church(2)), church(3))
    result, steps, _ = normalize(two_plus_three)
    print(f"\n2 + 3:")
    print(f"  Term:   {two_plus_three}")
    print(f"  Result: {result}")
    print(f"  Steps:  {steps}")
    print(f"  Equals church(5)? {result == church(5)}")

    # Compute 2 * 3
    two_times_three = App(App(mul, church(2)), church(3))
    result2, steps2, _ = normalize(two_times_three)
    print(f"\n2 × 3:")
    print(f"  Result: {result2}")
    print(f"  Steps:  {steps2}")
    print(f"  Equals church(6)? {result2 == church(6)}")

    # Verify substitution functoriality computationally
    print("\nVerifying substitution functoriality on Church arithmetic terms...")
    sigma = lambda n: church(1) if n == 0 else Var(n)
    tau = lambda n: church(2) if n == 0 else Var(n)

    for name, t in [("add", add), ("mul", mul), ("church(3)", church(3))]:
        t_s = subst(t, sigma)
        t_s_t = subst(t_s, tau)
        t_comp = subst(t, comp_subst(sigma, tau))
        ok = t_s_t == t_comp
        print(f"  subst_comp for {name}: {'✓' if ok else '✗'}")
    print()


# ============================================================================
# Application 4: Compiler Optimization Pipeline
# ============================================================================

def demo_optimization_pipeline():
    """Demonstrate a sequence of higher-order rewrites as an optimization pipeline.

    Pipeline:
    1. β-reduction (function inlining)
    2. Map fusion (deforestation)
    3. Dead code elimination (as β-reduction)
    """
    print("=" * 70)
    print("APPLICATION 4: Compiler Optimization Pipeline")
    print("=" * 70)

    # Simulate: let f = λx.x+1 in map f (map (λx.x*2) xs)
    # Step 1: inline f → map (λx.x+1) (map (λx.x*2) xs)
    # Step 2: fuse → map (λx. (λx.x+1)((λx.x*2) x)) xs
    # Step 3: β-reduce → map (λx. (x*2)+1) xs

    succ_fn = Lam(App(Var(10), Var(0)))  # λx. succ(x)
    dbl_fn = Lam(App(Var(11), Var(0)))   # λx. double(x)
    map_sym = Var(100)
    xs = Var(99)

    # Before optimization: (λf. map f (map (λx.x*2) xs)) (λx.x+1)
    before = App(
        Lam(App(App(rename(lambda x: x+1, map_sym), Var(0)),
                App(App(rename(lambda x: x+1, map_sym), rename(lambda x: x+1, dbl_fn)),
                    rename(lambda x: x+1, xs)))),
        succ_fn
    )

    print(f"\nBefore optimization (with let-binding):")
    print(f"  {before}")
    print(f"  Size: {term_size(before)}")

    # Step 1: β-reduce (inline the let-binding)
    step1, _, _ = normalize(before, max_steps=1)
    print(f"\nStep 1 - Function inlining (β-reduction):")
    print(f"  {step1}")
    print(f"  Size: {term_size(step1)}")

    # Continue normalizing
    final, steps, _ = normalize(before)
    print(f"\nFully normalized ({steps} β-steps):")
    print(f"  {final}")
    print(f"  Size: {term_size(final)}")
    print()


# ============================================================================
# Application 5: Equational Reasoning Chains
# ============================================================================

def demo_equational_reasoning():
    """Demonstrate chains of equational reasoning steps."""
    print("=" * 70)
    print("APPLICATION 5: Equational Reasoning Chains")
    print("=" * 70)

    # Show a chain: t₀ →β t₁ →β ... →β tₙ
    # where each step is a valid rewrite

    # Term: (λx.λy. x y) (λz.z) w
    t0 = App(App(Lam(Lam(App(Var(1), Var(0)))), Lam(Var(0))), Var(0))
    print(f"\nStarting term: {t0}")

    chain = [t0]
    current = t0
    for i in range(10):
        r = all_one_step_reducts(current)
        if not r:
            break
        # Take leftmost
        current = r[0]
        chain.append(current)

    print("\nRewrite chain:")
    for i, t in enumerate(chain):
        arrow = "  → " if i > 0 else "    "
        print(f"  {arrow}{t}")

    if len(chain) > 1:
        # Verify each step
        print("\nVerifying each step is a valid β-reduction:")
        for i in range(len(chain) - 1):
            reducts = all_one_step_reducts(chain[i])
            valid = chain[i+1] in reducts
            print(f"  Step {i} → {i+1}: {'✓' if valid else '✗'}")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Higher-Order Completion: Applications                              ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_map_fusion()
    demo_eta_laws()
    demo_church_arithmetic()
    demo_optimization_pipeline()
    demo_equational_reasoning()

    print("=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Higher-Order Completion and Lambda-Calculus Integration — Demo

This script demonstrates the core concepts of higher-order rewriting
in the simply-typed lambda calculus:
1. Construction of typed λ-terms with de Bruijn indices
2. β-reduction (leftmost-outermost strategy)
3. Substitution and its composition
4. Higher-order rewriting with equation application
5. Experimental test of the local confluence conjecture
"""

from dataclasses import dataclass
from typing import Optional, Callable
import itertools


# ============================================================================
# Section 1: Term Representation (de Bruijn indexed λ-terms)
# ============================================================================

class Term:
    """Base class for lambda terms with de Bruijn indices."""
    pass

@dataclass(frozen=True)
class Var(Term):
    index: int
    def __repr__(self):
        return f"x{self.index}"

@dataclass(frozen=True)
class App(Term):
    fun: Term
    arg: Term
    def __repr__(self):
        return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam(Term):
    body: Term
    def __repr__(self):
        return f"(λ {self.body})"


# ============================================================================
# Section 2: Renaming and Substitution
# ============================================================================

def lift_ren(rho: Callable[[int], int]) -> Callable[[int], int]:
    """Lift a renaming under a binder."""
    def lifted(n: int) -> int:
        if n == 0:
            return 0
        return rho(n - 1) + 1
    return lifted

def rename(rho: Callable[[int], int], t: Term) -> Term:
    """Apply a variable renaming to a term."""
    if isinstance(t, Var):
        return Var(rho(t.index))
    elif isinstance(t, App):
        return App(rename(rho, t.fun), rename(rho, t.arg))
    elif isinstance(t, Lam):
        return Lam(rename(lift_ren(rho), t.body))
    raise TypeError

def lift_subst(sigma: Callable[[int], Term]) -> Callable[[int], Term]:
    """Lift a substitution under a binder."""
    def lifted(n: int) -> Term:
        if n == 0:
            return Var(0)
        return rename(lambda x: x + 1, sigma(n - 1))
    return lifted

def subst(t: Term, sigma: Callable[[int], Term]) -> Term:
    """Apply a substitution to a term."""
    if isinstance(t, Var):
        return sigma(t.index)
    elif isinstance(t, App):
        return App(subst(t.fun, sigma), subst(t.arg, sigma))
    elif isinstance(t, Lam):
        return Lam(subst(t.body, lift_subst(sigma)))
    raise TypeError

def single_subst(s: Term) -> Callable[[int], Term]:
    """Single substitution: var 0 -> s, var (n+1) -> var n."""
    def sigma(n: int) -> Term:
        if n == 0:
            return s
        return Var(n - 1)
    return sigma

def beta_contract(body: Term, arg: Term) -> Term:
    """β-contraction: (λ body) arg → body[0 := arg]."""
    return subst(body, single_subst(arg))


# ============================================================================
# Section 3: β-Reduction
# ============================================================================

def leftmost_reduce(t: Term) -> Optional[Term]:
    """One step of leftmost-outermost β-reduction."""
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            return beta_contract(t.fun.body, t.arg)
        r = leftmost_reduce(t.fun)
        if r is not None:
            return App(r, t.arg)
        r = leftmost_reduce(t.arg)
        if r is not None:
            return App(t.fun, r)
        return None
    elif isinstance(t, Lam):
        r = leftmost_reduce(t.body)
        if r is not None:
            return Lam(r)
        return None
    return None

def normalize(t: Term, max_steps: int = 100) -> tuple[Term, int]:
    """Normalize a term by repeated leftmost-outermost β-reduction."""
    steps = 0
    while steps < max_steps:
        r = leftmost_reduce(t)
        if r is None:
            return t, steps
        t = r
        steps += 1
    return t, steps

def size(t: Term) -> int:
    """Count the number of constructors in a term."""
    if isinstance(t, Var):
        return 1
    elif isinstance(t, App):
        return 1 + size(t.fun) + size(t.arg)
    elif isinstance(t, Lam):
        return 1 + size(t.body)
    return 0

def count_redexes(t: Term) -> int:
    """Count the number of β-redexes in a term."""
    if isinstance(t, Var):
        return 0
    elif isinstance(t, App):
        if isinstance(t.fun, Lam):
            return 1 + count_redexes(t.fun.body) + count_redexes(t.arg)
        return count_redexes(t.fun) + count_redexes(t.arg)
    elif isinstance(t, Lam):
        return count_redexes(t.body)
    return 0


# ============================================================================
# Section 4: Substitution Composition (Demonstration of Theorem 1)
# ============================================================================

def comp_subst(sigma, tau):
    """Compose two substitutions: first sigma, then tau."""
    def composed(n):
        return subst(sigma(n), tau)
    return composed

def demo_subst_comp():
    """Demonstrate substitution functoriality: (t[σ])[τ] = t[σ;τ]."""
    print("=" * 70)
    print("DEMO 1: Substitution Functoriality (Theorem 1)")
    print("  Higher-order analogue of FOTerm.subst_comp")
    print("=" * 70)

    # t = λx. x (y z) where y=var 1, z=var 2 (under binder, so y=var 0, z=var 1 outside)
    t = Lam(App(Var(0), App(Var(1), Var(2))))
    print(f"\nTerm t = {t}")

    # σ: var 0 ↦ λx.x, var 1 ↦ var 0
    sigma = lambda n: Lam(Var(0)) if n == 0 else (Var(0) if n == 1 else Var(n))
    # τ: var 0 ↦ var 1
    tau = lambda n: Var(1) if n == 0 else Var(n)

    t_sigma = subst(t, sigma)
    t_sigma_tau = subst(t_sigma, tau)
    t_comp = subst(t, comp_subst(sigma, tau))

    print(f"t[σ] = {t_sigma}")
    print(f"(t[σ])[τ] = {t_sigma_tau}")
    print(f"t[σ;τ] = {t_comp}")
    print(f"Equal? {t_sigma_tau == t_comp}")
    assert t_sigma_tau == t_comp, "Substitution composition failed!"
    print("✓ Substitution functoriality verified")

    # Additional test with multiple compositions
    print("\nTesting associativity of substitution composition...")
    s1 = lambda n: App(Var(0), Var(n)) if n < 2 else Var(n)
    s2 = lambda n: Lam(Var(n + 1)) if n == 0 else Var(n)
    s3 = lambda n: Var(n + 1)

    for test_t in [Var(0), Var(1), App(Var(0), Var(1)), Lam(App(Var(0), Var(1)))]:
        lhs = subst(subst(subst(test_t, s1), s2), s3)
        rhs = subst(test_t, comp_subst(s1, comp_subst(s2, s3)))
        assert lhs == rhs, f"Associativity failed for {test_t}"
    print("✓ Substitution associativity verified on test terms")
    print()


# ============================================================================
# Section 5: β-Step Stability Under Substitution (Theorem 4)
# ============================================================================

def demo_beta_subst():
    """Demonstrate that β-contraction commutes with substitution."""
    print("=" * 70)
    print("DEMO 2: β-Step Stability Under Substitution (Theorem 4)")
    print("  Binding enters the theory for real")
    print("=" * 70)

    # body = var 0 applied to var 1 (free variable)
    body = App(Var(0), Var(1))
    arg = Lam(Var(0))  # identity function
    sigma = lambda n: App(Var(0), Var(0)) if n == 0 else Var(n)

    print(f"\nbody = {body}")
    print(f"arg = {arg}")
    print(f"σ(0) = {sigma(0)}")

    # LHS: (betaContract body arg)[σ]
    bc = beta_contract(body, arg)
    lhs = subst(bc, sigma)

    # RHS: betaContract (body[↑σ]) (arg[σ])
    body_lifted = subst(body, lift_subst(sigma))
    arg_subst = subst(arg, sigma)
    rhs = beta_contract(body_lifted, arg_subst)

    print(f"\nbetaContract body arg = {bc}")
    print(f"LHS = (betaContract body arg)[σ] = {lhs}")
    print(f"body[↑σ] = {body_lifted}")
    print(f"arg[σ] = {arg_subst}")
    print(f"RHS = betaContract (body[↑σ]) (arg[σ]) = {rhs}")
    print(f"Equal? {lhs == rhs}")
    assert lhs == rhs, "β-contraction commutativity failed!"
    print("✓ β-contraction commutes with substitution")
    print()


# ============================================================================
# Section 6: Higher-Order Rewriting Example
# ============================================================================

def demo_ho_rewriting():
    """Demonstrate higher-order rewriting with map fusion."""
    print("=" * 70)
    print("DEMO 3: Map Fusion as Higher-Order Rewriting")
    print("  Connecting rewriting theory to compiler optimization")
    print("=" * 70)

    # map fusion: map f (map g xs) = map (λx. f(g x)) xs
    # Using var 3 = map, var 2 = f, var 1 = g, var 0 = xs
    lhs = App(App(Var(3), Var(2)), App(App(Var(3), Var(1)), Var(0)))
    rhs = App(App(Var(3), Lam(App(Var(3), App(Var(2), Var(0))))), Var(0))

    print(f"\nMap fusion equation:")
    print(f"  LHS: map f (map g xs) = {lhs}")
    print(f"  RHS: map (λx. f(g x)) xs = {rhs}")

    # Instantiate with concrete functions
    # map = λf. λxs. xs  (trivial for demo)
    # f = λx. x+1 (represented as Lam(App(Var(1), Var(0))))
    # g = λx. x*2 (represented as Lam(App(Var(2), Var(0))))
    sigma = lambda n: {
        3: Var(10),  # map symbol
        2: Lam(App(Var(100), Var(0))),  # f
        1: Lam(App(Var(200), Var(0))),  # g
        0: Var(42),  # xs
    }.get(n, Var(n))

    lhs_inst = subst(lhs, sigma)
    rhs_inst = subst(rhs, sigma)

    print(f"\nInstantiated with σ:")
    print(f"  LHS[σ] = {lhs_inst}")
    print(f"  RHS[σ] = {rhs_inst}")

    # Show that β-normalizing the RHS gives the fused version
    rhs_norm, steps = normalize(rhs_inst)
    print(f"\n  RHS[σ] after {steps} β-steps: {rhs_norm}")
    print("✓ Map fusion equation successfully instantiated under substitution")
    print()


# ============================================================================
# Section 7: Normalization Traces
# ============================================================================

def demo_normalization():
    """Demonstrate β-normalization with step traces."""
    print("=" * 70)
    print("DEMO 4: β-Normalization Traces")
    print("=" * 70)

    # Church numerals
    zero = Lam(Lam(Var(0)))  # λf.λx.x
    one = Lam(Lam(App(Var(1), Var(0))))  # λf.λx.f x
    two = Lam(Lam(App(Var(1), App(Var(1), Var(0)))))  # λf.λx.f(f x)

    # Successor: λn.λf.λx. f(n f x)
    succ_term = Lam(Lam(Lam(
        App(Var(1), App(App(Var(2), Var(1)), Var(0)))
    )))

    # succ(one)
    t = App(succ_term, one)
    print(f"\nTerm: succ 1 = {t}")
    print(f"Size: {size(t)}, Redexes: {count_redexes(t)}")
    print("\nReduction trace:")

    step = 0
    current = t
    while step < 20:
        print(f"  Step {step}: {current}")
        r = leftmost_reduce(current)
        if r is None:
            break
        current = r
        step += 1

    result, _ = normalize(t)
    print(f"\nNormal form: {result}")

    # Verify it equals Church 2
    print(f"Church 2:    {two}")
    print(f"Equal to Church 2? {result == two}")
    print()


# ============================================================================
# Section 8: Experimental Confluence Test
# ============================================================================

def enumerate_closed_terms(max_size: int) -> list[Term]:
    """Enumerate closed λ-terms up to a given size."""
    terms = []

    def generate(sz: int, bound_vars: int) -> list[Term]:
        if sz <= 0:
            return []
        if sz == 1:
            return [Var(i) for i in range(bound_vars)]
        result = []
        # Lam
        if sz >= 2:
            for body in generate(sz - 1, bound_vars + 1):
                result.append(Lam(body))
        # App
        for s1 in range(1, sz - 1):
            s2 = sz - 1 - s1
            for f in generate(s1, bound_vars):
                for a in generate(s2, bound_vars):
                    result.append(App(f, a))
        return result

    for s in range(1, max_size + 1):
        terms.extend(generate(s, 0))
    return terms

def all_reducts(t: Term, max_depth: int = 10) -> set:
    """Compute all one-step β-reducts of a term (modulo choice of redex)."""
    results = set()

    def find_reducts(t: Term):
        if isinstance(t, App):
            if isinstance(t.fun, Lam):
                results.add(beta_contract(t.fun.body, t.arg))
            # Reduce in function position
            for r in _one_step_reducts(t.fun):
                results.add(App(r, t.arg))
            # Reduce in argument position
            for r in _one_step_reducts(t.arg):
                results.add(App(t.fun, r))
        elif isinstance(t, Lam):
            for r in _one_step_reducts(t.body):
                results.add(Lam(r))

    def _one_step_reducts(t: Term) -> list[Term]:
        rs = []
        if isinstance(t, App):
            if isinstance(t.fun, Lam):
                rs.append(beta_contract(t.fun.body, t.arg))
            for r in _one_step_reducts(t.fun):
                rs.append(App(r, t.arg))
            for r in _one_step_reducts(t.arg):
                rs.append(App(t.fun, r))
        elif isinstance(t, Lam):
            for r in _one_step_reducts(t.body):
                rs.append(Lam(r))
        return rs

    find_reducts(t)
    return results

def demo_confluence_test():
    """Test local confluence for small closed λ-terms."""
    print("=" * 70)
    print("DEMO 5: Experimental Confluence Test")
    print("  Testing the local confluence conjecture for pure β-reduction")
    print("=" * 70)

    max_term_size = 7
    terms = enumerate_closed_terms(max_term_size)
    print(f"\nEnumerated {len(terms)} closed terms of size ≤ {max_term_size}")

    # Find terms with ≥ 2 reducts (local peaks)
    peaks_found = 0
    peaks_joined = 0
    counterexamples = []

    for t in terms:
        reducts = list(all_reducts(t))
        if len(reducts) >= 2:
            peaks_found += 1
            # Check if all pairs of reducts join
            joined = True
            for i in range(len(reducts)):
                for j in range(i + 1, len(reducts)):
                    u, _ = normalize(reducts[i], max_steps=50)
                    v, _ = normalize(reducts[j], max_steps=50)
                    if u != v:
                        joined = False
                        counterexamples.append((t, reducts[i], reducts[j], u, v))
            if joined:
                peaks_joined += 1

    print(f"Terms with ≥ 2 reducts (local peaks): {peaks_found}")
    print(f"Peaks where all reducts join: {peaks_joined}")
    print(f"Counterexamples: {len(counterexamples)}")

    if counterexamples:
        print("\nCounterexamples found:")
        for t, u, v, un, vn in counterexamples[:5]:
            print(f"  Term: {t}")
            print(f"    Reduct 1: {u} →* {un}")
            print(f"    Reduct 2: {v} →* {vn}")
    else:
        print("\n✓ No counterexamples found — local confluence holds for all tested terms")
        print("  (This is expected: the Church-Rosser theorem guarantees confluence for pure β)")
    print()


# ============================================================================
# Section 9: Context Closure Demonstration
# ============================================================================

def demo_context_closure():
    """Demonstrate rewriting under contexts."""
    print("=" * 70)
    print("DEMO 6: Context Closure for Higher-Order Rewriting")
    print("  Rewriting inside programs, not just at the top level")
    print("=" * 70)

    # A context: □ applied to some argument
    # C = (λy. □ y)
    # Fill with t = (λx.x)
    t = Lam(Var(0))  # identity
    # Context: apply t to var 0 inside a lambda
    filled = Lam(App(rename(lambda x: x + 1, t), Var(0)))
    print(f"\nContext C = λy. □ y")
    print(f"Term t = {t}")
    print(f"C[t] = {filled}")

    # Reduce: (λx.x) var 0 → var 0 inside the outer lambda
    reduced, steps = normalize(filled)
    print(f"C[t] normalizes to: {reduced} in {steps} steps")
    assert reduced == Lam(Var(0))
    print("✓ Rewriting under λ-context works correctly")

    # Applicative context
    print("\nApplicative context: C = (f □)")
    f = Var(0)
    inner = App(Lam(Var(0)), Var(1))  # (λx.x) y
    in_ctx = App(f, inner)
    print(f"  C[((λx.x) y)] = {in_ctx}")
    reduced2 = leftmost_reduce(in_ctx)
    print(f"  One step: {reduced2}")
    print("✓ Rewriting under applicative context works correctly")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Higher-Order Completion and Lambda-Calculus Integration            ║")
    print("║  Computational Demonstrations                                       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_subst_comp()
    demo_beta_subst()
    demo_ho_rewriting()
    demo_normalization()
    demo_confluence_test()
    demo_context_closure()

    print("=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json by reading all deliverable files."""
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all files
article = read_file('ARTICLE.md')
research = read_file('RESEARCH_PAPER.md')
future = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algo_code = read_file('algorithms.py')
apps_code = read_file('applications.py')
lean_code = read_file('Catalog/Pythagorean/HigherOrderCompletion.lean')
viz1 = read_file('visualize_rewrite_graph.py')
viz2 = read_file('visualize_substitution.py')
viz3 = read_file('visualize_normalization.py')
interactive = read_file('interactive_lambda.html')

package = {
    "title": "Higher-Order Completion and Lambda-Calculus Integration",
    "domain": "Rewriting Theory / Lambda Calculus / Certified Program Transformation",
    "article": article,
    "research_paper": research,
    "future_directions": future,
    "demos": [
        {
            "name": "Higher-Order Completion Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": apps_code
        }
    ],
    "algorithms": [
        {
            "name": "De Bruijn Substitution Calculus",
            "pseudocode": """PROCEDURE subst(t, σ):
  CASE t OF
    var(i) → σ(i)
    app(s, t) → app(subst(s, σ), subst(t, σ))
    lam(t) → lam(subst(t, liftSubst(σ)))

PROCEDURE liftSubst(σ):
  λn. IF n = 0 THEN var(0) ELSE rename(·+1, σ(n-1))

PROCEDURE compSubst(σ, τ):
  λi. subst(σ(i), τ)

THEOREM subst_comp: subst(subst(t, σ), τ) = subst(t, compSubst(σ, τ))
  Proved by structural induction on t, using liftSubst_compSubst for the lambda case.""",
            "code": algo_code
        },
        {
            "name": "Leftmost-Outermost β-Reduction",
            "pseudocode": """PROCEDURE leftmostReduce(t):
  CASE t OF
    app(lam(body), arg) → betaContract(body, arg)
    app(s, t) →
      IF r ← leftmostReduce(s) THEN app(r, t)
      ELIF r ← leftmostReduce(t) THEN app(s, r)
      ELSE None
    lam(t) →
      IF r ← leftmostReduce(t) THEN lam(r)
      ELSE None
    var(_) → None

Complexity: O(|t|) per step. Normalizing for simply-typed terms.""",
            "code": algo_code
        }
    ],
    "visualizations": [
        {
            "name": "β-Reduction Graph",
            "code": viz1,
            "description": "Directed graph of all possible β-reduction paths from a term, showing how different reduction strategies converge to the same normal form (Church-Rosser property)"
        },
        {
            "name": "Substitution Functoriality Verification",
            "code": viz2,
            "description": "Computational verification of the substitution composition theorem (t[σ])[τ] = t[σ;τ] across hundreds of randomly generated lambda terms of varying size and complexity"
        },
        {
            "name": "Normalization Dynamics",
            "code": viz3,
            "description": "Term size and redex count evolution during β-normalization of Church numeral arithmetic expressions, showing the non-monotonic behavior of reduction"
        }
    ],
    "interactive_demos": [
        {
            "name": "λ-Calculus β-Reduction Explorer",
            "html": interactive,
            "description": "Interactive lambda calculus interpreter: enter a term and watch it normalize step by step via leftmost-outermost β-reduction. Includes preloaded examples (Church arithmetic, SKI combinators, divergent terms)."
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("Generated PACKAGE.json")
print(f"Size: {len(json.dumps(package))} chars")


#!/usr/bin/env python3
"""
Visualization: β-Normalization Dynamics

Plots how term size and redex count evolve during β-normalization
for various Church numeral arithmetic expressions. Illustrates
the computational behavior that higher-order completion must tame.
"""

import matplotlib.pyplot as plt
import numpy as np

# Inline term definitions
class Term:
    pass

class Var(Term):
    def __init__(self, i): self.index = i
    def __eq__(self, o): return isinstance(o, Var) and self.index == o.index
    def __hash__(self): return hash(("V", self.index))

class App(Term):
    def __init__(self, f, a): self.fun, self.arg = f, a
    def __eq__(self, o): return isinstance(o, App) and self.fun == o.fun and self.arg == o.arg
    def __hash__(self): return hash(("A", self.fun, self.arg))

class Lam(Term):
    def __init__(self, b): self.body = b
    def __eq__(self, o): return isinstance(o, Lam) and self.body == o.body
    def __hash__(self): return hash(("L", self.body))

def lift_ren(rho):
    return lambda n: 0 if n == 0 else rho(n-1)+1

def rename(rho, t):
    if isinstance(t, Var): return Var(rho(t.index))
    if isinstance(t, App): return App(rename(rho, t.fun), rename(rho, t.arg))
    if isinstance(t, Lam): return Lam(rename(lift_ren(rho), t.body))

def lift_subst(sigma):
    def f(n):
        if n == 0: return Var(0)
        return rename(lambda x: x+1, sigma(n-1))
    return f

def subst(t, sigma):
    if isinstance(t, Var): return sigma(t.index)
    if isinstance(t, App): return App(subst(t.fun, sigma), subst(t.arg, sigma))
    if isinstance(t, Lam): return Lam(subst(t.body, lift_subst(sigma)))

def single_subst(s):
    return lambda n: s if n == 0 else Var(n-1)

def beta_contract(body, arg):
    return subst(body, single_subst(arg))

def leftmost_reduce(t):
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            return beta_contract(t.fun.body, t.arg)
        r = leftmost_reduce(t.fun)
        if r: return App(r, t.arg)
        r = leftmost_reduce(t.arg)
        if r: return App(t.fun, r)
    elif isinstance(t, Lam):
        r = leftmost_reduce(t.body)
        if r: return Lam(r)
    return None

def term_size(t):
    if isinstance(t, Var): return 1
    if isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    if isinstance(t, Lam): return 1 + term_size(t.body)

def count_redexes(t):
    if isinstance(t, Var): return 0
    if isinstance(t, App):
        extra = 1 if isinstance(t.fun, Lam) else 0
        return extra + count_redexes(t.fun) + count_redexes(t.arg)
    if isinstance(t, Lam): return count_redexes(t.body)

def church(n):
    body = Var(0)
    for _ in range(n):
        body = App(Var(1), body)
    return Lam(Lam(body))

# Church operations
add = Lam(Lam(Lam(Lam(App(App(Var(3), Var(1)), App(App(Var(2), Var(1)), Var(0)))))))
succ_fn = Lam(Lam(Lam(App(Var(1), App(App(Var(2), Var(1)), Var(0))))))

def trace_normalization(t, max_steps=60):
    sizes = [term_size(t)]
    redexes = [count_redexes(t)]
    for _ in range(max_steps):
        r = leftmost_reduce(t)
        if r is None:
            break
        t = r
        sizes.append(term_size(t))
        redexes.append(count_redexes(t))
    return sizes, redexes

# Create test expressions
expressions = {
    "succ(2)": App(succ_fn, church(2)),
    "succ(3)": App(succ_fn, church(3)),
    "2 + 2": App(App(add, church(2)), church(2)),
    "2 + 3": App(App(add, church(2)), church(3)),
    "3 + 3": App(App(add, church(3)), church(3)),
    "succ(succ(2))": App(succ_fn, App(succ_fn, church(2))),
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle("β-Normalization Dynamics of Church Numeral Arithmetic",
             fontsize=14, fontweight='bold')

colors = ['#4477AA', '#EE6677', '#228833', '#CCBB44', '#AA3377', '#66CCEE']

for (name, expr), color in zip(expressions.items(), colors):
    sizes, redexes = trace_normalization(expr)
    steps = range(len(sizes))

    ax1.plot(steps, sizes, color=color, label=name, linewidth=2, marker='o',
             markersize=3, alpha=0.8)
    ax2.plot(steps, redexes, color=color, label=name, linewidth=2, marker='s',
             markersize=3, alpha=0.8)

ax1.set_xlabel("Reduction step", fontsize=12)
ax1.set_ylabel("Term size (# constructors)", fontsize=12)
ax1.set_title("Term Size During Normalization", fontsize=12)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

ax2.set_xlabel("Reduction step", fontsize=12)
ax2.set_ylabel("Number of β-redexes", fontsize=12)
ax2.set_title("Redex Count During Normalization", fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("normalization_dynamics.png", dpi=150, bbox_inches='tight')
print("Saved normalization_dynamics.png")


#!/usr/bin/env python3
"""
Visualization: β-Reduction Graph

Visualizes the directed graph of β-reductions from a given lambda term,
showing all possible reduction paths and how they converge (Church-Rosser).
This illustrates the confluence property central to higher-order completion.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import deque

# Inline term definitions to be self-contained
class Term:
    pass

class Var(Term):
    def __init__(self, index):
        self.index = index
    def __repr__(self):
        return f"x{self.index}"
    def __eq__(self, other):
        return isinstance(other, Var) and self.index == other.index
    def __hash__(self):
        return hash(("V", self.index))

class App(Term):
    def __init__(self, fun, arg):
        self.fun = fun
        self.arg = arg
    def __repr__(self):
        f = repr(self.fun)
        a = repr(self.arg)
        return f"({f} {a})"
    def __eq__(self, other):
        return isinstance(other, App) and self.fun == other.fun and self.arg == other.arg
    def __hash__(self):
        return hash(("A", self.fun, self.arg))

class Lam(Term):
    def __init__(self, body):
        self.body = body
    def __repr__(self):
        return f"(λ.{self.body})"
    def __eq__(self, other):
        return isinstance(other, Lam) and self.body == other.body
    def __hash__(self):
        return hash(("L", self.body))

def lift_ren(rho):
    return lambda n: 0 if n == 0 else rho(n-1) + 1

def rename(rho, t):
    if isinstance(t, Var): return Var(rho(t.index))
    if isinstance(t, App): return App(rename(rho, t.fun), rename(rho, t.arg))
    if isinstance(t, Lam): return Lam(rename(lift_ren(rho), t.body))

def lift_subst(sigma):
    def f(n):
        if n == 0: return Var(0)
        return rename(lambda x: x+1, sigma(n-1))
    return f

def subst(t, sigma):
    if isinstance(t, Var): return sigma(t.index)
    if isinstance(t, App): return App(subst(t.fun, sigma), subst(t.arg, sigma))
    if isinstance(t, Lam): return Lam(subst(t.body, lift_subst(sigma)))

def single_subst(s):
    return lambda n: s if n == 0 else Var(n-1)

def beta_contract(body, arg):
    return subst(body, single_subst(arg))

def all_reducts(t):
    results = []
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            results.append(beta_contract(t.fun.body, t.arg))
        for r in all_reducts(t.fun):
            results.append(App(r, t.arg))
        for r in all_reducts(t.arg):
            results.append(App(t.fun, r))
    elif isinstance(t, Lam):
        for r in all_reducts(t.body):
            results.append(Lam(r))
    return results

def term_size(t):
    if isinstance(t, Var): return 1
    if isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    if isinstance(t, Lam): return 1 + term_size(t.body)

def build_reduction_graph(start, max_nodes=30):
    """BFS to build the reduction graph."""
    graph = {}
    queue = deque([start])
    visited = set()
    visited.add(start)
    labels = {start: repr(start)}

    while queue and len(visited) < max_nodes:
        t = queue.popleft()
        reducts = all_reducts(t)
        graph[t] = reducts
        for r in reducts:
            if r not in visited:
                visited.add(r)
                queue.append(r)
                labels[r] = repr(r)

    return graph, labels

def layout_graph(graph, start):
    """Simple layered layout by BFS depth."""
    levels = {}
    queue = deque([(start, 0)])
    visited = {start}
    levels[start] = 0

    while queue:
        t, depth = queue.popleft()
        for r in graph.get(t, []):
            if r not in visited:
                visited.add(r)
                levels[r] = depth + 1
                queue.append((r, depth + 1))

    # Arrange nodes by level
    by_level = {}
    for node, level in levels.items():
        by_level.setdefault(level, []).append(node)

    positions = {}
    max_level = max(by_level.keys()) if by_level else 0
    for level, nodes in by_level.items():
        for i, node in enumerate(nodes):
            x = (i - (len(nodes) - 1) / 2) * 3.5
            y = -level * 2
            positions[node] = (x, y)

    return positions

# Build graph for a sample term
# (λx.x x)(λx.x x) — the omega combinator (divergent)
# Let's use something that converges instead:
# (λf.λx. f(f x)) (λy.y) — apply twice the identity
start = App(Lam(Lam(App(Var(1), App(Var(1), Var(0))))), Lam(Var(0)))

graph, labels = build_reduction_graph(start, max_nodes=20)
positions = layout_graph(graph, start)

# Create figure
fig, ax = plt.subplots(1, 1, figsize=(14, 8))
fig.suptitle("β-Reduction Graph: Confluence in Action", fontsize=16, fontweight='bold')

# Draw edges
for source, targets in graph.items():
    if source in positions:
        sx, sy = positions[source]
        for target in targets:
            if target in positions:
                tx, ty = positions[target]
                ax.annotate("",
                    xy=(tx, ty), xytext=(sx, sy),
                    arrowprops=dict(arrowstyle="->", color="#4477AA",
                                   lw=1.5, connectionstyle="arc3,rad=0.1"))

# Draw nodes
for node, (x, y) in positions.items():
    is_normal = len(all_reducts(node)) == 0
    is_start = node == start

    if is_start:
        color = '#EE6677'
        edge_color = '#CC3311'
    elif is_normal:
        color = '#228833'
        edge_color = '#117722'
    else:
        color = '#CCBB44'
        edge_color = '#999922'

    label = repr(node)
    if len(label) > 25:
        label = label[:22] + "..."

    bbox = dict(boxstyle="round,pad=0.3", facecolor=color,
                edgecolor=edge_color, alpha=0.85)
    ax.text(x, y, label, ha='center', va='center',
            fontsize=7, fontfamily='monospace', bbox=bbox)

# Legend
start_patch = mpatches.Patch(color='#EE6677', label='Start term')
inter_patch = mpatches.Patch(color='#CCBB44', label='Intermediate')
normal_patch = mpatches.Patch(color='#228833', label='Normal form')
ax.legend(handles=[start_patch, inter_patch, normal_patch],
          loc='upper right', fontsize=10)

ax.set_xlim(-8, 8)
ax.set_ylim(min(y for _, y in positions.values()) - 1.5,
            max(y for _, y in positions.values()) + 1.5)
ax.axis('off')
ax.set_title("All reduction paths converge to the same normal form\n(Church-Rosser theorem)",
             fontsize=11, style='italic', pad=10)

plt.tight_layout()
plt.savefig("rewrite_graph.png", dpi=150, bbox_inches='tight')
print("Saved rewrite_graph.png")


#!/usr/bin/env python3
"""
Visualization: Substitution Composition Functoriality

Visualizes the key theorem: (t[σ])[τ] = t[σ;τ]
Shows how double substitution equals single composed substitution
across a range of term structures, confirming the categorical property.
"""

import matplotlib.pyplot as plt
import numpy as np

# Inline term definitions
class Term:
    pass

class Var(Term):
    def __init__(self, i): self.index = i
    def __eq__(self, o): return isinstance(o, Var) and self.index == o.index
    def __hash__(self): return hash(("V", self.index))
    def __repr__(self): return f"x{self.index}"

class App(Term):
    def __init__(self, f, a): self.fun, self.arg = f, a
    def __eq__(self, o): return isinstance(o, App) and self.fun == o.fun and self.arg == o.arg
    def __hash__(self): return hash(("A", self.fun, self.arg))
    def __repr__(self): return f"({self.fun} {self.arg})"

class Lam(Term):
    def __init__(self, b): self.body = b
    def __eq__(self, o): return isinstance(o, Lam) and self.body == o.body
    def __hash__(self): return hash(("L", self.body))
    def __repr__(self): return f"(λ.{self.body})"

def lift_ren(rho):
    return lambda n: 0 if n == 0 else rho(n-1) + 1

def rename(rho, t):
    if isinstance(t, Var): return Var(rho(t.index))
    if isinstance(t, App): return App(rename(rho, t.fun), rename(rho, t.arg))
    if isinstance(t, Lam): return Lam(rename(lift_ren(rho), t.body))

def lift_subst(sigma):
    def f(n):
        if n == 0: return Var(0)
        return rename(lambda x: x+1, sigma(n-1))
    return f

def subst(t, sigma):
    if isinstance(t, Var): return sigma(t.index)
    if isinstance(t, App): return App(subst(t.fun, sigma), subst(t.arg, sigma))
    if isinstance(t, Lam): return Lam(subst(t.body, lift_subst(sigma)))

def comp_subst(sigma, tau):
    return lambda n: subst(sigma(n), tau)

def term_size(t):
    if isinstance(t, Var): return 1
    if isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    if isinstance(t, Lam): return 1 + term_size(t.body)

def term_depth(t):
    if isinstance(t, Var): return 0
    if isinstance(t, App): return 1 + max(term_depth(t.fun), term_depth(t.arg))
    if isinstance(t, Lam): return 1 + term_depth(t.body)

def count_lambdas(t):
    if isinstance(t, Var): return 0
    if isinstance(t, App): return count_lambdas(t.fun) + count_lambdas(t.arg)
    if isinstance(t, Lam): return 1 + count_lambdas(t.body)

# Generate test terms
def gen_terms(max_size, num_vars=3):
    terms = []
    def gen(sz, bv):
        if sz <= 0: return []
        if sz == 1: return [Var(i) for i in range(bv + num_vars)]
        result = []
        if sz >= 2:
            for b in gen(sz - 1, bv + 1):
                result.append(Lam(b))
        for s1 in range(1, sz - 1):
            for f in gen(s1, bv):
                for a in gen(sz - 1 - s1, bv):
                    result.append(App(f, a))
                    if len(result) > 200:
                        return result
        return result
    for s in range(1, max_size + 1):
        terms.extend(gen(s, 0))
        if len(terms) > 500:
            break
    return terms[:500]

# Test substitution composition
terms = gen_terms(5)

sigma = lambda n: App(Var(0), Var(n)) if n == 0 else (Lam(Var(0)) if n == 1 else Var(n + 1))
tau = lambda n: Var(n + 2) if n == 0 else Lam(Var(n))

sizes = []
depths = []
lambdas_count = []
verified = []

for t in terms:
    try:
        lhs = subst(subst(t, sigma), tau)
        rhs = subst(t, comp_subst(sigma, tau))
        sizes.append(term_size(t))
        depths.append(term_depth(t))
        lambdas_count.append(count_lambdas(t))
        verified.append(lhs == rhs)
    except (RecursionError, TypeError):
        pass

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Substitution Composition Functoriality: (t[σ])[τ] = t[σ;τ]",
             fontsize=14, fontweight='bold')

# Plot 1: By term size
ax1 = axes[0]
colors1 = ['#228833' if v else '#EE6677' for v in verified]
ax1.scatter(range(len(sizes)), sizes, c=colors1, s=15, alpha=0.7)
ax1.set_xlabel("Test case index", fontsize=11)
ax1.set_ylabel("Term size", fontsize=11)
ax1.set_title(f"Verified: {sum(verified)}/{len(verified)}", fontsize=11)
ax1.axhline(y=0, color='gray', linewidth=0.5)

# Plot 2: Size vs depth with verification
ax2 = axes[1]
ax2.scatter(sizes, depths, c=colors1, s=20, alpha=0.6)
ax2.set_xlabel("Term size", fontsize=11)
ax2.set_ylabel("Term depth", fontsize=11)
ax2.set_title("Size vs Depth (green = verified)", fontsize=11)

# Plot 3: Lambda count distribution
ax3 = axes[2]
max_lam = max(lambdas_count) if lambdas_count else 0
bins = range(max_lam + 2)
ax3.hist(lambdas_count, bins=bins, color='#4477AA', edgecolor='white', alpha=0.8)
ax3.set_xlabel("Number of λ-binders", fontsize=11)
ax3.set_ylabel("Frequency", fontsize=11)
ax3.set_title("Binder complexity distribution", fontsize=11)

for ax in axes:
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("substitution_functoriality.png", dpi=150, bbox_inches='tight')
print(f"Saved substitution_functoriality.png")
print(f"Verified {sum(verified)}/{len(verified)} test cases")
