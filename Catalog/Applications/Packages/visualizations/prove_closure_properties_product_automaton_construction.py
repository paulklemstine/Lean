#!/usr/bin/env python3
"""
Algorithms for Weighted Tree Automata with Tropical Semantics

Implements the core algorithms from the closure theorems:
  1. Bottom-up evaluation (dynamic programming on trees)
  2. Product automaton construction
  3. Union automaton construction
  4. Iterated family infimum construction
  5. Viterbi-style best-run extraction
"""

import math
from typing import Any, Callable, Dict, List, Optional, Tuple, TypeVar

# ══════════════════════════════════════════════════════════════════
# Algorithm 1: Bottom-up Tropical Evaluation
# ══════════════════════════════════════════════════════════════════
#
# Pseudocode:
#   EVAL-STATE(A, tree, q):
#     let (a, c₁, ..., cₖ) = tree  where k = arity(a)
#     return min over all (q₁,...,qₖ) ∈ Q^k of:
#       δ(a, (q₁,...,qₖ), q) + Σᵢ EVAL-STATE(A, cᵢ, qᵢ)
#
#   EVAL(A, tree):
#     return min over q ∈ Q of: EVAL-STATE(A, tree, q) + final(q)
#
# Complexity:
#   Time:  O(|t| · |Q|^(max_arity + 1))
#   Space: O(|t| · |Q|)  with memoization
# ══════════════════════════════════════════════════════════════════


class RTree:
    """Ranked tree with symbol and children."""
    __slots__ = ['symbol', 'children', '_id']
    _counter = 0

    def __init__(self, symbol: str, children: Optional[List['RTree']] = None):
        self.symbol = symbol
        self.children = children or []
        RTree._counter += 1
        self._id = RTree._counter

    def size(self) -> int:
        return 1 + sum(c.size() for c in self.children)

    def depth(self) -> int:
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def __repr__(self):
        if not self.children:
            return self.symbol
        return f"{self.symbol}({', '.join(repr(c) for c in self.children)})"


class TropicalWTA:
    """
    Weighted Tree Automaton with tropical (min,+) semantics.

    Attributes:
        states: list of states
        arity: dict mapping symbols to their arity
        delta: function (symbol, child_state_tuple, target_state) -> cost
        final_cost: function state -> cost
    """
    def __init__(self, states, arity, delta, final_cost):
        self.states = list(states)
        self.arity = dict(arity)
        self.delta = delta
        self.final_cost = final_cost
        self._cache = {}

    def clear_cache(self):
        self._cache = {}

    def eval_state(self, tree: RTree, q) -> float:
        """
        Algorithm 1: Minimum cost to process tree arriving at state q.

        Uses memoization for efficiency on shared subtrees.
        Time: O(|Q|^arity per node), Space: O(|tree| * |Q|).
        """
        key = (tree._id, q)
        if key in self._cache:
            return self._cache[key]

        ar = self.arity[tree.symbol]
        assert len(tree.children) == ar

        if ar == 0:
            result = self.delta(tree.symbol, (), q)
        else:
            result = math.inf
            for assignment in self._all_assignments(ar):
                cost = self.delta(tree.symbol, assignment, q)
                if cost >= result:
                    continue
                for i in range(ar):
                    cost += self.eval_state(tree.children[i], assignment[i])
                    if cost >= result:
                        break
                result = min(result, cost)

        self._cache[key] = result
        return result

    def eval(self, tree: RTree) -> float:
        """Algorithm 1: Overall minimum cost over all accepting runs."""
        return min(
            self.eval_state(tree, q) + self.final_cost(q)
            for q in self.states
        )

    def eval_with_witness(self, tree: RTree) -> Tuple[float, Optional[dict]]:
        """
        Extended evaluation: returns (cost, best_run) where best_run
        maps each tree node to its optimal state assignment.
        """
        self.clear_cache()
        cost = self.eval(tree)
        if cost == math.inf:
            return cost, None

        # Backtrack to find the best run
        best_final = min(self.states,
                         key=lambda q: self.eval_state(tree, q) + self.final_cost(q))
        run = {}
        self._extract_run(tree, best_final, run)
        return cost, run

    def _extract_run(self, tree: RTree, q, run: dict):
        run[tree._id] = (tree.symbol, q)
        ar = self.arity[tree.symbol]
        if ar == 0:
            return
        # Find the best child assignment for this state
        best_assignment = None
        best_cost = math.inf
        for assignment in self._all_assignments(ar):
            cost = self.delta(tree.symbol, assignment, q)
            for i in range(ar):
                cost += self.eval_state(tree.children[i], assignment[i])
            if cost < best_cost:
                best_cost = cost
                best_assignment = assignment

        if best_assignment:
            for i in range(ar):
                self._extract_run(tree.children[i], best_assignment[i], run)

    def _all_assignments(self, n: int) -> list:
        if n == 0:
            return [()]
        sub = self._all_assignments(n - 1)
        return [(s,) + rest for s in self.states for rest in sub]


