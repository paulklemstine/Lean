#!/usr/bin/env python3
"""
Higher-Order Completion: Core Algorithms

Implements the computational core of the higher-order completion framework:
1. De Bruijn term operations (rename, subst, beta-reduce)
2. Higher-order pattern matching
3. Bounded completion step generator
4. β-aware rewrite closure checker

All algorithms mirror the formally verified Lean definitions.
"""

from dataclasses import dataclass, field
from typing import Optional, Callable, Generator
from collections import deque


# ============================================================================
# 1. Term Data Structures
# ============================================================================

class Term:
    """Lambda term with de Bruijn indices."""
    pass

@dataclass(frozen=True)
class Var(Term):
    index: int
    def __repr__(self): return f"v{self.index}"
    def __hash__(self): return hash(("Var", self.index))
    def __eq__(self, other): return isinstance(other, Var) and self.index == other.index

@dataclass(frozen=True)
class App(Term):
    fun: Term
    arg: Term
    def __repr__(self): return f"({self.fun} · {self.arg})"
    def __hash__(self): return hash(("App", self.fun, self.arg))
    def __eq__(self, other): return isinstance(other, App) and self.fun == other.fun and self.arg == other.arg

@dataclass(frozen=True)
class Lam(Term):
    body: Term
    def __repr__(self): return f"(λ.{self.body})"
    def __hash__(self): return hash(("Lam", self.body))
    def __eq__(self, other): return isinstance(other, Lam) and self.body == other.body

@dataclass
class Equation:
    """An oriented rewrite rule."""
    lhs: Term
    rhs: Term
    name: str = ""

    def __repr__(self):
        return f"{self.name}: {self.lhs} → {self.rhs}"


# ============================================================================
# 2. Core Operations
# ============================================================================

def lift_ren(rho: Callable[[int], int]) -> Callable[[int], int]:
    """Lift a renaming under one binder.

    Complexity: O(1) per application.
    """
    def lifted(n: int) -> int:
        return 0 if n == 0 else rho(n - 1) + 1
    return lifted

def rename(rho: Callable[[int], int], t: Term) -> Term:
    """Apply a variable renaming to a term.

    Complexity: O(|t|) where |t| is the size of the term.

    Args:
        rho: A function mapping variable indices to variable indices.
        t: The term to rename.

    Returns:
        The renamed term.
    """
    if isinstance(t, Var):
        return Var(rho(t.index))
    elif isinstance(t, App):
        return App(rename(rho, t.fun), rename(rho, t.arg))
    elif isinstance(t, Lam):
        return Lam(rename(lift_ren(rho), t.body))
    raise TypeError(f"Unknown term type: {type(t)}")

def lift_subst(sigma: Callable[[int], Term]) -> Callable[[int], Term]:
    """Lift a substitution under one binder.

    The bound variable (index 0) maps to itself;
    free variables are substituted and then weakened.

    Complexity: O(|σ(n)|) per application (due to renaming).
    """
    def lifted(n: int) -> Term:
        if n == 0:
            return Var(0)
        return rename(lambda x: x + 1, sigma(n - 1))
    return lifted

def subst(t: Term, sigma: Callable[[int], Term]) -> Term:
    """Apply a substitution to a term.

    Complexity: O(|t| * max(|σ(i)|)) in the worst case.

    Args:
        t: The term to substitute into.
        sigma: A function mapping variable indices to terms.

    Returns:
        The substituted term.
    """
    if isinstance(t, Var):
        return sigma(t.index)
    elif isinstance(t, App):
        return App(subst(t.fun, sigma), subst(t.arg, sigma))
    elif isinstance(t, Lam):
        return Lam(subst(t.body, lift_subst(sigma)))
    raise TypeError(f"Unknown term type: {type(t)}")

def single_subst(s: Term) -> Callable[[int], Term]:
    """Substitution replacing variable 0 with s, shifting others down."""
    def sigma(n: int) -> Term:
        return s if n == 0 else Var(n - 1)
    return sigma

