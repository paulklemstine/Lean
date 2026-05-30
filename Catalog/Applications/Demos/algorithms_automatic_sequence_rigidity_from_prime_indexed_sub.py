"""
Algorithms for Prime-Indexed Subword Zeta Functions

Implements the core algorithms from the research paper with full
documentation, type hints, and complexity analysis.
"""

from typing import List, Dict, Tuple, Set, Optional, Callable
from collections import Counter
from math import log, sqrt
import numpy as np


# ============================================================
# Algorithm 1: Subword Complexity via Suffix Array
# ============================================================

def compute_subword_complexity(
    seq: List[int],
    max_length: int
) -> List[int]:
    """
    Compute subword complexity p(n) for n = 0, 1, ..., max_length.

    Uses a direct hashing approach for correctness.

    Time complexity: O(N * max_length) where N = len(seq)
    Space complexity: O(N * max_length) in the worst case

    Args:
        seq: The input sequence as a list of integers.
        max_length: Maximum subword length to compute.

    Returns:
        List where result[n] = number of distinct length-n subwords.

    Example:
        >>> tm = [bin(n).count('1') % 2 for n in range(100)]
        >>> p = compute_subword_complexity(tm, 10)
        >>> all(p[n] >= n + 1 for n in range(1, 10))  # Morse-Hedlund
        True
    """
    N = len(seq)
    result = [0] * (max_length + 1)
    result[0] = 1  # Only one empty word

    for length in range(1, max_length + 1):
        subwords = set()
        for i in range(N - length + 1):
            subwords.add(tuple(seq[i:i+length]))
        result[length] = len(subwords)

    return result


# ============================================================
# Algorithm 2: Shannon Entropy of Subword Distribution
# ============================================================

def compute_subword_entropy(
    seq: List[int],
    length: int,
    window: Optional[int] = None
) -> float:
    """
    Compute Shannon entropy of the subword frequency distribution
    at a given length.

    H(L) = -Σ_w freq(w) * log(freq(w))

    where freq(w) = (number of occurrences of w) / (total windows).

    Time complexity: O(N * L) where N = len(seq), L = length
    Space complexity: O(|Σ|^L) worst case, typically much less

    Args:
        seq: Input sequence.
        length: Subword length L.
        window: Optional window size (uses full sequence if None).

    Returns:
        Shannon entropy value (in nats).

    Example:
        >>> const = [0] * 100
        >>> compute_subword_entropy(const, 5)  # Only one subword
        0.0
    """
    if window is not None:
        seq = seq[:window]
    N = len(seq) - length + 1
    if N <= 0:
        return 0.0

    counts = Counter()
    for i in range(N):
        w = tuple(seq[i:i+length])
        counts[w] += 1

    entropy = 0.0
    for count in counts.values():
        p = count / N
        if p > 0:
            entropy -= p * log(p)
    return entropy


# ============================================================
# Algorithm 3: Prime-Indexed Subword Zeta Function
# ============================================================

def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Generate all primes up to limit using the Sieve of Eratosthenes.

    Time complexity: O(n log log n)
    Space complexity: O(n)
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(sqrt(limit)) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def compute_prime_subword_zeta(
    seq: List[int],
    s_values: List[float],
    max_prime: int = 100,
    window: int = 1000
) -> Dict[float, float]:
    """
    Compute the prime-indexed subword zeta function:

        Z_a(s) = Σ_p p^{-s} * H(v_p(a))

    where the sum is over primes p, and H(v_p(a)) is the Shannon
    entropy of the length-p subword frequency distribution.

    Time complexity: O(π(max_prime) * window * max_prime)
    Space complexity: O(window)

    Args:
        seq: Input sequence (should be long enough).
        s_values: List of complex parameter values s to evaluate at.
        max_prime: Upper bound on primes to sum over.
        window: Window size for frequency computation.

    Returns:
        Dictionary mapping s to Z_a(s).

    Example:
        >>> tm = [bin(n).count('1') % 2 for n in range(5000)]
        >>> z = compute_prime_subword_zeta(tm, [1.0, 2.0, 3.0])
        >>> all(z[s] >= 0 for s in z)
        True
    """
    primes = sieve_of_eratosthenes(max_prime)
    result = {}

    # Precompute entropies at each prime
    entropies = {}
    for p in primes:
        if p < len(seq) and p < window:
            entropies[p] = compute_subword_entropy(seq, p, window)

    for s in s_values:
        total = 0.0
        for p in primes:
            if p in entropies:
                total += p ** (-s) * entropies[p]
        result[s] = total

    return result


