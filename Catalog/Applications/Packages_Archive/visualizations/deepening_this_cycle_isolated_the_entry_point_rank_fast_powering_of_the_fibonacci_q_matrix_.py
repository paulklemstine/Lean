from typing import Tuple

def fib_pair_mod(k: int, m: int) -> Tuple[int, int]:
    """Return (F_k mod m, F_{k+1} mod m) via fast doubling = fast powering of
    the Fibonacci matrix Q. O(log k) ring operations."""
    def fd(n: int) -> Tuple[int, int]:
        if n == 0:
            return (0 % m, 1 % m)
        a, b = fd(n >> 1)
        c = (a * ((2 * b - a) % m)) % m      # F_{2i}
        d = (a * a + b * b) % m              # F_{2i+1}
        return (d, (c + d) % m) if (n & 1) else (c, d)
    return fd(k)

def shift_pow_apply(a: int, b: int, k: int, m: int) -> Tuple[int, int]:
    """Closed form Q^k(a,b) = (a(F_{k+1}-F_k)+b F_k, a F_k + b F_{k+1})."""
    fk, fk1 = fib_pair_mod(k, m)
    first = (a * ((fk1 - fk) % m) + b * fk) % m
    second = (a * fk + b * fk1) % m
    return (first, second)
