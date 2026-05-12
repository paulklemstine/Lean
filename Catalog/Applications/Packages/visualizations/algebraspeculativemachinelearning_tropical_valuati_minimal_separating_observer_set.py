#!/usr/bin/env python3
"""
Algorithms for Tropical Valuation Distillation

Implements the core algorithms from the research paper with full
type hints, docstrings, and complexity analysis.
"""

from typing import List, Tuple, Dict, Set, Optional
from itertools import combinations
from math import gcd, log2


# =============================================================================
# Algorithm 1: Valuation Profile Computation
# =============================================================================

def compute_valuation_profile(
    x: int,
    moduli: List[int]
) -> Tuple[int, ...]:
    """
    Compute the valuation profile of element x under modular observers.

    The valuation profile maps x to its tuple of residues modulo each observer.
    This is the tropical feature vector in the spectral compression framework.

    Args:
        x: Element of Z/nZ
        moduli: List of observer moduli [m₁, m₂, ..., mₖ]

    Returns:
        Tuple (x mod m₁, x mod m₂, ..., x mod mₖ)

    Complexity: O(k) where k = len(moduli)

    Example:
        >>> compute_valuation_profile(7, [2, 3, 5])
        (1, 1, 2)
    """
    return tuple(x % m for m in moduli)


# =============================================================================
# Algorithm 2: Observer Separation Check
# =============================================================================

def check_separation(
    x: int,
    y: int,
    moduli: List[int]
) -> Tuple[bool, Optional[int]]:
    """
    Check if observers separate x from y, returning a witness if so.

    Implements the constructive separation theorem: if x ≠ y and the
    observers separate them, returns the index of a separating observer.

    Args:
        x: First element
        y: Second element
        moduli: List of observer moduli

    Returns:
        (True, witness_index) if separated, (False, None) if equivalent

    Complexity: O(k) worst case, O(1) best case (early termination)

    Example:
        >>> check_separation(3, 7, [2, 5])
        (True, 1)  # mod 5 separates: 3%5=3, 7%5=2
    """
    for i, m in enumerate(moduli):
        if x % m != y % m:
            return True, i
    return False, None


# =============================================================================
# Algorithm 3: Full Separation Verification
# =============================================================================

