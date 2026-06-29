#!/usr/bin/env python3
"""
Algorithms for Higher-Order State Complexity

Implements the core algorithms from the research on exact type complexity
bounds for simply typed lambda calculus:

1. TypeStateBound computation (recursive on type structure)
2. Bounded state set enumeration via BFS over beta-reductions
3. Witness synthesis for tightness verification
4. Saturation depth detection

All algorithms operate on explicitly represented lambda terms and simple types.
"""

from __future__ import annotations
from dataclasses import dataclass
from collections import deque
from typing import Optional, Iterator


# ─── Types ─────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Ty:
    """Abstract base for simple types."""
    pass

@dataclass(frozen=True)
class Base(Ty):
    """The atomic base type."""
    def __repr__(self) -> str:
        return "o"

@dataclass(frozen=True)
class Arrow(Ty):
    """Function type A → B."""
    dom: Ty
    cod: Ty
    def __repr__(self) -> str:
        d = f"({self.dom})" if isinstance(self.dom, Arrow) else f"{self.dom}"
        return f"{d} → {self.cod}"


def type_state_bound(ty: Ty) -> int:
    """Compute the type state bound.

    Algorithm: Structural recursion on the type.
    - typeStateBound(base) = 1
    - typeStateBound(A → B) = (typeStateBound(A) + 1) * (typeStateBound(B) + 1)

    Time complexity: O(|ty|) where |ty| is the size of the type tree.
    Space complexity: O(depth(ty)) for the recursion stack.

    Returns:
        The exact type state bound, a positive integer.
    """
    if isinstance(ty, Base):
        return 1
    elif isinstance(ty, Arrow):
        return (type_state_bound(ty.dom) + 1) * (type_state_bound(ty.cod) + 1)
    raise TypeError(f"Unknown type: {ty}")


def type_depth(ty: Ty) -> int:
    """Compute the depth of a type tree.

    Time complexity: O(|ty|).
    """
    if isinstance(ty, Base):
        return 0
    elif isinstance(ty, Arrow):
        return 1 + max(type_depth(ty.dom), type_depth(ty.cod))
    raise TypeError


def type_size(ty: Ty) -> int:
    """Compute the number of nodes in a type tree.

    Time complexity: O(|ty|).
    """
    if isinstance(ty, Base):
        return 1
    elif isinstance(ty, Arrow):
        return 1 + type_size(ty.dom) + type_size(ty.cod)
    raise TypeError


# ─── Lambda Terms ──────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Lam:
    """Abstract base for lambda terms."""
    pass

@dataclass(frozen=True)
class Var(Lam):
    """Variable reference."""
    n: int
    def __repr__(self) -> str:
        return f"x{self.n}"

@dataclass(frozen=True)
class App(Lam):
    """Application."""
    fun: Lam
    arg: Lam
    def __repr__(self) -> str:
        return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Abs(Lam):
    """Lambda abstraction."""
    x: int
    body: Lam
    def __repr__(self) -> str:
        return f"(λx{self.x}. {self.body})"


def subst(term: Lam, x: int, s: Lam) -> Lam:
    """Capture-ignoring substitution: term[x := s].

    Warning: This does NOT perform capture avoidance. It matches
    the formal definition in our Lean development where variable
    shadowing prevents capture in well-scoped terms.

    Time complexity: O(|term| * |s|) worst case.
    """
    if isinstance(term, Var):
        return s if term.n == x else term
    elif isinstance(term, App):
        return App(subst(term.fun, x, s), subst(term.arg, x, s))
    elif isinstance(term, Abs):
        if term.x == x:
            return term
        return Abs(term.x, subst(term.body, x, s))
    raise TypeError


def term_size(term: Lam) -> int:
    """Compute the size (number of nodes) of a term."""
    if isinstance(term, Var):
        return 1
    elif isinstance(term, App):
        return 1 + term_size(term.fun) + term_size(term.arg)
    elif isinstance(term, Abs):
        return 1 + term_size(term.body)
    raise TypeError


