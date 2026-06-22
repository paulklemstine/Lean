from typing import List

def decimal_digits(n: int) -> List[int]:
    """Base-10 digits of n (little-endian); digits(0) == []."""
    if n == 0:
        return []
    out: List[int] = []
    while n > 0:
        out.append(n % 10)
        n //= 10
    return out

def is_narcissistic(n: int) -> bool:
    """True iff n equals the sum of its digits each raised to the digit count."""
    ds = decimal_digits(n)
    length = len(ds)
    return n == sum(d ** length for d in ds)

def narcissistic_up_to(limit: int) -> List[int]:
    """Return every narcissistic number n with 0 <= n < limit, in order."""
    return [n for n in range(limit) if is_narcissistic(n)]
