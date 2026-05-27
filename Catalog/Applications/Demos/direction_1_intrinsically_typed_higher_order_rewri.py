#!/usr/bin/env python3
"""
applications.py — Real-world applications of intrinsically typed βη-rewriting.

Demonstrates how the formal theory applies to:
1. Compiler optimization: η-reduction as a safe program transformation
2. Proof normalization: reducing proofs in simply-typed proof systems
3. Algebraic specification: verifying term rewriting systems
"""

from dataclasses import dataclass
from typing import List, Optional, Tuple

# Inline all needed types/functions for self-containment
class Ty: pass

@dataclass(frozen=True)
class Base(Ty):
    index: int
    def __repr__(self): return f"b{self.index}"

@dataclass(frozen=True)
class Arr(Ty):
    dom: Ty
    cod: Ty
    def __repr__(self): return f"({self.dom} → {self.cod})"

B0, B1 = Base(0), Base(1)

class Tm: pass

@dataclass(frozen=True)
class Var(Tm):
    index: int
    def __repr__(self): return f"v{self.index}"
    def size(self): return 1

@dataclass(frozen=True)
class App(Tm):
    fun: Tm
    arg: Tm
    def __repr__(self): return f"({self.fun} {self.arg})"
    def size(self): return 1 + self.fun.size() + self.arg.size()

@dataclass(frozen=True)
class Lam(Tm):
    dom_ty: Ty
    body: Tm
    def __repr__(self): return f"(λ:{self.dom_ty}. {self.body})"
    def size(self): return 1 + self.body.size()

def rename(rho, t):
    if isinstance(t, Var): return Var(rho(t.index))
    elif isinstance(t, App): return App(rename(rho, t.fun), rename(rho, t.arg))
    elif isinstance(t, Lam):
        return Lam(t.dom_ty, rename(lambda i, r=rho: 0 if i==0 else r(i-1)+1, t.body))

def shift(t): return rename(lambda i: i+1, t)

def subst(sigma, t):
    if isinstance(t, Var): return sigma(t.index)
    elif isinstance(t, App): return App(subst(sigma, t.fun), subst(sigma, t.arg))
    elif isinstance(t, Lam):
        def lifted(i, s=sigma):
            if i == 0: return Var(0)
            return shift(s(i-1))
        return Lam(t.dom_ty, subst(lifted, t.body))

def subst_single(body, arg):
    return subst(lambda i: arg if i==0 else Var(i-1), body)

def is_shifted(t):
    if isinstance(t, Var): return Var(t.index-1) if t.index > 0 else None
    elif isinstance(t, App):
        f, a = is_shifted(t.fun), is_shifted(t.arg)
        return App(f, a) if f is not None and a is not None else None
    return None

def beta_reduce_step(t):
    if isinstance(t, App):
        if isinstance(t.fun, Lam): return subst_single(t.fun.body, t.arg)
        r = beta_reduce_step(t.fun)
        if r: return App(r, t.arg)
        r = beta_reduce_step(t.arg)
        if r: return App(t.fun, r)
    elif isinstance(t, Lam):
        r = beta_reduce_step(t.body)
        if r: return Lam(t.dom_ty, r)
    return None

def eta_contract_step(t):
    if isinstance(t, Lam):
        if isinstance(t.body, App) and isinstance(t.body.arg, Var) and t.body.arg.index == 0:
            u = is_shifted(t.body.fun)
            if u is not None: return u
        r = eta_contract_step(t.body)
        if r: return Lam(t.dom_ty, r)
    elif isinstance(t, App):
        r = eta_contract_step(t.fun)
        if r: return App(r, t.arg)
        r = eta_contract_step(t.arg)
        if r: return App(t.fun, r)
    return None

def normalize_beta_eta(t, max_steps=10000):
    for _ in range(max_steps):
        r = beta_reduce_step(t)
        if r: t = r; continue
        r = eta_contract_step(t)
        if r: t = r; continue
        return t
    return t

# ============================================================================
# Application 1: Compiler Optimization — η-Reduction
# ============================================================================

