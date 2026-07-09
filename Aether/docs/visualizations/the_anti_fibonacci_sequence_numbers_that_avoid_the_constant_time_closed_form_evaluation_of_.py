from typing import List

def anti_fib_closed(n: int) -> int:
    """Exact value A(n) = (n^2 - n + 2) / 2 in O(1) integer operations."""
    return (n * n - n + 2) // 2

def anti_fib_table(count: int) -> List[int]:
    """Return [A(0), ..., A(count-1)] using the closed form."""
    return [anti_fib_closed(n) for n in range(count)]
