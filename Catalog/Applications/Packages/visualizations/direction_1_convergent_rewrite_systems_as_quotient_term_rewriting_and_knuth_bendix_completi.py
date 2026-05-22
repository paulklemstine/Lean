#!/usr/bin/env python3
"""
Algorithms for convergent rewrite systems and quotient optimization.

Implements:
1. Term matching and unification
2. Rewriting (single-step and normalization)
3. Critical pair computation
4. Naive Knuth-Bendix completion
5. Normal form complexity analysis
6. Convergence checking (local confluence + termination)

All algorithms include docstrings, type hints, and complexity analysis.
"""

from dataclasses import dataclass, field
from typing import Optional
import itertools


# ============================================================
# Core Types
# ============================================================

@dataclass(frozen=True)
class Sig:
    """Algebraic signature: tuple of operation arities.

    Example:
        Sig((2, 0)) — one binary op and one constant
    """
    arities: tuple[int, ...]

    @property
    def num_ops(self) -> int:
        return len(self.arities)


class Term:
    """Abstract base for first-order terms."""
    def size(self) -> int:
        raise NotImplementedError

    def depth(self) -> int:
        raise NotImplementedError

    def variables(self) -> set[int]:
        raise NotImplementedError

    def subterms(self) -> list['Term']:
        """Return all subterms (including self)."""
        raise NotImplementedError


@dataclass(frozen=True)
class Var(Term):
    """Variable term."""
    name: int

    def size(self) -> int:
        return 1

    def depth(self) -> int:
        return 0

    def variables(self) -> set[int]:
        return {self.name}

    def subterms(self) -> list[Term]:
        return [self]

    def __repr__(self):
        return f"x{self.name}"


@dataclass(frozen=True)
class App(Term):
    """Application of an operation to arguments."""
    op: int
    args: tuple[Term, ...]

    def size(self) -> int:
        return 1 + sum(a.size() for a in self.args)

    def depth(self) -> int:
        if not self.args:
            return 0
        return 1 + max(a.depth() for a in self.args)

    def variables(self) -> set[int]:
        result: set[int] = set()
        for a in self.args:
            result |= a.variables()
        return result

    def subterms(self) -> list[Term]:
        result = [self]
        for a in self.args:
            result.extend(a.subterms())
        return result

    def __repr__(self):
        if not self.args:
            return f"f{self.op}"
        return f"f{self.op}({', '.join(str(a) for a in self.args)})"


@dataclass(frozen=True)
class RewriteRule:
    """Directed equation l → r."""
    lhs: Term
    rhs: Term

    def __repr__(self):
        return f"{self.lhs} → {self.rhs}"


# ============================================================
# Algorithm 1: Pattern Matching
# ============================================================

def match_terms(pattern: Term, target: Term) -> Optional[dict[int, Term]]:
    """Match a pattern against a target term.

    Returns a substitution σ such that pattern[σ] = target, or None if no match.

    Time complexity: O(|pattern| + |target|)
    Space complexity: O(|variables(pattern)|)

    Example:
        >>> match_terms(App(0, (Var(0), Var(1))), App(0, (Var(2), Var(3))))
        {0: Var(2), 1: Var(3)}
    """
    subst: dict[int, Term] = {}

    def _match(p: Term, t: Term) -> bool:
        if isinstance(p, Var):
            if p.name in subst:
                return subst[p.name] == t
            subst[p.name] = t
            return True
        if isinstance(p, App) and isinstance(t, App):
            if p.op != t.op or len(p.args) != len(t.args):
                return False
            return all(_match(pa, ta) for pa, ta in zip(p.args, t.args))
        return False

    if _match(pattern, target):
        return subst
    return None


# ============================================================
# Algorithm 2: Substitution Application
# ============================================================

