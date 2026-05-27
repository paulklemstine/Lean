#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Moment Method on Random Cayley Graphs

Implements the algorithms underlying the formal Lean proofs:
  1. Word evaluation in symmetric groups
  2. Closed-walk enumeration
  3. Backtrack-free word generation
  4. Adjacency matrix construction and trace computation
  5. Moment kernel computation

All algorithms include complexity analysis and docstrings.
"""

import itertools
import numpy as np
from math import factorial, comb
from typing import List, Tuple, Optional, Dict


# ═══════════════════════════════════════════════════════════════════════════
# Permutation Arithmetic
# ═══════════════════════════════════════════════════════════════════════════

def compose(p: List[int], q: List[int]) -> List[int]:
    """Compose permutations: (p ∘ q)(i) = p[q[i]].
    
    Time: O(n), Space: O(n)
    
    >>> compose([1, 2, 0], [2, 0, 1])
    [0, 1, 2]
    """
    return [p[q[i]] for i in range(len(p))]


def inverse(p: List[int]) -> List[int]:
    """Inverse permutation.
    
    Time: O(n), Space: O(n)
    
    >>> inverse([1, 2, 0])
    [2, 0, 1]
    """
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return inv


def identity(n: int) -> List[int]:
    """Identity permutation on {0, ..., n-1}."""
    return list(range(n))


# ═══════════════════════════════════════════════════════════════════════════
# Word Evaluation (corresponds to `evalWord` in Lean)
# ═══════════════════════════════════════════════════════════════════════════

# Alphabet: 0 = σ, 1 = σ⁻¹, 2 = τ, 3 = τ⁻¹
SIGMA, SIGMA_INV, TAU, TAU_INV = 0, 1, 2, 3
LETTER_INV = {SIGMA: SIGMA_INV, SIGMA_INV: SIGMA, TAU: TAU_INV, TAU_INV: TAU}


def eval_word(sigma: List[int], tau: List[int], word: Tuple[int, ...]) -> List[int]:
    """Evaluate a word in {σ, σ⁻¹, τ, τ⁻¹}* in S_n.
    
    Corresponds to `evalWord σ τ w` in the Lean formalization.
    
    Time: O(m·n) where m = len(word), n = len(sigma)
    Space: O(n)
    
    Args:
        sigma: First generator (permutation)
        tau: Second generator (permutation)  
        word: Tuple of letter indices (0-3)
    
    Returns:
        Product permutation
    
    >>> sigma = [1, 0, 2]  # transposition (0 1)
    >>> tau = [0, 2, 1]    # transposition (1 2)
    >>> eval_word(sigma, tau, (0, 2))  # σ · τ
    [2, 0, 1]
    """
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    result = identity(n)
    for letter in word:
        result = compose(gens[letter], result)
    return result


# ═══════════════════════════════════════════════════════════════════════════
# Closed-Walk Counting (corresponds to `closedWordCount` in Lean)
# ═══════════════════════════════════════════════════════════════════════════

def closed_word_count(sigma: List[int], tau: List[int], m: int) -> int:
    """Count length-m words evaluating to the identity.
    
    Corresponds to `closedWordCount σ τ m` in the Lean formalization.
    
    This is the fundamental quantity of the moment method:
        closedWordCount(σ, τ, m) = tr(A^m) / |G|
    
    Time: O(4^m · m · n)
    Space: O(n)
    
    Args:
        sigma, tau: Generators (permutations on n elements)
        m: Word length
    
    Returns:
        Number of words evaluating to identity
    """
    n = len(sigma)
    id_perm = identity(n)
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if eval_word(sigma, tau, word) == id_perm:
            count += 1
    return count


def moment_kernel(sigma: List[int], tau: List[int], m: int) -> float:
    """Normalized return probability = closedWordCount / 4^m.
    
    Corresponds to `momentKernel σ τ m` in the Lean formalization.
    
    This equals (1/|G|) · tr(A_norm^m), the m-th spectral moment
    of the normalized adjacency operator.
    
    Time: O(4^m · m · n)
    """
    return closed_word_count(sigma, tau, m) / (4 ** m)


# ═══════════════════════════════════════════════════════════════════════════
# Adjacency Matrix Construction
# ═══════════════════════════════════════════════════════════════════════════

def cayley_adj_matrix(sigma: List[int], tau: List[int]) -> np.ndarray:
    """Construct the unnormalized adjacency matrix of Cay(G, {σ,σ⁻¹,τ,τ⁻¹}).
    
    Corresponds to `cayleyAdjMatrixTwoGen` in the Lean formalization.
    Entry A[g][h] = #{s ∈ S : h = s·g}.
    
    For S_n, this is an n! × n! matrix.
    
    Time: O(|G|² · |S|), Space: O(|G|²)
    Warning: Only feasible for small n (n ≤ 5).
    """
    n = len(sigma)
    # Enumerate all permutations
    perms = list(itertools.permutations(range(n)))
    perm_to_idx = {p: i for i, p in enumerate(perms)}
    N = len(perms)
    
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    A = np.zeros((N, N), dtype=float)
    
    for g_idx, g in enumerate(perms):
        for s in gens:
            h = tuple(compose(s, list(g)))
            h_idx = perm_to_idx[h]
            A[h_idx][g_idx] += 1
    
    return A


def verify_trace_identity(sigma: List[int], tau: List[int], m: int) -> Dict:
    """Verify tr(A^m) = closedWordCount · |G| by direct computation.
    
    This is the computational verification of Theorem 1 from the
    Lean formalization (trace_pow_eq_closedWordCount).
    
    Returns dict with trace, closed_word_count, and verification status.
    """
    n = len(sigma)
    A = cayley_adj_matrix(sigma, tau)
    Am = np.linalg.matrix_power(A, m)
    trace = np.trace(Am)
    
    cwc = closed_word_count(sigma, tau, m)
    group_size = factorial(n)
    expected_trace = cwc * group_size
    
    return {
        "trace_A_m": trace,
        "closed_word_count": cwc,
        "group_size": group_size,
        "expected_trace": expected_trace,
        "match": abs(trace - expected_trace) < 1e-6,
        "moment_kernel": cwc / (4 ** m),
    }


# ═══════════════════════════════════════════════════════════════════════════
# Backtrack-Free Words (corresponds to `BacktrackFree` in Lean)
# ═══════════════════════════════════════════════════════════════════════════

def is_backtrack_free(word: Tuple[int, ...]) -> bool:
    """Check if a word has no immediate cancellations.
    
    A word is backtrack-free if no letter is immediately followed
    by its formal inverse.
    
    Corresponds to `BacktrackFree` in the Lean formalization.
    
    Time: O(m)
    """
    for i in range(len(word) - 1):
        if word[i + 1] == LETTER_INV[word[i]]:
            return False
    return True


def count_backtrack_free(m: int) -> int:
    """Count backtrack-free words of length m by enumeration.
    
    Time: O(4^m · m) — brute force
    """
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if is_backtrack_free(word):
            count += 1
    return count


def backtrack_free_formula(m: int) -> int:
    """Exact formula: 4 · 3^(m-1) for m ≥ 1, 1 for m = 0.
    
    This is the tree-like contribution to the moment method:
    it counts walks on the infinite 4-regular tree (Cayley graph of F_2).
    
    Time: O(1)
    """
    if m == 0:
        return 1
    return 4 * (3 ** (m - 1))


# ═══════════════════════════════════════════════════════════════════════════
# Free Group Return Probabilities
# ═══════════════════════════════════════════════════════════════════════════

def free_group_return_prob(two_k: int) -> float:
    """Return probability at time 2k for SRW on F_2.
    
    For the 4-regular tree:
        p_{2k}(e) = C_k · 3^k / 4^{2k}
    
    where C_k is the k-th Catalan number.
    
    Time: O(k)
    """
    if two_k % 2 != 0:
        return 0.0
    k = two_k // 2
    if k == 0:
        return 1.0
    catalan = comb(2 * k, k) // (k + 1)
    return catalan * (3 ** k) / (4 ** two_k)


# ═══════════════════════════════════════════════════════════════════════════
# Reverse-Invert Map (corresponds to `reverseInvertWord` in Lean)
# ═══════════════════════════════════════════════════════════════════════════

def reverse_invert(word: Tuple[int, ...]) -> Tuple[int, ...]:
    """Reverse and invert each letter.
    
    Corresponds to `reverseInvertWord` in the Lean formalization.
    Key property (proved in Lean): evalWord(σ, τ, reverseInvert(w)) = (evalWord(σ, τ, w))⁻¹
    
    Time: O(m)
    """
    return tuple(LETTER_INV[a] for a in reversed(word))


# ═══════════════════════════════════════════════════════════════════════════
# Entry Point
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=== Algorithm Verification ===\n")
    
    # Verify backtrack-free formula
    print("Backtrack-free word count verification:")
    for m in range(1, 9):
        exact = backtrack_free_formula(m)
        if m <= 6:
            brute = count_backtrack_free(m)
            match = "✓" if exact == brute else "✗"
            print(f"  m={m}: formula={exact:7d}, enumeration={brute:7d}  {match}")
        else:
            print(f"  m={m}: formula={exact:7d}")
    
    print()
    
    # Verify trace identity for S_3
    print("Trace identity verification (S_3):")
    sigma = [1, 2, 0]  # (0 1 2)
    tau = [1, 0, 2]    # (0 1)
    for m in range(5):
        result = verify_trace_identity(sigma, tau, m)
        print(f"  m={m}: tr(A^m)={result['trace_A_m']:.0f}, "
              f"cwc·|G|={result['expected_trace']}, "
              f"match={result['match']}")
    
    print()
    
    # Verify reverse-invert involution
    print("Reverse-invert involution verification:")
    for m in range(1, 5):
        all_ok = True
        for word in itertools.product(range(4), repeat=m):
            if reverse_invert(reverse_invert(word)) != word:
                all_ok = False
                break
        print(f"  m={m}: involution property holds = {all_ok}")
    
    print()
    
    # Verify reverse-invert and eval_word relationship
    print("Reverse-invert evaluation identity:")
    sigma = [1, 2, 0]
    tau = [1, 0, 2]
    n = len(sigma)
    for m in range(1, 5):
        all_ok = True
        for word in itertools.product(range(4), repeat=m):
            ev = eval_word(sigma, tau, word)
            ev_rev = eval_word(sigma, tau, reverse_invert(word))
            if compose(ev, ev_rev) != identity(n):
                all_ok = False
                break
        print(f"  m={m}: evalWord(w) · evalWord(reverseInvert(w)) = id: {all_ok}")
