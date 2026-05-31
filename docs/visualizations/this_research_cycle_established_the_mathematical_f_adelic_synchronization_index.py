def adelic_sync_index(c, primes):
    dists = {p: orbit_length_distribution(c, p) for p in primes}
    total, count = 0.0, 0
    for i, p in enumerate(primes):
        for j, q in enumerate(primes):
            if i < j:
                keys = set(dists[p]) | set(dists[q])
                total += sum(dists[p].get(k,0)*dists[q].get(k,0) for k in keys)
                count += 1
    return total / count if count > 0 else 0.0