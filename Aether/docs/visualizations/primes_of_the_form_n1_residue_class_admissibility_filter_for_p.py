from math import isqrt
from typing import List

def admissible_prime_factors(bound: int) -> List[int]:
    """List primes that CAN divide some n^2+1: only 2 and primes p ≡ 1 (mod 4).

    Implements the Great Filter (not_dvd_of_three_mod_four): primes p ≡ 3 (mod 4)
    are excluded a priori. Complexity: O(bound log log bound) via a sieve.
    """
    if bound < 2:
        return []
    sieve = bytearray([1]) * (bound + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, isqrt(bound) + 1):
        if sieve[i]:
            sieve[i*i:bound+1:i] = bytearray(len(range(i*i, bound+1, i)))
    return [p for p in range(2, bound + 1) if sieve[p] and (p == 2 or p % 4 == 1)]
