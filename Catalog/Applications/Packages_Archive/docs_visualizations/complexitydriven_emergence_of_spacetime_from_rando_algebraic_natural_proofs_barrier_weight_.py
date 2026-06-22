def barrier_min_weight(exp_const: int, n: int) -> int:
    """Algorithm C: algebraic natural-proofs barrier weight estimator (Theorem 11).

    Given the hard-class exponent c = exp_const (>= 1) and problem level n (>= 1),
    returns the certified lower bound 2**(c*n) on the weight ceiling maxWeight of
    ANY sound bounded-weight separator that distinguishes hard(n) from easy(n).
    No separator with maxWeight below this value can succeed.
    """
    assert exp_const >= 1 and n >= 1
    return 2 ** (exp_const * n)
