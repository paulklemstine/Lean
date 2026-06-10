#!/usr/bin/env python3
"""
Algorithms for Weighted Tree Automata over the Tropical Semiring

Implements:
1. Bottom-up WTA evaluation (dynamic programming on trees)
2. Product automaton construction
3. Union semantic decomposition
4. Finite-family ensemble evaluation
5. Viterbi-style optimal run extraction

All algorithms operate over the min-plus (tropical) semiring where:
- ⊕ (tropical addition) = min
- ⊗ (tropical multiplication) = +
"""

import math
from typing import Dict, List, Tuple, Any, Optional, Set
from dataclasses import dataclass, field
from itertools import product as cartesian_product
import time


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class Tree:
    """Ranked tree with symbol and children."""
    symbol: str
    children: List['Tree'] = field(default_factory=list)

    def depth(self) -> int:
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def size(self) -> int:
        return 1 + sum(c.size() for c in self.children)

    def __repr__(self):
        if not self.children:
            return self.symbol
        return f"{self.symbol}({', '.join(repr(c) for c in self.children)})"


@dataclass
class WTA:
    """Weighted Tree Automaton.

    Attributes:
        states: List of state identifiers
        arity: Mapping from symbols to their arity
        delta: Transition cost function (symbol, child_states_tuple, target_state) -> cost
        final_cost: Final state cost function (state) -> cost
    """
    states: List[Any]
    arity: Dict[str, int]
    delta: Any  # Callable
    final_cost: Any  # Callable


# ============================================================
# Algorithm 1: Bottom-Up Evaluation (Dynamic Programming)
# ============================================================

def eval_state_dp(wta: WTA, tree: Tree, memo: Optional[dict] = None) -> Dict[Any, float]:
    """
    Bottom-up dynamic programming evaluation of a WTA on a tree.

    Returns a dictionary mapping each state q to the minimum cost of
    processing the tree and arriving at state q.

    Time complexity: O(|T| · |Q|^(max_arity+1))
    Space complexity: O(|T| · |Q|)

    where |T| = tree size, |Q| = number of states, max_arity = max symbol arity.
    """
    if memo is None:
        memo = {}

    tree_id = id(tree)
    if tree_id in memo:
        return memo[tree_id]

    symbol = tree.symbol
    k = wta.arity[symbol]
    assert len(tree.children) == k

    # Recursively evaluate children
    child_results = [eval_state_dp(wta, tree.children[i], memo) for i in range(k)]

    result = {}
    for q in wta.states:
        best = math.inf
        if k == 0:
            best = wta.delta(symbol, (), q)
        else:
            for child_states in cartesian_product(wta.states, repeat=k):
                child_cost = sum(
                    child_results[i][child_states[i]]
                    for i in range(k)
                )
                transition_cost = wta.delta(symbol, child_states, q)
                best = min(best, child_cost + transition_cost)
        result[q] = best

    memo[tree_id] = result
    return result


def eval_dp(wta: WTA, tree: Tree) -> float:
    """
    Evaluate a WTA on a tree using bottom-up dynamic programming.

    Returns the minimum cost: min_q (eval_state(t, q) + final_cost(q))

    This is the main evaluation algorithm.
    """
    state_costs = eval_state_dp(wta, tree)
    return min(
        state_costs[q] + wta.final_cost(q)
        for q in wta.states
    )


# ============================================================
# Algorithm 2: Product Automaton Construction
# ============================================================

def construct_product(A1: WTA, A2: WTA) -> WTA:
    """
    Construct the product automaton A1 ⊗ A2.

    Product state space: Q1 × Q2
    Product transition: δ_prod(a, qs, (q1,q2)) = δ1(a, qs1, q1) + δ2(a, qs2, q2)
    Product final cost: f_prod((q1,q2)) = f1(q1) + f2(q2)

    The product automaton satisfies:
        eval(A1 ⊗ A2, t) = eval(A1, t) + eval(A2, t)

    Time complexity of construction: O(|Q1| · |Q2|) states
    Evaluation complexity: O(|T| · (|Q1|·|Q2|)^(max_arity+1))

    Args:
        A1, A2: Input weighted tree automata over the same signature.

    Returns:
        Product automaton with state space Q1 × Q2.
    """
    states = [(q1, q2) for q1 in A1.states for q2 in A2.states]

    def delta(sym, child_states, target):
        q1, q2 = target
        cs1 = tuple(c[0] for c in child_states)
        cs2 = tuple(c[1] for c in child_states)
        return A1.delta(sym, cs1, q1) + A2.delta(sym, cs2, q2)

    def final(state):
        return A1.final_cost(state[0]) + A2.final_cost(state[1])

    return WTA(states, A1.arity, delta, final)


# ============================================================
# Algorithm 3: Viterbi-Style Optimal Run Extraction
# ============================================================

@dataclass
class Run:
    """An optimal run: assignment of states to tree nodes."""
    state: Any
    children: List['Run'] = field(default_factory=list)
    cost: float = 0.0

    def __repr__(self):
        if not self.children:
            return f"[{self.state}:{self.cost:.2f}]"
        child_strs = ", ".join(repr(c) for c in self.children)
        return f"[{self.state}:{self.cost:.2f}]({child_strs})"


