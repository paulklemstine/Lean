def component_staircase(primes):
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    unique_gaps = sorted(set(gaps))
    return [(0, len(primes))] + [(eps, 1 + sum(1 for g in gaps if g > eps)) for eps in unique_gaps]