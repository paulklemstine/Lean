def reconstruct_at(lattice, weights, K):
    """Reconstruct f(K) from canonical weights."""
    vals = [weights[j] for j in lattice.join_irreducibles() if lattice.le(j, K)]
    return max(vals) if vals else 0