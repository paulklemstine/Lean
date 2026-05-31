def verify_cramer(bound: int):
    primes = sieve(bound + 1000)
    for i in range(len(primes) - 1):
        p = primes[i]
        if 11 <= p <= bound:
            gap = primes[i+1] - p
            if gap > math.log(p)**2:
                return (False, p)
    return (True, None)