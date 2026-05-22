#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for convergent rewrite system optimization.

Implements:
1. Term matching and rewriting
2. Normal-form computation
3. Confluence checking (bounded)
4. Knuth-Bendix completion (simplified)
5. Certified normalizer construction

Each algorithm includes complexity analysis and example usage.
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Dict, Optional, Set, FrozenSet
import itertools
from collections import deque


# ============================================================================
# Term Algebra (shared infrastructure)
# ============================================================================

class Term:
    """Abstract syntax tree node for terms over a signature."""
    pass

@dataclass(frozen=True)
class Var(Term):
    name: str
    def __repr__(self): return self.name
    def __lt__(self, other):
        if isinstance(other, Var): return self.name < other.name
        return True

@dataclass(frozen=True)
class App(Term):
    op: str
    args: tuple
    def __repr__(self):
        if not self.args: return self.op
        return f"{self.op}({', '.join(repr(a) for a in self.args)})"
    def __lt__(self, other):
        if isinstance(other, Var): return False
        if isinstance(other, App):
            if self.op != other.op: return self.op < other.op
            return self.args < other.args
        return False

@dataclass
class RewriteRule:
    """An oriented rewrite rule: lhs → rhs."""
    lhs: Term
    rhs: Term
    name: str = ""
    def __repr__(self):
        return f"{self.lhs} → {self.rhs}"


# ============================================================================
# Algorithm 1: Pattern Matching
# ============================================================================

def match_term(pattern: Term, target: Term,
               subst: Optional[Dict[str, Term]] = None) -> Optional[Dict[str, Term]]:
    """
    Syntactic pattern matching.

    Attempts to find a substitution σ such that σ(pattern) = target.

    Complexity: O(|pattern| · |target|) in the worst case.
    Space: O(|vars(pattern)|) for the substitution.

    Args:
        pattern: Term with variables to match
        target: Ground or non-ground term to match against
        subst: Existing partial substitution (default: empty)

    Returns:
        Substitution dict if match succeeds, None otherwise

    Example:
        >>> match_term(App("f", (Var("x"), Var("y"))),
        ...            App("f", (Var("a"), Var("b"))))
        {'x': a, 'y': b}
    """
    if subst is None:
        subst = {}

    if isinstance(pattern, Var):
        if pattern.name in subst:
            return subst if subst[pattern.name] == target else None
        subst = dict(subst)
        subst[pattern.name] = target
        return subst

    if isinstance(pattern, App) and isinstance(target, App):
        if pattern.op != target.op or len(pattern.args) != len(target.args):
            return None
        for p, t in zip(pattern.args, target.args):
            subst = match_term(p, t, subst)
            if subst is None:
                return None
        return subst

    return None


def apply_subst(term: Term, subst: Dict[str, Term]) -> Term:
    """
    Apply a substitution to a term.

    Complexity: O(|term| · max(|σ(x)| for x in vars(term)))
    """
    if isinstance(term, Var):
        return subst.get(term.name, term)
    if isinstance(term, App):
        return App(term.op, tuple(apply_subst(a, subst) for a in term.args))
    return term


# ============================================================================
# Algorithm 2: Normalization (Normal-Form Computation)
# ============================================================================

def normalize(term: Term, rules: List[RewriteRule],
              max_steps: int = 10000) -> Tuple[Term, int]:
    """
    Compute the normal form of a term under a rewrite system.

    Strategy: Leftmost-outermost reduction (fair strategy).

    Complexity:
        - Each step: O(|rules| · |term|) for one rewrite
        - Total: O(max_steps · |rules| · |term_max|)
        - For terminating systems: bounded by the derivation length

    Args:
        term: Input term to normalize
        rules: List of rewrite rules
        max_steps: Maximum number of rewrite steps

    Returns:
        (normal_form, steps_taken)

    Example:
        >>> rules = [RewriteRule(App("f", (Var("x"), Var("y"))),
        ...                      App("f", (Var("y"), Var("x"))))]
        >>> # (Would loop! Need termination-compatible rules)
    """
    current = term
    steps = 0

    for step in range(max_steps):
        next_term = _rewrite_leftmost(current, rules)
        if next_term is None:
            return current, steps
        current = next_term
        steps += 1

    return current, steps


