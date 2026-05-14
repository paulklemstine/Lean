#!/usr/bin/env python3
"""
Tropical Source Coding: Algorithms

Implements the core algorithms from the tropical source coding theory:
1. Shannon code construction
2. Huffman coding (tropical merge interpretation)
3. Min-plus convolution
4. Tropical dynamic programming for code optimization
"""

import heapq
import numpy as np
from typing import List, Tuple, Dict, Optional, Callable
from dataclasses import dataclass, field


# ──────────────────────────────────────────────────────────────
# 1. Shannon Code Construction
# ──────────────────────────────────────────────────────────────

def shannon_code(probs: Dict[str, float]) -> Dict[str, int]:
    """
    Construct Shannon code lengths: L(a) = ⌈-log(p(a))⌉.

    This is the tropical self-information rounded to the nearest integer above.
    By Theorem A, the expected length satisfies H(μ) ≤ E[L] < H(μ) + 1.
    By Theorem B, these lengths satisfy the Kraft inequality.

    Args:
        probs: Dictionary mapping symbols to probabilities (must sum to 1).

    Returns:
        Dictionary mapping symbols to integer code lengths.

    Example:
        >>> shannon_code({'a': 0.5, 'b': 0.25, 'c': 0.25})
        {'a': 1, 'b': 2, 'c': 2}
    """
    assert abs(sum(probs.values()) - 1.0) < 1e-9, "Probabilities must sum to 1"
    assert all(p > 0 for p in probs.values()), "All probabilities must be positive"

    return {symbol: int(np.ceil(-np.log(p))) for symbol, p in probs.items()}


def verify_kraft(lengths: Dict[str, int]) -> Tuple[float, bool]:
    """
    Verify the Kraft inequality: ∑ exp(-L(a)) ≤ 1.

    Args:
        lengths: Dictionary mapping symbols to code lengths.

    Returns:
        Tuple of (Kraft sum, whether inequality holds).
    """
    kraft_sum = sum(np.exp(-l) for l in lengths.values())
    return kraft_sum, kraft_sum <= 1.0 + 1e-10


def entropy(probs: Dict[str, float]) -> float:
    """Compute Shannon entropy in nats: H = -∑ p·log(p)."""
    return -sum(p * np.log(p) for p in probs.values())


def expected_code_length(probs: Dict[str, float], lengths: Dict[str, int]) -> float:
    """Compute expected code length: E[L] = ∑ p(a)·L(a)."""
    return sum(probs[s] * lengths[s] for s in probs)


# ──────────────────────────────────────────────────────────────
# 2. Huffman Coding (Tropical Merge Interpretation)
# ──────────────────────────────────────────────────────────────

@dataclass(order=True)
class HuffmanNode:
    """Node in a Huffman tree with tropical weight."""
    weight: float
    symbol: Optional[str] = field(default=None, compare=False)
    left: Optional['HuffmanNode'] = field(default=None, compare=False)
    right: Optional['HuffmanNode'] = field(default=None, compare=False)


def huffman_code(probs: Dict[str, float]) -> Dict[str, int]:
    """
    Construct Huffman code lengths via tropical merge.

    The Huffman algorithm is tropical dynamic programming:
    - Each symbol starts with tropical weight -log(p)
    - Merging two nodes combines weights via log-sum-exp (tropical addition)
    - The greedy selection of minimum-weight pairs is the tropical DP policy

    Args:
        probs: Dictionary mapping symbols to probabilities.

    Returns:
        Dictionary mapping symbols to optimal integer code lengths.
    """
    if len(probs) <= 1:
        return {s: 0 for s in probs}

    # Build priority queue with tropical weights
    heap: List[HuffmanNode] = []
    for symbol, p in probs.items():
        heapq.heappush(heap, HuffmanNode(weight=p, symbol=symbol))

    # Tropical merge: repeatedly combine two smallest
    while len(heap) > 1:
        left = heapq.heappop(heap)
        right = heapq.heappop(heap)
        merged = HuffmanNode(
            weight=left.weight + right.weight,
            left=left,
            right=right
        )
        heapq.heappush(heap, merged)

    # Extract code lengths from tree
    root = heap[0]
    lengths: Dict[str, int] = {}

    def traverse(node: HuffmanNode, depth: int):
        if node.symbol is not None:
            lengths[node.symbol] = max(depth, 1) if len(probs) > 1 else 0
        if node.left:
            traverse(node.left, depth + 1)
        if node.right:
            traverse(node.right, depth + 1)

    traverse(root, 0)
    return lengths


# ──────────────────────────────────────────────────────────────
# 3. Min-Plus Convolution
# ──────────────────────────────────────────────────────────────

def min_plus_convolution(f: np.ndarray, g: np.ndarray) -> np.ndarray:
    """
    Compute the min-plus convolution of two sequences.

    (f ⊛ g)(n) = min_{i+j=n} [f(i) + g(j)]

    By Theorem C, this is the algebraic mechanism generating optimal
    merged code lengths. Product source Kraft sums decompose as
    tropical convolution in log space.

    Args:
        f: First sequence (cost profile).
        g: Second sequence (cost profile).

    Returns:
        The min-plus convolution array.

    Time complexity: O(len(f) · len(g))
    """
    m, n = len(f), len(g)
    result = np.full(m + n - 1, np.inf)

    for i in range(m):
        for j in range(n):
            k = i + j
            result[k] = min(result[k], f[i] + g[j])

    return result


