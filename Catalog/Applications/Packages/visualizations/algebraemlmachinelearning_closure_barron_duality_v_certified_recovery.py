def certified_recovery(lattice, oracle):
    """Recover functional from oracle queries on JI only."""
    ji = lattice.join_irreducibles()
    weights = {j: oracle(j) for j in ji}
    def f_hat(K):
        vals = [weights[j] for j in ji if lattice.le(j, K)]
        return max(vals) if vals else 0
    return f_hat, weights