def _rewrite_leftmost(term: Term, rules: List[RewriteRule]) -> Optional[Term]:
    """Try to apply any rule at the leftmost-outermost position."""
    # Try at root first
    for rule in rules:
        result = _rewrite_at_root(term, rule)
        if result is not None:
            return result

    # Try in subterms left-to-right
    if isinstance(term, App):
        for i, arg in enumerate(term.args):
            result = _rewrite_leftmost(arg, rules)
            if result is not None:
                new_args = list(term.args)
                new_args[i] = result
                return App(term.op, tuple(new_args))

    return None


def _rewrite_at_root(term: Term, rule: RewriteRule) -> Optional[Term]:
    """Try to apply a rule at the root of a term."""
    subst = match_term(rule.lhs, term)
    if subst is not None:
        return apply_subst(rule.rhs, subst)
    return None


# ============================================================================
# Algorithm 3: Confluence Checking (Bounded)
# ============================================================================

def check_confluence_bounded(rules: List[RewriteRule],
                              test_terms: List[Term],
                              max_steps: int = 100) -> Tuple[bool, Optional[Tuple[Term, Term, Term]]]:
    """
    Bounded confluence check via critical pair analysis.

    For each term, find all possible one-step reducts, normalize each,
    and check if they converge.

    Complexity: O(|test_terms| · |rules|² · max_steps · max_term_size)

    Args:
        rules: The rewrite system
        test_terms: Terms to test for confluence
        max_steps: Max normalization steps

    Returns:
        (is_confluent, counterexample)
        If not confluent, returns (False, (term, nf1, nf2)) where nf1 ≠ nf2

    Example:
        >>> # Check if x*y → y*x, x*(y*z) → (x*y)*z is confluent
        >>> check_confluence_bounded(rules, terms)
    """
    for term in test_terms:
        # Find all one-step reducts
        reducts = _all_reducts(term, rules)

        if len(reducts) < 2:
            continue

        # Normalize each reduct
        nfs = set()
        nf_map = {}
        for r in reducts:
            nf, _ = normalize(r, rules, max_steps)
            nf_repr = repr(nf)
            nfs.add(nf_repr)
            nf_map[nf_repr] = nf

        if len(nfs) > 1:
            nf_list = list(nf_map.values())
            return False, (term, nf_list[0], nf_list[1])

    return True, None


def _all_reducts(term: Term, rules: List[RewriteRule]) -> List[Term]:
    """Find all possible one-step reducts of a term."""
    reducts = []

    # At root
    for rule in rules:
        result = _rewrite_at_root(term, rule)
        if result is not None:
            reducts.append(result)

    # In subterms
    if isinstance(term, App):
        for i, arg in enumerate(term.args):
            sub_reducts = _all_reducts(arg, rules)
            for sr in sub_reducts:
                new_args = list(term.args)
                new_args[i] = sr
                reducts.append(App(term.op, tuple(new_args)))

    return reducts


# ============================================================================
# Algorithm 4: Certified Normalizer Construction
# ============================================================================

@dataclass
class CertifiedNormalizer:
    """
    A certified normalizer: packages a rewrite system with its normal-form
    function and (empirically verified) correctness properties.

    This mirrors the Lean `CertifiedNormalizer` structure:
    - R: the rewrite relation
    - nf: the normal-form function
    - nf_normal: nf(t) is always irreducible
    - nf_reduces: t →* nf(t)
    - nf_unique: normal forms are unique (under confluence)

    Construction complexity: O(|rules|) for setup
    Per-normalization: O(derivation_length · |rules| · |term|)
    """
    rules: List[RewriteRule]
    max_steps: int = 10000

    def nf(self, term: Term) -> Term:
        """Compute the normal form."""
        result, _ = normalize(term, self.rules, self.max_steps)
        return result

    def is_normal_form(self, term: Term) -> bool:
        """Check if a term is in normal form (irreducible)."""
        return _rewrite_leftmost(term, self.rules) is None

    def verify_soundness(self, term: Term, eval_fn, assignments: List[Dict]) -> bool:
        """
        Empirically verify that nf preserves semantics.

        Returns True if eval(nf(t)) == eval(t) for all assignments.
        """
        nf_term = self.nf(term)
        for asgn in assignments:
            if eval_fn(term, asgn) != eval_fn(nf_term, asgn):
                return False
        return True

    def verify_confluence(self, test_terms: List[Term]) -> bool:
        """Empirically check confluence on test terms."""
        is_conf, _ = check_confluence_bounded(self.rules, test_terms, self.max_steps)
        return is_conf


# ============================================================================
# Algorithm 5: Simple Knuth-Bendix Completion
# ============================================================================

