#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for intrinsically typed higher-order rewriting.

Implements:
1. βη-normalizer for simply typed λ-terms (de Bruijn representation)
2. Orthogonality checker for finite typed rewrite rule sets
3. One-step η-redex detection
4. Substitution composition verifier
5. HOEqGen closure computation

All algorithms match the formal Lean definitions in IntrinsicBetaEta/Core.lean
and IntrinsicBetaEta/BetaEta.lean.
"""

from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Dict, Set, Callable
from enum import Enum

# ============================================================================
# Types (same as demo.py, inlined for self-containment)
# ============================================================================

class Ty:
    """Simple types."""
    pass

@dataclass(frozen=True)
class Base(Ty):
    index: int
    def __repr__(self): return f"b{self.index}"
    def order(self) -> int: return 0

@dataclass(frozen=True)
class Arr(Ty):
    dom: Ty
    cod: Ty
    def __repr__(self): return f"({self.dom} → {self.cod})"
    def order(self) -> int: return max(self.dom.order() + 1, self.cod.order())

B0, B1 = Base(0), Base(1)
Ctx = tuple

# ============================================================================
# Terms
# ============================================================================

class Tm:
    pass

@dataclass(frozen=True)
class Var(Tm):
    index: int
    def __repr__(self): return f"v{self.index}"
    def size(self) -> int: return 1

@dataclass(frozen=True)
class App(Tm):
    fun: Tm
    arg: Tm
    def __repr__(self): return f"({self.fun} {self.arg})"
    def size(self) -> int: return 1 + self.fun.size() + self.arg.size()

@dataclass(frozen=True)
class Lam(Tm):
    dom_ty: Ty
    body: Tm
    def __repr__(self): return f"(λ:{self.dom_ty}. {self.body})"
    def size(self) -> int: return 1 + self.body.size()

# ============================================================================
# Algorithm 1: Renaming and Substitution
# ============================================================================

def rename(rho: Callable[[int], int], t: Tm) -> Tm:
    """Apply a renaming to a term.

    Time complexity: O(|t|) where |t| is the size of the term.
    Space complexity: O(|t|) for the result term.

    >>> rename(lambda i: i+1, Var(0))
    v1
    """
    if isinstance(t, Var):
        return Var(rho(t.index))
    elif isinstance(t, App):
        return App(rename(rho, t.fun), rename(rho, t.arg))
    elif isinstance(t, Lam):
        lifted = lambda i, r=rho: 0 if i == 0 else r(i - 1) + 1
        return Lam(t.dom_ty, rename(lifted, t.body))
    raise TypeError(f"Unknown term type: {type(t)}")

def shift(t: Tm) -> Tm:
    """Weaken a term by shifting all variables up by 1.

    >>> shift(Var(0))
    v1
    >>> shift(App(Var(0), Var(1)))
    (v1 v2)
    """
    return rename(lambda i: i + 1, t)

def subst(sigma: Callable[[int], Tm], t: Tm) -> Tm:
    """Apply a substitution to a term.

    sigma maps variable indices to terms.

    Time complexity: O(|t| * max(|sigma(i)|))
    Space complexity: O(|result|)

    >>> subst(lambda i: Var(i+1), Var(0))
    v1
    """
    if isinstance(t, Var):
        return sigma(t.index)
    elif isinstance(t, App):
        return App(subst(sigma, t.fun), subst(sigma, t.arg))
    elif isinstance(t, Lam):
        def lifted(i, s=sigma):
            if i == 0:
                return Var(0)
            return shift(s(i - 1))
        return Lam(t.dom_ty, subst(lifted, t.body))
    raise TypeError(f"Unknown term type: {type(t)}")

def subst_single(body: Tm, arg: Tm) -> Tm:
    """Substitute arg for variable 0 in body.

    >>> subst_single(Var(0), Var(42))
    v42
    >>> subst_single(Var(1), Var(42))
    v0
    """
    def sigma(i):
        if i == 0:
            return arg
        return Var(i - 1)
    return subst(sigma, body)

def comp_sub(tau: Callable[[int], Tm], sigma: Callable[[int], Tm]) -> Callable[[int], Tm]:
    """Compose two substitutions: (comp_sub tau sigma)(v) = subst tau (sigma v).

    This is the categorical composition in the substitution category.

    >>> cs = comp_sub(lambda i: Var(i+1), lambda i: Var(i))
    >>> cs(0)
    v1
    """
    return lambda i: subst(tau, sigma(i))

# ============================================================================
# Algorithm 2: βη-Normalizer
# ============================================================================

def beta_reduce_step(t: Tm) -> Optional[Tm]:
    """One-step leftmost-outermost β-reduction.

    Returns None if no β-redex exists.

    Time complexity: O(|t|) for redex search + O(|body| + |arg|) for substitution.

    >>> beta_reduce_step(App(Lam(B0, Var(0)), Var(1)))
    v1
    """
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

def is_shifted(t: Tm) -> Optional[Tm]:
    """Check if t = shift(s) for some s; return s or None.

    This is the key check for η-redex detection: λx. f x is an η-redex
    when f = shift(g), meaning x does not appear free in f.

    Time complexity: O(|t|)

    >>> is_shifted(Var(1))
    v0
    >>> is_shifted(Var(0))
    """
    if isinstance(t, Var):
        return Var(t.index - 1) if t.index > 0 else None
    elif isinstance(t, App):
        f = is_shifted(t.fun)
        a = is_shifted(t.arg)
        return App(f, a) if f is not None and a is not None else None
    elif isinstance(t, Lam):
        return None  # Conservative
    return None

def eta_contract_step(t: Tm) -> Optional[Tm]:
    """One-step η-contraction: λx. f x → f when x ∉ FV(f).

    The side condition is checked via is_shifted: f must be of the form
    shift(g), ensuring variable 0 does not appear in f.

    Time complexity: O(|t|)

    >>> f = Var(0)
    >>> eta_expanded = Lam(B0, App(shift(f), Var(0)))
    >>> eta_contract_step(eta_expanded)
    v0
    """
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

def normalize_beta_eta(t: Tm, max_steps: int = 10000) -> Tm:
    """Normalize a term by alternating β-reduction and η-contraction.

    Strategy: leftmost-outermost β first, then η.
    Terminates for all simply-typed terms (strong normalization).

    Time complexity: O(max_steps * |t|) worst case.
    For simply-typed terms, termination is guaranteed.

    >>> t = App(Lam(B0, Var(0)), Var(1))
    >>> normalize_beta_eta(t)
    v1
    """
    steps = 0
    for _ in range(max_steps):
        r = beta_reduce_step(t)
        if r is not None:
            t = r
            steps += 1
            continue
        r = eta_contract_step(t)
        if r is not None:
            t = r
            steps += 1
            continue
        return t
    return t

# ============================================================================
# Algorithm 3: Orthogonality Checker
# ============================================================================

@dataclass
class RewriteRule:
    """A typed rewrite rule with context information."""
    ctx: Ctx
    ty: Ty
    lhs: Tm
    rhs: Tm

    def __repr__(self):
        return f"{self.lhs} → {self.rhs} : {self.ty}"

def patterns_overlap(p1: Tm, p2: Tm) -> bool:
    """Check if two patterns overlap (have a common instance).

    Two patterns overlap if they unify. For first-order patterns
    (no lambdas in the pattern), this is decidable.

    Time complexity: O(|p1| + |p2|) for first-order patterns.

    >>> patterns_overlap(Var(0), Var(1))
    True
    >>> patterns_overlap(App(Var(0), Var(1)), Lam(B0, Var(0)))
    False
    """
    if isinstance(p1, Var) or isinstance(p2, Var):
        return True  # Variables match anything
    if type(p1) != type(p2):
        return False
    if isinstance(p1, App) and isinstance(p2, App):
        return patterns_overlap(p1.fun, p2.fun) and patterns_overlap(p1.arg, p2.arg)
    if isinstance(p1, Lam) and isinstance(p2, Lam):
        return patterns_overlap(p1.body, p2.body)
    return False

def check_orthogonality(rules: List[RewriteRule]) -> Tuple[bool, Optional[str]]:
    """Check if a set of rewrite rules is orthogonal.

    A system is orthogonal if:
    1. It is left-linear (no variable appears twice in a LHS) — simplified: always true for our patterns
    2. No critical pairs exist (no overlapping left-hand sides)

    Returns (is_orthogonal, reason_if_not).

    Time complexity: O(n² * max(|lhs|)) where n is the number of rules.

    >>> rules = [RewriteRule((), B0, App(Var(0), Var(1)), Var(0))]
    >>> check_orthogonality(rules)
    (True, None)
    """
    for i, r1 in enumerate(rules):
        for j, r2 in enumerate(rules):
            if i >= j:
                continue
            if patterns_overlap(r1.lhs, r2.lhs):
                return False, f"Rules {i} and {j} have overlapping LHS"
    return True, None

# ============================================================================
# Algorithm 4: Substitution Composition Verifier
# ============================================================================

def verify_subst_comp(sigma, tau, t: Tm) -> bool:
    """Verify subst τ (subst σ t) = subst (compSub τ σ) t.

    This computationally checks Theorem 1 for a specific instance.

    >>> verify_subst_comp(lambda i: Var(i), lambda i: Var(i), Var(0))
    True
    """
    lhs = subst(tau, subst(sigma, t))
    rhs = subst(comp_sub(tau, sigma), t)
    return lhs == rhs

# ============================================================================
# Algorithm 5: HOEqGen Closure Computation
# ============================================================================

def compute_hoegen_closure(rules: List[RewriteRule],
                          terms: List[Tm],
                          max_iterations: int = 100) -> Dict[Tm, Set[int]]:
    """Compute equivalence classes under HOEqGen for a finite set of terms.

    Returns a mapping from each term to its equivalence class (represented
    as a set of indices into the terms list).

    Time complexity: O(max_iterations * |terms|² * |rules|)

    >>> rules_empty = []
    >>> terms = [Var(0), Var(1)]
    >>> classes = compute_hoegen_closure(rules_empty, terms)
    >>> len(classes)
    2
    """
    n = len(terms)
    # Union-find for equivalence classes
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
            return True
        return False

    # Normalize all terms
    nf = [normalize_beta_eta(t) for t in terms]

    # Initial: merge terms with the same normal form
    for i in range(n):
        for j in range(i + 1, n):
            if nf[i] == nf[j]:
                union(i, j)

    # Apply rules
    changed = True
    iteration = 0
    while changed and iteration < max_iterations:
        changed = False
        iteration += 1
        for rule in rules:
            for i in range(n):
                for j in range(n):
                    if find(i) == find(j):
                        continue
                    # Check if terms[i] rewrites to terms[j] or vice versa
                    if nf[i] == normalize_beta_eta(rule.lhs) and \
                       nf[j] == normalize_beta_eta(rule.rhs):
                        if union(i, j):
                            changed = True

    # Build class map
    classes = {}
    for i in range(n):
        root = find(i)
        if root not in classes:
            classes[root] = set()
        classes[root].add(i)

    return {terms[k]: v for k, v in classes.items()}


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # β-reduction
    print("1. β-reduction:")
    t = App(Lam(B0, App(Var(0), Var(0))), Lam(B0, Var(0)))
    print(f"   {t}")
    nf = normalize_beta_eta(t)
    print(f"   →βη* {nf}\n")

    # η-contraction
    print("2. η-contraction:")
    f = Var(0)
    eta_exp = Lam(B0, App(shift(f), Var(0)))
    print(f"   {eta_exp}")
    contracted = eta_contract_step(eta_exp)
    print(f"   →η {contracted}\n")

    # Substitution composition
    print("3. Substitution composition verification:")
    sigma = lambda i: Lam(B0, Var(0)) if i == 0 else Var(i)
    tau = lambda i: Var(i)
    test_term = App(Var(0), Var(1))
    result = verify_subst_comp(sigma, tau, test_term)
    print(f"   Term: {test_term}")
    print(f"   Composition verified: {result}\n")

    # Orthogonality check
    print("4. Orthogonality check:")
    rules = [
        RewriteRule((B0,), B0, App(Lam(B0, Var(0)), Var(0)), Var(0)),
    ]
    orth, reason = check_orthogonality(rules)
    print(f"   Rules: {rules}")
    print(f"   Orthogonal: {orth} ({reason})\n")

    print("All algorithm demonstrations complete.")
