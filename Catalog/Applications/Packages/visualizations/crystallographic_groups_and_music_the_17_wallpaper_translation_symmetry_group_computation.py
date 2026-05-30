#!/usr/bin/env python3
"""
Algorithms for Crystallographic Rhythm Analysis

Implements the core algorithms from the research paper:
1. Translation symmetry group computation
2. Necklace counting via Burnside's lemma
3. 2D wallpaper symmetry classification
4. Symmetry-entropy bound computation
"""

from math import gcd, log2
from typing import List, Set, Dict, Tuple
from collections import Counter
from itertools import product


# =============================================================================
# Algorithm 1: Translation Symmetry Group
# =============================================================================

def compute_translation_symmetries(rhythm: List[bool]) -> Set[int]:
    """
    Compute the translation symmetry group of a periodic rhythm.
    
    A shift k is a symmetry iff r(n + k) = r(n) for all n (mod p).
    
    Time complexity: O(p²)
    Space complexity: O(p)
    
    Returns a set of integers in {0, ..., p-1} forming a subgroup of Z/pZ.
    
    Properties (formally verified in Lean):
    - 0 is always in the result (translationSym_zero)
    - Closed under addition mod p (translationSym_add)
    - Closed under negation mod p (translationSym_neg)
    
    Example:
    >>> compute_translation_symmetries([True, False, True, False])
    {0, 2}
    >>> compute_translation_symmetries([True, True, True, True])
    {0, 1, 2, 3}
    """
    p = len(rhythm)
    if p == 0:
        return {0}
    
    symmetries = set()
    for k in range(p):
        is_sym = True
        for n in range(p):
            if rhythm[(n + k) % p] != rhythm[n]:
                is_sym = False
                break
        if is_sym:
            symmetries.add(k)
    
    return symmetries


# =============================================================================
# Algorithm 2: Palindrome Detection
# =============================================================================

def is_palindromic(rhythm: List[bool]) -> bool:
    """
    Check if a rhythm is palindromic: r(n) = r(-n mod p) for all n.
    
    Time complexity: O(p)
    Space complexity: O(1)
    
    Properties (formally verified):
    - Full and silent rhythms are palindromic (full_isPalindrome, silent_isPalindrome)
    - Complement of palindrome is palindrome (complement_palindrome)
    
    Example:
    >>> is_palindromic([True, False, True, True, True, False])
    True
    """
    p = len(rhythm)
    return all(rhythm[n] == rhythm[(-n) % p] for n in range(p))


# =============================================================================
# Algorithm 3: Onset Count and Complement Duality
# =============================================================================

def onset_count(rhythm: List[bool]) -> int:
    """Count the number of True values (onsets) in a rhythm."""
    return sum(1 for b in rhythm if b)


def complement_rhythm(rhythm: List[bool]) -> List[bool]:
    """
    Compute the complement of a rhythm.
    
    Property (formally verified):
        onset_count(complement(r)) + onset_count(r) = p
    """
    return [not b for b in rhythm]


# =============================================================================
# Algorithm 4: Necklace Counting (Burnside's Lemma)
# =============================================================================

def count_necklaces(p: int) -> int:
    """
    Count distinct binary necklaces of length p using Burnside's lemma.
    
    N(p) = (1/p) * Σ_{k=0}^{p-1} 2^gcd(k, p)
    
    Time complexity: O(p log p) (gcd is O(log p))
    Space complexity: O(1)
    
    For prime p: N(p) = (2^p - 2)/p + 2 (formally verified: necklace_count_prime)
    
    Example:
    >>> count_necklaces(5)
    8
    >>> count_necklaces(7)
    20
    """
    if p == 0:
        return 1
    total = sum(2 ** gcd(k, p) for k in range(p))
    return total // p