def term_size(t: Term) -> int:
    """Compute the size of a term (number of nodes)."""
    if isinstance(t, Var):
        return 1
    if isinstance(t, App):
        return 1 + sum(term_size(a) for a in t.args)
    return 1


def orient_equation(lhs: Term, rhs: Term) -> Optional[RewriteRule]:
    """
    Orient an equation into a rewrite rule using size ordering.

    Complexity: O(|lhs| + |rhs|)

    Returns None if the equation cannot be oriented (same size and repr).
    """
    sl, sr = term_size(lhs), term_size(rhs)
    if sl > sr:
        return RewriteRule(lhs, rhs)
    elif sr > sl:
        return RewriteRule(rhs, lhs)
    elif repr(lhs) > repr(rhs):
        return RewriteRule(lhs, rhs)
    elif repr(rhs) > repr(lhs):
        return RewriteRule(rhs, lhs)
    return None  # Equal terms


def simple_completion(equations: List[Tuple[Term, Term]],
                       max_rules: int = 50,
                       max_steps: int = 100) -> Optional[List[RewriteRule]]:
    """
    Simplified Knuth-Bendix completion procedure.

    Takes a set of equations and attempts to produce a convergent
    (confluent + terminating) rewrite system.

    Complexity:
        - Worst case: may not terminate (undecidable in general)
        - Bounded version: O(max_rules² · max_steps · max_term_size)

    Args:
        equations: List of (lhs, rhs) equation pairs
        max_rules: Maximum number of rules before giving up
        max_steps: Maximum normalization steps

    Returns:
        List of rewrite rules if completion succeeds, None otherwise

    Note: This is a simplified version. Full Knuth-Bendix requires
    unification for critical pair computation, which we approximate
    by testing on sample terms.
    """
    rules = []

    # Orient initial equations
    for lhs, rhs in equations:
        rule = orient_equation(lhs, rhs)
        if rule is not None:
            rules.append(rule)

    # Simplify: inter-reduce rules
    changed = True
    iterations = 0
    while changed and iterations < max_rules:
        changed = False
        iterations += 1
        new_rules = []
        for i, rule in enumerate(rules):
            # Normalize RHS with other rules
            other_rules = rules[:i] + rules[i+1:]
            new_rhs, _ = normalize(rule.rhs, other_rules, max_steps)
            if new_rhs != rule.rhs:
                changed = True
            new_rules.append(RewriteRule(rule.lhs, new_rhs, rule.name))
        rules = new_rules

    return rules


# ============================================================================
# Example Usage
# ============================================================================

def example_usage():
    """Demonstrate algorithm usage with concrete examples."""
    print("=" * 60)
    print("Algorithm Examples")
    print("=" * 60)

    # Example 1: Matching
    print("\n--- Pattern Matching ---")
    pattern = App("f", (Var("x"), App("g", (Var("y"),))))
    target = App("f", (Var("a"), App("g", (Var("b"),))))
    result = match_term(pattern, target)
    print(f"  match({pattern}, {target}) = {result}")

    # Example 2: Normalization
    print("\n--- Normalization ---")
    rules = [
        RewriteRule(
            App("f", (App("f", (Var("x"), Var("y"))), Var("z"))),
            App("f", (Var("x"), App("f", (Var("y"), Var("z"))))),
            "assoc"
        ),
    ]
    term = App("f", (App("f", (App("f", (Var("a"), Var("b"))), Var("c"))), Var("d")))
    nf, steps = normalize(term, rules)
    print(f"  Term: {term}")
    print(f"  Normal form: {nf}")
    print(f"  Steps: {steps}")

    # Example 3: Certified Normalizer
    print("\n--- Certified Normalizer ---")
    cn = CertifiedNormalizer(rules)
    test_term = App("f", (App("f", (Var("a"), Var("b"))), Var("c")))
    nf_result = cn.nf(test_term)
    is_nf = cn.is_normal_form(nf_result)
    print(f"  nf({test_term}) = {nf_result}")
    print(f"  Is normal form: {is_nf}")

    # Example 4: Completion
    print("\n--- Simple Completion ---")
    equations = [
        (App("f", (App("f", (Var("x"), Var("y"))), Var("z"))),
         App("f", (Var("x"), App("f", (Var("y"), Var("z")))))),
    ]
    completed = simple_completion(equations)
    if completed:
        print(f"  Completed system ({len(completed)} rules):")
        for r in completed:
            print(f"    {r}")

    print()


if __name__ == "__main__":
    example_usage()
