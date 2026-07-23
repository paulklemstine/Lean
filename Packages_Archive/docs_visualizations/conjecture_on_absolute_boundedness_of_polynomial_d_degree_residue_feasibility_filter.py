def same_degree_feasible(d: int, k: int, deg_n: int) -> bool:
    """Return False when a same-degree D_k(n) family is provably impossible.

    d      : common degree of the members
    k      : the power exponent (>= 1)
    deg_n  : degree of the shift n (use -1 for the zero shift)
    """
    if d < 1:
        return True          # constants place no degree constraint
    if deg_n >= 2 * d:
        return True          # leading terms may cancel; rigidity does not apply
    return (2 * d) % k == 0  # the degree rigidity law  k | 2d
