#!/usr/bin/env python3
"""
algorithms.py — First-Order Term Algebra: Core Algorithms

Implements matching, rewriting, and Knuth-Bendix completion step functions
for first-order terms over a signature with arities.

These algorithms correspond to the formally verified definitions in
the Lean development (Pythagorean/ConcreteTermAlgebra.lean).

Time complexity:
  - match_term: O(|pattern| + |target|) — single pass
  - rewrite_one_step: O(|rules| * |term|^2) worst case
  - normalize: O(steps * |rules| * |term|^2)
  - compute_critical_pairs: O(|rules|^2 * max_term_size^2)
"""

from dataclasses import dataclass, field
from typing import Optional, Dict, List, Tuple
from copy import deepcopy


# ============================================================================
# Core Data Types
# ============================================================================

@dataclass(frozen=True)
class FnSym:
    """A function symbol with a name and arity."""
    name: str
    arity: int
    
    def __repr__(self):
        return self.name

@dataclass(frozen=True)
class Var:
    """A term variable."""
    name: str
    
    def __eq__(self, other):
        return isinstance(other, Var) and self.name == other.name
    
    def __hash__(self):
        return hash(("Var", self.name))

@dataclass(frozen=True)
class App:
    """Application of a function symbol to arguments."""
    fn: FnSym
    args: tuple  # tuple of Term
    
    def __init__(self, fn: FnSym, args: list):
        object.__setattr__(self, 'fn', fn)
        object.__setattr__(self, 'args', tuple(args))
        assert len(args) == fn.arity, f"{fn.name} expects {fn.arity} args, got {len(args)}"
    
    def __eq__(self, other):
        return isinstance(other, App) and self.fn == other.fn and self.args == other.args
    
    def __hash__(self):
        return hash(("App", self.fn.name, self.args))

# A Term is either Var or App
Term = Var | App

Substitution = Dict[str, Term]

@dataclass
class Rule:
    """A rewrite rule: lhs → rhs."""
    lhs: Term
    rhs: Term

@dataclass
class Equation:
    """An equation: lhs ≈ rhs."""
    lhs: Term
    rhs: Term


# ============================================================================
# Pretty Printing
# ============================================================================

def pretty_term(t: Term) -> str:
    """Human-readable term representation."""
    if isinstance(t, Var):
        return t.name
    elif isinstance(t, App):
        if t.fn.arity == 0:
            return t.fn.name
        elif t.fn.arity == 2 and t.fn.name in ("*", "·", "+", "∘"):
            return f"({pretty_term(t.args[0])} {t.fn.name} {pretty_term(t.args[1])})"
        elif t.fn.arity == 1 and t.fn.name in ("⁻¹", "-"):
            return f"{pretty_term(t.args[0])}{t.fn.name}"
        else:
            args_str = ", ".join(pretty_term(a) for a in t.args)
            return f"{t.fn.name}({args_str})"

def pretty_rule(r: Rule) -> str:
    return f"{pretty_term(r.lhs)} → {pretty_term(r.rhs)}"

def pretty_equation(e: Equation) -> str:
    return f"{pretty_term(e.lhs)} ≈ {pretty_term(e.rhs)}"


# ============================================================================
# Substitution Application
# ============================================================================

def apply_subst(sigma: Substitution, t: Term) -> Term:
    """Apply substitution σ to term t.
    
    Corresponds to FOTerm.subst in the Lean development.
    Satisfies: apply_subst({}, t) == t  (subst_id theorem)
    """
    if isinstance(t, Var):
        return sigma.get(t.name, t)
    elif isinstance(t, App):
        return App(t.fn, [apply_subst(sigma, a) for a in t.args])

def compose_subst(tau: Substitution, sigma: Substitution) -> Substitution:
    """Compose substitutions: first apply sigma, then tau.
    
    Corresponds to FOTerm.compSubst in the Lean development.
    Satisfies: apply_subst(compose_subst(tau, sigma), t) 
             == apply_subst(tau, apply_subst(sigma, t))  (subst_comp theorem)
    """
    result = {}
    all_vars = set(sigma.keys()) | set(tau.keys())
    for v in all_vars:
        if v in sigma:
            result[v] = apply_subst(tau, sigma[v])
        else:
            result[v] = tau.get(v, Var(v))
    # Remove identity mappings
    return {k: v for k, v in result.items() if v != Var(k)}


# ============================================================================
# Pattern Matching
# ============================================================================

def match_term(pattern: Term, target: Term, bindings: Optional[Substitution] = None) -> Optional[Substitution]:
    """Match pattern against target, returning substitution if successful.
    
    Returns σ such that apply_subst(σ, pattern) == target, or None.
    
    Soundness: if match_term(p, t) = σ, then apply_subst(σ, p) == t
    Corresponds to matchTerm in the Lean development.
    
    Time complexity: O(|pattern| + |target|)
    """
    if bindings is None:
        bindings = {}
    
    if isinstance(pattern, Var):
        if pattern.name in bindings:
            # Variable already bound — check consistency
            if bindings[pattern.name] == target:
                return dict(bindings)
            else:
                return None
        else:
            result = dict(bindings)
            result[pattern.name] = target
            return result
    
    elif isinstance(pattern, App):
        if not isinstance(target, App):
            return None
        if pattern.fn != target.fn:
            return None
        
        current = dict(bindings)
        for p_arg, t_arg in zip(pattern.args, target.args):
            result = match_term(p_arg, t_arg, current)
            if result is None:
                return None
            current = result
        return current


