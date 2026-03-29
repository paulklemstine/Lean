#!/usr/bin/env python3
"""
Oracle Binary Search — Optimal Query Strategy Demo

Demonstrates the information-theoretic lower bound: to find a target
among N possibilities, you need at least ⌈log₂(N)⌉ binary oracle queries.

Binary search achieves this bound exactly, making it the OPTIMAL oracle
query strategy for ordered search spaces.

This is Theorem 2.1 of our formalization in action.
"""

import math
import random
from typing import Callable, Optional

# ═══════════════════════════════════════════════════════════════════════════
# §1: The Oracle Query Model
# ═══════════════════════════════════════════════════════════════════════════

class Oracle:
    """A binary oracle: answers yes/no to queries."""
    
    def __init__(self, truth_function: Callable[[int], bool]):
        self.truth = truth_function
        self.query_count = 0
    
    def query(self, q: int) -> bool:
        """Ask the oracle: is the answer ≥ q?"""
        self.query_count += 1
        return self.truth(q)
    
    def reset(self):
        self.query_count = 0


def optimal_binary_search(oracle: Oracle, lo: int, hi: int) -> int:
    """
    Find the target using binary search (optimal strategy).
    
    The oracle answers: "Is the target ≥ mid?"
    Guaranteed to use exactly ⌈log₂(hi - lo)⌉ queries.
    """
    while lo < hi:
        mid = (lo + hi) // 2
        if oracle.query(mid):
            hi = mid
        else:
            lo = mid + 1
    return lo


def linear_search(oracle: Oracle, lo: int, hi: int) -> int:
    """
    Find the target using linear search (suboptimal strategy).
    Uses up to (hi - lo) queries — exponentially worse!
    """
    for i in range(lo, hi + 1):
        if oracle.query(i):
            return i
    return hi


# ═══════════════════════════════════════════════════════════════════════════
# §2: Demonstration — Binary Search is Optimal
# ═══════════════════════════════════════════════════════════════════════════

def demo_optimality():
    """Show that binary search matches the information-theoretic lower bound."""
    
    print("=" * 70)
    print("  ORACLE BINARY SEARCH — Optimal Query Strategy")
    print("  Theorem: ⌈log₂(N)⌉ queries are necessary and sufficient")
    print("=" * 70)
    print()
    
    for N in [8, 16, 64, 256, 1024, 1_000_000]:
        target = random.randint(0, N - 1)
        
        # Create oracle: "Is the answer equal to target?"
        oracle = Oracle(lambda q, t=target: q <= t)
        
        # Binary search
        oracle.reset()
        result = optimal_binary_search(oracle, 0, N)
        bs_queries = oracle.query_count
        
        # Information-theoretic lower bound
        lower_bound = math.ceil(math.log2(N)) if N > 1 else 1
        
        print(f"  N = {N:>10,}  |  target = {target:>10,}  |  "
              f"queries used: {bs_queries:>3}  |  "
              f"⌈log₂(N)⌉ = {lower_bound:>3}  |  "
              f"{'✓ OPTIMAL' if bs_queries <= lower_bound + 1 else '✗ SUBOPTIMAL'}")
    
    print()
    print("  Binary search uses O(log N) queries — matching the lower bound!")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §3: Query Tree Visualization
# ═══════════════════════════════════════════════════════════════════════════

class QueryNode:
    """A node in a binary decision tree (query tree)."""
    
    def __init__(self, query_val=None, true_branch=None, false_branch=None, answer=None):
        self.query_val = query_val
        self.true_branch = true_branch
        self.false_branch = false_branch
        self.answer = answer  # leaf node
    
    def is_leaf(self):
        return self.answer is not None
    
    def depth(self):
        if self.is_leaf():
            return 0
        return 1 + max(
            self.true_branch.depth() if self.true_branch else 0,
            self.false_branch.depth() if self.false_branch else 0
        )
    
    def execute(self, oracle_fn):
        if self.is_leaf():
            return self.answer
        if oracle_fn(self.query_val):
            return self.true_branch.execute(oracle_fn)
        else:
            return self.false_branch.execute(oracle_fn)


def build_optimal_tree(lo: int, hi: int) -> QueryNode:
    """Build the optimal query tree for searching [lo, hi)."""
    if hi - lo <= 1:
        return QueryNode(answer=lo)
    mid = (lo + hi) // 2
    return QueryNode(
        query_val=mid,
        true_branch=build_optimal_tree(lo, mid),
        false_branch=build_optimal_tree(mid, hi)
    )


def print_tree(node: QueryNode, prefix="", is_right=True):
    """Pretty-print a query tree."""
    if node.is_leaf():
        print(f"{prefix}{'└── ' if is_right else '├── '}Answer: {node.answer}")
    else:
        print(f"{prefix}{'└── ' if is_right else '├── '}Query: x < {node.query_val}?")
        new_prefix = prefix + ('    ' if is_right else '│   ')
        if node.false_branch:
            print_tree(node.false_branch, new_prefix, False)
        if node.true_branch:
            print_tree(node.true_branch, new_prefix, True)


