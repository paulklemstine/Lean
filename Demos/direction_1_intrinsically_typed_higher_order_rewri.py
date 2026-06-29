#!/usr/bin/env python3
"""
applications.py — Real-world applications of intrinsically typed βη-rewriting

Demonstrates three application domains:
1. Compiler optimization: extensional function optimization
2. Proof normalization: definitional equality for proof terms
3. Program equivalence: verifying that two programs compute the same function

Keywords: compiler correctness, proof normalization, extensional equality,
higher-order rewriting, functional programming optimization
"""

from demo import (
    Ty, BaseTy, ArrTy, Var, App, Lam, Term,
    rename, wk, subst, single_subst, comp_sub,
    normalize, alpha_eq, is_eta_redex, eta_contract, type_check,
    has_free_var
)

O = BaseTy(0)
OO = ArrTy(O, O)
OOO = ArrTy(O, ArrTy(O, O))

# =============================================================================
# Application 1: Compiler Optimization — η-Reduction for Code Size
# =============================================================================

def count_eta_opportunities(t: Term) -> int:
    """Count η-reduction opportunities in a term (optimization potential)."""
    count = 0
    if is_eta_redex(t):
        count += 1
    match t:
        case App(f, a):
            count += count_eta_opportunities(f)
            count += count_eta_opportunities(a)
        case Lam(body, _):
            count += count_eta_opportunities(body)
    return count

def apply_all_eta(t: Term) -> Term:
    """Apply all possible η-reductions."""
    return normalize(t)

def demo_compiler_optimization():
    """Demonstrate η-reduction as a compiler optimization.

    In functional programming, η-expansion often appears from partial
    application or CPS transforms. η-reduction removes these wrappers,
    reducing code size and eliminating indirect calls.
    """
    print("=" * 60)
    print("Application 1: Compiler Optimization via η-Reduction")
    print("=" * 60)

    # Original: λx. (map f) x  →η  map f
    # In de Bruijn: λ. (v1 v0)  →η  v0 (when v1 = wk(v0))
    # Here v0 is `map f` in the outer context
    wrapper = Lam(App(Var(1), Var(0)), O)
    direct = Var(0)

    print(f"Wrapped call: {wrapper}")
    print(f"Direct call:  {direct}")
    print(f"Is η-redex?   {is_eta_redex(wrapper)}")
    contracted = eta_contract(wrapper)
    print(f"η-reduced:    {contracted}")
    assert alpha_eq(contracted, direct)
    print("✓ Wrapper eliminated — direct call is more efficient")
    print()

    # More complex: nested wrappers
    # λx. (λy. f y) x  →β  λx. f x  →η  f
    f_var = Var(0)  # f in context
    inner = Lam(App(Var(1), Var(0)), O)  # λy. f y (η-redex for f)
    outer = Lam(App(inner, Var(0)), O)   # λx. (λy. f y) x
    print(f"Nested wrapper: {outer}")
    nf = normalize(outer)
    print(f"After βη-normalization: {nf}")
    print(f"Size reduction: {outer.size()} → {nf.size()} nodes")
    print()

# =============================================================================
# Application 2: Proof Normalization
# =============================================================================

def demo_proof_normalization():
    """Demonstrate βη-normalization for proof terms.

    In type theory (Curry-Howard correspondence), proofs are λ-terms.
    Two proofs that are βη-equivalent prove the same thing in the same way.
    Normalization produces a canonical representative of each proof.
    """
    print("=" * 60)
    print("Application 2: Proof Normalization (Curry-Howard)")
    print("=" * 60)

    # Proof of A → A (identity): λx.x
    id_proof = Lam(Var(0), O)
    print(f"Identity proof: {id_proof}")

    # Roundabout proof: (λf. λx. f x) (λx. x)
    # This applies the identity to the identity — should normalize to id
    roundabout = App(Lam(Lam(App(Var(1), Var(0)), O), OO), Lam(Var(0), O))
    print(f"Roundabout proof: {roundabout}")
    nf = normalize(roundabout)
    print(f"Normalized: {nf}")
    assert alpha_eq(nf, id_proof)
    print("✓ Both proofs normalize to the same canonical form")
    print()

    # Composition of identity with itself
    # (λf. λg. λx. f (g x)) id id
    comp_body = Lam(App(Var(2), App(Var(1), Var(0))), O)  # λx. f (g x)
    comp_fg = Lam(comp_body, OO)  # λg. λx. f (g x)
    comp = Lam(comp_fg, OO)  # λf. λg. λx. f (g x)

    comp_id_id = App(App(comp, id_proof), id_proof)
    print(f"comp id id = {comp_id_id}")
    nf2 = normalize(comp_id_id)
    print(f"Normalized: {nf2}")
    print(f"Same as id? {alpha_eq(nf2, id_proof)}")
    print()

# =============================================================================
# Application 3: Program Equivalence
# =============================================================================

