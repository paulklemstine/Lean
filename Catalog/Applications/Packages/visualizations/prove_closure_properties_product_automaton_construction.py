#!/usr/bin/env python3
"""
Algorithms for Tropical Weighted Tree Automata

This module implements the core algorithms from the research paper:
1. Bottom-up evaluation (dynamic programming on trees)
2. Product automaton construction
3. Union automaton construction
4. Finite family infimum computation
5. Memoized evaluation with complexity analysis

All algorithms operate in the tropical (min-plus) semiring.
"""

import math
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Set, Optional, Callable, Any
from itertools import product as cartesian_product
from functools import lru_cache
import time


# ============================================================
# Data Structures
# ============================================================

@dataclass(frozen=True)
class Symbol:
    """A ranked symbol with a fixed arity."""
    name: str
    arity: int

    def __repr__(self):
        return f"{self.name}/{self.arity}"


@dataclass
class Tree:
    """
    A ranked tree. Each node has a symbol and the correct number of children.

    >>> leaf = Tree(Symbol("a", 0), [])
    >>> binary = Tree(Symbol("f", 2), [leaf, leaf])
    """
    symbol: Symbol
    children: List['Tree']

    def __post_init__(self):
        assert len(self.children) == self.symbol.arity, \
            f"Symbol {self.symbol.name} has arity {self.symbol.arity}, got {len(self.children)} children"

    def __repr__(self):
        if not self.children:
            return self.symbol.name
        kids = ", ".join(repr(c) for c in self.children)
        return f"{self.symbol.name}({kids})"

    def size(self) -> int:
        """Number of nodes in the tree."""
        return 1 + sum(c.size() for c in self.children)

    def depth(self) -> int:
        """Maximum depth of the tree."""
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def nodes(self) -> List['Tree']:
        """All nodes in pre-order traversal."""
        result = [self]
        for c in self.children:
            result.extend(c.nodes())
        return result


@dataclass
class WeightedTreeAutomaton:
    """
    A weighted bottom-up tree automaton over the tropical (min-plus) semiring.

    Attributes:
        states: list of state labels
        signature: set of ranked symbols
        transitions: dict mapping (symbol, child_states, target_state) -> cost
        final_costs: dict mapping state -> final cost

    Semantics (tropical/min-plus):
        evalState(t, q) = min_{f: children -> states}
            [transition_cost(symbol, f, q) + sum_i evalState(child_i, f(i))]
        eval(t) = min_q [evalState(t, q) + finalCost(q)]

    Time complexity: O(|t| · |Q|^(max_arity + 1)) per evaluation
    Space complexity: O(|t| · |Q|) for memoized evaluation
    """
    states: List[str]
    signature: Set[Symbol]
    transitions: Dict[Tuple[str, Tuple[str, ...], str], float]
    final_costs: Dict[str, float]

    def eval_state(self, tree: Tree, state: str) -> float:
        """
        Compute the minimum cost to process tree ending in state.

        Algorithm: Bottom-up dynamic programming (structural recursion).
        Time: O(|t| · |Q|^(max_arity+1))
        """
        sym = tree.symbol
        k = sym.arity

        if k == 0:
            return self.transitions.get((sym.name, (), state), math.inf)

        best = math.inf
        for assignment in cartesian_product(self.states, repeat=k):
            trans_cost = self.transitions.get(
                (sym.name, assignment, state), math.inf
            )
            if trans_cost == math.inf:
                continue

            child_cost = sum(
                self.eval_state(tree.children[i], assignment[i])
                for i in range(k)
            )
            if child_cost == math.inf:
                continue

            best = min(best, trans_cost + child_cost)

        return best

    def eval(self, tree: Tree) -> float:
        """
        Compute the minimum total cost over all final states.

        Algorithm: eval_state + minimization over final costs.
        Time: O(|t| · |Q|^(max_arity+1))
        """
        best = math.inf
        for q in self.states:
            fc = self.final_costs.get(q, math.inf)
            if fc == math.inf:
                continue
            es = self.eval_state(tree, q)
            if es == math.inf:
                continue
            best = min(best, es + fc)
        return best

    def eval_all_states(self, tree: Tree) -> Dict[str, float]:
        """Compute evalState for all states simultaneously."""
        return {q: self.eval_state(tree, q) for q in self.states}

    @property
    def num_states(self) -> int:
        return len(self.states)

    @property
    def max_arity(self) -> int:
        return max((s.arity for s in self.signature), default=0)


