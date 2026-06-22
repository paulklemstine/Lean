from typing import Dict, Optional

def least_primitive_prime_divisor(n: int) -> Optional[int]:
    """Least primitive prime divisor of F(n), or None (n in {1,2,6,12})."""
    fn = fib(n)
    if fn <= 1:
        return None
    for p in sorted(factorize(fn)):
        if is_prime(p) and fib_mod(n, p) == 0 and fib_entry(p) == n:
            return p
    return None
