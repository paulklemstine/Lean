def anti_fib_closed(n: int) -> int:
    """O(1) computation of the n-th anti-Fibonacci number."""
    return n * (n - 1) // 2 + 1