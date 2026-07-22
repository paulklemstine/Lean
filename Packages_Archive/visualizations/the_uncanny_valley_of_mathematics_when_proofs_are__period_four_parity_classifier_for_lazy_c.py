def caterer_is_odd(n: int) -> bool:
    """True iff the lazy caterer number p(n) is odd, by the period-4 parity law."""
    return n % 4 == 0 or n % 4 == 3
