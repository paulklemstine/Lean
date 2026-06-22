from typing import Callable, Optional

def divides_value(a: Callable[[int], int], p: int, n: int,
                  cached_entry: Optional[int] = None) -> bool:
    """Decide p | a(n) using the bridge p | a(n) <=> z(p) | n.
    After z(p) is computed once, each query costs a single modular test --
    no further evaluation of the (possibly huge) sequence value a(n)."""
    z = cached_entry
    if z is None:
        k = 1
        while a(k) % p != 0:
            k += 1
        z = k
    return n % z == 0
