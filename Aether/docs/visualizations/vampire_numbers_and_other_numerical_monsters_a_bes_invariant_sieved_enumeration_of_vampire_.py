"""Demo: enumerate vampire numbers by balanced digit-sharing factor pairs."""
from typing import List, Tuple


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b); n //= b
    return out


def shares_all_digits(b: int, x: int, y: int) -> bool:
    return sorted(digits(b, x) + digits(b, y)) == sorted(digits(b, x * y))


def vampires(k: int) -> List[Tuple[int, int, int]]:
    lo, hi = 10 ** (k - 1), 10 ** k - 1
    found = {}
    for x in range(lo, hi + 1):
        if x % 3 == 1:
            continue
        for y in range(x, hi + 1):
            if y % 3 == 1 or (x % 10 == 0 and y % 10 == 0):
                continue
            v = x * y
            if (x + y) % 9 != v % 9:
                continue
            if shares_all_digits(10, x, y):
                found.setdefault(v, (x, y))
    return sorted((v, a, b) for v, (a, b) in found.items())


if __name__ == "__main__":
    for v, x, y in vampires(2):
        print(f"{v} = {x} x {y}")
