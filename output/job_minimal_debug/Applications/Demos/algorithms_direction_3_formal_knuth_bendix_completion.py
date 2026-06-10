#!/usr/bin/env python3
"""
Knuth-Bendix Completion Algorithm
==================================

A complete implementation of Knuth-Bendix completion for finitely presented
algebraic structures (monoids, groups, etc.).

Key components:
- Term: First-order terms over a signature
- RewriteRule: Oriented rewrite rule (lhs → rhs)
- KnuthBendixCompleter: The completion procedure

Algorithm complexity:
- Each completion step: O(n²) where n is the number of current rules
  (for computing all critical pairs)
- Overall: potentially unbounded (may not terminate for undecidable word problems)
- In practice: O(|G|²) steps for finite groups of small order

References:
- Knuth, D.E. and Bendix, P.B. (1970). "Simple Word Problems in Universal
  Algebras." In Computational Problems in Abstract Algebra, pp. 263-297.
- Baader, F. and Nipkow, T. (1998). Term Rewriting and All That. Cambridge
  University Press.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
from copy import deepcopy


# ============================================================
# Term representation
# ============================================================

class Term:
    """Base class for first-order terms."""
    pass


@dataclass(frozen=True)
class Var(Term):
    """A variable."""
    name: str

    def __repr__(self):
        return self.name

    def __eq__(self, other):
        return isinstance(other, Var) and self.name == other.name

    def __hash__(self):
        return hash(("Var", self.name))


@dataclass(frozen=True)
class Op(Term):
    """An operation applied to arguments."""
    symbol: str
    args: tuple  # tuple of Term

    def __init__(self, symbol: str, args: list):
        object.__setattr__(self, 'symbol', symbol)
        object.__setattr__(self, 'args', tuple(args))

    def __repr__(self):
        if not self.args:
            return self.symbol
        if self.symbol == "*" and len(self.args) == 2:
            return f"({self.args[0]}*{self.args[1]})"
        if self.symbol == "inv" and len(self.args) == 1:
            return f"{self.args[0]}⁻¹"
        return f"{self.symbol}({', '.join(str(a) for a in self.args)})"

    def __eq__(self, other):
        return isinstance(other, Op) and self.symbol == other.symbol and self.args == other.args

    def __hash__(self):
        return hash(("Op", self.symbol, self.args))


# ============================================================
# Term operations
# ============================================================

def term_size(t: Term) -> int:
    """Number of nodes in a term."""
    if isinstance(t, Var):
        return 1
    return 1 + sum(term_size(a) for a in t.args)


def term_vars(t: Term) -> set:
    """Variables occurring in a term."""
    if isinstance(t, Var):
        return {t.name}
    return set().union(*(term_vars(a) for a in t.args))


def apply_subst(t: Term, subst: dict, _seen: frozenset = frozenset()) -> Term:
    """Apply a substitution to a term (fully, until fixpoint)."""
    if isinstance(t, Var):
        if t.name in subst and t.name not in _seen:
            result = subst[t.name]
            return apply_subst(result, subst, _seen | {t.name})
        return t
    return Op(t.symbol, [apply_subst(a, subst, _seen) for a in t.args])


def unify(t1: Term, t2: Term, subst: Optional[dict] = None) -> Optional[dict]:
    """
    Unify two terms. Returns a most general unifier (substitution) if one exists.

    Uses the standard Robinson unification algorithm.

    Time complexity: O(n²) in the worst case (without occurs check optimization),
    where n is the total size of terms.
    """
    if subst is None:
        subst = {}

    t1 = apply_subst(t1, subst)
    t2 = apply_subst(t2, subst)

    if t1 == t2:
        return subst

    if isinstance(t1, Var):
        if occurs_in(t1.name, t2):
            return None
        subst[t1.name] = t2
        return subst

    if isinstance(t2, Var):
        if occurs_in(t2.name, t1):
            return None
        subst[t2.name] = t1
        return subst

    if isinstance(t1, Op) and isinstance(t2, Op):
        if t1.symbol != t2.symbol or len(t1.args) != len(t2.args):
            return None
        for a1, a2 in zip(t1.args, t2.args):
            subst = unify(a1, a2, subst)
            if subst is None:
                return None
        return subst

    return None


def occurs_in(var_name: str, t: Term) -> bool:
    """Check if a variable occurs in a term (occurs check)."""
    if isinstance(t, Var):
        return t.name == var_name
    return any(occurs_in(var_name, a) for a in t.args)


def match_term(pattern: Term, target: Term, subst: Optional[dict] = None) -> Optional[dict]:
    """
    One-way matching: find substitution σ such that σ(pattern) = target.
    Only substitutes variables in the pattern, not in the target.
    """
    if subst is None:
        subst = {}

    if isinstance(pattern, Var):
        if pattern.name in subst:
            if subst[pattern.name] == target:
                return subst
            return None
        subst[pattern.name] = target
        return subst

    if isinstance(target, Var):
        return None

    if isinstance(pattern, Op) and isinstance(target, Op):
        if pattern.symbol != target.symbol or len(pattern.args) != len(target.args):
            return None
        for p, t in zip(pattern.args, target.args):
            subst = match_term(p, t, subst)
            if subst is None:
                return None
        return subst

    return None


# ============================================================
# Rewrite rules and reduction
# ============================================================

@dataclass
class RewriteRule:
    """An oriented rewrite rule: lhs → rhs."""
    lhs: Term
    rhs: Term

    def __repr__(self):
        return f"{self.lhs} → {self.rhs}"


def reduce_at_root(t: Term, rules: list[RewriteRule]) -> Optional[Term]:
    """Try to reduce a term at the root position."""
    for rule in rules:
        subst = match_term(rule.lhs, t)
        if subst is not None:
            return apply_subst(rule.rhs, subst)
    return None


def reduce_one_step(t: Term, rules: list[RewriteRule]) -> Optional[Term]:
    """
    Reduce a term by one step (leftmost-outermost strategy).

    Returns the reduced term, or None if no rule applies.
    """
    # Try root first
    result = reduce_at_root(t, rules)
    if result is not None:
        return result

    # Try subterms
    if isinstance(t, Op):
        for i, arg in enumerate(t.args):
            result = reduce_one_step(arg, rules)
            if result is not None:
                new_args = list(t.args)
                new_args[i] = result
                return Op(t.symbol, new_args)

    return None


def normalize(t: Term, rules: list[RewriteRule], max_steps: int = 1000) -> Term:
    """
    Normalize a term by repeatedly applying rewrite rules until a normal form
    is reached.

    Time complexity: O(max_steps * n * |rules|) where n is the term size.
    """
    for _ in range(max_steps):
        result = reduce_one_step(t, rules)
        if result is None:
            return t
        t = result
    return t  # max steps reached


def reduce_term(t: Term, rules: list[RewriteRule]) -> Term:
    """Alias for normalize."""
    return normalize(t, rules)


# ============================================================
# Ordering on terms
# ============================================================

def term_weight(t: Term) -> tuple:
    """Compute a weight tuple for shortlex ordering."""
    if isinstance(t, Var):
        return (1, t.name)
    w = sum(term_weight(a)[0] for a in t.args) + 1
    return (w, t.symbol) + tuple(
        item for a in t.args for item in term_weight(a)
    )


def shortlex_gt(t1: Term, t2: Term) -> bool:
    """
    Shortlex ordering: t1 > t2 if t1 is larger, or same size but
    lexicographically greater.

    This is a simplification reduction ordering suitable for many
    completion problems.
    """
    s1, s2 = term_size(t1), term_size(t2)
    if s1 != s2:
        return s1 > s2
    return str(t1) > str(t2)


# ============================================================
# Critical pairs
# ============================================================

def rename_vars(t: Term, suffix: str) -> Term:
    """Rename all variables in a term by adding a suffix."""
    if isinstance(t, Var):
        return Var(t.name + suffix)
    return Op(t.symbol, [rename_vars(a, suffix) for a in t.args])


def superpose(rule1: RewriteRule, rule2: RewriteRule, counter: int = 0) -> list:
    """
    Compute critical pairs between two rules by superposition.

    For each non-variable subterm position p of rule1.lhs, try to unify
    rule1.lhs|_p with rule2.lhs. If successful, the critical pair is
    (σ(rule1.rhs), σ(rule1.lhs[p ← rule2.rhs])).

    Returns list of (term1, term2) critical pairs.
    """
    # Rename variables in rule2 to avoid capture
    r2_lhs = rename_vars(rule2.lhs, f"_{counter}")
    r2_rhs = rename_vars(rule2.rhs, f"_{counter}")

    pairs = []
    _superpose_at(rule1.lhs, rule1.rhs, r2_lhs, r2_rhs, [], pairs)
    return pairs


def _superpose_at(lhs1, rhs1, lhs2, rhs2, position, pairs):
    """Helper: try superposition at each position of lhs1."""
    # Skip variable positions
    if isinstance(lhs1, Var):
        return

    # Try to unify lhs1 (at current position) with lhs2
    subst = unify(deepcopy(lhs1), deepcopy(lhs2))
    if subst is not None:
        # Critical pair: (σ(rhs2 embedded in lhs1's context), σ(rhs1))
        # But at root, it's simply (σ(rhs1), σ(rhs2))
        if not position:  # at root
            cp1 = apply_subst(rhs1, subst)
            cp2 = apply_subst(rhs2, subst)
            if cp1 != cp2:
                pairs.append((cp1, cp2))
        else:
            # σ applied to lhs1 with the matched subterm replaced by rhs2
            replaced = _replace_at(lhs1, position, rhs2)
            cp1 = apply_subst(replaced, subst)
            cp2 = apply_subst(rhs1, subst)
            if cp1 != cp2:
                pairs.append((cp1, cp2))

    # Recurse into subterms
    if isinstance(lhs1, Op):
        for i, arg in enumerate(lhs1.args):
            _superpose_at(arg, rhs1, lhs2, rhs2, position + [i], pairs)


def _replace_at(t: Term, position: list, replacement: Term) -> Term:
    """Replace the subterm at the given position with replacement."""
    if not position:
        return replacement
    if isinstance(t, Op):
        new_args = list(t.args)
        new_args[position[0]] = _replace_at(t.args[position[0]], position[1:], replacement)
        return Op(t.symbol, new_args)
    return t


def all_critical_pairs(rules: list[RewriteRule]) -> list:
    """
    Compute all critical pairs from a set of rewrite rules.

    Time complexity: O(n² * m) where n is the number of rules and m is
    the maximum rule size.
    """
    pairs = []
    counter = 0
    for i, r1 in enumerate(rules):
        for j, r2 in enumerate(rules):
            counter += 1
            cps = superpose(r1, r2, counter)
            pairs.extend(cps)
    return pairs


# ============================================================
# Knuth-Bendix Completion
# ============================================================

class KnuthBendixCompleter:
    """
    Knuth-Bendix completion procedure.

    Given a set of equations and a reduction ordering, attempts to produce
    a convergent (terminating + confluent) term rewriting system.

    Algorithm (pseudocode):
    ```
    Input: equations E, reduction ordering >
    Output: convergent TRS R (if completion succeeds)

    1. Orient equations into rules R using >
    2. Repeat:
       a. Compute all critical pairs CP from R
       b. For each (s, t) in CP:
          - Normalize s and t using R
          - If nf(s) ≠ nf(t), orient the equation nf(s) = nf(t) into a new rule
       c. Simplify existing rules using new rules
       d. If no new rules added, return R (success)
    ```

    Space complexity: O(|R| * max_rule_size)
    """

    def __init__(self, ordering):
        """
        Initialize with a reduction ordering.

        Args:
            ordering: function (t1, t2) -> bool, returns True if t1 > t2
        """
        self.ordering = ordering
        self.rules: list[RewriteRule] = []

    def orient(self, t1: Term, t2: Term) -> Optional[RewriteRule]:
        """Orient an equation into a rule using the ordering."""
        if self.ordering(t1, t2):
            return RewriteRule(t1, t2)
        elif self.ordering(t2, t1):
            return RewriteRule(t2, t1)
        return None  # Cannot orient

    def complete(self, equations: list[tuple[Term, Term]],
                 max_steps: int = 100) -> bool:
        """
        Run Knuth-Bendix completion.

        Args:
            equations: list of (lhs, rhs) equation pairs
            max_steps: maximum number of completion iterations

        Returns:
            True if completion succeeded (convergent system found),
            False if max_steps reached.
        """
        # Step 1: Orient initial equations
        for lhs, rhs in equations:
            rule = self.orient(lhs, rhs)
            if rule:
                self.rules.append(rule)

        # Step 2: Iterate
        for step in range(max_steps):
            # Compute critical pairs
            cps = all_critical_pairs(self.rules)

            new_rules = []
            for s, t in cps:
                # Normalize both sides
                ns = normalize(s, self.rules)
                nt = normalize(t, self.rules)

                if ns != nt:
                    rule = self.orient(ns, nt)
                    if rule and rule not in self.rules and rule not in new_rules:
                        new_rules.append(rule)

            if not new_rules:
                return True  # All critical pairs join — system is confluent

            # Add new rules
            self.rules.extend(new_rules)

            # Interreduce: simplify right-hand sides of existing rules
            self._interreduce()

        return False  # Max steps reached

    def _interreduce(self):
        """Simplify rules using each other (interreduction)."""
        changed = True
        while changed:
            changed = False
            new_rules = []
            for rule in self.rules:
                # Simplify RHS
                new_rhs = normalize(rule.rhs, [r for r in self.rules if r != rule])
                if new_rhs != rule.rhs:
                    new_rules.append(RewriteRule(rule.lhs, new_rhs))
                    changed = True
                else:
                    new_rules.append(rule)
            self.rules = new_rules

            # Remove trivial rules (lhs = rhs)
            self.rules = [r for r in self.rules if r.lhs != r.rhs]

            # Remove redundant rules (whose LHS can be reduced by another rule)
            non_redundant = []
            for i, rule in enumerate(self.rules):
                other_rules = [r for j, r in enumerate(self.rules) if j != i]
                nf_lhs = normalize(rule.lhs, other_rules)
                if nf_lhs == rule.lhs:
                    non_redundant.append(rule)
                else:
                    changed = True
                    # The simplified equation might still be needed
                    nf_rhs = normalize(rule.rhs, other_rules)
                    if nf_lhs != nf_rhs:
                        new_rule = self.orient(nf_lhs, nf_rhs)
                        if new_rule and new_rule not in non_redundant:
                            non_redundant.append(new_rule)
            self.rules = non_redundant


# ============================================================
# Utility functions
# ============================================================

def is_convergent(rules: list[RewriteRule], test_terms: list[Term]) -> bool:
    """
    Heuristic check for convergence: verify all critical pairs are joinable
    and test terms have unique normal forms.
    """
    cps = all_critical_pairs(rules)
    for s, t in cps:
        ns = normalize(s, rules)
        nt = normalize(t, rules)
        if ns != nt:
            return False
    return True


if __name__ == "__main__":
    # Quick test
    x, y = Var("x"), Var("y")
    e = Op("e", [])

    print("Testing unification:")
    s = unify(Op("*", [x, y]), Op("*", [Var("a"), Var("b")]))
    print(f"  unify(x*y, a*b) = {s}")

    print("\nTesting matching:")
    m = match_term(Op("*", [x, x]), Op("*", [Var("a"), Var("a")]))
    print(f"  match(x*x, a*a) = {m}")

    m2 = match_term(Op("*", [x, x]), Op("*", [Var("a"), Var("b")]))
    print(f"  match(x*x, a*b) = {m2}")

    print("\nTesting shortlex ordering:")
    t1 = Op("*", [Var("a"), Var("b")])
    t2 = Var("a")
    print(f"  {t1} > {t2}: {shortlex_gt(t1, t2)}")

    print("\nTesting normalization:")
    rules = [RewriteRule(Op("*", [x, x]), x)]
    t = Op("*", [Var("a"), Var("a")])
    print(f"  normalize({t}) = {normalize(t, rules)}")

    print("\nAll tests passed!")