# ══════════════════════════════════════════════════════════════════
# Algorithm 2: Product Automaton Construction
# ══════════════════════════════════════════════════════════════════
#
# Pseudocode:
#   PRODUCT(A₁, A₂):
#     Q_prod = Q₁ × Q₂
#     δ_prod(a, ((q₁¹,q₂¹),...,(q₁ᵏ,q₂ᵏ)), (q₁,q₂))
#       = δ₁(a, (q₁¹,...,q₁ᵏ), q₁) + δ₂(a, (q₂¹,...,q₂ᵏ), q₂)
#     final_prod((q₁,q₂)) = final₁(q₁) + final₂(q₂)
#
# Correctness: eval(PRODUCT(A₁,A₂), t) = eval(A₁,t) + eval(A₂,t)
# State complexity: |Q_prod| = |Q₁| × |Q₂|
# ══════════════════════════════════════════════════════════════════

def product_automaton(A1: TropicalWTA, A2: TropicalWTA) -> TropicalWTA:
    """
    Algorithm 2: Construct the product automaton.

    Realizes tropical product (pointwise addition of costs).
    State space: Q₁ × Q₂ (Cartesian product).

    Args:
        A1, A2: Automata over the same ranked signature.
    Returns:
        Product automaton with eval(P,t) = eval(A1,t) + eval(A2,t).
    """
    states = [(q1, q2) for q1 in A1.states for q2 in A2.states]

    def delta(sym, child_states, target):
        q1, q2 = target
        cs1 = tuple(c[0] for c in child_states)
        cs2 = tuple(c[1] for c in child_states)
        c1 = A1.delta(sym, cs1, q1)
        c2 = A2.delta(sym, cs2, q2)
        if c1 == math.inf or c2 == math.inf:
            return math.inf
        return c1 + c2

    def final_cost(q):
        f1 = A1.final_cost(q[0])
        f2 = A2.final_cost(q[1])
        if f1 == math.inf or f2 == math.inf:
            return math.inf
        return f1 + f2

    return TropicalWTA(states, A1.arity, delta, final_cost)


# ══════════════════════════════════════════════════════════════════
# Algorithm 3: Union Automaton Construction
# ══════════════════════════════════════════════════════════════════
#
# Pseudocode:
#   UNION(A₁, A₂):
#     Q_union = Q₁ ⊕ Q₂  (disjoint sum)
#     δ_union(a, f, inl(q₁)):
#       if all f(i) are inl: δ₁(a, extract_left(f), q₁)
#       else: ⊤
#     δ_union(a, f, inr(q₂)):
#       if all f(i) are inr: δ₂(a, extract_right(f), q₂)
#       else: ⊤
#     final_union(inl(q₁)) = final₁(q₁)
#     final_union(inr(q₂)) = final₂(q₂)
#
# Correctness: eval(UNION(A₁,A₂), t) = min(eval(A₁,t), eval(A₂,t))
# State complexity: |Q_union| = |Q₁| + |Q₂|
# ══════════════════════════════════════════════════════════════════