def verify_full_separation(
    n: int,
    moduli: List[int]
) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Verify that the observer family fully separates Z/nZ.

    Checks all pairs of distinct elements. Returns the first
    unseparated pair if separation fails.

    Args:
        n: Size of Z/nZ
        moduli: List of observer moduli

    Returns:
        (True, None) if fully separating
        (False, (x, y)) if x ≠ y but observers don't separate them

    Complexity: O(n² · k) where k = len(moduli)

    Example:
        >>> verify_full_separation(6, [2, 3])
        (True, None)
        >>> verify_full_separation(6, [2])
        (False, (0, 2))
    """
    for x in range(n):
        for y in range(x + 1, n):
            separated, _ = check_separation(x, y, moduli)
            if not separated:
                return False, (x, y)
    return True, None


# =============================================================================
# Algorithm 4: Codebook Extraction
# =============================================================================

def extract_codebook(
    n: int,
    moduli: List[int]
) -> Dict[Tuple[int, ...], List[int]]:
    """
    Extract the minimal codebook from the observer family.

    Maps each valuation profile to the list of elements sharing that profile.
    When the family fully separates, each profile maps to exactly one element.

    Args:
        n: Size of Z/nZ
        moduli: List of observer moduli

    Returns:
        Dictionary mapping profiles to element lists

    Complexity: O(n · k) where k = len(moduli)

    Example:
        >>> extract_codebook(6, [2, 3])
        {(0, 0): [0], (1, 1): [1], (0, 2): [2], (1, 0): [3], (0, 1): [4], (1, 2): [5]}
    """
    codebook: Dict[Tuple[int, ...], List[int]] = {}
    for x in range(n):
        profile = compute_valuation_profile(x, moduli)
        if profile not in codebook:
            codebook[profile] = []
        codebook[profile].append(x)
    return codebook


# =============================================================================
# Algorithm 5: Separation Score Matrix
# =============================================================================

def separation_score_matrix(
    n: int,
    moduli: List[int]
) -> List[List[int]]:
    """
    Compute the pairwise separation score matrix.

    Entry (i, j) counts how many observers distinguish element i from element j.
    The matrix is symmetric with zeros on the diagonal.

    Args:
        n: Size of Z/nZ
        moduli: List of observer moduli

    Returns:
        n × n matrix of separation scores

    Complexity: O(n² · k)

    Example:
        >>> separation_score_matrix(4, [2])
        [[0, 1, 0, 1], [1, 0, 1, 0], [0, 1, 0, 1], [1, 0, 1, 0]]
    """
    matrix = [[0] * n for _ in range(n)]
    for x in range(n):
        for y in range(n):
            if x != y:
                matrix[x][y] = sum(
                    1 for m in moduli if x % m != y % m
                )
    return matrix


# =============================================================================
# Algorithm 6: Minimal Separating Observer Set
# =============================================================================

def find_minimal_separating_set(
    n: int,
    candidates: List[int],
    max_observers: int = 10
) -> Optional[List[int]]:
    """
    Find a minimal subset of candidate moduli that fully separates Z/nZ.

    Uses greedy search: at each step, adds the modulus that separates
    the most currently-unseparated pairs.

    Args:
        n: Size of Z/nZ
        candidates: List of candidate moduli
        max_observers: Maximum number of observers to use

    Returns:
        Minimal separating subset, or None if impossible

    Complexity: O(max_observers · |candidates| · n²)

    Example:
        >>> find_minimal_separating_set(6, [2, 3, 5, 7])
        [2, 3]
    """
    selected: List[int] = []
    remaining_candidates = list(candidates)

    for _ in range(max_observers):
        if not remaining_candidates:
            break

        # Check if already fully separating
        ok, _ = verify_full_separation(n, selected)
        if ok:
            return selected

        # Find the candidate that separates the most unseparated pairs
        best_m = None
        best_count = -1

        for m in remaining_candidates:
            trial = selected + [m]
            # Count newly separated pairs
            count = 0
            for x in range(n):
                for y in range(x + 1, n):
                    # Check if this pair was unseparated before
                    old_sep, _ = check_separation(x, y, selected) if selected else (False, None)
                    if not old_sep:
                        new_sep, _ = check_separation(x, y, trial)
                        if new_sep:
                            count += 1

            if count > best_count:
                best_count = count
                best_m = m

        if best_m is not None and best_count > 0:
            selected.append(best_m)
            remaining_candidates.remove(best_m)
        else:
            break

    ok, _ = verify_full_separation(n, selected)
    return selected if ok else None


# =============================================================================
# Algorithm 7: Compression Rate Computation
# =============================================================================

def compression_rate(
    n: int,
    moduli: List[int]
) -> float:
    """
    Compute the compression rate: codebook_size / n.

    A rate of 1.0 means no compression (all elements are distinguished).
    A rate less than 1.0 means some elements are merged by the observers.

    Args:
        n: Size of Z/nZ
        moduli: List of observer moduli

    Returns:
        Compression rate in [0, 1]

    Complexity: O(n · k)

    Example:
        >>> compression_rate(6, [2, 3])
        1.0
        >>> compression_rate(6, [2])
        0.333...
    """
    codebook = extract_codebook(n, moduli)
    return len(codebook) / n


# =============================================================================
# Algorithm 8: Stalk Class Computation
# =============================================================================

def compute_stalk_class(
    x: int,
    prime_modulus: int,
    observer_moduli: List[int]
) -> Tuple[int, Tuple[int, ...]]:
    """
    Compute the stalk valuation class at a prime congruence.

    The stalk class is a pair: (prime quotient class, observer profile).
    This is the local spectral data at a point of the prime spectrum.

    Args:
        x: Element
        prime_modulus: The prime congruence modulus
        observer_moduli: List of observer moduli

    Returns:
        (x mod prime_modulus, valuation_profile(x))

    Complexity: O(k) where k = len(observer_moduli)

    Example:
        >>> compute_stalk_class(7, 3, [2, 5])
        (1, (1, 2))
    """
    return (
        x % prime_modulus,
        compute_valuation_profile(x, observer_moduli)
    )


# =============================================================================
# Main: Run all algorithms with examples
# =============================================================================

if __name__ == '__main__':
    print("Tropical Valuation Distillation — Algorithm Demonstrations\n")

    # Algorithm 1
    print("Algorithm 1: Valuation Profile")
    for x in range(6):
        print(f"  v({x}) = {compute_valuation_profile(x, [2, 3])}")

    # Algorithm 2
    print("\nAlgorithm 2: Separation Check")
    print(f"  sep(3, 7, [2,5]) = {check_separation(3, 7, [2, 5])}")
    print(f"  sep(4, 6, [2]) = {check_separation(4, 6, [2])}")

    # Algorithm 3
    print("\nAlgorithm 3: Full Separation Verification")
    print(f"  Z/6Z with [2,3]: {verify_full_separation(6, [2, 3])}")
    print(f"  Z/6Z with [2]:   {verify_full_separation(6, [2])}")

    # Algorithm 4
    print("\nAlgorithm 4: Codebook Extraction")
    book = extract_codebook(6, [2, 3])
    for profile, elems in sorted(book.items()):
        print(f"  {profile} → {elems}")

    # Algorithm 5
    print("\nAlgorithm 5: Separation Score Matrix (Z/4Z, mod 2)")
    matrix = separation_score_matrix(4, [2])
    for row in matrix:
        print(f"  {row}")

    # Algorithm 6
    print("\nAlgorithm 6: Minimal Separating Set")
    result = find_minimal_separating_set(30, [2, 3, 5, 7, 11, 13])
    print(f"  Z/30Z: minimal set = {result}")

    # Algorithm 7
    print("\nAlgorithm 7: Compression Rate")
    print(f"  Z/6Z, [2,3]: rate = {compression_rate(6, [2, 3]):.3f}")
    print(f"  Z/6Z, [2]:   rate = {compression_rate(6, [2]):.3f}")
    print(f"  Z/6Z, [3]:   rate = {compression_rate(6, [3]):.3f}")

    # Algorithm 8
    print("\nAlgorithm 8: Stalk Classes")
    for x in range(6):
        stalk = compute_stalk_class(x, 3, [2, 3])
        print(f"  stalk({x}, mod 3) = {stalk}")