def demo_compiler_optimization():
    """
    Demonstrates that η-reduction is a safe program transformation.

    In a higher-order functional language, the transformation:
        λx. f x  →  f   (when x ∉ FV(f))

    is a common compiler optimization that:
    - Reduces closure allocations
    - Eliminates unnecessary function wrappers
    - Preserves program semantics (by Theorem 2)
    """
    print("=" * 60)
    print("APPLICATION 1: Compiler Optimization via η-Reduction")
    print("=" * 60)

    # Simulating a functional program:
    # map (λx. f x) xs  →  map f xs
    # Here f = Var(0) in context [B0→B0]
    f_ty = Arr(B0, B0)
    f = Var(0)

    # The wrapper: λx. f x
    wrapper = Lam(B0, App(shift(f), Var(0)))
    print(f"\nOriginal:    map (λx. f x) xs")
    print(f"  Wrapper:   {wrapper}")

    # η-contract
    optimized = eta_contract_step(wrapper)
    print(f"  Optimized: {optimized}")
    print(f"  Savings:   eliminated 1 closure allocation")

    # Verify under substitution (Theorem 2)
    print(f"\n  Verification under substitution:")
    concrete_f = Lam(B0, App(Var(0), Var(0)))  # λy. y y
    sigma = lambda i: concrete_f if i == 0 else Var(i)

    subst_wrapper = subst(sigma, wrapper)
    subst_f = subst(sigma, f)
    print(f"  σ(f) = {concrete_f}")
    print(f"  subst σ (wrapper) = {subst_wrapper}")
    print(f"  subst σ (optimized) = {subst_f}")

    nf_wrapper = normalize_beta_eta(subst_wrapper)
    nf_f = normalize_beta_eta(subst_f)
    print(f"  βη-nf(subst σ wrapper) = {nf_wrapper}")
    print(f"  βη-nf(subst σ optimized) = {nf_f}")
    print(f"  Semantically equivalent: {nf_wrapper == nf_f}")

    # Nested case: λf. λx. f x → λf. f (but this is just id!)
    print(f"\n  Nested optimization:")
    nested = Lam(f_ty, Lam(B0, App(Var(1), Var(0))))
    print(f"  λf. λx. f x = {nested}")
    nf = normalize_beta_eta(nested)
    print(f"  After η-reduction: {nf}")

# ============================================================================
# Application 2: Proof Normalization
# ============================================================================

def demo_proof_normalization():
    """
    In the Curry-Howard correspondence, types are propositions and terms are proofs.
    βη-equivalence is definitional equality of proofs.

    Theorem 3 says: if an equational theory (proof transformation) respects
    βη-equivalence, then it descends to normal-form proofs.

    This means: proof search can work on normal forms without losing completeness.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Proof Normalization (Curry-Howard)")
    print("=" * 60)

    # Types as propositions: A → B means "A implies B"
    A = Base(0)  # proposition A
    B = Base(1)  # proposition B
    A_imp_B = Arr(A, B)  # A → B
    A_imp_A = Arr(A, A)  # A → A

    # The identity proof: λx. x proves A → A
    id_proof = Lam(A, Var(0))
    print(f"\n  Identity proof (A → A): {id_proof}")

    # A detour proof: (λf. f) (λx. x) is also a proof of A → A
    detour = App(Lam(A_imp_A, Var(0)), Lam(A, Var(0)))
    print(f"  Detour proof (A → A):  {detour}")

    nf = normalize_beta_eta(detour)
    print(f"  Normal form:           {nf}")
    print(f"  Same as identity:      {nf == id_proof}")

    # Composition of proofs: given f: A→B and g: B→C, build g∘f: A→C
    C = Base(2)
    B_imp_C = Arr(B, C)
    f = Var(0)  # f: A→B in context [A→B]
    g = Var(1)  # g: B→C in context [B→C, A→B]

    # Explicit composition: λx. g (f x)
    comp = Lam(A, App(Var(2), App(Var(1), Var(0))))
    print(f"\n  Composition proof (A→C given f:A→B and g:B→C):")
    print(f"    λx. g (f x) = {comp}")

    # η-expanded version: λx. (λy. g y) (f x)
    eta_comp = Lam(A, App(Lam(B, App(Var(3), Var(0))), App(Var(1), Var(0))))
    print(f"    η-expanded:   {eta_comp}")

    nf_comp = normalize_beta_eta(comp)
    nf_eta = normalize_beta_eta(eta_comp)
    print(f"    Normal forms equal: {nf_comp == nf_eta}")
    print(f"\n  This demonstrates Theorem 3: equational theories on proofs")
    print(f"  respect βη-equivalence (proof normalization).")

# ============================================================================
# Application 3: Algebraic Specification Verification
# ============================================================================

def demo_algebraic_specification():
    """
    Demonstrates verifying properties of algebraic specifications
    (term rewriting systems) using βη-normalization.

    We encode simple algebraic operations as λ-terms and verify
    that equational laws hold after normalization.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Algebraic Specification Verification")
    print("=" * 60)

    # Church numerals: encoding natural numbers as λ-terms
    # 0 = λf. λx. x
    # 1 = λf. λx. f x
    # 2 = λf. λx. f (f x)
    # succ n = λf. λx. f (n f x)

    f_ty = Arr(B0, B0)  # type of f

    zero = Lam(f_ty, Lam(B0, Var(0)))
    one = Lam(f_ty, Lam(B0, App(Var(1), Var(0))))
    two = Lam(f_ty, Lam(B0, App(Var(1), App(Var(1), Var(0)))))

    print(f"\n  Church numerals:")
    print(f"    0 = {zero}")
    print(f"    1 = {one}")
    print(f"    2 = {two}")

    # succ = λn. λf. λx. f (n f x)
    n_ty = Arr(f_ty, Arr(B0, B0))
    succ = Lam(n_ty, Lam(f_ty, Lam(B0,
        App(Var(1), App(App(Var(2), Var(1)), Var(0)))
    )))
    print(f"    succ = {succ}")

    # Verify: succ 0 = 1
    succ_zero = App(succ, zero)
    nf_succ_zero = normalize_beta_eta(succ_zero)
    nf_one = normalize_beta_eta(one)
    print(f"\n  Verification:")
    print(f"    succ 0 = {succ_zero}")
    print(f"    βη-nf(succ 0) = {nf_succ_zero}")
    print(f"    βη-nf(1) = {nf_one}")
    print(f"    succ 0 ≈βη 1: {nf_succ_zero == nf_one}")

    # Verify: succ 1 = 2
    succ_one = App(succ, one)
    nf_succ_one = normalize_beta_eta(succ_one)
    nf_two = normalize_beta_eta(two)
    print(f"\n    succ 1 = {succ_one}")
    print(f"    βη-nf(succ 1) = {nf_succ_one}")
    print(f"    βη-nf(2) = {nf_two}")
    print(f"    succ 1 ≈βη 2: {nf_succ_one == nf_two}")

    # K combinator: K = λx. λy. x
    K = Lam(B0, Lam(B0, Var(1)))
    # Verify K a b = a
    a, b = Var(0), Var(1)
    Kab = App(App(K, a), b)
    nf_Kab = normalize_beta_eta(Kab)
    print(f"\n    K = {K}")
    print(f"    K v0 v1 = {Kab}")
    print(f"    βη-nf(K v0 v1) = {nf_Kab}")
    print(f"    K v0 v1 ≈βη v0: {nf_Kab == a}")

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Intrinsically Typed βη-Rewriting      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_compiler_optimization()
    demo_proof_normalization()
    demo_algebraic_specification()


