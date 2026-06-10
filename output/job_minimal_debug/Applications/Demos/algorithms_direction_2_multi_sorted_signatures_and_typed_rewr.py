#!/usr/bin/env python3
"""
algorithms.py — Multi-sorted rewriting algorithms.

Implements:
1. Multi-sorted normalization with sort-preservation guarantees
2. Sort-aware critical pair computation
3. Convergence checking for multi-sorted systems
4. Sort-graded complexity analysis

All algorithms include docstrings, type hints, and complexity analysis.
"""

from dataclasses import dataclass, field
from typing import (
    Dict, List, Tuple, Optional, Set, Callable, Any, Iterator
)
from enum import Enum, auto
import itertools


# ──────────────────────────────────────────────────────────────
# Core Types
# ──────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Sort:
    """A sort in a multi-sorted signature."""
    name: str

    def __repr__(self) -> str:
        return self.name


@dataclass(frozen=True)
class OpSym:
    """An operation symbol with its type signature."""
    name: str
    arg_sorts: Tuple[Sort, ...]
    result_sort: Sort

    @property
    def arity(self) -> int:
        return len(self.arg_sorts)

    def __repr__(self) -> str:
        args = " × ".join(str(s) for s in self.arg_sorts) or "()"
        return f"{self.name} : {args} → {self.result_sort}"


@dataclass(frozen=True)
class MSig:
    """A multi-sorted algebraic signature."""
    sorts: Tuple[Sort, ...]
    ops: Tuple[OpSym, ...]

    def ops_of_sort(self, s: Sort) -> List[OpSym]:
        """Return all operations producing sort s."""
        return [op for op in self.ops if op.result_sort == s]

    def max_arity(self) -> int:
        """Maximum arity of any operation."""
        return max((op.arity for op in self.ops), default=0)


class Term:
    """Abstract base for well-sorted terms."""

    def sort(self) -> Sort:
        raise NotImplementedError

    def size(self) -> int:
        raise NotImplementedError

    def subterms(self) -> Iterator["Term"]:
        raise NotImplementedError

    def positions(self) -> Iterator[Tuple[int, ...]]:
        """Yield all positions in the term as tuples of indices."""
        raise NotImplementedError

    def at_position(self, pos: Tuple[int, ...]) -> "Term":
        raise NotImplementedError

    def replace_at(self, pos: Tuple[int, ...], replacement: "Term") -> "Term":
        raise NotImplementedError


@dataclass(frozen=True)
class Var(Term):
    """A variable with a designated sort."""
    _sort: Sort
    index: int

    def sort(self) -> Sort:
        return self._sort

    def size(self) -> int:
        return 1

    def subterms(self) -> Iterator[Term]:
        yield self

    def positions(self) -> Iterator[Tuple[int, ...]]:
        yield ()

    def at_position(self, pos: Tuple[int, ...]) -> Term:
        if pos == ():
            return self
        raise IndexError(f"Invalid position {pos} in variable")

    def replace_at(self, pos: Tuple[int, ...], replacement: Term) -> Term:
        if pos == ():
            return replacement
        raise IndexError(f"Invalid position {pos} in variable")

    def __repr__(self) -> str:
        return f"x{self.index}:{self._sort}"


@dataclass(frozen=True)
class App(Term):
    """An operation applied to arguments."""
    op: OpSym
    args: Tuple[Term, ...]

    def __post_init__(self):
        if len(self.args) != self.op.arity:
            raise TypeError(
                f"Arity mismatch for {self.op.name}: "
                f"expected {self.op.arity}, got {len(self.args)}"
            )
        for i, (arg, expected) in enumerate(zip(self.args, self.op.arg_sorts)):
            if arg.sort() != expected:
                raise TypeError(
                    f"Sort mismatch at arg {i} of {self.op.name}: "
                    f"expected {expected}, got {arg.sort()}"
                )

    def sort(self) -> Sort:
        return self.op.result_sort

    def size(self) -> int:
        return 1 + sum(a.size() for a in self.args)

    def subterms(self) -> Iterator[Term]:
        yield self
        for arg in self.args:
            yield from arg.subterms()

    def positions(self) -> Iterator[Tuple[int, ...]]:
        yield ()
        for i, arg in enumerate(self.args):
            for pos in arg.positions():
                yield (i,) + pos

    def at_position(self, pos: Tuple[int, ...]) -> Term:
        if pos == ():
            return self
        i, *rest = pos
        return self.args[i].at_position(tuple(rest))

    def replace_at(self, pos: Tuple[int, ...], replacement: Term) -> Term:
        if pos == ():
            return replacement
        i, *rest = pos
        new_args = list(self.args)
        new_args[i] = self.args[i].replace_at(tuple(rest), replacement)
        return App(self.op, tuple(new_args))

    def __repr__(self) -> str:
        if not self.args:
            return self.op.name
        return f"{self.op.name}({', '.join(repr(a) for a in self.args)})"


