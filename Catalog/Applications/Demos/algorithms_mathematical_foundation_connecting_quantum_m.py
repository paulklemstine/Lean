#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for quantum shell mathematics

Type-hinted implementations of the key algorithms from the research.
"""

from math import comb
from typing import Iterator


def orbital_degeneracy(l: int) -> int:
    """Number of quantum states in subshell with azimuthal number l.
    
    This equals 2(2l+1): factor (2l+1) for magnetic quantum numbers
    m = -l, ..., +l, and factor 2 for spin up/down.
    
    Args:
        l: Azimuthal quantum number (non-negative integer)
    Returns:
        Number of quantum states: 2(2l+1)
    """
    return 2 * (2 * l + 1)


def shell_capacity(n: int) -> int:
    """Total electron capacity of shell n (principal quantum number).
    
    Sums orbital_degeneracy(l) for l = 0, 1, ..., n-1.
    Result equals 2n² by the Pythagorean sum-of-odd-numbers identity.
    
    Args:
        n: Principal quantum number (positive integer)
    Returns:
        Shell capacity: 2n²
    """
    return sum(orbital_degeneracy(l) for l in range(n))


def madelung_key(n: int, l: int) -> tuple[int, int]:
    """Sorting key for Madelung filling order.
    
    Returns (n+l, n) so lexicographic sorting produces the Madelung order.
    
    Args:
        n: Principal quantum number
        l: Azimuthal quantum number
    Returns:
        Tuple (n+l, n) for sorting
    """
    return (n + l, n)


def enumerate_subshells(max_group: int) -> list[tuple[int, int, int]]:
    """Enumerate electron subshells in Madelung filling order.
    
    Args:
        max_group: Maximum value of n+l to include
    Returns:
        List of (n, l, capacity) tuples in filling order
    """
    subshells: list[tuple[int, int, int]] = []
    for g in range(1, max_group + 1):
        for n in range(1, g + 1):
            l = g - n
            if 0 <= l <= n - 1:
                subshells.append((n, l, orbital_degeneracy(l)))
    return subshells


def electron_configuration(Z: int) -> dict[str, int]:
    """Compute the ground-state electron configuration for element Z
    using the Madelung filling rule.
    
    Args:
        Z: Atomic number (number of electrons for neutral atom)
    Returns:
        Dictionary mapping subshell labels (e.g., '1s', '2p') to electron counts
    """
    orbital_names = {0: 's', 1: 'p', 2: 'd', 3: 'f', 4: 'g', 5: 'h'}
    config: dict[str, int] = {}
    remaining = Z
    for n, l, cap in enumerate_subshells(20):
        if remaining <= 0:
            break
        fill = min(remaining, cap)
        label = f"{n}{orbital_names.get(l, f'[{l}]')}"
        config[label] = fill
        remaining -= fill
    return config


def ho_shell_degeneracy(N: int) -> int:
    """Degeneracy of the N-th 3D harmonic oscillator shell (without spin).
    
    Equals C(N+2, 2) = (N+1)(N+2)/2.
    
    Args:
        N: Shell quantum number (non-negative integer)
    Returns:
        Number of orbital states: (N+1)(N+2)/2
    """
    return comb(N + 2, 2)


def magic_numbers_ho(max_shell: int) -> list[int]:
    """Compute harmonic oscillator magic numbers (with spin degeneracy).
    
    These are the cumulative spin-doubled shell capacities:
    2 * sum_{k=0}^{N} C(k+2, 2) = 2 * C(N+3, 3)
    
    Args:
        max_shell: Maximum shell number N
    Returns:
        List of magic numbers [2*C(3,3), 2*C(4,3), ..., 2*C(max_shell+3,3)]
    """
    return [2 * comb(N + 3, 3) for N in range(max_shell + 1)]


def period_boundaries(max_z: int) -> list[int]:
    """Compute period boundaries (noble gas atomic numbers) up to max_z.
    
    Uses the Madelung filling order to determine where each period ends.
    A period ends when a p-subshell is completely filled (for periods > 1)
    or when 1s is filled (for period 1).
    
    Args:
        max_z: Maximum atomic number to consider
    Returns:
        List of atomic numbers at period boundaries
    """
    boundaries: list[int] = []
    cumulative = 0
    for n, l, cap in enumerate_subshells(20):
        cumulative += cap
        if cumulative > max_z:
            break
        # Period ends at s-filling for period 1, p-filling for later periods
        if (l == 0 and n == 1) or l == 1:
            boundaries.append(cumulative)
    return boundaries


def spectral_shell_partition(multiplicities: list[int], z: int) -> int:
    """Find which period (shell) element z belongs to.
    
    Given a sequence of shell multiplicities (capacities), determines
    the unique shell index n such that cumulative(n-1) < z <= cumulative(n).
    
    Args:
        multiplicities: List of positive shell capacities
        z: Element number (positive integer)
    Returns:
        Shell index (0-indexed)
    Raises:
        ValueError: If z exceeds total capacity
    """
    if z <= 0:
        raise ValueError("z must be positive")
    cumulative = 0
    for i, m in enumerate(multiplicities):
        cumulative += m
        if z <= cumulative:
            return i
    raise ValueError(f"z={z} exceeds total capacity {cumulative}")


def madelung_compare(p: tuple[int, int], q: tuple[int, int]) -> int:
    """Compare two pairs under the Madelung ordering.
    
    Returns:
        -1 if p <_M q, 0 if p = q, +1 if q <_M p
    """
    sp, sq = p[0] + p[1], q[0] + q[1]
    if sp < sq:
        return -1
    elif sp > sq:
        return 1
    elif p[0] < q[0]:
        return -1
    elif p[0] > q[0]:
        return 1
    else:
        return 0


if __name__ == "__main__":
    # Quick self-test
    assert shell_capacity(1) == 2
    assert shell_capacity(2) == 8
    assert shell_capacity(3) == 18
    assert shell_capacity(4) == 32

    assert magic_numbers_ho(5) == [2, 8, 20, 40, 70, 112]

    config = electron_configuration(26)  # Iron
    print(f"Iron (Z=26): {config}")

    boundaries = period_boundaries(118)
    print(f"Period boundaries: {boundaries}")
    print(f"Period lengths: {[b - (boundaries[i-1] if i > 0 else 0) for i, b in enumerate(boundaries)]}")

    print("All self-tests passed.")
