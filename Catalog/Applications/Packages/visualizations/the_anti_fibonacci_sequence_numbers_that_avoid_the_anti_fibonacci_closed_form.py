def anti_fib(n: int) -> int:
    """O(1) computation of the n-th anti-Fibonacci term."""
    return n + n // 2 + 1