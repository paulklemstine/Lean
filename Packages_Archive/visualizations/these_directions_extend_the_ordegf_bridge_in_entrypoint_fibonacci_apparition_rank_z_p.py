from typing import Optional


def entry_point(p: int, bound: int = 100000) -> Optional[int]:
    """Fibonacci entry point z(p): least m > 0 with p | F(m).
    Streams F(m) mod-free (full integers) and returns the first hit."""
    a, b = 0, 1
    for m in range(1, bound + 1):
        a, b = b, a + b
        if a % p == 0:
            return m
    return None
