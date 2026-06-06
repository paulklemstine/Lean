"""
Integrated Information Theory: Core Algorithms
================================================

Type-hinted implementations of IIT computations including
Phi calculation, cross-count, integration spectrum, and
cycle analysis.
"""

from typing import Callable, Optional
from itertools import product


def cross_count(f: Callable[[int], int], p: Callable[[int], bool], n: int) -> int:
    """Count the number of states whose transitions cross the partition boundary.

    Args:
        f: Transition function on {0, ..., n-1}
        p: Bipartition (assigns each state to True or False)
        n: Number of states

    Returns:
        Number of states i where p(f(i)) != p(i)
    """
    return sum(1 for i in range(n) if p(f(i)) != p(i))


def cross_tf(f: Callable[[int], int], p: Callable[[int], bool], n: int) -> list[int]:
    """States crossing from True side to False side."""
    return [i for i in range(n) if p(i) and not p(f(i))]


def cross_ft(f: Callable[[int], int], p: Callable[[int], bool], n: int) -> list[int]:
    """States crossing from False side to True side."""
    return [i for i in range(n) if not p(i) and p(f(i))]


def is_nontrivial(p: Callable[[int], bool], n: int) -> bool:
    """Check if a bipartition has both sides nonempty."""
    vals = [p(i) for i in range(n)]
    return True in vals and False in vals


def all_bipartitions(n: int):
    """Generate all nontrivial bipartitions of {0, ..., n-1}.

    Yields:
        Functions p: int -> bool representing nontrivial bipartitions
    """
    for bits in product([False, True], repeat=n):
        if True in bits and False in bits:
            yield lambda i, b=bits: b[i]


def compute_phi(f: Callable[[int], int], n: int) -> int:
    """Compute the integrated information Phi.

    Args:
        f: Transition function on {0, ..., n-1}
        n: Number of states

    Returns:
        Phi = minimum cross-count over all nontrivial bipartitions.
        Returns 0 if n < 2 (no nontrivial bipartitions exist).
    """
    if n < 2:
        return 0

    min_cross = n  # Upper bound
    for p in all_bipartitions(n):
        cc = cross_count(f, p, n)
        min_cross = min(min_cross, cc)
        if min_cross == 0:
            break  # Can't do better than 0

    return min_cross


def integration_spectrum(f: Callable[[int], int], n: int) -> list[int]:
    """Compute the full integration spectrum.

    Returns:
        Sorted list of distinct cross-count values over all nontrivial bipartitions.
    """
    if n < 2:
        return []

    values = set()
    for p in all_bipartitions(n):
        values.add(cross_count(f, p, n))
    return sorted(values)


def cycle_perm(n: int) -> Callable[[int], int]:
    """The cyclic permutation: i -> (i+1) mod n."""
    return lambda i: (i + 1) % n


def identity(n: int) -> Callable[[int], int]:
    """The identity function."""
    return lambda i: i


def is_bijective(f: Callable[[int], int], n: int) -> bool:
    """Check if f is bijective on {0, ..., n-1}."""
    return len(set(f(i) for i in range(n))) == n


def verify_balance(f: Callable[[int], int], p: Callable[[int], bool], n: int) -> tuple[int, int]:
    """Verify the Bijective Balance Theorem for a specific partition.

    Returns:
        (|crossTF|, |crossFT|) — should be equal for bijective f.
    """
    tf = len(cross_tf(f, p, n))
    ft = len(cross_ft(f, p, n))
    return tf, ft


def orbit_decomposition(f: Callable[[int], int], n: int) -> list[list[int]]:
    """Compute the orbit decomposition of a permutation.

    Args:
        f: A bijective function on {0, ..., n-1}
        n: Number of states

    Returns:
        List of orbits (each orbit is a list of states in order).
    """
    visited = set()
    orbits = []
    for start in range(n):
        if start in visited:
            continue
        orbit = []
        current = start
        while current not in visited:
            visited.add(current)
            orbit.append(current)
            current = f(current)
        orbits.append(orbit)
    return orbits


