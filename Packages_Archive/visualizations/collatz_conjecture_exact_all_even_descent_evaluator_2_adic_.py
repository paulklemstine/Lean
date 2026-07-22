def T(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def all_even_run_length(n: int) -> int:
    """Largest k with the first k iterates of n all even (= 2-adic valuation of n)."""
    k = 0
    while n > 0 and n % 2 == 0:
        n //= 2; k += 1
    return k

def all_even_descent_value(n: int) -> int:
    """Compute T^[k](n) for the maximal even run length k; equals n // 2**k."""
    k = all_even_run_length(n)
    return n // (2 ** k)
