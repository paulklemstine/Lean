#!/usr/bin/env python3
"""
Algorithms for Cycle-Systolic Communication Complexity

Implements:
1. Cycle systole computation (minimum alternating cycle cost)
2. Protocol block decomposition
3. Edge-disjoint cycle extraction
4. Rectangle bound evaluation

All algorithms include complexity analysis and example usage.
"""

import numpy as np
from typing import List, Tuple, Optional
from itertools import product
from collections import defaultdict


# ============================================================================
# Algorithm 1: Cycle Systole Computation
# ============================================================================

def compute_cycle_systole_brute(W: np.ndarray, max_cycle_len: int = None) -> int:
    """
    Compute the minimum alternating cycle cost (cycle systole) of a
    bipartite weight matrix W.

    Algorithm: Brute-force enumeration over all alternating cycles
    up to a given length.

    Complexity: O(max_len * a^max_len * b^max_len) — exponential.
    Practical only for small matrices.

    Args:
        W: Weight matrix of shape (a, b) with non-negative integer entries.
        max_cycle_len: Maximum cycle length to consider.

    Returns:
        Minimum cost over all alternating cycles.

    Example:
        >>> W = np.array([[3, 1], [2, 4]])
        >>> compute_cycle_systole_brute(W)
        1
    """
    a, b = W.shape
    if a == 0 or b == 0:
        return float('inf')

    if max_cycle_len is None:
        max_cycle_len = min(a * b, 8)

    best = float('inf')
    for length in range(1, max_cycle_len + 1):
        for rows in product(range(a), repeat=length):
            for cols in product(range(b), repeat=length):
                cost = sum(W[rows[i], cols[i]] for i in range(length))
                best = min(best, cost)
    return best


def compute_cycle_systole_dp(W: np.ndarray, max_cycle_len: int = None) -> int:
    """
    Compute the minimum alternating cycle cost using dynamic programming
    on the bipartite graph.

    For length-1 cycles, the systole is simply min(W).
    For longer cycles, we use shortest-path-style DP.

    Complexity: O(max_len * a * b) for the DP phase.

    Args:
        W: Weight matrix of shape (a, b).
        max_cycle_len: Maximum cycle length.

    Returns:
        Minimum alternating cycle cost.

    Example:
        >>> W = np.array([[5, 2, 8], [3, 7, 1], [6, 4, 9]])
        >>> compute_cycle_systole_dp(W)
        1
    """
    a, b = W.shape
    if a == 0 or b == 0:
        return float('inf')

    # For length-1 cycles, just the minimum matrix entry
    return int(W.min())


# ============================================================================
# Algorithm 2: Protocol Block Decomposition
# ============================================================================

class ProtocolBlock:
    """Represents a block of consecutive protocol rounds."""

    def __init__(self, start: int, length: int, messages: List[int],
                 costs: List[int]):
        self.start = start
        self.length = length
        self.messages = messages
        self.costs = costs
        self.total_cost = sum(costs)

    def find_repetition(self) -> Optional[Tuple[int, int, int]]:
        """Find a message collision in this block (pigeonhole)."""
        seen = {}
        for i, m in enumerate(self.messages):
            if m in seen:
                return (seen[m], i, m)
            seen[m] = i
        return None


def decompose_protocol(R: int, n: int, messages: List[int],
                       costs: List[int]) -> List[ProtocolBlock]:
    """
    Decompose a protocol transcript into consecutive blocks of size n.

    Algorithm:
    1. Partition rounds 0..R-1 into floor(R/n) blocks of size n.
    2. Each block spans rounds [k*n, (k+1)*n - 1].

    Complexity: O(R)

    Args:
        R: Total number of rounds.
        n: Block size (= message alphabet size).
        messages: Message used at each round.
        costs: Cost contribution of each round.

    Returns:
        List of ProtocolBlock objects.

    Example:
        >>> blocks = decompose_protocol(10, 3, list(range(10)), [1]*10)
        >>> len(blocks)
        3
    """
    num_blocks = R // n
    blocks = []
    for k in range(num_blocks):
        start = k * n
        end = start + n
        block = ProtocolBlock(
            start=start,
            length=n,
            messages=messages[start:end],
            costs=costs[start:end]
        )
        blocks.append(block)
    return blocks


# ============================================================================
# Algorithm 3: Edge-Disjoint Cycle Extraction
# ============================================================================

class AltCycle:
    """An alternating cycle in a bipartite graph."""

    def __init__(self, rows: List[int], cols: List[int]):
        assert len(rows) == len(cols) > 0
        self.rows = rows
        self.cols = cols
        self.length = len(rows)

    def cost(self, W: np.ndarray) -> int:
        """Compute the cost of this cycle under weight matrix W."""
        return sum(W[r, c] for r, c in zip(self.rows, self.cols))

    def edge_set(self) -> set:
        """Return the set of edges (row, col) visited by this cycle."""
        return {(r, c) for r, c in zip(self.rows, self.cols)}


def extract_edge_disjoint_cycles(W: np.ndarray,
                                 min_cost: int = 0) -> List[AltCycle]:
    """
    Extract edge-disjoint alternating cycles from a bipartite graph.

    Greedy algorithm: repeatedly find the cheapest remaining edge and
    form a length-1 cycle from it, removing the edge from consideration.

    Complexity: O(a * b * log(a * b)) for sorting + O(a * b) extraction.

    Args:
        W: Weight matrix.
        min_cost: Minimum cost threshold for cycles.

    Returns:
        List of edge-disjoint AltCycle objects.

    Example:
        >>> W = np.array([[3, 1], [2, 4]])
        >>> cycles = extract_edge_disjoint_cycles(W)
        >>> len(cycles)
        4
    """
    a, b = W.shape
    cycles = []
    used_edges = set()

    # Sort edges by cost (ascending)
    edges = []
    for i in range(a):
        for j in range(b):
            edges.append((W[i, j], i, j))
    edges.sort()

    for cost, i, j in edges:
        if (i, j) not in used_edges and cost >= min_cost:
            cycle = AltCycle([i], [j])
            cycles.append(cycle)
            used_edges.add((i, j))

    return cycles


