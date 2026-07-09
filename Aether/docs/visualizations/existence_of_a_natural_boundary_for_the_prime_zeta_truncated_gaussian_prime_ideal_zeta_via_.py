from typing import List, Literal

SplitType = Literal["ramified", "split", "inert"]


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes: all primes p <= n."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i : n + 1 : i] = bytearray(len(range(i * i, n + 1, i)))
    return [i for i in range(2, n + 1) if sieve[i]]


def splitting_type(p: int) -> SplitType:
    """Classify a rational prime by its splitting in Z[i] (depends on p mod 4)."""
    if p == 2:
        return "ramified"
    return "split" if p % 4 == 1 else "inert"


def gauss_term(s: float, p: int) -> float:
    """Per-prime contribution of P_{Q(i)}(s) using the splitting law."""
    kind = splitting_type(p)
    if kind == "ramified":
        return 2.0 ** (-s)
    if kind == "split":
        return 2.0 * (p ** (-s))
    return p ** (-2.0 * s)


def gauss_prime_zeta_partial(s: float, n: int) -> float:
    """Truncated Gaussian prime-ideal zeta: sum of gauss_term over primes p <= n."""
    return sum(gauss_term(s, p) for p in primes_up_to(n))
