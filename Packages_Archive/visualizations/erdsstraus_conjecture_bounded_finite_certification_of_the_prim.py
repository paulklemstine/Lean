from fractions import Fraction
from typing import Dict, List, Optional, Tuple

Triple = Tuple[int, int, int]

def primes_up_to(N: int) -> List[int]:
    sieve = [True] * N
    sieve[0:2] = [False, False]
    for i in range(2, int(N ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N, i):
                sieve[j] = False
    return [i for i in range(N) if sieve[i]]

def search_prime_witness(p: int) -> Optional[Triple]:
    target = Fraction(4, p)
    for x in range(p // 4 + 1, 3 * p // 4 + 3):
        rem = target - Fraction(1, x)
        if rem <= 0:
            continue
        a, c = rem.numerator, rem.denominator
        for y in range(c // a + 1, 2 * c // a + 2):
            second = rem - Fraction(1, y)
            if second > 0 and second.numerator == 1:
                return (x, y, second.denominator)
    return None

def certify(N: int) -> Dict[int, Triple]:
    hard = [p for p in primes_up_to(N) if p % 8 == 1]
    table: Dict[int, Triple] = {}
    for p in hard:
        t = search_prime_witness(p)
        assert t is not None
        x, y, z = t
        assert 4 * x * y * z == p * (x * y + y * z + z * x)
        table[p] = t
    return table
