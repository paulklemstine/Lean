#!/usr/bin/env python3
"""
Algorithms for Tropical Non-Encodability Analysis

This module implements algorithms for:
1. Testing downward-closure of Boolean predicates
2. Computing the antichain frontier of a Boolean predicate
3. Checking tropical sublevel representability
4. Computing tropical formula evaluation and monotonicity certificates
"""

from typing import Callable, List, Tuple, Set, Optional, FrozenSet
import itertools


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Downward-Closure Test
# ─────────────────────────────────────────────────────────────────────

def is_downward_closed(S: Set[Tuple[int, ...]], n: int, upper: int = 1) -> bool:
    """
    Test whether a set S ⊆ {0,...,upper}^n is downward closed.

    A set S is downward closed if whenever a ∈ S and b ≤ a componentwise,
    then b ∈ S.

    Time complexity: O(|S| · (upper+1)^n) in the worst case.
    For Boolean vectors (upper=1): O(|S| · 2^n).

    Args:
        S: Set of tuples representing the predicate's true set.
        n: Number of variables.
        upper: Maximum value per coordinate (default 1 for Boolean).

    Returns:
        True if S is downward closed.

    >>> is_downward_closed({(0,0), (1,0), (0,1)}, 2)
    True
    >>> is_downward_closed({(1,0), (0,1), (1,1)}, 2)
    False
    """
    for a in S:
        # Generate all b ≤ a
        ranges = [range(a[i] + 1) for i in range(n)]
        for b in itertools.product(*ranges):
            if b not in S:
                return False
    return True


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Antichain Frontier Computation
# ─────────────────────────────────────────────────────────────────────

def antichain_frontier(S: Set[Tuple[int, ...]], n: int) -> Set[Tuple[int, ...]]:
    """
    Compute the antichain frontier of a downward-closed set S ⊆ {0,1}^n.

    The frontier consists of the maximal elements of S — those elements
    a ∈ S such that no a' > a componentwise is also in S.

    For an arbitrary set, compute the minimal elements of the complement.

    Time complexity: O(|S| · n · |S|) via pairwise comparison.

    Args:
        S: Set of Boolean tuples.
        n: Number of variables.

    Returns:
        The antichain of maximal elements of S.

    >>> sorted(antichain_frontier({(0,0), (0,1), (1,0)}, 2))
    [(0, 1), (1, 0)]
    """
    maximal = set()
    for a in S:
        is_maximal = True
        for b in S:
            if b != a and all(a[i] <= b[i] for i in range(n)):
                is_maximal = False
                break
        if is_maximal:
            maximal.add(a)
    return maximal


def antichain_width(S: Set[Tuple[int, ...]], n: int) -> int:
    """
    Compute the width of the antichain frontier.

    This is a measure of the "complexity" of the boundary of S.
    Downward-closed sets have small antichain frontiers;
    SAT instances can have exponentially large ones.

    Args:
        S: Set of Boolean tuples.
        n: Number of variables.

    Returns:
        Size of the antichain frontier.
    """
    return len(antichain_frontier(S, n))


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Tropical Sublevel Representability Check
# ─────────────────────────────────────────────────────────────────────

def check_tropical_sublevel_representability(
    predicate: Callable[[Tuple[int, ...]], bool],
    n: int
) -> dict:
    """
    Check whether a Boolean predicate on {0,1}^n is representable
    as a tropical sublevel set.

    A predicate P is tropical-sublevel-representable if and only if
    its true set {a | P(a)} is downward closed in the componentwise order.

    This is a direct consequence of Theorem A (tropical monotonicity).

    Time complexity: O(2^n · 2^n) = O(4^n) for the closure check.

    Args:
        predicate: Function from {0,1}^n tuples to bool.
        n: Number of variables.

    Returns:
        Dictionary with:
        - 'representable': bool
        - 'true_set': the set where predicate is true
        - 'witness': if not representable, a pair (a, b) with b ≤ a,
          P(a) true, P(b) false.
    """
    true_set = set()
    for a in itertools.product(range(2), repeat=n):
        if predicate(a):
            true_set.add(a)

    # Check downward closure
    for a in true_set:
        ranges = [range(a[i] + 1) for i in range(n)]
        for b in itertools.product(*ranges):
            if b not in true_set:
                return {
                    'representable': False,
                    'true_set': true_set,
                    'witness': (a, b),
                    'reason': f'{b} ≤ {a}, P({a})=True but P({b})=False'
                }

    return {
        'representable': True,
        'true_set': true_set,
        'witness': None,
        'reason': 'True set is downward closed'
    }


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: CNF Analysis
# ─────────────────────────────────────────────────────────────────────

