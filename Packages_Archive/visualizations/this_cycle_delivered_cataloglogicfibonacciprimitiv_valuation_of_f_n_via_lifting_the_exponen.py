def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def padic_val(p: int, n: int) -> int:
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def fib_valuation_via_lte(p: int, n: int, entry: int) -> int:
    """
    Compute v_p(F_n) using the lifting-the-exponent law, given the entry point
    z(p) = entry (least k>0 with p|F_k).  If entry does not divide n, then p
    does not divide F_n and the valuation is 0; otherwise, for an odd prime p,
        v_p(F_n) = v_p(F_entry) + v_p(n / entry).
    This evaluates the valuation in O(1) Fibonacci/valuation calls instead of
    factoring the (astronomically large) number F_n.
    """
    if n % entry != 0:
        return 0
    if p == 2:  # p = 2 obeys a separate (doubling) rule; fall back to direct count
        return padic_val(2, fib(n))
    return padic_val(p, fib(entry)) + padic_val(p, n // entry)