# ──────────────────────────────────────────────────────────────
# Algorithm 1: Pattern Matching
# ──────────────────────────────────────────────────────────────

Substitution = Dict[Tuple[Sort, int], Term]


def match_pattern(pattern: Term, target: Term) -> Optional[Substitution]:
    """
    Match a pattern against a target term, returning a substitution if successful.

    Time complexity: O(|pattern| · |target|) in the worst case.
    Space complexity: O(|variables in pattern|) for the substitution.

    Args:
        pattern: The pattern to match (may contain variables).
        target: The concrete term to match against.

    Returns:
        A substitution mapping pattern variables to subterms of target,
        or None if matching fails.
    """
    subst: Substitution = {}

    def go(p: Term, t: Term) -> bool:
        if isinstance(p, Var):
            key = (p._sort, p.index)
            if p.sort() != t.sort():
                return False
            if key in subst:
                return subst[key] == t
            subst[key] = t
            return True
        elif isinstance(p, App) and isinstance(t, App):
            if p.op != t.op:
                return False
            return all(go(pa, ta) for pa, ta in zip(p.args, t.args))
        return False

    return subst if go(pattern, target) else None


def apply_substitution(term: Term, subst: Substitution) -> Term:
    """
    Apply a substitution to a term.

    Time complexity: O(|term| · max_subst_size).
    Space complexity: O(|result|).
    """
    if isinstance(term, Var):
        key = (term._sort, term.index)
        return subst.get(key, term)
    elif isinstance(term, App):
        new_args = tuple(apply_substitution(a, subst) for a in term.args)
        return App(term.op, new_args)
    raise TypeError


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Multi-Sorted Normalization
# ──────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class RewriteRule:
    """A sort-preserving rewrite rule."""
    lhs: Term
    rhs: Term

    def __post_init__(self):
        if self.lhs.sort() != self.rhs.sort():
            raise TypeError(
                f"Sort mismatch in rule: lhs sort {self.lhs.sort()} "
                f"!= rhs sort {self.rhs.sort()}"
            )

    @property
    def rule_sort(self) -> Sort:
        return self.lhs.sort()


class NormalizationResult(Enum):
    """Result status of normalization."""
    NORMAL_FORM = auto()
    MAX_STEPS_EXCEEDED = auto()


@dataclass
class NormalizationStats:
    """Statistics from a normalization run."""
    steps: int = 0
    result: NormalizationResult = NormalizationResult.NORMAL_FORM
    original_size: int = 0
    final_size: int = 0
    rules_applied: List[str] = field(default_factory=list)

    @property
    def complexity_ratio(self) -> float:
        if self.original_size == 0:
            return 0.0
        return self.final_size / self.original_size


def normalize(rules: List[RewriteRule], term: Term,
              max_steps: int = 10000) -> Tuple[Term, NormalizationStats]:
    """
    Normalize a term using leftmost-outermost rewriting.

    Applies rules repeatedly until no more rules apply (normal form)
    or the step limit is reached.

    Algorithm:
        1. Traverse the term left-to-right, top-to-bottom
        2. At each position, try all rules in order
        3. Apply the first matching rule
        4. Restart traversal from the root
        5. Stop when no rule applies anywhere

    Time complexity: O(max_steps · |term| · |rules| · max_pattern_size)
    Space complexity: O(|term|) for the current term

    Args:
        rules: List of rewrite rules to apply.
        term: The term to normalize.
        max_steps: Maximum number of rewrite steps.

    Returns:
        Tuple of (normalized term, statistics).

    Postcondition (if result is NORMAL_FORM):
        - get_sort(result) == get_sort(term)  (sort preservation)
        - No rule applies to the result (irreducibility)
    """
    stats = NormalizationStats(original_size=term.size())
    current = term

    for step in range(max_steps):
        rewritten = False
        for pos in current.positions():
            subterm = current.at_position(pos)
            for rule in rules:
                subst = match_pattern(rule.lhs, subterm)
                if subst is not None:
                    replacement = apply_substitution(rule.rhs, subst)
                    current = current.replace_at(pos, replacement)
                    stats.steps += 1
                    stats.rules_applied.append(
                        f"Step {stats.steps}: applied rule at position {pos}"
                    )
                    rewritten = True
                    break
            if rewritten:
                break

        if not rewritten:
            stats.result = NormalizationResult.NORMAL_FORM
            stats.final_size = current.size()
            return current, stats

    stats.result = NormalizationResult.MAX_STEPS_EXCEEDED
    stats.final_size = current.size()
    return current, stats


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Sort-Graded Complexity Analysis
# ──────────────────────────────────────────────────────────────

