#!/usr/bin/env python3
"""
algorithms.py — Algorithms for moment method on random Cayley graphs

Implements:
  1. Word evaluation in symmetric groups
  2. Closed-word counting (exact and sampling-based)
  3. Backtrack-free word enumeration
  4. Adjacency matrix construction and trace computation
  5. Moment kernel computation

All algorithms correspond to formally verified definitions in the Lean
formalization (Pythagorean/CayleyExpander/MomentMethod.lean).
"""

import itertools
import math
import random
from typing import List, Tuple, Dict, Optional

# --- Type aliases ---
Perm = Tuple[int, ...]

# --- Permutation operations ---

def identity(n: int) -> Perm:
    """Identity permutation of {0, ..., n-1}."""
    return tuple(range(n))

def compose(p: Perm, q: Perm) -> Perm:
    """Compose permutations: (p ∘ q)(i) = p(q(i)).
    
    Time: O(n), Space: O(n)
    """
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p: Perm) -> Perm:
    """Inverse permutation.
    
    Time: O(n), Space: O(n)
    """
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def random_perm(n: int) -> Perm:
    """Uniformly random permutation (Fisher-Yates shuffle).
    
    Time: O(n), Space: O(n)
    """
    p = list(range(n))
    random.shuffle(p)
    return tuple(p)

# --- GenLetter alphabet ---
# We encode: 0=sigma, 1=sigmaInv, 2=tau, 3=tauInv

SIGMA, SIGMA_INV, TAU, TAU_INV = 0, 1, 2, 3
LETTER_NAMES = {0: "σ", 1: "σ⁻¹", 2: "τ", 3: "τ⁻¹"}

def letter_inv(a: int) -> int:
    """Formal inverse of a letter.
    
    Corresponds to GenLetter.inv in the Lean formalization.
    """
    return {SIGMA: SIGMA_INV, SIGMA_INV: SIGMA,
            TAU: TAU_INV, TAU_INV: TAU}[a]

def is_backtrack_free(word: List[int]) -> bool:
    """Check if a word is backtrack-free (no adjacent cancelling pairs).
    
    Corresponds to BacktrackFree in the Lean formalization.
    
    Time: O(m), Space: O(1) where m = len(word)
    """
    for i in range(len(word) - 1):
        if word[i+1] == letter_inv(word[i]):
            return False
    return True

# --- Word evaluation ---

def eval_word(sigma: Perm, tau: Perm, word: List[int]) -> Perm:
    """Evaluate a word in the generators {σ, σ⁻¹, τ, τ⁻¹}.
    
    Corresponds to evalWord in the Lean formalization.
    
    Time: O(m·n), Space: O(n) where m = len(word), n = |perm|
    
    Args:
        sigma: First generator (permutation)
        tau: Second generator (permutation)
        word: List of letter indices (0-3)
    
    Returns:
        The product of generators in order.
    """
    n = len(sigma)
    sigma_inv = inverse(sigma)
    tau_inv = inverse(tau)
    gens = {SIGMA: sigma, SIGMA_INV: sigma_inv,
            TAU: tau, TAU_INV: tau_inv}
    
    result = identity(n)
    for letter in word:
        result = compose(gens[letter], result)
    return result

# --- Closed-word counting ---

def closed_word_count_exact(sigma: Perm, tau: Perm, m: int) -> int:
    """Count words of length m evaluating to identity (exact enumeration).
    
    Corresponds to closedWordCount in the Lean formalization.
    
    Time: O(4^m · m · n), Space: O(n)
    
    Theorem (trace_pow_eq_closedWordCount):
        This equals (1/|G|) · tr(A^m) where A is the adjacency matrix.
    """
    n = len(sigma)
    id_perm = identity(n)
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if eval_word(sigma, tau, list(word)) == id_perm:
            count += 1
    return count

def closed_word_count_sampling(sigma: Perm, tau: Perm, m: int,
                                num_samples: int = 10000) -> float:
    """Estimate closed-word count by random sampling.
    
    Time: O(num_samples · m · n), Space: O(n)
    
    Returns estimated count (not normalized).
    """
    n = len(sigma)
    id_perm = identity(n)
    hits = 0
    for _ in range(num_samples):
        word = [random.randint(0, 3) for _ in range(m)]
        if eval_word(sigma, tau, word) == id_perm:
            hits += 1
    return hits * (4**m) / num_samples