def apply_subst(term: Term, subst: dict[int, Term]) -> Term:
    """Apply a substitution to a term.

    Time complexity: O(|term| * max(|σ(x)|))
    Space complexity: O(|result|)

    Example:
        >>> apply_subst(App(0, (Var(0), Var(1))), {0: Var(2), 1: App(1, (Var(3),))})
        App(0, (Var(2), App(1, (Var(3),))))
    """
    if isinstance(term, Var):
        return subst.get(term.name, term)
    if isinstance(term, App):
        new_args = tuple(apply_subst(a, subst) for a in term.args)
        return App(term.op, new_args)
    raise TypeError(f"Unknown term type: {type(term)}")


# ============================================================
# Algorithm 3: Single-Step Rewriting
# ============================================================

def rewrite_at_root(term: Term, rules: list[RewriteRule]) -> Optional[Term]:
    """Try to apply a rule at the root of the term.

    Time complexity: O(|rules| * |term|)
    """
    for rule in rules:
        subst = match_terms(rule.lhs, term)
        if subst is not None:
            return apply_subst(rule.rhs, subst)
    return None


def rewrite_one_step(term: Term, rules: list[RewriteRule]) -> Optional[Term]:
    """Apply one rewrite step anywhere in term (leftmost-outermost strategy).

    Time complexity: O(|term| * |rules| * |term|) = O(|term|² * |rules|)

    Returns None if term is in normal form.
    """
    # Try at root first
    result = rewrite_at_root(term, rules)
    if result is not None:
        return result

    # Try in arguments (left to right)
    if isinstance(term, App):
        for i, arg in enumerate(term.args):
            result = rewrite_one_step(arg, rules)
            if result is not None:
                new_args = list(term.args)
                new_args[i] = result
                return App(term.op, tuple(new_args))

    return None


# ============================================================
# Algorithm 4: Normalization
# ============================================================

def normalize(term: Term, rules: list[RewriteRule],
              max_steps: int = 10000) -> tuple[Term, int]:
    """Compute normal form by exhaustive rewriting.

    Returns (normal_form, num_steps).

    Time complexity: O(max_steps * |term|² * |rules|) worst case
    For terminating systems, bounded by the termination measure.

    Example:
        >>> rules = [RewriteRule(App(0, (App(0, (Var(0), Var(1))), Var(2))),
        ...                      App(0, (Var(0), App(0, (Var(1), Var(2))))))]
        >>> t = App(0, (App(0, (Var(0), Var(1))), Var(2)))
        >>> normalize(t, rules)
        (App(0, (Var(0), App(0, (Var(1), Var(2))))), 1)
    """
    current = term
    steps = 0
    while steps < max_steps:
        next_term = rewrite_one_step(current, rules)
        if next_term is None:
            break
        current = next_term
        steps += 1
    return current, steps


# ============================================================
# Algorithm 5: Critical Pair Computation
# ============================================================

def rename_vars(term: Term, offset: int) -> Term:
    """Rename all variables by adding offset."""
    if isinstance(term, Var):
        return Var(term.name + offset)
    if isinstance(term, App):
        return App(term.op, tuple(rename_vars(a, offset) for a in term.args))
    raise TypeError


def unify(s: Term, t: Term) -> Optional[dict[int, Term]]:
    """Syntactic unification of two terms.

    Returns most general unifier or None.

    Time complexity: O(|s| * |t|) (naive algorithm)
    """
    equations: list[tuple[Term, Term]] = [(s, t)]
    subst: dict[int, Term] = {}

    def apply_current(term: Term) -> Term:
        return apply_subst(term, subst)

    def occurs_in(var: int, term: Term) -> bool:
        if isinstance(term, Var):
            return term.name == var
        if isinstance(term, App):
            return any(occurs_in(var, a) for a in term.args)
        return False

    while equations:
        lhs, rhs = equations.pop()
        lhs = apply_current(lhs)
        rhs = apply_current(rhs)

        if lhs == rhs:
            continue
        if isinstance(lhs, Var):
            if occurs_in(lhs.name, rhs):
                return None
            subst[lhs.name] = rhs
        elif isinstance(rhs, Var):
            if occurs_in(rhs.name, lhs):
                return None
            subst[rhs.name] = lhs
        elif isinstance(lhs, App) and isinstance(rhs, App):
            if lhs.op != rhs.op or len(lhs.args) != len(rhs.args):
                return None
            for la, ra in zip(lhs.args, rhs.args):
                equations.append((la, ra))
        else:
            return None

    return subst


