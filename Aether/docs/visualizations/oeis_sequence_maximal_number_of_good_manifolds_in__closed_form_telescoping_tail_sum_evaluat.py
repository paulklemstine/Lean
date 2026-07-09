def tail_sum_closed(N: int) -> int:
    """Return sum_{k=7}^N a(k) = 2^(N+1) - 2^7 in O(log N) time.

    Uses the telescoping identity to avoid the linear-time explicit sum.
    Requires N >= 7 (the regular tail).
    """
    if N < 7:
        raise ValueError("closed tail sum requires N >= 7")
    return 2 ** (N + 1) - 2 ** 7
