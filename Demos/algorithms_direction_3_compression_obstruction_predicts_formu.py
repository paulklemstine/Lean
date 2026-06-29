#!/usr/bin/env python3
"""
Algorithms for Computing Compression Obstructions

This module implements algorithms for computing and bounding the compression
obstruction for finite witness sets, supporting the theoretical framework
developed in the Lean formalization.

Algorithms:
  1. ExactCompressionObstruction — computes the exact general obstruction
  2. ExactPrefixFreeObstruction — computes the exact prefix-free obstruction
  3. WitnessCompressionProfile — computes the full compression profile
"""

import math
from typing import List, Tuple, Dict, Optional


# ─── Algorithm 1: Exact Compression Obstruction ─────────────────────────────────

def exact_compression_obstruction(n: int) -> int:
    """
    Compute the exact compression obstruction for a set of n elements.

    This is the minimum k such that n elements can be injectively encoded
    into binary strings of length ≤ k.

    The number of binary strings of length ≤ k is 2^(k+1) - 1.
    So we need the smallest k with 2^(k+1) - 1 ≥ n.

    Time complexity: O(log n)
    Space complexity: O(1)

    Examples:
        >>> exact_compression_obstruction(1)
        0
        >>> exact_compression_obstruction(3)
        1
        >>> exact_compression_obstruction(4)
        2
        >>> exact_compression_obstruction(8)
        3
    """
    if n <= 0:
        return 0
    if n == 1:
        return 0  # The empty string suffices
    k = 0
    while (1 << (k + 1)) - 1 < n:
        k += 1
    return k


# ─── Algorithm 2: Exact Prefix-Free Obstruction ────────────────────────────────

def exact_prefix_free_obstruction(n: int) -> int:
    """
    Compute the exact prefix-free compression obstruction for n elements.

    A prefix-free code with max codeword length k has at most 2^k codewords
    (by the Kraft inequality, proved in our Lean formalization as
    `prefixFree_code_card_le`). Conversely, we can always construct a
    prefix-free code achieving this bound (e.g., fixed-length codes).

    So the answer is ⌈log₂ n⌉.

    Time complexity: O(1)
    Space complexity: O(1)

    Examples:
        >>> exact_prefix_free_obstruction(1)
        0
        >>> exact_prefix_free_obstruction(2)
        1
        >>> exact_prefix_free_obstruction(3)
        2
        >>> exact_prefix_free_obstruction(5)
        3
    """
    if n <= 1:
        return 0
    return math.ceil(math.log2(n))


# ─── Algorithm 3: Witness Compression Profile ──────────────────────────────────

def witness_compression_profile(
    n_witnesses: int,
    max_budget: Optional[int] = None
) -> Dict[int, int]:
    """
    Compute the witness compression profile for a set of n_witnesses elements.

    For each code-length budget ℓ from 0 to max_budget, compute the maximum
    number of witnesses that can be encoded using binary strings of length ≤ ℓ.

    The answer for budget ℓ is min(n_witnesses, 2^(ℓ+1) - 1).

    Args:
        n_witnesses: Number of witnesses in the set
        max_budget: Maximum budget to compute (default: enough to cover all)

    Returns:
        Dictionary mapping budget ℓ to count of encodable witnesses

    Time complexity: O(max_budget)
    Space complexity: O(max_budget)

    Examples:
        >>> witness_compression_profile(7)
        {0: 1, 1: 3, 2: 7}
        >>> witness_compression_profile(10)
        {0: 1, 1: 3, 2: 7, 3: 10}
    """
    if max_budget is None:
        max_budget = exact_compression_obstruction(n_witnesses)

    profile = {}
    for ell in range(max_budget + 1):
        available = (1 << (ell + 1)) - 1  # 2^(ℓ+1) - 1
        profile[ell] = min(n_witnesses, available)
    return profile


# ─── Algorithm 4: Constrained Obstruction ───────────────────────────────────────

def constrained_obstruction(
    n_witnesses: int,
    min_codeword_length: int = 0,
    prefix_free: bool = False
) -> int:
    """
    Compute the compression obstruction under structural constraints.

    Constraints:
    - min_codeword_length: all codewords must have length ≥ this value
    - prefix_free: if True, require prefix-free codes

    This demonstrates how structural constraints increase the obstruction
    beyond the naive counting bound.

    Examples:
        >>> constrained_obstruction(2, min_codeword_length=0)
        1
        >>> constrained_obstruction(2, min_codeword_length=2)
        2
        >>> constrained_obstruction(3, prefix_free=True)
        2
        >>> constrained_obstruction(3, prefix_free=False)
        1
    """
    if n_witnesses <= 0:
        return 0

    if prefix_free:
        obs = exact_prefix_free_obstruction(n_witnesses)
    else:
        obs = exact_compression_obstruction(n_witnesses)

    return max(obs, min_codeword_length)


# ─── Algorithm 5: Gap Detector ──────────────────────────────────────────────────

def find_strict_gaps(max_elements: int = 100) -> List[Dict]:
    """
    Find all element counts n ≤ max_elements where the prefix-free
    obstruction strictly exceeds the general obstruction.

    Returns a list of dictionaries with the gap analysis.

    The gap occurs exactly when n > 2^k but n ≤ 2^(k+1) - 1 for some k,
    meaning n elements fit into variable-length codes of max length k
    but NOT into prefix-free codes of max length k.

    Examples:
        >>> gaps = find_strict_gaps(10)
        >>> any(g['n'] == 3 for g in gaps)  # Verified in Lean!
        True
    """
    gaps = []
    for n in range(1, max_elements + 1):
        gen = exact_compression_obstruction(n)
        pf = exact_prefix_free_obstruction(n)
        if pf > gen:
            gaps.append({
                'n': n,
                'general_obstruction': gen,
                'prefix_free_obstruction': pf,
                'gap': pf - gen,
                'counting_bound': math.floor(math.log2(n)) if n > 0 else 0
            })
    return gaps


# ─── Main ───────────────────────────────────────────────────────────────────────

def main():
    print("Compression Obstruction Algorithms")
    print("=" * 50)

    # Algorithm 1: Exact computation
    print("\n--- Exact Compression Obstruction ---")
    for n in [1, 2, 3, 4, 5, 7, 8, 10, 15, 16, 100]:
        gen = exact_compression_obstruction(n)
        pf = exact_prefix_free_obstruction(n)
        counting = math.floor(math.log2(n)) if n > 0 else 0
        print(f"  n={n:>4}: counting={counting}, general={gen}, prefix-free={pf}")

    # Algorithm 3: Compression profiles
    print("\n--- Witness Compression Profiles ---")
    for n in [3, 7, 15]:
        profile = witness_compression_profile(n)
        print(f"  n={n}: {profile}")

    # Algorithm 5: Gap detection
    print("\n--- Strict Gaps (PF > General) for n ≤ 30 ---")
    gaps = find_strict_gaps(30)
    for g in gaps:
        print(f"  n={g['n']:>3}: general={g['general_obstruction']}, "
              f"PF={g['prefix_free_obstruction']}, gap={g['gap']}")

    # Highlight the Lean-verified example
    print("\n--- Lean-Verified Example ---")
    print(f"  n=3: general={exact_compression_obstruction(3)}, "
          f"PF={exact_prefix_free_obstruction(3)}")
    print("  This gap is formally verified in Lean 4!")
    print("  (See strict_gap_prefixFree_vs_general in CompressionObstruction.lean)")


if __name__ == "__main__":
    main()