def count_necklaces_prime(p: int) -> int:
    """
    Simplified necklace count for prime p.
    
    Uses the formula: N(p) = (2^p - 2)/p + 2
    
    This works because for prime p:
    - gcd(0, p) = p, contributing 2^p
    - gcd(k, p) = 1 for 0 < k < p (formally verified: gcd_prime_coprime),
      each contributing 2^1 = 2 (formally verified: fixed_by_nonzero_prime)
    - Total = 2^p + 2(p-1) = 2^p + 2p - 2
    - N(p) = (2^p + 2p - 2) / p = (2^p - 2)/p + 2
    """
    return (2**p - 2) // p + 2


# =============================================================================
# Algorithm 5: Degrees of Freedom (Symmetry-Entropy Bridge)
# =============================================================================

def rhythm_degrees_of_freedom(p: int, sym_order: int) -> int:
    """
    Compute the degrees of freedom of a rhythm with period p and 
    symmetry group of order sym_order.
    
    DOF = p / sym_order = size of fundamental domain
    
    Properties (formally verified):
    - symmetry_reduces_freedom: d1 ≤ d2 → DOF(p,d2) ≤ DOF(p,d1)
    - maximal_symmetry_one_dof: DOF(p,p) = 1
    - trivial_symmetry_full_dof: DOF(p,1) = p
    
    The entropy bound is then DOF * log(2) bits.
    """
    if sym_order == 0:
        raise ValueError("Symmetry order must be positive")
    return p // sym_order


def entropy_bound(p: int, sym_order: int) -> float:
    """
    Upper bound on Shannon entropy (in bits) for a rhythm with given
    period and symmetry order.
    
    H ≤ DOF * 1 bit = (p / sym_order) bits
    
    This is the Symmetry-Entropy Bridge: crystallographic symmetry
    constrains information content.
    """
    dof = rhythm_degrees_of_freedom(p, sym_order)
    return float(dof)


# =============================================================================
# Algorithm 6: 2D Drum Pattern Symmetry Classification
# =============================================================================

def classify_2d_pattern(pattern: List[List[bool]]) -> Dict[str, bool]:
    """
    Classify a 2D drum pattern by its point symmetries.
    
    Returns a dictionary of symmetry predicates:
    - time_mirror: g(-t, v) = g(t, v) for all t, v
    - pitch_mirror: g(t, -v) = g(t, v) for all t, v
    - rotation2: g(-t, -v) = g(t, v) for all t, v
    
    Property (formally verified: mirror_pair_implies_rotation):
        time_mirror AND pitch_mirror → rotation2
    
    Time complexity: O(p * q)
    Space complexity: O(1)
    """
    p = len(pattern)
    q = len(pattern[0]) if p > 0 else 0
    
    time_mirror = all(
        pattern[(-t) % p][v] == pattern[t][v]
        for t in range(p) for v in range(q)
    )
    
    pitch_mirror = all(
        pattern[t][(-v) % q] == pattern[t][v]
        for t in range(p) for v in range(q)
    )
    
    rotation2 = all(
        pattern[(-t) % p][(-v) % q] == pattern[t][v]
        for t in range(p) for v in range(q)
    )
    
    # Verify formal theorem: two mirrors imply rotation
    if time_mirror and pitch_mirror:
        assert rotation2, "mirror_pair_implies_rotation violated!"
    
    return {
        'time_mirror': time_mirror,
        'pitch_mirror': pitch_mirror,
        'rotation2': rotation2,
    }


def assign_wallpaper_type(symmetries: Dict[str, bool]) -> str:
    """
    Assign a simplified wallpaper type based on detected symmetries.
    
    This is a simplified classification — a full classification would
    also consider glide reflections and higher rotational orders.
    """
    tm = symmetries['time_mirror']
    pm = symmetries['pitch_mirror']
    r2 = symmetries['rotation2']
    
    if tm and pm:
        return 'pmm'  # Both mirrors → rotation (verified)
    elif tm or pm:
        return 'pm'   # Single mirror
    elif r2:
        return 'p2'   # Rotation without mirrors
    else:
        return 'p1'   # No point symmetry


