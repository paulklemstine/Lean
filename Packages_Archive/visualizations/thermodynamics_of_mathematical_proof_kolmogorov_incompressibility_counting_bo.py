def incompressible(n: int) -> bool:
    """Kolmogorov counting bound: no injection from the 2**n predicates on an
    n-element register into the 2**n - 1 programs of length < n.

    Returns True iff 2**n > (2**n - 1), i.e. always (for n >= 1): some predicate
    has no description shorter than n bits, so its verification erases >= n bits.
    """
    num_predicates: int = 2 ** n
    num_short_programs: int = sum(2 ** k for k in range(n))  # = 2**n - 1
    return num_predicates > num_short_programs
