#!/usr/bin/env python3
"""
Algorithms for computing normalization cost and bisimulation distance
on lambda calculus terms.

Implements the computational methods from the formal Lean 4 development
of "Normalization Cost as Bisimulation Distance."
"""

from dataclasses import dataclass
from typing import Optional
from collections import deque


# ─── Lambda Calculus AST ─────────────────────────────────────────────
@dataclass(frozen=True)
class Var:
    name: int
    def __repr__(self): return f"x{self.name}"

@dataclass(frozen=True)
class App:
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam:
    var: int
    body: 'Term'
    def __repr__(self): return f"(λx{self.var}. {self.body})"

Term = Var | App | Lam


def term_size(t: Term) -> int:
    """Number of constructors in a term."""
    match t:
        case Var(_): return 1
        case App(f, a): return 1 + term_size(f) + term_size(a)
        case Lam(_, body): return 1 + term_size(body)


def subst(t: Term, x: int, s: Term) -> Term:
    """Naive substitution of s for x in t."""
    match t:
        case Var(n): return s if n == x else t
        case App(f, a): return App(subst(f, x, s), subst(a, x, s))
        case Lam(y, body): return t if y == x else Lam(y, subst(body, x, s))


def beta_reducts(t: Term) -> list[Term]:
    """
    All one-step β-reducts of t.

    Complexity: O(|t|) per reduct, O(|t|²) total for a term with O(|t|) redexes.
    """
    match t:
        case Var(_):
            return []
        case App(Lam(x, body), arg):
            result = [subst(body, x, arg)]
            for b in beta_reducts(body):
                result.append(App(Lam(x, b), arg))
            for a in beta_reducts(arg):
                result.append(App(Lam(x, body), a))
            return result
        case App(f, a):
            result = []
            for f2 in beta_reducts(f):
                result.append(App(f2, a))
            for a2 in beta_reducts(a):
                result.append(App(f, a2))
            return result
        case Lam(x, body):
            return [Lam(x, b) for b in beta_reducts(body)]


def is_normal_form(t: Term) -> bool:
    """Check if t is in β-normal form. O(|t|)."""
    return len(beta_reducts(t)) == 0


# ─── Algorithm 1: Normalization Cost ─────────────────────────────────
def compute_norm_cost(t: Term, fuel: int = 100) -> Optional[int]:
    """
    Compute the normalization cost of t using leftmost-outermost reduction.

    Algorithm: Repeatedly apply the leftmost β-reduction until a normal
    form is reached or fuel is exhausted.

    Time complexity: O(fuel × |t|²) in the worst case.
    Space complexity: O(|t|) for the current term.

    Args:
        t: Lambda term to normalize
        fuel: Maximum number of reduction steps

    Returns:
        The number of steps to normal form, or None if fuel exhausted.

    Example:
        >>> compute_norm_cost(App(Lam(0, Var(0)), Lam(0, Var(0))))
        1
    """
    steps = 0
    current = t
    while not is_normal_form(current):
        if fuel == 0:
            return None
        reducts = beta_reducts(current)
        current = reducts[0]  # Leftmost-outermost
        steps += 1
        fuel -= 1
    return steps


# ─── Algorithm 2: Joinability Distance ───────────────────────────────
def compute_join_distance(t: Term, u: Term, max_depth: int = 6) -> Optional[int]:
    """
    Compute the joinability distance between t and u.

    The joinability distance is the minimum k₁ + k₂ such that t reduces
    to some common term v in k₁ steps and u reduces to v in k₂ steps.

    Algorithm: Breadth-first expansion of the reachable sets from t and u,
    checking for common terms at each depth level.

    Time complexity: O(B^d × |t|) where B is the branching factor
                     (number of reducts per term) and d is max_depth.
    Space complexity: O(B^d) for storing reachable terms.

    Args:
        t, u: Lambda terms to compare
        max_depth: Maximum search depth

    Returns:
        The joinability distance, or None if no common reduct found.

    Example:
        >>> I = Lam(0, Var(0))
        >>> compute_join_distance(App(I, I), I)
        1
    """
    reach_t: dict[Term, int] = {t: 0}
    reach_u: dict[Term, int] = {u: 0}
    frontier_t = [t]
    frontier_u = [u]
    best = None

    for depth in range(max_depth + 1):
        for v in reach_t:
            if v in reach_u:
                d = reach_t[v] + reach_u[v]
                if best is None or d < best:
                    best = d

        if depth == max_depth:
            break

        new_t = []
        for s in frontier_t:
            for r in beta_reducts(s):
                if r not in reach_t:
                    reach_t[r] = reach_t[s] + 1
                    new_t.append(r)
        frontier_t = new_t

        new_u = []
        for s in frontier_u:
            for r in beta_reducts(s):
                if r not in reach_u:
                    reach_u[r] = reach_u[s] + 1
                    new_u.append(r)
        frontier_u = new_u

    return best


