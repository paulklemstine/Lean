from typing import Optional

def fibonacci_entry_point(p: int, bound: Optional[int] = None) -> int:
    """
    Compute the Fibonacci entry point z(p): the least k > 0 with p | F_k.
    By the localization theorem z(p) | p^2 - 1, so the search provably
    terminates by k = p^2 - 1 (in fact by k = p + 1).
    Complexity: O(z(p)) modular steps with a rolling (F_{k-1}, F_k) pair.
    """
    if bound is None:
        bound = max(2, p * p - 1)
    m = p * p  # work mod p^2 to keep integers small while preserving p-divisibility
    a, b = 0, 1
    for k in range(1, bound + 1):
        a, b = b, (a + b) % m
        if a % p == 0:
            return k
    raise RuntimeError("no entry point within bound")
