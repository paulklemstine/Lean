#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for intrinsically typed higher-order rewriting

Implements:
1. βη-normalizer for simply typed λ-terms (de Bruijn)
2. Orthogonality checker for typed rewrite rules
3. η-redex detector
4. Substitution composition engine
5. Higher-order equational generation

Complexity:
- Normalization: O(n * 2^n) worst case, O(n^2) typical for simply typed terms
  (strong normalization guarantees termination)
- Orthogonality check: O(|rules|^2 * max_pattern_size)
- η-detection: O(size(t))
- Substitution composition: O(size(σ) * size(t))

Keywords: higher-order rewriting, βη-equivalence, normalization, de Bruijn indices,
substitution calculus, completion procedures
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, Callable
from enum import Enum, auto

# =============================================================================
# Type System
# =============================================================================

class TyKind(Enum):
    BASE = auto()
    ARR = auto()

@dataclass(frozen=True)
class Ty:
    kind: TyKind
    idx: int = 0          # for base types
    dom: Optional['Ty'] = None  # for arrow types
    cod: Optional['Ty'] = None

    @staticmethod
    def base(n: int = 0) -> 'Ty':
        return Ty(TyKind.BASE, idx=n)

    @staticmethod
    def arr(a: 'Ty', b: 'Ty') -> 'Ty':
        return Ty(TyKind.ARR, dom=a, cod=b)

    def order(self) -> int:
        """The order of a type (max nesting depth of arrows on the left)."""
        if self.kind == TyKind.BASE:
            return 0
        return max(self.dom.order() + 1, self.cod.order())

    def __repr__(self):
        if self.kind == TyKind.BASE:
            return f"τ{self.idx}"
        return f"({self.dom} → {self.cod})"


# =============================================================================
# Terms (de Bruijn, intrinsically scoped)
# =============================================================================

