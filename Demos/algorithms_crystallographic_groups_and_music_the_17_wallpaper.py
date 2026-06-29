#!/usr/bin/env python3
"""
Crystallographic Rhythm Theory — Algorithms

Type-hinted implementations of the core algorithms for:
1. Euler's totient function and crystallographic restriction
2. Binary necklace enumeration (Burnside's lemma)
3. Rhythm symmetry classification
4. Drum pattern symmetry detection
"""

from math import gcd
from itertools import product as cartprod
from typing import Optional


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Euler's Totient and Crystallographic Restriction
# ═══════════════════════════════════════════════════════════════

def euler_totient(n: int) -> int:
    """
    Compute Euler's totient function φ(n).

    φ(n) = n · ∏_{p|n} (1 - 1/p)

    Time complexity: O(√n)
    """
    if n <= 0:
        return 0
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def is_crystallographic_order(n: int) -> bool:
    """
    Check if n is a crystallographic order.

    A positive integer n is crystallographic iff φ(n) ≤ 2,
    which holds iff n ∈ {1, 2, 3, 4, 6}.

    Time complexity: O(1)
    """
    return n in {1, 2, 3, 4, 6}


def crystallographic_orders_up_to(d: int) -> list[int]:
    """
    Find all n with φ(n) ≤ d.

    For d=2, returns {1,2,3,4,6} (2D crystallographic restriction).
    For d=4, returns {1,2,3,4,5,6,8,10,12} (4D restriction).

    Time complexity: O(N√N) where N is the largest output value.
    """
    # Upper bound: φ(n) > √(n/2) for n > 6, so n < 2(d+1)² suffices
    upper = max(2 * (d + 1) ** 2, 30)
    return [n for n in range(1, upper + 1) if euler_totient(n) <= d]


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Binary Necklace Enumeration
# ═══════════════════════════════════════════════════════════════

def necklace_count_prime(p: int) -> int:
    """
    Count distinct binary necklaces of prime length p.

    N(p) = (2^p + 2p - 2) / p

    By Fermat's little theorem, this is always an integer.

    Time complexity: O(log p) for the power computation.
    """
    return (pow(2, p) + 2 * p - 2) // p