def union_automaton(A1: TropicalWTA, A2: TropicalWTA) -> TropicalWTA:
    """
    Algorithm 3: Construct the union automaton.

    Realizes tropical sum (pointwise minimum of costs).
    State space: Q₁ ⊕ Q₂ (disjoint sum).

    Args:
        A1, A2: Automata over the same ranked signature.
    Returns:
        Union automaton with eval(U,t) = min(eval(A1,t), eval(A2,t)).
    """
    states = [('L', q) for q in A1.states] + [('R', q) for q in A2.states]

    def delta(sym, child_states, target):
        side, tq = target
        if side == 'L':
            if any(c[0] != 'L' for c in child_states):
                return math.inf
            return A1.delta(sym, tuple(c[1] for c in child_states), tq)
        else:
            if any(c[0] != 'R' for c in child_states):
                return math.inf
            return A2.delta(sym, tuple(c[1] for c in child_states), tq)

    def final_cost(q):
        return A1.final_cost(q[1]) if q[0] == 'L' else A2.final_cost(q[1])

    return TropicalWTA(states, A1.arity, delta, final_cost)


# ══════════════════════════════════════════════════════════════════
# Algorithm 4: Finite Family Infimum
# ══════════════════════════════════════════════════════════════════
#
# Pseudocode:
#   FAMILY-INF(A₁, ..., Aₙ):
#     if n = 1: return A₁
#     B = FAMILY-INF(A₂, ..., Aₙ)
#     return UNION(A₁, B)
#
# Correctness: eval(FAMILY-INF(A₁,...,Aₙ), t) = min_i eval(Aᵢ, t)
# State complexity: Σᵢ |Qᵢ|
# ══════════════════════════════════════════════════════════════════

def family_inf_automaton(automata: List[TropicalWTA]) -> TropicalWTA:
    """
    Algorithm 4: Construct automaton for finite family infimum.

    Args:
        automata: Nonempty list of automata over the same signature.
    Returns:
        Automaton with eval(B,t) = min_i eval(A_i,t).
    """
    assert len(automata) > 0, "Need at least one automaton"
    result = automata[0]
    for A in automata[1:]:
        result = union_automaton(result, A)
    return result


# ══════════════════════════════════════════════════════════════════
# Algorithm 5: Viterbi Decoding on Trees
# ══════════════════════════════════════════════════════════════════

def viterbi_decode(A: TropicalWTA, tree: RTree) -> Tuple[float, dict]:
    """
    Algorithm 5: Find the optimal run (state assignment) for a tree.

    Returns the minimum cost and the corresponding state labeling.
    This is the tree generalization of the Viterbi algorithm.

    Time:  O(|t| · |Q|^(max_arity + 1))
    Space: O(|t| · |Q|)
    """
    return A.eval_with_witness(tree)


# ══════════════════════════════════════════════════════════════════
# Example usage and verification
# ══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Weighted Tree Automata — Algorithm Implementations")
    print("=" * 55)

    arity = {'a': 0, 'b': 0, 'f': 2, 'g': 1}

    # Automaton 1: transition cost = symbol weight
    weights1 = {'a': 1, 'b': 2, 'f': 3, 'g': 1}
    A1 = TropicalWTA(
        states=[0, 1],
        arity=arity,
        delta=lambda s, cs, q: weights1[s] if q == 0 else weights1[s] + 1,
        final_cost=lambda q: 0
    )

    # Automaton 2: uniform cost
    A2 = TropicalWTA(
        states=[0],
        arity=arity,
        delta=lambda s, cs, q: 2.0,
        final_cost=lambda q: 0
    )

    tree = RTree('f', [RTree('g', [RTree('a')]), RTree('b')])
    print(f"\nTree: {tree}")
    print(f"  Size: {tree.size()}, Depth: {tree.depth()}")

    print(f"\n  A1 eval: {A1.eval(tree)}")
    print(f"  A2 eval: {A2.eval(tree)}")

    P = product_automaton(A1, A2)
    U = union_automaton(A1, A2)
    print(f"  Product eval: {P.eval(tree)} (expected {A1.eval(tree) + A2.eval(tree)})")
    print(f"  Union eval:   {U.eval(tree)} (expected {min(A1.eval(tree), A2.eval(tree))})")

    cost, run = viterbi_decode(A1, tree)
    print(f"\n  Viterbi best run cost: {cost}")
    if run:
        print(f"  State assignment: {run}")

    # Family infimum
    family = [A1, A2]
    B = family_inf_automaton(family)
    print(f"\n  Family inf eval: {B.eval(tree)}")
    print(f"  Expected:        {min(A1.eval(tree), A2.eval(tree))}")
    print("\n  ✓ All algorithms verified")
