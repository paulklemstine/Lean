#!/usr/bin/env python3
"""
Algorithms for De Bruijn Lambda Calculus Complexity Analysis

Implements the key algorithms from the research paper:
1. Affine term generator
2. Branch complexity computation
3. β-reduction explorer with monotonicity checking
4. Variable occurrence counting and affine verification

All algorithms correspond directly to formally verified definitions.
"""

from dataclasses import dataclass
from typing import Optional, Iterator
import random


# ─── Core Data Types ────────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    """De Bruijn variable with index."""
    index: int
    def __repr__(self) -> str:
        return f"x{self.index}"

@dataclass(frozen=True)
class App:
    """Application node (branching point)."""
    fun: 'Term'
    arg: 'Term'
    def __repr__(self) -> str:
        return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction."""
    body: 'Term'
    def __repr__(self) -> str:
        return f"(λ.{self.body})"

Term = Var | App | Lam


# ─── Algorithm 1: Shift (Variable Renaming) ─────────────────────────────

def shift(d: int, c: int, t: Term) -> Term:
    """
    Shift free variables in t by d, with cutoff c.
    
    Variables with index ≥ c are incremented by d.
    Under lambda binders, the cutoff increases.
    
    Time complexity: O(|t|) where |t| is the term size.
    Space complexity: O(|t|) for the new term.
    
    Corresponds to DBTerm.shift in the formal development.
    
    >>> shift(1, 0, Var(0))
    Var(index=1)
    >>> shift(1, 0, Lam(Var(0)))  # Bound var 0 stays
    Lam(body=Var(index=0))
    """
    if isinstance(t, Var):
        return Var(t.index) if t.index < c else Var(t.index + d)
    elif isinstance(t, App):
        return App(shift(d, c, t.fun), shift(d, c, t.arg))
    elif isinstance(t, Lam):
        return Lam(shift(d, c + 1, t.body))
    raise TypeError(f"Unknown term type: {type(t)}")


# ─── Algorithm 2: Capture-Avoiding Substitution ─────────────────────────

def subst(j: int, s: Term, t: Term) -> Term:
    """
    Capture-avoiding substitution: replace variable j with s in t.
    
    - Variables equal to j are replaced by s
    - Variables below j are unchanged
    - Variables above j are decremented (binder consumed)
    - Under lambdas, j increments and s is shifted
    
    Time complexity: O(|t| · |s|) worst case (affine: O(|t| + |s|))
    Space complexity: O(|t| + |s|)
    
    Corresponds to DBTerm.subst in the formal development.
    
    >>> subst(0, Var(42), Var(0))
    Var(index=42)
    >>> subst(0, Var(42), Var(1))
    Var(index=0)
    """
    if isinstance(t, Var):
        if t.index == j:
            return s
        elif t.index < j:
            return t
        else:
            return Var(t.index - 1)
    elif isinstance(t, App):
        return App(subst(j, s, t.fun), subst(j, s, t.arg))
    elif isinstance(t, Lam):
        return Lam(subst(j + 1, shift(1, 0, s), t.body))
    raise TypeError(f"Unknown term type: {type(t)}")


# ─── Algorithm 3: Variable Occurrence Counting ──────────────────────────

def var_occurrences(k: int, t: Term) -> int:
    """
    Count occurrences of variable k in term t.
    
    Under lambda binders, k is incremented to track the same
    semantic variable through the scope.
    
    Time complexity: O(|t|)
    Space complexity: O(depth(t)) for recursion stack
    
    Corresponds to DBTerm.varOccurrences.
    
    >>> var_occurrences(0, Var(0))
    1
    >>> var_occurrences(0, App(Var(0), Var(0)))
    2
    >>> var_occurrences(0, Lam(Var(0)))  # var 0 is bound, tracked as var 1
    0
    """
    if isinstance(t, Var):
        return 1 if t.index == k else 0
    elif isinstance(t, App):
        return var_occurrences(k, t.fun) + var_occurrences(k, t.arg)
    elif isinstance(t, Lam):
        return var_occurrences(k + 1, t.body)
    raise TypeError


# ─── Algorithm 4: Affine Checking ───────────────────────────────────────

def is_affine_at(k: int, t: Term) -> bool:
    """Check if variable k occurs at most once in t."""
    return var_occurrences(k, t) <= 1

def is_affine_closed(t: Term) -> bool:
    """
    Check if t is affine-closed: every bound variable used ≤ once.
    
    Time complexity: O(|t|²) naive, O(|t|) with memoization
    Space complexity: O(depth(t))
    
    Corresponds to DBTerm.AffineClosed.
    
    >>> is_affine_closed(Lam(Var(0)))
    True
    >>> is_affine_closed(Lam(App(Var(0), Var(0))))
    False
    """
    if isinstance(t, Var):
        return True
    elif isinstance(t, App):
        return is_affine_closed(t.fun) and is_affine_closed(t.arg)
    elif isinstance(t, Lam):
        return is_affine_at(0, t.body) and is_affine_closed(t.body)
    raise TypeError


# ─── Algorithm 5: Branch Complexity ─────────────────────────────────────

def branch_complexity(t: Term) -> int:
    """
    Count application nodes (branching points).
    
    This is the key complexity measure. The certified monotonicity
    theorem guarantees this never increases under affine β-reduction.
    
    Time complexity: O(|t|)
    
    Corresponds to DBTerm.branchComplexityDB.
    
    >>> branch_complexity(Var(0))
    0
    >>> branch_complexity(App(Var(0), Var(1)))
    1
    >>> branch_complexity(Lam(App(Var(0), Var(1))))
    1
    """
    if isinstance(t, Var):
        return 0
    elif isinstance(t, App):
        return 1 + branch_complexity(t.fun) + branch_complexity(t.arg)
    elif isinstance(t, Lam):
        return branch_complexity(t.body)
    raise TypeError


# ─── Algorithm 6: Redex Counting ────────────────────────────────────────

def redex_count(t: Term) -> int:
    """
    Count β-redexes in t.
    
    For affine-closed terms: redex_count(t) ≤ term_size(t)
    (No-contraction resource law, Theorem D).
    
    >>> redex_count(App(Lam(Var(0)), Var(1)))
    1
    """
    if isinstance(t, Var):
        return 0
    elif isinstance(t, App):
        if isinstance(t.fun, Lam):
            return 1 + redex_count(t.arg)
        return redex_count(t.fun) + redex_count(t.arg)
    elif isinstance(t, Lam):
        return redex_count(t.body)
    raise TypeError


def term_size(t: Term) -> int:
    """Count constructors in t."""
    if isinstance(t, Var):
        return 1
    elif isinstance(t, App):
        return 1 + term_size(t.fun) + term_size(t.arg)
    elif isinstance(t, Lam):
        return 1 + term_size(t.body)
    raise TypeError


# ─── Algorithm 7: One-Step β-Reduction ──────────────────────────────────

def beta_reducts(t: Term) -> list[Term]:
    """
    Enumerate all one-step β-reducts of t.
    
    Implements BetaDB from the formal development.
    Returns all terms reachable by a single β-step.
    
    Time complexity: O(|t| · |body|) per reduct
    
    >>> len(beta_reducts(App(Lam(Var(0)), Var(1))))
    1
    """
    results = []
    if isinstance(t, App):
        # Beta rule: (λ.body) arg → subst 0 arg body
        if isinstance(t.fun, Lam):
            results.append(subst(0, t.arg, t.fun.body))
        # Context: reduce in function position
        for r in beta_reducts(t.fun):
            results.append(App(r, t.arg))
        # Context: reduce in argument position
        for r in beta_reducts(t.arg):
            results.append(App(t.fun, r))
    elif isinstance(t, Lam):
        # Context: reduce under lambda
        for r in beta_reducts(t.body):
            results.append(Lam(r))
    return results


# ─── Algorithm 8: Reduction Path Explorer ───────────────────────────────

def explore_reductions(t: Term, max_depth: int = 10) -> dict:
    """
    Explore all β-reduction paths from t up to given depth.
    
    Returns statistics about the reduction graph:
    - reachable: set of all reachable terms
    - max_bc: maximum branch complexity encountered
    - min_bc: minimum branch complexity encountered
    - monotone: whether BC never increased
    - path_count: number of distinct reduction paths
    
    Time complexity: O(|reachable| · |t_max|) where t_max is largest reachable term
    """
    bc_t = branch_complexity(t)
    visited = {t}
    frontier = [(t, 0)]
    max_bc = bc_t
    min_bc = bc_t
    monotone = True
    path_count = 0
    
    while frontier:
        new_frontier = []
        for term, depth in frontier:
            if depth >= max_depth:
                continue
            for r in beta_reducts(term):
                bc_r = branch_complexity(r)
                if bc_r > bc_t:
                    monotone = False
                max_bc = max(max_bc, bc_r)
                min_bc = min(min_bc, bc_r)
                path_count += 1
                if r not in visited:
                    visited.add(r)
                    new_frontier.append((r, depth + 1))
        frontier = new_frontier
    
    return {
        "reachable_count": len(visited),
        "initial_bc": bc_t,
        "max_bc": max_bc,
        "min_bc": min_bc,
        "monotone": monotone,
        "path_count": path_count,
    }


# ─── Algorithm 9: Random Affine Term Generator ─────────────────────────

def random_affine_term(size: int, depth: int = 0) -> Optional[Term]:
    """
    Generate a random affine-closed de Bruijn term.
    
    Strategy: build terms bottom-up, rejecting non-affine results.
    Each bound variable is used at most once in its scope.
    
    Args:
        size: target term size (approximate)
        depth: current binding depth (internal)
    
    Returns:
        An affine-closed term, or None if generation fails.
    
    Time complexity: O(size²) expected with rejection sampling
    """
    if size <= 1:
        if depth > 0 and random.random() < 0.6:
            return Var(random.randint(0, depth - 1))
        return Var(depth + random.randint(0, 2))
    
    if random.random() < 0.35 and size >= 2:
        body = random_affine_term(size - 1, depth + 1)
        if body is not None and var_occurrences(0, body) <= 1:
            result = Lam(body)
            if is_affine_closed(result):
                return result
    
    if size >= 3:
        split = random.randint(1, size - 2)
        left = random_affine_term(split, depth)
        right = random_affine_term(size - 1 - split, depth)
        if left is not None and right is not None:
            result = App(left, right)
            if is_affine_closed(result):
                return result
    
    return Var(random.randint(0, max(0, depth - 1)))


def generate_affine_terms(count: int, min_size: int = 5, max_size: int = 20) -> list[Term]:
    """Generate multiple affine-closed terms."""
    terms = []
    attempts = 0
    while len(terms) < count and attempts < count * 20:
        size = random.randint(min_size, max_size)
        t = random_affine_term(size)
        if t is not None and is_affine_closed(t) and term_size(t) >= min_size:
            terms.append(t)
        attempts += 1
    return terms


# ─── Main ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import doctest
    doctest.testmod()
    
    print("Algorithms module loaded. Key functions:")
    print("  shift(d, c, t)          - De Bruijn shift")
    print("  subst(j, s, t)          - Capture-avoiding substitution")
    print("  branch_complexity(t)    - Count application nodes")
    print("  is_affine_closed(t)     - Check affine property")
    print("  beta_reducts(t)         - One-step β-reducts")
    print("  explore_reductions(t,d) - Explore reduction paths")
    print("  random_affine_term(n)   - Generate random affine term")