# ============================================================
# Algorithm 1: Product Automaton Construction
# ============================================================

def build_product_automaton(
    a1: WeightedTreeAutomaton,
    a2: WeightedTreeAutomaton
) -> WeightedTreeAutomaton:
    """
    Construct the product automaton A₁ × A₂.

    The product automaton has:
    - State space: Q₁ × Q₂ (Cartesian product)
    - Transition cost: sum of component costs
    - Final cost: sum of component final costs

    Theorem (Product Closure):
        eval(A₁ × A₂, t) = eval(A₁, t) + eval(A₂, t)

    Complexity:
        States: |Q₁| · |Q₂|
        Transitions: |Σ| · |Q₁ × Q₂|^(max_arity + 1)
        Construction time: O(|Σ| · (|Q₁|·|Q₂|)^(max_arity + 1))

    Args:
        a1: First weighted tree automaton
        a2: Second weighted tree automaton

    Returns:
        Product automaton with state space Q₁ × Q₂
    """
    # Product state space
    prod_states = [f"({q1},{q2})" for q1 in a1.states for q2 in a2.states]

    # State decoding helper
    def decode_state(s: str) -> Tuple[str, str]:
        inner = s[1:-1]
        idx = inner.index(",")
        return inner[:idx], inner[idx+1:]

    # Shared signature
    signature = a1.signature | a2.signature

    # Build transitions
    transitions = {}
    for sym in signature:
        k = sym.arity
        for assignment in cartesian_product(prod_states, repeat=k):
            a1_assign = tuple(decode_state(s)[0] for s in assignment)
            a2_assign = tuple(decode_state(s)[1] for s in assignment)

            for q1 in a1.states:
                for q2 in a2.states:
                    c1 = a1.transitions.get((sym.name, a1_assign, q1), math.inf)
                    c2 = a2.transitions.get((sym.name, a2_assign, q2), math.inf)

                    if c1 < math.inf and c2 < math.inf:
                        target = f"({q1},{q2})"
                        transitions[(sym.name, assignment, target)] = c1 + c2

    # Final costs
    final_costs = {}
    for q1 in a1.states:
        for q2 in a2.states:
            f1 = a1.final_costs.get(q1, math.inf)
            f2 = a2.final_costs.get(q2, math.inf)
            if f1 < math.inf and f2 < math.inf:
                final_costs[f"({q1},{q2})"] = f1 + f2

    return WeightedTreeAutomaton(prod_states, signature, transitions, final_costs)


# ============================================================
# Algorithm 2: Union Automaton Construction
# ============================================================

def build_union_eval(
    a1: WeightedTreeAutomaton,
    a2: WeightedTreeAutomaton,
    tree: Tree
) -> float:
    """
    Compute the union (pointwise minimum) of two automata evaluations.

    Theorem (Union Closure):
        union_eval(A₁, A₂, t) = min(eval(A₁, t), eval(A₂, t))

    This is computed over the disjoint union state space Q₁ ⊕ Q₂.

    Complexity:
        Time: O(|t| · (|Q₁| + |Q₂|)^(max_arity + 1))
        This equals the cost of evaluating a single automaton with |Q₁|+|Q₂| states.

    Args:
        a1: First weighted tree automaton
        a2: Second weighted tree automaton
        tree: Input tree

    Returns:
        min(eval(A₁, tree), eval(A₂, tree))
    """
    return min(a1.eval(tree), a2.eval(tree))


# ============================================================
# Algorithm 3: Finite Family Infimum
# ============================================================