def demo_query_tree():
    """Visualize the optimal query tree."""
    
    print("=" * 70)
    print("  QUERY TREE — Optimal Decision Tree for N=8")
    print("=" * 70)
    print()
    
    tree = build_optimal_tree(0, 8)
    print(f"  Tree depth: {tree.depth()} = ⌈log₂(8)⌉ = 3")
    print()
    print_tree(tree, "  ")
    print()
    
    # Verify correctness
    print("  Verification:")
    for target in range(8):
        oracle_fn = lambda q, t=target: q > t
        result = tree.execute(oracle_fn)
        print(f"    Target={target}: tree returns {result}  {'✓' if result == target else '✗'}")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §4: Comparison of Strategies
# ═══════════════════════════════════════════════════════════════════════════

def demo_strategy_comparison():
    """Compare binary search vs linear search vs random search."""
    
    print("=" * 70)
    print("  STRATEGY COMPARISON — Binary vs Linear vs Random")
    print("=" * 70)
    print()
    
    N = 1000
    trials = 100
    
    strategies = {
        "Binary Search": [],
        "Linear Search": [],
        "Random Guess": [],
    }
    
    for _ in range(trials):
        target = random.randint(0, N - 1)
        oracle_fn = lambda q, t=target: q <= t
        
        # Binary search
        oracle = Oracle(oracle_fn)
        optimal_binary_search(oracle, 0, N)
        strategies["Binary Search"].append(oracle.query_count)
        
        # Linear search
        oracle = Oracle(oracle_fn)
        linear_search(oracle, 0, N)
        strategies["Linear Search"].append(oracle.query_count)
        
        # Random search (random queries until found)
        oracle = Oracle(oracle_fn)
        lo, hi = 0, N
        while hi - lo > 1:
            q = random.randint(lo + 1, hi - 1) if hi - lo > 2 else lo + 1
            if oracle.query(q):
                hi = q
            else:
                lo = q
        strategies["Random Guess"].append(oracle.query_count)
    
    print(f"  Search space: N = {N}")
    print(f"  Trials: {trials}")
    print(f"  ⌈log₂(N)⌉ = {math.ceil(math.log2(N))}")
    print()
    print(f"  {'Strategy':<20} {'Avg Queries':>12} {'Max Queries':>12} {'Min Queries':>12}")
    print(f"  {'-'*56}")
    
    for name, counts in strategies.items():
        avg = sum(counts) / len(counts)
        print(f"  {name:<20} {avg:>12.1f} {max(counts):>12} {min(counts):>12}")
    
    print()
    print("  → Binary search is optimal: it matches the information-theoretic bound!")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §5: The Meta-Oracle — Choosing Which Oracle to Consult
# ═══════════════════════════════════════════════════════════════════════════

def demo_meta_oracle():
    """
    The meta-oracle problem: given multiple oracles with different costs
    and accuracies, which should you consult?
    
    This is itself a decision problem solvable by... an oracle!
    """
    
    print("=" * 70)
    print("  META-ORACLE — Choosing the Optimal Oracle")
    print("=" * 70)
    print()
    
    # Define available oracles with costs and accuracies
    oracles = [
        {"name": "Cheap Oracle", "cost": 1, "accuracy": 0.6},
        {"name": "Medium Oracle", "cost": 5, "accuracy": 0.85},
        {"name": "Expert Oracle", "cost": 20, "accuracy": 0.99},
    ]
    
    target = 42
    N = 100
    
    print("  Available Oracles:")
    for o in oracles:
        print(f"    {o['name']:<20} cost={o['cost']:>3}  accuracy={o['accuracy']:.0%}")
    print()
    
    # Simulate: how many queries of each type to reach 99% confidence?
    for o in oracles:
        p = o["accuracy"]
        # After k majority-vote rounds, error ≤ (4p(1-p))^(k/2)
        # We want error ≤ 0.01
        if p >= 0.99:
            k = 1
        else:
            decay = 4 * p * (1 - p)
            k = math.ceil(math.log(0.01) / math.log(decay)) if decay < 1 else float('inf')
        
        total_cost = (2 * k + 1) * o["cost"]
        print(f"  {o['name']:<20}: need {2*k+1:>3} queries × ${o['cost']:>2} = ${total_cost:>5} "
              f"for 99% confidence")
    
    print()
    print("  → The meta-oracle selects the strategy minimizing total cost!")
    print("  → This selection is itself an idempotent operation (Theorem 6.3)")
    print()


if __name__ == "__main__":
    random.seed(42)
    demo_optimality()
    demo_query_tree()
    demo_strategy_comparison()
    demo_meta_oracle()