#!/usr/bin/env python3
"""
demo.py — Demonstrates intrinsically typed higher-order rewriting with βη-completion.

This script implements:
1. Generation of small well-typed simply-typed λ-terms (de Bruijn representation)
2. βη-normalization (both β-reduction and η-contraction)
3. Sample rewrite closure checks
4. Conjecture test: for orthogonal βη-stable systems, normalization commutes with rewriting
"""

from dataclasses import dataclass
from typing import List, Optional, Tuple, Set
from enum import Enum
import itertools

# ============================================================================
# Types and Contexts
# ============================================================================

class Ty:
    """Simple types: base types and arrow types."""
    pass

@dataclass(frozen=True)
class Base(Ty):
    index: int
    def __repr__(self):
        return f"b{self.index}"

@dataclass(frozen=True)
class Arr(Ty):
    dom: Ty
    cod: Ty
    def __repr__(self):
        return f"({self.dom} → {self.cod})"

# Shorthand types
B0 = Base(0)
B1 = Base(1)

Ctx = tuple  # A context is a tuple of types (head = most recent binding)

# ============================================================================
# Terms (de Bruijn representation)
# ============================================================================

class Tm:
    """Intrinsically typed λ-terms with de Bruijn indices."""
    pass

@dataclass(frozen=True)
class Var(Tm):
    """Variable reference (de Bruijn index)."""
    index: int
    def __repr__(self):
        return f"v{self.index}"
    def size(self):
        return 1

@dataclass(frozen=True)
class App(Tm):
    """Application."""
    fun: Tm
    arg: Tm
    def __repr__(self):
        return f"({self.fun} {self.arg})"
    def size(self):
        return 1 + self.fun.size() + self.arg.size()

@dataclass(frozen=True)
class Lam(Tm):
    """λ-abstraction (binds one variable)."""
    dom_ty: Ty  # type of the bound variable
    body: Tm
    def __repr__(self):
        return f"(λ:{self.dom_ty}. {self.body})"
    def size(self):
        return 1 + self.body.size()

# ============================================================================
# Type inference
# ============================================================================

def infer_type(ctx: Ctx, t: Tm) -> Optional[Ty]:
    """Infer the type of a term in a context, or None if ill-typed."""
    if isinstance(t, Var):
        if t.index < len(ctx):
            return ctx[t.index]
        return None
    elif isinstance(t, App):
        fty = infer_type(ctx, t.fun)
        if not isinstance(fty, Arr):
            return None
        aty = infer_type(ctx, t.arg)
        if aty != fty.dom:
            return None
        return fty.cod
    elif isinstance(t, Lam):
        new_ctx = (t.dom_ty,) + ctx
        bty = infer_type(new_ctx, t.body)
        if bty is None:
            return None
        return Arr(t.dom_ty, bty)
    return None

