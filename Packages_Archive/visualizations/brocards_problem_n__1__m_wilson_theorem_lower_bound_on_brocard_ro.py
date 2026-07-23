from math import isqrt, factorial
from typing import Optional

def is_prime(p: int) -> bool:
    if p < 2:
        return False
    i: int = 2
    while i * i <= p:
        if p % i == 0:
            return False
        i += 1
    return True

def wilson_root_lower_bound(n: int) -> Optional[int]:
    """If n+1 = p is prime, return the Wilson lower bound p on any root m of
    n! + 1 = m^2 (since p | (p-1)!+1 = m^2 => p | m => m >= p). Else None."""
    p: int = n + 1
    if not is_prime(p):
        return None
    return p

def verify_wilson(n: int) -> str:
    p: Optional[int] = wilson_root_lower_bound(n)
    val: int = factorial(n) + 1
    r: int = isqrt(val)
    if p is None:
        return f"n={n}: n+1 not prime, Wilson bound N/A"
    sq: bool = r * r == val
    note: str = f", and indeed {p} | {r}" if sq else ""
    return f"n={n}: n+1={p} prime => any root m >= {p}{note}"

if __name__ == "__main__":
    for n in (4, 6, 10, 12):
        print(verify_wilson(n))
