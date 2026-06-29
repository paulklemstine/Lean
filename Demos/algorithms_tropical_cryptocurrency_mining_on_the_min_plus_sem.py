#!/usr/bin/env python3
"""
Tropical Cryptocurrency Mining Algorithms
==========================================
Type-hinted implementations of all algorithms from the research.
"""

from typing import List, Tuple, Optional, Set
import math


def tsha(m: List[int], h: List[int]) -> int:
    """
    Tropical Secure Hash Algorithm.
    
    Computes TSHA(m, h) = min_{i=0..k-1} (m_i + h_i)
    in the min-plus semiring.
    
    Time complexity: O(k) — single pass over components.
    Space complexity: O(1).
    
    Args:
        m: Message vector of length k
        h: Key vector of length k
    
    Returns:
        The tropical hash value (minimum component sum)
    """
    assert len(m) == len(h) > 0, "Vectors must be non-empty and equal length"
    return min(m[i] + h[i] for i in range(len(m)))


def tsha_with_witness(m: List[int], h: List[int]) -> Tuple[int, int]:
    """
    TSHA with minimizer index (witness).
    
    Returns (hash_value, minimizer_index) where
    hash_value = m[minimizer_index] + h[minimizer_index] = min_i(m_i + h_i).
    
    Args:
        m: Message vector
        h: Key vector
    
    Returns:
        Tuple of (hash value, index achieving the minimum)
    """
    k = len(m)
    assert k == len(h) > 0
    best_val = m[0] + h[0]
    best_idx = 0
    for i in range(1, k):
        val = m[i] + h[i]
        if val < best_val:
            best_val = val
            best_idx = i
    return best_val, best_idx


def tsha2(m: List[int], h: List[int], h2: List[int]) -> Tuple[int, int]:
    """
    Double Tropical Secure Hash Algorithm.
    
    TSHA2(m, h, h') = (TSHA(m, h), TSHA(m, h'))
    
    Uses two independent keys for collision resistance.
    
    Args:
        m: Message vector
        h: First key vector
        h2: Second key vector
    
    Returns:
        Pair of tropical hash values
    """
    return (tsha(m, h), tsha(m, h2))


def canonical_preimage(y: int, h: List[int]) -> List[int]:
    """
    Construct the canonical preimage for target value y.
    
    Given target y and key h, returns m where m_i = y - h_i.
    This satisfies TSHA(m, h) = y.
    
    Time complexity: O(k).
    
    Args:
        y: Target hash value
        h: Key vector
    
    Returns:
        Message vector m with TSHA(m, h) = y
    """
    return [y - hi for hi in h]


def find_all_minimizers(m: List[int], h: List[int]) -> List[int]:
    """
    Find all indices achieving the TSHA minimum.
    
    Args:
        m: Message vector
        h: Key vector
    
    Returns:
        List of indices i where m_i + h_i equals the minimum
    """
    k = len(m)
    min_val = tsha(m, h)
    return [i for i in range(k) if m[i] + h[i] == min_val]


def generate_collision(m: List[int], h: List[int]) -> List[int]:
    """
    Generate a TSHA collision for message m under key h.
    
    Strategy: find the minimizer index j, then add 1 to all
    non-minimizer coordinates. The hash value is preserved because
    the minimum (at j) is unchanged.
    
    Args:
        m: Original message
        h: Key vector
    
    Returns:
        m' ≠ m with TSHA(m', h) = TSHA(m, h)
    """
    k = len(m)
    _, j = tsha_with_witness(m, h)
    m_prime = [m[i] + (0 if i == j else 1) for i in range(k)]
    return m_prime


def tropical_mine(
    h: List[int],
    target: int,
    max_attempts: int = 1000000,
    search_range: int = 100
) -> Optional[List[int]]:
    """
    Tropical mining: find message m with TSHA(m, h) ≤ target.
    
    This is the tropical proof-of-work problem. Unlike SHA256 mining,
    we can use the canonical preimage construction to find solutions
    in O(k) time. The difficulty comes from additional constraints
    (e.g., nonce range restrictions).
    
    Args:
        h: Hash key
        target: Target value (lower = harder)
        max_attempts: Maximum random search attempts
        search_range: Range for random nonce values
    
    Returns:
        Message achieving target, or None
    """
    # Canonical solution always works in O(k)
    return canonical_preimage(target, h)


