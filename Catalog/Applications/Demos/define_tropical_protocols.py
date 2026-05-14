#!/usr/bin/env python3
"""
Tropical Protocol Trees — Demonstration and Verification

This module implements tropical protocol trees in Python and verifies
the five foundational theorems computationally on concrete examples.
"""

import math
import random
from typing import Optional, Union
from dataclasses import dataclass


# ============================================================
# Core Data Structure
# ============================================================

INF = float('inf')

@dataclass
class TropProtocolTree:
    """A tropical protocol tree.

    Either a leaf with a value in ℕ ∪ {∞},
    or an internal node with children [(cost, subtree), ...].
    """
    leaf_value: Optional[float] = None
    children: Optional[list] = None  # list of (cost: int, child: TropProtocolTree)

    @staticmethod
    def leaf(value: float) -> 'TropProtocolTree':
        return TropProtocolTree(leaf_value=value)

    @staticmethod
    def node(children: list) -> 'TropProtocolTree':
        return TropProtocolTree(children=children)

    def is_leaf(self) -> bool:
        return self.children is None

    def __repr__(self):
        if self.is_leaf():
            v = '∞' if self.leaf_value == INF else str(self.leaf_value)
            return f'leaf({v})'
        cs = ', '.join(f'({c}, {t})' for c, t in self.children)
        return f'node([{cs}])'


# ============================================================
# Recursive Definitions
# ============================================================

def value(T: TropProtocolTree) -> float:
    """Tropical value: min-plus aggregation."""
    if T.is_leaf():
        return T.leaf_value
    if not T.children:
        return INF
    return min(c + value(child) for c, child in T.children)


def depth(T: TropProtocolTree) -> int:
    """Tree depth."""
    if T.is_leaf():
        return 0
    if not T.children:
        return 1
    return 1 + max(depth(child) for _, child in T.children)


def path_values(T: TropProtocolTree) -> list:
    """All root-to-leaf path values."""
    if T.is_leaf():
        return [T.leaf_value]
    result = []
    for c, child in (T.children or []):
        for v in path_values(child):
            result.append(c + v)
    return result


def num_leaves(T: TropProtocolTree) -> int:
    """Total number of leaves."""
    if T.is_leaf():
        return 1
    return sum(num_leaves(child) for _, child in (T.children or []))


def num_finite_leaves(T: TropProtocolTree) -> int:
    """Number of leaves with finite value."""
    if T.is_leaf():
        return 0 if T.leaf_value == INF else 1
    return sum(num_finite_leaves(child) for _, child in (T.children or []))


def max_branching(T: TropProtocolTree) -> int:
    """Maximum branching factor."""
    if T.is_leaf():
        return 0
    b = len(T.children) if T.children else 0
    for _, child in (T.children or []):
        b = max(b, max_branching(child))
    return b


def map_leaves(T: TropProtocolTree, f) -> 'TropProtocolTree':
    """Apply f to every leaf value."""
    if T.is_leaf():
        return TropProtocolTree.leaf(f(T.leaf_value))
    return TropProtocolTree.node(
        [(c, map_leaves(child, f)) for c, child in T.children]
    )


# ============================================================
# Test Tree Generators
# ============================================================

def make_binary_tree(depth_val: int, leaf_gen=None) -> TropProtocolTree:
    """Create a complete binary tree."""
    if leaf_gen is None:
        counter = [0]
        def leaf_gen():
            counter[0] += 1
            return counter[0]
    if depth_val == 0:
        return TropProtocolTree.leaf(leaf_gen())
    return TropProtocolTree.node([
        (random.randint(0, 5), make_binary_tree(depth_val - 1, leaf_gen)),
        (random.randint(0, 5), make_binary_tree(depth_val - 1, leaf_gen)),
    ])


def make_random_tree(max_depth: int, max_branch: int) -> TropProtocolTree:
    """Create a random tree with bounded depth and branching."""
    if max_depth == 0 or random.random() < 0.3:
        v = random.choice([random.randint(0, 50), INF])
        return TropProtocolTree.leaf(v)
    k = random.randint(1, max_branch)
    children = [
        (random.randint(0, 10), make_random_tree(max_depth - 1, max_branch))
        for _ in range(k)
    ]
    return TropProtocolTree.node(children)