def necklace_count_general(n: int) -> int:
    """
    Count distinct binary necklaces of length n (Burnside formula).

    N(n) = (1/n) · Σ_{d|n} φ(n/d) · 2^d

    Time complexity: O(d(n) · √n) where d(n) is the number of divisors.
    """
    if n <= 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += euler_totient(n // d) * pow(2, d)
    return total // n


def canonical_necklace(bits: tuple[int, ...]) -> tuple[int, ...]:
    """
    Return the canonical (lexicographically smallest) rotation of a binary string.

    Time complexity: O(n²) where n = len(bits).
    """
    n = len(bits)
    return min(bits[i:] + bits[:i] for i in range(n))


def enumerate_necklaces(n: int) -> list[tuple[int, ...]]:
    """
    Enumerate all distinct binary necklaces of length n.

    Returns necklaces in sorted order.

    Time complexity: O(2^n · n) — exponential, for small n only.
    """
    seen: set[tuple[int, ...]] = set()
    result: list[tuple[int, ...]] = []
    for bits in cartprod([0, 1], repeat=n):
        canon = canonical_necklace(bits)
        if canon not in seen:
            seen.add(canon)
            result.append(canon)
    return sorted(result)


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Rhythm Symmetry Classification
# ═══════════════════════════════════════════════════════════════

def has_kfold_symmetry(rhythm: tuple[int, ...], k: int) -> bool:
    """
    Check if a rhythm has k-fold rotational symmetry.

    A rhythm f of length n has k-fold symmetry if f(i) = f((i + n/k) mod n)
    for all i. Requires k | n.

    Time complexity: O(n).
    """
    n = len(rhythm)
    if k <= 0 or n % k != 0:
        return False
    shift = n // k
    return all(rhythm[i] == rhythm[(i + shift) % n] for i in range(n))


def symmetry_order(rhythm: tuple[int, ...]) -> int:
    """
    Find the maximum rotational symmetry order of a rhythm.

    Returns the largest k such that the rhythm has k-fold symmetry.

    Time complexity: O(n · d(n)) where d(n) is the number of divisors.
    """
    n = len(rhythm)
    max_k = 1
    for k in range(2, n + 1):
        if n % k == 0 and has_kfold_symmetry(rhythm, k):
            max_k = k
    return max_k


def is_palindromic(rhythm: tuple[int, ...]) -> bool:
    """Check if a rhythm is palindromic (mirror-symmetric)."""
    return rhythm == rhythm[::-1]


def classify_rhythm(rhythm: tuple[int, ...]) -> dict[str, object]:
    """
    Classify a rhythm by its symmetry properties.

    Returns a dictionary with symmetry information.
    """
    n = len(rhythm)
    k = symmetry_order(rhythm)
    onset = sum(rhythm)
    return {
        "length": n,
        "onset_count": onset,
        "onset_density": onset / n if n > 0 else 0,
        "symmetry_order": k,
        "is_palindromic": is_palindromic(rhythm),
        "information_bits": n // k,
        "canonical_form": canonical_necklace(rhythm),
    }


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Drum Pattern (2D) Symmetry Detection
# ═══════════════════════════════════════════════════════════════

DrumGrid = list[list[int]]  # m × n grid of 0s and 1s


def has_time_mirror(grid: DrumGrid) -> bool:
    """Check if a drum pattern has time-mirror symmetry."""
    m = len(grid)
    return all(grid[i] == grid[m - 1 - i] for i in range(m // 2 + 1))


def has_pitch_mirror(grid: DrumGrid) -> bool:
    """Check if a drum pattern has pitch-mirror symmetry."""
    if not grid:
        return True
    n = len(grid[0])
    return all(
        all(grid[i][j] == grid[i][n - 1 - j] for j in range(n // 2 + 1))
        for i in range(len(grid))
    )


def has_rotation_180(grid: DrumGrid) -> bool:
    """Check if a drum pattern has 180° rotational symmetry."""
    m = len(grid)
    if m == 0:
        return True
    n = len(grid[0])
    return all(
        grid[i][j] == grid[m - 1 - i][n - 1 - j]
        for i in range(m) for j in range(n)
    )


def classify_drum_pattern(grid: DrumGrid) -> str:
    """
    Classify a drum pattern by its 2D symmetry type.

    Returns the wallpaper type (simplified: p1, p2, pm, pmm, or pg).
    """
    tm = has_time_mirror(grid)
    pm_ = has_pitch_mirror(grid)
    r2 = has_rotation_180(grid)

    if tm and pm_:
        return "pmm"  # Double mirror (implies rotation)
    elif tm:
        return "pm (time)"
    elif pm_:
        return "pm (pitch)"
    elif r2:
        return "p2"
    else:
        return "p1"


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Wallpaper Type Database
# ═══════════════════════════════════════════════════════════════

WALLPAPER_TYPES = {
    "p1":   {"rotation_order": 1, "has_mirror": False, "has_glide": False,
             "musical_name": "Free rhythm"},
    "p2":   {"rotation_order": 2, "has_mirror": False, "has_glide": False,
             "musical_name": "Call-and-response"},
    "pm":   {"rotation_order": 1, "has_mirror": True,  "has_glide": False,
             "musical_name": "Palindrome"},
    "pg":   {"rotation_order": 1, "has_mirror": False, "has_glide": True,
             "musical_name": "Canon"},
    "cm":   {"rotation_order": 1, "has_mirror": True,  "has_glide": True,
             "musical_name": "Round"},
    "pmm":  {"rotation_order": 2, "has_mirror": True,  "has_glide": False,
             "musical_name": "Bilateral palindrome"},
    "pmg":  {"rotation_order": 2, "has_mirror": True,  "has_glide": True,
             "musical_name": "Inverted canon"},
    "pgg":  {"rotation_order": 2, "has_mirror": False, "has_glide": True,
             "musical_name": "Double canon"},
    "cmm":  {"rotation_order": 2, "has_mirror": True,  "has_glide": True,
             "musical_name": "Round + palindrome"},
    "p4":   {"rotation_order": 4, "has_mirror": False, "has_glide": False,
             "musical_name": "4-bar cycle"},
    "p4m":  {"rotation_order": 4, "has_mirror": True,  "has_glide": False,
             "musical_name": "Variations on a theme"},
    "p4g":  {"rotation_order": 4, "has_mirror": True,  "has_glide": True,
             "musical_name": "Inverted variations"},
    "p3":   {"rotation_order": 3, "has_mirror": False, "has_glide": False,
             "musical_name": "3-bar blues"},
    "p3m1": {"rotation_order": 3, "has_mirror": True,  "has_glide": False,
             "musical_name": "3-fold + mirrors"},
    "p31m": {"rotation_order": 3, "has_mirror": False, "has_glide": True,
             "musical_name": "3-fold + glides"},
    "p6":   {"rotation_order": 6, "has_mirror": False, "has_glide": False,
             "musical_name": "Whole-tone scale symmetry"},
    "p6m":  {"rotation_order": 6, "has_mirror": True,  "has_glide": True,
             "musical_name": "Maximal symmetry"},
}


if __name__ == "__main__":
    # Verify crystallographic restriction
    cryst = crystallographic_orders_up_to(2)
    print(f"Crystallographic orders (φ(n) ≤ 2): {cryst}")
    assert cryst == [1, 2, 3, 4, 6]

    # Verify necklace counts
    for p in [2, 3, 5, 7]:
        formula = necklace_count_prime(p)
        general = necklace_count_general(p)
        enumerated = len(enumerate_necklaces(p))
        assert formula == general == enumerated
        print(f"N({p}) = {formula} (verified 3 ways)")

    # Classify some rhythms
    bossa = (1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0)
    four_on_floor = (1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
    clave = (1, 0, 0, 1, 0, 0, 1, 0)

    for name, rhythm in [("Bossa nova", bossa), ("Four-on-floor", four_on_floor), ("Clave", clave)]:
        info = classify_rhythm(rhythm)
        print(f"\n{name}: {rhythm}")
        print(f"  Symmetry order: {info['symmetry_order']}")
        print(f"  Palindromic: {info['is_palindromic']}")
        print(f"  Information bits: {info['information_bits']}")

    # Double mirror theorem demo
    grid = [[1, 0, 1], [0, 1, 0], [1, 0, 1]]
    wtype = classify_drum_pattern(grid)
    print(f"\nDrum pattern {grid} → {wtype}")
    assert has_rotation_180(grid), "Double mirror should imply rotation"
    print("Double mirror → rotation verified!")
