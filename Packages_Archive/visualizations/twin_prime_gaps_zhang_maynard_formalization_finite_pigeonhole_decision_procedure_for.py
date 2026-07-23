from __future__ import annotations
from typing import Optional


def primes_upto(limit: int) -> list[int]:
    """All primes <= limit by the sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(limit ** 0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i in range(limit + 1) if sieve[i]]


def missing_residue(H: list[int], p: int) -> Optional[int]:
    """Return a residue class mod p missed by H, else None (the pigeonhole witness)."""
    hit = {h % p for h in H}
    for r in range(p):
        if r not in hit:
            return r
    return None


def is_admissible(H: list[int]) -> bool:
    """
    Decide admissibility via isAdmissible_iff_small_primes:
    H is admissible iff every prime p <= |H| misses a residue class.
    The infinite quantifier over primes collapses to primes p <= |H|
    because (pigeonhole) any prime p > |H| automatically misses a class.
    """
    k = len(set(H))
    for p in primes_upto(k):
        if missing_residue(H, p) is None:
            return False
    return True
