from typing import Optional, Tuple

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True

def find_goldbach_pair(n: int) -> Optional[Tuple[int, int]]:
    fuel, k = n, 2
    while fuel > 0:
        fuel -= 1
        if k > n:
            return None
        if is_prime(k) and is_prime(n - k):
            return (k, n - k)
        k += 1
    return None