def tropical_mine_constrained(
    h: List[int],
    target: int,
    lo: int = 0,
    hi_bound: int = 100,
    max_attempts: int = 1000000
) -> Optional[List[int]]:
    """
    Constrained tropical mining: find m ∈ [lo, hi_bound]^k with TSHA(m,h) ≤ target.
    
    When messages are constrained to a bounded range, mining becomes
    genuinely difficult — this is where the computational hardness lies.
    
    Args:
        h: Hash key
        target: Target value
        lo: Lower bound on message components
        hi_bound: Upper bound on message components
        max_attempts: Maximum attempts
    
    Returns:
        Constrained message achieving target, or None
    """
    import random
    k = len(h)
    
    # Check if target is achievable
    best_possible = min(lo + h[i] for i in range(k))
    if best_possible > target:
        return None
    
    for _ in range(max_attempts):
        m = [random.randint(lo, hi_bound) for _ in range(k)]
        if tsha(m, h) <= target:
            return m
    return None


def tropical_merkle_root(leaves: List[int]) -> int:
    """
    Compute the tropical Merkle root of a list of values.
    
    The tropical Merkle tree uses min (tropical addition) instead of
    SHA256 for combining child nodes. Key property: the root equals
    the global minimum of all leaves.
    
    Note: tropical Merkle is idempotent (min(a,a) = a), which means
    it cannot distinguish repeated subtrees — a fundamental difference
    from classical Merkle trees with security implications.
    
    Args:
        leaves: List of leaf values
    
    Returns:
        The tropical Merkle root (= min of all leaves)
    """
    if not leaves:
        raise ValueError("Empty leaf list")
    
    # Build tree bottom-up
    level = list(leaves)
    while len(level) > 1:
        next_level = []
        for i in range(0, len(level), 2):
            if i + 1 < len(level):
                next_level.append(min(level[i], level[i + 1]))
            else:
                next_level.append(level[i])
        level = next_level
    return level[0]


def collision_freedom_degree(m: List[int], h: List[int]) -> int:
    """
    Compute the collision freedom degree of a message.
    
    The collision freedom degree is the number of coordinates that can
    be independently perturbed upward while preserving the hash.
    It equals k - (number of minimizer indices).
    
    Args:
        m: Message vector
        h: Key vector
    
    Returns:
        Number of freely perturbable coordinates
    """
    minimizers = find_all_minimizers(m, h)
    return len(m) - len(minimizers)


def tsha_concat_decompose(
    m1: List[int], m2: List[int],
    h1: List[int], h2: List[int]
) -> Tuple[int, int, int]:
    """
    Demonstrate concatenation decomposition.
    
    Returns (TSHA(m1‖m2, h1‖h2), TSHA(m1,h1), TSHA(m2,h2)).
    The first should equal min of the other two.
    
    Args:
        m1, m2: Message sub-vectors
        h1, h2: Key sub-vectors
    
    Returns:
        Tuple (full_hash, hash1, hash2)
    """
    full_hash = tsha(m1 + m2, h1 + h2)
    hash1 = tsha(m1, h1)
    hash2 = tsha(m2, h2)
    assert full_hash == min(hash1, hash2), "Concatenation decomposition failed!"
    return full_hash, hash1, hash2


def estimate_hash_expectation(k: int, N: int, n_samples: int = 10000) -> float:
    """
    Estimate E[TSHA(m, h)] for uniform random m, h ∈ {0,...,N}^k.
    
    Conjecture: E[TSHA] ≈ 2N/(k+1).
    
    Args:
        k: Dimension
        N: Range upper bound
        n_samples: Number of Monte Carlo samples
    
    Returns:
        Estimated expected value
    """
    import random
    total = 0
    for _ in range(n_samples):
        m = [random.randint(0, N) for _ in range(k)]
        h = [random.randint(0, N) for _ in range(k)]
        total += tsha(m, h)
    return total / n_samples


if __name__ == "__main__":
    # Quick verification
    m = [3, 1, 4, 1, 5]
    h = [2, 7, 1, 8, 2]
    print(f"TSHA({m}, {h}) = {tsha(m, h)}")
    print(f"TSHA2 = {tsha2(m, h, [1,2,3,4,5])}")
    print(f"Collision: {generate_collision(m, h)}")
    print(f"Merkle root: {tropical_merkle_root([5, 3, 8, 1, 7])}")
    print(f"Collision freedom degree: {collision_freedom_degree(m, h)}")