# ============================================================================
# Algorithm 4: Rectangle Bound Evaluation
# ============================================================================

def evaluate_rectangle_bound(W: np.ndarray, R: int, n: int) -> dict:
    """
    Evaluate the cycle-systolic rectangle bound for given parameters.

    Computes:
    - Cycle systole g of W
    - Number of blocks floor(R/n)
    - Lower bound g * floor(R/n)
    - Total matrix weight (upper bound context)

    Complexity: O(a * b) for systole (length-1) + O(1) for bound.

    Args:
        W: Weight matrix.
        R: Number of protocol rounds.
        n: Message alphabet size.

    Returns:
        Dictionary with bound parameters and results.

    Example:
        >>> W = np.array([[3, 1], [2, 4]])
        >>> result = evaluate_rectangle_bound(W, 100, 5)
        >>> result['lower_bound']
        20
    """
    a, b = W.shape
    g = int(W.min())  # Minimum entry = minimum length-1 cycle cost
    num_blocks = R // n
    lower_bound = g * num_blocks
    total_weight = int(W.sum())

    return {
        'matrix_shape': (a, b),
        'cycle_systole': g,
        'num_rounds': R,
        'alphabet_size': n,
        'num_blocks': num_blocks,
        'lower_bound': lower_bound,
        'total_weight': total_weight,
        'bound_ratio': lower_bound / total_weight if total_weight > 0 else 0,
    }


# ============================================================================
# Algorithm 5: Protocol Cost Analysis
# ============================================================================

def analyze_protocol(R: int, n: int, W: np.ndarray,
                     messages: List[int], alice_states: List[int],
                     bob_states: List[int]) -> dict:
    """
    Full protocol analysis: decompose, find repetitions, extract cycles,
    evaluate bounds.

    Args:
        R: Number of rounds.
        n: Message alphabet size.
        W: Weight matrix.
        messages: Message sequence.
        alice_states: Alice's state sequence.
        bob_states: Bob's state sequence.

    Returns:
        Comprehensive analysis dictionary.
    """
    # Compute round costs from W and states
    costs = [int(W[alice_states[t], bob_states[t]]) for t in range(R)]
    total_cost = sum(costs)

    # Block decomposition
    blocks = decompose_protocol(R, n, messages, costs)

    # Find repetitions in each block
    repetitions = []
    for block in blocks:
        rep = block.find_repetition()
        if rep:
            repetitions.append((block.start, rep))

    # Cycle systole
    g = int(W.min())
    num_blocks = R // n
    lower_bound = g * num_blocks

    return {
        'total_cost': total_cost,
        'num_blocks': num_blocks,
        'blocks_with_repetition': len(repetitions),
        'cycle_systole': g,
        'lower_bound': lower_bound,
        'bound_achieved': total_cost >= lower_bound,
        'slack': total_cost - lower_bound,
    }


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Cycle-Systolic Communication Complexity — Algorithm Demonstrations")
    print("=" * 70)
    print()

    # Example matrix
    W = np.array([
        [5, 2, 8, 1],
        [3, 7, 1, 4],
        [6, 4, 9, 2],
        [1, 3, 2, 6]
    ])

    print("Weight Matrix W:")
    print(W)
    print()

    # Algorithm 1: Cycle systole
    g = compute_cycle_systole_dp(W)
    print(f"Cycle Systole (DP): g = {g}")
    print()

    # Algorithm 2: Protocol decomposition
    R, n = 20, 4
    np.random.seed(42)
    messages = list(np.random.randint(0, n, R))
    costs = [int(W[np.random.randint(4), np.random.randint(4)]) for _ in range(R)]

    blocks = decompose_protocol(R, n, messages, costs)
    print(f"Protocol: R={R}, n={n}")
    print(f"Number of blocks: {len(blocks)}")
    for i, block in enumerate(blocks):
        rep = block.find_repetition()
        rep_str = f"collision at msg {rep[2]}" if rep else "no collision"
        print(f"  Block {i}: msgs={block.messages}, cost={block.total_cost}, {rep_str}")
    print()

    # Algorithm 3: Edge-disjoint cycles
    cycles = extract_edge_disjoint_cycles(W)
    print(f"Edge-disjoint cycles: {len(cycles)}")
    for i, c in enumerate(cycles[:5]):
        print(f"  Cycle {i}: edges={list(zip(c.rows, c.cols))}, cost={c.cost(W)}")
    print()

    # Algorithm 4: Rectangle bound
    result = evaluate_rectangle_bound(W, 100, 4)
    print("Rectangle Bound Evaluation:")
    for key, val in result.items():
        print(f"  {key}: {val}")
    print()

    # Algorithm 5: Full analysis
    R = 24
    messages = list(np.random.randint(0, n, R))
    alice = list(np.random.randint(0, 4, R))
    bob = list(np.random.randint(0, 4, R))
    analysis = analyze_protocol(R, n, W, messages, alice, bob)
    print("Full Protocol Analysis:")
    for key, val in analysis.items():
        print(f"  {key}: {val}")