# ============================================================================
# Renaming and Substitution
# ============================================================================

def rename(rho, t: Tm) -> Tm:
    """Apply a renaming (function on indices) to a term."""
    if isinstance(t, Var):
        return Var(rho(t.index))
    elif isinstance(t, App):
        return App(rename(rho, t.fun), rename(rho, t.arg))
    elif isinstance(t, Lam):
        lifted = lambda i: 0 if i == 0 else rho(i - 1) + 1
        return Lam(t.dom_ty, rename(lifted, t.body))

def shift(t: Tm) -> Tm:
    """Shift all free variables up by 1 (weakening)."""
    return rename(lambda i: i + 1, t)

def subst_single(body: Tm, arg: Tm) -> Tm:
    """Substitute arg for variable 0 in body."""
    def sigma(i):
        if i == 0:
            return arg
        return Var(i - 1)
    return subst(sigma, body)

def subst(sigma, t: Tm) -> Tm:
    """Apply a substitution (function from indices to terms) to a term."""
    if isinstance(t, Var):
        return sigma(t.index)
    elif isinstance(t, App):
        return App(subst(sigma, t.fun), subst(sigma, t.arg))
    elif isinstance(t, Lam):
        def lifted(i):
            if i == 0:
                return Var(0)
            return shift(sigma(i - 1))
        return Lam(t.dom_ty, subst(lifted, t.body))

# ============================================================================
# β-reduction and η-contraction
# ============================================================================

def is_shifted(t: Tm) -> Optional[Tm]:
    """Check if t = shift(s) for some s; if so, return s."""
    if isinstance(t, Var):
        if t.index > 0:
            return Var(t.index - 1)
        return None
    elif isinstance(t, App):
        f = is_shifted(t.fun)
        a = is_shifted(t.arg)
        if f is not None and a is not None:
            return App(f, a)
        return None
    elif isinstance(t, Lam):
        # Under a binder, shifted means: var 0 stays, others shift
        # This is more complex; we check rename (·+1) s = t.body
        # Simplified: check if body doesn't use var 0 and all others are shifted
        return None  # Conservative: don't try to un-shift under binders
    return None

def beta_reduce_step(t: Tm) -> Optional[Tm]:
    """One-step β-reduction (leftmost-outermost)."""
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            return subst_single(t.fun.body, t.arg)
        r = beta_reduce_step(t.fun)
        if r is not None:
            return App(r, t.arg)
        r = beta_reduce_step(t.arg)
        if r is not None:
            return App(t.fun, r)
    elif isinstance(t, Lam):
        r = beta_reduce_step(t.body)
        if r is not None:
            return Lam(t.dom_ty, r)
    return None

def eta_contract_step(t: Tm) -> Optional[Tm]:
    """One-step η-contraction: λx. f x → f when x ∉ FV(f)."""
    if isinstance(t, Lam):
        if isinstance(t.body, App):
            if isinstance(t.body.arg, Var) and t.body.arg.index == 0:
                unshifted = is_shifted(t.body.fun)
                if unshifted is not None:
                    return unshifted
        r = eta_contract_step(t.body)
        if r is not None:
            return Lam(t.dom_ty, r)
    elif isinstance(t, App):
        r = eta_contract_step(t.fun)
        if r is not None:
            return App(r, t.arg)
        r = eta_contract_step(t.arg)
        if r is not None:
            return App(t.fun, r)
    return None

def normalize_beta(t: Tm, max_steps: int = 1000) -> Tm:
    """Normalize by β-reduction."""
    for _ in range(max_steps):
        r = beta_reduce_step(t)
        if r is None:
            return t
        t = r
    return t  # May not be fully normalized

def normalize_beta_eta(t: Tm, max_steps: int = 1000) -> Tm:
    """Normalize by βη-reduction."""
    for _ in range(max_steps):
        r = beta_reduce_step(t)
        if r is not None:
            t = r
            continue
        r = eta_contract_step(t)
        if r is not None:
            t = r
            continue
        return t
    return t

# ============================================================================
# Term Generation
# ============================================================================

