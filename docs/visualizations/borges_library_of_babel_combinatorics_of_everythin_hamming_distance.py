#!/usr/bin/env python3
"""
Library of Babel: Core Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from typing import List, Dict, Tuple, Optional, Callable, Set
import math


def hamming_distance(x: List[int], y: List[int]) -> int:
    """
    Compute the Hamming distance between two words.

    Time complexity: O(n) where n = len(x) = len(y)

    Args:
        x: First word (list of symbol indices)
        y: Second word (list of symbol indices)

    Returns:
        Number of positions where x and y differ
    """
    assert len(x) == len(y), "Words must have equal length"
    return sum(1 for a, b in zip(x, y) if a != b)


def hamming_ball_volume(n: int, k: int, r: int) -> int:
    """
    Compute the volume (cardinality) of a Hamming ball.

    V(n, k, r) = sum_{i=0}^{r} C(n, i) * (k-1)^i

    Args:
        n: Word length
        k: Alphabet size
        r: Ball radius

    Returns:
        Number of words within Hamming distance r of any center
    """
    total = 0
    for i in range(min(r, n) + 1):
        total += math.comb(n, i) * (k - 1) ** i
    return total


def hamming_bound(n: int, k: int, t: int) -> int:
    """
    Compute the Hamming (sphere-packing) bound for error-correcting codes.

    For a code with minimum distance d = 2t + 1, the maximum code size is
    at most k^n / V(n, k, t).

    Args:
        n: Codeword length
        k: Alphabet size
        t: Error-correction capability (t = (d-1)/2)

    Returns:
        Upper bound on code size
    """
    vol = hamming_ball_volume(n, k, t)
    return k ** n // vol


def entropy_profile(word: List[int], max_scale: Optional[int] = None) -> Dict[int, int]:
    """
    Compute the entropy profile of a word at multiple scales.

    For each scale s, counts the number of distinct s-grams
    (contiguous substrings of length s).

    Args:
        word: Input word as list of symbol indices
        max_scale: Maximum scale to compute (default: min(len(word), 20))

    Returns:
        Dictionary mapping scale s to number of distinct s-grams
    """
    n = len(word)
    if max_scale is None:
        max_scale = min(n, 20)

    profile: Dict[int, int] = {}
    for s in range(1, max_scale + 1):
        if s > n:
            break
        sgrams: Set[Tuple[int, ...]] = set()
        for i in range(n - s + 1):
            sgrams.add(tuple(word[i:i + s]))
        profile[s] = len(sgrams)
    return profile


def is_maximally_complex(
    word: List[int],
    alphabet_size: int,
    threshold: int
) -> bool:
    """
    Check if a word is maximally complex up to a given threshold.

    A word is maximally complex at threshold t if for all 1 ≤ s ≤ t,
    the number of distinct s-grams equals min(n - s + 1, k^s).

    Args:
        word: Input word
        alphabet_size: Size of the alphabet
        threshold: Maximum scale to check

    Returns:
        True if the word is maximally complex at all scales up to threshold
    """
    n = len(word)
    profile = entropy_profile(word, threshold)

    for s in range(1, threshold + 1):
        if s > n:
            return False
        expected = min(n - s + 1, alphabet_size ** s)
        if profile.get(s, 0) != expected:
            return False
    return True


def compressibility_ratio(
    compress: Callable[[List[int]], List[int]],
    decompress: Callable[[List[int]], List[int]],
    words: List[List[int]]
) -> float:
    """
    Compute the fraction of words that are compressible under a scheme.

    A word w is compressible if decompress(compress(w)) == w.

    Args:
        compress: Compression function
        decompress: Decompression function
        words: List of words to test

    Returns:
        Fraction of words that roundtrip successfully
    """
    if not words:
        return 0.0
    compressible = sum(1 for w in words if decompress(compress(w)) == w)
    return compressible / len(words)


def expected_hamming_distance(n: int, k: int) -> float:
    """
    Compute the expected Hamming distance between two random words.

    E[d_H(x, y)] = n * (k-1) / k

    Args:
        n: Word length
        k: Alphabet size

    Returns:
        Expected Hamming distance
    """
    return n * (k - 1) / k


def hamming_distance_std(n: int, k: int) -> float:
    """
    Compute the standard deviation of Hamming distance between random words.

    Std[d_H(x, y)] = sqrt(n * (k-1) / k^2)

    Args:
        n: Word length
        k: Alphabet size

    Returns:
        Standard deviation of Hamming distance
    """
    return math.sqrt(n * (k - 1) / k ** 2)


def hamming_distance_exact_count(n: int, k: int, d: int) -> int:
    """
    Compute the exact number of words at Hamming distance d from a fixed word.

    Count = C(n, d) * (k-1)^d

    Args:
        n: Word length
        k: Alphabet size
        d: Target Hamming distance

    Returns:
        Number of words at exactly distance d
    """
    if d < 0 or d > n:
        return 0
    return math.comb(n, d) * (k - 1) ** d


def library_statistics() -> Dict[str, object]:
    """
    Compute key statistics for the Library of Babel.

    Returns:
        Dictionary with library statistics
    """
    n = 410 * 3200  # book length
    k = 25  # alphabet size

    return {
        "alphabet_size": k,
        "book_length": n,
        "library_size_log10": n * math.log10(k),
        "expected_hamming_distance": expected_hamming_distance(n, k),
        "hamming_distance_std": hamming_distance_std(n, k),
        "fraction_compressible_1char": k ** (n - 1) / k ** n,
        "incompressible_fraction_lower_bound": 1 - 1 / k,
    }


if __name__ == "__main__":
    stats = library_statistics()
    print("Library of Babel Statistics:")
    for key, value in stats.items():
        if isinstance(value, float):
            print(f"  {key}: {value:.4f}")
        else:
            print(f"  {key}: {value}")