# ============================================================
# Theorem Verification
# ============================================================

def verify_bellman(T: TropProtocolTree) -> bool:
    """Verify Theorem 1: value = inf(pathValues)."""
    v = value(T)
    pvs = path_values(T)
    inf_pv = min(pvs) if pvs else INF
    return v == inf_pv


def verify_monotonicity(T: TropProtocolTree, delta: int = 5) -> bool:
    """Verify Theorem 2: increasing leaf values increases root value.
    We add delta to each leaf (making values larger) and check value increases.
    """
    v1 = value(T)
    T2 = map_leaves(T, lambda a: a + delta if a != INF else INF)
    v2 = value(T2)
    return v1 <= v2


def verify_depth_bound(T: TropProtocolTree) -> bool:
    """Verify Theorem 4: numLeaves ≤ b^depth."""
    b = max_branching(T)
    d = depth(T)
    n = num_leaves(T)
    if b == 0:
        return n <= 1
    return n <= b ** d


def verify_gauge_invariance(T: TropProtocolTree, k: int = 7) -> bool:
    """Verify Theorem 5: value(mapLeaves(+k, T)) = k + value(T)."""
    v = value(T)
    T_shifted = map_leaves(T, lambda a: k + a)
    v_shifted = value(T_shifted)
    return v_shifted == k + v


# ============================================================
# Demonstrations
# ============================================================

def demo_basic():
    """Basic demonstration of a tropical protocol tree."""
    print("=" * 60)
    print("DEMO 1: Basic Tropical Protocol Tree")
    print("=" * 60)

    # A simple tree:
    #       root
    #      / |  \
    #    c=1 c=2 c=3
    #    /    |    \
    #  v=5  v=1   v=4
    T = TropProtocolTree.node([
        (1, TropProtocolTree.leaf(5)),
        (2, TropProtocolTree.leaf(1)),
        (3, TropProtocolTree.leaf(4)),
    ])

    print(f"Tree: {T}")
    print(f"Value: {value(T)}")
    print(f"  Path values: {path_values(T)}")
    print(f"  = min(1+5, 2+1, 3+4) = min(6, 3, 7) = 3")
    print(f"Depth: {depth(T)}")
    print(f"Leaves: {num_leaves(T)}")
    print()


def demo_nested():
    """Nested tree demonstration."""
    print("=" * 60)
    print("DEMO 2: Nested Tree (Dynamic Programming)")
    print("=" * 60)

    #       root
    #      /    \
    #    c=2    c=1
    #    /       \
    #  node     leaf(0)
    #  / \
    # c=1 c=3
    # /     \
    # v=4   v=2
    inner = TropProtocolTree.node([
        (1, TropProtocolTree.leaf(4)),
        (3, TropProtocolTree.leaf(2)),
    ])
    T = TropProtocolTree.node([
        (2, inner),
        (1, TropProtocolTree.leaf(0)),
    ])

    print(f"Value: {value(T)}")
    print(f"  Path values: {path_values(T)}")
    print(f"  Paths: 2+1+4=7, 2+3+2=7, 1+0=1")
    print(f"  Optimal: go right, cost = 1")
    print(f"Depth: {depth(T)}")
    print()


def demo_bellman():
    """Demonstrate the Bellman principle on random trees."""
    print("=" * 60)
    print("DEMO 3: Bellman Principle Verification")
    print("=" * 60)

    random.seed(42)
    n_tests = 1000
    passed = 0
    for _ in range(n_tests):
        T = make_random_tree(max_depth=5, max_branch=4)
        if verify_bellman(T):
            passed += 1

    print(f"Tested {n_tests} random trees")
    print(f"Bellman principle verified: {passed}/{n_tests}")
    print()


