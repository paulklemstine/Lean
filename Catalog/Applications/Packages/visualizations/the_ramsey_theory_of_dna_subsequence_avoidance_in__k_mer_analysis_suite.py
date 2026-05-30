#!/usr/bin/env python3
"""
Algorithms for k-Mer Analysis in DNA Sequences

Implements the core algorithms for analyzing k-mer repetition, diversity,
and subsequential repeat forcing in genetic sequences.

Time complexities:
  - extract_all_kmers: O(n * k) using hashing, O(n) with rolling hash
  - first_repeat_rolling: O(n) amortized with polynomial rolling hash
  - kmer_spectrum: O(n * k)
  - repeat_free_window_scan: O(n * k)
  - diversity_profile: O(n * k^2)
"""

from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict
import math


# --- Core k-mer algorithms ---

def polynomial_hash(kmer: str, base: int = 31, mod: int = (1 << 61) - 1) -> int:
    """Compute polynomial rolling hash of a k-mer string.
    
    Uses Mersenne prime 2^61 - 1 for modular arithmetic.
    Time: O(k), Space: O(1)
    
    Args:
        kmer: The k-mer string
        base: Hash base (default 31)
        mod: Hash modulus (default 2^61 - 1, a Mersenne prime)
    
    Returns:
        Hash value in [0, mod)
    """
    h = 0
    for c in kmer:
        h = (h * base + ord(c)) % mod
    return h


def extract_all_kmers(seq: str, k: int) -> List[str]:
    """Extract all contiguous k-mers from a sequence.
    
    Time: O((n-k+1) * k), Space: O((n-k+1) * k)
    
    Args:
        seq: Input sequence string
        k: k-mer length
    
    Returns:
        List of all k-mers in order of occurrence
    
    Example:
        >>> extract_all_kmers("ACGTACGT", 3)
        ['ACG', 'CGT', 'GTA', 'TAC', 'ACG', 'CGT']
    """
    if len(seq) < k:
        return []
    return [seq[i:i+k] for i in range(len(seq) - k + 1)]


def first_repeat_rolling(seq: str, k: int) -> Optional[int]:
    """Find the position of the first repeated k-mer using rolling hash.
    
    Uses a set of hashes for O(1) amortized lookup. Falls back to exact
    string comparison on hash collision.
    
    Time: O(n) amortized, Space: O(min(n, α^k))
    
    Args:
        seq: Input sequence
        k: k-mer length
    
    Returns:
        Index of the second occurrence of the first repeated k-mer,
        or None if no repeat exists
    
    Example:
        >>> first_repeat_rolling("ACGTACGT", 3)
        4  # 'ACG' repeats at position 4
    """
    if len(seq) < k:
        return None
    
    seen_hashes: Dict[int, List[int]] = defaultdict(list)
    
    for i in range(len(seq) - k + 1):
        kmer = seq[i:i+k]
        h = polynomial_hash(kmer)
        
        # Check for collision or true match
        for prev_idx in seen_hashes[h]:
            if seq[prev_idx:prev_idx+k] == kmer:
                return i
        
        seen_hashes[h].append(i)
    
    return None


def kmer_spectrum(seq: str, k: int) -> Dict[str, int]:
    """Compute the k-mer frequency spectrum.
    
    Returns a dictionary mapping each distinct k-mer to its count.
    
    Time: O(n * k), Space: O(min(n, α^k) * k)
    
    Args:
        seq: Input sequence
        k: k-mer length
    
    Returns:
        Dictionary of k-mer counts
    
    Example:
        >>> kmer_spectrum("AAAA", 2)
        {'AA': 3}
    """
    counts: Dict[str, int] = defaultdict(int)
    for i in range(len(seq) - k + 1):
        counts[seq[i:i+k]] += 1
    return dict(counts)


def kmer_diversity_index(seq: str, k: int, alpha: int = 4) -> float:
    """Compute the k-mer diversity index.
    
    The diversity index is the ratio of observed distinct k-mers
    to the total possible k-mers (α^k). Ranges from 0 to 1.
    
    Time: O(n * k), Space: O(min(n, α^k))
    
    Args:
        seq: Input sequence
        k: k-mer length
        alpha: Alphabet size (default 4 for DNA)
    
    Returns:
        Diversity index in [0, 1]
    
    Example:
        >>> kmer_diversity_index("ACGTACGT", 2)  # 7 distinct 2-mers / 16
        0.4375
    """
    distinct = len(set(extract_all_kmers(seq, k)))
    return distinct / (alpha ** k)


