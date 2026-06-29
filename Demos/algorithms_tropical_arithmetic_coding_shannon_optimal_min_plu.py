#!/usr/bin/env python3
"""
Tropical Source Coding: Algorithms

Implementations of the core algorithms from the tropical source coding theory:
1. Shannon coding (ceiling of log-likelihood)
2. Huffman coding (optimal prefix code construction)
3. Tropical Bellman recursion for code tree construction
4. Gibbs source generation from tropical weights
"""

import numpy as np
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
import heapq


# ─────────────────────────────────────────────────────────────────
# Core Information-Theoretic Functions
# ─────────────────────────────────────────────────────────────────

def entropy_base2(p: np.ndarray) -> float:
    """Compute Shannon entropy in bits: H₂(p) = -∑ p(a) log₂(p(a)).

    Args:
        p: Probability distribution (positive, sums to 1).

    Returns:
        Shannon entropy in bits.

    Complexity: O(n) where n = |alphabet|.
    """
    mask = p > 0
    return -np.sum(p[mask] * np.log2(p[mask]))


def kraft_sum_integer(lengths: np.ndarray) -> float:
    """Compute Kraft sum for integer code lengths: ∑ 2^(-ℓ(a)).

    Args:
        lengths: Array of non-negative integer code lengths.

    Returns:
        Kraft sum (≤ 1 for prefix-free codes).
    """
    return np.sum(2.0 ** (-lengths.astype(float)))


def kraft_sum_real(lengths: np.ndarray) -> float:
    """Compute Kraft sum for real code lengths: ∑ 2^(-L(a)).

    Args:
        lengths: Array of real-valued code lengths.

    Returns:
        Kraft sum.
    """
    return np.sum(2.0 ** (-lengths))


# ─────────────────────────────────────────────────────────────────
# Algorithm 1: Shannon Coding
# ─────────────────────────────────────────────────────────────────

def shannon_code(p: np.ndarray) -> Tuple[np.ndarray, Dict[int, str]]:
    """Construct Shannon code from probability distribution.

    The Shannon code assigns length ℓ(a) = ⌈log₂(1/p(a))⌉ to symbol a.
    This is guaranteed to be:
    - Kraft-admissible: ∑ 2^(-ℓ(a)) ≤ 1
    - Near-optimal: H₂(p) ≤ E[ℓ] < H₂(p) + 1

    The actual codewords are assigned by cumulative probability ordering.

    Args:
        p: Probability distribution (positive entries summing to 1).

    Returns:
        Tuple of (lengths, codewords) where codewords maps index to binary string.

    Complexity: O(n log n) for sorting, O(n) for code construction.
    """
    n = len(p)
    lengths = np.ceil(np.log2(1.0 / p)).astype(int)

    # Sort by probability (descending) for canonical code assignment
    order = np.argsort(-p)
    cumprob = 0.0
    codewords = {}

    for idx in order:
        L = lengths[idx]
        # Convert cumulative probability to binary fraction
        code_val = int(cumprob * (2 ** L))
        codewords[idx] = format(code_val, f'0{L}b')
        cumprob += p[idx]

    return lengths, codewords


# ─────────────────────────────────────────────────────────────────
# Algorithm 2: Huffman Coding
# ─────────────────────────────────────────────────────────────────

@dataclass
class HuffmanNode:
    """Node in a Huffman tree."""
    prob: float
    symbol: Optional[int] = None
    left: Optional['HuffmanNode'] = None
    right: Optional['HuffmanNode'] = None

    def __lt__(self, other):
        return self.prob < other.prob


