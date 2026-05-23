"""
Algorithms for Convergent Rewrite Systems

Implements:
- Term representation and manipulation
- Substitution and pattern matching
- Normal form computation
- Critical pair analysis
- Knuth-Bendix completion (simplified)
- Evaluation in algebras

All algorithms correspond to the formal definitions in
Pythagorean/ConvergentRewriteMaster.lean.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import itertools


# =============================================================================
# Term Representation
# =============================================================================

@dataclass(frozen=True)
class Term:
    """First-order term over a signature with variables."""
    pass

@dataclass(frozen=True)
class Var(Term):
    """A variable term."""
    name: str

    def __repr__(self) -> str:
        return self.name

@dataclass(frozen=True)
class App(Term):
    """An application of an operation to arguments."""
    op: str
    args: tuple[Term, ...]

    def __repr__(self) -> str:
        if not self.args:
            return self.op
        return f"{self.op}({', '.join(repr(a) for a in self.args)})"


def term_size(t: Term) -> int:
    """Compute the size (number of nodes) of a term."""
    if isinstance(t, Var):
        return 1
    elif isinstance(t, App):
        return 1 + sum(term_size(a) for a in t.args)
    raise ValueError(f"Unknown term type: {type(t)}")


def term_vars(t: Term) -> set[str]:
    """Collect all variable names in a term."""
    if isinstance(t, Var):
        return {t.name}
    elif isinstance(t, App):
        return set().union(*(term_vars(a) for a in t.args))
    return set()


def term_depth(t: Term) -> int:
    """Compute the depth of a term."""
    if isinstance(t, Var):
        return 0
    elif isinstance(t, App):
        if not t.args:
            return 0
        return 1 + max(term_depth(a) for a in t.args)
    return 0


# =============================================================================
# Substitution
# =============================================================================

Substitution = dict[str, Term]


def apply_subst(t: Term, sub: Substitution) -> Term:
    """Apply a substitution to a term.

    Corresponds to Term.applySubst in the Lean formalization.
    """
    if isinstance(t, Var):
        return sub.get(t.name, t)
    elif isinstance(t, App):
        return App(t.op, tuple(apply_subst(a, sub) for a in t.args))
    raise ValueError(f"Unknown term type: {type(t)}")


def match_term(pattern: Term, target: Term, sub: Optional[Substitution] = None) -> Optional[Substitution]:
    """Try to match pattern against target, extending substitution sub.

    Returns the substitution if successful, None if matching fails.

    >>> match_term(Var('x'), App('f', (Var('a'),)))
    {'x': f(a)}
    >>> match_term(App('f', (Var('x'),)), App('f', (Var('a'),)))
    {'x': a}
    >>> match_term(App('f', (Var('x'),)), App('g', (Var('a'),)))  # None
    """
    if sub is None:
        sub = {}
    if isinstance(pattern, Var):
        if pattern.name in sub:
            if sub[pattern.name] == target:
                return sub
            return None
        sub = dict(sub)
        sub[pattern.name] = target
        return sub
    elif isinstance(pattern, App) and isinstance(target, App):
        if pattern.op != target.op or len(pattern.args) != len(target.args):
            return None
        for p, t in zip(pattern.args, target.args):
            sub = match_term(p, t, sub)
            if sub is None:
                return None
        return sub
    return None


# =============================================================================
# Rewrite Rules and Systems
# =============================================================================

@dataclass(frozen=True)
class RewriteRule:
    """A rewrite rule l → r.

    Corresponds to RewriteRule in the Lean formalization.
    """
    lhs: Term
    rhs: Term

    def __repr__(self) -> str:
        return f"{self.lhs} → {self.rhs}"


class RewriteSystem:
    """A term rewrite system (set of rewrite rules).

    Supports one-step and multi-step rewriting, normal form computation,
    and critical pair analysis.
    """

    def __init__(self, rules: list[RewriteRule]):
        self.rules = rules

    def one_step_rewrites(self, t: Term) -> list[Term]:
        """Compute all one-step rewrites of t.

        Tries to apply each rule at every position in t.
        """
        results = []
        for rule in self.rules:
            results.extend(self._apply_rule_at_all_positions(t, rule))
        return results

    def _apply_rule_at_all_positions(self, t: Term, rule: RewriteRule) -> list[Term]:
        """Apply a rule at every possible position in t."""
        results = []
        # Try at root
        sub = match_term(rule.lhs, t)
        if sub is not None:
            results.append(apply_subst(rule.rhs, sub))
        # Try in subterms
        if isinstance(t, App):
            for i, arg in enumerate(t.args):
                for rewritten_arg in self._apply_rule_at_all_positions(arg, rule):
                    new_args = list(t.args)
                    new_args[i] = rewritten_arg
                    results.append(App(t.op, tuple(new_args)))
        return results

    def normal_form(self, t: Term, max_steps: int = 10000) -> tuple[Term, int]:
        """Compute the normal form of t by repeatedly applying rules.

        Returns (normal_form, number_of_steps).
        Corresponds to nf in CertifiedNormalizer.

        Raises RuntimeError if max_steps exceeded (potential non-termination).
        """
        current = t
        steps = 0
        while steps < max_steps:
            rewrites = self.one_step_rewrites(current)
            if not rewrites:
                return current, steps
            current = rewrites[0]  # Leftmost-outermost strategy
            steps += 1
        raise RuntimeError(f"Normal form computation exceeded {max_steps} steps; "
                          f"system may not terminate. Last term: {current}")

    def is_normal_form(self, t: Term) -> bool:
        """Check if t is a normal form (no rules apply)."""
        return len(self.one_step_rewrites(t)) == 0


# =============================================================================
# Critical Pair Analysis
# =============================================================================

@dataclass
class CriticalPair:
    """A critical pair arising from overlapping rule applications.

    Corresponds to CriticalPair in the Lean formalization.
    """
    peak: Term
    left_result: Term
    right_result: Term
    rule1: RewriteRule
    rule2: RewriteRule

    def __repr__(self) -> str:
        return f"CP({self.left_result} ← {self.peak} → {self.right_result})"


def rename_vars(t: Term, suffix: str) -> Term:
    """Rename all variables in t by adding a suffix."""
    if isinstance(t, Var):
        return Var(t.name + suffix)
    elif isinstance(t, App):
        return App(t.op, tuple(rename_vars(a, suffix) for a in t.args))
    raise ValueError


def unify(t1: Term, t2: Term, sub: Optional[Substitution] = None) -> Optional[Substitution]:
    """Unify two terms, returning the most general unifier if it exists."""
    if sub is None:
        sub = {}
    t1 = _apply_sub_fully(t1, sub)
    t2 = _apply_sub_fully(t2, sub)
    if t1 == t2:
        return sub
    if isinstance(t1, Var):
        if _occurs_in(t1.name, t2):
            return None
        sub = dict(sub)
        sub[t1.name] = t2
        return sub
    if isinstance(t2, Var):
        if _occurs_in(t2.name, t1):
            return None
        sub = dict(sub)
        sub[t2.name] = t1
        return sub
    if isinstance(t1, App) and isinstance(t2, App):
        if t1.op != t2.op or len(t1.args) != len(t2.args):
            return None
        for a1, a2 in zip(t1.args, t2.args):
            sub = unify(a1, a2, sub)
            if sub is None:
                return None
        return sub
    return None


def _apply_sub_fully(t: Term, sub: Substitution) -> Term:
    """Apply substitution until no more substitutions apply."""
    prev = None
    while prev != t:
        prev = t
        t = apply_subst(t, sub)
    return t


def _occurs_in(var_name: str, t: Term) -> bool:
    """Occurs check: does var_name appear in t?"""
    if isinstance(t, Var):
        return t.name == var_name
    elif isinstance(t, App):
        return any(_occurs_in(var_name, a) for a in t.args)
    return False


def compute_critical_pairs(rules: list[RewriteRule]) -> list[CriticalPair]:
    """Compute all critical pairs from a list of rewrite rules.

    A critical pair arises when the LHS of one rule overlaps with
    a non-variable subterm of the LHS of another rule.
    """
    cps = []
    for i, r1 in enumerate(rules):
        for j, r2 in enumerate(rules):
            # Rename r2's variables to avoid capture
            r2_renamed = RewriteRule(
                rename_vars(r2.lhs, "_r"),
                rename_vars(r2.rhs, "_r")
            )
            # Try to overlap r2 at every non-variable position of r1.lhs
            cps.extend(_overlap_at_positions(r1, r2_renamed, r1.lhs, []))
    return cps


def _overlap_at_positions(r1: RewriteRule, r2: RewriteRule,
                          subterm: Term, position: list[int]) -> list[CriticalPair]:
    """Find overlaps of r2.lhs with subterms of r1.lhs."""
    cps = []
    # Skip variable positions (trivial overlaps)
    if isinstance(subterm, App):
        # Try to unify r2.lhs with this subterm
        mgu = unify(r2.lhs, subterm)
        if mgu is not None:
            # We have an overlap!
            # Apply r1 at root: result = apply_subst(r1.rhs, mgu)
            left = _apply_sub_fully(r1.rhs, mgu)
            # Apply r2 at this position: replace subterm with r2.rhs, then apply mgu
            right = _apply_sub_fully(
                _replace_at_position(r1.lhs, position, r2.rhs), mgu
            )
            peak = _apply_sub_fully(r1.lhs, mgu)
            cps.append(CriticalPair(
                peak=peak, left_result=left, right_result=right,
                rule1=r1, rule2=r2
            ))
        # Recurse into subterms
        for i, arg in enumerate(subterm.args):
            cps.extend(_overlap_at_positions(r1, r2, arg, position + [i]))
    return cps


def _replace_at_position(t: Term, position: list[int], replacement: Term) -> Term:
    """Replace the subterm at the given position with replacement."""
    if not position:
        return replacement
    if isinstance(t, App):
        idx = position[0]
        new_args = list(t.args)
        new_args[idx] = _replace_at_position(t.args[idx], position[1:], replacement)
        return App(t.op, tuple(new_args))
    raise ValueError(f"Invalid position {position} in term {t}")


def check_joinability(rs: RewriteSystem, cp: CriticalPair,
                      max_steps: int = 1000) -> bool:
    """Check if a critical pair is joinable.

    A critical pair (l, r) is joinable if nf(l) = nf(r).

    Corresponds to CriticalPair.Joinable in the Lean formalization.
    """
    try:
        nf_l, _ = rs.normal_form(cp.left_result, max_steps)
        nf_r, _ = rs.normal_form(cp.right_result, max_steps)
        return nf_l == nf_r
    except RuntimeError:
        return False  # Can't determine joinability if normalization doesn't terminate


# =============================================================================
# Algebra and Evaluation
# =============================================================================

class Algebra:
    """A Σ-algebra: a carrier set with operation interpretations.

    Corresponds to SigAlgebra in the Lean formalization.
    """

    def __init__(self, carrier: list, operations: dict[str, callable]):
        """
        Args:
            carrier: Elements of the algebra
            operations: Map from operation names to functions
        """
        self.carrier = carrier
        self.operations = operations

    def eval(self, t: Term, valuation: dict[str, object]) -> object:
        """Evaluate a term in this algebra under a valuation.

        Corresponds to eval in the Lean formalization.
        """
        if isinstance(t, Var):
            return valuation[t.name]
        elif isinstance(t, App):
            args = [self.eval(a, valuation) for a in t.args]
            return self.operations[t.op](*args)
        raise ValueError(f"Unknown term type: {type(t)}")


# =============================================================================
# Knuth-Bendix Completion (Simplified)
# =============================================================================

def knuth_bendix_completion(
    equations: list[tuple[Term, Term]],
    term_order: callable,
    max_iterations: int = 100
) -> Optional[list[RewriteRule]]:
    """Simplified Knuth-Bendix completion procedure.

    Attempts to transform a set of equations into a convergent rewrite system.

    Args:
        equations: List of (lhs, rhs) equation pairs
        term_order: Function (t1, t2) -> bool, True if t1 > t2
        max_iterations: Maximum completion iterations

    Returns:
        List of rewrite rules forming a convergent system, or None if
        completion fails.

    Corresponds to the completion procedure described in Section 5.2
    of the research paper.
    """
    # Step 1: Orient equations into rules
    rules = []
    for lhs, rhs in equations:
        if lhs == rhs:
            continue
        if term_order(lhs, rhs):
            rules.append(RewriteRule(lhs, rhs))
        elif term_order(rhs, lhs):
            rules.append(RewriteRule(rhs, lhs))
        else:
            return None  # Cannot orient

    # Step 2: Iterate
    for iteration in range(max_iterations):
        rs = RewriteSystem(rules)
        cps = compute_critical_pairs(rules)

        new_rules = []
        all_joinable = True
        for cp in cps:
            try:
                nf_l, _ = rs.normal_form(cp.left_result, 1000)
                nf_r, _ = rs.normal_form(cp.right_result, 1000)
            except RuntimeError:
                return None

            if nf_l != nf_r:
                all_joinable = False
                if term_order(nf_l, nf_r):
                    new_rules.append(RewriteRule(nf_l, nf_r))
                elif term_order(nf_r, nf_l):
                    new_rules.append(RewriteRule(nf_r, nf_l))
                else:
                    return None

        if all_joinable:
            return rules

        rules.extend(new_rules)

    return None  # Didn't converge


# =============================================================================
# Utility: Term Order (size-based with lexicographic tiebreaker)
# =============================================================================

def size_lex_order(t1: Term, t2: Term) -> bool:
    """A simple term order: larger size wins, with lexicographic tiebreaker."""
    s1, s2 = term_size(t1), term_size(t2)
    if s1 != s2:
        return s1 > s2
    return repr(t1) > repr(t2)


if __name__ == "__main__":
    # Example: Commutativity of addition
    x, y = Var('x'), Var('y')
    a, b, c = Var('a'), Var('b'), Var('c')

    # f(x, y) -> f(y, x) when x > y lexicographically
    rule = RewriteRule(
        App('f', (Var('x'), Var('y'))),
        App('f', (Var('y'), Var('x')))
    )
    print(f"Rule: {rule}")
    print(f"LHS vars: {term_vars(rule.lhs)}")
    print(f"RHS vars: {term_vars(rule.rhs)}")

    # Test matching
    t = App('f', (App('g', (a,)), b))
    sub = match_term(rule.lhs, t)
    print(f"\nMatching {rule.lhs} against {t}: {sub}")
    if sub:
        result = apply_subst(rule.rhs, sub)
        print(f"Result: {result}")

    # Test algebra evaluation
    alg = Algebra(
        carrier=list(range(10)),
        operations={'f': lambda x, y: x + y, 'g': lambda x: x * 2}
    )
    val = {'a': 3, 'b': 5}
    print(f"\neval({t}, {val}) = {alg.eval(t, val)}")

    # Test critical pairs
    rules = [
        RewriteRule(App('f', (App('f', (Var('x'), Var('y'))), Var('z'))),
                    App('f', (Var('x'), App('f', (Var('y'), Var('z')))))),
    ]
    cps = compute_critical_pairs(rules)
    print(f"\nCritical pairs for associativity: {len(cps)}")
    for cp in cps:
        print(f"  {cp}")
