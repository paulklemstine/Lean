#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for de Bruijn lambda calculus.

Implements:
1. Complete Development (Takahashi's ⋆-translation) — O(n) per pass
2. Parallel β-reduction
3. Certified normalizer via iterated complete development
4. Path distance computation via BFS on the reduction graph

All algorithms correspond to formally verified counterparts in
Catalog/Pythagorean/ChurchRosserDeBruijn.lean
"""

from dataclasses import dataclass
from typing import Optional, List, Set, Tuple, Dict
from collections import deque


# ─── De Bruijn Term ADT ──────────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    """Variable represented by de Bruijn index."""
    index: int
    def __repr__(self): return str(self.index)

@dataclass(frozen=True)
class App:
    """Application of function to argument."""
    fun: 'DBTerm'
    arg: 'DBTerm'
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction (binder implicit in de Bruijn)."""
    body: 'DBTerm'
    def __repr__(self): return f"(λ.{self.body})"

DBTerm = Var | App | Lam


# ─── Algorithm 1: Shifting ────────────────────────────────────────────────────

def shift(d: int, c: int, t: DBTerm) -> DBTerm:
    """
    Shift free variables in t that are >= cutoff c by amount d.

    Time complexity: O(|t|) where |t| is the size of the term.
    Space complexity: O(|t|) for the new term.

    Corresponds to DBTerm.shift in the Lean formalization.
    """
    match t:
        case Var(k):
            return Var(k) if k < c else Var(k + d)
        case App(f, a):
            return App(shift(d, c, f), shift(d, c, a))
        case Lam(body):
            return Lam(shift(d, c + 1, body))


# ─── Algorithm 2: Substitution ────────────────────────────────────────────────

def subst(s: DBTerm, j: int, t: DBTerm) -> DBTerm:
    """
    Capture-avoiding substitution: replace variable j with s in t.
    Variables above j are decremented (the binder is consumed).

    Time complexity: O(|t| * |s|) in the worst case (s is duplicated).
    Space complexity: O(|t| * |s|).

    Corresponds to DBTerm.subst in the Lean formalization.
    Formally verified properties:
    - subst_shift_cancel: subst r j (shift 1 j t) = t
    - shift_subst_comm: shift d c (subst s j t) = subst (shift d c s) j (shift d (c+1) t) when j ≤ c
    - subst_subst_gen: subst s j (subst t k body) = subst (subst s j t) k (subst (shift 1 k s) (j+1) body) when k ≤ j
    """
    match t:
        case Var(k):
            if k == j: return s
            elif k < j: return Var(k)
            else: return Var(k - 1)
        case App(f, a):
            return App(subst(s, j, f), subst(s, j, a))
        case Lam(body):
            return Lam(subst(shift(1, 0, s), j + 1, body))


# ─── Algorithm 3: Complete Development ────────────────────────────────────────

def complete_dev(t: DBTerm) -> DBTerm:
    """
    Takahashi's complete development (⋆-translation).
    Contracts ALL β-redexes in t simultaneously.

    This is the key algorithmic ingredient for the Church-Rosser proof:
    every parallel reduct of t further reduces to complete_dev(t).

    Time complexity: O(|t|²) worst case (due to substitution in β case).
    Space complexity: O(|t|²).

    Corresponds to DBTerm.completeDev in the Lean formalization.
    Formally verified: ParBeta t u → ParBeta u (completeDev t)
    """
    match t:
        case Var(k):
            return Var(k)
        case App(Lam(body), arg):
            return subst(complete_dev(arg), 0, complete_dev(body))
        case App(f, a):
            return App(complete_dev(f), complete_dev(a))
        case Lam(body):
            return Lam(complete_dev(body))


# ─── Algorithm 4: One-step β-reduction (all reducts) ─────────────────────────

def all_reducts(t: DBTerm) -> List[DBTerm]:
    """
    Compute all possible one-step β-reducts of t.

    Time complexity: O(|t|² * k) where k is the number of redexes.
    """
    results = []
    match t:
        case Var(_):
            pass
        case App(Lam(body), arg):
            # The β-redex itself
            results.append(subst(arg, 0, body))
            # Reduce inside the function (lam body)
            for r in all_reducts(body):
                results.append(App(Lam(r), arg))
            # Reduce inside the argument
            for r in all_reducts(arg):
                results.append(App(Lam(body), r))
        case App(f, a):
            for r in all_reducts(f):
                results.append(App(r, a))
            for r in all_reducts(a):
                results.append(App(f, r))
        case Lam(body):
            for r in all_reducts(body):
                results.append(Lam(r))
    return results


# ─── Algorithm 5: Leftmost-outermost reduction ───────────────────────────────

def beta_reduce_leftmost(t: DBTerm) -> Optional[DBTerm]:
    """
    Perform one leftmost-outermost β-reduction step.
    This strategy is normalizing for terms that have a normal form.

    Time complexity: O(|t|) per step.
    """
    match t:
        case App(Lam(body), arg):
            return subst(arg, 0, body)
        case App(f, a):
            r = beta_reduce_leftmost(f)
            if r is not None: return App(r, a)
            r = beta_reduce_leftmost(a)
            if r is not None: return App(f, r)
            return None
        case Lam(body):
            r = beta_reduce_leftmost(body)
            return Lam(r) if r is not None else None
        case _:
            return None


# ─── Algorithm 6: Normalization ───────────────────────────────────────────────

def normalize(t: DBTerm, fuel: int = 1000) -> Tuple[Optional[DBTerm], int]:
    """
    Normalize t via leftmost-outermost reduction.

    Returns (normal_form, step_count) or (None, fuel) if fuel exhausted.

    Time complexity: O(fuel * |t_max|) where |t_max| is the max term size.
    """
    steps = 0
    current = t
    for _ in range(fuel):
        r = beta_reduce_leftmost(current)
        if r is None:
            return current, steps
        current = r
        steps += 1
    return None, fuel


def normalize_via_cd(t: DBTerm, fuel: int = 100) -> Tuple[Optional[DBTerm], int]:
    """
    Normalize via iterated complete development.

    Each pass contracts all redexes at once. Typically converges faster
    than single-step reduction.

    Returns (normal_form, passes) or (None, fuel) if fuel exhausted.
    """
    passes = 0
    current = t
    for _ in range(fuel):
        if is_normal_form(current):
            return current, passes
        current = complete_dev(current)
        passes += 1
    return None, fuel


def is_normal_form(t: DBTerm) -> bool:
    """Check if t is in β-normal form."""
    match t:
        case Var(_): return True
        case App(Lam(_), _): return False
        case App(f, a): return is_normal_form(f) and is_normal_form(a)
        case Lam(body): return is_normal_form(body)


# ─── Algorithm 7: Path Distance (BFS) ────────────────────────────────────────

def eq_path_dist(t: DBTerm, u: DBTerm, max_depth: int = 20) -> Optional[int]:
    """
    Compute the equivalence-path distance between t and u.

    Uses BFS on the β-reduction graph (forward and backward steps).
    Returns the minimum number of steps (forward or backward β-reductions)
    to connect t to u, or None if not found within max_depth.

    Time complexity: O(b^d) where b is branching factor, d is distance.
    """
    if t == u:
        return 0

    # BFS from both ends
    visited_t: Dict[DBTerm, int] = {t: 0}
    visited_u: Dict[DBTerm, int] = {u: 0}
    queue_t: deque = deque([t])
    queue_u: deque = deque([u])

    for depth in range(1, max_depth + 1):
        # Expand from t
        new_queue_t = deque()
        while queue_t:
            current = queue_t.popleft()
            for r in all_reducts(current):
                if r not in visited_t:
                    visited_t[r] = depth
                    new_queue_t.append(r)
                    if r in visited_u:
                        return depth + visited_u[r]
        queue_t = new_queue_t

        # Expand from u
        new_queue_u = deque()
        while queue_u:
            current = queue_u.popleft()
            for r in all_reducts(current):
                if r not in visited_u:
                    visited_u[r] = depth
                    new_queue_u.append(r)
                    if r in visited_t:
                        return visited_t[r] + depth
        queue_u = new_queue_u

    return None


# ─── Algorithm 8: Term Size ───────────────────────────────────────────────────

def term_size(t: DBTerm) -> int:
    """Number of constructors in the term."""
    match t:
        case Var(_): return 1
        case App(f, a): return 1 + term_size(f) + term_size(a)
        case Lam(body): return 1 + term_size(body)


# ─── Standard Combinators ────────────────────────────────────────────────────

I = Lam(Var(0))
K = Lam(Lam(Var(1)))
S = Lam(Lam(Lam(App(App(Var(2), Var(0)), App(Var(1), Var(0))))))

def church(n: int) -> DBTerm:
    """Church numeral n = λf.λx.f^n(x)"""
    body = Var(0)
    for _ in range(n):
        body = App(Var(1), body)
    return Lam(Lam(body))


# ─── Self-test ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Testing algorithms...")

    # Test shift
    assert shift(1, 0, Var(0)) == Var(1)
    assert shift(1, 1, Var(0)) == Var(0)
    assert shift(0, 0, Var(5)) == Var(5)

    # Test substitution
    assert subst(Var(1), 0, Var(0)) == Var(1)
    assert subst(Var(1), 0, Var(1)) == Var(0)  # decrement

    # Test subst_shift_cancel
    for j in range(3):
        for t in [Var(0), Var(1), App(Var(0), Var(1)), Lam(Var(0))]:
            r = Var(42)  # arbitrary
            assert subst(r, j, shift(1, j, t)) == t, f"subst_shift_cancel failed for j={j}, t={t}"

    # Test complete development
    assert complete_dev(App(I, Var(0))) == Var(0)
    assert is_normal_form(complete_dev(App(I, I)))

    # Test normalization
    nf, cost = normalize(App(App(K, I), Var(0)))
    assert nf == I

    # Test Church numerals
    nf3, _ = normalize(church(3))
    assert nf3 == church(3)  # already in NF

    print("All tests passed!")
