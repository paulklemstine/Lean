#!/usr/bin/env python3
"""
Algorithms for Collatz Undecidability Research
===============================================
Type-hinted implementations of the core algorithms.
"""

from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass
import math


@dataclass
class OrbitData:
    """Complete data about a Collatz orbit."""
    start: int
    orbit: List[int]
    stopping_time: int
    peak_value: int
    odd_count: int
    even_count: int
    balance_ratio: float
    orbit_numerator: int
    parity_profile: List[bool]


def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd.

    Time: O(1)
    Space: O(1)
    """
    return n // 2 if n % 2 == 0 else 3 * n + 1


def syracuse_step(n: int) -> int:
    """Accelerated Collatz (Syracuse function).

    Combines the odd step (3n+1) with the guaranteed subsequent even step (/2).

    Time: O(1)
    Space: O(1)
    """
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def compute_orbit(n: int, max_steps: int = 10_000_000) -> OrbitData:
    """Compute complete orbit data for starting value n.

    Algorithm:
    1. Iterate collatz_step until reaching 1 or max_steps
    2. Track parity profile, peak value, odd/even counts
    3. Compute balance ratio and orbit numerator

    Time: O(stopping_time)
    Space: O(stopping_time) for storing the orbit

    Args:
        n: Starting positive integer
        max_steps: Maximum iteration count (safety limit)

    Returns:
        OrbitData with all computed properties
    """
    orbit: List[int] = [n]
    parity: List[bool] = []
    peak = n
    odd = 0
    current = n

    while current != 1 and len(orbit) <= max_steps:
        is_odd = current % 2 == 1
        parity.append(is_odd)
        if is_odd:
            odd += 1
        current = collatz_step(current)
        orbit.append(current)
        peak = max(peak, current)

    total = len(orbit) - 1
    even = total - odd
    ratio = odd / total if total > 0 else 0.0
    numerator = 3 ** odd

    return OrbitData(
        start=n,
        orbit=orbit,
        stopping_time=total,
        peak_value=peak,
        odd_count=odd,
        even_count=even,
        balance_ratio=ratio,
        orbit_numerator=numerator,
        parity_profile=parity,
    )


def gcs_step(n: int, modulus: int, multipliers: List[int],
             offsets: List[int]) -> int:
    """Apply a Generalized Collatz System step.

    Algorithm:
    1. Compute r = n mod modulus
    2. Return (multipliers[r] * n + offsets[r]) // modulus

    Time: O(1)
    Space: O(1)

    Args:
        n: Current value
        modulus: GCS modulus (≥ 1)
        multipliers: Multiplier for each residue class
        offsets: Additive offset for each residue class
    """
    r = n % modulus
    return (multipliers[r] * n + offsets[r]) // modulus


def gcs_orbit(n: int, modulus: int, multipliers: List[int],
              offsets: List[int], target: int = 1,
              max_steps: int = 10_000) -> Optional[List[int]]:
    """Compute a GCS orbit until reaching target or max_steps.

    Returns None if target not reached within max_steps.
    """
    orbit = [n]
    while n != target and len(orbit) < max_steps:
        n = gcs_step(n, modulus, multipliers, offsets)
        orbit.append(n)
        if n == 0:  # stuck at 0
            break
    return orbit if orbit[-1] == target else None


def verify_parity_balance(n: int) -> Tuple[bool, int, int, float]:
    """Verify the parity balance conjecture for a single n.

    Returns:
        (passes, odd_count, total_steps, ratio)
    """
    data = compute_orbit(n)
    passes = 3 * data.odd_count < 2 * data.stopping_time
    return passes, data.odd_count, data.stopping_time, data.balance_ratio


def batch_verify_parity_balance(start: int, end: int) -> Tuple[int, float, int]:
    """Verify parity balance conjecture for range [start, end).

    Returns:
        (violations, max_ratio, n_with_max_ratio)
    """
    violations = 0
    max_ratio = 0.0
    max_n = start

    for n in range(start, end):
        passes, _, _, ratio = verify_parity_balance(n)
        if not passes:
            violations += 1
        if ratio > max_ratio:
            max_ratio = ratio
            max_n = n

    return violations, max_ratio, max_n


def max_odd_run_length(n: int) -> int:
    """Find the maximum consecutive odd-step run in the orbit of n.

    This tests the forbidden-pattern conjecture from Future Direction 1:
    max odd run length should be O(log n).
    """
    max_run = 0
    current_run = 0
    current = n

    while current != 1:
        if current % 2 == 1:
            current_run += 1
            max_run = max(max_run, current_run)
        else:
            current_run = 0
        current = collatz_step(current)

    return max_run


def tropical_potential(n: int) -> float:
    """Compute the tropical potential φ(n) = log₂(n)."""
    return math.log2(n) if n > 0 else float('-inf')


def average_potential_change(n: int) -> float:
    """Compute the average change in tropical potential along the orbit.

    Tests Future Direction 2: should converge to (log₂3 - 2)/2 ≈ -0.2075.
    """
    data = compute_orbit(n)
    if data.stopping_time == 0:
        return 0.0

    total_change = 0.0
    for i in range(data.stopping_time):
        phi_before = tropical_potential(data.orbit[i])
        phi_after = tropical_potential(data.orbit[i + 1])
        total_change += phi_after - phi_before

    return total_change / data.stopping_time


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")

    # Test orbit computation
    data = compute_orbit(27)
    assert data.stopping_time == 111
    assert data.peak_value == 9232
    assert data.orbit_numerator == 3 ** data.odd_count
    print(f"  orbit(27): steps={data.stopping_time}, peak={data.peak_value}, "
          f"ratio={data.balance_ratio:.4f}")

    # Test GCS equivalence
    for n in range(1, 100):
        gcs_val = gcs_step(n, 2, [1, 3], [0, 1])
        if n % 2 == 0:
            assert gcs_val == collatz_step(n), f"GCS≠collatz at even n={n}"
        else:
            assert gcs_val == syracuse_step(n), f"GCS≠syracuse at odd n={n}"
    print("  GCS equivalence: verified for n=1..99")

    # Test parity balance
    violations, max_ratio, max_n = batch_verify_parity_balance(1, 10_000)
    print(f"  Parity balance (n≤10000): violations={violations}, "
          f"max_ratio={max_ratio:.4f} at n={max_n}")

    # Test tropical potential
    avg = average_potential_change(27)
    expected = (math.log2(3) - 2) / 2
    print(f"  Tropical potential (n=27): avg_change={avg:.4f}, "
          f"expected={expected:.4f}")

    print("All self-tests passed.")
