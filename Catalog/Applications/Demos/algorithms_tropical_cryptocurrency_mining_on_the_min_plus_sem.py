"""
Tropical Cryptocurrency: Algorithms

Implements core algorithms for tropical hash-based cryptocurrency mining:
1. TSHA and TSHA2 hash functions
2. Tropical mining (proof-of-work)
3. Preimage and collision algorithms
4. Mining difficulty analysis
5. Tropical shortest-path interpretation

All algorithms include complexity analysis and docstrings.
"""

from typing import List, Tuple, Optional, Dict
import random
import math
import time


# ============================================================
# Algorithm 1: TSHA — Tropical Secure Hash Algorithm
# ============================================================

def tsha(m: List[int], h: List[int]) -> int:
    """
    Tropical Secure Hash Algorithm.
    
    TSHA(m, h) = min_{i=0..k-1} (m_i + h_i)
    
    Time: O(k) — single pass over components
    Space: O(1) — only stores running minimum
    
    Args:
        m: Message vector of length k
        h: Key vector of length k
    Returns:
        The tropical hash value (minimum of component sums)
    
    >>> tsha([10, 4, 8], [3, 7, 1])
    9
    """
    assert len(m) == len(h) > 0
    return min(m[i] + h[i] for i in range(len(m)))


def tsha_with_witness(m: List[int], h: List[int]) -> Tuple[int, int]:
    """
    TSHA with witness: returns (hash_value, argmin_index).
    
    Time: O(k), Space: O(1)
    
    >>> tsha_with_witness([10, 4, 8], [3, 7, 1])
    (9, 2)
    """
    assert len(m) == len(h) > 0
    best_val = m[0] + h[0]
    best_idx = 0
    for i in range(1, len(m)):
        val = m[i] + h[i]
        if val < best_val:
            best_val = val
            best_idx = i
    return best_val, best_idx


# ============================================================
# Algorithm 2: TSHA2 — Double Tropical Hash
# ============================================================

def tsha2(m: List[int], h1: List[int], h2: List[int]) -> Tuple[int, int]:
    """
    Double Tropical Secure Hash Algorithm.
    
    TSHA2(m, h, h') = (TSHA(m, h), TSHA(m, h'))
    
    Time: O(k) — two passes (or one fused pass)
    Space: O(1)
    
    >>> tsha2([10, 4, 8], [3, 7, 1], [5, 2, 6])
    (9, 6)
    """
    return (tsha(m, h1), tsha(m, h2))


# ============================================================
# Algorithm 3: Tropical Mining (Proof-of-Work)
# ============================================================

def tropical_mine(
    header: List[int],
    key: List[int],
    target: int,
    nonce_range: Tuple[int, int] = (-1000, 1000),
    nonce_len: int = 4,
    max_attempts: int = 100000,
    use_tsha2: bool = False,
    key2: Optional[List[int]] = None,
    target2: Optional[int] = None
) -> Optional[Dict]:
    """
    Tropical proof-of-work mining algorithm.
    
    Finds a nonce vector such that TSHA(header || nonce, key) ≤ target.
    
    Strategy: Random search over nonce space.
    
    Time: O(max_attempts * k) worst case, where k = len(header) + nonce_len
    Space: O(k) for the full message
    
    Args:
        header: Block header components
        key: Tropical hash key (length = len(header) + nonce_len)
        target: Mining difficulty target
        nonce_range: Range for random nonce components
        nonce_len: Number of nonce components
        max_attempts: Maximum mining attempts
        use_tsha2: If True, use double hash for mining
        key2: Second key for TSHA2
        target2: Second target for TSHA2
    
    Returns:
        Dictionary with nonce, hash value, and attempt count, or None
    """
    k_total = len(header) + nonce_len
    assert len(key) == k_total
    
    for attempt in range(1, max_attempts + 1):
        nonce = [random.randint(*nonce_range) for _ in range(nonce_len)]
        full_msg = header + nonce
        hash_val = tsha(full_msg, key)
        
        if hash_val <= target:
            if use_tsha2:
                assert key2 is not None and target2 is not None
                hash_val2 = tsha(full_msg, key2)
                if hash_val2 > target2:
                    continue
                return {
                    "nonce": nonce,
                    "hash": (hash_val, hash_val2),
                    "attempts": attempt,
                    "target": (target, target2)
                }
            return {
                "nonce": nonce,
                "hash": hash_val,
                "attempts": attempt,
                "target": target
            }
    return None


# ============================================================
# Algorithm 4: Constructive Preimage
# ============================================================

def construct_preimage(y: int, h: List[int]) -> List[int]:
    """
    Construct the canonical preimage for TSHA.
    
    Given target y and key h, returns m where m_i = y - h_i.
    Guarantees TSHA(m, h) = y.
    
    Time: O(k), Space: O(k)
    
    This is the formal content of the theorem tsha_explicit_preimage,
    proven in Lean 4.
    
    >>> m = construct_preimage(42, [3, 7, 1])
    >>> tsha(m, [3, 7, 1])
    42
    """
    return [y - h_i for h_i in h]


