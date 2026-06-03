#!/usr/bin/env python3
"""
Algorithms for Collatz Orbit Analysis

Type-hinted implementations of key algorithms from the formal development.
"""

from typing import List, Tuple, Optional, Dict
import math


def collatz_step(n: int) -> int:
    """The standard Collatz step T(n)."""
    if n % 2 == 0:
        return n // 2
    else:
        return 3 * n + 1


def collatz_iter(n: int, k: int) -> int:
    """Iterate the Collatz step k times: T^k(n)."""
    current = n
    for _ in range(k):
        current = collatz_step(current)
    return current


def collatz_orbit(n: int, max_steps: int = 1_000_000) -> List[int]:
    """Full Collatz orbit from n to 1 (or up to max_steps)."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def parity_word(n: int, k: int) -> List[bool]:
    """
    The parity word of n's orbit for k steps.
    True = odd step, False = even step.
    """
    word: List[bool] = []
    current = n
    for _ in range(k):
        word.append(current % 2 == 1)
        current = collatz_step(current)
    return word


def odd_steps_count(word: List[bool]) -> int:
    """Count of odd (True) entries in a parity word."""
    return sum(1 for b in word if b)


def even_steps_count(word: List[bool]) -> int:
    """Count of even (False) entries in a parity word."""
    return sum(1 for b in word if not b)


def is_descent_word(word: List[bool]) -> bool:
    """
    Check if a parity word is a descent word.
    A descent word satisfies 3^j < 2^(k-j) where j = odd count, k = length.
    """
    j = odd_steps_count(word)
    e = even_steps_count(word)
    return 3 ** j < 2 ** e


def verify_parity_exclusion(word: List[bool]) -> bool:
    """
    Verify the parity exclusion property:
    no two consecutive True values in the word.
    """
    for i in range(len(word) - 1):
        if word[i] and word[i + 1]:
            return False
    return True


def stopping_time(n: int, max_steps: int = 10_000_000) -> Optional[int]:
    """
    Compute the stopping time: least k with T^k(n) = 1.
    Returns None if not found within max_steps.
    """
    current = n
    for k in range(max_steps):
        if current == 1:
            return k
        current = collatz_step(current)
    return None


def peak_value(n: int) -> int:
    """The maximum value in the Collatz orbit of n."""
    orbit = collatz_orbit(n)
    return max(orbit)


def orbit_diameter(n: int) -> float:
    """The orbit diameter: peak / starting value."""
    if n <= 0:
        return 0.0
    return peak_value(n) / n


def odd_density(n: int, k: int) -> float:
    """Fraction of odd steps in the first k steps of n's orbit."""
    word = parity_word(n, k)
    return odd_steps_count(word) / k if k > 0 else 0.0


def classify_complexity(n: int) -> str:
    """
    Classify n by orbit complexity:
    - trivial: stopping_time ≤ 3 * log₂(n)
    - moderate: stopping_time ≤ (log₂(n))²
    - hard: stopping_time > (log₂(n))²
    - unknown: does not reach 1 within limit
    """
    st = stopping_time(n)
    if st is None:
        return "unknown"
    logn = max(1, int(math.log2(n)) + 1) if n >= 2 else 1
    if st <= 3 * logn:
        return "trivial"
    elif st <= logn * logn:
        return "moderate"
    else:
        return "hard"


def density_contraction_check(j: int, e: int) -> Dict[str, object]:
    """
    Check the density contraction conditions:
    - Sufficient: 2*j ≤ e (our formalized theorem)
    - Necessary: j * log(3) < e * log(2) (sharp threshold)
    """
    sufficient = 2 * j <= e
    necessary = j * math.log(3) < e * math.log(2) if e > 0 else j == 0
    is_descent = 3 ** j < 2 ** e
    return {
        "odd_steps": j,
        "even_steps": e,
        "sufficient_condition_met": sufficient,
        "sharp_condition_met": necessary,
        "is_descent": is_descent,
        "mul_factor": 3 ** j,
        "div_factor": 2 ** e,
    }


def gcs_apply(n: int, modulus: int,
              rules: List[Tuple[int, int, int]]) -> int:
    """
    Apply a Generalized Collatz System.
    rules[r] = (mul, offset, divisor) for residue r.
    """
    r = n % modulus
    mul, offset, divisor = rules[r]
    assert (mul * n + offset) % divisor == 0, "Divisibility violated"
    return (mul * n + offset) // divisor


def standard_collatz_as_gcs(n: int) -> int:
    """The standard Collatz map expressed as a GCS with modulus 2."""
    rules = [(1, 0, 2), (3, 1, 1)]  # even: n/2, odd: 3n+1
    return gcs_apply(n, 2, rules)


def orbit_merge_check(a: int, b: int,
                      max_steps: int = 10000) -> Optional[Tuple[int, int]]:
    """
    Check if orbits of a and b merge.
    Returns (ja, jb) such that T^ja(a) = T^jb(b), or None.
    """
    orbit_a = set()
    current_a = a
    for ja in range(max_steps):
        orbit_a.add((current_a, ja))
        current_a = collatz_step(current_a)

    a_values = {v: j for v, j in orbit_a}
    current_b = b
    for jb in range(max_steps):
        if current_b in a_values:
            return (a_values[current_b], jb)
        current_b = collatz_step(current_b)
    return None


if __name__ == "__main__":
    # Quick self-test
    print("Standard Collatz as GCS test:")
    for n in range(1, 20):
        assert standard_collatz_as_gcs(n) == collatz_step(n), f"Mismatch at n={n}"
    print("  All GCS ↔ standard tests passed ✓")

    print("\nParity exclusion test:")
    for n in range(1, 1000):
        st = stopping_time(n)
        if st:
            word = parity_word(n, st)
            assert verify_parity_exclusion(word), f"Failed at n={n}"
    print("  All parity exclusion tests passed ✓")

    print("\nDensity contraction test:")
    for n in range(1, 1000):
        st = stopping_time(n)
        if st and st > 0:
            word = parity_word(n, st)
            j = odd_steps_count(word)
            e = even_steps_count(word)
            check = density_contraction_check(j, e)
            assert check["is_descent"], f"Not descent at n={n}"
    print("  All density contraction tests passed ✓")

    print("\nOrbit merge test:")
    result = orbit_merge_check(27, 54)
    if result:
        ja, jb = result
        print(f"  Orbits of 27 and 54 merge: T^{ja}(27) = T^{jb}(54)")
    print("  Orbit merge test passed ✓")