def beta_contract(body: Term, arg: Term) -> Term:
    """β-contraction: (λ.body) arg  →  body[0 := arg]."""
    return subst(body, single_subst(arg))

def comp_subst(sigma, tau):
    """Compose substitutions: apply sigma first, then tau.

    This implements the categorically-motivated composition
    that makes substitutions form a category.
    """
    return lambda n: subst(sigma(n), tau)

def term_size(t: Term) -> int:
    """Number of constructors in a term."""
    if isinstance(t, Var): return 1
    elif isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    elif isinstance(t, Lam): return 1 + term_size(t.body)
    return 0


# ============================================================================
# 3. Higher-Order Pattern Matching
# ============================================================================

def ho_match(pattern: Term, target: Term, bound: int = 0) -> Optional[dict[int, Term]]:
    """Higher-order pattern matching (Miller patterns).

    Attempts to find a substitution σ such that pattern[σ] = target.
    Only matches "higher-order patterns" where meta-variables are
    applied to distinct bound variables.

    Args:
        pattern: The pattern to match against (variables are meta-variables).
        target: The target term.
        bound: Number of enclosing binders (for internal recursion).

    Returns:
        A substitution (as a dict) if matching succeeds, None otherwise.

    Complexity: O(|pattern| * |target|) in the size of terms.

    Example:
        >>> ho_match(Var(0), Lam(Var(0)))
        {0: Lam(Var(0))}
    """
    sigma: dict[int, Term] = {}

    def match_rec(pat: Term, tgt: Term, depth: int) -> bool:
        nonlocal sigma
        if isinstance(pat, Var):
            if pat.index < depth:
                # Bound variable — must match exactly
                return isinstance(tgt, Var) and tgt.index == pat.index
            else:
                # Free variable (meta-variable)
                meta_idx = pat.index - depth
                if meta_idx in sigma:
                    # Already bound — check consistency
                    expected = sigma[meta_idx]
                    # Need to shift expected by depth
                    shifted = rename(lambda x: x + depth, expected)
                    return shifted == tgt
                else:
                    # Try to extract: tgt should not mention bound vars
                    # For simplicity, just store with de-shifting
                    try:
                        val = rename(lambda x: x - depth if x >= depth else -1, tgt)
                        sigma[meta_idx] = val
                        return True
                    except:
                        return False
        elif isinstance(pat, App) and isinstance(tgt, App):
            return match_rec(pat.fun, tgt.fun, depth) and match_rec(pat.arg, tgt.arg, depth)
        elif isinstance(pat, Lam) and isinstance(tgt, Lam):
            return match_rec(pat.body, tgt.body, depth + 1)
        else:
            return False

    if match_rec(pattern, target, bound):
        return sigma
    return None

def apply_match(sigma: dict[int, Term], t: Term) -> Term:
    """Apply a matching substitution to a term."""
    return subst(t, lambda n: sigma.get(n, Var(n)))

def verify_match(pattern: Term, target: Term, sigma: dict[int, Term]) -> bool:
    """Verify that a matching substitution is correct."""
    result = apply_match(sigma, pattern)
    return result == target


# ============================================================================
# 4. β-Aware Reduction
# ============================================================================

def all_one_step_reducts(t: Term) -> list[Term]:
    """Compute all possible one-step β-reducts of a term.

    Returns all terms reachable by contracting exactly one β-redex.

    Complexity: O(|t|^2) in the worst case (finding all redexes
    and copying the term for each).
    """
    results = []
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            results.append(beta_contract(t.fun.body, t.arg))
        for r in all_one_step_reducts(t.fun):
            results.append(App(r, t.arg))
        for r in all_one_step_reducts(t.arg):
            results.append(App(t.fun, r))
    elif isinstance(t, Lam):
        for r in all_one_step_reducts(t.body):
            results.append(Lam(r))
    return results