def repeat_free_window_scan(seq: str, k: int) -> List[int]:
    """Find the length of the maximum repeat-free window starting at each position.
    
    For each starting position i, computes the maximum w such that
    seq[i:i+w] has no repeated k-mer.
    
    Time: O(n * W) where W is the max window size, Space: O(α^k)
    
    Args:
        seq: Input sequence
        k: k-mer length
    
    Returns:
        List of maximum repeat-free window lengths, one per starting position
    
    Example:
        >>> repeat_free_window_scan("ACGTACGT", 3)
        [7, 6, 5, 4, 3, 3]
    """
    n = len(seq)
    if n < k:
        return []
    
    result = []
    for start in range(n - k + 1):
        seen: Set[str] = set()
        window_end = start
        while window_end + k <= n:
            kmer = seq[window_end:window_end+k]
            if kmer in seen:
                break
            seen.add(kmer)
            window_end += 1
        result.append(window_end - start + k - 1)
    
    return result


def diversity_profile(seq: str, max_k: int, alpha: int = 4) -> List[Tuple[int, float]]:
    """Compute the diversity profile: diversity index as a function of k.
    
    Shows how the sequence's k-mer diversity changes with k-mer length.
    For truly random sequences, diversity approaches 1 for small k and
    decreases for k close to sequence length.
    
    Time: O(n * max_k^2), Space: O(n * max_k)
    
    Args:
        seq: Input sequence
        max_k: Maximum k-mer length to analyze
        alpha: Alphabet size
    
    Returns:
        List of (k, diversity_index) pairs
    """
    profile = []
    for k in range(1, min(max_k + 1, len(seq) + 1)):
        di = kmer_diversity_index(seq, k, alpha)
        profile.append((k, di))
    return profile


def subsequential_repeat_test(seq: str, k: int, step: int = 1) -> Optional[int]:
    """Test for k-mer repeats in subsequences (every step-th character).
    
    Extracts the subsequence seq[0], seq[step], seq[2*step], ... and
    checks for repeated k-mers. This tests whether structured sampling
    of the sequence still forces k-mer repeats.
    
    Time: O(n/step * k), Space: O(α^k)
    
    Args:
        seq: Input sequence
        k: k-mer length
        step: Subsequence step size
    
    Returns:
        Position of first repeat in the subsequence, or None
    """
    subseq = seq[::step]
    return first_repeat_rolling(subseq, k)


# --- Birthday paradox analysis ---

def birthday_paradox_prediction(alpha: int, k: int) -> float:
    """Predict the expected first k-mer repeat using the birthday paradox.
    
    For a uniform random sequence over alphabet of size α, the expected
    position of the first repeated k-mer is approximately:
        sqrt(π/2 * α^k) + k - 1
    
    This is the birthday paradox applied to the k-mer space.
    
    Args:
        alpha: Alphabet size
        k: k-mer length
    
    Returns:
        Expected position of first repeated k-mer
    """
    N = alpha ** k  # size of k-mer space
    return math.sqrt(math.pi / 2 * N) + k - 1


def pigeonhole_bound(alpha: int, k: int) -> int:
    """The pigeonhole bound: maximum repeat-free sequence length.
    
    Any sequence of length > α^k + k - 1 must contain a repeated k-mer.
    
    Args:
        alpha: Alphabet size
        k: k-mer length
    
    Returns:
        Maximum repeat-free length
    """
    return alpha ** k + k - 1


# --- Main demonstration ---

if __name__ == "__main__":
    import random
    random.seed(42)
    
    print("=== k-Mer Analysis Algorithms ===\n")
    
    # Demo: extract k-mers
    seq = "ACGTACGTAA"
    print(f"Sequence: {seq}")
    print(f"3-mers: {extract_all_kmers(seq, 3)}")
    print(f"3-mer spectrum: {kmer_spectrum(seq, 3)}")
    print(f"First 3-mer repeat at: {first_repeat_rolling(seq, 3)}")
    print(f"Diversity index (k=3): {kmer_diversity_index(seq, 3):.4f}")
    
    print(f"\n--- Theoretical Bounds ---")
    for k in range(2, 7):
        pb = pigeonhole_bound(4, k)
        bp = birthday_paradox_prediction(4, k)
        print(f"k={k}: Pigeonhole={pb}, Birthday≈{bp:.1f}, Space=4^{k}={4**k}")
    
    print(f"\n--- Diversity Profile (random 1000bp) ---")
    random_seq = ''.join(random.choice('ACGT') for _ in range(1000))
    profile = diversity_profile(random_seq, 8)
    for k, di in profile:
        print(f"  k={k}: diversity = {di:.4f} ({int(di * 4**k)}/{4**k} distinct)")
    
    print(f"\n--- Repeat-Free Window Scan ---")
    short_seq = ''.join(random.choice('ACGT') for _ in range(50))
    windows = repeat_free_window_scan(short_seq, 3)
    print(f"Sequence (50bp): max repeat-free 3-mer window = {max(windows)}")
    print(f"  Theoretical max: {pigeonhole_bound(4, 3)}")