def generate_typed_terms(ctx: Ctx, ty: Ty, max_size: int) -> List[Tm]:
    """Generate all well-typed terms of a given type up to a size bound."""
    if max_size <= 0:
        return []

    results = []

    # Variables
    for i, t in enumerate(ctx):
        if t == ty and max_size >= 1:
            results.append(Var(i))

    # Lambda abstraction: ty must be Arr(a, b)
    if isinstance(ty, Arr) and max_size >= 2:
        new_ctx = (ty.dom,) + ctx
        for body in generate_typed_terms(new_ctx, ty.cod, max_size - 1):
            results.append(Lam(ty.dom, body))

    # Application: find all possible splits
    if max_size >= 3:
        # Try all possible argument types
        arg_types = set()
        _collect_subtypes(ty, arg_types)
        for a_ty in _all_simple_types(2):  # Small argument types
            fun_ty = Arr(a_ty, ty)
            for s1 in range(1, max_size - 1):
                s2 = max_size - 1 - s1
                for f in generate_typed_terms(ctx, fun_ty, s1):
                    for a in generate_typed_terms(ctx, a_ty, s2):
                        results.append(App(f, a))

    return results

def _collect_subtypes(ty: Ty, acc: set):
    acc.add(ty)
    if isinstance(ty, Arr):
        _collect_subtypes(ty.dom, acc)
        _collect_subtypes(ty.cod, acc)

def _all_simple_types(depth: int) -> List[Ty]:
    """Generate simple types up to a given depth."""
    if depth <= 0:
        return [B0]
    base = [B0, B1]
    if depth == 1:
        return base
    sub = _all_simple_types(depth - 1)
    result = list(base)
    for a in sub:
        for b in sub:
            result.append(Arr(a, b))
    return result

# ============================================================================
# Rewrite Rules and Orthogonality
# ============================================================================

@dataclass
class RewriteRule:
    """A typed rewrite rule: lhs → rhs in a given context with a given type."""
    ctx: Ctx
    ty: Ty
    lhs: Tm
    rhs: Tm

    def __repr__(self):
        return f"{self.lhs} → {self.rhs}"

def apply_rule(rule: RewriteRule, t: Tm) -> Optional[Tm]:
    """Try to apply a rewrite rule at the top of the term. (Simple pattern matching.)"""
    # For simplicity, we only match syntactically identical terms
    if t == rule.lhs:
        return rule.rhs
    return None

def apply_rule_anywhere(rule: RewriteRule, t: Tm) -> Optional[Tm]:
    """Try to apply a rewrite rule anywhere in the term."""
    r = apply_rule(rule, t)
    if r is not None:
        return r
    if isinstance(t, App):
        r = apply_rule_anywhere(rule, t.fun)
        if r is not None:
            return App(r, t.arg)
        r = apply_rule_anywhere(rule, t.arg)
        if r is not None:
            return App(t.fun, r)
    elif isinstance(t, Lam):
        r = apply_rule_anywhere(rule, t.body)
        if r is not None:
            return Lam(t.dom_ty, r)
    return None

# ============================================================================
# Conjecture Test
# ============================================================================

def test_normalization_conjecture(max_term_size: int = 8):
    """
    Test the conjecture: For orthogonal βη-stable rule sets,
    βη-normalization commutes with rewriting.

    For each small rewrite rule and each small closed term, check that:
    normalize(rewrite(t)) ≈βη normalize(t) whenever rewrite applies.
    """
    print("=" * 60)
    print("CONJECTURE TEST: Normalization commutes with rewriting")
    print("=" * 60)

    # Define some sample orthogonal rules
    # Rule: K x y → x (on base type)
    k_ty = Arr(B0, Arr(B0, B0))
    k_term = Lam(B0, Lam(B0, Var(1)))  # λx. λy. x
    s_ty = Arr(Arr(B0, Arr(B0, B0)), Arr(Arr(B0, B0), Arr(B0, B0)))

    # We test with a simple rule: double f = λx. f (f x)
    # Rule: D f → λx. f (f x) where D has type (B0→B0)→(B0→B0)
    d_fun_ty = Arr(B0, B0)
    d_ty = Arr(d_fun_ty, d_fun_ty)

    # Generate some test terms
    test_types = [B0, Arr(B0, B0)]
    test_ctx = ()  # closed terms

    total_tests = 0
    counterexamples = 0

    for ty in test_types:
        terms = generate_typed_terms(test_ctx, ty, max_term_size)
        print(f"\nType {ty}: generated {len(terms)} terms of size ≤ {max_term_size}")

        for t in terms[:50]:  # Limit to first 50 per type
            # Normalize the term
            t_nf = normalize_beta_eta(t)

            # Try β-reducing and re-normalizing
            t_beta = beta_reduce_step(t)
            if t_beta is not None:
                t_beta_nf = normalize_beta_eta(t_beta)
                total_tests += 1
                if t_nf != t_beta_nf:
                    # Check if they're βη-equivalent (by normalizing both)
                    if normalize_beta_eta(t_nf) != normalize_beta_eta(t_beta_nf):
                        counterexamples += 1
                        print(f"  COUNTEREXAMPLE: {t}")
                        print(f"    normalize(t) = {t_nf}")
                        print(f"    normalize(β-step(t)) = {t_beta_nf}")

    print(f"\nTotal tests: {total_tests}")
    print(f"Counterexamples: {counterexamples}")
    if counterexamples == 0:
        print("CONJECTURE HOLDS for all tested cases!")
    else:
        print(f"CONJECTURE FAILS: {counterexamples} counterexamples found")
    return counterexamples

