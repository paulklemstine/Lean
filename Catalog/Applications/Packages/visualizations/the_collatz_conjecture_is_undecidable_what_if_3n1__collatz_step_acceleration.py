#!/usr/bin/env python3
"""
Algorithms for Collatz Undecidability Analysis

Type-hinted implementations of the key algorithms used in the research.
"""
from typing import Optional


def collatz_step(n: int) -> int:
    """Standard Collatz step: T(n) = n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_iter(n: int, k: int) -> int:
    """Apply the Collatz step k times."""
    for _ in range(k):
        n = collatz_step(n)
    return n


def stopping_time(n: int, max_steps: int = 100000) -> Optional[int]:
    """Compute the stopping time of n (steps to reach 1)."""
    for k in range(max_steps):
        if n == 1:
            return k
        n = collatz_step(n)
    return None


def peak_value(n: int) -> int:
    """Compute the peak value in the orbit of n."""
    peak = n
    while n != 1:
        n = collatz_step(n)
        peak = max(peak, n)
    return peak


def parity_word(n: int, k: int) -> list[bool]:
    """Compute the parity word (True = odd) of the first k iterates."""
    word: list[bool] = []
    val = n
    for _ in range(k):
        word.append(val % 2 == 1)
        val = collatz_step(val)
    return word


def odd_density(n: int, k: int) -> float:
    """Compute the odd-step density in the first k iterates."""
    word = parity_word(n, k)
    return sum(word) / k if k > 0 else 0.0


def mod4_accelerated_step(n: int) -> tuple[int, str]:
    """Mod-4 accelerated step: compute 2 Collatz steps in one operation.
    
    Returns (result, description).
    """
    r = n % 4
    if r == 0:
        return n // 4, "n/4 (double halving)"
    elif r == 1:
        return (3 * n + 1) // 2, "(3n+1)/2 (odd+halve)"
    elif r == 2:
        return 3 * (n // 2) + 1, "3(n/2)+1 (halve+odd)"
    else:  # r == 3
        return (3 * n + 1) // 2, "(3n+1)/2 (odd+halve)"


def mod8_accelerated_step(n: int) -> tuple[int, str]:
    """Mod-8 accelerated step: compute 3 Collatz steps for n ≡ 0,4 (mod 8)."""
    r = n % 8
    if r == 0:
        return n // 8, "n/8 (triple halving)"
    elif r == 4:
        return 3 * (n // 4) + 1, "3(n/4)+1"
    else:
        # Fall back to computing 3 steps
        return collatz_iter(n, 3), "computed"


def syracuse(n: int) -> int:
    """Syracuse (accelerated) step: for odd n, compute (3n+1)/2."""
    return (3 * n + 1) // 2


def density_contraction_check(word: list[bool]) -> bool:
    """Check if a parity word satisfies the density contraction condition.
    
    Returns True if 2 * oddCount ≤ evenCount, meaning guaranteed contraction.
    """
    odd = sum(word)
    even = len(word) - odd
    return 2 * odd <= even


def proof_resistance(n: int) -> dict[str, int]:
    """Compute the proof resistance measure for n.
    
    Returns a dict with stopping_time, peak_value, and resistance score.
    """
    import math
    st = stopping_time(n) or 0
    pk = peak_value(n) if st else 0
    log_pk = int(math.log2(pk)) + 1 if pk > 0 else 0
    return {
        "input": n,
        "stopping_time": st,
        "peak_value": pk,
        "log2_peak": log_pk,
        "resistance": st * log_pk,
    }


def gcs_apply(n: int, modulus: int,
              rules: list[tuple[int, int, int]]) -> int:
    """Apply a Generalized Collatz System.
    
    rules[r] = (mul, offset, divisor) for residue class r.
    """
    r = n % modulus
    mul, offset, divisor = rules[r]
    return (mul * n + offset) // divisor


def standard_gcs_rules() -> list[tuple[int, int, int]]:
    """The standard Collatz map as GCS rules (modulus 2)."""
    return [
        (1, 0, 2),  # even: n/2
        (3, 1, 1),  # odd: 3n+1
    ]


def verify_gcs_equivalence(n_max: int = 1000) -> bool:
    """Verify that the standard GCS agrees with collatz_step for n ∈ [1, n_max]."""
    rules = standard_gcs_rules()
    for n in range(1, n_max + 1):
        gcs_result = gcs_apply(n, 2, rules)
        step_result = collatz_step(n)
        if gcs_result != step_result:
            return False
    return True


def power_of_two_halvings(m: int, k: int) -> int:
    """Verify that iter(2^k * m, k) = m for odd m."""
    n = (2 ** k) * m
    return collatz_iter(n, k)


if __name__ == "__main__":
    # Quick test of all algorithms
    print("Testing algorithms...")
    
    # Test collatz_step
    assert collatz_step(4) == 2
    assert collatz_step(3) == 10
    
    # Test stopping_time
    assert stopping_time(1) == 0
    assert stopping_time(2) == 1
    assert stopping_time(4) == 2
    
    # Test mod4 acceleration
    assert mod4_accelerated_step(8)[0] == 2  # 8/4 = 2
    assert mod4_accelerated_step(5)[0] == 8  # (15+1)/2 = 8
    
    # Test GCS equivalence
    assert verify_gcs_equivalence(1000)
    
    # Test power of two halvings
    for m in [1, 3, 5, 7]:
        for k in range(1, 8):
            assert power_of_two_halvings(m, k) == m, \
                f"Failed for m={m}, k={k}"
    
    print("All tests passed!")
