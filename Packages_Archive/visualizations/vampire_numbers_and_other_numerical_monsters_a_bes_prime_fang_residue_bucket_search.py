from math import isqrt
from typing import List, Tuple

def prime(n: int) -> bool:
    if n < 2: return False
    return all(n % d for d in range(2, isqrt(n) + 1))

def admissible_prime_pairs(limit: int) -> List[Tuple[int, int]]:
    ps = [p for p in range(2, limit + 1) if prime(p)]
    allowed = {(2, 2), (5, 8), (8, 5)}
    return [(p, q) for p in ps for q in ps if (p % 9, q % 9) in allowed]

if __name__ == "__main__":
    pairs = admissible_prime_pairs(50)
    assert all((p * q) % 9 == 4 for p, q in pairs)
    print(len(pairs), "admissible ordered prime pairs")