def cnf_sat_set(clauses: List[List[int]], n: int) -> Set[Tuple[int, ...]]:
    """
    Compute the satisfying assignment set of a CNF formula on {0,1}^n.

    Literals are signed: positive i means x_i, negative -(i+1) means ¬x_i.
    (Using 0-indexed variables.)

    Args:
        clauses: List of clauses, each a list of signed literal indices.
        n: Number of variables.

    Returns:
        Set of satisfying assignments.
    """
    sat = set()
    for a in itertools.product(range(2), repeat=n):
        satisfied = True
        for clause in clauses:
            clause_sat = False
            for lit in clause:
                if lit >= 0:
                    if a[lit] == 1:
                        clause_sat = True
                        break
                else:
                    if a[-lit - 1] == 0:
                        clause_sat = True
                        break
            if not clause_sat:
                satisfied = False
                break
        if satisfied:
            sat.add(a)
    return sat


def analyze_cnf_representability(clauses: List[List[int]], n: int) -> dict:
    """
    Full analysis of a CNF formula's tropical representability.

    Args:
        clauses: CNF formula as list of clauses.
        n: Number of variables.

    Returns:
        Comprehensive analysis dictionary.
    """
    sat = cnf_sat_set(clauses, n)
    dc = is_downward_closed(sat, n)
    frontier = antichain_frontier(sat, n)

    result = {
        'n_vars': n,
        'n_clauses': len(clauses),
        'sat_count': len(sat),
        'is_downward_closed': dc,
        'tropical_representable': dc,
        'frontier_width': len(frontier),
        'frontier': sorted(frontier),
    }

    if not dc:
        # Find witness
        for a in sat:
            for b in itertools.product(*[range(a[i] + 1) for i in range(n)]):
                if b not in sat:
                    result['witness'] = (a, b)
                    break
            if 'witness' in result:
                break

    return result


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Tropical Formula Enumeration and Evaluation
# ─────────────────────────────────────────────────────────────────────

class TropFormula:
    """Tropical formula in the semiring (ℕ, min, +)."""
    pass

class TConst(TropFormula):
    def __init__(self, c): self.c = c
    def __repr__(self): return str(self.c)
    def eval(self, a): return self.c
    def size(self): return 1

class TVar(TropFormula):
    def __init__(self, i): self.i = i
    def __repr__(self): return f"x{self.i}"
    def eval(self, a): return a[self.i]
    def size(self): return 1

class TAdd(TropFormula):
    def __init__(self, l, r): self.l, self.r = l, r
    def __repr__(self): return f"({self.l}+{self.r})"
    def eval(self, a): return self.l.eval(a) + self.r.eval(a)
    def size(self): return 1 + self.l.size() + self.r.size()

class TMin(TropFormula):
    def __init__(self, l, r): self.l, self.r = l, r
    def __repr__(self): return f"min({self.l},{self.r})"
    def eval(self, a): return min(self.l.eval(a), self.r.eval(a))
    def size(self): return 1 + self.l.size() + self.r.size()


def enumerate_tropical_formulas(n_vars: int, max_depth: int):
    """
    Enumerate all tropical formulas up to a given depth.

    Yields (formula, depth) pairs.

    Args:
        n_vars: Number of variables.
        max_depth: Maximum nesting depth.
    """
    if max_depth == 0:
        for c in range(4):
            yield TConst(c)
        for i in range(n_vars):
            yield TVar(i)
        return

    base = list(enumerate_tropical_formulas(n_vars, max_depth - 1))
    yield from (f for f in base)
    for f1 in base:
        for f2 in base:
            yield TAdd(f1, f2)
            yield TMin(f1, f2)


# ─────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: Check representability of x₁ ∨ x₂
    print("\n--- CNF: x₀ ∨ x₁ ---")
    result = analyze_cnf_representability([[0, 1]], 2)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 2: Check representability of x₁ ∧ x₂
    print("\n--- CNF: x₀ ∧ x₁ (= two unit clauses) ---")
    result = analyze_cnf_representability([[0], [1]], 2)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 3: A more complex CNF
    print("\n--- CNF: (x₀ ∨ x₁) ∧ (¬x₀ ∨ ¬x₁) (= XOR-like) ---")
    result = analyze_cnf_representability([[0, 1], [-1, -2]], 2)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 4: Downward-closed CNF (all negative literals)
    print("\n--- CNF: ¬x₀ ∧ ¬x₁ ---")
    result = analyze_cnf_representability([[-1], [-2]], 2)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 5: Antichain frontier for {0,1}^3
    print("\n--- Antichain analysis for x₀ ∨ x₁ ∨ x₂ ---")
    result = analyze_cnf_representability([[0, 1, 2]], 3)
    for k, v in result.items():
        print(f"  {k}: {v}")
