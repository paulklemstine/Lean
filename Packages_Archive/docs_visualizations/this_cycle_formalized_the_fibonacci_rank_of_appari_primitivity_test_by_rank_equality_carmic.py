def is_primitive_bridge(m: int, n: int) -> bool:
    """m is a primitive divisor of F(n) iff rank(m) == n."""
    if m <= 0 or n <= 0:
        return False
    return fib_rank_direct(m) == n