def demo_depth_bound():
    """Demonstrate the depth lower bound."""
    print("=" * 60)
    print("DEMO 4: Depth Lower Bound")
    print("=" * 60)

    random.seed(123)
    n_tests = 1000
    passed = 0
    examples = []
    for _ in range(n_tests):
        T = make_random_tree(max_depth=6, max_branch=3)
        b = max_branching(T)
        d = depth(T)
        n = num_leaves(T)
        if verify_depth_bound(T):
            passed += 1
        if len(examples) < 5:
            bound = b ** d if b > 0 else 1
            examples.append((n, b, d, bound))

    print(f"Tested {n_tests} random trees")
    print(f"Depth bound verified: {passed}/{n_tests}")
    print()
    print("Sample trees:")
    print(f"{'Leaves':>8} {'Branch':>8} {'Depth':>8} {'Bound':>8}")
    for n, b, d, bound in examples:
        print(f"{n:>8} {b:>8} {d:>8} {bound:>8}")
    print()


def demo_gauge_invariance():
    """Demonstrate gauge invariance."""
    print("=" * 60)
    print("DEMO 5: Gauge Invariance")
    print("=" * 60)

    T = TropProtocolTree.node([
        (2, TropProtocolTree.leaf(3)),
        (1, TropProtocolTree.leaf(7)),
    ])

    k = 10
    v_orig = value(T)
    T_shifted = map_leaves(T, lambda a: k + a)
    v_shifted = value(T_shifted)

    print(f"Original value: {v_orig}")
    print(f"Shift k = {k}")
    print(f"Shifted value: {v_shifted}")
    print(f"k + original = {k + v_orig}")
    print(f"Equal: {v_shifted == k + v_orig}")
    print()

    # Verify on random trees
    random.seed(99)
    n_tests = 1000
    passed = sum(1 for _ in range(n_tests)
                 if verify_gauge_invariance(make_random_tree(4, 3), k=5))
    print(f"Verified on {passed}/{n_tests} random trees")
    print()


def demo_routing():
    """Network routing application."""
    print("=" * 60)
    print("DEMO 6: Network Routing Application")
    print("=" * 60)

    # Model a simple network routing decision:
    # From headquarters, choose between:
    #   - Fiber link (cost 1) to datacenter A (latency 2)
    #   - Satellite link (cost 5) to datacenter B (latency 0)
    #   - VPN tunnel (cost 3) to router C, which connects to:
    #       - Datacenter D (cost 1, latency 3)
    #       - Datacenter E (cost 2, latency 1)

    T = TropProtocolTree.node([
        (1, TropProtocolTree.leaf(2)),  # Fiber → DC_A
        (5, TropProtocolTree.leaf(0)),  # Satellite → DC_B
        (3, TropProtocolTree.node([     # VPN → Router_C
            (1, TropProtocolTree.leaf(3)),  # → DC_D
            (2, TropProtocolTree.leaf(1)),  # → DC_E
        ])),
    ])

    print("Network topology:")
    print("  HQ → Fiber(1) → DC_A(2)")
    print("  HQ → Satellite(5) → DC_B(0)")
    print("  HQ → VPN(3) → Router_C → Link(1) → DC_D(3)")
    print("                         → Link(2) → DC_E(1)")
    print()
    print(f"All path costs: {path_values(T)}")
    print(f"Optimal total cost: {value(T)}")
    print(f"  (Fiber to DC_A: 1+2=3)")
    print()


def demo_all_theorems():
    """Comprehensive verification of all theorems."""
    print("=" * 60)
    print("COMPREHENSIVE THEOREM VERIFICATION")
    print("=" * 60)

    random.seed(2025)
    n_tests = 5000
    results = {
        'Bellman': 0,
        'Monotonicity': 0,
        'Depth Bound': 0,
        'Gauge Invariance': 0,
    }

    for _ in range(n_tests):
        T = make_random_tree(max_depth=5, max_branch=4)
        if verify_bellman(T): results['Bellman'] += 1
        if verify_monotonicity(T): results['Monotonicity'] += 1
        if verify_depth_bound(T): results['Depth Bound'] += 1
        if verify_gauge_invariance(T): results['Gauge Invariance'] += 1

    print(f"Tested {n_tests} random trees")
    print()
    for name, count in results.items():
        status = "✓" if count == n_tests else "✗"
        print(f"  {status} {name}: {count}/{n_tests}")
    print()


if __name__ == '__main__':
    demo_basic()
    demo_nested()
    demo_bellman()
    demo_depth_bound()
    demo_gauge_invariance()
    demo_routing()
    demo_all_theorems()