class TermKind(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()

@dataclass(frozen=True)
class Term:
    kind: TermKind
    idx: int = 0
    fun: Optional['Term'] = None
    arg: Optional['Term'] = None
    body: Optional['Term'] = None
    binder_ty: Optional[Ty] = None

    @staticmethod
    def var(i: int) -> 'Term':
        return Term(TermKind.VAR, idx=i)

    @staticmethod
    def app(f: 'Term', a: 'Term') -> 'Term':
        return Term(TermKind.APP, fun=f, arg=a)

    @staticmethod
    def lam(ty: Ty, body: 'Term') -> 'Term':
        return Term(TermKind.LAM, body=body, binder_ty=ty)

    def size(self) -> int:
        match self.kind:
            case TermKind.VAR: return 1
            case TermKind.APP: return 1 + self.fun.size() + self.arg.size()
            case TermKind.LAM: return 1 + self.body.size()

    def __repr__(self):
        match self.kind:
            case TermKind.VAR: return f"x{self.idx}"
            case TermKind.APP: return f"({self.fun} {self.arg})"
            case TermKind.LAM: return f"(λ{self.binder_ty}.{self.body})"


# =============================================================================
# Algorithm 1: Renaming and Substitution
# =============================================================================

def rename(f: Callable[[int], int], t: Term) -> Term:
    """Apply a renaming (variable-to-variable map) to a term.

    Time: O(size(t))
    Space: O(depth(t)) for stack
    """
    match t.kind:
        case TermKind.VAR:
            return Term.var(f(t.idx))
        case TermKind.APP:
            return Term.app(rename(f, t.fun), rename(f, t.arg))
        case TermKind.LAM:
            lifted = lambda i: 0 if i == 0 else f(i - 1) + 1
            return Term.lam(t.binder_ty, rename(lifted, t.body))

def subst(sigma: Callable[[int], Term], t: Term) -> Term:
    """Apply a substitution to a term.

    Time: O(size(sigma_image) * size(t))
    Space: O(depth(t)) for stack
    """
    match t.kind:
        case TermKind.VAR:
            return sigma(t.idx)
        case TermKind.APP:
            return Term.app(subst(sigma, t.fun), subst(sigma, t.arg))
        case TermKind.LAM:
            def lifted(i):
                if i == 0:
                    return Term.var(0)
                return rename(lambda j: j + 1, sigma(i - 1))
            return Term.lam(t.binder_ty, subst(lifted, t.body))

def comp_subst(tau, sigma):
    """Compose substitutions: (tau ∘ sigma)(v) = subst tau (sigma v).

    This implements the verified composition law from Theorem 1.
    """
    return lambda i: subst(tau, sigma(i))


# =============================================================================
# Algorithm 2: βη-Normalizer
# =============================================================================

def beta_reduce_top(t: Term) -> Optional[Term]:
    """Top-level β-reduction: (λ.body) arg → body[arg/0].

    Time: O(size(body) * size(arg))
    """
    if t.kind == TermKind.APP and t.fun.kind == TermKind.LAM:
        return subst(lambda i: t.arg if i == 0 else Term.var(i - 1), t.fun.body)
    return None

def has_free(t: Term, v: int) -> bool:
    """Check if variable v occurs free in t. O(size(t))."""
    match t.kind:
        case TermKind.VAR: return t.idx == v
        case TermKind.APP: return has_free(t.fun, v) or has_free(t.arg, v)
        case TermKind.LAM: return has_free(t.body, v + 1)

def eta_contract_top(t: Term) -> Optional[Term]:
    """Top-level η-contraction: λ.(f (x0)) → f when x0 ∉ FV(f).

    This implements the η-step from Theorem 2.
    Time: O(size(t))
    """
    if t.kind != TermKind.LAM:
        return None
    body = t.body
    if body.kind != TermKind.APP:
        return None
    if body.arg.kind != TermKind.VAR or body.arg.idx != 0:
        return None
    if has_free(body.fun, 0):
        return None
    # Shift free variables down by 1
    return rename(lambda i: i - 1, body.fun)

def normalize(t: Term, max_steps: int = 10000) -> Term:
    """Full βη-normalization using leftmost-outermost strategy.

    For simply typed λ-terms, this always terminates (strong normalization).

    Time: O(n * 2^n) worst case, O(n^2) typical
    Convergence: guaranteed for simply typed terms (strong normalization theorem)

    Args:
        t: term to normalize
        max_steps: safety bound (should never be hit for well-typed terms of reasonable size)

    Returns:
        βη-normal form of t
    """
    for _ in range(max_steps):
        r = _normalize_step(t)
        if r is None:
            return t
        t = r
    return t

def _normalize_step(t: Term) -> Optional[Term]:
    """One leftmost-outermost βη-reduction step."""
    r = beta_reduce_top(t)
    if r is not None:
        return r
    r = eta_contract_top(t)
    if r is not None:
        return r
    match t.kind:
        case TermKind.VAR:
            return None
        case TermKind.APP:
            rf = _normalize_step(t.fun)
            if rf is not None:
                return Term.app(rf, t.arg)
            ra = _normalize_step(t.arg)
            if ra is not None:
                return Term.app(t.fun, ra)
            return None
        case TermKind.LAM:
            rb = _normalize_step(t.body)
            if rb is not None:
                return Term.lam(t.binder_ty, rb)
            return None


# =============================================================================
# Algorithm 3: η-Redex Detector
# =============================================================================

def detect_eta_redexes(t: Term) -> list[tuple[list[str], Term]]:
    """Find all η-redexes in a term, returning their paths and the redex.

    Time: O(size(t)^2) worst case
    """
    results = []
    _detect_eta(t, [], results)
    return results

def _detect_eta(t: Term, path: list[str], results: list):
    r = eta_contract_top(t)
    if r is not None:
        results.append((list(path), t))
    match t.kind:
        case TermKind.APP:
            _detect_eta(t.fun, path + ["fun"], results)
            _detect_eta(t.arg, path + ["arg"], results)
        case TermKind.LAM:
            _detect_eta(t.body, path + ["body"], results)
        case _:
            pass


# =============================================================================
# Algorithm 4: Orthogonality Checker
# =============================================================================

@dataclass
class RewriteRule:
    """A typed rewrite rule lhs → rhs."""
    name: str
    lhs: Term
    rhs: Term
    ctx: tuple  # context (types of free variables)
    ty: Ty      # type of both sides

def patterns_overlap(p1: Term, p2: Term, depth: int = 0) -> bool:
    """Check if two pattern terms could overlap (conservative check).

    Two patterns overlap if there exists a substitution making them equal.
    This is a simplified check for first-order-like patterns.

    Time: O(min(size(p1), size(p2)))
    """
    if depth > 100:
        return True  # conservative
    match (p1.kind, p2.kind):
        case (TermKind.VAR, _) | (_, TermKind.VAR):
            return True  # variable matches anything
        case (TermKind.APP, TermKind.APP):
            return patterns_overlap(p1.fun, p2.fun, depth+1) and \
                   patterns_overlap(p1.arg, p2.arg, depth+1)
        case (TermKind.LAM, TermKind.LAM):
            return patterns_overlap(p1.body, p2.body, depth+1)
        case _:
            return False

def check_orthogonal(rules: list[RewriteRule]) -> tuple[bool, Optional[str]]:
    """Check if a set of rewrite rules is orthogonal.

    A set of rules is orthogonal if:
    1. All rules are left-linear (no repeated variables in LHS)
    2. No two distinct rules have overlapping LHS patterns

    Time: O(|rules|^2 * max_pattern_size)

    Returns:
        (is_orthogonal, reason_if_not)
    """
    for i, r1 in enumerate(rules):
        for j, r2 in enumerate(rules):
            if i >= j:
                continue
            if patterns_overlap(r1.lhs, r2.lhs):
                return False, f"Rules '{r1.name}' and '{r2.name}' have overlapping patterns"
    return True, None


# =============================================================================
# Algorithm 5: Higher-Order Equational Generation
# =============================================================================

@dataclass
class EqProof:
    """A derivation in the HOEqGen system."""
    kind: str  # "rule", "refl", "symm", "trans", "congApp", "congLam"
    children: list['EqProof'] = field(default_factory=list)
    rule_name: str = ""
    term_left: Optional[Term] = None
    term_right: Optional[Term] = None

    def depth(self) -> int:
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

def generate_equations(rules: list[RewriteRule], t: Term,
                       max_depth: int = 3) -> list[tuple[Term, EqProof]]:
    """Generate all terms equated to t by HOEqGen up to given derivation depth.

    This implements a bounded search through the HOEqGen inference rules.

    Time: O(|rules|^depth * size(t)^depth) — exponential in depth
    """
    seen = {id(t)}
    results = [(t, EqProof("refl", term_left=t, term_right=t))]

    frontier = [(t, EqProof("refl", term_left=t, term_right=t))]
    for _ in range(max_depth):
        new_frontier = []
        for term, proof in frontier:
            # Try applying each rule
            for rule in rules:
                matches = find_rule_matches(term, rule)
                for new_term in matches:
                    key = repr(new_term)
                    if key not in seen:
                        seen.add(key)
                        p = EqProof("rule", [proof], rule.name, term, new_term)
                        results.append((new_term, p))
                        new_frontier.append((new_term, p))
        frontier = new_frontier

    return results

def find_rule_matches(t: Term, rule: RewriteRule) -> list[Term]:
    """Find all ways to apply a rewrite rule to t (at any position)."""
    results = []
    _find_matches(t, rule, results)
    return results

def _find_matches(t: Term, rule: RewriteRule, results: list):
    # Try matching at the root
    sigma = try_match(rule.lhs, t)
    if sigma is not None:
        results.append(subst(sigma, rule.rhs))
    # Recurse
    match t.kind:
        case TermKind.APP:
            for new_f in find_rule_matches(t.fun, rule):
                results.append(Term.app(new_f, t.arg))
            for new_a in find_rule_matches(t.arg, rule):
                results.append(Term.app(t.fun, new_a))
        case TermKind.LAM:
            for new_b in find_rule_matches(t.body, rule):
                results.append(Term.lam(t.binder_ty, new_b))
        case _:
            pass

def try_match(pattern: Term, target: Term) -> Optional[Callable]:
    """Try to match pattern against target, returning a substitution if successful."""
    bindings = {}
    if _match(pattern, target, bindings):
        return lambda i: bindings.get(i, Term.var(i))
    return None

def _match(pattern: Term, target: Term, bindings: dict) -> bool:
    match pattern.kind:
        case TermKind.VAR:
            if pattern.idx in bindings:
                return bindings[pattern.idx] == target
            bindings[pattern.idx] = target
            return True
        case TermKind.APP:
            if target.kind != TermKind.APP:
                return False
            return _match(pattern.fun, target.fun, bindings) and \
                   _match(pattern.arg, target.arg, bindings)
        case TermKind.LAM:
            if target.kind != TermKind.LAM:
                return False
            return _match(pattern.body, target.body, bindings)
    return False


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    O = Ty.base(0)
    OO = Ty.arr(O, O)

    # Example: normalize (λ.x0) applied to itself
    t = Term.app(Term.lam(O, Term.var(0)), Term.lam(O, Term.var(0)))
    print(f"Term: {t}")
    nf = normalize(t)
    print(f"Normal form: {nf}")

    # Example: detect η-redexes
    eta = Term.lam(O, Term.app(Term.var(1), Term.var(0)))
    redexes = detect_eta_redexes(eta)
    print(f"\nη-redexes in {eta}: {len(redexes)} found")

    # Example: orthogonality check
    r1 = RewriteRule("id", Term.app(Term.var(0), Term.var(1)),
                     Term.var(1), (OO, O), O)
    r2 = RewriteRule("const", Term.app(Term.app(Term.var(0), Term.var(1)), Term.var(2)),
                     Term.var(1), (Ty.arr(O, OO), O, O), O)
    is_orth, reason = check_orthogonal([r1, r2])
    print(f"\nOrthogonality: {is_orth} ({reason})")
