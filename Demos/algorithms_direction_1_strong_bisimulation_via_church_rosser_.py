#!/usr/bin/env python3
"""
Algorithms for Church-Rosser Confluence and Bisimulation Transfer

Implements the core algorithms from the formalization:
1. Parallel beta reduction
2. Takahashi's complete development (star translation)
3. Church-Rosser common reduct finder
4. Bounded FTS construction
5. Strong bisimulation checker (partition refinement)
6. Budget estimation for joinability
"""

from dataclasses import dataclass
from typing import Optional
from collections import deque


# ─── Lambda Term Representation ──────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    n: int
    def __repr__(self): return f"x{self.n}"

@dataclass(frozen=True)
class App:
    fun: 'Lam'
    arg: 'Lam'
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam_:
    var: int
    body: 'Lam'
    def __repr__(self): return f"(λx{self.var}. {self.body})"

Lam = Var | App | Lam_


# ─── Core Operations ─────────────────────────────────────────────────────

def subst(t: Lam, x: int, s: Lam) -> Lam:
    """Naive substitution: t[x := s]."""
    if isinstance(t, Var):
        return s if t.n == x else t
    elif isinstance(t, App):
        return App(subst(t.fun, x, s), subst(t.arg, x, s))
    elif isinstance(t, Lam_):
        return t if t.var == x else Lam_(t.var, subst(t.body, x, s))


def term_size(t: Lam) -> int:
    """Number of constructors in a term."""
    if isinstance(t, Var): return 1
    elif isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    elif isinstance(t, Lam_): return 1 + term_size(t.body)


def free_vars(t: Lam) -> set[int]:
    """Free variables of a term."""
    if isinstance(t, Var): return {t.n}
    elif isinstance(t, App): return free_vars(t.fun) | free_vars(t.arg)
    elif isinstance(t, Lam_): return free_vars(t.body) - {t.var}


# ─── Algorithm 1: Parallel Beta Reduction ────────────────────────────────

def complete_development(t: Lam) -> Lam:
    """Takahashi's complete development (⋆-translation).

    Simultaneously contracts ALL beta redexes in a single pass.
    This is the canonical "maximal reduct" of a term.

    Time complexity: O(n²) where n = term_size(t), due to substitution.
    Space complexity: O(n) for the result term.

    The diamond property guarantees: for any parallel reducts u, v of t,
    both u and v reduce (in parallel) to t⋆.
    """
    if isinstance(t, Var):
        return t
    elif isinstance(t, App):
        if isinstance(t.fun, Lam_):
            body_star = complete_development(t.fun.body)
            arg_star = complete_development(t.arg)
            return subst(body_star, t.fun.var, arg_star)
        else:
            return App(complete_development(t.fun), complete_development(t.arg))
    elif isinstance(t, Lam_):
        return Lam_(t.var, complete_development(t.body))


# ─── Algorithm 2: Church-Rosser Common Reduct Finder ─────────────────────

def beta_reducts(t: Lam) -> list[Lam]:
    """All one-step beta reducts of t."""
    results = []
    if isinstance(t, App):
        if isinstance(t.fun, Lam_):
            results.append(subst(t.fun.body, t.fun.var, t.arg))
        for f in beta_reducts(t.fun):
            results.append(App(f, t.arg))
        for a in beta_reducts(t.arg):
            results.append(App(t.fun, a))
    elif isinstance(t, Lam_):
        for b in beta_reducts(t.body):
            results.append(Lam_(t.var, b))
    return results


def find_common_reduct_bfs(t: Lam, u: Lam, max_depth: int = 10) -> Optional[tuple]:
    """Find a common reduct using breadth-first search.

    Returns (common_reduct, depth_t, depth_u) or None.

    Time complexity: O(B^d) where B is branching factor, d is depth.
    This is exponential but works for small terms.
    """
    t_reachable = {}  # term -> depth
    u_reachable = {}

    t_frontier = {t}
    u_frontier = {u}
    t_reachable[t] = 0
    u_reachable[u] = 0

    for depth in range(1, max_depth + 1):
        # Expand t frontier
        new_t = set()
        for term in t_frontier:
            for r in beta_reducts(term):
                if r not in t_reachable:
                    t_reachable[r] = depth
                    new_t.add(r)
        t_frontier = new_t

        # Expand u frontier
        new_u = set()
        for term in u_frontier:
            for r in beta_reducts(term):
                if r not in u_reachable:
                    u_reachable[r] = depth
                    new_u.add(r)
        u_frontier = new_u

        # Check for common reduct
        common = set(t_reachable.keys()) & set(u_reachable.keys())
        if common:
            best = min(common, key=lambda x: t_reachable[x] + u_reachable[x])
            return (best, t_reachable[best], u_reachable[best])

    return None


