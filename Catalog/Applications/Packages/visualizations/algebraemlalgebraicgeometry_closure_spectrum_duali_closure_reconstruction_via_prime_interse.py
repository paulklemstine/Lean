def reconstruct_closure(A, primes, G):
    """Reconstruct Cl(A) as intersection of primes containing A."""
    containing = [P for P in primes if A <= P]
    if not containing:
        return frozenset(G)
    result = frozenset(G)
    for P in containing:
        result = result & P
    return result