# ============================================================
# Algorithm 5: Collision Generator
# ============================================================

def generate_collisions(m: List[int], h: List[int], count: int = 10) -> List[List[int]]:
    """
    Generate multiple collisions for a given message under TSHA.
    
    Strategy: Identify the minimum index, then modify non-minimum
    indices arbitrarily (as long as they don't become the new minimum).
    
    Time: O(count * k)
    Space: O(count * k) for storing collisions
    
    This exploits the proven theorem tsha_collision_easy: for k ≥ 2,
    collisions always exist.
    
    >>> collisions = generate_collisions([10, 4, 8], [3, 7, 1], 5)
    >>> all(tsha(c, [3, 7, 1]) == tsha([10, 4, 8], [3, 7, 1]) for c in collisions)
    True
    """
    k = len(m)
    hash_val, j = tsha_with_witness(m, h)
    collisions = []
    
    for _ in range(count):
        m_prime = m.copy()
        # Modify a random non-minimum index
        i = random.choice([idx for idx in range(k) if idx != j])
        # Increase it so it can't become the new minimum
        m_prime[i] = m[i] + random.randint(1, 100)
        assert tsha(m_prime, h) == hash_val
        collisions.append(m_prime)
    
    return collisions


# ============================================================
# Algorithm 6: Mining Difficulty Estimator
# ============================================================

def estimate_mining_difficulty(
    k: int,
    msg_range: Tuple[int, int],
    key_range: Tuple[int, int],
    target: int,
    n_samples: int = 10000
) -> Dict:
    """
    Estimate the probability that a random message hashes below the target.
    
    This gives an empirical measure of mining difficulty.
    
    Time: O(n_samples * k)
    
    Returns:
        Dictionary with success probability, estimated attempts to find solution,
        and other statistics.
    """
    h = [random.randint(*key_range) for _ in range(k)]
    successes = 0
    hash_values = []
    
    for _ in range(n_samples):
        m = [random.randint(*msg_range) for _ in range(k)]
        hv = tsha(m, h)
        hash_values.append(hv)
        if hv <= target:
            successes += 1
    
    prob = successes / n_samples if n_samples > 0 else 0
    return {
        "k": k,
        "target": target,
        "success_probability": prob,
        "expected_attempts": 1.0 / prob if prob > 0 else float('inf'),
        "min_hash": min(hash_values),
        "max_hash": max(hash_values),
        "mean_hash": sum(hash_values) / len(hash_values),
    }


# ============================================================
# Algorithm 7: Tropical Shortest Path Interpretation
# ============================================================

def tsha_as_shortest_path(m: List[int], h: List[int]) -> Dict:
    """
    Interpret TSHA as a shortest-path problem in a bipartite graph K_{1,k}.
    
    The source connects to k vertices with edge weights w_i = m_i + h_i.
    TSHA = minimum weight edge = shortest path from source to any vertex.
    
    This is the formal content of tsha_eq_shortest_weighted_path, proven in Lean 4.
    
    Returns:
        Dictionary with graph structure, edge weights, and shortest path info.
    """
    k = len(m)
    edges = [(0, i + 1, m[i] + h[i]) for i in range(k)]
    hash_val, argmin = tsha_with_witness(m, h)
    
    return {
        "graph": "K_{1," + str(k) + "}",
        "edges": edges,
        "shortest_path": {
            "source": 0,
            "destination": argmin + 1,
            "weight": hash_val,
        },
        "all_weights": [m[i] + h[i] for i in range(k)],
    }


if __name__ == "__main__":
    # Quick algorithm tests
    print("Algorithm Tests")
    print("=" * 40)
    
    h = [3, 7, 1, 5, 2]
    m = [10, 4, 8, 6, 9]
    
    print(f"TSHA({m}, {h}) = {tsha(m, h)}")
    print(f"TSHA with witness: {tsha_with_witness(m, h)}")
    
    preimage = construct_preimage(42, h)
    print(f"Preimage for y=42: {preimage}, TSHA={tsha(preimage, h)}")
    
    collisions = generate_collisions(m, h, 5)
    print(f"Generated {len(collisions)} collisions, all valid: "
          f"{all(tsha(c, h) == tsha(m, h) for c in collisions)}")
    
    print("\nMining difficulty estimation:")
    for k in [8, 16, 32, 64]:
        diff = estimate_mining_difficulty(k, (-50, 50), (-50, 50), -30, 10000)
        print(f"  k={k:3d}: P(hash ≤ -30) = {diff['success_probability']:.4f}, "
              f"E[attempts] = {diff['expected_attempts']:.0f}")
    
    path_info = tsha_as_shortest_path(m, h)
    print(f"\nShortest path interpretation: {path_info['shortest_path']}")
