from math import gcd, isqrt

def exhaustive_certificate(limit: int, exponents: tuple[int, ...]) -> int:
    """Return the count of perfect squares among (a^n+1)(b^n+1) over the window."""
    count = 0
    for a in range(2, limit):
        for b in range(a + 1, limit):
            if gcd(a, b) != 1:
                continue
            for n in exponents:
                N = (a**n + 1) * (b**n + 1)
                r = isqrt(N)
                if r * r == N:
                    count += 1
    return count