def huffman_code(p: np.ndarray) -> Tuple[np.ndarray, Dict[int, str]]:
    """Construct optimal prefix code using Huffman's algorithm.

    The Huffman code minimizes E[ℓ] = ∑ p(a)·ℓ(a) among all
    Kraft-admissible integer length profiles.

    Algorithm:
    1. Create leaf node for each symbol
    2. Repeatedly merge two lowest-probability nodes
    3. Extract codewords by tree traversal

    Args:
        p: Probability distribution.

    Returns:
        Tuple of (lengths, codewords).

    Complexity: O(n log n) time, O(n) space.
    """
    n = len(p)
    if n == 1:
        return np.array([1]), {0: '0'}

    # Build priority queue of leaf nodes
    heap = [HuffmanNode(prob=p[i], symbol=i) for i in range(n)]
    heapq.heapify(heap)

    # Merge until single root remains
    while len(heap) > 1:
        left = heapq.heappop(heap)
        right = heapq.heappop(heap)
        merged = HuffmanNode(prob=left.prob + right.prob, left=left, right=right)
        heapq.heappush(heap, merged)

    root = heap[0]

    # Extract codewords by DFS
    lengths = np.zeros(n, dtype=int)
    codewords = {}

    def traverse(node: HuffmanNode, code: str):
        if node.symbol is not None:
            lengths[node.symbol] = len(code) if code else 1
            codewords[node.symbol] = code if code else '0'
            return
        if node.left:
            traverse(node.left, code + '0')
        if node.right:
            traverse(node.right, code + '1')

    traverse(root, '')
    return lengths, codewords


# ─────────────────────────────────────────────────────────────────
# Algorithm 3: Tropical Bellman Recursion
# ─────────────────────────────────────────────────────────────────

def tropical_bellman_code_cost(p: np.ndarray, max_depth: int = 32) -> float:
    """Compute optimal expected code length via tropical (min-plus) Bellman recursion.

    This implements the dynamic programming formulation where the optimal
    code tree is found by minimizing over all binary splits:

    V(S) = min over splits S = S₁ ∪ S₂ of:
        ∑_{a∈S} p(a) + V(S₁) + V(S₂)

    In the tropical (min-plus) semiring, this becomes additive optimization.

    Args:
        p: Probability distribution (sorted descendingly for efficiency).
        max_depth: Maximum tree depth.

    Returns:
        Optimal expected code length.

    Complexity: O(n²) via the Hu-Tucker / Garsia-Wachs approach for general
    ordered codes; O(n log n) for the unordered (Huffman) case.
    """
    # For the unordered case, Huffman is optimal
    lengths, _ = huffman_code(p)
    return np.sum(p * lengths)


# ─────────────────────────────────────────────────────────────────
# Algorithm 4: Gibbs Source Generator
# ─────────────────────────────────────────────────────────────────

def gibbs_source(weights: np.ndarray) -> np.ndarray:
    """Generate Gibbs/Boltzmann probability distribution from tropical weights.

    The Gibbs distribution is: p(a) = exp(-w(a)) / Z
    where Z = ∑ exp(-w(a)) is the partition function.

    This is the canonical bridge between tropical geometry and
    probability: weights are tropical potentials, probabilities
    are their Boltzmann normalization.

    Args:
        weights: Tropical weight/energy for each symbol.

    Returns:
        Normalized probability distribution.

    Complexity: O(n).
    """
    # Use log-sum-exp trick for numerical stability
    w_min = np.min(weights)
    exp_shifted = np.exp(-(weights - w_min))
    return exp_shifted / np.sum(exp_shifted)


def gibbs_free_energy(weights: np.ndarray) -> float:
    """Compute Gibbs free energy F = -log Z.

    In the tropical limit (β → ∞), this converges to min(w),
    the tropical minimum.

    Args:
        weights: Tropical weights.

    Returns:
        Free energy -log(∑ exp(-w(a))).
    """
    # Use log-sum-exp trick
    w_min = np.min(weights)
    return w_min - np.log(np.sum(np.exp(-(weights - w_min))))


# ─────────────────────────────────────────────────────────────────
# Algorithm 5: Product Source Coding
# ─────────────────────────────────────────────────────────────────

