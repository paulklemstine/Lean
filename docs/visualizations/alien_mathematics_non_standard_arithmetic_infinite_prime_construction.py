def infinite_prime_seq(n):
    primes = []
    candidate = 2
    while len(primes) <= n:
        if all(candidate % p != 0 for p in primes if p*p <= candidate):
            primes.append(candidate)
        candidate += 1
    return primes[n]