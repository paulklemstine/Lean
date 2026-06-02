def cramer_model(N, seed=None):
    import random, math
    rng = random.Random(seed)
    return {n for n in range(2, N+1) if rng.random() < 1.0/math.log(n)}