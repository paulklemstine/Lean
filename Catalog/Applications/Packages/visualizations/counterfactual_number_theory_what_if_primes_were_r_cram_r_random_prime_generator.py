def cramer_random_primes(N, seed=None):
    import math, random
    if seed: random.seed(seed)
    return {n for n in range(2, N+1) if random.random() < 1/math.log(n)}