def sort_graded_size(term: Term, sorts: Tuple[Sort, ...]) -> Dict[Sort, int]:
    """
    Compute the sort-graded size of a term.

    Returns a dictionary mapping each sort to the count of subterms
    of that sort. The sum of all values equals term.size().

    Time complexity: O(|term| · |sorts|)
    Space complexity: O(|sorts|)
    """
    result = {s: 0 for s in sorts}

    def traverse(t: Term):
        s = t.sort()
        if s in result:
            result[s] += 1
        if isinstance(t, App):
            for arg in t.args:
                traverse(arg)

    traverse(term)
    return result


def verify_graded_consistency(term: Term, sorts: Tuple[Sort, ...]) -> bool:
    """Verify that sum of graded sizes equals total size."""
    graded = sort_graded_size(term, sorts)
    return sum(graded.values()) == term.size()


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Critical Pair Computation
# ──────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class CriticalPair:
    """A critical pair: two terms that arise from overlapping rule applications."""
    term1: Term
    term2: Term
    overlap_position: Tuple[int, ...]
    rule1_idx: int
    rule2_idx: int


def compute_critical_pairs(rules: List[RewriteRule],
                            sig: MSig) -> List[CriticalPair]:
    """
    Compute all sort-respecting critical pairs between rules.

    A critical pair arises when the lhs of one rule overlaps with
    a non-variable subterm of the lhs of another rule, and the
    sorts are compatible.

    Time complexity: O(|rules|² · max_term_size² · max_arity)
    Space complexity: O(|critical_pairs|)

    Returns:
        List of critical pairs found.
    """
    pairs: List[CriticalPair] = []
    next_var = 100  # Fresh variable counter

    for i, r1 in enumerate(rules):
        for j, r2 in enumerate(rules):
            # Rename variables in r2 to avoid capture
            renamed_r2_lhs = _rename_vars(r2.lhs, next_var)
            renamed_r2_rhs = _rename_vars(r2.rhs, next_var)
            next_var += 50

            for pos in renamed_r2_lhs.positions():
                if pos == () and i == j:
                    continue  # Skip trivial self-overlap at root
                subterm = renamed_r2_lhs.at_position(pos)
                if isinstance(subterm, Var):
                    continue  # No overlap with variables

                # Check sort compatibility
                if subterm.sort() != r1.lhs.sort():
                    continue

                # Try to unify r1.lhs with the subterm
                unifier = _unify(r1.lhs, subterm)
                if unifier is not None:
                    # Critical pair found
                    # Apply rule 1 at the overlap position
                    t1 = apply_substitution(
                        renamed_r2_lhs.replace_at(
                            pos, apply_substitution(r1.rhs, unifier)
                        ),
                        unifier
                    )
                    # Apply rule 2 at the root
                    t2 = apply_substitution(renamed_r2_rhs, unifier)

                    pairs.append(CriticalPair(
                        term1=t1, term2=t2,
                        overlap_position=pos,
                        rule1_idx=i, rule2_idx=j
                    ))

    return pairs


def _rename_vars(term: Term, offset: int) -> Term:
    """Rename all variables by adding an offset to their indices."""
    if isinstance(term, Var):
        return Var(term._sort, term.index + offset)
    elif isinstance(term, App):
        new_args = tuple(_rename_vars(a, offset) for a in term.args)
        return App(term.op, new_args)
    raise TypeError


def _unify(t1: Term, t2: Term) -> Optional[Substitution]:
    """
    Simple first-order unification (syntactic).

    Returns a most general unifier if one exists.
    """
    subst: Substitution = {}
    stack = [(t1, t2)]

    while stack:
        a, b = stack.pop()
        a = _apply_subst_chain(a, subst)
        b = _apply_subst_chain(b, subst)

        if a == b:
            continue
        if isinstance(a, Var):
            key = (a._sort, a.index)
            if a.sort() != b.sort():
                return None
            if _occurs_in(key, b):
                return None
            subst[key] = b
        elif isinstance(b, Var):
            key = (b._sort, b.index)
            if b.sort() != a.sort():
                return None
            if _occurs_in(key, a):
                return None
            subst[key] = a
        elif isinstance(a, App) and isinstance(b, App):
            if a.op != b.op:
                return None
            for ai, bi in zip(a.args, b.args):
                stack.append((ai, bi))
        else:
            return None

    return subst


