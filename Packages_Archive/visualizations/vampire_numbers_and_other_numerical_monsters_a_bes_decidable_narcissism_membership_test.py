from typing import List

def digits(n: int) -> List[int]:
    """Base-ten digits of n, least-significant first."""
    out: List[int] = []
    while n > 0:
        out.append(n % 10)
        n //= 10
    return out

def is_narcissistic(n: int) -> bool:
    """Return True iff n equals the sum of its digits each raised to the
    power equal to the digit count (Theorem 3.6: decidable membership)."""
    ds = digits(n)
    d = len(ds)
    return n == sum(a ** d for a in ds)
