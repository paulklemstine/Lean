from typing import Tuple

def fib_pair_mod(n: int, m: int) -> Tuple[int, int]:
    """
    Return (F_n mod m, F_{n+1} mod m) using fast doubling:
        F_{2k}   = F_k * (2 F_{k+1} - F_k)
        F_{2k+1} = F_{k+1}^2 + F_k^2
    Runs in O(log n) modular multiplications, enabling F_d mod p for huge d.
    """
    if m == 1:
        return (0, 0)
    if n == 0:
        return (0, 1 % m)
    a, b = fib_pair_mod(n >> 1, m)   # a = F_k, b = F_{k+1}
    c = (a * ((2 * b - a) % m)) % m   # F_{2k}
    d = (a * a + b * b) % m            # F_{2k+1}
    if n & 1:
        return (d, (c + d) % m)
    return (c, d)

def fib_mod(n: int, m: int) -> int:
    """F_n mod m."""
    return fib_pair_mod(n, m)[0]