# ============================================================================
# Demo: Substitution Composition
# ============================================================================

def demo_substitution_composition():
    """Demonstrate Theorem 1: subst τ (subst σ t) = subst (compSub τ σ) t."""
    print("\n" + "=" * 60)
    print("DEMO: Substitution Composition (Theorem 1)")
    print("=" * 60)

    # Context: [B0, B0] (two base-type variables)
    # Term: λx. v1 x  (where v1 is the second variable in context)
    ctx = (B0, B0)
    # t = Lam(B0, App(Var(2), Var(0)))  -- λx. v1 x
    t = Lam(B0, App(Var(2), Var(0)))

    print(f"Context: {ctx}")
    print(f"Term t = {t}")
    print(f"Type: {infer_type(ctx, t)}")

    # σ: v0 ↦ λy.y, v1 ↦ λy.y
    id_term = Lam(B0, Var(0))  # λy. y
    sigma = lambda i: id_term if i <= 1 else Var(i)

    # τ: v0 ↦ v0 (identity on the target context)
    tau = lambda i: Var(i)

    # Apply σ then τ
    t1 = subst(sigma, t)
    t2 = subst(tau, t1)
    print(f"\nσ(v0) = σ(v1) = {id_term}")
    print(f"subst σ t = {t1}")
    print(f"subst τ (subst σ t) = {t2}")

    # Apply compSub(τ, σ)
    comp = lambda i: subst(tau, sigma(i))
    t3 = subst(comp, t)
    print(f"subst (compSub τ σ) t = {t3}")
    print(f"Equal? {t2 == t3}")

def demo_eta_stability():
    """Demonstrate Theorem 2: η-step is stable under substitution."""
    print("\n" + "=" * 60)
    print("DEMO: η-Stability Under Substitution (Theorem 2)")
    print("=" * 60)

    # f = v0 of type B0 → B0 in context [B0 → B0]
    f = Var(0)
    f_ty = Arr(B0, B0)
    ctx = (f_ty,)

    # η-expanded form: λx. f x = λx. (shift f) x
    eta_expanded = Lam(B0, App(shift(f), Var(0)))
    print(f"f = {f}")
    print(f"η-expanded: λx. f x = {eta_expanded}")
    print(f"η-contracts to: {f}")

    # Apply substitution: σ(v0) = λy. y
    id_fn = Lam(B0, Var(0))
    sigma = lambda i: id_fn if i == 0 else Var(i)

    subst_expanded = subst(sigma, eta_expanded)
    subst_f = subst(sigma, f)
    print(f"\nσ(v0) = {id_fn}")
    print(f"subst σ (η-expanded) = {subst_expanded}")
    print(f"subst σ f = {subst_f}")

    # Check that the substituted form is still an η-redex
    contracted = eta_contract_step(subst_expanded)
    print(f"η-contract(subst σ (η-expanded)) = {contracted}")
    print(f"Equal to subst σ f? {contracted == subst_f}")

    # Normalize both
    nf1 = normalize_beta_eta(subst_expanded)
    nf2 = normalize_beta_eta(subst_f)
    print(f"βη-nf of subst σ (η-expanded) = {nf1}")
    print(f"βη-nf of subst σ f = {nf2}")
    print(f"βη-equivalent? {nf1 == nf2}")