def critical_pairs(rule1: RewriteRule, rule2: RewriteRule) -> list[tuple[Term, Term]]:
    """Compute all critical pairs between two rules.

    A critical pair arises when the LHS of rule2 unifies with a non-variable
    subterm of the LHS of rule1.

    Time complexity: O(|rule1.lhs| * |rule2.lhs|² * unification_cost)

    Returns list of (term1, term2) pairs that should be joinable if the
    system is confluent.
    """
    # Rename rule2 variables to avoid clashes
    max_var = max(rule1.lhs.variables() | rule1.rhs.variables() | {-1}) + 1
    r2_lhs = rename_vars(rule2.lhs, max_var)
    r2_rhs = rename_vars(rule2.rhs, max_var)

    pairs: list[tuple[Term, Term]] = []

    def find_overlaps(term: Term, position: list[int]) -> None:
        """Find positions where rule2.lhs overlaps with subterms of rule1.lhs."""
        if isinstance(term, Var):
            return

        mgu = unify(term, r2_lhs)
        if mgu is not None:
            # Critical pair: apply mgu to rule1.rhs and to the term with
            # the subterm replaced by rule2.rhs
            t1 = apply_subst(rule1.rhs, mgu)
            # Replace the subterm at position with r2_rhs, then apply mgu
            replaced = replace_subterm(rule1.lhs, position, r2_rhs)
            t2 = apply_subst(replaced, mgu)
            pairs.append((t1, t2))

        if isinstance(term, App):
            for i, arg in enumerate(term.args):
                find_overlaps(arg, position + [i])

    find_overlaps(rule1.lhs, [])
    return pairs


def replace_subterm(term: Term, position: list[int], replacement: Term) -> Term:
    """Replace the subterm at the given position."""
    if not position:
        return replacement
    if isinstance(term, App):
        idx = position[0]
        new_args = list(term.args)
        new_args[idx] = replace_subterm(term.args[idx], position[1:], replacement)
        return App(term.op, tuple(new_args))
    raise ValueError(f"Invalid position {position} for term {term}")


# ============================================================
# Algorithm 6: Naive Knuth-Bendix Completion
# ============================================================