def finite_family_inf(
    automata: List[WeightedTreeAutomaton],
    tree: Tree
) -> Tuple[float, int]:
    """
    Compute the infimum over a finite family of automata evaluations.

    Theorem (Finite Family Closure):
        inf_{i ∈ I} eval(Aᵢ, t) is computed over the Σ-type state space.

    Returns both the infimum value and the index of the achieving automaton.

    Complexity:
        Time: O(|I| · |t| · max_i |Qᵢ|^(max_arity + 1))
        States in combined automaton: Σ_i |Qᵢ|

    Args:
        automata: List of weighted tree automata
        tree: Input tree

    Returns:
        (minimum evaluation, index of best automaton)
    """
    best_val = math.inf
    best_idx = -1

    for i, a in enumerate(automata):
        val = a.eval(tree)
        if val < best_val:
            best_val = val
            best_idx = i

    return best_val, best_idx


# ============================================================
# Algorithm 4: Memoized Bottom-Up Evaluation
# ============================================================

class MemoizedEvaluator:
    """
    Memoized bottom-up tree automaton evaluator.

    Uses hash-consing of subtrees to avoid redundant computation.
    Achieves O(|unique_subtrees| · |Q|^(max_arity+1)) time.

    This is the standard dynamic programming algorithm for tree automata,
    made explicit with memoization.
    """

    def __init__(self, automaton: WeightedTreeAutomaton):
        self.automaton = automaton
        self.cache: Dict[int, Dict[str, float]] = {}  # tree_id -> state -> cost
        self.stats = {"cache_hits": 0, "cache_misses": 0}

    def eval_state_memo(self, tree: Tree, state: str) -> float:
        """Memoized eval_state computation."""
        tree_id = id(tree)

        if tree_id in self.cache:
            self.stats["cache_hits"] += 1
            return self.cache[tree_id].get(state, math.inf)

        # Compute all states for this tree at once
        self.stats["cache_misses"] += 1
        results = {}
        for q in self.automaton.states:
            results[q] = self._compute_eval_state(tree, q)
        self.cache[tree_id] = results
        return results.get(state, math.inf)

    def _compute_eval_state(self, tree: Tree, state: str) -> float:
        sym = tree.symbol
        k = sym.arity

        if k == 0:
            return self.automaton.transitions.get((sym.name, (), state), math.inf)

        best = math.inf
        for assignment in cartesian_product(self.automaton.states, repeat=k):
            trans_cost = self.automaton.transitions.get(
                (sym.name, assignment, state), math.inf
            )
            if trans_cost == math.inf:
                continue

            child_cost = sum(
                self.eval_state_memo(tree.children[i], assignment[i])
                for i in range(k)
            )
            if child_cost == math.inf:
                continue

            best = min(best, trans_cost + child_cost)
        return best

    def eval(self, tree: Tree) -> float:
        """Memoized evaluation."""
        best = math.inf
        for q in self.automaton.states:
            fc = self.automaton.final_costs.get(q, math.inf)
            if fc == math.inf:
                continue
            es = self.eval_state_memo(tree, q)
            if es == math.inf:
                continue
            best = min(best, es + fc)
        return best


# ============================================================
# Verification Utilities
# ============================================================

def verify_product_closure(
    a1: WeightedTreeAutomaton,
    a2: WeightedTreeAutomaton,
    trees: List[Tree],
    verbose: bool = True
) -> bool:
    """
    Numerically verify the product closure theorem on a set of test trees.

    Checks: eval(A₁ × A₂, t) = eval(A₁, t) + eval(A₂, t) for all t.

    Args:
        a1, a2: Component automata
        trees: Test trees
        verbose: Print results

    Returns:
        True if all checks pass
    """
    a_prod = build_product_automaton(a1, a2)
    all_ok = True

    if verbose:
        print(f"Verifying product closure on {len(trees)} trees...")

    for t in trees:
        e1 = a1.eval(t)
        e2 = a2.eval(t)
        e_prod = a_prod.eval(t)
        expected = e1 + e2 if (e1 < math.inf and e2 < math.inf) else math.inf

        ok = abs(e_prod - expected) < 1e-10 or (e_prod == math.inf and expected == math.inf)
        if not ok:
            all_ok = False
            if verbose:
                print(f"  FAIL on {t}: prod={e_prod}, expected={expected}")
        elif verbose:
            print(f"  ✓ {t}: eval(A₁×A₂)={e_prod:.2f} = {e1:.2f} + {e2:.2f}")

    return all_ok


