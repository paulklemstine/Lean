from typing import Callable

DigitStream = Callable[[int], int]

def count_digit(s: DigitStream, d: int, n: int) -> int:
    """countDigit(s, d, n): number of indices k < n with s(k) == d.  O(n)."""
    return sum(1 for k in range(n) if s(k) == d)

def freq(s: DigitStream, d: int, n: int) -> float:
    """Empirical frequency; junk value 0.0 at n == 0."""
    return count_digit(s, d, n) / n if n else 0.0

def frequency_vector(s: DigitStream, b: int, n: int) -> list[float]:
    """The point (freq(s,0,n), ..., freq(s,b-1,n)) of the simplex Delta^{b-1}."""
    return [freq(s, d, n) for d in range(b)]