# ─── Beta Reduction ────────────────────────────────────────────────────────

def beta_reductions(term: Lam) -> list[Lam]:
    """Enumerate all one-step beta reductions of a term.

    Implements the full congruence closure:
    - (λx. body) arg → body[x := arg]          (beta)
    - (t₁ t₂) → (t₁' t₂)  if t₁ → t₁'        (appLeft)
    - (t₁ t₂) → (t₁ t₂')  if t₂ → t₂'        (appRight)
    - (λx. t) → (λx. t')   if t → t'           (lamBody)

    Time complexity: O(|term|²) worst case (due to substitution).

    Returns:
        List of all terms obtainable by a single beta step.
    """
    results: list[Lam] = []

    if isinstance(term, App):
        # Beta redex
        if isinstance(term.fun, Abs):
            results.append(subst(term.fun.body, term.fun.x, term.arg))
        # Reduce function
        for t in beta_reductions(term.fun):
            results.append(App(t, term.arg))
        # Reduce argument
        for t in beta_reductions(term.arg):
            results.append(App(term.fun, t))
    elif isinstance(term, Abs):
        # Reduce body
        for t in beta_reductions(term.body):
            results.append(Abs(term.x, t))

    return results


def is_normal_form(term: Lam) -> bool:
    """Check if a term is in beta-normal form (no reductions possible)."""
    return len(beta_reductions(term)) == 0


# ─── Bounded State Set (BFS) ──────────────────────────────────────────────

def bounded_state_set(depth: int, term: Lam) -> set[Lam]:
    """Compute the bounded state set: all terms reachable within `depth` steps.

    Algorithm: Breadth-first search over the beta-reduction graph,
    limited to `depth` layers.

    Time complexity: O(depth * |states| * |term_size|²)
    Space complexity: O(|states| * |max_term_size|)

    The state set is always finite for strongly normalizing terms,
    and may be finite or infinite in general. For well-typed STLC terms,
    finiteness is guaranteed by strong normalization.

    Args:
        depth: Maximum number of beta-reduction steps.
        term: Starting term.

    Returns:
        Set of all terms reachable from `term` within `depth` steps.
    """
    visited: set[Lam] = {term}
    frontier: set[Lam] = {term}

    for _ in range(depth):
        next_frontier: set[Lam] = set()
        for t in frontier:
            for t2 in beta_reductions(t):
                if t2 not in visited:
                    visited.add(t2)
                    next_frontier.add(t2)
        frontier = next_frontier
        if not frontier:
            break

    return visited


def canonical_quotient_size(depth: int, term: Lam) -> int:
    """Compute the canonical quotient size at a given depth.

    This is simply |bounded_state_set(depth, term)|.
    """
    return len(bounded_state_set(depth, term))


# ─── Saturation Detection ─────────────────────────────────────────────────

def detect_saturation(
    term: Lam,
    ty: Ty,
    max_depth: int = 20
) -> Optional[int]:
    """Detect the saturation depth: the smallest d such that
    canonical_quotient_size(d, term) = type_state_bound(ty).

    Returns None if saturation is not achieved within max_depth.

    Algorithm: Incrementally compute bounded state sets and check
    against the type state bound.

    Args:
        term: The witness term to analyze.
        ty: The type whose state bound we're targeting.
        max_depth: Maximum depth to search.

    Returns:
        The saturation depth, or None if not found.
    """
    target = type_state_bound(ty)

    visited: set[Lam] = {term}
    frontier: set[Lam] = {term}

    if len(visited) == target:
        return 0

    for d in range(1, max_depth + 1):
        next_frontier: set[Lam] = set()
        for t in frontier:
            for t2 in beta_reductions(t):
                if t2 not in visited:
                    visited.add(t2)
                    next_frontier.add(t2)
        frontier = next_frontier

        if len(visited) == target:
            return d

        if not frontier:
            # No more reductions possible
            break

    return None