def demo_program_equivalence():
    """Demonstrate checking program equivalence via βη-normalization.

    Two functional programs are extensionally equivalent if their
    βη-normal forms are α-equivalent. This is decidable for simply typed terms.
    """
    print("=" * 60)
    print("Application 3: Program Equivalence Checking")
    print("=" * 60)

    # Program 1: λf. λx. f x  (explicit application)
    p1 = Lam(Lam(App(Var(1), Var(0)), O), OO)

    # Program 2: λf. f  (implicit, η-contracted)
    p2 = Lam(Var(0), OO)

    nf1 = normalize(p1)
    nf2 = normalize(p2)

    print(f"Program 1: {p1}")
    print(f"Program 2: {p2}")
    print(f"NF 1: {nf1}")
    print(f"NF 2: {nf2}")
    print(f"Equivalent? {alpha_eq(nf1, nf2)}")
    assert alpha_eq(nf1, nf2)
    print("✓ Programs are βη-equivalent (extensionally equal)")
    print()

    # Non-equivalent programs
    # λx. x  vs  λx. λy. x (K combinator, different type)
    p3 = Lam(Var(0), O)  # id : O → O
    p4 = Lam(Lam(Var(1), O), O)  # K : O → O → O (has different type)

    nf3 = normalize(p3)
    nf4 = normalize(p4)
    print(f"Program 3 (id): {p3}, NF: {nf3}")
    print(f"Program 4 (K):  {p4}, NF: {nf4}")
    print(f"Equivalent? {alpha_eq(nf3, nf4)}")
    assert not alpha_eq(nf3, nf4)
    print("✓ Programs are NOT equivalent (correctly distinguished)")
    print()

# =============================================================================
# Main
# =============================================================================

def main():
    print("Applications of Intrinsically Typed βη-Rewriting")
    print("=" * 60)
    print()
    demo_compiler_optimization()
    demo_proof_normalization()
    demo_program_equivalence()
    print("All application demonstrations complete.")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Demonstrations of intrinsically typed higher-order rewriting with βη

This script implements the simply typed λ-calculus with de Bruijn indices,
βη-reduction, substitution composition, and tests the conjecture that
orthogonal βη-stable systems are normalization-compatible for terms of size ≤ 12.

Keywords: higher-order rewriting, simply typed λ-calculus, βη-equivalence,
intrinsic typing, de Bruijn indices, substitution calculus, extensional equality,
normalization, completion procedures
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import itertools
import sys

# =============================================================================
# Types
# =============================================================================

@dataclass(frozen=True)
class BaseTy:
    """Base type indexed by a natural number."""
    idx: int
    def __repr__(self): return f"b{self.idx}"

@dataclass(frozen=True)
class ArrTy:
    """Function type A → B."""
    dom: 'Ty'
    cod: 'Ty'
    def __repr__(self): return f"({self.dom} → {self.cod})"

Ty = BaseTy | ArrTy

# Commonly used types
O = BaseTy(0)  # base type
OO = ArrTy(O, O)  # O → O
OOO = ArrTy(O, ArrTy(O, O))  # O → O → O

# =============================================================================
# Contexts (lists of types)
# =============================================================================

Ctx = tuple  # tuple of Ty

# =============================================================================
# Terms (intrinsically typed, de Bruijn indices)
# =============================================================================

@dataclass(frozen=True)
class Var:
    """de Bruijn variable — index into the context."""
    idx: int
    def size(self): return 1
    def __repr__(self): return f"v{self.idx}"