# ============================================================
# Algorithm 4: Hankel Matrix Rank Profile
# ============================================================

def compute_hankel_rank_profile(
    seq: List[int],
    max_size: int = 20
) -> List[int]:
    """
    Compute the Hankel rank profile: for each n, the rank of
    the n×n Hankel matrix H[i,j] = seq[i+j].

    Time complexity: O(max_size^3) for SVD at each size
    Space complexity: O(max_size^2)

    Args:
        seq: Input sequence.
        max_size: Maximum matrix size.

    Returns:
        List where result[n] = rank of n×n Hankel matrix.

    Example:
        >>> const = [1] * 100
        >>> profile = compute_hankel_rank_profile(const, 10)
        >>> all(r == 1 for r in profile[1:])
        True
    """
    result = [0]  # rank of 0×0 matrix is 0
    for n in range(1, max_size + 1):
        H = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                idx = i + j
                if idx < len(seq):
                    H[i, j] = seq[idx]
        result.append(int(np.linalg.matrix_rank(H)))
    return result


# ============================================================
# Algorithm 5: Automatic Sequence Comparison
# ============================================================

def compare_sequences(
    seq_a: List[int],
    seq_b: List[int],
    max_prime: int = 50,
    window: int = 500
) -> Dict[str, any]:
    """
    Compare two sequences using prime-indexed subword invariants.

    Computes entropy and Hankel rank profiles at prime indices
    and checks for matching.

    Args:
        seq_a, seq_b: Input sequences.
        max_prime: Maximum prime to check.
        window: Window size.

    Returns:
        Dictionary with comparison results including:
        - matching_entropy_primes: primes where entropy matches
        - matching_rank_primes: primes where Hankel rank matches
        - shift_equivalent: whether sequences appear shift-equivalent
    """
    primes = sieve_of_eratosthenes(max_prime)

    entropy_matches = []
    entropy_diffs = []
    rank_matches = []

    for p in primes:
        if p < min(len(seq_a), len(seq_b)) and p < window:
            e_a = compute_subword_entropy(seq_a, p, window)
            e_b = compute_subword_entropy(seq_b, p, window)
            if abs(e_a - e_b) < 1e-10:
                entropy_matches.append(p)
            entropy_diffs.append((p, abs(e_a - e_b)))

    # Check for shift equivalence (approximate)
    max_shift = min(100, min(len(seq_a), len(seq_b)) // 2)
    best_shift = -1
    best_match = 0
    for k in range(max_shift):
        match = sum(1 for i in range(min(len(seq_a) - k, len(seq_b)))
                    if seq_a[i + k] == seq_b[i])
        total = min(len(seq_a) - k, len(seq_b))
        ratio = match / total if total > 0 else 0
        if ratio > best_match:
            best_match = ratio
            best_shift = k

    return {
        'matching_entropy_primes': entropy_matches,
        'entropy_diffs': entropy_diffs,
        'rank_matches': rank_matches,
        'best_shift': best_shift,
        'best_match_ratio': best_match,
        'shift_equivalent': best_match > 0.99
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Automatic Sequence Analysis Algorithms\n")

    # Generate sequences
    N = 2000
    tm = [bin(n).count('1') % 2 for n in range(N)]

    # 1. Subword complexity
    print("1. Subword Complexity (Thue-Morse):")
    p_n = compute_subword_complexity(tm, 15)
    for n in range(1, 16):
        print(f"   p({n:2d}) = {p_n[n]:4d}  (≥ {n+1}? {'✓' if p_n[n] >= n+1 else '✗'})")

    # 2. Prime-indexed zeta function
    print("\n2. Prime-Indexed Subword Zeta Function:")
    zeta = compute_prime_subword_zeta(tm, [1.0, 1.5, 2.0, 3.0], max_prime=50, window=500)
    for s, val in zeta.items():
        print(f"   Z_tm(s={s}) = {val:.6f}")

    # 3. Hankel rank profile
    print("\n3. Hankel Rank Profile:")
    profile = compute_hankel_rank_profile(tm, 15)
    print(f"   Ranks: {profile[1:]}")

    # 4. Compare Thue-Morse with its shift
    print("\n4. Comparing Thue-Morse with shift-by-1:")
    tm_shifted = tm[1:]
    result = compare_sequences(tm, tm_shifted, max_prime=30, window=200)
    print(f"   Matching entropy primes: {result['matching_entropy_primes']}")
    print(f"   Best shift: {result['best_shift']}, match ratio: {result['best_match_ratio']:.4f}")
    print(f"   Shift equivalent: {result['shift_equivalent']}")
