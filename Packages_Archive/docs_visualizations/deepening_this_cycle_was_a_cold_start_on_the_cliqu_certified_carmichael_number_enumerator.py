from typing import Dict, List, Tuple

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n % 2 == 0: return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0: return False
        d += 2
    return True

def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    m, d = n, 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def is_korselt(n: int) -> bool:
    if n <= 1 or is_prime(n):
        return False
    factors = factorize(n)
    if any(e > 1 for e in factors.values()):
        return False
    return all((n - 1) % (p - 1) == 0 for p in factors)

def enumerate_carmichael(limit: int) -> List[Tuple[int, List[int], List[Tuple[int, int, int]]]]:
    """Return Carmichael numbers < limit with Korselt certificates."""
    result: List[Tuple[int, List[int], List[Tuple[int, int, int]]]] = []
    for n in range(3, limit, 2):
        if is_korselt(n):
            primes = sorted(factorize(n).keys())
            cert = [(p, p - 1, (n - 1) // (p - 1)) for p in primes]
            result.append((n, primes, cert))
    return result

if __name__ == "__main__":
    for n, primes, cert in enumerate_carmichael(10000):
        print(n, "=", " * ".join(map(str, primes)), "| cert:", cert)
