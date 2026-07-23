from math import sqrt

PHI: float = (1.0 + sqrt(5.0)) / 2.0

def is_chain_encodable(n: int) -> bool:
    """True iff D_c(n) = 1 + n/10 < phi, i.e. n < N_critical = 7."""
    return 1.0 + n / 10.0 < PHI