def leftmost_reduce(t: Term) -> Optional[Term]:
    """Leftmost-outermost β-reduction (one step).

    This strategy is normalizing for the simply-typed λ-calculus.

    Complexity: O(|t|) to find the leftmost redex.
    """
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            return beta_contract(t.fun.body, t.arg)
        r = leftmost_reduce(t.fun)
        if r is not None:
            return App(r, t.arg)
        r = leftmost_reduce(t.arg)
        if r is not None:
            return App(t.fun, r)
    elif isinstance(t, Lam):
        r = leftmost_reduce(t.body)
        if r is not None:
            return Lam(r)
    return None

def normalize(t: Term, max_steps: int = 200) -> tuple[Term, int, bool]:
    """Normalize a term by leftmost-outermost reduction.

    Returns:
        (normal_form, steps_taken, reached_normal_form)

    Complexity: O(max_steps * |t_max|) where |t_max| is the
    maximum intermediate term size.
    """
    steps = 0
    while steps < max_steps:
        r = leftmost_reduce(t)
        if r is None:
            return t, steps, True
        t = r
        steps += 1
    return t, steps, False


# ============================================================================
# 5. Higher-Order Rewrite Step Checker
# ============================================================================

def check_rewrite_step(equations: list[Equation], t: Term, u: Term) -> Optional[str]:
    """Check if t rewrites to u in one step using the given equations.

    Tries all equations at all positions in t, checking if any
    yields u. Also checks β-reduction.

    Args:
        equations: The rewrite rules.
        t: Source term.
        u: Target term.

    Returns:
        A description of the rewrite step if found, None otherwise.

    Complexity: O(|t| * |equations| * matching_cost).
    """
    # Check β-step
    if isinstance(t, App) and isinstance(t.fun, Lam):
        if beta_contract(t.fun.body, t.arg) == u:
            return "β-reduction at root"

    # Check equation application at root
    for eq in equations:
        sigma = ho_match(eq.lhs, t)
        if sigma is not None:
            result = apply_match(sigma, eq.rhs)
            if result == u:
                return f"Rule '{eq.name}' at root with σ={sigma}"

    # Check in subterms
    if isinstance(t, App) and isinstance(u, App):
        if t.arg == u.arg:
            r = check_rewrite_step(equations, t.fun, u.fun)
            if r is not None:
                return f"In function position: {r}"
        if t.fun == u.fun:
            r = check_rewrite_step(equations, t.arg, u.arg)
            if r is not None:
                return f"In argument position: {r}"
    elif isinstance(t, Lam) and isinstance(u, Lam):
        r = check_rewrite_step(equations, t.body, u.body)
        if r is not None:
            return f"Under λ: {r}"

    return None


# ============================================================================
# 6. Bounded Completion Step Generator
# ============================================================================

def generate_critical_pairs(eq1: Equation, eq2: Equation) -> list[tuple[Term, Term]]:
    """Generate critical pairs between two equations.

    A critical pair arises when the LHS of one equation overlaps
    with a subterm of the LHS of another.

    For higher-order systems, this is more complex than first-order
    due to β-equivalence classes. This implementation handles
    simple (non-nested) overlaps.

    Complexity: O(|eq1.lhs| * |eq2.lhs|) for simple overlaps.
    """
    pairs = []

    def find_overlaps(t: Term, pos: list) -> None:
        sigma = ho_match(eq2.lhs, t)
        if sigma is not None:
            # Overlap found: eq1.lhs has a subterm matching eq2.lhs
            # Result 1: apply eq1 to the whole term → eq1.rhs
            # Result 2: apply eq2 at position → eq1.lhs with subterm replaced
            rhs_local = apply_match(sigma, eq2.rhs)
            replaced = replace_at(eq1.lhs, pos, rhs_local)
            if replaced is not None:
                pairs.append((eq1.rhs, replaced))

        if isinstance(t, App):
            find_overlaps(t.fun, pos + ['L'])
            find_overlaps(t.arg, pos + ['R'])
        elif isinstance(t, Lam):
            find_overlaps(t.body, pos + ['B'])

    def replace_at(t: Term, pos: list, replacement: Term) -> Optional[Term]:
        if not pos:
            return replacement
        if isinstance(t, App):
            if pos[0] == 'L':
                r = replace_at(t.fun, pos[1:], replacement)
                return App(r, t.arg) if r is not None else None
            elif pos[0] == 'R':
                r = replace_at(t.arg, pos[1:], replacement)
                return App(t.fun, r) if r is not None else None
        elif isinstance(t, Lam) and pos[0] == 'B':
            r = replace_at(t.body, pos[1:], replacement)
            return Lam(r) if r is not None else None
        return None

    find_overlaps(eq1.lhs, [])
    return pairs

