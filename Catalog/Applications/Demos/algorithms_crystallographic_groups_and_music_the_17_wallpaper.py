#!/usr/bin/env python3
"""
Crystallographic Rhythm Theory: Core Algorithms

Type-hinted implementations of the key algorithms for:
1. Rhythmic Interaction Tensor computation
2. Autocorrelation spectrum analysis
3. Wallpaper symmetry detection for 2D drum patterns
4. Rhythm classification by symmetry type
"""
from typing import List, Tuple, Dict, Set, Optional
from enum import Enum
import math


class WallpaperType(Enum):
    """The 17 wallpaper group types with their musical interpretations."""
    P1 = ("p1", 1, False, False, "Free rhythm")
    P2 = ("p2", 2, False, False, "Call-and-response")
    PM = ("pm", 1, True, False, "Palindrome")
    PG = ("pg", 1, False, True, "Canon")
    CM = ("cm", 1, True, True, "Round")
    PMM = ("pmm", 2, True, False, "Bilateral palindrome")
    PMG = ("pmg", 2, True, True, "Inverted canon")
    PGG = ("pgg", 2, False, True, "Double canon")
    CMM = ("cmm", 2, True, True, "Round + palindrome")
    P4 = ("p4", 4, False, False, "4-bar cycle")
    P4M = ("p4m", 4, True, False, "Variations on a theme")
    P4G = ("p4g", 4, True, True, "Inverted variations")
    P3 = ("p3", 3, False, False, "3-bar blues")
    P3M1 = ("p3m1", 3, True, False, "3-fold + mirrors")
    P31M = ("p31m", 3, True, True, "3-fold + glides")
    P6 = ("p6", 6, False, False, "Whole-tone symmetry")
    P6M = ("p6m", 6, True, True, "Maximal symmetry")

    def __init__(self, name: str, rot_order: int,
                 has_mirror: bool, has_glide: bool, description: str):
        self.type_name = name
        self.rot_order = rot_order
        self.has_mirror = has_mirror
        self.has_glide = has_glide
        self.description = description


def compute_rit(f: List[int], g: List[int]) -> List[int]:
    """
    Compute the Rhythmic Interaction Tensor I(f,g).

    Algorithm: For each lag k in {0, ..., n-1}, count positions j
    where f[j] = 1 and g[(j+k) mod n] = 1.

    Time complexity: O(n²)

    Args:
        f: First rhythm as binary list
        g: Second rhythm as binary list

    Returns:
        List of n interaction values I(f,g)(0), ..., I(f,g)(n-1)
    """
    n = len(f)
    assert len(g) == n, "Rhythms must have the same period"
    result = []
    for k in range(n):
        count = sum(f[j] * g[(j + k) % n] for j in range(n))
        result.append(count)
    return result


def compute_autocorrelation(rhythm: List[int]) -> List[int]:
    """
    Compute the autocorrelation spectrum R(k) = I(f,f)(k).

    The autocorrelation is always palindromic: R(k) = R(n-k).

    Args:
        rhythm: Binary rhythm as list of 0s and 1s

    Returns:
        Autocorrelation values R(0), ..., R(n-1)
    """
    return compute_rit(rhythm, rhythm)


def detect_rotation_symmetry(rhythm: List[int]) -> List[int]:
    """
    Find all rotation symmetry shifts of a cyclic rhythm.

    A shift s is a symmetry if f[(j+s) mod n] = f[j] for all j.

    Args:
        rhythm: Binary rhythm

    Returns:
        List of symmetry shifts (always includes 0)
    """
    n = len(rhythm)
    shifts = []
    for s in range(n):
        if all(rhythm[(j + s) % n] == rhythm[j] for j in range(n)):
            shifts.append(s)
    return shifts


def detect_mirror_symmetry(rhythm: List[int]) -> bool:
    """Check if rhythm equals its retrograde."""
    n = len(rhythm)
    return all(rhythm[j] == rhythm[(-j) % n] for j in range(n))


def classify_1d_symmetry(rhythm: List[int]) -> Dict[str, any]:
    """
    Classify the symmetry profile of a 1D cyclic rhythm.

    Returns dict with:
    - weight: onset count
    - rotation_shifts: list of symmetry shifts
    - rotation_order: order of the rotation subgroup
    - is_palindromic: whether rhythm has mirror symmetry
    - min_period: minimal period
    """
    n = len(rhythm)
    shifts = detect_rotation_symmetry(rhythm)
    rot_order = len(shifts)
    min_period = n // rot_order if rot_order > 0 else n

    return {
        "weight": sum(rhythm),
        "rotation_shifts": shifts,
        "rotation_order": rot_order,
        "is_palindromic": detect_mirror_symmetry(rhythm),
        "min_period": min_period,
    }


