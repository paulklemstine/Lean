#!/usr/bin/env python3
"""
Algorithms for Crystallographic Rhythm Analysis

Type-hinted implementations of the core algorithms for classifying
drum patterns by wallpaper group symmetry.
"""

import math
from typing import List, Tuple, Dict, Optional, Set


# --- Core Data Types ---

Pattern1D = List[int]  # Binary rhythm: list of 0s and 1s
Pattern2D = List[List[int]]  # Drum pattern: 2D grid of 0s and 1s


# --- Symmetry Detection ---

def detect_time_mirror(grid: Pattern2D) -> bool:
    """
    Detect time-mirror symmetry in a drum pattern.

    A pattern has time-mirror symmetry if g(T-1-t, p) = g(t, p) for all t, p.
    Musically: the rhythm is a palindrome in time.

    Time complexity: O(T * P)
    """
    T: int = len(grid)
    if T == 0:
        return True
    P: int = len(grid[0])
    for t in range(T // 2 + 1):
        for p in range(P):
            if grid[T - 1 - t][p] != grid[t][p]:
                return False
    return True


def detect_pitch_mirror(grid: Pattern2D) -> bool:
    """
    Detect pitch-mirror symmetry in a drum pattern.

    A pattern has pitch-mirror symmetry if g(t, P-1-p) = g(t, p) for all t, p.
    Musically: swapping instruments preserves the pattern.

    Time complexity: O(T * P)
    """
    T: int = len(grid)
    if T == 0:
        return True
    P: int = len(grid[0])
    for t in range(T):
        for p in range(P // 2 + 1):
            if grid[t][P - 1 - p] != grid[t][p]:
                return False
    return True


def detect_rotation2(grid: Pattern2D) -> bool:
    """
    Detect 2-fold rotational symmetry.

    g(T-1-t, P-1-p) = g(t, p) for all t, p.
    Musically: call-and-response with inversion.

    Time complexity: O(T * P)
    """
    T: int = len(grid)
    if T == 0:
        return True
    P: int = len(grid[0])
    for t in range(T):
        for p in range(P):
            if grid[T - 1 - t][P - 1 - p] != grid[t][p]:
                return False
    return True


def detect_glide_reflection(grid: Pattern2D, half_shift: int) -> bool:
    """
    Detect glide reflection symmetry.

    g((t + half_shift) mod T, P-1-p) = g(t, p) for all t, p.
    Musically: canon with inversion.

    Time complexity: O(T * P)
    """
    T: int = len(grid)
    if T == 0:
        return True
    P: int = len(grid[0])
    for t in range(T):
        for p in range(P):
            if grid[(t + half_shift) % T][P - 1 - p] != grid[t][p]:
                return False
    return True


def detect_rotation4(grid: Pattern2D) -> bool:
    """
    Detect 4-fold rotational symmetry (requires square grid T = P).

    g(p, T-1-t) = g(t, p) for all t, p.

    Time complexity: O(T^2)
    """
    T: int = len(grid)
    if T == 0:
        return True
    P: int = len(grid[0])
    if T != P:
        return False
    for t in range(T):
        for p in range(P):
            if grid[p][T - 1 - t] != grid[t][p]:
                return False
    return True


# --- Wallpaper Type Classification ---

def classify_wallpaper_type(grid: Pattern2D) -> str:
    """
    Classify a drum pattern by its wallpaper group type.

    Returns one of the 17 wallpaper type labels.

    Algorithm:
    1. Detect all symmetry elements
    2. Determine maximal rotation order
    3. Check mirror and glide presence
    4. Match to wallpaper type

    Time complexity: O(T * P)
    """
    T: int = len(grid)
    P: int = len(grid[0]) if grid else 0

    tm: bool = detect_time_mirror(grid)
    pm: bool = detect_pitch_mirror(grid)
    r2: bool = detect_rotation2(grid)
    r4: bool = detect_rotation4(grid) if T == P else False
    gl: bool = detect_glide_reflection(grid, T // 2) if T >= 2 else False

    # Determine maximal rotation order
    if r4:
        max_rot = 4
    elif r2:
        max_rot = 2
    else:
        max_rot = 1

    has_mirror: bool = tm or pm
    has_glide: bool = gl

    # Classification logic
    if max_rot == 4:
        if has_mirror and has_glide:
            return "p4g"
        elif has_mirror:
            return "p4m"
        else:
            return "p4"
    elif max_rot == 2:
        if has_mirror and has_glide:
            return "cmm"
        elif has_mirror and tm and pm:
            return "pmm"
        elif has_mirror and has_glide:
            return "pmg"
        elif has_glide:
            return "pgg"
        elif has_mirror:
            return "pmg" if gl else "pmm" if (tm and pm) else "pm"
        else:
            return "p2"
    else:  # max_rot == 1
        if has_mirror and has_glide:
            return "cm"
        elif has_mirror:
            return "pm"
        elif has_glide:
            return "pg"
        else:
            return "p1"


# --- Rhythm Operations ---

def reflect(rhythm: Pattern1D) -> Pattern1D:
    """
    Reflect a rhythm (time reversal).

    Property: reflect(reflect(r)) = r (involution)
    """
    return list(reversed(rhythm))


def is_palindromic(rhythm: Pattern1D) -> bool:
    """
    Check if a rhythm is palindromic.

    Equivalent to: rhythm == reflect(rhythm)
    """
    return rhythm == reflect(rhythm)


def cyclic_shift(rhythm: Pattern1D, d: int) -> Pattern1D:
    """Shift a rhythm cyclically by d positions."""
    n: int = len(rhythm)
    if n == 0:
        return []
    return [rhythm[(i + d) % n] for i in range(n)]


def stabilizer_size(rhythm: Pattern1D) -> int:
    """
    Compute the stabilizer size: number of cyclic shifts preserving the rhythm.

    Property: stabilizer_size(r) divides len(r)
    """
    n: int = len(rhythm)
    return sum(1 for d in range(n) if cyclic_shift(rhythm, d) == rhythm)


def minimal_period(rhythm: Pattern1D) -> int:
    """
    Compute the minimal period of a rhythm.

    Property: minimal_period(r) = len(r) / stabilizer_size(r)
    """
    n: int = len(rhythm)
    for p in range(1, n + 1):
        if n % p == 0 and cyclic_shift(rhythm, p) == rhythm:
            return p
    return n


# --- Burnside Counting ---

def euler_phi(n: int) -> int:
    """Euler's totient function φ(n)."""
    count: int = 0
    for k in range(1, n + 1):
        if math.gcd(k, n) == 1:
            count += 1
    return count


def count_necklaces(n: int) -> int:
    """
    Count distinct binary necklaces of length n.

    Formula: N(n) = (1/n) Σ_{d|n} φ(d) · 2^{n/d}

    This is an application of Burnside's lemma using the fact that
    the number of patterns fixed by d-rotation is 2^{gcd(d,n)}.
    """
    if n == 0:
        return 1
    total: int = sum(euler_phi(d) * (2 ** (n // d))
                     for d in range(1, n + 1) if n % d == 0)
    return total // n


def fixed_point_count(n: int, d: int) -> int:
    """
    Number of binary patterns of length n fixed by d-rotation.

    Theorem: |Fix(σ^d)| = 2^{gcd(d, n)}

    Proof: A pattern fixed by d-rotation must be constant on each
    coset of ⟨d⟩ in ℤ/nℤ. There are gcd(d,n) such cosets, each
    freely assignable.
    """
    return 2 ** math.gcd(d, n)


# --- Tensor Product Construction ---

def tensor_product(r1: Pattern1D, r2: Pattern1D) -> Pattern2D:
    """
    Construct a 2D drum pattern as the tensor product of two 1D rhythms.

    g(t, p) = r1(t) AND r2(p)

    Property: If r1 has time-mirror symmetry and r2 has pitch-mirror symmetry,
    then g has both mirrors and hence rotation2 (by our theorem).
    """
    return [[r1[t] & r2[p] for p in range(len(r2))] for t in range(len(r1))]


def verify_double_mirror_theorem(grid: Pattern2D) -> bool:
    """
    Verify the double mirror → rotation theorem on a specific pattern.

    Returns True if the implication holds (as it must, by our theorem).
    """
    tm: bool = detect_time_mirror(grid)
    pm: bool = detect_pitch_mirror(grid)
    r2: bool = detect_rotation2(grid)
    if tm and pm:
        return r2  # Must be True by theorem
    return True  # Hypothesis not satisfied, implication vacuously true


# --- Pattern Generation ---

def generate_palindromic_rhythms(n: int) -> List[Pattern1D]:
    """Generate all palindromic rhythms of length n."""
    results: List[Pattern1D] = []
    # Only need to specify first ceil(n/2) beats
    half: int = (n + 1) // 2
    for bits in range(2 ** half):
        first_half: List[int] = [(bits >> i) & 1 for i in range(half)]
        # Mirror to create full pattern
        full: List[int] = first_half + list(reversed(first_half[:n - half]))
        results.append(full)
    return results


def generate_symmetric_drum_patterns(T: int, P: int,
                                      symmetry: str = "pmm") -> List[Pattern2D]:
    """
    Generate drum patterns with specified symmetry type.

    For 'pmm' (double mirror): only specify top-left quadrant.
    """
    results: List[Pattern2D] = []
    half_T: int = (T + 1) // 2
    half_P: int = (P + 1) // 2

    if symmetry == "pmm":
        for bits in range(2 ** (half_T * half_P)):
            # Build quadrant
            quadrant: List[List[int]] = [
                [(bits >> (t * half_P + p)) & 1 for p in range(half_P)]
                for t in range(half_T)
            ]
            # Mirror to full pattern
            grid: List[List[int]] = [[0] * P for _ in range(T)]
            for t in range(T):
                for p in range(P):
                    st: int = t if t < half_T else T - 1 - t
                    sp: int = p if p < half_P else P - 1 - p
                    grid[t][p] = quadrant[st][sp]
            results.append(grid)

    return results


if __name__ == "__main__":
    # Quick test
    print("Necklace counts:", [count_necklaces(n) for n in range(1, 13)])
    print("Palindromic rhythms of length 5:", generate_palindromic_rhythms(5))

    # Verify double mirror theorem exhaustively for 3x3
    patterns_3x3 = [
        [[(bits >> (t * 3 + p)) & 1 for p in range(3)] for t in range(3)]
        for bits in range(2**9)
    ]
    all_ok = all(verify_double_mirror_theorem(g) for g in patterns_3x3)
    print(f"Double mirror theorem verified for all 3×3 patterns: {all_ok}")
