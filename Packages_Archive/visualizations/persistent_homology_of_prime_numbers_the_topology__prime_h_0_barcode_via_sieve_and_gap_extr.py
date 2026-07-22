from typing import List


def sieve_of_eratosthenes(bound: int) -> List[int]:
    """All primes <= bound in O(bound log log bound) time."""
    if bound < 2:
        return []
    sieve = bytearray([1]) * (bound + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(bound ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:bound + 1:i] = b"\x00" * len(range(i * i, bound + 1, i))
    return [i for i in range(2, bound + 1) if sieve[i]]


def prime_h0_barcode(bound: int) -> List[int]:
    """Finite H_0 barcode of the prime cloud up to `bound`.

    By the Single-Linkage / Adjacent-Merge theorems the i-th finite bar has
    death scale equal to the i-th prime gap p_{i+1} - p_i, so the barcode is
    exactly the list of consecutive gaps.
    """
    primes = sieve_of_eratosthenes(bound)
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]