def find_common_reduct_star(t: Lam, u: Lam, max_iter: int = 20) -> Optional[Lam]:
    """Find a common reduct using iterated complete development.

    Repeatedly applies t⋆ to both terms until they converge.
    For strongly normalizing terms, this always terminates.

    Time complexity: O(n² × max_iter) per term.
    """
    t_current = t
    u_current = u

    for _ in range(max_iter):
        if t_current == u_current:
            return t_current
        t_current = complete_development(t_current)
        u_current = complete_development(u_current)

    return None


# ─── Algorithm 3: Bounded FTS Construction ───────────────────────────────

def build_bounded_fts(t: Lam, depth: int) -> dict:
    """Build a bounded finite transition system.

    Returns:
        {
            "states": set of Lam terms,
            "init": initial state,
            "transitions": set of (source, target) pairs,
            "depth": the depth bound
        }

    Time complexity: O(|states| × B) where B is max branching factor.
    Space complexity: O(|states| + |transitions|).
    """
    states = set()
    transitions = set()
    frontier = {t}
    states.add(t)

    for _ in range(depth):
        new_frontier = set()
        for s in frontier:
            for r in beta_reducts(s):
                transitions.add((s, r))
                if r not in states:
                    states.add(r)
                    new_frontier.add(r)
        frontier = new_frontier
        if not frontier:
            break

    return {
        "states": states,
        "init": t,
        "transitions": transitions,
        "depth": depth
    }


# ─── Algorithm 4: Strong Bisimulation Checker ────────────────────────────

def check_strong_bisimulation(fts_a: dict, fts_b: dict) -> tuple[bool, set]:
    """Check if two FTS are strongly bisimilar.

    Uses a coinductive approach: try to build a bisimulation relation
    by BFS from the initial state pair.

    Returns: (is_bisimilar, relation)
    where relation is a set of (state_a, state_b) pairs.

    Time complexity: O(|S_A| × |S_B| × (|T_A| + |T_B|))
    Space complexity: O(|S_A| × |S_B|)
    """
    R = set()
    queue = deque()
    queue.append((fts_a["init"], fts_b["init"]))
    failed = False

    def successors(fts, state):
        return {s2 for (s1, s2) in fts["transitions"] if s1 == state}

    while queue and not failed:
        a, b = queue.popleft()
        if (a, b) in R:
            continue
        R.add((a, b))

        a_succs = successors(fts_a, a)
        b_succs = successors(fts_b, b)

        # Every a-successor must be matched by some b-successor
        for a_prime in a_succs:
            found = False
            for b_prime in b_succs:
                queue.append((a_prime, b_prime))
                found = True
                break
            if not found:
                failed = True
                break

        # Every b-successor must be matched by some a-successor
        if not failed:
            for b_prime in b_succs:
                found = False
                for a_prime in a_succs:
                    found = True
                    break
                if not found:
                    failed = True
                    break

    return (not failed, R)


# ─── Algorithm 5: Budget Estimation ──────────────────────────────────────

def estimate_joinability_budget(t: Lam, u: Lam) -> Optional[int]:
    """Estimate the minimum depth at which t and u are joinable.

    Uses BFS to find the minimum total reduction depth.
    Returns the max of the two individual depths, or None if not found.
    """
    result = find_common_reduct_bfs(t, u, max_depth=15)
    if result:
        _, dt, du = result
        return max(dt, du)
    return None


def syntactic_budget_upper_bound(t: Lam, u: Lam) -> int:
    """Conjectured upper bound for joinability budget.

    Heuristic: term_size(t) + term_size(u).
    This is a conjecture — counterexamples may exist for complex terms.
    """
    return term_size(t) + term_size(u)


# ─── Example Usage ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Church-Rosser Algorithms")
    print("=" * 50)

    # Example: (λx.x) y and y
    t = App(Lam_(0, Var(0)), Var(1))
    u = Var(1)

    print(f"\nt = {t}")
    print(f"u = {u}")

    # Complete development
    print(f"\nComplete development of t: {complete_development(t)}")

    # Common reduct (BFS)
    result = find_common_reduct_bfs(t, u)
    if result:
        v, dt, du = result
        print(f"Common reduct via BFS: {v} (t needs {dt} steps, u needs {du} steps)")

    # Common reduct (star iteration)
    v_star = find_common_reduct_star(t, u)
    print(f"Common reduct via ⋆-iteration: {v_star}")

    # Budget estimation
    budget = estimate_joinability_budget(t, u)
    print(f"Joinability budget: {budget}")
    print(f"Syntactic upper bound: {syntactic_budget_upper_bound(t, u)}")

    # Bounded FTS
    fts_t = build_bounded_fts(t, 2)
    fts_u = build_bounded_fts(u, 2)
    print(f"\nBounded FTS at depth 2:")
    print(f"  toFTS(2, t): {len(fts_t['states'])} states, {len(fts_t['transitions'])} transitions")
    print(f"  toFTS(2, u): {len(fts_u['states'])} states, {len(fts_u['transitions'])} transitions")

    # Bisimulation check
    is_bisim, R = check_strong_bisimulation(fts_t, fts_u)
    print(f"  Strongly bisimilar: {is_bisim}")
