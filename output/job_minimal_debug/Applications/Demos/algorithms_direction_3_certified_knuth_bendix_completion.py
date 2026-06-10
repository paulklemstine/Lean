"""
Knuth-Bendix Completion Algorithm — Core Implementation

This module implements the Knuth-Bendix completion procedure for
equational theories, producing convergent term rewrite systems.

The algorithm takes a set of equations and a reduction ordering,
and attempts to produce a confluent, terminating rewrite system
whose equational theory matches the input.

References:
    Knuth, D. E. & Bendix, P. B. (1970). Simple Word Problems in Universal Algebras.
    Baader, F. & Nipkow, T. (1998). Term Rewriting and All That.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, Callable
from collections import defaultdict
import itertools


# ─────────────────────────────────────────────────────────────────────
#  Core Data Structures
# ─────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Term:
    """A first-order term: either a variable or a function application.
    
    Examples:
        >>> x = Term.var("x")
        >>> f_x = Term.fun("f", [x])
        >>> g_x_y = Term.fun("g", [x, Term.var("y")])
    """
    symbol: str
    args: tuple["Term", ...] = ()
    is_variable: bool = False

    @staticmethod
    def var(name: str) -> "Term":
        """Create a variable term."""
        return Term(symbol=name, is_variable=True)

    @staticmethod
    def fun(name: str, args: list["Term"]) -> "Term":
        """Create a function application term."""
        return Term(symbol=name, args=tuple(args), is_variable=False)

    def variables(self) -> set[str]:
        """Return the set of variable names occurring in the term."""
        if self.is_variable:
            return {self.symbol}
        result: set[str] = set()
        for arg in self.args:
            result |= arg.variables()
        return result

    def substitute(self, subst: dict[str, "Term"]) -> "Term":
        """Apply a substitution to this term."""
        if self.is_variable:
            return subst.get(self.symbol, self)
        return Term.fun(self.symbol, [a.substitute(subst) for a in self.args])

    def size(self) -> int:
        """Number of nodes in the term tree."""
        return 1 + sum(a.size() for a in self.args)

    def __str__(self) -> str:
        if self.is_variable:
            return self.symbol
        if not self.args:
            return self.symbol
        return f"{self.symbol}({', '.join(str(a) for a in self.args)})"

    def __repr__(self) -> str:
        return str(self)


@dataclass(frozen=True)
class Equation:
    """An unoriented equation between two terms."""
    lhs: Term
    rhs: Term

    def __str__(self) -> str:
        return f"{self.lhs} = {self.rhs}"


@dataclass(frozen=True)
class Rule:
    """An oriented rewrite rule: lhs → rhs."""
    lhs: Term
    rhs: Term

    def __str__(self) -> str:
        return f"{self.lhs} → {self.rhs}"


# ─────────────────────────────────────────────────────────────────────
#  Unification
# ─────────────────────────────────────────────────────────────────────

def occurs_check(var: str, term: Term) -> bool:
    """Check if variable `var` occurs in `term`."""
    if term.is_variable:
        return term.symbol == var
    return any(occurs_check(var, a) for a in term.args)


def unify(s: Term, t: Term) -> Optional[dict[str, Term]]:
    """Compute the most general unifier of two terms.
    
    Returns None if the terms are not unifiable.
    
    >>> x, y = Term.var("x"), Term.var("y")
    >>> f = lambda *a: Term.fun("f", list(a))
    >>> unify(f(x), f(y))
    {'x': y}
    """
    equations: list[tuple[Term, Term]] = [(s, t)]
    subst: dict[str, Term] = {}

    while equations:
        a, b = equations.pop()
        # Apply current substitution
        a = a.substitute(subst)
        b = b.substitute(subst)

        if a == b:
            continue
        if a.is_variable:
            if occurs_check(a.symbol, b):
                return None
            subst = {k: v.substitute({a.symbol: b}) for k, v in subst.items()}
            subst[a.symbol] = b
        elif b.is_variable:
            if occurs_check(b.symbol, a):
                return None
            subst = {k: v.substitute({b.symbol: a}) for k, v in subst.items()}
            subst[b.symbol] = a
        elif a.symbol == b.symbol and len(a.args) == len(b.args):
            equations.extend(zip(a.args, b.args))
        else:
            return None

    return subst


# ─────────────────────────────────────────────────────────────────────
#  Reduction Orderings
# ─────────────────────────────────────────────────────────────────────

def lpo(precedence: dict[str, int]) -> Callable[[Term, Term], bool]:
    """Create a Lexicographic Path Ordering (LPO) comparator.
    
    Returns a function `greater(s, t)` that returns True iff s > t in the LPO.
    
    Args:
        precedence: mapping from function symbols to precedence values (higher = greater)
    """
    def greater(s: Term, t: Term) -> bool:
        if t.is_variable:
            return not s.is_variable and t.symbol in s.variables()
        if s.is_variable:
            return False
        # Check if any argument of s is >= t
        for si in s.args:
            if si == t or greater(si, t):
                return True
        if s.symbol == t.symbol:
            # Lexicographic comparison of arguments
            for si, ti in zip(s.args, t.args):
                if si == ti:
                    continue
                if greater(si, ti):
                    return all(greater(s, tj) for tj in t.args if tj != ti)
                return False
        elif precedence.get(s.symbol, 0) > precedence.get(t.symbol, 0):
            return all(greater(s, tj) for tj in t.args)
        return False
    return greater


# ─────────────────────────────────────────────────────────────────────
#  Rewriting
# ─────────────────────────────────────────────────────────────────────

def match_term(pattern: Term, target: Term, subst: Optional[dict[str, Term]] = None) -> Optional[dict[str, Term]]:
    """One-way pattern matching: find substitution σ such that pattern[σ] = target."""
    if subst is None:
        subst = {}
    if pattern.is_variable:
        if pattern.symbol in subst:
            return subst if subst[pattern.symbol] == target else None
        subst = dict(subst)
        subst[pattern.symbol] = target
        return subst
    if target.is_variable:
        return None
    if pattern.symbol != target.symbol or len(pattern.args) != len(target.args):
        return None
    for pa, ta in zip(pattern.args, target.args):
        subst = match_term(pa, ta, subst)
        if subst is None:
            return None
    return subst


def rewrite_at_root(term: Term, rules: list[Rule]) -> Optional[Term]:
    """Try to rewrite `term` at the root using one of the rules."""
    for rule in rules:
        sigma = match_term(rule.lhs, term)
        if sigma is not None:
            return rule.rhs.substitute(sigma)
    return None


def rewrite_one_step(term: Term, rules: list[Rule]) -> Optional[Term]:
    """Apply one rewrite step at the leftmost-innermost position."""
    # Try subterms first (innermost)
    if not term.is_variable:
        for i, arg in enumerate(term.args):
            result = rewrite_one_step(arg, rules)
            if result is not None:
                new_args = list(term.args)
                new_args[i] = result
                return Term.fun(term.symbol, new_args)
    # Then try root
    return rewrite_at_root(term, rules)


def normalize(term: Term, rules: list[Rule], max_steps: int = 10000) -> Term:
    """Reduce a term to normal form using the given rules.
    
    Args:
        term: the term to normalize
        rules: rewrite rules to apply
        max_steps: maximum number of rewrite steps (prevents infinite loops)
    
    Returns:
        The normal form of the term
    """
    for _ in range(max_steps):
        result = rewrite_one_step(term, rules)
        if result is None:
            return term
        term = result
    return term  # max steps reached


# ─────────────────────────────────────────────────────────────────────
#  Critical Pairs
# ─────────────────────────────────────────────────────────────────────

def rename_variables(term: Term, suffix: str) -> Term:
    """Rename all variables in a term by adding a suffix."""
    if term.is_variable:
        return Term.var(term.symbol + suffix)
    return Term.fun(term.symbol, [rename_variables(a, suffix) for a in term.args])


def subterms_with_positions(term: Term) -> list[tuple[Term, list[int]]]:
    """Return all subterms with their positions (list of child indices)."""
    result = [(term, [])]
    if not term.is_variable:
        for i, arg in enumerate(term.args):
            for sub, pos in subterms_with_positions(arg):
                result.append((sub, [i] + pos))
    return result


def replace_at_position(term: Term, position: list[int], replacement: Term) -> Term:
    """Replace the subterm at the given position with the replacement."""
    if not position:
        return replacement
    if term.is_variable:
        raise ValueError("Invalid position for variable term")
    i = position[0]
    new_args = list(term.args)
    new_args[i] = replace_at_position(term.args[i], position[1:], replacement)
    return Term.fun(term.symbol, new_args)


def get_at_position(term: Term, position: list[int]) -> Term:
    """Get the subterm at the given position."""
    if not position:
        return term
    return get_at_position(term.args[position[0]], position[1:])


def critical_pairs(rule1: Rule, rule2: Rule) -> list[tuple[Term, Term]]:
    """Compute all critical pairs between two rules.
    
    A critical pair arises when the LHS of rule1 can be unified with
    a non-variable subterm of the LHS of rule2.
    
    Returns:
        List of (term1, term2) pairs that must be joinable for local confluence.
    """
    # Rename variables in rule1 to avoid capture
    r1_lhs = rename_variables(rule1.lhs, "'")
    r1_rhs = rename_variables(rule1.rhs, "'")

    pairs: list[tuple[Term, Term]] = []

    for subterm, pos in subterms_with_positions(rule2.lhs):
        if subterm.is_variable:
            continue
        # Skip the root position if rule1 == rule2 (trivial overlap)
        if rule1 == rule2 and not pos:
            continue

        sigma = unify(r1_lhs, subterm)
        if sigma is not None:
            # Critical pair: (rule2.rhs[σ], rule2.lhs[p ← rule1.rhs][σ])
            t1 = rule2.rhs.substitute(sigma)
            t2 = replace_at_position(rule2.lhs, pos, r1_rhs).substitute(sigma)
            pairs.append((t1, t2))

    return pairs


# ─────────────────────────────────────────────────────────────────────
#  Knuth-Bendix Completion
# ─────────────────────────────────────────────────────────────────────

@dataclass
class CompletionState:
    """State of the KB completion procedure."""
    rules: list[Rule] = field(default_factory=list)
    pending: list[Equation] = field(default_factory=list)
    step_count: int = 0

    def __str__(self) -> str:
        lines = [f"Step {self.step_count}:"]
        lines.append(f"  Rules ({len(self.rules)}):")
        for r in self.rules:
            lines.append(f"    {r}")
        lines.append(f"  Pending ({len(self.pending)}):")
        for e in self.pending:
            lines.append(f"    {e}")
        return "\n".join(lines)


@dataclass
class CompletionResult:
    """Result of KB completion."""
    terminated: bool
    rules: list[Rule]
    steps: int
    history: list[str]

    def is_convergent(self) -> bool:
        """Check if the resulting system is convergent (all critical pairs joinable)."""
        if not self.terminated:
            return False
        for r1 in self.rules:
            for r2 in self.rules:
                for cp1, cp2 in critical_pairs(r1, r2):
                    nf1 = normalize(cp1, self.rules)
                    nf2 = normalize(cp2, self.rules)
                    if nf1 != nf2:
                        return False
        return True


def kb_complete(
    equations: list[Equation],
    ordering: Callable[[Term, Term], bool],
    max_steps: int = 10000,
    verbose: bool = False,
) -> CompletionResult:
    """Run the Knuth-Bendix completion procedure.
    
    Args:
        equations: input equational axioms
        ordering: reduction ordering (greater function)
        max_steps: maximum number of completion steps
        verbose: if True, log each step
    
    Returns:
        CompletionResult with the final rewrite system
    
    Algorithm:
        1. Start with empty rules, all equations pending
        2. While pending equations exist:
           a. Pick an equation
           b. Normalize both sides with current rules
           c. If trivial (s = s), delete
           d. Orient into a rule (using the ordering)
           e. Compute critical pairs with all existing rules
           f. Add critical pairs to pending
        3. If pending is empty, the system is convergent
    """
    state = CompletionState(pending=list(equations))
    history: list[str] = []

    for step in range(max_steps):
        if not state.pending:
            return CompletionResult(
                terminated=True,
                rules=state.rules,
                steps=step,
                history=history,
            )

        eq = state.pending.pop(0)
        state.step_count = step

        # Normalize both sides
        lhs = normalize(eq.lhs, state.rules)
        rhs = normalize(eq.rhs, state.rules)

        if lhs == rhs:
            msg = f"Step {step}: DELETE {eq}"
            history.append(msg)
            if verbose:
                print(msg)
            continue

        # Orient the equation
        if ordering(lhs, rhs):
            new_rule = Rule(lhs, rhs)
        elif ordering(rhs, lhs):
            new_rule = Rule(rhs, lhs)
        else:
            msg = f"Step {step}: FAIL - cannot orient {lhs} = {rhs}"
            history.append(msg)
            if verbose:
                print(msg)
            return CompletionResult(
                terminated=False,
                rules=state.rules,
                steps=step,
                history=history,
            )

        msg = f"Step {step}: ORIENT {new_rule}"
        history.append(msg)
        if verbose:
            print(msg)

        # Compute critical pairs with all existing rules
        new_pairs: list[tuple[Term, Term]] = []
        for old_rule in state.rules:
            new_pairs.extend(critical_pairs(new_rule, old_rule))
            new_pairs.extend(critical_pairs(old_rule, new_rule))
        # Self-critical pairs
        new_pairs.extend(critical_pairs(new_rule, new_rule))

        state.rules.append(new_rule)

        # Add non-trivial critical pairs to pending
        for t1, t2 in new_pairs:
            nf1 = normalize(t1, state.rules)
            nf2 = normalize(t2, state.rules)
            if nf1 != nf2:
                state.pending.append(Equation(nf1, nf2))
                msg2 = f"  CP: {nf1} = {nf2}"
                history.append(msg2)
                if verbose:
                    print(msg2)

    return CompletionResult(
        terminated=False,
        rules=state.rules,
        steps=max_steps,
        history=history,
    )


# ─────────────────────────────────────────────────────────────────────
#  Convenience Constructors
# ─────────────────────────────────────────────────────────────────────

def make_var(name: str) -> Term:
    """Shorthand for creating a variable."""
    return Term.var(name)

def make_fun(name: str, *args: Term) -> Term:
    """Shorthand for creating a function application."""
    return Term.fun(name, list(args))


if __name__ == "__main__":
    # Quick test: complete the theory of a commutative, associative operation
    # with identity element
    x, y, z = make_var("x"), make_var("y"), make_var("z")
    e = make_fun("e")
    f = lambda a, b: make_fun("f", a, b)

    equations = [
        Equation(f(f(x, y), z), f(x, f(y, z))),  # associativity
        Equation(f(e, x), x),                       # left identity
        Equation(f(x, e), x),                       # right identity
    ]

    prec = {"f": 2, "e": 1}
    ordering = lpo(prec)

    result = kb_complete(equations, ordering, verbose=True)
    print(f"\nTerminated: {result.terminated}")
    print(f"Steps: {result.steps}")
    print(f"Rules: {len(result.rules)}")
    for r in result.rules:
        print(f"  {r}")
    print(f"Convergent: {result.is_convergent()}")