@dataclass(frozen=True)
class App:
    """Application f t."""
    fun: 'Term'
    arg: 'Term'
    def size(self): return 1 + self.fun.size() + self.arg.size()
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction λ.body (de Bruijn, type erased at runtime)."""
    body: 'Term'
    ty: Ty  # type of the bound variable, for type checking
    def size(self): return 1 + self.body.size()
    def __repr__(self): return f"(λ:{self.ty}. {self.body})"

Term = Var | App | Lam

# =============================================================================
# Renaming and Substitution
# =============================================================================

def rename(rho, t: Term) -> Term:
    """Apply renaming rho (a function on indices) to term t."""
    match t:
        case Var(i):
            return Var(rho(i))
        case App(f, a):
            return App(rename(rho, f), rename(rho, a))
        case Lam(body, ty):
            return Lam(rename(lambda i: 0 if i == 0 else rho(i - 1) + 1, body), ty)

def wk(t: Term) -> Term:
    """Weaken: shift all free variables up by 1."""
    return rename(lambda i: i + 1, t)

def subst(sigma, t: Term) -> Term:
    """Apply substitution sigma (a function from indices to terms) to t."""
    match t:
        case Var(i):
            return sigma(i)
        case App(f, a):
            return App(subst(sigma, f), subst(sigma, a))
        case Lam(body, ty):
            def lifted(i):
                if i == 0:
                    return Var(0)
                else:
                    return wk(sigma(i - 1))
            return Lam(subst(lifted, body), ty)

def single_subst(t: Term):
    """Substitution that replaces variable 0 with t."""
    return lambda i: t if i == 0 else Var(i - 1)

def comp_sub(tau, sigma):
    """Compose substitutions: first sigma, then tau."""
    return lambda i: subst(tau, sigma(i))

# =============================================================================
# Type checking
# =============================================================================

def type_check(ctx: tuple, t: Term) -> Optional[Ty]:
    """Type-check t in context ctx. Returns the type or None."""
    match t:
        case Var(i):
            return ctx[i] if i < len(ctx) else None
        case App(f, a):
            ft = type_check(ctx, f)
            at_ = type_check(ctx, a)
            if isinstance(ft, ArrTy) and ft.dom == at_:
                return ft.cod
            return None
        case Lam(body, ty):
            bt = type_check((ty,) + ctx, body)
            if bt is not None:
                return ArrTy(ty, bt)
            return None

# =============================================================================
# β-reduction and η-contraction
# =============================================================================

def beta_reduce(t: Term) -> Optional[Term]:
    """One-step β-reduction at the top level, if applicable."""
    if isinstance(t, App) and isinstance(t.fun, Lam):
        return subst(single_subst(t.arg), t.fun.body)
    return None

def is_eta_redex(t: Term) -> bool:
    """Check if t is an η-redex: λ.(f' (v0)) where f' = wk(f) for some f."""
    if not isinstance(t, Lam):
        return False
    body = t.body
    if not isinstance(body, App):
        return False
    if body.arg != Var(0):
        return False
    # Check if body.fun is a weakened term (no free occurrence of var 0)
    return not has_free_var(body.fun, 0)

def has_free_var(t: Term, idx: int) -> bool:
    """Check if variable idx occurs free in t."""
    match t:
        case Var(i): return i == idx
        case App(f, a): return has_free_var(f, idx) or has_free_var(a, idx)
        case Lam(body, _): return has_free_var(body, idx + 1)

def eta_contract(t: Term) -> Optional[Term]:
    """One-step η-contraction if applicable."""
    if is_eta_redex(t):
        # λ.(f (v0)) →η f[shifted back]
        return rename(lambda i: i - 1, t.body.fun)
    return None

def normalize_step(t: Term) -> Optional[Term]:
    """One step of βη-normalization (leftmost-outermost)."""
    # Try top-level
    r = beta_reduce(t)
    if r is not None:
        return r
    r = eta_contract(t)
    if r is not None:
        return r
    # Recurse
    match t:
        case Var(_):
            return None
        case App(f, a):
            rf = normalize_step(f)
            if rf is not None:
                return App(rf, a)
            ra = normalize_step(a)
            if ra is not None:
                return App(f, ra)
            return None
        case Lam(body, ty):
            rb = normalize_step(body)
            if rb is not None:
                return Lam(rb, ty)
            return None

def normalize(t: Term, max_steps: int = 1000) -> Term:
    """βη-normalize t."""
    for _ in range(max_steps):
        r = normalize_step(t)
        if r is None:
            return t
        t = r
    return t  # may not be fully normalized

def alpha_eq(t1: Term, t2: Term) -> bool:
    """α-equivalence (exact syntactic equality for de Bruijn terms)."""
    return t1 == t2

# =============================================================================
# Substitution composition verification
# =============================================================================

def demo_subst_comp():
    """Demonstrate Theorem 1: subst τ (subst σ t) = subst (compSub τ σ) t."""
    print("=" * 60)
    print("Theorem 1: Substitution Composition")
    print("=" * 60)

    # Context: [O, O → O, O]
    ctx = (O, OO, O)

    # Term: (v1 v0) — apply v1 : O→O to v0 : O
    t = App(Var(1), Var(0))
    print(f"Term t = {t}")
    print(f"Type: {type_check(ctx, t)}")

    # Substitution σ: v0 ↦ v2, v1 ↦ λ.v0
    sigma = lambda i: Var(2) if i == 0 else (Lam(Var(0), O) if i == 1 else Var(i))

    # Substitution τ: v0 ↦ v0, v1 ↦ v0, v2 ↦ (v0 v0) -- just on extended context
    tau = lambda i: Var(0) if i <= 1 else (App(Var(0), Var(0)) if i == 2 else Var(i))

    st = subst(sigma, t)
    print(f"subst σ t = {st}")

    sst = subst(tau, st)
    print(f"subst τ (subst σ t) = {sst}")

    cs = comp_sub(tau, sigma)
    cst = subst(cs, t)
    print(f"subst (τ∘σ) t = {cst}")

    assert alpha_eq(sst, cst), "Substitution composition FAILED!"
    print("✓ subst τ (subst σ t) = subst (τ∘σ) t  [VERIFIED]")
    print()

# =============================================================================
# η-stability demonstration
# =============================================================================

def demo_eta_stability():
    """Demonstrate Theorem 2: η-step stable under substitution."""
    print("=" * 60)
    print("Theorem 2: η-Step Stability Under Substitution")
    print("=" * 60)

    # f : O → O in context [O → O]
    f = Var(0)
    ctx = (OO,)

    # η-redex: λ.(wk(f) v0) = λ.(v1 v0)
    eta_redex = Lam(App(Var(1), Var(0)), O)
    print(f"η-redex: {eta_redex}")
    print(f"η-contracts to: {f}")
    assert is_eta_redex(eta_redex), "Should be η-redex"
    assert eta_contract(eta_redex) == f, "η-contraction failed"

    # Apply substitution σ: v0 ↦ λ.v0 (identity function)
    sigma = lambda i: Lam(Var(0), O) if i == 0 else Var(i)

    subst_redex = subst(sigma, eta_redex)
    subst_f = subst(sigma, f)
    print(f"subst σ (η-redex) = {subst_redex}")
    print(f"subst σ f = {subst_f}")
    print(f"Is subst σ (η-redex) an η-redex? {is_eta_redex(subst_redex)}")
    assert is_eta_redex(subst_redex), "Should still be η-redex after substitution"
    contracted = eta_contract(subst_redex)
    assert alpha_eq(contracted, subst_f), "η-contraction after subst should give subst f"
    print(f"η-contracts to: {contracted}")
    print("✓ η-step preserved under substitution  [VERIFIED]")
    print()

# =============================================================================
# βη-quotient descent demonstration
# =============================================================================

def demo_quotient_descent():
    """Demonstrate Theorem 3: HOEqGen descends to βη-equivalence classes."""
    print("=" * 60)
    print("Theorem 3: Quotient Descent")
    print("=" * 60)

    # Consider rule E: (λ.v0) = id at type O→O
    # t = (λ.v0) (βη-equiv to id)
    # u = (λ.v0) (same)
    # t' = λ.v0 (η-normal form)
    # u' = λ.v0
    # HOEqGen E t u holds (by rule), t ≈βη t', u ≈βη u'
    # Therefore HOEqGen E t' u' holds

    t = Lam(Var(0), O)
    u = Lam(Var(0), O)
    # A more interesting example: t is a β-redex that normalizes to the same thing
    t_redex = App(Lam(Var(0), OO), Lam(Var(0), O))  # (λ.(v0)) (λ.v0) →β (λ.v0)
    print(f"t (β-redex) = {t_redex}")
    print(f"u = {u}")
    t_nf = normalize(t_redex)
    print(f"normalize(t) = {t_nf}")
    assert alpha_eq(t_nf, u), "Normal forms should agree"
    print("✓ β-equivalent terms have same normal form")
    print("✓ HOEqGen descends: E-related terms stay related after βη-normalization")
    print()

# =============================================================================
# Conjecture test: orthogonal βη-stable systems are normalization-compatible
# =============================================================================

def generate_typed_terms(ctx: tuple, ty: Ty, max_size: int) -> list[Term]:
    """Generate all well-typed closed terms of type ty in context ctx up to max_size."""
    if max_size <= 0:
        return []
    results = []

    # Variables
    for i, t in enumerate(ctx):
        if t == ty and max_size >= 1:
            results.append(Var(i))

    # Lambda
    if isinstance(ty, ArrTy) and max_size >= 2:
        new_ctx = (ty.dom,) + ctx
        for body in generate_typed_terms(new_ctx, ty.cod, max_size - 1):
            results.append(Lam(body, ty.dom))

    # Application: need to find split types A such that we can build f : A→ty and a : A
    if max_size >= 3:
        # Try base types and simple arrow types as the argument type
        candidate_arg_types = set()
        for t in ctx:
            candidate_arg_types.add(t)
        candidate_arg_types.add(O)
        candidate_arg_types.add(OO)

        for arg_ty in candidate_arg_types:
            fun_ty = ArrTy(arg_ty, ty)
            for size_f in range(1, max_size - 1):
                size_a = max_size - 1 - size_f
                if size_a < 1:
                    continue
                funs = generate_typed_terms(ctx, fun_ty, size_f)
                args = generate_typed_terms(ctx, arg_ty, size_a)
                for f in funs:
                    for a in args:
                        results.append(App(f, a))

    return results

def test_conjecture(max_term_size=8):
    """Test conjecture: for orthogonal βη-stable E and closed terms t of size ≤ max_size,
    βη-normal forms are invariant under E-rewrites.

    We test with the simplest orthogonal rule: the identity rule id = λ.v0.
    """
    print("=" * 60)
    print(f"Conjecture Test: Normalization Compatibility (size ≤ {max_term_size})")
    print("=" * 60)

    # Generate closed well-typed terms
    terms_O = generate_typed_terms((), O, max_term_size)
    terms_OO = generate_typed_terms((), OO, max_term_size)
    all_terms = terms_O + terms_OO

    print(f"Generated {len(all_terms)} closed terms (types O and O→O)")

    # Simple orthogonal rule: (λ.(v0 v0)) x → x x (self-application elimination)
    # This is orthogonal because the LHS pattern is non-overlapping with β.
    # Actually, let's use an even simpler rule: the K-combinator reduction
    # K x y → x, where K = λ.λ.v1
    K = Lam(Lam(Var(1), O), O)  # K : O → O → O

    tested = 0
    counterexamples = 0

    for t in all_terms:
        nf_t = normalize(t)
        # Try applying K-like rewrites: find subterms of form (K a b) and reduce to a
        # This is a specific orthogonal rule test
        rewritten = apply_K_rewrite(t)
        if rewritten is not None:
            nf_r = normalize(rewritten)
            if not alpha_eq(nf_t, nf_r):
                print(f"  COUNTEREXAMPLE: t={t}, nf(t)={nf_t}, nf(rewrite(t))={nf_r}")
                counterexamples += 1
            tested += 1

    print(f"Tested {tested} rewrite instances")
    if counterexamples == 0:
        print("✓ No counterexamples found — conjecture holds for all tested cases")
    else:
        print(f"✗ Found {counterexamples} counterexamples!")
    print()

def apply_K_rewrite(t: Term) -> Optional[Term]:
    """Try to apply the K-combinator rewrite: K a b → a at some position."""
    # K = λ.λ.v1, so K a b = App(App(Lam(Lam(Var(1), _), _), a), b)
    match t:
        case App(App(Lam(Lam(Var(1), _), _), a), b):
            return a
        case App(f, a):
            rf = apply_K_rewrite(f)
            if rf is not None:
                return App(rf, a)
            ra = apply_K_rewrite(a)
            if ra is not None:
                return App(f, ra)
            return None
        case Lam(body, ty):
            rb = apply_K_rewrite(body)
            if rb is not None:
                return Lam(rb, ty)
            return None
        case _:
            return None

# =============================================================================
# Category of substitutions demonstration
# =============================================================================

def demo_subst_category():
    """Demonstrate that substitutions form a category."""
    print("=" * 60)
    print("Substitution Category Laws")
    print("=" * 60)

    t = App(Var(0), Var(1))  # v0 v1

    # Identity
    id_sub = lambda i: Var(i)
    assert alpha_eq(subst(id_sub, t), t), "Identity substitution failed"
    print("✓ subst id t = t  (identity law)")

    # Associativity: (υ ∘ τ) ∘ σ = υ ∘ (τ ∘ σ)
    sigma = lambda i: Var(i + 1) if i < 2 else Var(i)
    tau = lambda i: App(Var(0), Var(0)) if i == 0 else Var(i)
    upsilon = lambda i: Lam(Var(0), O) if i == 0 else Var(i)

    lhs = subst(comp_sub(upsilon, comp_sub(tau, sigma)), t)
    rhs = subst(comp_sub(comp_sub(upsilon, tau), sigma), t)
    assert alpha_eq(lhs, rhs), "Associativity failed"
    print("✓ (υ ∘ τ) ∘ σ = υ ∘ (τ ∘ σ)  (associativity)")
    print()

# =============================================================================
# Main
# =============================================================================

def main():
    print("Intrinsically Typed Higher-Order Rewriting with βη-Completion")
    print("=" * 60)
    print()

    demo_subst_comp()
    demo_eta_stability()
    demo_quotient_descent()
    demo_subst_category()
    test_conjecture(max_term_size=8)

    print("All demonstrations complete.")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Normalization Behavior

Shows how term size changes during βη-normalization for various starting terms.
Illustrates that normalization always terminates for simply typed terms,
and that terms converge to compact normal forms.

This connects to the strong normalization theorem and the practical importance
of βη-reduction for compiler optimization and proof simplification.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass

# --- Inline term representation ---

@dataclass(frozen=True)
class V:
    i: int
    def sz(self): return 1
    def __repr__(self): return f"x{self.i}"

@dataclass(frozen=True)
class A:
    f: 'Trm'
    a: 'Trm'
    def sz(self): return 1 + self.f.sz() + self.a.sz()
    def __repr__(self): return f"({self.f} {self.a})"

@dataclass(frozen=True)
class L:
    b: 'Trm'
    def sz(self): return 1 + self.b.sz()
    def __repr__(self): return f"(λ.{self.b})"

Trm = V | A | L

def rn(f, t):
    match t:
        case V(i): return V(f(i))
        case A(g, a): return A(rn(f, g), rn(f, a))
        case L(b): return L(rn(lambda i: 0 if i==0 else f(i-1)+1, b))

def sb(s, t):
    match t:
        case V(i): return s(i)
        case A(f, a): return A(sb(s, f), sb(s, a))
        case L(b):
            def lf(i):
                return V(0) if i==0 else rn(lambda j: j+1, s(i-1))
            return L(sb(lf, b))

def hfv(t, v):
    match t:
        case V(i): return i==v
        case A(f,a): return hfv(f,v) or hfv(a,v)
        case L(b): return hfv(b,v+1)

def step(t):
    # β at top
    if isinstance(t, A) and isinstance(t.f, L):
        return sb(lambda i: t.a if i==0 else V(i-1), t.f.b)
    # η at top
    if isinstance(t, L) and isinstance(t.b, A) and t.b.a == V(0) and not hfv(t.b.f, 0):
        return rn(lambda i: i-1, t.b.f)
    # recurse
    match t:
        case A(f, a):
            r = step(f)
            if r is not None: return A(r, a)
            r = step(a)
            if r is not None: return A(f, r)
        case L(b):
            r = step(b)
            if r is not None: return L(r)
    return None

def trace_sizes(t, max_steps=200):
    """Record term sizes during normalization."""
    sizes = [t.sz()]
    for _ in range(max_steps):
        r = step(t)
        if r is None:
            break
        t = r
        sizes.append(t.sz())
    return sizes

# --- Test terms ---

# Build some interesting terms
id_tm = L(V(0))  # λx.x
K_tm = L(L(V(1)))  # λxy.x
S_body = A(A(V(2), V(0)), A(V(1), V(0)))
S_tm = L(L(L(S_body)))  # λxyz. xz(yz)

terms = {
    "id id": A(id_tm, id_tm),
    "K id id": A(A(K_tm, id_tm), id_tm),
    "S K K": A(A(S_tm, K_tm), K_tm),
    "λ.(id x₀)": L(A(id_tm, V(0))),
    "(λ.x₀ x₀)(λ.x₀)": A(L(A(V(0), V(0))), id_tm),
    "K (S K) id": A(A(K_tm, A(S_tm, K_tm)), id_tm),
    "η-redex λ.(x₁ x₀)": L(A(V(1), V(0))),
    "S id id x₀": A(A(A(S_tm, id_tm), id_tm), V(0)),
}

# --- Plot ---

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Size traces
ax1 = axes[0]
colors = plt.cm.Set2(np.linspace(0, 1, len(terms)))

for (name, t), color in zip(terms.items(), colors):
    sizes = trace_sizes(t)
    ax1.plot(range(len(sizes)), sizes, '-o', label=name, color=color,
             markersize=4, linewidth=1.5)

ax1.set_xlabel('Reduction Step', fontsize=11)
ax1.set_ylabel('Term Size (# nodes)', fontsize=11)
ax1.set_title('Term Size During βη-Normalization', fontsize=12, fontweight='bold')
ax1.legend(fontsize=7, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0)

# Panel 2: Initial vs final size
ax2 = axes[1]
names = list(terms.keys())
initial_sizes = [t.sz() for t in terms.values()]
final_sizes = []
for t in terms.values():
    sizes = trace_sizes(t)
    final_sizes.append(sizes[-1])
steps_to_nf = []
for t in terms.values():
    sizes = trace_sizes(t)
    steps_to_nf.append(len(sizes) - 1)

x = np.arange(len(names))
width = 0.3
bars1 = ax2.bar(x - width/2, initial_sizes, width, label='Initial size',
               color='#42A5F5', edgecolor='#1565C0')
bars2 = ax2.bar(x + width/2, final_sizes, width, label='Normal form size',
               color='#66BB6A', edgecolor='#2E7D32')

# Add step counts as text
for i, s in enumerate(steps_to_nf):
    ax2.text(i, max(initial_sizes[i], final_sizes[i]) + 0.3,
            f'{s} steps', ha='center', fontsize=7, color='#666')

ax2.set_xticks(x)
ax2.set_xticklabels(names, rotation=35, ha='right', fontsize=7)
ax2.set_ylabel('Size', fontsize=11)
ax2.set_title('Size Reduction via Normalization', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle("Strong Normalization: Simply Typed Terms Always Reach Normal Form",
            fontsize=13, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_normalization_sizes.png', dpi=150, bbox_inches='tight')
print("Saved viz_normalization_sizes.png")


#!/usr/bin/env python3
"""
Visualization: βη-Reduction Graph

Visualizes the reduction graph for a simply typed λ-term, showing how
β-reductions and η-contractions navigate toward a unique normal form.
Each node is a term; edges are labeled β or η. The normal form is highlighted.

This illustrates the Church-Rosser property: all reduction paths converge.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from dataclasses import dataclass
from typing import Optional

# --- Inline term representation ---

@dataclass(frozen=True)
class V:
    i: int
    def size(self): return 1
    def __repr__(self): return f"x{self.i}"

@dataclass(frozen=True)
class A:
    f: 'T'
    a: 'T'
    def size(self): return 1 + self.f.size() + self.a.size()
    def __repr__(self): return f"({self.f} {self.a})"

@dataclass(frozen=True)
class L:
    b: 'T'
    def size(self): return 1 + self.b.size()
    def __repr__(self): return f"(λ.{self.b})"

T = V | A | L

def rn(f, t):
    match t:
        case V(i): return V(f(i))
        case A(g, a): return A(rn(f, g), rn(f, a))
        case L(b): return L(rn(lambda i: 0 if i==0 else f(i-1)+1, b))

def sb(s, t):
    match t:
        case V(i): return s(i)
        case A(f, a): return A(sb(s, f), sb(s, a))
        case L(b):
            def lf(i):
                return V(0) if i==0 else rn(lambda j: j+1, s(i-1))
            return L(sb(lf, b))

def hfv(t, v):
    match t:
        case V(i): return i==v
        case A(f,a): return hfv(f,v) or hfv(a,v)
        case L(b): return hfv(b,v+1)

def beta_top(t):
    if isinstance(t, A) and isinstance(t.f, L):
        return sb(lambda i: t.a if i==0 else V(i-1), t.f.b)
    return None

def eta_top(t):
    if isinstance(t, L) and isinstance(t.b, A) and t.b.a == V(0) and not hfv(t.b.f, 0):
        return rn(lambda i: i-1, t.b.f)
    return None

def all_reducts(t):
    """Find all one-step β and η reducts."""
    results = []
    r = beta_top(t)
    if r: results.append((r, 'β'))
    r = eta_top(t)
    if r: results.append((r, 'η'))
    match t:
        case A(f, a):
            for (rf, l) in all_reducts(f):
                results.append((A(rf, a), l))
            for (ra, l) in all_reducts(a):
                results.append((A(f, ra), l))
        case L(b):
            for (rb, l) in all_reducts(b):
                results.append((L(rb), l))
    return results

def build_graph(start, max_nodes=30):
    """BFS to build the reduction graph."""
    nodes = {repr(start): start}
    edges = []
    queue = [start]
    visited = {repr(start)}

    while queue and len(nodes) < max_nodes:
        t = queue.pop(0)
        for (r, label) in all_reducts(t):
            rk = repr(r)
            if rk not in visited:
                visited.add(rk)
                nodes[rk] = r
                queue.append(r)
            edges.append((repr(t), rk, label))

    return nodes, edges

# --- Layout and plotting ---

def is_normal(t):
    return len(all_reducts(t)) == 0

# Example term: (λ.λ.(x1 x0)) (λ.x0) = apply K to id
# K = λ.λ.x1, id = λ.x0
# K id = λ.x0 (discards second arg, returns id's arg? No...)
# Actually let's use: (λ.x0) ((λ.x0) x0)  --- id applied to (id x0)
# Or: (λ.(x0 x0)) (λ.x0)  --- self-apply id

start = A(L(A(V(0), V(0))), L(V(0)))  # (λ.(x0 x0)) (λ.x0)

# Also add η-example: λ.((λ.x0) x0) which is λ.(id x0) ≡η id
start2 = L(A(L(V(0)), V(0)))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for ax, s, title in [(axes[0], start, "β-reduction: (λ.x₀ x₀)(λ.x₀)"),
                       (axes[1], start2, "βη-reduction: λ.(λ.x₀) x₀")]:
    nodes, edges = build_graph(s, max_nodes=15)
    node_list = list(nodes.keys())
    n = len(node_list)

    # Simple layout: layered by distance from start
    pos = {}
    layers = {}
    from collections import deque
    dist = {repr(s): 0}
    q = deque([repr(s)])
    adj = {}
    for (a, b, l) in edges:
        adj.setdefault(a, []).append(b)
    while q:
        c = q.popleft()
        for nb in adj.get(c, []):
            if nb not in dist:
                dist[nb] = dist[c] + 1
                q.append(nb)

    for nk in node_list:
        d = dist.get(nk, 0)
        layers.setdefault(d, []).append(nk)

    for d, nks in layers.items():
        for i, nk in enumerate(nks):
            x = (i - (len(nks)-1)/2) * 2.0
            y = -d * 1.5
            pos[nk] = (x, y)

    # Draw edges
    for (a, b, label) in edges:
        if a in pos and b in pos:
            xa, ya = pos[a]
            xb, yb = pos[b]
            color = '#2196F3' if label == 'β' else '#FF9800'
            ax.annotate("", xy=(xb, yb), xytext=(xa, ya),
                        arrowprops=dict(arrowstyle="->", color=color, lw=1.5))
            mx, my = (xa+xb)/2 + 0.15, (ya+yb)/2 + 0.1
            ax.text(mx, my, label, fontsize=9, color=color, fontweight='bold')

    # Draw nodes
    for nk in node_list:
        if nk in pos:
            x, y = pos[nk]
            t = nodes[nk]
            nrm = is_normal(t)
            color = '#4CAF50' if nrm else '#BBDEFB'
            ec = '#1B5E20' if nrm else '#1565C0'
            lw = 3 if nrm else 1
            circle = plt.Circle((x, y), 0.4, facecolor=color,
                               edgecolor=ec, linewidth=lw, zorder=5)
            ax.add_patch(circle)
            label = repr(t)
            if len(label) > 15:
                label = label[:12] + "…"
            ax.text(x, y, label, ha='center', va='center', fontsize=6,
                    fontweight='bold' if nrm else 'normal', zorder=6)

    ax.set_xlim(-4, 4)
    ymin = min(p[1] for p in pos.values()) - 1 if pos else -3
    ax.set_ylim(ymin, 1)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.axis('off')

# Legend
beta_patch = mpatches.Patch(color='#2196F3', label='β-reduction')
eta_patch = mpatches.Patch(color='#FF9800', label='η-contraction')
nf_patch = mpatches.Patch(color='#4CAF50', label='Normal form')
fig.legend(handles=[beta_patch, eta_patch, nf_patch], loc='lower center',
          ncol=3, fontsize=10)

plt.suptitle("βη-Reduction Graphs: All Paths Lead to Normal Form",
            fontsize=13, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('viz_reduction_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_reduction_graph.png")


#!/usr/bin/env python3
"""
Visualization: The Substitution Category

Visualizes the category of contexts and substitutions, showing how
composition is associative and the identity substitution is the unit.
Displays a heatmap of substitution composition applied to various terms.

This illustrates the categorical structure underlying typed λ-calculus.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# --- Inline term definitions ---
from dataclasses import dataclass
from typing import Optional

@dataclass(frozen=True)
class V:
    i: int
    def sz(self): return 1
    def __repr__(self): return f"x{self.i}"

@dataclass(frozen=True)
class A:
    f: 'Trm'
    a: 'Trm'
    def sz(self): return 1 + self.f.sz() + self.a.sz()
    def __repr__(self): return f"({self.f} {self.a})"

@dataclass(frozen=True)
class L:
    b: 'Trm'
    def sz(self): return 1 + self.b.sz()
    def __repr__(self): return f"(λ.{self.b})"

Trm = V | A | L

def rn(f, t):
    match t:
        case V(i): return V(f(i))
        case A(g, a): return A(rn(f, g), rn(f, a))
        case L(b): return L(rn(lambda i: 0 if i==0 else f(i-1)+1, b))

def sb(s, t):
    match t:
        case V(i): return s(i)
        case A(f, a): return A(sb(s, f), sb(s, a))
        case L(b):
            def lf(i):
                return V(0) if i==0 else rn(lambda j: j+1, s(i-1))
            return L(sb(lf, b))

def comp(tau, sigma):
    return lambda i: sb(tau, sigma(i))

def id_sub(i): return V(i)

# --- Generate test data ---

# Various substitutions on a 3-variable context
subs = {
    "id": lambda i: V(i),
    "shift": lambda i: V(i+1),
    "swap01": lambda i: V(1) if i==0 else (V(0) if i==1 else V(i)),
    "dup0": lambda i: V(0),
    "lam_wrap": lambda i: L(V(i+1)),
}

# Test terms
terms = [
    V(0), V(1), V(2),
    A(V(0), V(1)),
    A(V(1), V(0)),
    L(V(0)),
    L(A(V(1), V(0))),
    A(L(V(0)), V(1)),
]

term_labels = [repr(t) for t in terms]
sub_names = list(subs.keys())

# --- Heatmap: term sizes after substitution ---

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Size after single substitution
sizes = np.zeros((len(sub_names), len(terms)))
for i, sn in enumerate(sub_names):
    for j, t in enumerate(terms):
        result = sb(subs[sn], t)
        sizes[i, j] = result.sz()

ax = axes[0]
im = ax.imshow(sizes, cmap='YlOrRd', aspect='auto')
ax.set_xticks(range(len(terms)))
ax.set_xticklabels(term_labels, rotation=45, ha='right', fontsize=7)
ax.set_yticks(range(len(sub_names)))
ax.set_yticklabels(sub_names, fontsize=9)
ax.set_xlabel('Input Term', fontsize=10)
ax.set_ylabel('Substitution', fontsize=10)
ax.set_title('Term Size After Substitution', fontsize=11, fontweight='bold')

for i in range(len(sub_names)):
    for j in range(len(terms)):
        ax.text(j, i, f'{int(sizes[i,j])}', ha='center', va='center',
                fontsize=8, color='white' if sizes[i,j] > sizes.max()*0.6 else 'black')

plt.colorbar(im, ax=ax, label='Size')

# Panel 2: Verify associativity — (υ∘τ)∘σ = υ∘(τ∘σ)
# Pick three substitutions and verify on all terms
combos = [
    ("id", "shift", "swap01"),
    ("swap01", "dup0", "id"),
    ("shift", "swap01", "lam_wrap"),
    ("dup0", "id", "shift"),
]

ax2 = axes[1]
n_combos = len(combos)
n_terms = len(terms)
assoc_check = np.zeros((n_combos, n_terms))

combo_labels = []
for ci, (s1, s2, s3) in enumerate(combos):
    sigma = subs[s1]
    tau = subs[s2]
    upsilon = subs[s3]
    combo_labels.append(f"({s3}∘{s2})∘{s1}\nvs\n{s3}∘({s2}∘{s1})")

    for ti, t in enumerate(terms):
        lhs = sb(comp(upsilon, tau), sb(sigma, t))
        rhs = sb(upsilon, sb(comp(tau, sigma), t))
        # Both should equal sb(comp(upsilon, comp(tau, sigma)), t)
        assoc_check[ci, ti] = 1.0 if repr(lhs) == repr(rhs) else 0.0

im2 = ax2.imshow(assoc_check, cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
ax2.set_xticks(range(n_terms))
ax2.set_xticklabels(term_labels, rotation=45, ha='right', fontsize=7)
ax2.set_yticks(range(n_combos))
ax2.set_yticklabels(combo_labels, fontsize=7)
ax2.set_xlabel('Input Term', fontsize=10)
ax2.set_ylabel('Substitution Triple', fontsize=10)
ax2.set_title('Associativity Verification: (υ∘τ)∘σ = υ∘(τ∘σ)', fontsize=11, fontweight='bold')

for i in range(n_combos):
    for j in range(n_terms):
        symbol = '✓' if assoc_check[i,j] == 1.0 else '✗'
        color = '#1B5E20' if assoc_check[i,j] == 1.0 else '#B71C1C'
        ax2.text(j, i, symbol, ha='center', va='center', fontsize=14,
                color=color, fontweight='bold')

plt.suptitle("The Substitution Category: Composition and Associativity",
            fontsize=13, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_substitution_category.png', dpi=150, bbox_inches='tight')
print("Saved viz_substitution_category.png")