# ─── Witness Synthesis ─────────────────────────────────────────────────────

def synthesize_witness_base_arrow(var_start: int = 0) -> Lam:
    """Synthesize the canonical witness for base → base.

    Construction: (λx₀. x₀)((λx₁. x₁)(λx₂. x₂))

    This term has the reduction diamond:
        w₀ = (λx₀.x₀)((λx₁.x₁)(λx₂.x₂))
           /                              \\
      w₁ = (λx₁.x₁)(λx₂.x₂)     w₂ = (λx₀.x₀)(λx₂.x₂)
           \\                              /
                    w₃ = λx₂.x₂

    giving exactly 4 reachable states = typeStateBound(base → base).

    Args:
        var_start: Starting variable index for fresh names.

    Returns:
        The witness term.
    """
    x0, x1, x2 = var_start, var_start + 1, var_start + 2
    return App(
        Abs(x0, Var(x0)),
        App(Abs(x1, Var(x1)), Abs(x2, Var(x2)))
    )


def enumerate_witnesses(
    ty: Ty,
    max_size: int = 15,
    max_depth: int = 10
) -> list[tuple[Lam, int, int]]:
    """Enumerate witness terms and find the best achiever.

    Generates lambda terms up to a given size and evaluates their
    canonical quotient sizes.

    Args:
        ty: Target type.
        max_size: Maximum term size to enumerate.
        max_depth: Maximum depth for state set computation.

    Returns:
        List of (term, best_quotient_size, saturation_depth) tuples,
        sorted by quotient size descending.
    """
    target = type_state_bound(ty)
    results: list[tuple[Lam, int, int]] = []

    # For now, just test the known constructions
    candidates = [
        Abs(0, Var(0)),  # identity
        synthesize_witness_base_arrow(),
    ]

    # Add nested identity variants
    for n in range(1, 6):
        t = Abs(0, Var(0))
        for i in range(n):
            t = App(Abs(100 + i, Var(100 + i)), t)
        candidates.append(t)

    for term in candidates:
        best_qs = 0
        best_d = 0
        for d in range(max_depth + 1):
            qs = canonical_quotient_size(d, term)
            if qs > best_qs:
                best_qs = qs
                best_d = d
            if qs == target:
                break
        results.append((term, best_qs, best_d))

    results.sort(key=lambda x: -x[1])
    return results


# ─── Iterated Endomorphism Types ──────────────────────────────────────────

def iter_end_ty(n: int) -> Ty:
    """Compute the n-th iterated endomorphism type.

    iterEndTy(0) = base
    iterEndTy(n+1) = iterEndTy(n) → iterEndTy(n)

    The sequence of typeStateBound values: 1, 4, 25, 676, 458329, ...
    which satisfies a(n+1) = (a(n) + 1)².
    """
    if n == 0:
        return Base()
    sub = iter_end_ty(n - 1)
    return Arrow(sub, sub)


# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Type state bound computation
    print("1. Type State Bound:")
    for n in range(6):
        ty = iter_end_ty(n)
        print(f"   iterEndTy({n}): typeStateBound = {type_state_bound(ty)}")

    # 2. Witness synthesis and verification
    print("\n2. Witness Verification (base → base):")
    w = synthesize_witness_base_arrow()
    ty = Arrow(Base(), Base())
    sat = detect_saturation(w, ty)
    print(f"   Witness: {w}")
    print(f"   Saturation depth: {sat}")
    print(f"   States at saturation: {canonical_quotient_size(sat, w)}")
    print(f"   typeStateBound: {type_state_bound(ty)}")
    print(f"   Match: {canonical_quotient_size(sat, w) == type_state_bound(ty)}")

    # 3. State set enumeration
    print("\n3. Bounded State Set (depth=2):")
    states = bounded_state_set(2, w)
    for i, s in enumerate(sorted(states, key=str)):
        print(f"   State {i}: {s}")
