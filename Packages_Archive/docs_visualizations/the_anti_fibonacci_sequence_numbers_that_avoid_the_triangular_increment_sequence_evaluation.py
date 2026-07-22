from fractions import Fraction
from typing import List

def displayed_sequence(length: int) -> List[int]:
    if length < 0:
        raise ValueError("length must be nonnegative")
    out: List[int] = []
    value = 1
    for n in range(length):
        out.append(value)
        value += n
    return out

def displayed_closed(n: int) -> int:
    if n < 0:
        raise ValueError("n must be nonnegative")
    return 1 + n * (n - 1) // 2

if __name__ == "__main__":
    values = displayed_sequence(12)
    print(values)
    assert all(v == displayed_closed(n) for n, v in enumerate(values))
    for n in (10, 100, 1000, 1_000_000):
        ratio = Fraction(displayed_closed(n), n*n)
        print(n, float(ratio))
