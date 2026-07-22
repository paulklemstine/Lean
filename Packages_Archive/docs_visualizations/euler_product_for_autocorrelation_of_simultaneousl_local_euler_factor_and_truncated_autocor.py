from math import gcd
from typing import Iterable, Sequence, Tuple

Vec = Tuple[int, ...]

def primes_up_to(n: int) -> list[int]:
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(2, n + 1) if sieve[i]]

def reduce_mod(p: int, w: Sequence[int]) -> Vec:
    return tuple(c % p for c in w)

def local_factor(S: Iterable[Vec], z: Vec, p: int, k: int) -> float:
    """f_p(z) = 1 - |S_p ∪ (S - z)_p| / p^k."""
    S = list(S)
    residues: set[Vec] = set()
    for s in S:
        residues.add(reduce_mod(p, s))
        residues.add(reduce_mod(p, tuple(si + zi for si, zi in zip(s, z))))
    return 1.0 - len(residues) / (p ** k)

def truncated_autocorrelation(S: Iterable[Vec], z: Vec, k: int, bound: int) -> float:
    """prod_{p <= bound} f_p(z); error <= 2|S| * sum_{p>bound} p^{-k}."""
    S = list(S)
    prod = 1.0
    for p in primes_up_to(bound):
        prod *= local_factor(S, z, p, k)
    return prod
