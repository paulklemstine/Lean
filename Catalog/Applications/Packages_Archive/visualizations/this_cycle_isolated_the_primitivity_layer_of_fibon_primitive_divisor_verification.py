from typing import Callable

Seq = Callable[[int], int]

def is_primitive(u: Seq, p: int, n: int) -> bool:
    """p is a primitive divisor of u(n): p | u(n) but p | no u(k), 0<k<n."""
    vn = u(n)
    if not (vn == 0 or vn % p == 0):
        return False
    return all(not (u(k) != 0 and u(k) % p == 0) for k in range(1, n))
