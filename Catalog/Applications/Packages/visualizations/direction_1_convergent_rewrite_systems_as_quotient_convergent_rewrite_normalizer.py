"""
Algorithms for Convergent Rewrite Systems as Quotient Optimizers.

Implements the core algorithms from the research paper:
1. Term representation and evaluation
2. Rewrite rule application (top-level and subterm)
3. Iterative normalization with fuel
4. Convergence checking (heuristic)
5. Critical pair computation
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Optional
import random


# ---------------------------------------------------------------------------
# Term Representation
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Term:
    """A first-order term over a signature."""
    symbol: str
    children: tuple[Term, ...] = ()

    def size(self) -> int:
        """Number of nodes in the term tree."""
        return 1 + sum(c.size() for c in self.children)

    def depth(self) -> int:
        """Maximum depth of the term tree."""
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def subterms(self) -> list[Term]:
        """All subterms (including self)."""
        result = [self]
        for c in self.children:
            result.extend(c.subterms())
        return result

    def __repr__(self) -> str:
        if not self.children:
            return self.symbol
        args = ", ".join(repr(c) for c in self.children)
        return f"{self.symbol}({args})"


# ---------------------------------------------------------------------------
# Rewrite Rules
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class RewriteRule:
    """A rewrite rule lhs -> rhs."""
    lhs: Term
    rhs: Term

    def __repr__(self) -> str:
        return f"{self.lhs} → {self.rhs}"


def match_term(pattern: Term, target: Term) -> Optional[dict[str, Term]]:
    """
    Match a pattern against a target term, returning a substitution
    (variable name -> term) if successful, None otherwise.

    Variables are terms with no children whose symbol starts with '?'.
    """
    if not pattern.children and pattern.symbol.startswith("?"):
        return {pattern.symbol: target}

    if pattern.symbol != target.symbol:
        return None
    if len(pattern.children) != len(target.children):
        return None

    subst: dict[str, Term] = {}
    for pc, tc in zip(pattern.children, target.children):
        child_subst = match_term(pc, tc)
        if child_subst is None:
            return None
        for var, val in child_subst.items():
            if var in subst and subst[var] != val:
                return None
            subst[var] = val
    return subst


def apply_substitution(term: Term, subst: dict[str, Term]) -> Term:
    """Apply a substitution to a term."""
    if not term.children and term.symbol.startswith("?"):
        return subst.get(term.symbol, term)
    return Term(term.symbol, tuple(apply_substitution(c, subst) for c in term.children))


def apply_rule_top(rule: RewriteRule, term: Term) -> Optional[Term]:
    """Try to apply a rule at the top level."""
    subst = match_term(rule.lhs, term)
    if subst is not None:
        return apply_substitution(rule.rhs, subst)
    return None


def apply_rule_anywhere(rule: RewriteRule, term: Term) -> Optional[Term]:
    """Try to apply a rule at any position (leftmost-outermost)."""
    # Try at top level first
    result = apply_rule_top(rule, term)
    if result is not None:
        return result

    # Try in children
    for i, child in enumerate(term.children):
        result = apply_rule_anywhere(rule, child)
        if result is not None:
            new_children = list(term.children)
            new_children[i] = result
            return Term(term.symbol, tuple(new_children))

    return None


# ---------------------------------------------------------------------------
# Normalization
# ---------------------------------------------------------------------------

def normalize(rules: list[RewriteRule], term: Term, fuel: int = 1000) -> tuple[Term, int]:
    """
    Normalize a term by repeatedly applying rules.

    Returns (normal_form, steps_taken).

    Complexity: O(fuel * |rules| * |term|) per normalization.
    """
    current = term
    steps = 0

    for _ in range(fuel):
        applied = False
        for rule in rules:
            result = apply_rule_anywhere(rule, current)
            if result is not None:
                current = result
                steps += 1
                applied = True
                break
        if not applied:
            break

    return current, steps


def is_normal_form(rules: list[RewriteRule], term: Term) -> bool:
    """Check if no rule applies to the term."""
    for rule in rules:
        if apply_rule_anywhere(rule, term) is not None:
            return False
    return True


# ---------------------------------------------------------------------------
# Algebra (Finite Model) Evaluation
# ---------------------------------------------------------------------------

@dataclass
class FiniteAlgebra:
    """
    A finite algebra: a carrier set {0, ..., n-1} with interpretations
    for each function symbol.
    """
    carrier_size: int
    interp: dict[str, Callable]

    def eval_term(self, term: Term, assignment: dict[str, int]) -> int:
        """Evaluate a term in this algebra under a variable assignment."""
        if not term.children:
            # Variable or constant
            if term.symbol in assignment:
                return assignment[term.symbol]
            # Treat as constant 0
            return 0

        func = self.interp.get(term.symbol)
        if func is None:
            return 0

        child_vals = [self.eval_term(c, assignment) for c in term.children]
        return func(*child_vals) % self.carrier_size


# ---------------------------------------------------------------------------
# Convergence Checking (Heuristic)
# ---------------------------------------------------------------------------

def check_termination_heuristic(
    rules: list[RewriteRule],
    sample_terms: list[Term],
    fuel: int = 100
) -> bool:
    """
    Heuristic termination check: normalize sample terms and check
    that normalization always terminates within fuel steps.
    """
    for term in sample_terms:
        _, steps = normalize(rules, term, fuel)
        if steps >= fuel:
            return False
    return True


def compute_critical_pairs(
    rules: list[RewriteRule]
) -> list[tuple[Term, Term]]:
    """
    Compute critical pairs from overlapping rule applications.

    For each pair of rules (r1, r2) and each non-variable position in r1.lhs
    where r2.lhs can unify, compute the resulting pair of terms.

    Simplified version: only checks top-level overlaps.
    """
    pairs = []
    for r1 in rules:
        for r2 in rules:
            # Check if r2 can apply to a subterm of r1.lhs
            for sub in r1.lhs.subterms():
                subst = match_term(r2.lhs, sub)
                if subst is not None:
                    # Found an overlap
                    t1 = apply_substitution(r1.rhs, subst)
                    t2_full = apply_substitution(r1.lhs, subst)
                    t2_result = apply_rule_anywhere(r2, t2_full)
                    if t2_result is not None and t1 != t2_result:
                        pairs.append((t1, t2_result))
    return pairs


def check_confluence_heuristic(
    rules: list[RewriteRule],
    sample_terms: list[Term],
    fuel: int = 100
) -> bool:
    """
    Heuristic confluence check: for each term, try different rule orderings
    and check that the resulting normal forms agree.
    """
    for term in sample_terms:
        nf1, _ = normalize(rules, term, fuel)
        # Try with reversed rule order
        nf2, _ = normalize(list(reversed(rules)), term, fuel)
        if nf1 != nf2:
            return False
    return True


# ---------------------------------------------------------------------------
# Random Generation
# ---------------------------------------------------------------------------

def random_term(
    symbols: list[tuple[str, int]],  # (name, arity)
    variables: list[str],
    max_depth: int
) -> Term:
    """Generate a random term up to given depth."""
    if max_depth <= 0 or random.random() < 0.3:
        # Leaf: variable
        return Term(random.choice(variables))

    # Choose a function symbol
    sym, arity = random.choice(symbols)
    if arity == 0:
        return Term(sym)

    children = tuple(
        random_term(symbols, variables, max_depth - 1)
        for _ in range(arity)
    )
    return Term(sym, children)


def random_finite_algebra(
    symbols: list[tuple[str, int]],
    carrier_size: int
) -> FiniteAlgebra:
    """Generate a random finite algebra."""
    interp: dict[str, Callable] = {}
    for sym, arity in symbols:
        if arity == 0:
            continue
        # Create a random lookup table
        table: dict[tuple[int, ...], int] = {}
        for args in _all_tuples(carrier_size, arity):
            table[args] = random.randint(0, carrier_size - 1)

        def make_func(t: dict[tuple[int, ...], int]) -> Callable:
            def f(*args: int) -> int:
                return t.get(args, 0)
            return f

        interp[sym] = make_func(table)

    return FiniteAlgebra(carrier_size, interp)


def _all_tuples(n: int, k: int) -> list[tuple[int, ...]]:
    """Generate all k-tuples from {0, ..., n-1}."""
    if k == 0:
        return [()]
    result = []
    for rest in _all_tuples(n, k - 1):
        for i in range(n):
            result.append(rest + (i,))
    return result


# ---------------------------------------------------------------------------
# Example Usage
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    # Commutative semiring rules on PolyTerm-like syntax
    x = Term("?x")
    y = Term("?y")
    z = Term("?z")

    rules = [
        # 0 + x -> x
        RewriteRule(Term("add", (Term("0"), x)), x),
        # x + 0 -> x
        RewriteRule(Term("add", (x, Term("0"))), x),
        # 1 * x -> x
        RewriteRule(Term("mul", (Term("1"), x)), x),
        # x * 1 -> x
        RewriteRule(Term("mul", (x, Term("1"))), x),
        # 0 * x -> 0
        RewriteRule(Term("mul", (Term("0"), x)), Term("0")),
        # x * 0 -> 0
        RewriteRule(Term("mul", (x, Term("0"))), Term("0")),
    ]

    # Example term: 0 + (1 * (a + 0))
    a = Term("a")
    t = Term("add", (Term("0"), Term("mul", (Term("1"), Term("add", (a, Term("0")))))))
    print(f"Original:    {t}")
    print(f"Size:        {t.size()}")

    nf, steps = normalize(rules, t)
    print(f"Normal form: {nf}")
    print(f"NF size:     {nf.size()}")
    print(f"Steps:       {steps}")
    print(f"Reduction:   {(1 - nf.size()/t.size())*100:.1f}%")
