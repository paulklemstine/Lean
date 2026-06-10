"""
K-Mer Avoidance Framework: Core Algorithms

Type-hinted implementations of k-mer extraction, subword complexity,
and bias detection for sequences over finite alphabets.
"""

from typing import TypeVar, Sequence, Dict, Set, Tuple, List, Optional
from collections import Counter
import math

T = TypeVar('T')


def extract_kmer(seq: Sequence[T], k: int, i: int) -> Tuple[T, ...]:
    """Extract the k-mer starting at position i.

    Args:
        seq: Input sequence
        k: Window size
        i: Starting position (0-indexed)

    Returns:
        Tuple of k consecutive elements starting at position i

    Raises:
        IndexError: If i + k > len(seq)
    """
    if i + k > len(seq):
        raise IndexError(f"Position {i} + window {k} exceeds sequence length {len(seq)}")
    return tuple(seq[i:i + k])


def all_kmers(seq: Sequence[T], k: int) -> List[Tuple[T, ...]]:
    """Extract all k-mers from a sequence using a sliding window.

    Args:
        seq: Input sequence
        k: Window size

    Returns:
        List of all k-mers in order of position
    """
    n = len(seq)
    if k > n or k <= 0:
        return []
    return [extract_kmer(seq, k, i) for i in range(n - k + 1)]


def subword_complexity(seq: Sequence[T], k: int) -> int:
    """Compute the subword complexity at window size k.

    The subword complexity counts the number of distinct k-mers.

    Args:
        seq: Input sequence
        k: Window size

    Returns:
        Number of distinct k-mers
    """
    return len(set(all_kmers(seq, k)))


def is_kmer_repeat_free(seq: Sequence[T], k: int) -> bool:
    """Check if a sequence is k-mer repeat-free.

    A sequence is repeat-free if all k-mers at distinct positions are distinct.

    Args:
        seq: Input sequence
        k: Window size

    Returns:
        True if no two k-mers are identical
    """
    kmers = all_kmers(seq, k)
    return len(kmers) == len(set(kmers))


def ramsey_threshold(alpha: int, k: int) -> int:
    """Compute the Ramsey threshold for k-mer repetition.

    Any sequence of length >= threshold over an alpha-letter alphabet
    must contain a repeated k-mer.

    Args:
        alpha: Alphabet size
        k: Window size

    Returns:
        The threshold alpha^k + k
    """
    return alpha ** k + k


def composition_bias(seq: Sequence[T]) -> int:
    """Compute the composition bias of a sequence.

    Returns the number of distinct symbols used.

    Args:
        seq: Input sequence

    Returns:
        Number of distinct symbols
    """
    return len(set(seq))


def detect_bias(seq: Sequence[T], k: int, alpha: int) -> Dict[str, object]:
    """Detect composition bias using k-mer analysis.

    Compares the subword complexity against the theoretical maximum
    for an unbiased sequence.

    Args:
        seq: Input sequence
        k: Window size
        alpha: Full alphabet size

    Returns:
        Dictionary with bias detection results
    """
    sc = subword_complexity(seq, k)
    max_sc = alpha ** k
    bias = composition_bias(seq)
    biased_max = bias ** k

    return {
        "subword_complexity": sc,
        "max_possible": max_sc,
        "symbols_used": bias,
        "biased_max": biased_max,
        "is_biased": bias < alpha,
        "bias_detected": sc < max_sc,
        "bias_ratio": sc / max_sc if max_sc > 0 else 0,
    }


def kmer_frequency_profile(seq: Sequence[T], k: int) -> Dict[Tuple[T, ...], int]:
    """Compute the frequency profile of all k-mers.

    Args:
        seq: Input sequence
        k: Window size

    Returns:
        Dictionary mapping each k-mer to its frequency
    """
    return dict(Counter(all_kmers(seq, k)))


def subword_complexity_profile(seq: Sequence[T], max_k: Optional[int] = None) -> List[int]:
    """Compute the subword complexity for all window sizes k = 1, ..., max_k.

    Args:
        seq: Input sequence
        max_k: Maximum window size (defaults to len(seq))

    Returns:
        List where index k-1 gives the subword complexity at window size k
    """
    n = len(seq)
    if max_k is None:
        max_k = n
    return [subword_complexity(seq, k) for k in range(1, max_k + 1)]


def find_repeated_kmer(seq: Sequence[T], k: int) -> Optional[Tuple[int, int, Tuple[T, ...]]]:
    """Find the first repeated k-mer in a sequence.

    Args:
        seq: Input sequence
        k: Window size

    Returns:
        Tuple (i, j, kmer) where i < j are positions with identical k-mers,
        or None if no repetition exists
    """
    seen: Dict[Tuple[T, ...], int] = {}
    for i in range(len(seq) - k + 1):
        km = extract_kmer(seq, k, i)
        if km in seen:
            return (seen[km], i, km)
        seen[km] = i
    return None


def generate_de_bruijn(alpha: int, k: int) -> List[int]:
    """Generate a de Bruijn sequence of order k over alphabet {0, ..., alpha-1}.

    Uses Martin's algorithm (lexicographically smallest de Bruijn sequence).

    Args:
        alpha: Alphabet size
        k: Window size

    Returns:
        List of integers forming the de Bruijn sequence (length alpha^k + k - 1
        for the linear version, which contains every k-mer exactly once)
    """
    if k == 0:
        return [0]

    # Generate cyclic de Bruijn sequence using necklace algorithm
    sequence: List[int] = []
    a = [0] * (alpha * k)

    def db(t: int, p: int) -> None:
        if t > k:
            if k % p == 0:
                sequence.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, alpha):
                a[t] = j
                db(t + 1, t)

    db(1, 1)

    # Convert cyclic to linear by appending first k-1 elements
    linear = sequence + sequence[:k - 1]
    return linear
