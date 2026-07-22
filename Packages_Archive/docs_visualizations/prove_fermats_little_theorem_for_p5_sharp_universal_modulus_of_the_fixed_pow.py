def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d: int = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True

def universal_modulus(k: int) -> int:
    m: int = 1
    for p in range(2, k + 1):
        if is_prime(p) and (k - 1) % (p - 1) == 0:
            m *= p
    return m