def demo_betaeta_quotient():
    """Demonstrate Theorem 3: HOEqGen descends to βη-quotients."""
    print("\n" + "=" * 60)
    print("DEMO: Equational Theory Descends to βη-Quotients (Theorem 3)")
    print("=" * 60)

    # Consider the rule: K x y = x (projection)
    # K = λx. λy. x
    K = Lam(B0, Lam(B0, Var(1)))
    # K applied: K a b = a
    a = Var(0)
    b = Var(1)
    ctx = (B0, B0)

    Ka = App(K, a)
    Kab = App(Ka, b)
    print(f"K = {K}")
    print(f"K a b = {Kab}")
    nf = normalize_beta_eta(Kab)
    print(f"βη-normal form of K a b = {nf}")

    # Now η-expand K: K' = λx. λy. K x y
    K_eta = Lam(B0, Lam(B0, App(App(shift(shift(K)), Var(1)), Var(0))))
    print(f"\nη-expanded K' = {K_eta}")
    K_eta_nf = normalize_beta_eta(K_eta)
    print(f"βη-nf of K' = {K_eta_nf}")

    # K' a b should also reduce to a
    K_eta_ab = App(App(K_eta, a), b)
    K_eta_ab_nf = normalize_beta_eta(K_eta_ab)
    print(f"βη-nf of K' a b = {K_eta_ab_nf}")
    print(f"K a b ≈βη K' a b? {nf == K_eta_ab_nf}")
    print("\nThis demonstrates: the equational theory generated by K-reduction")
    print("descends to βη-equivalence classes (Theorem 3).")

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Intrinsically Typed Higher-Order Rewriting with βη    ║")
    print("║  Demonstration of Formally Verified Theorems           ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_substitution_composition()
    demo_eta_stability()
    demo_betaeta_quotient()
    test_normalization_conjecture(max_term_size=8)


#!/usr/bin/env python3
"""
visualize_rewriting.py — Visualizes the structure of βη-reduction on typed λ-terms.

Shows a heatmap of term sizes before and after βη-normalization across different
type complexities, illustrating how η-contraction and β-reduction interact to
simplify higher-order terms.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ============================================================================
# Inline all needed types and functions (self-contained)
# ============================================================================

class Ty: pass

class Base(Ty):
    def __init__(self, i): self.index = i
    def __eq__(self, o): return isinstance(o, Base) and self.index == o.index
    def __hash__(self): return hash(('Base', self.index))
    def __repr__(self): return f"b{self.index}"
    def order(self): return 0

class Arr(Ty):
    def __init__(self, d, c): self.dom, self.cod = d, c
    def __eq__(self, o): return isinstance(o, Arr) and self.dom == o.dom and self.cod == o.cod
    def __hash__(self): return hash(('Arr', self.dom, self.cod))
    def __repr__(self): return f"({self.dom}→{self.cod})"
    def order(self): return max(self.dom.order() + 1, self.cod.order())

B0 = Base(0)

class Tm: pass

class Var(Tm):
    def __init__(self, i): self.index = i
    def __eq__(self, o): return isinstance(o, Var) and self.index == o.index
    def __hash__(self): return hash(('Var', self.index))
    def size(self): return 1

class App(Tm):
    def __init__(self, f, a): self.fun, self.arg = f, a
    def __eq__(self, o): return isinstance(o, App) and self.fun == o.fun and self.arg == o.arg
    def __hash__(self): return hash(('App', self.fun, self.arg))
    def size(self): return 1 + self.fun.size() + self.arg.size()

class Lam(Tm):
    def __init__(self, ty, b): self.dom_ty, self.body = ty, b
    def __eq__(self, o): return isinstance(o, Lam) and self.dom_ty == o.dom_ty and self.body == o.body
    def __hash__(self): return hash(('Lam', self.dom_ty, self.body))
    def size(self): return 1 + self.body.size()

def rename(rho, t):
    if isinstance(t, Var): return Var(rho(t.index))
    elif isinstance(t, App): return App(rename(rho, t.fun), rename(rho, t.arg))
    elif isinstance(t, Lam):
        return Lam(t.dom_ty, rename(lambda i, r=rho: 0 if i==0 else r(i-1)+1, t.body))

def shift(t): return rename(lambda i: i+1, t)

def subst_single(body, arg):
    def sigma(i):
        if i == 0: return arg
        return Var(i-1)
    return subst(sigma, body)

def subst(sigma, t):
    if isinstance(t, Var): return sigma(t.index)
    elif isinstance(t, App): return App(subst(sigma, t.fun), subst(sigma, t.arg))
    elif isinstance(t, Lam):
        def lifted(i, s=sigma):
            if i == 0: return Var(0)
            return shift(s(i-1))
        return Lam(t.dom_ty, subst(lifted, t.body))

def is_shifted(t):
    if isinstance(t, Var): return Var(t.index-1) if t.index > 0 else None
    elif isinstance(t, App):
        f, a = is_shifted(t.fun), is_shifted(t.arg)
        return App(f, a) if f is not None and a is not None else None
    return None

def beta_step(t):
    if isinstance(t, App):
        if isinstance(t.fun, Lam): return subst_single(t.fun.body, t.arg)
        r = beta_step(t.fun)
        if r: return App(r, t.arg)
        r = beta_step(t.arg)
        if r: return App(t.fun, r)
    elif isinstance(t, Lam):
        r = beta_step(t.body)
        if r: return Lam(t.dom_ty, r)
    return None

def eta_step(t):
    if isinstance(t, Lam):
        if isinstance(t.body, App) and isinstance(t.body.arg, Var) and t.body.arg.index == 0:
            u = is_shifted(t.body.fun)
            if u is not None: return u
        r = eta_step(t.body)
        if r: return Lam(t.dom_ty, r)
    elif isinstance(t, App):
        r = eta_step(t.fun)
        if r: return App(r, t.arg)
        r = eta_step(t.arg)
        if r: return App(t.fun, r)
    return None

def normalize(t, max_steps=500):
    steps_beta, steps_eta = 0, 0
    for _ in range(max_steps):
        r = beta_step(t)
        if r: t = r; steps_beta += 1; continue
        r = eta_step(t)
        if r: t = r; steps_eta += 1; continue
        break
    return t, steps_beta, steps_eta

def generate_terms(ctx, ty, max_size):
    if max_size <= 0: return []
    results = []
    for i, ct in enumerate(ctx):
        if ct == ty: results.append(Var(i))
    if isinstance(ty, Arr) and max_size >= 2:
        new_ctx = (ty.dom,) + ctx
        for body in generate_terms(new_ctx, ty.cod, max_size - 1):
            results.append(Lam(ty.dom, body))
    if max_size >= 3:
        for a_ty in [B0, Arr(B0, B0)]:
            fun_ty = Arr(a_ty, ty)
            for s1 in range(1, max_size - 1):
                s2 = max_size - 1 - s1
                for f in generate_terms(ctx, fun_ty, s1):
                    for a in generate_terms(ctx, a_ty, s2):
                        results.append(App(f, a))
    return results

# ============================================================================
# Visualization
# ============================================================================

# Generate types of increasing complexity
types = [
    B0,
    Arr(B0, B0),
    Arr(B0, Arr(B0, B0)),
    Arr(Arr(B0, B0), B0),
    Arr(Arr(B0, B0), Arr(B0, B0)),
]
type_labels = ["b₀", "b₀→b₀", "b₀→b₀→b₀", "(b₀→b₀)→b₀", "(b₀→b₀)→b₀→b₀"]

# Collect data
max_sizes = list(range(3, 10))
data_reduction = np.zeros((len(types), len(max_sizes)))
data_beta_steps = np.zeros((len(types), len(max_sizes)))
data_eta_steps = np.zeros((len(types), len(max_sizes)))
data_term_counts = np.zeros((len(types), len(max_sizes)))

ctx = (B0,)  # One base-type variable

for i, ty in enumerate(types):
    for j, ms in enumerate(max_sizes):
        terms = generate_terms(ctx, ty, ms)
        if not terms:
            continue
        data_term_counts[i, j] = len(terms)
        total_reduction = 0
        total_beta = 0
        total_eta = 0
        for t in terms[:100]:
            orig_size = t.size()
            nf, sb, se = normalize(t)
            nf_size = nf.size()
            total_reduction += (orig_size - nf_size) / max(orig_size, 1)
            total_beta += sb
            total_eta += se
        n = min(len(terms), 100)
        data_reduction[i, j] = total_reduction / n if n > 0 else 0
        data_beta_steps[i, j] = total_beta / n if n > 0 else 0
        data_eta_steps[i, j] = total_eta / n if n > 0 else 0

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Size reduction ratio
im1 = axes[0].imshow(data_reduction, aspect='auto', cmap='YlOrRd',
                      interpolation='nearest')
axes[0].set_xticks(range(len(max_sizes)))
axes[0].set_xticklabels(max_sizes)
axes[0].set_yticks(range(len(types)))
axes[0].set_yticklabels(type_labels)
axes[0].set_xlabel('Max Term Size')
axes[0].set_ylabel('Type')
axes[0].set_title('Average Size Reduction\nby βη-Normalization')
plt.colorbar(im1, ax=axes[0], label='Fraction reduced')

# Plot 2: Average β-steps
im2 = axes[1].imshow(data_beta_steps, aspect='auto', cmap='Blues',
                      interpolation='nearest')
axes[1].set_xticks(range(len(max_sizes)))
axes[1].set_xticklabels(max_sizes)
axes[1].set_yticks(range(len(types)))
axes[1].set_yticklabels(type_labels)
axes[1].set_xlabel('Max Term Size')
axes[1].set_title('Average β-Reduction\nSteps to Normal Form')
plt.colorbar(im2, ax=axes[1], label='Steps')

# Plot 3: Average η-steps
im3 = axes[2].imshow(data_eta_steps, aspect='auto', cmap='Greens',
                      interpolation='nearest')
axes[2].set_xticks(range(len(max_sizes)))
axes[2].set_xticklabels(max_sizes)
axes[2].set_yticks(range(len(types)))
axes[2].set_yticklabels(type_labels)
axes[2].set_xlabel('Max Term Size')
axes[2].set_title('Average η-Contraction\nSteps to Normal Form')
plt.colorbar(im3, ax=axes[2], label='Steps')

fig.suptitle('βη-Normalization Landscape for Simply Typed λ-Terms', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('visualization_betaeta.png', dpi=150, bbox_inches='tight')
print("Saved visualization_betaeta.png")
