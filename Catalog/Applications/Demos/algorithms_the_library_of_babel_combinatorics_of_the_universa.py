#!/usr/bin/env python3
"""
Library of Babel: Algorithms for Universal Information Spaces
Type-hinted implementations of key algorithms from the formalization.
"""

import math
from typing import List, Tuple, Optional, Dict
from functools import reduce


def volume_to_index(volume: List[int], alphabet_size: int) -> int:
    """Convert a volume (list of symbol indices) to its lexicographic index.
    
    This is the 'address' of a volume in the Library.
    O(L) time, where L is the volume length.
    
    Args:
        volume: List of integers in [0, alphabet_size)
        alphabet_size: Size of the alphabet (A)
    
    Returns:
        Integer index in [0, A^L)
    """
    index = 0
    for symbol in volume:
        index = index * alphabet_size + symbol
    return index


def index_to_volume(index: int, alphabet_size: int, length: int) -> List[int]:
    """Convert a lexicographic index to its corresponding volume.
    
    Inverse of volume_to_index. O(L) time.
    
    Args:
        index: Integer in [0, A^L)
        alphabet_size: Size of the alphabet (A)
        length: Length of the volume (L)
    
    Returns:
        List of integers in [0, alphabet_size)
    """
    volume = []
    for _ in range(length):
        volume.append(index % alphabet_size)
        index //= alphabet_size
    return volume[::-1]


def hamming_distance(v: List[int], w: List[int]) -> int:
    """Compute the Hamming distance between two volumes.
    
    Args:
        v, w: Equal-length lists of integers
    
    Returns:
        Number of positions where v and w differ
    """
    return sum(1 for a, b in zip(v, w) if a != b)


def hamming_sphere_size(alphabet_size: int, length: int, radius: int) -> int:
    """Exact size of the Hamming sphere of given radius.
    
    |S(r)| = C(L, r) * (A-1)^r
    
    This follows from choosing r positions to change (C(L,r) ways)
    and changing each to one of (A-1) other symbols.
    """
    return math.comb(length, radius) * (alphabet_size - 1) ** radius


def hamming_ball_size(alphabet_size: int, length: int, radius: int) -> int:
    """Exact size of the Hamming ball of given radius.
    
    |B(r)| = sum_{k=0}^{r} C(L, k) * (A-1)^k
    """
    return sum(hamming_sphere_size(alphabet_size, length, k)
               for k in range(min(radius, length) + 1))


def compression_deficiency(
    alphabet_size: int, full_length: int, compressed_length: int
) -> Tuple[int, float]:
    """Compute the minimum information deficiency of compression.
    
    For any compression from A^L to A^M:
    - At least A^L - A^M volumes are incompressible
    - The incompressible fraction ≥ 1 - A^(M-L)
    
    Returns:
        (minimum_incompressible_count, incompressible_fraction)
    """
    full = alphabet_size ** full_length
    compressed = alphabet_size ** compressed_length
    deficiency = full - compressed
    fraction = deficiency / full
    return deficiency, fraction


def periodic_volume_count(alphabet_size: int, length: int, period: int) -> int:
    """Number of volumes periodic with period p (when p | L).
    
    A p-periodic volume satisfies v[i] = v[i+p] for all valid i.
    Such volumes are determined by their first p characters: A^p total.
    """
    assert length % period == 0, f"Period {period} must divide length {length}"
    return alphabet_size ** period


def fiber_count(
    alphabet_size: int, length: int, freq: int
) -> int:
    """Number of volumes where a fixed symbol appears exactly `freq` times.
    
    = C(L, freq) * (A-1)^(L-freq)
    
    Choose freq positions for the symbol, fill rest with A-1 other symbols.
    """
    return math.comb(length, freq) * (alphabet_size - 1) ** (length - freq)


def catalog_impossibility_ratio(
    alphabet_size: int, length: int, description_size: int
) -> float:
    """Fraction of catalog schemes representable by a single volume.
    
    At most A^L out of D^(A^L) schemes can be represented.
    Returns log10 of the ratio for numerical stability.
    """
    lib_size = alphabet_size ** length  # A^L
    # log10(A^L / D^(A^L)) = L*log10(A) - A^L * log10(D)
    log_representable = length * math.log10(alphabet_size)
    log_total = lib_size * math.log10(description_size)
    return log_representable - log_total


def find_nearest_volume(
    target: List[int],
    candidates: List[List[int]]
) -> Tuple[int, List[int]]:
    """Find the nearest volume by Hamming distance (brute force).
    
    Returns:
        (distance, nearest_volume)
    """
    best_dist = len(target) + 1
    best_vol = candidates[0]
    for vol in candidates:
        d = hamming_distance(target, vol)
        if d < best_dist:
            best_dist = d
            best_vol = vol
    return best_dist, best_vol


def generate_de_bruijn(alphabet_size: int, length: int) -> List[int]:
    """Generate a de Bruijn sequence B(A, L).
    
    A de Bruijn sequence contains every possible L-length substring
    over an A-symbol alphabet exactly once. Length = A^L.
    
    Uses Martin's algorithm (greedy approach).
    """
    k, n = alphabet_size, length
    if n == 0:
        return [0]
    
    sequence: List[int] = []
    a = [0] * (k * n)
    
    def db(t: int, p: int) -> None:
        if t > n:
            if n % p == 0:
                sequence.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, k):
                a[t] = j
                db(t + 1, t)
    
    db(1, 1)
    return sequence


def mini_library_catalog(
    alphabet_size: int = 4,
    book_length: int = 4
) -> Dict[str, any]:
    """Construct a complete catalog for a mini-library.
    
    Demonstrates the de Bruijn sequence approach for locating volumes.
    
    Returns dict with library statistics and the de Bruijn sequence.
    """
    lib_size = alphabet_size ** book_length
    db_seq = generate_de_bruijn(alphabet_size, book_length)
    
    # Verify: every book_length-gram appears in the (cyclic) de Bruijn sequence
    extended = db_seq + db_seq[:book_length - 1]
    substrings = set()
    for i in range(len(db_seq)):
        substr = tuple(extended[i:i + book_length])
        substrings.add(substr)
    
    return {
        "alphabet_size": alphabet_size,
        "book_length": book_length,
        "library_size": lib_size,
        "de_bruijn_length": len(db_seq),
        "unique_substrings": len(substrings),
        "all_found": len(substrings) == lib_size,
        "de_bruijn_sequence": db_seq[:50],  # First 50 elements
    }


if __name__ == "__main__":
    # Demonstrate algorithms
    print("=== Algorithm Demonstrations ===\n")
    
    # Volume addressing
    vol = [1, 2, 0, 3]
    idx = volume_to_index(vol, 4)
    recovered = index_to_volume(idx, 4, 4)
    print(f"Volume {vol} → index {idx} → recovered {recovered}")
    assert vol == recovered
    
    # Hamming geometry
    print(f"\nHamming ball sizes (A=4, L=16):")
    for r in range(6):
        print(f"  B({r}) = {hamming_ball_size(4, 16, r):,}")
    
    # De Bruijn sequence
    result = mini_library_catalog(4, 4)
    print(f"\nMini-library catalog (A={result['alphabet_size']}, L={result['book_length']}):")
    print(f"  Library size: {result['library_size']}")
    print(f"  De Bruijn sequence length: {result['de_bruijn_length']}")
    print(f"  All volumes found: {result['all_found']}")
    print(f"  First 20 symbols: {result['de_bruijn_sequence'][:20]}")