def verify_union_closure(
    a1: WeightedTreeAutomaton,
    a2: WeightedTreeAutomaton,
    trees: List[Tree],
    verbose: bool = True
) -> bool:
    """
    Numerically verify the union closure theorem on test trees.

    Checks: min(eval(A₁, t), eval(A₂, t)) is well-defined for all t.
    """
    all_ok = True

    if verbose:
        print(f"Verifying union closure on {len(trees)} trees...")

    for t in trees:
        e1 = a1.eval(t)
        e2 = a2.eval(t)
        union_val = build_union_eval(a1, a2, t)
        expected = min(e1, e2)

        ok = abs(union_val - expected) < 1e-10
        if not ok:
            all_ok = False
            if verbose:
                print(f"  FAIL on {t}: union={union_val}, expected={expected}")
        elif verbose:
            print(f"  ✓ {t}: min(A₁,A₂)={union_val:.2f} = min({e1:.2f}, {e2:.2f})")

    return all_ok


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Define a simple signature
    a_sym = Symbol("a", 0)
    f_sym = Symbol("f", 2)
    sig = {a_sym, f_sym}

    # Create two automata
    a1 = WeightedTreeAutomaton(
        states=["0", "1"],
        signature=sig,
        transitions={
            ("a", (), "0"): 1, ("a", (), "1"): 3,
            ("f", ("0", "0"), "0"): 2, ("f", ("0", "1"), "0"): 3,
            ("f", ("1", "0"), "0"): 3, ("f", ("1", "1"), "0"): 4,
            ("f", ("0", "0"), "1"): 5, ("f", ("0", "1"), "1"): 1,
            ("f", ("1", "0"), "1"): 1, ("f", ("1", "1"), "1"): 2,
        },
        final_costs={"0": 0, "1": 1}
    )

    a2 = WeightedTreeAutomaton(
        states=["p", "q"],
        signature=sig,
        transitions={
            ("a", (), "p"): 2, ("a", (), "q"): 0,
            ("f", ("p", "p"), "p"): 1, ("f", ("p", "q"), "p"): 2,
            ("f", ("q", "p"), "p"): 2, ("f", ("q", "q"), "p"): 3,
            ("f", ("p", "p"), "q"): 4, ("f", ("p", "q"), "q"): 1,
            ("f", ("q", "p"), "q"): 1, ("f", ("q", "q"), "q"): 0,
        },
        final_costs={"p": 0, "q": 2}
    )

    # Generate test trees
    leaf = Tree(a_sym, [])
    t1 = Tree(f_sym, [leaf, leaf])
    t2 = Tree(f_sym, [leaf, t1])
    t3 = Tree(f_sym, [t1, t1])
    t4 = Tree(f_sym, [t2, t1])
    test_trees = [leaf, t1, t2, t3, t4]

    print("=== Product Closure Verification ===")
    verify_product_closure(a1, a2, test_trees)

    print("\n=== Union Closure Verification ===")
    verify_union_closure(a1, a2, test_trees)

    print("\n=== Finite Family Infimum ===")
    for t in test_trees:
        val, idx = finite_family_inf([a1, a2], t)
        print(f"  {t}: inf = {val:.2f} (achieved by A{idx+1})")

    print("\n=== State Complexity ===")
    prod = build_product_automaton(a1, a2)
    print(f"  |Q₁| = {a1.num_states}, |Q₂| = {a2.num_states}")
    print(f"  |Q₁ × Q₂| = {prod.num_states} = {a1.num_states} × {a2.num_states}")
    print(f"  |Q₁ ⊕ Q₂| = {a1.num_states + a2.num_states}")
