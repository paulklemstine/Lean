import math

def sieve_certified(limit):
    """Sieve of Eratosthenes with certified √limit bound."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    sieve_bound = math.isqrt(limit)
    for p in range(2, sieve_bound + 1):
        if is_prime[p]:
            for m in range(p * p, limit + 1, p):
                is_prime[m] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

# Example
primes = sieve_certified(100)
print(f'Primes up to 100: {primes}')
print(f'Count: {len(primes)}')
print(f'Sieve bound: {math.isqrt(100)} (certified by theorem)')