def classify_2d_symmetry(
    grid: List[List[int]]
) -> Dict[str, bool]:
    """
    Classify symmetry of a 2D drum pattern (m × n grid).

    Detects:
    - time_mirror: g(-t, p) = g(t, p) for all t, p
    - pitch_mirror: g(t, -p) = g(t, p) for all t, p
    - rotation_2: g(-t, -p) = g(t, p) for all t, p

    Args:
        grid: 2D binary array (list of lists)

    Returns:
        Dict of detected symmetries
    """
    m = len(grid)
    if m == 0:
        return {"time_mirror": True, "pitch_mirror": True, "rotation_2": True}
    n = len(grid[0])

    time_mirror = all(
        grid[(-t) % m][p] == grid[t][p]
        for t in range(m) for p in range(n)
    )
    pitch_mirror = all(
        grid[t][(-p) % n] == grid[t][p]
        for t in range(m) for p in range(n)
    )
    rotation_2 = all(
        grid[(-t) % m][(-p) % n] == grid[t][p]
        for t in range(m) for p in range(n)
    )

    return {
        "time_mirror": time_mirror,
        "pitch_mirror": pitch_mirror,
        "rotation_2": rotation_2,
        "double_mirror_implies_rotation": (
            not (time_mirror and pitch_mirror) or rotation_2
        ),
    }


def verify_interaction_properties(
    f: List[int], g: List[int]
) -> Dict[str, bool]:
    """
    Verify the key algebraic properties of the Rhythmic Interaction Tensor.

    Checks:
    1. Skew symmetry: I(f,g)(k) = I(g,f)(-k)
    2. Weight product sum: Σ I(f,g)(k) = w(f)·w(g)
    3. Autocorrelation palindromicity (for self-interaction)
    4. Weight-square sum (for self-interaction)

    Args:
        f, g: Binary rhythms of the same period

    Returns:
        Dict mapping property names to verification results
    """
    n = len(f)
    I_fg = compute_rit(f, g)
    I_gf = compute_rit(g, f)
    R_f = compute_autocorrelation(f)
    w_f = sum(f)
    w_g = sum(g)

    return {
        "skew_symmetry": all(
            I_fg[k] == I_gf[(-k) % n] for k in range(n)
        ),
        "weight_product_sum": sum(I_fg) == w_f * w_g,
        "autocorr_palindromic": all(
            R_f[k] == R_f[(-k) % n] for k in range(n)
        ),
        "weight_square_sum": sum(R_f) == w_f ** 2,
    }


def necklace_count(n: int) -> int:
    """
    Count distinct binary necklaces of length n (rhythms up to rotation).

    Uses Burnside's lemma: (1/n) Σ_{d|n} φ(n/d) · 2^d

    This counts the number of essentially different cyclic rhythms.
    """
    if n == 0:
        return 1

    def euler_phi(k: int) -> int:
        result = k
        p = 2
        temp = k
        while p * p <= temp:
            if temp % p == 0:
                while temp % p == 0:
                    temp //= p
                result -= result // p
            p += 1
        if temp > 1:
            result -= result // temp
        return result

    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += euler_phi(n // d) * (2 ** d)
    return total // n


if __name__ == "__main__":
    # Verify all properties on example rhythms
    print("=== Algorithmic Verification ===\n")

    # Son Clave pattern
    clave = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]
    print(f"Son Clave: {clave}")
    sym = classify_1d_symmetry(clave)
    print(f"  Symmetry: {sym}")

    # 3-against-4 polyrhythm
    f3 = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]
    f4 = [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]
    props = verify_interaction_properties(f3, f4)
    print(f"\n3-vs-4 polyrhythm interaction properties:")
    for name, ok in props.items():
        print(f"  {name}: {'✓' if ok else '✗'}")

    # Necklace counting
    print("\nDistinct cyclic rhythms by period:")
    for n in range(1, 17):
        print(f"  n={n:2d}: {necklace_count(n):6d} necklaces")

    # 2D grid classification
    grid = [[1,0,0,1], [0,1,1,0], [0,1,1,0], [1,0,0,1]]
    print(f"\n4×4 symmetric grid classification:")
    for k, v in classify_2d_symmetry(grid).items():
        print(f"  {k}: {v}")