# ============================================================================
# Rewriting
# ============================================================================

def rewrite_at_root(rules: List[Rule], t: Term) -> Optional[Term]:
    """Try to rewrite t at the root position using one of the rules.
    
    Corresponds to Rewrites.root in the Lean development.
    """
    for rule in rules:
        sigma = match_term(rule.lhs, t)
        if sigma is not None:
            return apply_subst(sigma, rule.rhs)
    return None

def rewrite_one_step(rules: List[Rule], t: Term) -> Optional[Term]:
    """Try to rewrite t at any position (leftmost-outermost).
    
    Corresponds to Rewrites in the Lean development.
    The closure theorems guarantee this is sound:
    - rewrites_closed_under_subst: rewriting commutes with substitution
    - rewrites_closed_under_context: rewriting works in any context
    """
    # Try root first
    result = rewrite_at_root(rules, t)
    if result is not None:
        return result
    
    # Try arguments
    if isinstance(t, App):
        for i, arg in enumerate(t.args):
            result = rewrite_one_step(rules, arg)
            if result is not None:
                new_args = list(t.args)
                new_args[i] = result
                return App(t.fn, new_args)
    
    return None

def normalize(rules: List[Rule], t: Term, max_steps: int = 100) -> Term:
    """Normalize t by repeatedly applying rewrite rules.
    
    Returns the normal form (if terminating within max_steps).
    By the master theorem (convergent_nf_preserves_eval from 
    ConvergentRewriteSystems.lean), the normal form preserves
    semantics in every model of the equational theory.
    """
    current = t
    for _ in range(max_steps):
        next_t = rewrite_one_step(rules, current)
        if next_t is None:
            return current
        current = next_t
    return current


# ============================================================================
# Term Variables and Renaming
# ============================================================================

def term_vars(t: Term) -> set:
    """Collect all variables in a term."""
    if isinstance(t, Var):
        return {t.name}
    elif isinstance(t, App):
        result = set()
        for a in t.args:
            result |= term_vars(a)
        return result

def rename_vars(t: Term, suffix: str) -> Term:
    """Rename all variables in t by adding a suffix."""
    if isinstance(t, Var):
        return Var(t.name + suffix)
    elif isinstance(t, App):
        return App(t.fn, [rename_vars(a, suffix) for a in t.args])


# ============================================================================
# Critical Pair Computation
# ============================================================================

def unify(s: Term, t: Term, bindings: Optional[Substitution] = None) -> Optional[Substitution]:
    """Simple first-order unification (without occurs check for simplicity).
    
    Returns most general unifier σ such that apply_subst(σ, s) == apply_subst(σ, t),
    or None if unification fails.
    """
    if bindings is None:
        bindings = {}
    
    s = _walk(s, bindings)
    t = _walk(t, bindings)
    
    if isinstance(s, Var):
        if s == t:
            return dict(bindings)
        result = dict(bindings)
        result[s.name] = t
        return result
    
    if isinstance(t, Var):
        result = dict(bindings)
        result[t.name] = s
        return result
    
    if isinstance(s, App) and isinstance(t, App):
        if s.fn != t.fn:
            return None
        current = dict(bindings)
        for sa, ta in zip(s.args, t.args):
            result = unify(sa, ta, current)
            if result is None:
                return None
            current = result
        return current
    
    return None

def _walk(t: Term, bindings: Substitution) -> Term:
    """Follow variable bindings to find the current value."""
    while isinstance(t, Var) and t.name in bindings:
        t = bindings[t.name]
    return t

def superpose_at_root(rule1: Rule, rule2: Rule) -> List[Tuple[Term, Term]]:
    """Compute critical pairs by superposing rule2 at the root of rule1's lhs."""
    # Rename rule2 to avoid variable clashes
    lhs2 = rename_vars(rule2.lhs, "'")
    rhs2 = rename_vars(rule2.rhs, "'")
    
    sigma = unify(rule1.lhs, lhs2)
    if sigma is None:
        return []
    
    cp_left = apply_subst(sigma, rule1.rhs)
    cp_right = apply_subst(sigma, rhs2)
    
    if cp_left == cp_right:
        return []
    return [(cp_left, cp_right)]

