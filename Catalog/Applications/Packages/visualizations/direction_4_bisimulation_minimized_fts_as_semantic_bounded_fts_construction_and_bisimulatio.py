"""
Algorithms for Bisimulation-Minimized Finite Transition Systems of Typed Lambda Terms

This module implements the core algorithms for computing bounded FTS,
bisimulation quotients, and canonical quotient sizes for simply typed
lambda calculus terms.

Application keywords: higher-order automata, coalgebraic minimization,
Myhill-Nerode, program equivalence, canonical semantics, state complexity
"""

from dataclasses import dataclass
from typing import Optional
from collections import defaultdict


# --- Lambda Calculus AST ---

@dataclass(frozen=True)
class Var:
    """Variable term."""
    name: int
    def __repr__(self): return f"x{self.name}"

@dataclass(frozen=True)
class App:
    """Application term."""
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction."""
    var: int
    body: 'Term'
    def __repr__(self): return f"(λx{self.var}. {self.body})"

Term = Var | App | Lam


# --- Simple Types ---

@dataclass(frozen=True)
class Base:
    """Base type."""
    def __repr__(self): return "o"

@dataclass(frozen=True)
class Arrow:
    """Arrow (function) type."""
    dom: 'Ty'
    cod: 'Ty'
    def __repr__(self): return f"({self.dom} → {self.cod})"

Ty = Base | Arrow


# --- Type Complexity ---

def type_state_bound(ty: Ty) -> int:
    """Compute the type-level state complexity bound.

    For base types, returns 1.
    For arrow types, grows multiplicatively.

    This bounds the canonical quotient size of any normal form of this type.

    Time complexity: O(|ty|)
    Space complexity: O(depth(ty)) for recursion
    """
    if isinstance(ty, Base):
        return 1
    return (type_state_bound(ty.dom) + 1) * (type_state_bound(ty.cod) + 1)


def type_depth(ty: Ty) -> int:
    """Compute the arrow nesting depth of a type."""
    if isinstance(ty, Base):
        return 0
    return 1 + max(type_depth(ty.dom), type_depth(ty.cod))


def type_complexity(ty: Ty) -> int:
    """Compute the multiplicative complexity of a type."""
    if isinstance(ty, Base):
        return 1
    return (type_complexity(ty.dom) + 1) * (type_complexity(ty.cod) + 1)


# --- Substitution ---

def free_vars(t: Term) -> set[int]:
    """Compute the set of free variables in a term."""
    if isinstance(t, Var):
        return {t.name}
    elif isinstance(t, App):
        return free_vars(t.fun) | free_vars(t.arg)
    else:
        return free_vars(t.body) - {t.var}


def subst(t: Term, x: int, s: Term) -> Term:
    """Substitute s for x in t (capture-avoiding with Barendregt convention)."""
    if isinstance(t, Var):
        return s if t.name == x else t
    elif isinstance(t, App):
        return App(subst(t.fun, x, s), subst(t.arg, x, s))
    else:
        if t.var == x:
            return t
        return Lam(t.var, subst(t.body, x, s))


# --- Beta Reduction ---

def beta_step(t: Term) -> list[Term]:
    """Compute all one-step beta reducts of t.

    Time complexity: O(|t|^2) in the worst case
    """
    results = []
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            results.append(subst(t.fun.body, t.fun.var, t.arg))
        for r in beta_step(t.fun):
            results.append(App(r, t.arg))
        for r in beta_step(t.arg):
            results.append(App(t.fun, r))
    elif isinstance(t, Lam):
        for r in beta_step(t.body):
            results.append(Lam(t.var, r))
    return results


def is_normal_form(t: Term) -> bool:
    """Check if t is in beta-normal form."""
    return len(beta_step(t)) == 0


def term_size(t: Term) -> int:
    """Compute the size (number of constructors) of a term."""
    if isinstance(t, Var):
        return 1
    elif isinstance(t, App):
        return 1 + term_size(t.fun) + term_size(t.arg)
    else:
        return 1 + term_size(t.body)


# --- Bounded FTS Construction ---

def compute_bounded_fts(d: int, t: Term) -> tuple[set[Term], set[tuple[Term, Term]]]:
    """Compute the bounded FTS at depth d for term t.

    Returns (states, transitions) where:
    - states is the set of terms reachable within d beta-steps
    - transitions is the set of (source, target) pairs

    Time complexity: O(d * max_branching * |t|^2)
    Space complexity: O(|states|)

    >>> t = App(Lam(0, Var(0)), Var(1))
    >>> states, trans = compute_bounded_fts(1, t)
    >>> len(states)
    2
    """
    states = {t}
    transitions = set()
    frontier = {t}

    for _ in range(d):
        new_frontier = set()
        for s in frontier:
            for r in beta_step(s):
                transitions.add((s, r))
                if r not in states:
                    states.add(r)
                    new_frontier.add(r)
        frontier = new_frontier

    return states, transitions


def canonical_quotient_size(d: int, t: Term) -> int:
    """Compute the canonical quotient size = |states| of toFTS d t.

    This is the central numerical invariant of the theory.

    >>> t = Var(0)
    >>> canonical_quotient_size(5, t)
    1
    """
    states, _ = compute_bounded_fts(d, t)
    return len(states)


# --- Bisimulation Quotient ---

def compute_bisimulation_quotient(states: set[Term],
                                   transitions: set[tuple[Term, Term]]
                                   ) -> list[frozenset[Term]]:
    """Compute the bisimulation quotient of a finite transition system.

    Uses partition refinement (Paige-Tarjan style).

    Time complexity: O(|states| * |transitions| * iterations)
    Space complexity: O(|states|)

    Returns a list of equivalence classes (frozensets of states).
    """
    # Build adjacency
    successors = defaultdict(set)
    for s, t in transitions:
        successors[s].add(t)

    # Initial partition: normal forms vs non-normal forms
    nf_states = {s for s in states if not successors[s]}
    non_nf = states - nf_states
    if nf_states and non_nf:
        partition = [frozenset(nf_states), frozenset(non_nf)]
    elif nf_states:
        partition = [frozenset(nf_states)]
    else:
        partition = [frozenset(non_nf)]

    # Refine until stable
    changed = True
    while changed:
        changed = False
        new_partition = []
        for block in partition:
            # Split block based on which partition classes its members can reach
            signatures = defaultdict(set)
            for s in block:
                sig = frozenset(
                    i for i, cls in enumerate(partition)
                    if successors[s] & cls
                )
                signatures[sig].add(s)
            if len(signatures) > 1:
                changed = True
            for group in signatures.values():
                new_partition.append(frozenset(group))
        partition = new_partition

    return partition


def bisimulation_quotient_size(d: int, t: Term) -> int:
    """Compute the number of bisimulation equivalence classes.

    >>> t = Var(0)
    >>> bisimulation_quotient_size(5, t)
    1
    """
    states, trans = compute_bounded_fts(d, t)
    return len(compute_bisimulation_quotient(states, trans))


# --- Term Enumeration ---

def enumerate_closed_terms(ty: Ty, max_size: int, ctx: dict[int, Ty] | None = None,
                            next_var: int = 0) -> list[Term]:
    """Enumerate closed well-typed terms of a given type up to a size bound.

    Time complexity: Exponential in max_size (inherent to enumeration)
    """
    if ctx is None:
        ctx = {}
    results = []
    if max_size < 1:
        return results

    # Variables
    for v, v_ty in ctx.items():
        if v_ty == ty and max_size >= 1:
            results.append(Var(v))

    # Lambda abstractions (if arrow type)
    if isinstance(ty, Arrow) and max_size >= 2:
        new_ctx = dict(ctx)
        new_ctx[next_var] = ty.dom
        for body in enumerate_closed_terms(ty.cod, max_size - 1, new_ctx, next_var + 1):
            results.append(Lam(next_var, body))

    # Applications
    if max_size >= 3:
        for arg_ty in _enumerate_subtypes(ty, max_depth=3):
            fun_ty = Arrow(arg_ty, ty)
            for fun_size in range(1, max_size - 1):
                arg_size = max_size - 1 - fun_size
                for fun_term in enumerate_closed_terms(fun_ty, fun_size, ctx, next_var):
                    for arg_term in enumerate_closed_terms(arg_ty, arg_size, ctx, next_var):
                        results.append(App(fun_term, arg_term))

    return results


def _enumerate_subtypes(ty: Ty, max_depth: int) -> list[Ty]:
    """Enumerate types that could serve as argument types for functions returning ty."""
    if max_depth <= 0:
        return [Base()]
    result = [Base()]
    if max_depth >= 1:
        result.append(ty)
        result.append(Arrow(Base(), Base()))
    return result


# --- Beta Equivalence Check ---

def normalize(t: Term, max_steps: int = 1000) -> Optional[Term]:
    """Normalize a term by leftmost-outermost reduction.

    Returns None if normalization doesn't terminate within max_steps.
    """
    current = t
    for _ in range(max_steps):
        reducts = beta_step(current)
        if not reducts:
            return current
        current = reducts[0]
    return None


def beta_equivalent(t: Term, u: Term, max_steps: int = 1000) -> Optional[bool]:
    """Check if two terms are beta-equivalent by normalizing both.

    Returns None if normalization doesn't terminate.
    """
    nf_t = normalize(t, max_steps)
    nf_u = normalize(u, max_steps)
    if nf_t is None or nf_u is None:
        return None
    return nf_t == nf_u


# --- Quotient Stability Detection ---

def find_stabilization_depth(t: Term, max_depth: int = 50) -> Optional[int]:
    """Find the depth at which the canonical quotient size stabilizes.

    Returns the smallest d₀ such that canonical_quotient_size(d, t) is
    constant for all d ≥ d₀ (up to max_depth).

    >>> find_stabilization_depth(Var(0))
    0
    """
    prev_size = canonical_quotient_size(0, t)
    stable_from = 0
    for d in range(1, max_depth + 1):
        curr_size = canonical_quotient_size(d, t)
        if curr_size != prev_size:
            stable_from = d
            prev_size = curr_size
    return stable_from


if __name__ == "__main__":
    # Quick demo
    print("=== Algorithms Demo ===")

    # Identity function
    ident = Lam(0, Var(0))
    print(f"Identity: {ident}")
    print(f"  Normal form? {is_normal_form(ident)}")
    print(f"  Quotient size at d=3: {canonical_quotient_size(3, ident)}")
    print(f"  Bisim quotient size at d=3: {bisimulation_quotient_size(3, ident)}")
    print(f"  Stabilization depth: {find_stabilization_depth(ident)}")

    # Redex: (λx.x)(λx.x)
    redex = App(Lam(0, Var(0)), Lam(1, Var(1)))
    print(f"\nRedex: {redex}")
    print(f"  Normal form? {is_normal_form(redex)}")
    for d in range(5):
        print(f"  d={d}: states={canonical_quotient_size(d, redex)}, "
              f"bisim_classes={bisimulation_quotient_size(d, redex)}")
    print(f"  Stabilization depth: {find_stabilization_depth(redex)}")

    # Type bounds
    for ty in [Base(), Arrow(Base(), Base()), Arrow(Arrow(Base(), Base()), Base())]:
        print(f"\nType {ty}: state_bound={type_state_bound(ty)}, depth={type_depth(ty)}")