# ─── Algorithm 3: Equivalence-Path Distance ─────────────────────────
def compute_eq_path_distance(t: Term, u: Term, max_depth: int = 8) -> Optional[int]:
    """
    Compute the equivalence-path distance between t and u.

    The eq-path distance is the minimum number of β-steps (forward or
    backward) needed to transform t into u. This is the shortest path
    in the β-equivalence graph.

    Algorithm: BFS on the β-equivalence graph, where edges connect
    terms related by a single β-step in either direction.

    Note: Computing backward edges (β-expansions) is expensive, so we
    use the joinability distance as an upper bound when direct BFS fails.

    Time complexity: O(B^d × |t|) where B includes both forward and
                     backward branching.
    Space complexity: O(B^d) for the BFS frontier.

    Args:
        t, u: Lambda terms to compare
        max_depth: Maximum BFS depth

    Returns:
        The eq-path distance (or upper bound), or None if not found.

    Example:
        >>> I = Lam(0, Var(0))
        >>> compute_eq_path_distance(I, I)
        0
    """
    if t == u:
        return 0

    # Forward BFS (reductions only)
    visited: dict[Term, int] = {t: 0}
    frontier = [t]

    for depth in range(1, max_depth + 1):
        new_frontier = []
        for s in frontier:
            for r in beta_reducts(s):
                if r == u:
                    return depth
                if r not in visited:
                    visited[r] = depth
                    new_frontier.append(r)
        frontier = new_frontier

    # Fallback: joinability gives an upper bound
    return compute_join_distance(t, u, max_depth // 2)


# ─── Algorithm 4: Conjecture Tester ─────────────────────────────────
def test_additive_bound(terms: list[Term], max_depth: int = 4,
                        fuel: int = 50) -> dict:
    """
    Test the additive bound conjecture:
        d(t, u) ≤ normCost(t) + normCost(u)
    for all pairs of joinable terms.

    Returns a dictionary with test results.
    """
    results = {
        "tested": 0,
        "passed": 0,
        "failed": 0,
        "violations": [],
        "examples": []
    }

    for i, t in enumerate(terms):
        nc_t = compute_norm_cost(t, fuel)
        if nc_t is None:
            continue
        for j, u in enumerate(terms):
            if i >= j:
                continue
            nc_u = compute_norm_cost(u, fuel)
            if nc_u is None:
                continue
            jd = compute_join_distance(t, u, max_depth)
            if jd is not None:
                results["tested"] += 1
                bound = nc_t + nc_u
                if jd <= bound:
                    results["passed"] += 1
                else:
                    results["failed"] += 1
                    results["violations"].append((t, u, jd, bound))
                results["examples"].append({
                    "t": str(t), "u": str(u),
                    "dist": jd, "bound": bound,
                    "nc_t": nc_t, "nc_u": nc_u,
                    "holds": jd <= bound
                })

    return results


def generate_terms(size_bound: int = 4, vars: list[int] = [0, 1]) -> list[Term]:
    """Generate distinct lambda terms up to a given size."""
    terms: set[Term] = set()

    def gen(size: int) -> list[Term]:
        if size <= 0:
            return []
        if size == 1:
            return [Var(v) for v in vars]
        result = [Var(v) for v in vars]
        for v in vars:
            for body in gen(size - 1):
                result.append(Lam(v, body))
        for s1 in range(1, size - 1):
            s2 = size - 1 - s1
            for f in gen(s1):
                for a in gen(s2):
                    result.append(App(f, a))
        return result

    for s in range(1, size_bound + 1):
        for t in gen(s):
            terms.add(t)
    return list(terms)


if __name__ == "__main__":
    print("Generating test terms...")
    terms = generate_terms(size_bound=4)
    print(f"Generated {len(terms)} terms")

    print("\nTesting additive bound conjecture...")
    results = test_additive_bound(terms, max_depth=4)
    print(f"  Tested: {results['tested']}")
    print(f"  Passed: {results['passed']}")
    print(f"  Failed: {results['failed']}")
    if results['violations']:
        print("  VIOLATIONS:")
        for t, u, d, b in results['violations']:
            print(f"    d({t}, {u}) = {d} > {b}")
    else:
        print("  No violations found — conjecture holds on tested range.")