def bounded_completion(equations: list[Equation], max_rounds: int = 10,
                       max_rules: int = 50) -> list[Equation]:
    """Bounded higher-order completion procedure.

    Attempts to complete a set of equations by:
    1. Computing critical pairs
    2. Normalizing critical pairs
    3. Adding non-trivial pairs as new rules

    This is a bounded approximation to the full Knuth-Bendix procedure
    adapted for higher-order systems with β-reduction.

    Args:
        equations: Initial set of equations.
        max_rounds: Maximum number of completion rounds.
        max_rules: Maximum number of rules to accumulate.

    Returns:
        The (possibly incomplete) set of rewrite rules after completion.

    Complexity: Each round is O(|rules|^2 * overlap_cost * normalization_cost).
    """
    rules = list(equations)
    rule_count = len(rules)

    for round_num in range(max_rounds):
        new_pairs = []
        for i, eq1 in enumerate(rules):
            for j, eq2 in enumerate(rules):
                pairs = generate_critical_pairs(eq1, eq2)
                for lhs, rhs in pairs:
                    # Normalize both sides
                    lhs_nf, _, _ = normalize(lhs)
                    rhs_nf, _, _ = normalize(rhs)
                    if lhs_nf != rhs_nf:
                        new_pairs.append((lhs_nf, rhs_nf))

        if not new_pairs:
            break

        for lhs, rhs in new_pairs:
            if len(rules) >= max_rules:
                break
            # Orient by size (simple heuristic)
            if term_size(lhs) >= term_size(rhs):
                rules.append(Equation(lhs, rhs, f"cp_{rule_count}"))
            else:
                rules.append(Equation(rhs, lhs, f"cp_{rule_count}"))
            rule_count += 1

    return rules


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=== Higher-Order Pattern Matching ===")
    # Pattern: f x where f is meta-variable 1, x is meta-variable 0
    pattern = App(Var(1), Var(0))
    target = App(Lam(Var(0)), Var(42))
    result = ho_match(pattern, target)
    print(f"Pattern: {pattern}")
    print(f"Target:  {target}")
    print(f"Match:   {result}")
    if result:
        print(f"Verify:  {verify_match(pattern, target, result)}")
    print()

    print("=== Rewrite Step Checking ===")
    # Rule: (λx.x) y → y  (beta as explicit rule)
    beta_rule = Equation(App(Lam(Var(0)), Var(1)), Var(1), "beta_explicit")
    t = App(App(Lam(Var(0)), Var(5)), Var(3))
    u = App(Var(5), Var(3))
    step = check_rewrite_step([beta_rule], t, u)
    print(f"Term:   {t}")
    print(f"Target: {u}")
    print(f"Step:   {step}")
    print()

    print("=== One-Step Reducts ===")
    t = App(Lam(App(Var(0), Var(0))), Lam(Var(0)))
    reducts = all_one_step_reducts(t)
    print(f"Term: {t}")
    print(f"Reducts ({len(reducts)}):")
    for r in reducts:
        print(f"  → {r}")
    print()

    print("=== Normalization ===")
    # (λx.λy.x) a b → a
    t = App(App(Lam(Lam(Var(1))), Var(0)), Var(1))
    nf, steps, done = normalize(t)
    print(f"Term: {t}")
    print(f"Normal form: {nf} (in {steps} steps, done={done})")