def viterbi_run(wta: WTA, tree: Tree) -> Tuple[float, Run]:
    """
    Extract the optimal run (Viterbi decoding for trees).

    Returns the minimum cost and the corresponding state assignment.

    Time complexity: O(|T| · |Q|^(max_arity+1))
    Space complexity: O(|T| · |Q|)
    """
    memo = {}

    def best_run(t: Tree, target_state) -> Tuple[float, Run]:
        key = (id(t), target_state)
        if key in memo:
            return memo[key]

        symbol = t.symbol
        k = wta.arity[symbol]

        if k == 0:
            cost = wta.delta(symbol, (), target_state)
            result = (cost, Run(state=target_state, cost=cost))
        else:
            best_cost = math.inf
            best_children = None
            best_child_states = None

            for child_states in cartesian_product(wta.states, repeat=k):
                child_runs = [best_run(t.children[i], child_states[i]) for i in range(k)]
                child_cost = sum(cr[0] for cr in child_runs)
                trans_cost = wta.delta(symbol, child_states, target_state)
                total = child_cost + trans_cost

                if total < best_cost:
                    best_cost = total
                    best_children = [cr[1] for cr in child_runs]
                    best_child_states = child_states

            result = (best_cost, Run(
                state=target_state,
                children=best_children or [],
                cost=best_cost
            ))

        memo[key] = result
        return result

    # Find globally optimal state
    best_cost = math.inf
    best_run_result = None
    for q in wta.states:
        cost, run = best_run(tree, q)
        total = cost + wta.final_cost(q)
        if total < best_cost:
            best_cost = total
            best_run_result = run

    return best_cost, best_run_result


# ============================================================
# Algorithm 4: Ensemble Evaluation
# ============================================================

def ensemble_min_eval(automata: List[WTA], tree: Tree) -> Tuple[float, int]:
    """
    Evaluate an ensemble of automata and return the minimum cost
    and the index of the automaton achieving it.

    This implements Core Theorem C: the infimum over any finite family
    of recognizable tree series is recognizable.

    Args:
        automata: List of WTAs over the same signature.
        tree: Input tree.

    Returns:
        (minimum_cost, best_automaton_index)
    """
    results = [(eval_dp(a, tree), i) for i, a in enumerate(automata)]
    return min(results, key=lambda x: x[0])


# ============================================================
# Benchmarking
# ============================================================

def benchmark_product_vs_separate(A1: WTA, A2: WTA, trees: List[Tree]):
    """
    Benchmark: evaluating the product automaton vs. evaluating
    both automata separately and adding.
    """
    Aprod = construct_product(A1, A2)

    # Method 1: Separate evaluation
    start = time.time()
    results_sep = [(eval_dp(A1, t) + eval_dp(A2, t)) for t in trees]
    time_sep = time.time() - start

    # Method 2: Product evaluation
    start = time.time()
    results_prod = [eval_dp(Aprod, t) for t in trees]
    time_prod = time.time() - start

    # Verify correctness
    max_err = max(abs(a - b) for a, b in zip(results_sep, results_prod))

    return {
        "time_separate": time_sep,
        "time_product": time_prod,
        "max_error": max_err,
        "num_trees": len(trees),
        "product_states": len(Aprod.states),
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Tree Automata Algorithms")
    print("=" * 50)

    # Define a simple WTA
    arity = {"a": 0, "f": 2}
    A = WTA(
        states=[0, 1],
        arity=arity,
        delta=lambda s, cs, q: (
            {0: 0.0, 1: 1.0}[q] if s == "a" else
            {0: 0.5, 1: 1.5}[q]
        ),
        final_cost=lambda q: {0: 0.0, 1: 0.5}[q]
    )

    # Build a tree
    leaf = Tree("a")
    t = Tree("f", [leaf, leaf])
    t2 = Tree("f", [t, leaf])

    print(f"\nTree: {t2}")
    print(f"Eval: {eval_dp(A, t2):.3f}")

    cost, run = viterbi_run(A, t2)
    print(f"Viterbi cost: {cost:.3f}")
    print(f"Optimal run: {run}")

    # Product benchmark
    B = WTA(
        states=[0, 1, 2],
        arity=arity,
        delta=lambda s, cs, q: q * 0.3 + (0.1 if s == "a" else 0.4),
        final_cost=lambda q: q * 0.2
    )

    def make_tree(depth):
        if depth == 0:
            return Tree("a")
        return Tree("f", [make_tree(depth - 1), make_tree(depth - 1)])

    trees = [make_tree(d) for d in range(5)]
    result = benchmark_product_vs_separate(A, B, trees)
    print(f"\nBenchmark:")
    print(f"  Separate eval time: {result['time_separate']*1000:.1f}ms")
    print(f"  Product eval time:  {result['time_product']*1000:.1f}ms")
    print(f"  Max error: {result['max_error']:.2e}")
    print(f"  Product states: {result['product_states']}")