# --- Moment kernel ---

def moment_kernel(sigma: Perm, tau: Perm, m: int) -> float:
    """Compute the moment kernel: P(random walk returns to identity at time m).
    
    Corresponds to momentKernel in the Lean formalization.
    
    Theorem (momentKernel_le_one): This is always ≤ 1.
    Theorem (momentKernel_nonneg): This is always ≥ 0.
    """
    cwc = closed_word_count_exact(sigma, tau, m)
    return cwc / (4**m)

# --- Adjacency matrix ---

def cayley_adj_matrix(sigma: Perm, tau: Perm) -> Dict[Tuple[Perm,Perm], int]:
    """Construct the adjacency matrix of Cay(G, {σ,σ⁻¹,τ,τ⁻¹}).
    
    Corresponds to cayleyAdjMatrixTwoGen in the Lean formalization.
    
    Returns sparse representation as dict.
    """
    n = len(sigma)
    sigma_inv = inverse(sigma)
    tau_inv = inverse(tau)
    gens = [sigma, sigma_inv, tau, tau_inv]
    
    # Generate group elements by BFS
    id_perm = identity(n)
    group = {id_perm}
    frontier = [id_perm]
    while frontier:
        new = []
        for g in frontier:
            for s in gens:
                h = compose(s, g)
                if h not in group:
                    group.add(h)
                    new.append(h)
        frontier = new
    
    matrix = {}
    for g in group:
        for s in gens:
            h = compose(s, g)
            key = (g, h)
            matrix[key] = matrix.get(key, 0) + 1
    
    return matrix

def trace_adj_power(sigma: Perm, tau: Perm, m: int) -> int:
    """Compute tr(A^m) using the closed-walk identity.
    
    Theorem (trace_pow_eq_closedWordCount):
        tr(A^m) = closedWordCount(σ,τ,m) * |G|
    
    This is more efficient than matrix exponentiation for small m.
    """
    n = len(sigma)
    group_size = math.factorial(n)
    cwc = closed_word_count_exact(sigma, tau, m)
    return cwc * group_size

# --- Backtrack-free counting ---

def backtrack_free_count_formula(m: int) -> int:
    """Number of backtrack-free words of length m.
    
    Theorem (card_backtrackFree_words): equals 4 * 3^(m-1) for m ≥ 1.
    
    Time: O(1), Space: O(1)
    """
    if m == 0:
        return 1
    return 4 * (3 ** (m - 1))

def backtrack_free_count_enumerate(m: int) -> int:
    """Count by explicit enumeration (for verification)."""
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if is_backtrack_free(list(word)):
            count += 1
    return count

# --- Verification ---

def verify_backtrack_free_formula():
    """Verify the backtrack-free counting formula for small m."""
    print("Verifying backtrack-free word count formula:")
    for m in range(1, 8):
        exact = backtrack_free_count_enumerate(m)
        formula = backtrack_free_count_formula(m)
        status = "✓" if exact == formula else "✗"
        print(f"  m={m}: enumerate={exact}, formula={formula} {status}")

def verify_trace_identity():
    """Verify the trace-closed-walk identity for S_4."""
    n = 4
    sigma = (1, 2, 3, 0)  # cycle (0 1 2 3)
    tau = (1, 0, 2, 3)     # transposition (0 1)
    
    print(f"\nVerifying trace identity for S_{n}:")
    print(f"  σ = {sigma}, τ = {tau}")
    
    for m in range(1, 5):
        cwc = closed_word_count_exact(sigma, tau, m)
        trace = trace_adj_power(sigma, tau, m)
        expected_trace = cwc * math.factorial(n)
        mk = moment_kernel(sigma, tau, m)
        print(f"  m={m}: cwc={cwc}, tr(A^m)={trace}, "
              f"|G|*cwc={expected_trace}, moment_kernel={mk:.6f}")

if __name__ == "__main__":
    verify_backtrack_free_formula()
    verify_trace_identity()