def min_plus_conv_associativity_check(f: np.ndarray, g: np.ndarray, h: np.ndarray) -> bool:
    """
    Verify associativity: (f ⊛ g) ⊛ h = f ⊛ (g ⊛ h).

    This is a key algebraic property that ensures the tropical merge
    order does not affect the final result.
    """
    left = min_plus_convolution(min_plus_convolution(f, g), h)
    right = min_plus_convolution(f, min_plus_convolution(g, h))

    # Pad to same length
    max_len = max(len(left), len(right))
    left_padded = np.full(max_len, np.inf)
    right_padded = np.full(max_len, np.inf)
    left_padded[:len(left)] = left
    right_padded[:len(right)] = right

    return np.allclose(left_padded, right_padded, atol=1e-10)


# ──────────────────────────────────────────────────────────────
# 4. Tropical Dynamic Programming
# ──────────────────────────────────────────────────────────────

def tropical_bellman_iteration(
    costs: np.ndarray,
    transitions: np.ndarray,
    discount: float = 1.0,
    max_iter: int = 100,
    tol: float = 1e-8
) -> Tuple[np.ndarray, int]:
    """
    Tropical value iteration for optimal coding.

    Solves the tropical Bellman equation:
        V(s) = min_a [c(s,a) + discount · max_{s'} T(s,a,s') + V(s')]

    In the tropical limit (discount=1), this gives optimal adaptive
    code lengths via the contraction mapping theorem.

    Args:
        costs: State-action cost matrix (n_states × n_actions).
        transitions: Transition matrix (n_states × n_actions × n_states).
        discount: Discount factor (1.0 for undiscounted).
        max_iter: Maximum iterations.
        tol: Convergence tolerance.

    Returns:
        Tuple of (optimal value function, number of iterations).
    """
    n_states, n_actions = costs.shape[:2]
    V = np.zeros(n_states)

    for iteration in range(max_iter):
        V_new = np.full(n_states, np.inf)

        for s in range(n_states):
            for a in range(n_actions):
                # Tropical transition: max over next states (worst case)
                next_val = np.max(transitions[s, a] + discount * V)
                V_new[s] = min(V_new[s], costs[s, a] + next_val)

        if np.max(np.abs(V_new - V)) < tol:
            return V_new, iteration + 1

        V = V_new

    return V, max_iter


# ──────────────────────────────────────────────────────────────
# 5. Kraft Sum Decomposition
# ──────────────────────────────────────────────────────────────

def kraft_product_decomposition(
    L1: Dict[str, int],
    L2: Dict[str, int]
) -> Tuple[float, float, float]:
    """
    Verify the Kraft product decomposition (Theorem C):
    ∑_{(a,b)} exp(-(L₁(a)+L₂(b))) = [∑_a exp(-L₁(a))] · [∑_b exp(-L₂(b))]

    Returns:
        Tuple of (product_sum, kraft1 * kraft2, relative_error).
    """
    kraft1 = sum(np.exp(-l) for l in L1.values())
    kraft2 = sum(np.exp(-l) for l in L2.values())

    product_sum = 0.0
    for l1 in L1.values():
        for l2 in L2.values():
            product_sum += np.exp(-(l1 + l2))

    relative_error = abs(product_sum - kraft1 * kraft2) / max(abs(kraft1 * kraft2), 1e-15)
    return product_sum, kraft1 * kraft2, relative_error


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: Compare Shannon and Huffman codes
    probs = {'a': 0.4, 'b': 0.3, 'c': 0.2, 'd': 0.1}

    print("Source distribution:", probs)
    print(f"Entropy: {entropy(probs):.4f} nats\n")

    # Shannon code
    sc = shannon_code(probs)
    sc_el = expected_code_length(probs, sc)
    sc_kraft, sc_kraft_ok = verify_kraft(sc)
    print(f"Shannon code: {sc}")
    print(f"  Expected length: {sc_el:.4f}")
    print(f"  Kraft sum: {sc_kraft:.6f} (valid: {sc_kraft_ok})")

    # Huffman code
    hc = huffman_code(probs)
    hc_el = expected_code_length(probs, hc)
    hc_kraft, hc_kraft_ok = verify_kraft(hc)
    print(f"\nHuffman code: {hc}")
    print(f"  Expected length: {hc_el:.4f}")
    print(f"  Kraft sum: {hc_kraft:.6f} (valid: {hc_kraft_ok})")

    # Min-plus convolution
    f = np.array([3.0, 1.0, 0.5])
    g = np.array([2.0, 0.5])
    conv = min_plus_convolution(f, g)
    print(f"\nMin-plus convolution of {f} and {g}: {conv}")

    # Associativity check
    h = np.array([1.0, 2.0, 0.5])
    assoc = min_plus_conv_associativity_check(f, g, h)
    print(f"Associativity check: {assoc}")

    # Kraft product decomposition
    L1 = {'x': 1, 'y': 2, 'z': 3}
    L2 = {'p': 1, 'q': 2}
    ps, kk, err = kraft_product_decomposition(L1, L2)
    print(f"\nKraft product decomposition:")
    print(f"  Product sum: {ps:.8f}")
    print(f"  K₁ × K₂:    {kk:.8f}")
    print(f"  Relative error: {err:.2e}")