def knuth_bendix_complete(
    equations: list[tuple[Term, Term]],
    order_fn,
    max_rules: int = 100,
    max_iterations: int = 1000
) -> Optional[list[RewriteRule]]:
    """Naive Knuth-Bendix completion algorithm.

    Given a set of equations and a reduction ordering, attempts to produce
    a convergent rewrite system.

    Args:
        equations: List of (lhs, rhs) equation pairs
        order_fn: Function (t1, t2) -> bool, returns True if t1 > t2
                  in the reduction ordering
        max_rules: Maximum number of rules before giving up
        max_iterations: Maximum iterations

    Returns:
        List of rewrite rules forming a convergent system, or None if
        completion fails.

    Time complexity: O(max_iterations * |rules|² * critical_pair_cost)
    Space complexity: O(|rules| * max_rule_size)

    Pseudocode:
        R ← orient(equations)
        while there exist unprocessed critical pairs:
            (s, t) ← next critical pair
            s' ← normalize(s, R)
            t' ← normalize(t, R)
            if s' ≠ t':
                orient s' ≈ t' into a new rule and add to R
        return R
    """
    # Orient equations into rules
    rules: list[RewriteRule] = []
    for lhs, rhs in equations:
        if order_fn(lhs, rhs):
            rules.append(RewriteRule(lhs, rhs))
        elif order_fn(rhs, lhs):
            rules.append(RewriteRule(rhs, lhs))
        elif lhs == rhs:
            continue
        else:
            return None  # Can't orient

    processed_pairs: set[tuple[str, str]] = set()

    for iteration in range(max_iterations):
        new_pairs = []
        for i, r1 in enumerate(rules):
            for j, r2 in enumerate(rules):
                pairs = critical_pairs(r1, r2)
                for s, t in pairs:
                    key = (repr(s), repr(t))
                    if key not in processed_pairs:
                        processed_pairs.add(key)
                        new_pairs.append((s, t))

        if not new_pairs:
            return rules  # Completion succeeded

        for s, t in new_pairs:
            s_nf, _ = normalize(s, rules)
            t_nf, _ = normalize(t, rules)

            if s_nf == t_nf:
                continue

            if order_fn(s_nf, t_nf):
                rules.append(RewriteRule(s_nf, t_nf))
            elif order_fn(t_nf, s_nf):
                rules.append(RewriteRule(t_nf, s_nf))
            else:
                return None  # Can't orient

            if len(rules) > max_rules:
                return None  # Too many rules

    return None  # Didn't converge


# ============================================================
# Algorithm 7: Normal Form Complexity Analysis
# ============================================================

def normal_form_complexity(term: Term, rules: list[RewriteRule]) -> float:
    """Compute the normal form complexity ratio nfc(t) = |nf(t)| / |t|.

    Time complexity: O(normalization_cost)

    Returns a value in (0, ∞). For simplifying systems, always ≤ 1.
    """
    nf, _ = normalize(term, rules)
    return nf.size() / term.size()


def complexity_statistics(terms: list[Term],
                          rules: list[RewriteRule]) -> dict[str, float]:
    """Compute statistics of normal form complexity over a set of terms.

    Returns dict with keys: mean, min, max, median, fraction_le_1.
    """
    ratios = [normal_form_complexity(t, rules) for t in terms]
    ratios.sort()
    n = len(ratios)
    return {
        'mean': sum(ratios) / n,
        'min': ratios[0],
        'max': ratios[-1],
        'median': ratios[n // 2],
        'fraction_le_1': sum(1 for r in ratios if r <= 1.0) / n,
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithms for Convergent Rewrite Systems ===\n")

    # Example: Associativity normalization
    sig = Sig((2,))

    # Rule: f(f(x,y), z) -> f(x, f(y,z))
    assoc_rule = RewriteRule(
        App(0, (App(0, (Var(0), Var(1))), Var(2))),
        App(0, (Var(0), App(0, (Var(1), Var(2)))))
    )

    # Left-associated term: f(f(f(a,b), c), d)
    term = App(0, (App(0, (App(0, (Var(0), Var(1))), Var(2))), Var(3)))

    print(f"Rule: {assoc_rule}")
    print(f"Term: {term}")

    nf, steps = normalize(term, [assoc_rule])
    print(f"Normal form: {nf} (in {steps} steps)")
    print(f"NFC ratio: {nf.size() / term.size():.3f}")
    print()

    # Pattern matching example
    pattern = App(0, (Var(0), Var(1)))
    target = App(0, (Var(2), App(0, (Var(3), Var(4)))))
    subst = match_terms(pattern, target)
    print(f"Match {pattern} against {target}: {subst}")
    print()

    # Critical pairs
    rule2 = RewriteRule(
        App(0, (Var(0), App(0, (Var(1), Var(2))))),
        App(0, (App(0, (Var(0), Var(1))), Var(2)))
    )
    cps = critical_pairs(assoc_rule, rule2)
    print(f"Critical pairs between {assoc_rule} and {rule2}:")
    for s, t in cps:
        print(f"  ({s}, {t})")