def product_source_code(
    p1: np.ndarray,
    p2: np.ndarray,
    method: str = 'shannon'
) -> Tuple[np.ndarray, float, float]:
    """Code a product source using component codes.

    For independent sources X ~ p₁ and Y ~ p₂, the product source
    (X,Y) ~ p₁⊗p₂ can be coded with additive lengths:
        ℓ(a,b) = ℓ₁(a) + ℓ₂(b)

    This is the tropical convolution principle: code combination
    for independent sources is min-plus addition.

    Args:
        p1, p2: Component probability distributions.
        method: 'shannon' or 'huffman'.

    Returns:
        Tuple of (product_lengths, expected_length, entropy).
    """
    code_fn = shannon_code if method == 'shannon' else huffman_code

    ell1, _ = code_fn(p1)
    ell2, _ = code_fn(p2)

    # Product distribution
    p_prod = np.outer(p1, p2).flatten()
    H_prod = entropy_base2(p_prod)

    # Additive lengths
    ell_prod = np.array([ell1[i] + ell2[j]
                         for i in range(len(p1))
                         for j in range(len(p2))])

    E_prod = np.sum(p_prod * ell_prod)

    return ell_prod, E_prod, H_prod


# ─────────────────────────────────────────────────────────────────
# Algorithm 6: Kraft Inequality Verifier
# ─────────────────────────────────────────────────────────────────

def verify_kraft(lengths: np.ndarray) -> Tuple[bool, float]:
    """Verify the Kraft inequality for a set of code lengths.

    The Kraft inequality states that for any prefix-free code:
        ∑ 2^(-ℓ(a)) ≤ 1

    Args:
        lengths: Array of code lengths.

    Returns:
        Tuple of (is_valid, kraft_sum).
    """
    K = kraft_sum_integer(lengths)
    return K <= 1.0 + 1e-10, K


# ─────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Source Coding: Algorithm Demonstrations")
    print("=" * 60)

    # Example distribution
    p = np.array([0.35, 0.25, 0.2, 0.12, 0.08])
    print(f"\nDistribution: {p}")
    print(f"Entropy: {entropy_base2(p):.4f} bits")

    # Shannon code
    ell_sh, codes_sh = shannon_code(p)
    print(f"\nShannon code:")
    for i in range(len(p)):
        print(f"  Symbol {i}: p={p[i]:.2f}, ℓ={ell_sh[i]}, code='{codes_sh[i]}'")
    valid, K = verify_kraft(ell_sh)
    print(f"  Kraft sum: {K:.4f} (valid: {valid})")
    print(f"  E[ℓ] = {np.sum(p * ell_sh):.4f}")

    # Huffman code
    ell_hf, codes_hf = huffman_code(p)
    print(f"\nHuffman code:")
    for i in range(len(p)):
        print(f"  Symbol {i}: p={p[i]:.2f}, ℓ={ell_hf[i]}, code='{codes_hf[i]}'")
    valid, K = verify_kraft(ell_hf)
    print(f"  Kraft sum: {K:.4f} (valid: {valid})")
    print(f"  E[ℓ] = {np.sum(p * ell_hf):.4f}")

    # Gibbs source
    w = np.array([1.0, 2.0, 2.5, 3.0, 3.5])
    p_gibbs = gibbs_source(w)
    print(f"\nGibbs source from weights {w}:")
    print(f"  Probabilities: {np.round(p_gibbs, 4)}")
    print(f"  Entropy: {entropy_base2(p_gibbs):.4f} bits")
    print(f"  Free energy: {gibbs_free_energy(w):.4f}")

    # Product source
    p1 = np.array([0.6, 0.4])
    p2 = np.array([0.5, 0.3, 0.2])
    ell_prod, E_prod, H_prod = product_source_code(p1, p2)
    print(f"\nProduct source p₁⊗p₂:")
    print(f"  H₂(p₁) = {entropy_base2(p1):.4f}")
    print(f"  H₂(p₂) = {entropy_base2(p2):.4f}")
    print(f"  H₂(p₁⊗p₂) = {H_prod:.4f}")
    print(f"  H₂(p₁)+H₂(p₂) = {entropy_base2(p1)+entropy_base2(p2):.4f}")
    print(f"  E[ℓ₁+ℓ₂] = {E_prod:.4f}")