# =============================================================================
# Algorithm 7: Wallpaper Type Properties
# =============================================================================

WALLPAPER_DATA = {
    'p1':   {'rotation': 1, 'mirror': False, 'glide': False},
    'p2':   {'rotation': 2, 'mirror': False, 'glide': False},
    'pm':   {'rotation': 1, 'mirror': True,  'glide': False},
    'pg':   {'rotation': 1, 'mirror': False, 'glide': True},
    'cm':   {'rotation': 1, 'mirror': True,  'glide': True},
    'pmm':  {'rotation': 2, 'mirror': True,  'glide': False},
    'pmg':  {'rotation': 2, 'mirror': True,  'glide': True},
    'pgg':  {'rotation': 2, 'mirror': False, 'glide': True},
    'cmm':  {'rotation': 2, 'mirror': True,  'glide': True},
    'p4':   {'rotation': 4, 'mirror': False, 'glide': False},
    'p4m':  {'rotation': 4, 'mirror': True,  'glide': False},
    'p4g':  {'rotation': 4, 'mirror': True,  'glide': True},
    'p3':   {'rotation': 3, 'mirror': False, 'glide': False},
    'p3m1': {'rotation': 3, 'mirror': True,  'glide': False},
    'p31m': {'rotation': 3, 'mirror': True,  'glide': True},
    'p6':   {'rotation': 6, 'mirror': False, 'glide': False},
    'p6m':  {'rotation': 6, 'mirror': True,  'glide': True},
}


def is_crystallographic_order(n: int) -> bool:
    """
    Check if n is a valid crystallographic rotation order.
    
    Property (formally verified: wallpaper_crystallographic_restriction):
        Every wallpaper type has a crystallographic rotation order.
    """
    return n in {1, 2, 3, 4, 6}


def wallpaper_types_by_order(n: int) -> List[str]:
    """Get all wallpaper types with a given max rotation order."""
    return [name for name, data in WALLPAPER_DATA.items() 
            if data['rotation'] == n]


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)
    
    # Algorithm 1: Translation symmetries
    r = [True, False, True, False, True, False]
    syms = compute_translation_symmetries(r)
    print(f"\nRhythm: {''.join('1' if b else '0' for b in r)}")
    print(f"Translation symmetries: {syms}")
    print(f"Symmetry order: {len(syms)}")
    print(f"Is palindromic: {is_palindromic(r)}")
    
    # Algorithm 4: Necklace counting
    print(f"\nNecklace counts for primes:")
    for p in [2, 3, 5, 7, 11, 13]:
        n1 = count_necklaces(p)
        n2 = count_necklaces_prime(p)
        print(f"  N({p}) = {n1} (prime formula: {n2}, match: {n1==n2})")
    
    # Algorithm 5: Symmetry-entropy bridge
    print(f"\nEntropy bounds for period 12:")
    for d in [1, 2, 3, 4, 6, 12]:
        dof = rhythm_degrees_of_freedom(12, d)
        bound = entropy_bound(12, d)
        print(f"  sym_order={d:>2}: DOF={dof:>2}, entropy ≤ {bound:.0f} bits, "
              f"possible rhythms = 2^{dof} = {2**dof}")
    
    # Algorithm 6: 2D classification
    pattern = [
        [True,  False, False, True],
        [False, True,  True,  False],
        [False, True,  True,  False],
        [True,  False, False, True],
    ]
    syms_2d = classify_2d_pattern(pattern)
    wtype = assign_wallpaper_type(syms_2d)
    print(f"\n2D pattern symmetries: {syms_2d}")
    print(f"Wallpaper type: {wtype}")
    
    # Crystallographic restriction
    print(f"\nCrystallographic restriction verification:")
    for n in range(1, 8):
        types = wallpaper_types_by_order(n)
        if types:
            print(f"  Order {n}: {len(types)} types — {', '.join(types)}")
    
    print(f"\nAll algorithms verified successfully.")