def superpose_at_subterms(rule1: Rule, rule2: Rule) -> List[Tuple[Term, Term]]:
    """Compute critical pairs by superposing rule2 at non-variable subterms of rule1's lhs."""
    results = []
    
    def try_at(t: Term, context_fn):
        """Try to unify rule2.lhs with subterm t."""
        if isinstance(t, Var):
            return
        
        lhs2 = rename_vars(rule2.lhs, "'")
        rhs2 = rename_vars(rule2.rhs, "'")
        
        sigma = unify(t, lhs2)
        if sigma is not None:
            # Critical pair: apply sigma to (context with rhs2) vs rule1.rhs
            cp_left = apply_subst(sigma, context_fn(rhs2))
            cp_right = apply_subst(sigma, rule1.rhs)
            if cp_left != cp_right:
                results.append((cp_left, cp_right))
        
        if isinstance(t, App):
            for i, arg in enumerate(t.args):
                def make_context(replacement, fn=t.fn, args=t.args, idx=i, outer=context_fn):
                    new_args = list(args)
                    new_args[idx] = replacement
                    return outer(App(fn, new_args))
                try_at(arg, make_context)
    
    # Only superpose at proper subterms (not root — that's handled by superpose_at_root)
    if isinstance(rule1.lhs, App):
        for i, arg in enumerate(rule1.lhs.args):
            def make_top_context(replacement, fn=rule1.lhs.fn, args=rule1.lhs.args, idx=i):
                new_args = list(args)
                new_args[idx] = replacement
                return App(fn, new_args)
            try_at(arg, make_top_context)
    
    return results

def compute_critical_pairs(rules: List[Rule]) -> List[Tuple[Term, Term]]:
    """Compute all critical pairs between rules.
    
    Critical pairs are the source of new equations in KB completion.
    The deduce rule adds them to the equation set.
    """
    cps = []
    for r1 in rules:
        for r2 in rules:
            cps.extend(superpose_at_root(r1, r2))
            cps.extend(superpose_at_subterms(r1, r2))
    return cps


# ============================================================================
# Completion State and Steps
# ============================================================================

@dataclass
class CompletionState:
    """Concrete completion state: equations E and rules R.
    
    Corresponds to ConcreteState in the Lean development.
    The fundamental theorem (concrete_completion_preserves_equational_theory)
    guarantees that each step preserves the equational theory.
    """
    equations: List[Equation]
    rules: List[Rule]

def orient_step(state: CompletionState, eq_idx: int) -> CompletionState:
    """Orient: move equation from E to R.
    
    Corresponds to concreteOrient. Proved sound by
    concrete_orient_preserves_equational_theory.
    """
    eq = state.equations[eq_idx]
    new_eqs = state.equations[:eq_idx] + state.equations[eq_idx+1:]
    new_rules = state.rules + [Rule(eq.lhs, eq.rhs)]
    return CompletionState(equations=new_eqs, rules=new_rules)

def delete_step(state: CompletionState, eq_idx: int) -> Optional[CompletionState]:
    """Delete: remove trivial equation s ≈ s.
    
    Corresponds to concreteDelete. Proved sound by
    concrete_delete_preserves_equational_theory.
    """
    eq = state.equations[eq_idx]
    if eq.lhs == eq.rhs:
        new_eqs = state.equations[:eq_idx] + state.equations[eq_idx+1:]
        return CompletionState(equations=new_eqs, rules=state.rules)
    return None

def simplify_step(state: CompletionState, eq_idx: int) -> Optional[CompletionState]:
    """Simplify: rewrite an equation's LHS using rules.
    
    Corresponds to concreteSimplify. Proved sound by
    concrete_simplify_preserves_equational_theory.
    """
    eq = state.equations[eq_idx]
    new_lhs = rewrite_one_step(state.rules, eq.lhs)
    if new_lhs is not None:
        new_eq = Equation(new_lhs, eq.rhs)
        new_eqs = state.equations[:eq_idx] + [new_eq] + state.equations[eq_idx+1:]
        return CompletionState(equations=new_eqs, rules=state.rules)
    return None

def compose_step(state: CompletionState, rule_idx: int) -> Optional[CompletionState]:
    """Compose: simplify a rule's RHS using other rules.
    
    Corresponds to concreteCompose. Proved sound by
    concrete_compose_preserves_equational_theory.
    """
    rule = state.rules[rule_idx]
    other_rules = state.rules[:rule_idx] + state.rules[rule_idx+1:]
    new_rhs = rewrite_one_step(other_rules, rule.rhs)
    if new_rhs is not None:
        new_rule = Rule(rule.lhs, new_rhs)
        new_rules = state.rules[:rule_idx] + [new_rule] + state.rules[rule_idx+1:]
        return CompletionState(equations=state.equations, rules=new_rules)
    return None

def deduce_step(state: CompletionState, s: Term, t: Term) -> CompletionState:
    """Deduce: add a new equation from a critical pair.
    
    Corresponds to concreteDeduce. Proved sound by
    concrete_deduce_preserves_equational_theory.
    """
    return CompletionState(
        equations=state.equations + [Equation(s, t)],
        rules=state.rules
    )


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    # Quick smoke test
    f = FnSym("f", 2)
    a = FnSym("a", 0)
    x = Var("x")
    
    pattern = App(f, [x, App(a, [])])
    target = App(f, [App(a, []), App(a, [])])
    
    sigma = match_term(pattern, target)
    print(f"match({pretty_term(pattern)}, {pretty_term(target)}) = {sigma}")
    if sigma:
        print(f"  verify: {pretty_term(apply_subst(sigma, pattern))} == {pretty_term(target)}")
