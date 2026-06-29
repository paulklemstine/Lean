#!/usr/bin/env python3
"""
Algorithms for Finite Information Complexity Theory

Implements the core algorithms arising from the bridge between
entropy bounds, state-space complexity, and coding theory.

Each algorithm is self-contained with docstrings, type hints,
complexity analysis, and usage examples.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Set


def shannon_entropy(p: np.ndarray) -> float:
    """
    Compute Shannon entropy of a probability distribution.
    
    H(p) = -∑ p_i log(p_i), with convention 0 log 0 = 0.
    
    Time complexity: O(n)
    Space complexity: O(1) additional
    
    Args:
        p: Probability distribution (nonneg, sums to 1)
    
    Returns:
        Shannon entropy in nats (natural logarithm base)
    
    Example:
        >>> p = np.array([0.5, 0.5])
        >>> abs(shannon_entropy(p) - np.log(2)) < 1e-10
        True
    """
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]))


def entropy_upper_bound(n: int) -> float:
    """
    Compute the maximum entropy achievable by a distribution on n elements.
    
    By the entropy_le_log_card theorem: H(p) ≤ log(n) for all p on {1,...,n}.
    Equality is achieved by the uniform distribution.
    
    Time complexity: O(1)
    
    Args:
        n: Cardinality of the support
    
    Returns:
        log(n), the entropy upper bound
    
    Example:
        >>> abs(entropy_upper_bound(10) - np.log(10)) < 1e-10
        True
    """
    if n <= 0:
        raise ValueError("Cardinality must be positive")
    return np.log(n)


def minimum_states_for_entropy(target_entropy: float) -> int:
    """
    Compute the minimum number of states needed to represent
    information with the given entropy level.
    
    By card_ge_exp_entropy: |states| ≥ exp(H), so we need
    at least ceil(exp(H)) states.
    
    Time complexity: O(1)
    
    Args:
        target_entropy: Desired information content in nats
    
    Returns:
        Minimum number of states (ceiling of exp(entropy))
    
    Example:
        >>> minimum_states_for_entropy(np.log(8))
        8
        >>> minimum_states_for_entropy(2.5)
        13
    """
    return int(np.ceil(np.exp(target_entropy)))


def matrix_rank_from_factorization(
    U: np.ndarray, V: np.ndarray
) -> Tuple[np.ndarray, int, int]:
    """
    Given matrices U (m×r) and V (r×n), compute M = U·V and verify
    that rank(M) ≤ r.
    
    Implements the finite_image_bound_of_matrix_factorization theorem.
    
    Time complexity: O(m·r·n) for multiplication + O(min(m,n)·max(m,n)) for rank
    Space complexity: O(m·n) for the product
    
    Args:
        U: Left factor matrix (m × r)
        V: Right factor matrix (r × n)
    
    Returns:
        (M, actual_rank, latent_dim_r)
    
    Example:
        >>> U = np.random.randn(10, 3)
        >>> V = np.random.randn(3, 8)
        >>> M, rank, r = matrix_rank_from_factorization(U, V)
        >>> rank <= r
        True
    """
    assert U.shape[1] == V.shape[0], "Matrix dimensions must agree"
    r = U.shape[1]
    M = U @ V
    actual_rank = np.linalg.matrix_rank(M)
    assert actual_rank <= r, f"Bug: rank {actual_rank} > latent dim {r}"
    return M, actual_rank, r


def automaton_state_distribution(
    transitions: np.ndarray,
    initial_state: int,
    n_samples: int = 10000,
    max_word_length: int = 20,
    n_symbols: int = 2
) -> np.ndarray:
    """
    Compute empirical state distribution of a finite automaton
    by running random input words.
    
    Time complexity: O(n_samples · max_word_length)
    Space complexity: O(n_states)
    
    Args:
        transitions: Transition table (n_states × n_symbols)
        initial_state: Starting state index
        n_samples: Number of random words to sample
        max_word_length: Maximum length of random words
        n_symbols: Size of input alphabet
    
    Returns:
        Probability distribution over states
    """
    n_states = transitions.shape[0]
    counts = np.zeros(n_states)
    
    for _ in range(n_samples):
        state = initial_state
        word_len = np.random.randint(1, max_word_length + 1)
        for _ in range(word_len):
            symbol = np.random.randint(0, n_symbols)
            state = transitions[state, symbol]
        counts[state] += 1
    
    return counts / counts.sum()


def verify_information_bottleneck(
    n_states: int,
    n_trials: int = 100
) -> Dict[str, float]:
    """
    Numerically verify the information bottleneck theorem:
    exp(H(P)) ≤ n_states for random distributions.
    
    Time complexity: O(n_trials · n_states)
    
    Args:
        n_states: Number of states
        n_trials: Number of random distributions to test
    
    Returns:
        Dictionary with statistics about the verification
    """
    max_ratio = 0.0
    entropies = []
    
    for _ in range(n_trials):
        raw = np.random.exponential(1, n_states)
        p = raw / raw.sum()
        h = shannon_entropy(p)
        exp_h = np.exp(h)
        
        ratio = exp_h / n_states
        max_ratio = max(max_ratio, ratio)
        entropies.append(h)
        
        # Verify the bound
        assert exp_h <= n_states + 1e-10, \
            f"Violation: exp(H) = {exp_h} > {n_states}"
    
    return {
        'n_states': n_states,
        'max_ratio_exp_h_over_n': max_ratio,
        'mean_entropy': np.mean(entropies),
        'max_entropy': np.max(entropies),
        'log_n_bound': np.log(n_states),
        'all_verified': True
    }


def coding_capacity_analysis(
    source_sizes: List[int],
    target_size: int
) -> List[Dict]:
    """
    Analyze coding capacity: which source sizes can be injectively
    encoded into a target space of given size.
    
    Implements the finite_coding_injective_bound theorem.
    
    Args:
        source_sizes: List of source cardinalities to check
        target_size: Size of the target (state) space
    
    Returns:
        List of analysis results
    """
    results = []
    for src in source_sizes:
        encodable = src <= target_size
        entropy_bound = np.log(target_size) if target_size > 0 else 0
        max_source_entropy = np.log(src) if src > 0 else 0
        
        results.append({
            'source_size': src,
            'target_size': target_size,
            'injective_encoding_possible': encodable,
            'max_source_entropy': max_source_entropy,
            'target_entropy_bound': entropy_bound,
            'entropy_compatible': max_source_entropy <= entropy_bound + 1e-10
        })
    
    return results


def compressed_rank_analysis(
    m: int, n: int, 
    latent_dims: List[int]
) -> List[Dict]:
    """
    Analyze how matrix rank and entropy bounds change with
    different latent (compressed) dimensions.
    
    Implements the entropy_rank_bridge theorem numerically.
    
    Args:
        m: Number of rows
        n: Number of columns
        latent_dims: List of latent dimensions to test
    
    Returns:
        Analysis results for each latent dimension
    """
    results = []
    for r in latent_dims:
        U = np.random.randn(m, r)
        V = np.random.randn(r, n)
        M = U @ V
        rank = np.linalg.matrix_rank(M)
        
        # Entropy bound on latent distribution
        if r > 0:
            entropy_bound = np.log(r)
            # Uniform latent distribution
            p_uniform = np.ones(r) / r
            h_max = shannon_entropy(p_uniform)
        else:
            entropy_bound = 0
            h_max = 0
        
        compression_ratio = (m * n) / max(m * r + r * n, 1)
        
        results.append({
            'latent_dim': r,
            'matrix_rank': rank,
            'rank_bound_holds': rank <= r,
            'entropy_bound': entropy_bound,
            'max_latent_entropy': h_max,
            'entropy_bound_holds': h_max <= entropy_bound + 1e-10,
            'compression_ratio': compression_ratio,
            'original_params': m * n,
            'compressed_params': m * r + r * n
        })
    
    return results


if __name__ == "__main__":
    np.random.seed(42)
    
    print("Finite Information Complexity — Algorithm Demonstrations")
    print("=" * 60)
    
    # Test entropy computation
    p = np.array([0.25, 0.25, 0.25, 0.25])
    h = shannon_entropy(p)
    print(f"\nEntropy of uniform(4): {h:.6f} = log(4) = {np.log(4):.6f}")
    
    # Test minimum states
    for H in [1.0, 2.0, 3.0, np.log(10), np.log(100)]:
        n = minimum_states_for_entropy(H)
        print(f"H = {H:.3f} → need ≥ {n} states (exp(H) = {np.exp(H):.2f})")
    
    # Test bottleneck verification
    print("\nVerifying information bottleneck:")
    for n in [5, 10, 50, 100]:
        result = verify_information_bottleneck(n, 1000)
        print(f"  n={n:3d}: max ratio exp(H)/n = {result['max_ratio_exp_h_over_n']:.6f} ≤ 1 ✓")
    
    # Test rank analysis
    print("\nCompressed rank analysis (50×40 matrix):")
    results = compressed_rank_analysis(50, 40, [1, 2, 5, 10, 20])
    for r in results:
        print(f"  r={r['latent_dim']:2d}: rank={r['matrix_rank']:2d} ≤ {r['latent_dim']} ✓  "
              f"H_max={r['max_latent_entropy']:.3f} ≤ {r['entropy_bound']:.3f} ✓  "
              f"compression={r['compression_ratio']:.2f}x")
