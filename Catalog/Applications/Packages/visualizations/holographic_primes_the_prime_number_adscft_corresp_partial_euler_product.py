import math
def euler_product(s: float, N: int) -> float:
    sieve = [True]*(N+1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5)+1):
        if sieve[i]:
            for j in range(i*i, N+1, i): sieve[j] = False
    prod = 1.0
    for p in range(2, N+1):
        if sieve[p]: prod /= (1.0 - p**(-s))
    return prod