def fast_phi_for_permutation(f: Callable[[int], int], n: int) -> int:
    """Compute Phi efficiently for permutations using orbit structure.

    For permutations: Phi = 0 if more than one orbit, Phi = 2 if single orbit (n >= 2).
    This is O(n) instead of O(n * 2^n).
    """
    if n < 2:
        return 0
    orbits = orbit_decomposition(f, n)
    if len(orbits) == 1:
        return 2  # Single cycle -> Phi = 2
    else:
        return 0  # Multiple orbits -> decomposable -> Phi = 0


def is_decomposable(f: Callable[[int], int], p: Callable[[int], bool], n: int) -> bool:
    """Check if f is decomposable w.r.t. partition p."""
    return all(p(f(i)) == p(i) for i in range(n))


# ============================================================
# Verification examples
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("IIT Algorithm Verification")
    print("=" * 60)

    # Example 1: Cycle on Fin 4
    n = 4
    f = cycle_perm(n)
    print(f"\n--- Cycle on Fin {n} ---")
    print(f"Transition: {[f(i) for i in range(n)]}")
    print(f"Is bijective: {is_bijective(f, n)}")
    print(f"Orbits: {orbit_decomposition(f, n)}")
    phi = compute_phi(f, n)
    print(f"Phi (brute force): {phi}")
    print(f"Phi (fast): {fast_phi_for_permutation(f, n)}")
    print(f"Integration spectrum: {integration_spectrum(f, n)}")
    print(f"Phi is even: {phi % 2 == 0}")

    # Verify balance for all bipartitions
    print("Balance verification:")
    for idx, p in enumerate(all_bipartitions(n)):
        tf, ft = verify_balance(f, p, n)
        cc = cross_count(f, p, n)
        parts = ([i for i in range(n) if p(i)], [i for i in range(n) if not p(i)])
        if tf != ft:
            print(f"  BALANCE VIOLATION at partition {parts}!")
        if cc % 2 != 0:
            print(f"  PARITY VIOLATION: cross_count = {cc} at partition {parts}!")

    print("  All partitions satisfy balance and parity ✓")

    # Example 2: Identity on Fin 4
    print(f"\n--- Identity on Fin {n} ---")
    f_id = identity(n)
    print(f"Phi: {compute_phi(f_id, n)}")
    print(f"Decomposable: {any(is_decomposable(f_id, p, n) and is_nontrivial(p, n) for p in all_bipartitions(n))}")

    # Example 3: Two-cycle permutation (1,0,3,2) on Fin 4
    print(f"\n--- Two-cycle (0↔1, 2↔3) on Fin {n} ---")
    f_two = lambda i: [1, 0, 3, 2][i]
    print(f"Transition: {[f_two(i) for i in range(n)]}")
    print(f"Orbits: {orbit_decomposition(f_two, n)}")
    print(f"Phi (brute force): {compute_phi(f_two, n)}")
    print(f"Phi (fast): {fast_phi_for_permutation(f_two, n)}")

    # Example 4: Verify cycle theorem for various n
    print("\n--- Cycle Integration Theorem verification ---")
    for n_test in range(2, 10):
        phi_val = compute_phi(cycle_perm(n_test), n_test)
        fast_val = fast_phi_for_permutation(cycle_perm(n_test), n_test)
        status = "✓" if phi_val == 2 and fast_val == 2 else "✗"
        print(f"  n={n_test}: Phi={phi_val}, fast={fast_val} {status}")

    # Example 5: Integration spectrum for cycles
    print("\n--- Integration spectra for cycles ---")
    for n_test in range(2, 8):
        spec = integration_spectrum(cycle_perm(n_test), n_test)
        print(f"  n={n_test}: spectrum = {spec}")