def _apply_subst_chain(term: Term, subst: Substitution) -> Term:
    """Apply substitution, following chains."""
    if isinstance(term, Var):
        key = (term._sort, term.index)
        if key in subst:
            return _apply_subst_chain(subst[key], subst)
        return term
    elif isinstance(term, App):
        new_args = tuple(_apply_subst_chain(a, subst) for a in term.args)
        return App(term.op, new_args)
    return term


def _occurs_in(var_key: Tuple[Sort, int], term: Term) -> bool:
    """Occurs check: does the variable appear in the term?"""
    if isinstance(term, Var):
        return (term._sort, term.index) == var_key
    elif isinstance(term, App):
        return any(_occurs_in(var_key, a) for a in term.args)
    return False


# ──────────────────────────────────────────────────────────────
# Algorithm 5: Convergence Checking (Simplified)
# ──────────────────────────────────────────────────────────────

def check_local_confluence(rules: List[RewriteRule],
                            sig: MSig,
                            max_steps: int = 100) -> Tuple[bool, List[str]]:
    """
    Check local confluence by computing and resolving all critical pairs.

    A system is locally confluent if every critical pair (t1, t2)
    can be joined: t1 →* u and t2 →* u for some u.

    By Newman's Lemma, local confluence + termination = confluence.

    Returns:
        (is_locally_confluent, list of diagnostic messages)
    """
    messages = []
    cps = compute_critical_pairs(rules, sig)
    messages.append(f"Found {len(cps)} critical pairs")

    all_joinable = True
    for cp in cps:
        nf1, _ = normalize(rules, cp.term1, max_steps=max_steps)
        nf2, _ = normalize(rules, cp.term2, max_steps=max_steps)
        if nf1 != nf2:
            all_joinable = False
            messages.append(
                f"Non-joinable critical pair: "
                f"{cp.term1} and {cp.term2} normalize to "
                f"{nf1} and {nf2}"
            )

    if all_joinable:
        messages.append("All critical pairs are joinable → locally confluent ✓")
    else:
        messages.append("Some critical pairs are NOT joinable → NOT locally confluent ✗")

    return all_joinable, messages


# ──────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Define a simple two-sorted signature
    S = Sort("scalar")
    V = Sort("vector")

    add_s = OpSym("add_s", (S, S), S)
    add_v = OpSym("add_v", (V, V), V)
    smul = OpSym("smul", (S, V), V)
    zero_s = OpSym("zero_s", (), S)
    zero_v = OpSym("zero_v", (), V)

    sig = MSig(sorts=(S, V), ops=(add_s, add_v, smul, zero_s, zero_v))

    print("Signature:")
    for op in sig.ops:
        print(f"  {op}")

    # Define rules
    x = Var(S, 0)
    v = Var(V, 0)
    z_s = App(zero_s, ())
    z_v = App(zero_v, ())

    rules = [
        RewriteRule(App(add_s, (x, z_s)), x),      # x + 0 → x
        RewriteRule(App(add_v, (v, z_v)), v),       # v + 0 → v
        RewriteRule(App(smul, (z_s, v)), z_v),      # 0·v → 0_v
    ]

    print("\nRules:")
    for r in rules:
        print(f"  {r.lhs} → {r.rhs}")

    # Normalize a term
    t = App(smul, (App(add_s, (x, z_s)), App(add_v, (v, z_v))))
    print(f"\nTerm: {t}")

    nf, stats = normalize(rules, t)
    print(f"Normal form: {nf}")
    print(f"Steps: {stats.steps}")
    print(f"Size reduction: {stats.original_size} → {stats.final_size}")
    print(f"Complexity ratio: {stats.complexity_ratio:.2f}")

    # Check graded consistency
    graded = sort_graded_size(t, sig.sorts)
    print(f"\nSort-graded size: {graded}")
    print(f"Sum = {sum(graded.values())}, total size = {t.size()}")
    print(f"Consistency: {'✓' if verify_graded_consistency(t, sig.sorts) else '✗'}")

    # Check local confluence
    print("\nChecking local confluence...")
    is_confluent, messages = check_local_confluence(rules, sig)
    for msg in messages:
        print(f"  {msg}")
